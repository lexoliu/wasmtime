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
