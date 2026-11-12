//! Tests of `Config::stack_limit_large_frame`: the prologue check of a frame
//! above a threshold, its configuration checks and its place in a compiled
//! module's compatibility.
#![cfg(not(miri))]

use std::fmt::Write as _;
use std::sync::{Arc, Mutex, OnceLock};
use wasmtime::*;
use wasmtime_test_macros::wasmtime_test;

/// The text of a module exporting `memory` and `big(i64) -> i64`.
///
/// `big` loads `values` consecutive `i64`s of the memory, one at a time, and
/// sums them once all are loaded, so every one is live at the same time and
/// the frame holds at least `8 * values` bytes of spill slots. `first` is
/// inserted as the function's first operators, where a test marks that the
/// body has started. `imports` declares what `first` calls.
///
/// The value at byte `8 * (i + 1)` of the memory is the `i`-th summand.
pub(crate) fn big_module(values: usize, imports: &str, first: &str) -> String {
    let mut wat = String::new();
    wat.push_str("(module\n");
    wat.push_str(imports);
    wat.push_str("(memory (export \"memory\") 1)\n");
    wat.push_str("(func (export \"big\") (param i64) (result i64)\n");
    for i in 0..values {
        writeln!(wat, "(local $v{i} i64)").unwrap();
    }
    wat.push_str(first);
    for i in 0..values {
        writeln!(
            wat,
            "(local.set $v{i} (i64.load offset={} (i32.wrap_i64 (local.get 0))))",
            8 * (i + 1)
        )
        .unwrap();
    }
    wat.push_str("(local.get $v0)\n");
    for i in 1..values {
        writeln!(wat, "(local.get $v{i}) (i64.add)").unwrap();
    }
    wat.push_str("))\n");
    wat
}

/// The bytes of a memory image whose `i`-th summand is `i + 1`.
pub(crate) fn big_memory_image(values: usize) -> Vec<u8> {
    let mut image = vec![0_u8; 8 * (values + 1)];
    for i in 0..values {
        let at = 8 * (i + 1);
        image[at..at + 8].copy_from_slice(&(i as u64 + 1).to_le_bytes());
    }
    image
}

/// What `big` returns over `big_memory_image(values)`.
pub(crate) fn big_sum(values: usize) -> i64 {
    (values * (values + 1) / 2) as i64
}

fn large_frame_config(threshold: Option<u32>) -> Config {
    let mut config = Config::new();
    config
        .stack_limit_interruption(true)
        .stack_limit_large_frame(threshold)
        .collector(Collector::Null);
    config
}

/// With room on the stack the check never takes its slow path, and the
/// arguments and the result are unharmed by it.
#[wasmtime_test(strategies(only(CraneliftNative)))]
fn a_large_frame_with_room_runs(config: &mut Config) -> Result<()> {
    config
        .stack_limit_interruption(true)
        .stack_limit_large_frame(Some(1024))
        .collector(Collector::Null);
    let engine = Engine::new(config)?;
    const VALUES: usize = 600;
    let module = Module::new(&engine, &big_module(VALUES, "", ""))?;
    let mut store = Store::new(&engine, ());
    let instance = Instance::new(&mut store, &module, &[])?;
    instance.get_memory(&mut store, "memory").unwrap().write(
        &mut store,
        0,
        &big_memory_image(VALUES),
    )?;
    let big = instance.get_typed_func::<i64, i64>(&mut store, "big")?;
    assert_eq!(big.call(&mut store, 0)?, big_sum(VALUES));
    Ok(())
}

/// A requested interruption fails the published limit word, so the
/// prologue check of a large frame calls out. `leaf` calls no wasm and has no
/// loop, so nothing else in it checks the stack against that word.
#[wasmtime_test(strategies(only(CraneliftNative)))]
fn a_large_leaf_delivers_an_interruption_in_its_prologue(config: &mut Config) -> Result<()> {
    config
        .stack_limit_interruption(true)
        .stack_limit_large_frame(Some(1024))
        .collector(Collector::Null);
    let engine = Engine::new(config)?;
    const VALUES: usize = 300;
    // The body's first operator marks that it has started.
    let module = Module::new(
        &engine,
        &big_module(VALUES, "", "(i64.store (i32.const 0) (i64.const 1))\n"),
    )?;
    let mut store = Store::new(&engine, ());
    let memory = Arc::new(OnceLock::<Memory>::new());
    let seen = Arc::new(Mutex::new(Vec::new()));
    {
        let memory = memory.clone();
        let seen = seen.clone();
        store.interrupt_callback(move |cx| {
            let marker = memory.get().unwrap().data(&cx)[0];
            seen.lock().unwrap().push(marker);
            Ok(InterruptAction::Continue)
        });
    }
    let instance = Instance::new(&mut store, &module, &[])?;
    let memory_export = instance.get_memory(&mut store, "memory").unwrap();
    memory.set(memory_export).unwrap();
    memory_export.write(&mut store, 8, &big_memory_image(VALUES)[8..])?;
    let big = instance.get_typed_func::<i64, i64>(&mut store, "big")?;

    store.interrupt_handle()?.interrupt();
    assert_eq!(big.call(&mut store, 0)?, big_sum(VALUES));
    // Exactly one delivery, and the body had not started: the marker was
    // still clear when the callback ran.
    assert_eq!(*seen.lock().unwrap(), [0]);
    assert_eq!(memory_export.data(&store)[0], 1);
    Ok(())
}

fn engine_error(config: &Config) -> String {
    format!(
        "{:#}",
        Engine::new(config).err().expect("the engine is refused")
    )
}

#[test]
fn a_large_frame_threshold_requires_stack_limit_interruption() {
    let mut config = Config::new();
    config.stack_limit_large_frame(Some(64));
    assert_eq!(
        engine_error(&config),
        "`stack_limit_large_frame` requires `stack_limit_interruption`"
    );
}

#[test]
fn a_large_frame_threshold_refuses_collectors_that_free_or_move() {
    for (collector, name) in [
        (
            Collector::DeferredReferenceCounting,
            "deferred reference-counting",
        ),
        (Collector::Copying, "copying"),
    ] {
        let mut config = Config::new();
        config
            .stack_limit_interruption(true)
            .stack_limit_large_frame(Some(64))
            .collector(collector);
        let message = engine_error(&config);
        assert!(
            message.starts_with(&format!(
                "`stack_limit_large_frame` (64) is not supported with the {name} collector"
            )),
            "{message}"
        );
    }
    // The null collector never frees or moves, and a build without GC
    // types has no references to lose.
    Engine::new(&large_frame_config(Some(64))).expect("the null collector is accepted");
}

#[test]
fn a_large_frame_threshold_refuses_targets_without_the_check() {
    let mut config = Config::new();
    config
        .stack_limit_interruption(true)
        .stack_limit_large_frame(Some(64))
        .collector(Collector::Null);
    config.target("s390x-unknown-linux-gnu").unwrap();
    assert_eq!(
        engine_error(&config),
        "`stack_limit_large_frame` is not supported on s390x-unknown-linux-gnu: only x86-64, \
         AArch64 and RISC-V 64 emit the prologue check"
    );
}

#[cfg(feature = "winch")]
#[test]
fn a_large_frame_threshold_refuses_winch() {
    let mut config = Config::new();
    config
        .strategy(Strategy::Winch)
        .stack_limit_interruption(true)
        .stack_limit_large_frame(Some(64));
    assert_eq!(
        engine_error(&config),
        "`stack_limit_large_frame` (64) is not supported with the Winch compiler, whose \
         prologue stack check does not resume"
    );
}

#[test]
fn a_module_loads_only_under_the_threshold_it_was_compiled_with() -> Result<()> {
    let engine_with = |threshold| Engine::new(&large_frame_config(threshold));
    let compiled_with = engine_with(Some(64))?;
    let bytes = Module::new(&compiled_with, "(module (func (export \"f\")))")?.serialize()?;

    // The same threshold loads.
    unsafe { Module::deserialize(&compiled_with, &bytes)? };

    let host_128 = engine_with(Some(128))?;
    let error = unsafe { Module::deserialize(&host_128, &bytes) }
        .err()
        .unwrap();
    assert_eq!(
        error.to_string(),
        "module was compiled with a prologue stack check for frames above 64 bytes however the \
         host is configured with a prologue stack check for frames above 128 bytes"
    );

    let host_none = engine_with(None)?;
    let error = unsafe { Module::deserialize(&host_none, &bytes) }
        .err()
        .unwrap();
    assert_eq!(
        error.to_string(),
        "module was compiled with a prologue stack check for frames above 64 bytes however the \
         host is configured with no prologue stack check for large frames"
    );

    // And a module compiled without a threshold is refused by an engine with
    // one.
    let bytes = Module::new(&host_none, "(module (func (export \"f\")))")?.serialize()?;
    let error = unsafe { Module::deserialize(&compiled_with, &bytes) }
        .err()
        .unwrap();
    assert_eq!(
        error.to_string(),
        "module was compiled with no prologue stack check for large frames however the host is \
         configured with a prologue stack check for frames above 64 bytes"
    );
    Ok(())
}
