use wasmtime::component::{Component, Linker, Resource, ResourceType};
use wasmtime::{Config, Engine, Result, Store, Trap};

mod generated {
    wasmtime::component::bindgen!({
        path: "tests/all/component_model/data-host.wit",
        imports: { default: trappable },
    });

    impl DataHostImports for u32 {
        fn increment(&mut self, n: u32) -> wasmtime::Result<u32> {
            *self += n;
            Ok(*self)
        }
    }
}

mod borrowed_generated {
    wasmtime::component::bindgen!({
        path: "tests/all/component_model/data-host-memory.wit",
        imports: { default: borrowed | trappable },
    });

    impl BorrowedHostImports for u32 {
        fn inspect(&mut self, _text: &str, _bytes: &[u8]) -> wasmtime::Result<u32> {
            *self += 1;
            Ok(*self)
        }
    }
}

fn engine(concurrent: bool) -> Result<Engine> {
    let mut config = Config::new();
    config.concurrency_support(concurrent);
    Engine::new(&config)
}

#[test]
fn data_host_scalar_calls_work_with_and_without_concurrency() -> Result<()> {
    for concurrent in [false, true] {
        let engine = engine(concurrent)?;
        let component = Component::new(&engine, include_str!("data-host.wat"))?;
        for generated in [false, true] {
            let mut linker = Linker::<u32>::new(&engine);
            if generated {
                generated::DataHost::add_to_linker::<_, wasmtime::component::HasSelf<u32>>(
                    &mut linker,
                    |data| data,
                )?;
            } else {
                linker
                    .root()
                    .func_wrap_data("increment", |data, (n,): (u32,)| {
                        *data += n;
                        Ok((*data,))
                    })?;
            }
            let mut store = Store::new(&engine, 0);
            let instance = linker.instantiate(&mut store, &component)?;
            let run = instance.get_typed_func::<(u32,), (u32,)>(&mut store, "run")?;
            let mut expected = 0;
            for n in 0..100 {
                expected += n;
                assert_eq!(run.call(&mut store, (n,))?, (expected,));
            }
            if concurrent {
                store.assert_concurrent_state_empty();
            }
        }
    }
    Ok(())
}

#[test]
fn data_host_preserves_guest_borrow_scope() -> Result<()> {
    for concurrent in [false, true] {
        let engine = engine(concurrent)?;
        let component = Component::new(&engine, include_str!("data-host-resource.wat"))?;
        let mut linker = Linker::<u32>::new(&engine);
        linker
            .root()
            .resource("item", ResourceType::host::<u32>(), |_, _| {
                panic!("borrowed resource must not be destroyed")
            })?;
        linker
            .root()
            .func_wrap_data("inspect", |data, (item,): (Resource<u32>,)| {
                assert!(!item.owned());
                *data += item.rep();
                Ok(())
            })?;
        linker
            .root()
            .func_wrap_data("increment", |data, (n,): (u32,)| {
                *data += n;
                Ok((*data,))
            })?;
        let mut store = Store::new(&engine, 0);
        let instance = linker.instantiate(&mut store, &component)?;
        let run = instance.get_typed_func::<(Resource<u32>,), ()>(&mut store, "run")?;
        for _ in 0..100 {
            run.call(&mut store, (Resource::new_borrow(42),))?;
            if concurrent {
                store.assert_concurrent_state_empty();
            }
        }
        assert_eq!(*store.data(), 4900);
    }
    Ok(())
}

#[test]
fn data_host_scalar_traps_preserve_the_error() -> Result<()> {
    for concurrent in [false, true] {
        let engine = engine(concurrent)?;
        let component = Component::new(&engine, include_str!("data-host.wat"))?;
        for data_only in [false, true] {
            let mut linker = Linker::<()>::new(&engine);
            if data_only {
                linker.root().func_wrap_data(
                    "increment",
                    |_, (_n,): (u32,)| -> Result<(u32,)> {
                        Err(wasmtime::Error::msg("data host trap"))
                    },
                )?;
            } else {
                linker
                    .root()
                    .func_wrap("increment", |_, (_n,): (u32,)| -> Result<(u32,)> {
                        Err(wasmtime::Error::msg("data host trap"))
                    })?;
            }
            let mut store = Store::new(&engine, ());
            let instance = linker.instantiate(&mut store, &component)?;
            let run = instance.get_typed_func::<(u32,), (u32,)>(&mut store, "run")?;
            let error = run.call(&mut store, (7,)).expect_err("host traps");
            assert!(format!("{error:#}").contains("data host trap"));
            // A component trap poisons the store rather than completing its tasks.
            let error = run.call(&mut store, (7,)).expect_err("store is poisoned");
            assert_eq!(error.downcast_ref(), Some(&Trap::CannotEnterComponent));
        }
    }
    Ok(())
}

#[test]
fn data_host_string_result_preserves_guest_realloc() -> Result<()> {
    for concurrent in [false, true] {
        let engine = engine(concurrent)?;
        let component = Component::new(&engine, include_str!("data-host-string.wat"))?;
        let mut linker = Linker::<String>::new(&engine);
        linker
            .root()
            .func_wrap_data("text", |text, (): ()| Ok((text.clone(),)))?;
        let mut store = Store::new(&engine, String::from("中文、日本語、한국어"));
        let instance = linker.instantiate(&mut store, &component)?;
        let run = instance.get_typed_func::<(), (String,)>(&mut store, "run")?;
        let allocations = instance.get_typed_func::<(), (u32,)>(&mut store, "allocations")?;
        for expected in 1..=10 {
            assert_eq!(run.call(&mut store, ())?.0, *store.data());
            assert_eq!(allocations.call(&mut store, ())?, (expected,));
            if concurrent {
                store.assert_concurrent_state_empty();
            }
        }
    }
    Ok(())
}

#[test]
fn data_host_borrows_memory_while_mutating_state() -> Result<()> {
    use std::borrow::Cow;
    use wasmtime::component::{WasmList, WasmStr};

    let text = "中文、日本語、한국어";
    for (concurrent, generated) in [(false, false), (false, true), (true, false), (true, true)] {
        let engine = engine(concurrent)?;
        let component = Component::new(&engine, include_str!("data-host-memory.wat"))?;
        let mut linker = Linker::<u32>::new(&engine);
        if generated {
            borrowed_generated::BorrowedHost::add_to_linker::<_, wasmtime::component::HasSelf<u32>>(
                &mut linker,
                |data| data,
            )?;
        } else {
            linker.root().func_wrap_data_memory(
                "inspect",
                move |calls, memory, (cursor, bytes): (WasmStr, WasmList<u8>)| {
                    let decoded = cursor.to_str_in(memory)?;
                    assert_eq!(decoded, text);
                    if let Cow::Borrowed(value) = &decoded {
                        assert_eq!(value.as_ptr(), bytes.as_le_slice_in(memory).as_ptr());
                    }
                    *calls += 1;
                    Ok((*calls,))
                },
            )?;
        }
        let mut store = Store::new(&engine, 0);
        let instance = linker.instantiate(&mut store, &component)?;
        let utf8 = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf8")?;
        let utf16 = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf16")?;
        assert_eq!(utf8.call(&mut store, (0, text.len() as u32))?, (1,));
        assert_eq!(
            utf16.call(&mut store, (128, text.encode_utf16().count() as u32))?,
            (2,)
        );
        if concurrent {
            store.assert_concurrent_state_empty();
        }

        for (ptr, len, error) in [(127, 1, "utf-8"), (65535, 2, "out of bounds")] {
            let mut store = Store::new(&engine, 0);
            let instance = linker.instantiate(&mut store, &component)?;
            let run = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf8")?;
            let trap = run.call(&mut store, (ptr, len)).unwrap_err();
            assert!(format!("{trap:#}").contains(error), "{trap:#}");
            assert_eq!(*store.data(), 0);
        }
    }
    Ok(())
}

mod borrowed_aggregate {
    wasmtime::component::bindgen!({
        path: "tests/all/component_model/data-host-aggregate.wit",
        imports: { default: borrowed | trappable },
    });

    impl BorrowedAggregateImports for u32 {
        fn inspect(&mut self, value: PayloadHostInput<'_>) -> wasmtime::Result<u32> {
            assert_eq!(value.text, "中文、日本語、한국어");
            if let std::borrow::Cow::Borrowed(text) = value.text {
                assert_eq!(text.as_ptr(), value.bytes.as_ptr());
            }
            *self += 1;
            Ok(*self)
        }

        fn inspect_choice(&mut self, _value: Option<ChoiceHostInput<'_>>) -> wasmtime::Result<()> {
            Ok(())
        }

        fn inspect_list(
            &mut self,
            _value: Vec<(std::borrow::Cow<'_, str>, &[u8])>,
        ) -> wasmtime::Result<()> {
            Ok(())
        }
    }
}

#[test]
fn data_host_borrows_aggregate_payloads() -> Result<()> {
    let text = "中文、日本語、한국어";
    for concurrent in [false, true] {
        let engine = engine(concurrent)?;
        let component = Component::new(&engine, include_str!("data-host-aggregate.wat"))?;
        let mut linker = Linker::<u32>::new(&engine);
        borrowed_aggregate::BorrowedAggregate::add_to_linker::<_, wasmtime::component::HasSelf<u32>>(
            &mut linker,
            |data| data,
        )?;
        for (export, ptr, len) in [
            ("utf8", 0, text.len() as u32),
            ("utf16", 128, text.encode_utf16().count() as u32),
        ] {
            let mut store = Store::new(&engine, 0);
            let instance = linker.instantiate(&mut store, &component)?;
            let run = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, export)?;
            assert_eq!(run.call(&mut store, (ptr, len))?, (1,));
            if concurrent {
                store.assert_concurrent_state_empty();
            }
        }
        for (ptr, len) in [(127, 1), (65535, 2)] {
            let mut store = Store::new(&engine, 0);
            let instance = linker.instantiate(&mut store, &component)?;
            let run = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf8")?;
            assert!(run.call(&mut store, (ptr, len)).is_err());
            assert_eq!(*store.data(), 0);
        }
    }
    Ok(())
}

#[tokio::test]
async fn data_host_prepares_owned_inputs_before_suspending() -> Result<()> {
    use wasmtime::component::{WasmList, WasmStr};
    let mut config = Config::new();
    config.wasm_component_model_async(true);
    let engine = Engine::new(&config)?;
    let component = Component::new(&engine, include_str!("data-host-prepare.wat"))?;
    let mut linker = Linker::<u32>::new(&engine);
    linker.root().func_wrap_concurrent_prepare(
        "inspect",
        |calls, memory, (text, bytes): (WasmStr, WasmList<u8>)| {
            let text = text.to_str_in(memory)?;
            assert_eq!(text, "中文、日本語、한국어");
            assert_eq!(text.as_ptr(), bytes.as_le_slice_in(memory).as_ptr());
            let request = text.into_owned();
            *calls += 1;
            Ok(request)
        },
        |_, request| {
            Box::pin(async move {
                tokio::task::yield_now().await;
                assert_eq!(request, "中文、日本語、한국어");
                Ok((request.len() as u32,))
            })
        },
    )?;
    for (ptr, len, valid) in [
        (0, "中文、日本語、한국어".len() as u32, true),
        (127, 1, false),
        (65535, 2, false),
    ] {
        let mut store = Store::new(&engine, 0);
        let instance = linker.instantiate_async(&mut store, &component).await?;
        let run = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf8")?;
        let result = run.call_async(&mut store, (ptr, len)).await;
        assert_eq!(result.is_ok(), valid);
        assert_eq!(*store.data(), u32::from(valid));
        if valid {
            store.assert_concurrent_state_empty();
        }
    }
    Ok(())
}

#[tokio::test]
async fn data_host_cancelled_preparation_releases_owned_request() -> Result<()> {
    use crate::async_functions::PollOnce;
    use std::sync::{
        Arc,
        atomic::{AtomicUsize, Ordering},
    };
    use wasmtime::component::{WasmList, WasmStr};
    struct Request {
        text: String,
        drops: Arc<AtomicUsize>,
    }
    impl Drop for Request {
        fn drop(&mut self) {
            self.drops.fetch_add(1, Ordering::SeqCst);
        }
    }
    let mut config = Config::new();
    config.wasm_component_model_async(true);
    let engine = Engine::new(&config)?;
    let component = Component::new(&engine, include_str!("data-host-prepare.wat"))?;
    let drops = Arc::new(AtomicUsize::new(0));
    let mut linker = Linker::<Arc<AtomicUsize>>::new(&engine);
    linker.root().func_wrap_concurrent_prepare(
        "inspect",
        |drops, memory, (text, bytes): (WasmStr, WasmList<u8>)| {
            let text = text.to_str_in(memory)?.into_owned();
            assert!(!bytes.as_le_slice_in(memory).is_empty());
            Ok(Request {
                text,
                drops: drops.clone(),
            })
        },
        |_, request| {
            Box::pin(async move {
                std::future::pending::<()>().await;
                Ok((request.text.len() as u32,))
            })
        },
    )?;
    let mut store = Store::new(&engine, drops.clone());
    let instance = linker.instantiate_async(&mut store, &component).await?;
    let run = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf8")?;
    let pending = PollOnce::new(Box::pin(
        run.call_async(&mut store, (0, "中文、日本語、한국어".len() as u32)),
    ))
    .await;
    assert!(pending.is_err());
    assert_eq!(drops.load(Ordering::SeqCst), 0);
    drop(pending);
    drop(store);
    assert_eq!(drops.load(Ordering::SeqCst), 1);
    Ok(())
}

mod borrowed_prepare_generated {
    wasmtime::component::bindgen!({
        path: "tests/all/component_model/data-host-prepare.wit",
        imports: { default: borrowed | trappable },
    });
    impl BorrowedPrepareImports for u32 {}
    impl<T> BorrowedPrepareImportsWithStore<T> for wasmtime::component::HasSelf<u32> {
        type InspectPrepared = String;
        fn prepare_inspect(
            host: &mut &mut u32,
            text: &str,
            bytes: &[u8],
        ) -> wasmtime::Result<String> {
            assert_eq!(text.as_ptr(), bytes.as_ptr());
            **host += 1;
            Ok(text.to_owned())
        }
        async fn inspect(
            _accessor: &wasmtime::component::Accessor<T, Self>,
            prepared: String,
        ) -> wasmtime::Result<u32> {
            tokio::task::yield_now().await;
            Ok(prepared.len() as u32)
        }
    }
}

#[tokio::test]
async fn data_host_generated_async_preparation_validates_ignored_inputs() -> Result<()> {
    let mut config = Config::new();
    config.wasm_component_model_async(true);
    let engine = Engine::new(&config)?;
    let component = Component::new(&engine, include_str!("data-host-prepare.wat"))?;
    let mut linker = Linker::<u32>::new(&engine);
    borrowed_prepare_generated::BorrowedPrepare::add_to_linker::<
        _,
        wasmtime::component::HasSelf<u32>,
    >(&mut linker, |data| data)?;
    for (ptr, len, valid) in [
        (0, "中文、日本語、한국어".len() as u32, true),
        (127, 1, false),
        (65535, 2, false),
    ] {
        let mut store = Store::new(&engine, 0);
        let instance = linker.instantiate_async(&mut store, &component).await?;
        let run = instance.get_typed_func::<(u32, u32), (u32,)>(&mut store, "utf8")?;
        assert_eq!(run.call_async(&mut store, (ptr, len)).await.is_ok(), valid);
        assert_eq!(*store.data(), u32::from(valid));
        if valid {
            store.assert_concurrent_state_empty();
        }
    }
    Ok(())
}

#[tokio::test]
async fn data_host_guest_cancellation_releases_prepared_request() -> Result<()> {
    use std::sync::{
        Arc,
        atomic::{AtomicUsize, Ordering},
    };
    let mut config = Config::new();
    config.wasm_component_model_async(true);
    let engine = Engine::new(&config)?;
    let component = Component::new(&engine, include_str!("data-host-cancel.wat"))?;
    let prepared = Arc::new(AtomicUsize::new(0));
    let mut store = Store::new(&engine, prepared.clone());
    let mut linker = Linker::<Arc<AtomicUsize>>::new(&engine);
    linker.root().func_wrap_concurrent_prepare(
        "f",
        |prepared, _, ()| {
            prepared.fetch_add(1, Ordering::SeqCst);
            Ok(prepared.clone())
        },
        |_, request| {
            Box::pin(async move {
                std::future::pending::<()>().await;
                drop(request);
                Ok(())
            })
        },
    )?;
    let instance = linker.instantiate_async(&mut store, &component).await?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "f")?;
    store
        .run_concurrent(async |accessor| -> Result<()> {
            run.call_concurrent(accessor, ()).await?;
            for _ in 0..5 {
                tokio::task::yield_now().await;
            }
            Ok(())
        })
        .await??;
    store.assert_concurrent_state_empty();
    assert_eq!(prepared.load(Ordering::SeqCst), 1);
    assert_eq!(Arc::strong_count(&prepared), 2);
    Ok(())
}
