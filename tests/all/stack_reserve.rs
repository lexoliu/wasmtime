//! Tests of `Store::stack_reserve_callback`.
//!
//! The fixture emulates an embedder that commits fiber stacks lazily, with
//! real faults. Every stack is an `mmap` that is `PROT_NONE` except for a top
//! window; the reserve callback `mprotect`s `[sp - RESERVE - STEP, floor)`
//! readable and writable and answers `floor + RESERVE`. Any touch below the
//! committed floor is a `SIGSEGV` (or `SIGBUS`) that kills the test process,
//! so a test that passes proves host code always had committed stack under it.
#![cfg(all(unix, not(miri)))]

use std::ops::Range;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
use wasmtime::component::{Component, Linker};
use wasmtime::*;
use wasmtime_test_macros::wasmtime_test;

const STACK_SIZE: usize = 4 << 20;
const MAX_WASM_STACK: usize = 2 << 20;
/// `R`: the bytes committed below the reserve limit.
const RESERVE: usize = 128 << 10;
/// `G`: the bytes committed beyond `RESERVE` by each callback.
const STEP: usize = 32 << 10;
/// `H`: the window committed when a stack is created.
const ENTRY_WINDOW: usize = 32 << 10;
/// `S`: the largest frame the reserve is sized to absorb below a checked `sp`.
const SLACK: usize = 16 << 10;

fn page_size() -> usize {
    rustix::param::page_size()
}

fn current_sp() -> usize {
    let marker = 0_u8;
    std::hint::black_box(&marker) as *const u8 as usize
}

/// One fixture stack: `base..base + STACK_SIZE`, committed from `floor` up.
struct Region {
    base: usize,
    floor: AtomicUsize,
    callbacks: AtomicUsize,
}

impl Region {
    fn top(&self) -> usize {
        self.base + STACK_SIZE
    }
}

#[derive(Default)]
struct Regions(Mutex<Vec<Arc<Region>>>);

impl Regions {
    fn find(&self, sp: usize) -> Arc<Region> {
        self.0
            .lock()
            .unwrap()
            .iter()
            .find(|region| (region.base..region.top()).contains(&sp))
            .unwrap_or_else(|| panic!("{sp:#x} is on no fixture stack"))
            .clone()
    }

    /// The reserve callback of an embedder that commits lazily: commits what
    /// host code needs below `sp` and answers the new reserve limit.
    fn commit(&self, sp: usize) -> Result<usize> {
        let region = self.find(sp);
        region.callbacks.fetch_add(1, Ordering::SeqCst);
        let page = page_size();
        let need = sp
            .checked_sub(RESERVE + STEP)
            .map(|need| need & !(page - 1))
            .filter(|need| *need >= region.base);
        let Some(need) = need else {
            return Err(Trap::StackOverflow.into());
        };
        let floor = region.floor.load(Ordering::SeqCst);
        if need < floor {
            unsafe {
                rustix::mm::mprotect(
                    need as *mut _,
                    floor - need,
                    rustix::mm::MprotectFlags::READ | rustix::mm::MprotectFlags::WRITE,
                )
                .unwrap();
            }
            region.floor.store(need, Ordering::SeqCst);
        }
        Ok(region.floor.load(Ordering::SeqCst) + RESERVE)
    }

    /// Asserts that the calling host code has at least `RESERVE - SLACK`
    /// committed below it.
    fn assert_reserved(&self) {
        let sp = current_sp();
        let region = self.find(sp);
        let committed = sp - region.floor.load(Ordering::SeqCst);
        assert!(
            committed >= RESERVE - SLACK,
            "host code at {sp:#x} has {committed:#x} bytes committed below it, \
             less than {:#x}",
            RESERVE - SLACK
        );
    }
}

struct FixtureStack {
    region: Arc<Region>,
    regions: Arc<Regions>,
}

unsafe impl StackMemory for FixtureStack {
    fn top(&self) -> *mut u8 {
        self.region.top() as *mut u8
    }
    fn range(&self) -> Range<usize> {
        self.region.base..self.region.top()
    }
    fn guard_range(&self) -> Range<*mut u8> {
        std::ptr::null_mut()..std::ptr::null_mut()
    }
}

impl Drop for FixtureStack {
    fn drop(&mut self) {
        self.regions
            .0
            .lock()
            .unwrap()
            .retain(|region| !Arc::ptr_eq(region, &self.region));
        unsafe {
            rustix::mm::munmap(self.region.base as *mut _, STACK_SIZE).unwrap();
        }
    }
}

struct FixtureStacks(Arc<Regions>);

unsafe impl StackCreator for FixtureStacks {
    fn new_stack(&self, size: usize, _zeroed: bool) -> Result<Box<dyn StackMemory>> {
        assert_eq!(size, STACK_SIZE);
        // Anonymous memory is zeroed, as every stack must be.
        let base = unsafe {
            rustix::mm::mmap_anonymous(
                std::ptr::null_mut(),
                STACK_SIZE,
                rustix::mm::ProtFlags::empty(),
                rustix::mm::MapFlags::PRIVATE,
            )?
        } as usize;
        let floor = base + STACK_SIZE - ENTRY_WINDOW;
        unsafe {
            rustix::mm::mprotect(
                floor as *mut _,
                ENTRY_WINDOW,
                rustix::mm::MprotectFlags::READ | rustix::mm::MprotectFlags::WRITE,
            )?;
        }
        let region = Arc::new(Region {
            base,
            floor: AtomicUsize::new(floor),
            callbacks: AtomicUsize::new(0),
        });
        self.0.0.lock().unwrap().push(region.clone());
        Ok(Box::new(FixtureStack {
            region,
            regions: self.0.clone(),
        }))
    }
}

/// Configures `config` for the fixture: lazily committed stacks and
/// stack-limit interruption.
fn fixture(config: &mut Config) -> Arc<Regions> {
    let regions = Arc::new(Regions::default());
    config
        .stack_limit_interruption(true)
        .async_stack_size(STACK_SIZE)
        .max_wasm_stack(MAX_WASM_STACK)
        .with_host_stack(Arc::new(FixtureStacks(regions.clone())));
    regions
}

/// Runs `f` with the stack burned down to `until_sp` first, touching every
/// page on the way.
fn burn<R>(until_sp: usize, f: impl FnOnce() -> R) -> R {
    let mut buf = [0_u8; 1024];
    let sp = std::hint::black_box(&mut buf).as_ptr() as usize;
    let result = if sp > until_sp {
        burn(until_sp, f)
    } else {
        f()
    };
    std::hint::black_box(&buf);
    result
}

/// Recursion with a host import at the bottom.
const RECURSION: &str = r#"
    (module
        (import "host" "bottom" (func $bottom))
        (func $rec (export "rec") (param i32)
            (if (local.get 0)
                (then (call $rec (i32.sub (local.get 0) (i32.const 1))))
                (else (call $bottom)))))
"#;

/// Deep enough to cross many callbacks' worth of stack.
const DEPTH: i32 = 20_000;

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn host_import_at_depth_has_the_reserve_committed(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    let engine = Engine::new(config)?;
    let module = Module::new(&engine, RECURSION)?;
    let mut store = Store::new(&engine, ());
    let callbacks = Arc::new(AtomicUsize::new(0));
    {
        let regions = regions.clone();
        let callbacks = callbacks.clone();
        store.stack_reserve_callback(move |_cx, sp| {
            callbacks.fetch_add(1, Ordering::SeqCst);
            regions.commit(sp)
        });
    }
    let bottom_sp = Arc::new(AtomicUsize::new(0));
    let bottom = {
        let regions = regions.clone();
        let bottom_sp = bottom_sp.clone();
        Func::wrap(&mut store, move || {
            regions.assert_reserved();
            bottom_sp.store(current_sp(), Ordering::SeqCst);
        })
    };
    let instance = Instance::new_async(&mut store, &module, &[bottom.into()]).await?;
    let rec = instance.get_typed_func::<i32, ()>(&mut store, "rec")?;
    let entry_sp = current_sp();
    rec.call_async(&mut store, DEPTH).await?;

    let descended = entry_sp - bottom_sp.load(Ordering::SeqCst);
    assert!(
        descended > 4 * (RESERVE + STEP),
        "the descent of {descended:#x} bytes must cross several callbacks"
    );
    assert!(callbacks.load(Ordering::SeqCst) >= 4);
    Ok(())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn no_callback_leaves_the_limit_alone(config: &mut Config) -> Result<()> {
    config.stack_limit_interruption(true);
    let engine = Engine::new(config)?;
    let module = Module::new(&engine, RECURSION)?;
    let mut store = Store::new(&engine, ());
    let bottom = Func::wrap(&mut store, || {});
    let instance = Instance::new_async(&mut store, &module, &[bottom.into()]).await?;
    let rec = instance.get_typed_func::<i32, ()>(&mut store, "rec")?;
    // Every check passes against the real limit alone: nothing is routed to
    // the slow path, which has no callback to answer a reserve.
    rec.call_async(&mut store, 5_000).await?;

    // And a genuine overflow still traps.
    let error = rec
        .call_async(&mut store, i32::MAX)
        .await
        .expect_err("recursion without end must overflow");
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    Ok(())
}

/// The store's own stack, which a synchronous call runs on, starts with no
/// reserve as well; only a fiber's reserve is swapped in at resume.
#[wasmtime_test(strategies(not(CraneliftPulley)))]
fn no_callback_leaves_the_limit_alone_on_the_thread_stack(config: &mut Config) -> Result<()> {
    config.stack_limit_interruption(true);
    let engine = Engine::new(config)?;
    let module = Module::new(&engine, RECURSION)?;
    let mut store = Store::new(&engine, ());
    let bottom = Func::wrap(&mut store, || {});
    let instance = Instance::new(&mut store, &module, &[bottom.into()])?;
    let rec = instance.get_typed_func::<i32, ()>(&mut store, "rec")?;
    rec.call(&mut store, 1_000)?;
    Ok(())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn callback_error_ends_the_call(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    let engine = Engine::new(config)?;
    let module = Module::new(&engine, RECURSION)?;
    let mut store = Store::new(&engine, ());
    let calls = Arc::new(AtomicUsize::new(0));
    {
        let regions = regions.clone();
        let calls = calls.clone();
        store.stack_reserve_callback(move |_cx, sp| {
            // The first call is the wasm entry; the second comes from a
            // failing stack-limit check inside the recursion.
            if calls.fetch_add(1, Ordering::SeqCst) == 1 {
                return Err(format_err!("reserve refused"));
            }
            regions.commit(sp)
        });
    }
    let bottom = Func::wrap(&mut store, || {});
    let instance = Instance::new_async(&mut store, &module, &[bottom.into()]).await?;
    let rec = instance.get_typed_func::<i32, ()>(&mut store, "rec")?;
    let error = rec
        .call_async(&mut store, DEPTH)
        .await
        .expect_err("the callback's error ends the call");
    assert_eq!(error.root_cause().to_string(), "reserve refused");
    assert_eq!(calls.load(Ordering::SeqCst), 2);
    Ok(())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn callback_error_at_entry_runs_no_wasm(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    let engine = Engine::new(config)?;
    let module = Module::new(&engine, RECURSION)?;
    let mut store = Store::new(&engine, ());
    store.stack_reserve_callback(move |_cx, _sp| {
        let _ = &regions;
        Err(format_err!("no stack"))
    });
    let reached = Arc::new(AtomicUsize::new(0));
    let bottom = {
        let reached = reached.clone();
        Func::wrap(&mut store, move || {
            reached.fetch_add(1, Ordering::SeqCst);
        })
    };
    let instance = Instance::new_async(&mut store, &module, &[bottom.into()]).await?;
    let rec = instance.get_typed_func::<i32, ()>(&mut store, "rec")?;
    let error = rec
        .call_async(&mut store, 0)
        .await
        .expect_err("the callback's error is what the call returns");
    assert_eq!(error.root_cause().to_string(), "no stack");
    assert_eq!(reached.load(Ordering::SeqCst), 0);
    Ok(())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn limit_above_sp_is_a_contract_violation(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    let engine = Engine::new(config)?;
    let module = Module::new(&engine, RECURSION)?;
    let mut store = Store::new(&engine, ());
    let answered = Arc::new(AtomicUsize::new(0));
    {
        let answered = answered.clone();
        store.stack_reserve_callback(move |_cx, sp| {
            regions.commit(sp)?;
            answered.store(sp + 1, Ordering::SeqCst);
            Ok(sp + 1)
        });
    }
    let bottom = Func::wrap(&mut store, || {});
    let instance = Instance::new_async(&mut store, &module, &[bottom.into()]).await?;
    let rec = instance.get_typed_func::<i32, ()>(&mut store, "rec")?;
    let error = rec
        .call_async(&mut store, 0)
        .await
        .expect_err("a limit above the stack pointer is refused");
    let limit = answered.load(Ordering::SeqCst);
    let message = format!("{error:#}");
    assert!(
        message.contains(&format!("{limit:#x}")) && message.contains(&format!("{:#x}", limit - 1)),
        "the error must name both values: {message}"
    );
    Ok(())
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn reserve_is_committed_before_the_interrupt_callback(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    let engine = Engine::new(config)?;
    let module = Module::new(
        &engine,
        r#"
            (module
                (import "host" "noop" (func $noop))
                (func (export "run") (call $noop)))
        "#,
    )?;
    let mut store = Store::new(&engine, ());
    let events = Arc::new(Mutex::new(Vec::new()));
    {
        let events = events.clone();
        let calls = AtomicUsize::new(0);
        store.stack_reserve_callback(move |_cx, sp| {
            events.lock().unwrap().push("commit");
            // Answer the entry with the stack pointer itself, so the first
            // check inside the guest is below the reserve limit as well as
            // meeting the pending interruption.
            if calls.fetch_add(1, Ordering::SeqCst) == 0 {
                return Ok(sp);
            }
            regions.commit(sp)
        });
    }
    {
        let events = events.clone();
        store.interrupt_callback(move |_cx| {
            events.lock().unwrap().push("interrupt");
            Ok(InterruptAction::Continue)
        });
    }
    let noop = Func::wrap(&mut store, || {});
    let instance = Instance::new_async(&mut store, &module, &[noop.into()]).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    store.interrupt_handle()?.interrupt();
    run.call_async(&mut store, ()).await?;
    assert_eq!(*events.lock().unwrap(), ["commit", "commit", "interrupt"]);
    Ok(())
}

struct BurnOnGrow;

impl ResourceLimiter for BurnOnGrow {
    fn memory_growing(
        &mut self,
        _current: usize,
        _desired: usize,
        _maximum: Option<usize>,
    ) -> Result<bool> {
        // Host code a libcall runs: it touches 80 KiB below itself.
        burn(current_sp() - (80 << 10), || ());
        Ok(true)
    }

    fn table_growing(
        &mut self,
        _current: usize,
        _desired: usize,
        _maximum: Option<usize>,
    ) -> Result<bool> {
        Ok(true)
    }
}

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn nested_entry_has_the_reserve_committed(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    let engine = Engine::new(config)?;
    let module = Module::new(
        &engine,
        r#"
            (module
                (import "host" "reenter" (func $reenter))
                (memory 1 10)
                (func (export "run") (call $reenter))
                ;; Calls nothing, so nothing checks the stack: the libcall
                ;; runs wherever the entry left the stack pointer.
                (func (export "leaf") (drop (memory.grow (i32.const 1)))))
        "#,
    )?;
    let mut store = Store::new(&engine, BurnOnGrow);
    store.limiter(|state| state);
    let callback_sps = Arc::new(Mutex::new(Vec::new()));
    {
        let regions = regions.clone();
        let callback_sps = callback_sps.clone();
        store.stack_reserve_callback(move |_cx, sp| {
            callback_sps.lock().unwrap().push(sp);
            regions.commit(sp)
        });
    }
    let host_sp = Arc::new(AtomicUsize::new(0));
    let reenter = {
        let host_sp = host_sp.clone();
        Func::wrap(&mut store, move |mut caller: Caller<'_, BurnOnGrow>| {
            let sp = current_sp();
            host_sp.store(sp, Ordering::SeqCst);
            let leaf = caller.get_export("leaf").unwrap().into_func().unwrap();
            // The host consumes most of its reserve before it re-enters, so
            // the nested entry lies below the reserve limit. The safe `call`
            // refuses to run on a fiber, so this enters the way the runtime's
            // own nested entries do (a `cabi_realloc` during lowering).
            burn(sp - (100 << 10), || unsafe {
                leaf.call_unchecked(&mut caller, &mut [] as *mut [ValRaw])
            })
        })
    };
    let instance = Instance::new_async(&mut store, &module, &[reenter.into()]).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    run.call_async(&mut store, ()).await?;

    let host_sp = host_sp.load(Ordering::SeqCst);
    assert!(
        callback_sps
            .lock()
            .unwrap()
            .iter()
            .any(|sp| *sp < host_sp - (90 << 10)),
        "the nested entry must have called the callback"
    );
    Ok(())
}

/// A stackful async task: checks its stack, suspends in `slow`, then recurses
/// and checks again at the bottom.
const TASKS: &str = r#"
(component
  (import "slow" (func $slow async))
  (import "check" (func $check))

  (core module $libc (memory (export "memory") 1))
  (core instance $libc (instantiate $libc))

  (core func $task_return (canon task.return))
  (core func $waitable_set_new (canon waitable-set.new))
  (core func $waitable_set_wait (canon waitable-set.wait (memory (core memory $libc "memory"))))
  (core func $waitable_join (canon waitable.join))
  (canon lower (func $slow) async (core func $slow_lowered))
  (canon lower (func $check) (core func $check_lowered))

  (core module $m
    (import "" "memory" (memory 1))
    (import "" "task.return" (func $task_return))
    (import "" "waitable-set.new" (func $waitable_set_new (result i32)))
    (import "" "waitable-set.wait" (func $waitable_set_wait (param i32 i32) (result i32)))
    (import "" "waitable.join" (func $waitable_join (param i32 i32)))
    (import "" "slow" (func $slow (result i32)))
    (import "" "check" (func $check))

    (func $rec (param i32)
      (if (local.get 0)
        (then (call $rec (i32.sub (local.get 0) (i32.const 1))))
        (else (call $check))))

    (func (export "run")
      (local $ret i32)
      (local $set i32)
      (local $call i32)
      (call $check)
      (local.set $ret (call $slow))
      (if (i32.eq (i32.const 1 (; STARTED ;)) (i32.and (local.get $ret) (i32.const 0xF)))
        (then
          (local.set $call (i32.shr_u (local.get $ret) (i32.const 4)))
          (local.set $set (call $waitable_set_new))
          (call $waitable_join (local.get $call) (local.get $set))
          (drop (call $waitable_set_wait (local.get $set) (i32.const 0)))))
      (call $rec (i32.const 20000))
      (call $task_return))
  )

  (core instance $i (instantiate $m
    (with "" (instance
      (export "memory" (memory $libc "memory"))
      (export "task.return" (func $task_return))
      (export "waitable-set.new" (func $waitable_set_new))
      (export "waitable-set.wait" (func $waitable_set_wait))
      (export "waitable.join" (func $waitable_join))
      (export "slow" (func $slow_lowered))
      (export "check" (func $check_lowered))))))

  (func (export "run") async (canon lift (core func $i "run") async))
)
"#;

#[wasmtime_test(strategies(not(CraneliftPulley)))]
async fn two_tasks_keep_their_own_reserve(config: &mut Config) -> Result<()> {
    let regions = fixture(config);
    config
        .wasm_component_model_async(true)
        .wasm_component_model_async_stackful(true);
    let engine = Engine::new(config)?;
    let component = Component::new(&engine, TASKS)?;
    let mut store = Store::new(&engine, ());
    {
        let regions = regions.clone();
        store.stack_reserve_callback(move |_cx, sp| regions.commit(sp));
    }
    let mut linker = Linker::new(&engine);
    {
        let regions = regions.clone();
        linker.root().func_wrap("check", move |_cx, ()| {
            regions.assert_reserved();
            Ok(())
        })?;
    }
    linker.root().func_wrap_concurrent("slow", |_, ()| {
        Box::pin(async {
            for _ in 0..5 {
                tokio::task::yield_now().await;
            }
            Ok(())
        })
    })?;
    let instance = linker.instantiate_async(&mut store, &component).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "run")?;
    // Both tasks suspend in `slow`, so they alternate on their two stacks.
    store
        .run_concurrent(async move |accessor| {
            let (a, b) = tokio::join!(
                run.call_concurrent(accessor, ()),
                run.call_concurrent(accessor, ())
            );
            a?;
            b?;
            Ok::<_, Error>(())
        })
        .await??;
    Ok(())
}

/// The values `big` of `crate::stack_large_frame::big_module` keeps live: a
/// frame of at least `8 * BIG_VALUES` = 40.6 KiB, more than the 32 KiB window
/// a fixture stack is created with.
const BIG_VALUES: usize = 5_200;

/// A wasm function whose frame is more than the committed window of a fresh
/// fixture stack, called with the real limit just above the edge of that
/// window, overflows. The check must run before the prologue's first probe
/// below the window: a probe there is a `SIGSEGV` that ends the test process.
#[wasmtime_test(strategies(only(CraneliftNative)))]
async fn a_large_frame_at_the_committed_edge_overflows_before_it_is_touched(
    config: &mut Config,
) -> Result<()> {
    let _regions = fixture(config);
    config
        .max_wasm_stack(ENTRY_WINDOW / 2)
        .stack_limit_large_frame(Some(4096))
        .collector(Collector::Null);
    let engine = Engine::new(config)?;
    // `big` calls wasm, so it is a class A function: the checks of its body
    // run only once its prologue has allocated and probed the frame, and the
    // prologue check alone stands between the frame and the edge. A function
    // that calls no wasm has the ISA's trapping check there already.
    let module = Module::new(
        &engine,
        &crate::stack_large_frame::big_module(BIG_VALUES, "(func $noop)\n", "(call $noop)\n"),
    )?;
    let mut store = Store::new(&engine, ());
    let instance = Instance::new_async(&mut store, &module, &[]).await?;
    let big = instance.get_typed_func::<i64, i64>(&mut store, "big")?;
    let error = big
        .call_async(&mut store, 0)
        .await
        .expect_err("the frame does not fit under the real limit");
    assert_eq!(error.downcast_ref::<Trap>(), Some(&Trap::StackOverflow));
    Ok(())
}

/// A large frame called with its stack pointer above the reserve limit and
/// its lowest address below it: the prologue check asks for the reserve
/// before the frame is touched, with the frame's lowest address.
///
/// The fixture stack is `PROT_NONE` below its top window. The embedder
/// commits nothing at the wasm entry and answers a reserve limit of
/// `sp - 4 KiB`; the committed window below the entry is only
/// `ENTRY_WINDOW`, and the frame of `big` is deeper than that. So the
/// frame's pages below the window are committed by the second call of the
/// callback or not at all: a prologue that probed them first would end the
/// test process with a `SIGSEGV`.
#[wasmtime_test(strategies(only(CraneliftNative)))]
async fn a_large_frame_asks_for_the_reserve_at_its_lowest_address(
    config: &mut Config,
) -> Result<()> {
    let regions = fixture(config);
    config
        .stack_limit_large_frame(Some(4096))
        .collector(Collector::Null);
    let engine = Engine::new(config)?;
    // `mark` is `big`'s first operator: the host's stack pointer there lies
    // below the frame of `big`, within a host call's depth of its lowest
    // address.
    let module = Module::new(
        &engine,
        &crate::stack_large_frame::big_module(
            BIG_VALUES,
            "(import \"host\" \"mark\" (func $mark))\n",
            "(call $mark)\n",
        ),
    )?;
    let mut store = Store::new(&engine, ());
    let callback_sps = Arc::new(Mutex::new(Vec::new()));
    {
        let regions = regions.clone();
        let callback_sps = callback_sps.clone();
        store.stack_reserve_callback(move |_cx, sp| {
            let mut sps = callback_sps.lock().unwrap();
            sps.push(sp);
            if sps.len() == 1 {
                // The wasm entry: a reserve limit just below the entry, with
                // nothing committed beyond the creation window.
                return Ok(sp - 4096);
            }
            // The prologue check is asked for the frame's lowest address,
            // which is at least `8 * BIG_VALUES` below the entry's stack
            // pointer. Refusing here, before committing, ends the call with
            // this message and leaves the frame untouched.
            if sp + 8 * BIG_VALUES > sps[0] {
                return Err(format_err!(
                    "asked for the reserve at {sp:#x}, which is not the lowest address of a \
                     frame of {} bytes entered at {:#x}",
                    8 * BIG_VALUES,
                    sps[0]
                ));
            }
            drop(sps);
            regions.commit(sp)
        });
    }
    let mark_sp = Arc::new(AtomicUsize::new(0));
    let mark = {
        let mark_sp = mark_sp.clone();
        Func::wrap(&mut store, move || {
            mark_sp.store(current_sp(), Ordering::SeqCst);
        })
    };
    let instance = Instance::new_async(&mut store, &module, &[mark.into()]).await?;
    instance.get_memory(&mut store, "memory").unwrap().write(
        &mut store,
        0,
        &crate::stack_large_frame::big_memory_image(BIG_VALUES),
    )?;
    let big = instance.get_typed_func::<i64, i64>(&mut store, "big")?;
    let result = big.call_async(&mut store, 0).await?;
    assert_eq!(result, crate::stack_large_frame::big_sum(BIG_VALUES));

    let sps = callback_sps.lock().unwrap().clone();
    let mark_sp = mark_sp.load(Ordering::SeqCst);
    // The wasm entry and the prologue check, and no other check asked.
    assert_eq!(sps.len(), 2, "{sps:#x?}");
    let (entry_sp, target) = (sps[0], sps[1]);
    // The frame's lowest address is below the reserve limit the entry set.
    assert!(target < entry_sp - 4096, "{target:#x} vs {entry_sp:#x}");
    // And the address is the frame's lowest, not the stack pointer on
    // entry: `big` is a host call's depth above `mark_sp`, its first
    // operator ran with the frame allocated.
    assert!(
        target > mark_sp && target - mark_sp <= 4096,
        "the callback was given {target:#x} but the frame of `big` bottoms out near \
         {mark_sp:#x}"
    );
    assert!(entry_sp - target >= 8 * BIG_VALUES);
    Ok(())
}
