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
                ;; first check after the host call returns.
                call $check
                call $after)
            (func $check))
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
