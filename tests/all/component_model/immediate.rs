//! Immediate host implementations retain the async WIT type and lowering ABI.

use wasmtime::component::{Component, Linker, Resource, ResourceType, TypedFunc};
use wasmtime::{Config, Engine, Result, Store, Trap};

mod generated {
    wasmtime::component::bindgen!({
        path: "tests/all/component_model/immediate.wit",
        imports: { default: immediate | trappable },
    });

    impl<T> ImmediateImportsWithStore<T> for wasmtime::component::HasSelf<u32> {
        fn increment(
            mut host: wasmtime::component::Access<'_, T, Self>,
            n: u32,
        ) -> wasmtime::Result<()> {
            *host.get() += n;
            Ok(())
        }
    }
    impl ImmediateImports for u32 {}
}

fn engine() -> Result<Engine> {
    let mut config = Config::new();
    config.wasm_component_model_async(true);
    Engine::new(&config)
}

#[tokio::test]
async fn immediate_host_rejects_synchronous_wit_import() -> Result<()> {
    let engine = engine()?;
    let component = Component::new(
        &engine,
        r#"(component (import "increment" (func (param "n" u32))))"#,
    )?;
    let mut linker = Linker::<()>::new(&engine);
    linker
        .root()
        .func_wrap_concurrent_immediate("increment", |_, (_n,): (u32,)| Ok(()))?;
    let mut store = Store::new(&engine, ());
    assert!(
        linker
            .instantiate_async(&mut store, &component)
            .await
            .is_err()
    );
    Ok(())
}

#[test]
fn immediate_host_requires_concurrency_support() -> Result<()> {
    let mut config = Config::new();
    config.concurrency_support(false);
    let engine = Engine::new(&config)?;
    let mut linker = Linker::<()>::new(&engine);
    let error = linker
        .root()
        .func_wrap_concurrent_immediate("increment", |_, (_n,): (u32,)| Ok(()))
        .expect_err("concurrency support is disabled");
    assert!(error.to_string().contains("concurrency_support"));
    Ok(())
}

#[tokio::test]
async fn immediate_host_preserves_reentry_checks() -> Result<()> {
    let engine = engine()?;
    let component = Component::new(&engine, include_str!("immediate.wat"))?;
    for export in ["sync", "async"] {
        let mut linker = Linker::<Option<TypedFunc<(), ()>>>::new(&engine);
        linker
            .root()
            .func_wrap_concurrent_immediate("increment", |mut store, (_n,): (u32,)| {
                let reenter = store.data().unwrap();
                let error = reenter
                    .call(&mut store, ())
                    .expect_err("reentry is forbidden");
                assert_eq!(error.downcast_ref(), Some(&Trap::CannotEnterComponent));
                Ok(())
            })?;
        let mut store = Store::new(&engine, None);
        let instance = linker.instantiate_async(&mut store, &component).await?;
        *store.data_mut() = Some(instance.get_typed_func(&mut store, "reenter")?);
        let run = instance.get_typed_func::<(), ()>(&mut store, export)?;
        run.call_async(&mut store, ()).await?;
        store.assert_concurrent_state_empty();
    }
    Ok(())
}

#[tokio::test]
async fn immediate_host_preserves_resource_borrows() -> Result<()> {
    let engine = engine()?;
    let component = Component::new(&engine, include_str!("immediate-resource.wat"))?;
    for export in ["sync", "async"] {
        let mut linker = Linker::<u32>::new(&engine);
        linker
            .root()
            .resource("item", ResourceType::host::<u32>(), |_, _| {
                panic!("borrowed resource must not be destroyed")
            })?;
        linker.root().func_wrap_concurrent_immediate(
            "inspect",
            |mut store, (item,): (Resource<u32>,)| {
                assert!(!item.owned());
                *store.data_mut() += item.rep();
                Ok(())
            },
        )?;
        let mut store = Store::new(&engine, 0);
        let instance = linker.instantiate_async(&mut store, &component).await?;
        let run = instance.get_typed_func::<(Resource<u32>,), ()>(&mut store, export)?;
        for _ in 0..100 {
            run.call_async(&mut store, (Resource::new_borrow(42),))
                .await?;
            store.assert_concurrent_state_empty();
        }
        assert_eq!(*store.data(), 4200);
    }
    Ok(())
}

#[tokio::test]
async fn immediate_host_supports_both_lowering_modes() -> Result<()> {
    let engine = engine()?;
    let component = Component::new(&engine, include_str!("immediate.wat"))?;
    for generated in [false, true] {
        for export in ["sync", "async"] {
            let mut linker = Linker::<u32>::new(&engine);
            if generated {
                generated::Immediate::add_to_linker::<_, wasmtime::component::HasSelf<u32>>(
                    &mut linker,
                    |data| data,
                )?;
            } else {
                linker.root().func_wrap_concurrent_immediate(
                    "increment",
                    |mut store, (n,): (u32,)| {
                        *store.data_mut() += n;
                        Ok(())
                    },
                )?;
            }
            let mut store = Store::new(&engine, 0);
            let instance = linker.instantiate_async(&mut store, &component).await?;
            let run = instance.get_typed_func::<(), ()>(&mut store, export)?;
            for _ in 0..100 {
                run.call_async(&mut store, ()).await?;
                store.assert_concurrent_state_empty();
            }
            assert_eq!(*store.data(), 1800);
        }
    }
    Ok(())
}

#[tokio::test]
async fn immediate_host_traps_in_both_lowering_modes() -> Result<()> {
    let engine = engine()?;
    let component = Component::new(&engine, include_str!("immediate.wat"))?;
    for export in ["sync", "async"] {
        let mut linker = Linker::<()>::new(&engine);
        linker
            .root()
            .func_wrap_concurrent_immediate("increment", |_, (_n,): (u32,)| -> Result<()> {
                Err(wasmtime::Error::msg("immediate host trap"))
            })?;
        let mut store = Store::new(&engine, ());
        let instance = linker.instantiate_async(&mut store, &component).await?;
        let run = instance.get_typed_func::<(), ()>(&mut store, export)?;
        let error = run
            .call_async(&mut store, ())
            .await
            .expect_err("host traps");
        assert!(format!("{error:#}").contains("immediate host trap"));
    }
    Ok(())
}
