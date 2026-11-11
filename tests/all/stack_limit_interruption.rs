#![cfg(not(miri))]

use crate::async_functions::CountPending;
use std::future::Future;
use std::pin::Pin;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::task::{Context, Poll};
use std::time::Duration;
use wasmtime::format_err;
use wasmtime::*;
use wasmtime_test_macros::wasmtime_test;

fn build_engine(config: &mut Config) -> Result<Engine> {
    config.stack_limit_interruption(true);
    Engine::new(config)
}

/// Interrupts `handle` from another thread after `delay`.
fn interrupt_after(handle: StoreInterruptHandle, delay: Duration) {
    std::thread::spawn(move || {
        std::thread::sleep(delay);
        handle.interrupt();
    });
}

const INFINITE_LOOP: &str = r#"
    (module
        (func (export "run")
            (loop $l
                (br $l))))
"#;

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn infinite_loop_yields_then_errors(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, INFINITE_LOOP)?;
    let mut store = Store::new(&engine, 0_u32);
    store.interrupt_callback(|mut cx| {
        *cx.data_mut() += 1;
        if *cx.data() == 1 {
            Ok(InterruptAction::Yield)
        } else {
            Err(format_err!("interrupted twice"))
        }
    });
    let handle = store.interrupt_handle()?;
    // The first interrupt yields; the second, sent once the guest has resumed
    // into the same loop, ends the call with the callback's error.
    std::thread::spawn(move || {
        std::thread::sleep(Duration::from_millis(50));
        handle.interrupt();
        std::thread::sleep(Duration::from_millis(50));
        handle.interrupt();
    });

    let instance = Instance::new_async(&mut store, &module, &[]).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    let (result, yields) = CountPending::new(Box::pin(run.call_async(&mut store, ()))).await;
    let error = result.expect_err("an infinite loop only ends through the interrupt callback");
    assert_eq!(error.root_cause().to_string(), "interrupted twice");
    assert_eq!(yields, 1);
    assert_eq!(*store.data(), 2);
    Ok(())
}

/// Polls the inner future and, the first time it yields, requests another
/// interruption while the guest is suspended on its fiber.
struct InterruptWhileSuspended<F> {
    future: F,
    handle: StoreInterruptHandle,
    yielded: bool,
}

impl<F: Future + Unpin> Future for InterruptWhileSuspended<F> {
    type Output = F::Output;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<F::Output> {
        let poll = Pin::new(&mut self.future).poll(cx);
        if poll.is_pending() && !self.yielded {
            self.yielded = true;
            self.handle.interrupt();
        }
        poll
    }
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn interrupt_while_suspended_is_delivered_on_resume(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, INFINITE_LOOP)?;
    let mut store = Store::new(&engine, 0_u32);
    store.interrupt_callback(|mut cx| {
        *cx.data_mut() += 1;
        if *cx.data() == 1 {
            Ok(InterruptAction::Yield)
        } else {
            Err(format_err!("delivered after resume"))
        }
    });
    let handle = store.interrupt_handle()?;
    handle.interrupt();

    // Should the request made while suspended be lost, the loop would never
    // end; this late interrupt bounds the test and is told apart by its flag.
    let late = Arc::new(AtomicBool::new(false));
    {
        let late = late.clone();
        let handle = handle.clone();
        std::thread::spawn(move || {
            std::thread::sleep(Duration::from_secs(10));
            late.store(true, Ordering::SeqCst);
            handle.interrupt();
        });
    }

    let instance = Instance::new_async(&mut store, &module, &[]).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    let result = InterruptWhileSuspended {
        future: Box::pin(run.call_async(&mut store, ())),
        handle,
        yielded: false,
    }
    .await;
    let error = result.expect_err("an infinite loop only ends through the interrupt callback");
    assert_eq!(error.root_cause().to_string(), "delivered after resume");
    assert!(
        !late.load(Ordering::SeqCst),
        "the interrupt requested while suspended was lost"
    );
    assert_eq!(*store.data(), 2);
    Ok(())
}

/// A call tree with no loops: ten calls at each of nine levels, a billion
/// calls in all. Only the function-entry check can interrupt it.
fn call_tree() -> String {
    let mut wat = String::from("(module\n(func (export \"run\")");
    wat.push_str(&" call $f1".repeat(10));
    wat.push_str(")\n");
    for level in 1..9 {
        wat.push_str(&format!("(func $f{level}"));
        wat.push_str(&format!(" call $f{}", level + 1).repeat(10));
        wat.push_str(")\n");
    }
    wat.push_str("(func $f9))");
    wat
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn call_tree_interrupted_at_function_entry(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, call_tree())?;
    // No callback: an interruption traps with `Trap::Interrupt`.
    let mut store = Store::new(&engine, ());
    interrupt_after(store.interrupt_handle()?, Duration::from_millis(50));

    let instance = Instance::new_async(&mut store, &module, &[]).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    let error = run
        .call_async(&mut store, ())
        .await
        .expect_err("a billion calls outlast the 50 ms interrupt");
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::Interrupt));
    Ok(())
}

const UNBOUNDED_RECURSION: &str = r#"
    (module
        (func $f (export "run")
            call $f))
"#;

#[wasmtime_test(strategies(not(CraneliftPulley)))]
fn unbounded_recursion_overflows(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, UNBOUNDED_RECURSION)?;
    let mut store = Store::new(&engine, 0_u32);
    store.interrupt_callback(|mut cx| {
        *cx.data_mut() += 1;
        Ok(InterruptAction::Continue)
    });
    let instance = Instance::new(&mut store, &module, &[])?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;

    // No interrupt: the failed check reaches the builtin with nothing pending
    // and raises the ordinary stack-overflow trap.
    let error = run.call(&mut store, ()).unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert_eq!(*store.data(), 0);

    // An interrupt pending on entry is delivered first, and the overflow is
    // still reported as one afterwards.
    store.interrupt_handle()?.interrupt();
    let error = run.call(&mut store, ()).unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert_eq!(*store.data(), 1);

    // The store still runs wasm normally after both overflows.
    let error = run.call(&mut store, ()).unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert_eq!(*store.data(), 1);
    Ok(())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn unbounded_recursion_overflows_while_interrupted(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, UNBOUNDED_RECURSION)?;
    let mut store = Store::new(&engine, 0_u32);
    // Every check re-arms another interrupt, so the guest overflows with an
    // interrupt pending at every function entry.
    let handle = store.interrupt_handle()?;
    store.interrupt_callback(move |mut cx| {
        *cx.data_mut() += 1;
        handle.interrupt();
        Ok(InterruptAction::Continue)
    });
    store.interrupt_handle()?.interrupt();

    let instance = Instance::new_async(&mut store, &module, &[]).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    let error = run.call_async(&mut store, ()).await.unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert!(*store.data() > 1);
    Ok(())
}

/// The name of the innermost wasm frame of a trap's backtrace.
fn innermost_frame(error: &Error) -> Option<&str> {
    error
        .downcast_ref::<WasmBacktrace>()
        .expect("traps carry a wasm backtrace")
        .frames()
        .first()
        .and_then(|frame| frame.func_name())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
fn call_free_leaf_is_interrupted_at_its_loop_header(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    // `$spin` calls no wasm, so its entry has no interruption check: the
    // interrupt can only be taken at its loop header.
    let module = Module::new(
        &engine,
        r#"
        (module
            (func $spin (param i32) (result i32)
                (loop $l
                    (local.set 0 (i32.add (local.get 0) (i32.const 1)))
                    (br $l))
                (local.get 0))
            (func (export "run") (result i32)
                (call $spin (i32.const 0))))
        "#,
    )?;
    // No callback: an interruption traps with `Trap::Interrupt`.
    let mut store = Store::new(&engine, ());
    interrupt_after(store.interrupt_handle()?, Duration::from_millis(50));

    let instance = Instance::new(&mut store, &module, &[])?;
    let run = instance.get_typed_func::<(), i32>(&mut store, "run")?;
    let error = run
        .call(&mut store, ())
        .expect_err("an infinite loop only ends through the interrupt");
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::Interrupt));
    assert_eq!(innermost_frame(&error), Some("spin"));
    Ok(())
}

/// Unbounded recursion through `$f`, which first calls `$wide`: a function
/// that calls no wasm and keeps sixty-four values live at once, so its frame
/// is larger than one level of the recursion and its prologue check is the
/// one that finds the stack exhausted. `poke` runs one interruptible entry
/// check and nothing else.
fn recursion_through_wide_leaf() -> String {
    let loads: String = (0..64)
        .map(|i| format!(" (i64.load offset={} (i32.const 0))", i * 8))
        .collect();
    let adds = " i64.add".repeat(63);
    format!(
        r#"
        (module
            (memory 1)
            (func $wide (result i64){loads}{adds})
            (func $f (export "run")
                (drop (call $wide))
                (call $f))
            (func (export "poke")
                (call $nothing))
            (func $nothing))
        "#
    )
}

#[derive(Default)]
struct Interrupts {
    delivered: u32,
    rearm: bool,
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
fn call_free_leaf_overflow_traps_with_and_without_an_interrupt(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, recursion_through_wide_leaf())?;
    let mut store = Store::new(&engine, Interrupts::default());
    let handle = store.interrupt_handle()?;
    store.interrupt_callback(move |mut cx| {
        cx.data_mut().delivered += 1;
        if cx.data().rearm {
            handle.interrupt();
        }
        Ok(InterruptAction::Continue)
    });
    let instance = Instance::new(&mut store, &module, &[])?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    let poke = instance.get_typed_func::<(), ()>(&mut store, "poke")?;

    // No interrupt: the leaf's check against the real limit traps.
    let error = run.call(&mut store, ()).unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert_eq!(innermost_frame(&error), Some("wide"));
    assert_eq!(store.data().delivered, 0);

    // An interrupt pending on entry is delivered at `$f`'s first entry, and
    // the overflow is still reported as one.
    store.interrupt_handle()?.interrupt();
    let error = run.call(&mut store, ()).unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert_eq!(innermost_frame(&error), Some("wide"));
    assert_eq!(store.data().delivered, 1);

    // Every delivery re-arms another interrupt, so one is pending when the
    // leaf's check finds the stack exhausted. That check never sees the
    // sentinel: it reports the overflow, and the interrupt stays pending.
    store.data_mut().rearm = true;
    store.interrupt_handle()?.interrupt();
    let error = run.call(&mut store, ()).unwrap_err();
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    assert_eq!(innermost_frame(&error), Some("wide"));
    let delivered = store.data().delivered;
    assert!(delivered > 2);

    // The interrupt left pending by the overflow is delivered at the next
    // check, not swallowed.
    store.data_mut().rearm = false;
    poke.call(&mut store, ())?;
    assert_eq!(store.data().delivered, delivered + 1);
    poke.call(&mut store, ())?;
    assert_eq!(store.data().delivered, delivered + 1);
    Ok(())
}

#[derive(Default)]
struct Marks(Vec<&'static str>);

#[wasmtime_test(strategies(not(CraneliftPulley)))]
fn interrupt_during_host_call_is_delivered_on_return(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(
        &engine,
        r#"
        (module
            (import "" "interrupt" (func $interrupt))
            (import "" "after" (func $after))
            (func (export "run")
                call $interrupt
                ;; The interrupt is observed at this function's entry, the
                ;; first check after the host call returns. `$check` calls
                ;; wasm: a function that calls none has no entry check.
                call $check
                call $after)
            (func $check
                call $leaf)
            (func $leaf))
        "#,
    )?;
    let mut store = Store::new(&engine, Marks::default());
    store.interrupt_callback(|mut cx| {
        cx.data_mut().0.push("interrupt");
        Ok(InterruptAction::Continue)
    });
    let handle = store.interrupt_handle()?;

    let mut linker = Linker::new(&engine);
    linker.func_wrap("", "interrupt", move |mut cx: Caller<'_, Marks>| {
        cx.data_mut().0.push("host");
        handle.interrupt();
    })?;
    linker.func_wrap("", "after", |mut cx: Caller<'_, Marks>| {
        cx.data_mut().0.push("after");
    })?;
    let instance = linker.instantiate(&mut store, &module)?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    run.call(&mut store, ())?;
    assert_eq!(store.data().0, ["host", "interrupt", "after"]);
    Ok(())
}

#[test]
fn interrupt_handle_requires_the_knob() -> Result<()> {
    let engine = Engine::default();
    let store = Store::new(&engine, ());
    let error = store.interrupt_handle().unwrap_err();
    assert!(
        error.to_string().contains("stack_limit_interruption"),
        "{error}"
    );
    Ok(())
}

fn per_processor_config(offset: i32) -> Config {
    let mut config = Config::new();
    config.stack_limit_interruption(true);
    config.stack_limit_location(StackLimitLocation::PerProcessor { offset });
    config
}

#[test]
fn a_per_processor_limit_requires_stack_limit_interruption() {
    let mut config = Config::new();
    config.stack_limit_location(StackLimitLocation::PerProcessor { offset: 16 });
    let error = Engine::new(&config).unwrap_err();
    assert_eq!(
        error.to_string(),
        "`stack_limit_location(StackLimitLocation::PerProcessor { .. })` requires \
         `stack_limit_interruption`"
    );
}

#[test]
fn a_per_processor_limit_refuses_a_target_without_a_thread_pointer_block() -> Result<()> {
    let mut config = per_processor_config(16);
    config.target("s390x-unknown-linux-gnu")?;
    let error = Engine::new(&config).unwrap_err();
    assert_eq!(
        error.to_string(),
        "a per-processor stack limit is not supported on s390x-unknown-linux-gnu: only \
         x86-64, AArch64 and RISC-V 64 address a processor-local block"
    );
    Ok(())
}

#[test]
fn a_per_processor_limit_refuses_an_unaligned_offset() {
    let error = Engine::new(&per_processor_config(12)).unwrap_err();
    assert_eq!(
        error.to_string(),
        "the per-processor stack limit offset 12 is not a multiple of the pointer size"
    );
}

#[test]
fn precompiled_code_must_agree_on_the_limit_location() -> Result<()> {
    let per_processor = Engine::new(&per_processor_config(16))?;
    let store_context = build_engine(&mut Config::new())?;

    let compiled = per_processor.precompile_module(b"(module)")?;
    let error = unsafe { Module::deserialize(&store_context, &compiled) }.unwrap_err();
    assert_eq!(
        error.root_cause().to_string(),
        "module was compiled to read the stack limit in the processor-local word at offset 16 \
         however the host keeps it in the store context"
    );
    Ok(())
}

#[test]
fn a_std_build_does_not_run_per_processor_code() -> Result<()> {
    let engine = Engine::new(&per_processor_config(16))?;
    let error = Module::new(&engine, "(module)").unwrap_err();
    assert!(
        format!("{error:?}").contains("a per-processor stack limit needs a custom platform"),
        "{error:?}"
    );
    Ok(())
}

#[test]
fn stack_limit_interruption_refuses_epochs() {
    let mut config = Config::new();
    config.stack_limit_interruption(true);
    config.epoch_interruption(true);
    let error = Engine::new(&config).unwrap_err();
    assert_eq!(
        error.to_string(),
        "`stack_limit_interruption` and `epoch_interruption` cannot both be enabled"
    );
}

#[test]
fn precompiled_code_must_agree_on_the_knob() -> Result<()> {
    let mut config = Config::new();
    config.stack_limit_interruption(true);
    let with_knob = Engine::new(&config)?;
    let without_knob = Engine::default();

    let compiled_without = without_knob.precompile_module(b"(module)")?;
    let error = unsafe { Module::deserialize(&with_knob, &compiled_without) }.unwrap_err();
    assert_eq!(
        error.root_cause().to_string(),
        "Module was compiled without stack-limit interruption but it is enabled for the host"
    );

    let compiled_with = with_knob.precompile_module(b"(module)")?;
    let error = unsafe { Module::deserialize(&without_knob, &compiled_with) }.unwrap_err();
    assert_eq!(
        error.root_cause().to_string(),
        "Module was compiled with stack-limit interruption but it is not enabled for the host"
    );
    Ok(())
}

/// A loop that keeps integer and floating-point values live across both
/// kinds of interruption check: its own loop header, and the entry of
/// `$step`, which calls wasm and so carries the resumable entry check, with
/// its parameters live across it.
const LIVE_ACROSS_CHECKS: &str = r#"
    (module
        (func $trunc (param f64) (result i64)
            (i64.trunc_f64_s (local.get 0)))
        (func $step (param i64 f64) (result i64)
            (i64.add (local.get 0) (call $trunc (local.get 1))))
        (func (export "run") (param $n i32) (result i64 f64 f64 i64)
            (local $i i64) (local $acc i64) (local $x f64) (local $y f64) (local $mix i64)
            (local.set $x (f64.const 0.5))
            (local.set $y (f64.const 3.25))
            (loop $l
                (local.set $acc
                    (call $step
                        (i64.add (local.get $acc) (local.get $i))
                        (local.get $y)))
                (local.set $x (f64.add (f64.mul (local.get $x) (f64.const 1.0001)) (f64.const 0.25)))
                (local.set $y (f64.sub (local.get $y) (f64.const 0.001)))
                (local.set $mix (i64.xor (i64.rotl (local.get $mix) (i64.const 7)) (local.get $acc)))
                (local.set $i (i64.add (local.get $i) (i64.const 1)))
                (br_if $l (i64.lt_u (local.get $i) (i64.extend_i32_u (local.get $n)))))
            (local.get $acc) (local.get $x) (local.get $y) (local.get $mix)))
"#;

#[wasmtime_test(strategies(not(CraneliftPulley)))]
fn values_live_across_an_interrupted_check_survive(config: &mut Config) -> Result<()> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, LIVE_ACROSS_CHECKS)?;
    let mut store = Store::new(&engine, Interrupts::default());
    let handle = store.interrupt_handle()?;
    store.interrupt_callback(move |mut cx| {
        cx.data_mut().delivered += 1;
        // Host floating-point work between the check and the resume, so a
        // register the guest kept live across the check is overwritten
        // unless the check's call preserves it.
        let scrambled = std::hint::black_box(f64::from(cx.data().delivered)).sqrt() * 1.5;
        std::hint::black_box(scrambled);
        if cx.data().rearm {
            handle.interrupt();
        }
        Ok(InterruptAction::Continue)
    });
    let instance = Instance::new(&mut store, &module, &[])?;
    let run = instance.get_typed_func::<i32, (i64, f64, f64, i64)>(&mut store, "run")?;

    let quiet = run.call(&mut store, 1000)?;
    assert_eq!(store.data().delivered, 0);

    // Every delivery re-arms, so every check from here on fails and calls
    // into the runtime: at `run`'s entry, then at least twice per iteration
    // (Winch also checks the entry of the call-free `$trunc`).
    store.data_mut().rearm = true;
    store.interrupt_handle()?.interrupt();
    let interrupted = run.call(&mut store, 1000)?;
    store.data_mut().rearm = false;
    assert!(store.data().delivered >= 2001, "{}", store.data().delivered);
    assert_eq!(interrupted.0, quiet.0);
    assert_eq!(interrupted.1.to_bits(), quiet.1.to_bits());
    assert_eq!(interrupted.2.to_bits(), quiet.2.to_bits());
    assert_eq!(interrupted.3, quiet.3);
    Ok(())
}

/// The bulk-memory libcalls' chunk: a request is delivered between two runs of
/// this many bytes.
const BULK_CHUNK: usize = wasmtime_environ::BULK_MEMORY_CHUNK_SIZE as usize;
const PAGE: usize = 64 * 1024;

/// Bulk-memory exports that request an interruption through a host call and
/// then run one `memory.copy` or `memory.fill`, with no check in between: the
/// function's only check is its entry, which runs before the host call.
fn bulk_module(pages: usize) -> String {
    format!(
        r#"
        (module
            (import "" "request" (func $request))
            (memory (export "memory") {pages})
            (func (export "copy") (param $dst i32) (param $src i32) (param $len i32)
                call $request
                (memory.copy (local.get $dst) (local.get $src) (local.get $len)))
            (func (export "fill") (param $dst i32) (param $val i32) (param $len i32)
                call $request
                (memory.fill (local.get $dst) (local.get $val) (local.get $len))))
        "#
    )
}

/// What the interrupt callback saw of linear memory when it ran.
#[derive(Default)]
struct BulkInterrupts {
    memory: Option<Memory>,
    /// The bytes at each probed address, one entry per delivery.
    seen: Vec<Vec<u8>>,
    probes: Vec<usize>,
    stop: bool,
}

fn bulk_instance(
    config: &mut Config,
    pages: usize,
    probes: Vec<usize>,
) -> Result<(Store<BulkInterrupts>, Instance)> {
    let engine = build_engine(config)?;
    let module = Module::new(&engine, bulk_module(pages))?;
    let mut store = Store::new(
        &engine,
        BulkInterrupts {
            probes,
            ..BulkInterrupts::default()
        },
    );
    store.interrupt_callback(|mut cx| {
        let memory = cx.data().memory.expect("the instance's memory is recorded");
        let seen = cx
            .data()
            .probes
            .iter()
            .map(|&at| memory.data(&cx)[at])
            .collect();
        cx.data_mut().seen.push(seen);
        if cx.data().stop {
            Err(format_err!("stopped mid-operation"))
        } else {
            Ok(InterruptAction::Continue)
        }
    });
    let handle = store.interrupt_handle()?;
    let mut linker = Linker::new(store.engine());
    linker.func_wrap("", "request", move || handle.interrupt())?;
    let instance = linker.instantiate(&mut store, &module)?;
    let memory = instance.get_memory(&mut store, "memory").unwrap();
    store.data_mut().memory = Some(memory);
    Ok((store, instance))
}

/// A request made while a forwards copy runs is delivered once, after the
/// first chunk and before the rest.
#[wasmtime_test(strategies(not(CraneliftPulley)), wasm_features(bulk_memory))]
fn a_long_copy_delivers_a_request_between_chunks(config: &mut Config) -> Result<()> {
    let len = BULK_CHUNK + PAGE;
    let (src, dst) = (0, len);
    let (mut store, instance) = bulk_instance(config, 2 * len / PAGE, vec![dst, dst + len - 1])?;
    let memory = store.data().memory.unwrap();
    memory.data_mut(&mut store)[src..src + len].fill(0x5a);

    let copy = instance.get_typed_func::<(i32, i32, i32), ()>(&mut store, "copy")?;
    copy.call(
        &mut store,
        (
            i32::try_from(dst)?,
            i32::try_from(src)?,
            i32::try_from(len)?,
        ),
    )?;
    assert_eq!(store.data().seen, [[0x5a, 0x00]]);
    assert_eq!(memory.data(&store)[dst + len - 1], 0x5a);
    Ok(())
}

/// A copy whose destination overlaps its source from above runs backwards,
/// highest chunk first, and still delivers between chunks with `memmove`
/// semantics intact.
#[wasmtime_test(strategies(not(CraneliftPulley)), wasm_features(bulk_memory))]
fn an_overlapping_copy_runs_backwards_and_delivers_between_chunks(
    config: &mut Config,
) -> Result<()> {
    let len = BULK_CHUNK + PAGE;
    let (src, dst) = (0, PAGE);
    let pattern = |at: usize| u8::try_from(at / PAGE % 251 + 1).unwrap();
    let (mut store, instance) = bulk_instance(config, len / PAGE + 1, vec![dst, dst + len - 1])?;
    let memory = store.data().memory.unwrap();
    for (at, byte) in memory.data_mut(&mut store)[..len].iter_mut().enumerate() {
        *byte = pattern(at);
    }

    let copy = instance.get_typed_func::<(i32, i32, i32), ()>(&mut store, "copy")?;
    copy.call(
        &mut store,
        (
            i32::try_from(dst)?,
            i32::try_from(src)?,
            i32::try_from(len)?,
        ),
    )?;
    // At delivery the highest chunk is in place and the lowest is not: the
    // destination's first byte still holds what was there before the copy.
    assert_eq!(store.data().seen, [[pattern(dst), pattern(src + len - 1)]]);
    let data = memory.data(&store);
    for at in [0, 1, PAGE - 1, PAGE, BULK_CHUNK, len - 1] {
        assert_eq!(data[dst + at], pattern(src + at), "byte {at} of the copy");
    }
    Ok(())
}

/// A request that ends execution during a fill leaves the chunk already
/// filled in place and returns the callback's error.
#[wasmtime_test(strategies(not(CraneliftPulley)), wasm_features(bulk_memory))]
fn an_interrupt_that_ends_a_fill_keeps_the_filled_chunk(config: &mut Config) -> Result<()> {
    let len = BULK_CHUNK + PAGE;
    let (mut store, instance) = bulk_instance(config, len / PAGE, vec![0, BULK_CHUNK])?;
    store.data_mut().stop = true;
    let memory = store.data().memory.unwrap();

    let fill = instance.get_typed_func::<(i32, i32, i32), ()>(&mut store, "fill")?;
    let error = fill
        .call(&mut store, (0, 0xab, i32::try_from(len)?))
        .unwrap_err();
    assert_eq!(error.root_cause().to_string(), "stopped mid-operation");
    assert_eq!(store.data().seen, [[0xab, 0x00]]);
    let data = memory.data(&store);
    assert_eq!(data[BULK_CHUNK - 1], 0xab);
    assert_eq!(data[BULK_CHUNK], 0x00);
    Ok(())
}

/// An operation no longer than one chunk never stops to deliver: the request
/// stays pending for the next check.
#[wasmtime_test(strategies(not(CraneliftPulley)), wasm_features(bulk_memory))]
fn a_one_chunk_operation_leaves_a_request_pending(config: &mut Config) -> Result<()> {
    let (mut store, instance) = bulk_instance(config, 1, vec![0])?;
    let fill = instance.get_typed_func::<(i32, i32, i32), ()>(&mut store, "fill")?;
    fill.call(&mut store, (0, 0xab, i32::try_from(PAGE)?))?;
    assert!(store.data().seen.is_empty());

    // The next call's entry check delivers it, before its own host call
    // requests another.
    fill.call(&mut store, (0, 0xcd, 1))?;
    assert_eq!(store.data().seen, [[0xab]]);
    Ok(())
}
