//! A host function sees the memory of the call it is serving.
//!
//! Every test composes two subcomponents, each with its own core memory
//! holding a different byte at offset 0, and has both call one host import.
//! The host answers with the byte it reads at offset 0 of
//! `Access::caller_memory`, so a call that saw the other subcomponent's
//! memory, or none, answers wrongly.

use std::sync::Arc;
use std::sync::atomic::{AtomicU32, Ordering};
use wasmtime::component::{Access, Accessor, Component, Linker};
use wasmtime::{AsContext, Config, Engine, Result, Store};

/// The byte at offset 0 of the first subcomponent's memory.
const FIRST: u8 = 0xa1;
/// The byte at offset 0 of the second subcomponent's memory.
const SECOND: u8 = 0xb2;

/// A component that instantiates two subcomponents, each lowering the root
/// import `peek` through its own memory, and exports each one's `run` as
/// `run-first` and `run-second`.
///
/// `import` is the import's function type and `lift` the options its `run`
/// is lifted with.
fn composition(import: &str, lift: &str) -> String {
    let subcomponent = |name: &str, byte: u8| {
        format!(
            r#"
  (component ${name}
    (import "peek" (func $peek {import}))
    (core module $libc
      (memory (export "memory") 1)
      (data (i32.const 0) "\{byte:02x}"))
    (core instance $libc (instantiate $libc))
    (core func $peek (canon lower (func $peek) (memory $libc "memory")))
    (core module $m
      (import "" "peek" (func $peek (result i32)))
      (func (export "run") (result i32) (call $peek)))
    (core instance $i (instantiate $m (with "" (instance (export "peek" (func $peek))))))
    (func (export "run") {lift} (result u32) (canon lift (core func $i "run"))))
  (instance ${name} (instantiate ${name} (with "peek" (func $peek))))"#
        )
    };
    format!(
        r#"(component
  (import "peek" (func $peek {import}))
  {}
  {}
  (export "run-first" (func $first "run"))
  (export "run-second" (func $second "run")))"#,
        subcomponent("first", FIRST),
        subcomponent("second", SECOND),
    )
}

/// The byte at offset 0 of the memory the call `access` serves came from.
fn peek<T, D>(access: &Access<'_, T, D>) -> u32
where
    D: wasmtime::component::HasData + ?Sized,
{
    let memory = access
        .caller_memory()
        .expect("each subcomponent lowers `peek` through its own memory");
    u32::from(memory.data(access.as_context())[0])
}

#[test]
fn synchronous_host_sees_its_callers_memory() -> Result<()> {
    let engine = Engine::default();
    let component = Component::new(&engine, composition("(result u32)", ""))?;
    let mut linker = Linker::<()>::new(&engine);
    linker
        .root()
        .func_wrap_access("peek", |access, ()| Ok((peek(&access),)))?;
    let mut store = Store::new(&engine, ());
    let instance = linker.instantiate(&mut store, &component)?;
    let first = instance.get_typed_func::<(), (u32,)>(&mut store, "run-first")?;
    let second = instance.get_typed_func::<(), (u32,)>(&mut store, "run-second")?;
    // Interleaved, so neither call can be answered from a memory an
    // earlier call left behind.
    for _ in 0..3 {
        assert_eq!(first.call(&mut store, ())?, (u32::from(FIRST),));
        assert_eq!(second.call(&mut store, ())?, (u32::from(SECOND),));
    }
    Ok(())
}

mod generated {
    wasmtime::component::bindgen!({
        inline: "
            package test:caller-memory;
            world caller-memory {
                import peek: func() -> u32;
            }
        ",
        imports: { default: store | trappable },
    });

    impl<T> CallerMemoryImportsWithStore<T> for wasmtime::component::HasSelf<u32> {
        fn peek(mut host: wasmtime::component::Access<'_, T, Self>) -> wasmtime::Result<u32> {
            *host.get() += 1;
            Ok(super::peek(&host))
        }
    }

    impl CallerMemoryImports for u32 {}
}

#[test]
fn generated_store_import_sees_its_callers_memory() -> Result<()> {
    let engine = Engine::default();
    let component = Component::new(&engine, composition("(result u32)", ""))?;
    let mut linker = Linker::<u32>::new(&engine);
    generated::CallerMemory::add_to_linker::<_, wasmtime::component::HasSelf<u32>>(
        &mut linker,
        |data| data,
    )?;
    let mut store = Store::new(&engine, 0);
    let instance = linker.instantiate(&mut store, &component)?;
    let first = instance.get_typed_func::<(), (u32,)>(&mut store, "run-first")?;
    let second = instance.get_typed_func::<(), (u32,)>(&mut store, "run-second")?;
    assert_eq!(first.call(&mut store, ())?, (u32::from(FIRST),));
    assert_eq!(second.call(&mut store, ())?, (u32::from(SECOND),));
    assert_eq!(*store.data(), 2);
    Ok(())
}

#[tokio::test]
async fn concurrent_host_sees_its_callers_memory_across_a_suspension() -> Result<()> {
    let mut config = Config::new();
    config.wasm_component_model_async(true);
    let engine = Engine::new(&config)?;
    let component = Component::new(&engine, composition("async (result u32)", "async"))?;
    let entered = Arc::new(AtomicU32::new(0));
    let mut linker = Linker::<()>::new(&engine);
    let host_entered = entered.clone();
    linker
        .root()
        .func_wrap_concurrent("peek", move |accessor: &Accessor<()>, ()| {
            let entered = host_entered.clone();
            Box::pin(async move {
                let before = accessor.with(|access| peek(&access));
                // Suspend until both calls have entered the host, so the
                // other call's host future has run on this store before
                // this one reads again.
                entered.fetch_add(1, Ordering::SeqCst);
                while entered.load(Ordering::SeqCst) < 2 {
                    tokio::task::yield_now().await;
                }
                let after = accessor.with(|access| peek(&access));
                Ok(((before << 8) | after,))
            })
        })?;
    let mut store = Store::new(&engine, ());
    let instance = linker.instantiate_async(&mut store, &component).await?;
    let first = instance.get_typed_func::<(), (u32,)>(&mut store, "run-first")?;
    let second = instance.get_typed_func::<(), (u32,)>(&mut store, "run-second")?;
    let (first, second) = store
        .run_concurrent(async |accessor| -> Result<_> {
            let (first, second) = tokio::join!(
                first.call_concurrent(accessor, ()),
                second.call_concurrent(accessor, ()),
            );
            Ok((first?, second?))
        })
        .await??;
    let twice = |byte: u8| (u32::from(byte) << 8) | u32::from(byte);
    assert_eq!(first, (twice(FIRST),));
    assert_eq!(second, (twice(SECOND),));
    assert_eq!(entered.load(Ordering::SeqCst), 2);
    store.assert_concurrent_state_empty();
    Ok(())
}
