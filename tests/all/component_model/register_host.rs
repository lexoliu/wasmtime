use wasmtime::component::{Component, Linker, Val};
use wasmtime::{Config, Engine, Result, Store};

#[test]
fn typed_and_dynamic_scalar_hosts_after_aot() -> Result<()> {
    for concurrent in [false, true] {
        let mut config = Config::new();
        config.concurrency_support(concurrent);
        let engine = Engine::new(&config)?;
        let artifact = engine.precompile_component(include_bytes!("register-host.wat"))?;
        // The bytes come from this engine's compiler, not an untrusted artifact.
        let component = unsafe { Component::deserialize(&engine, &artifact)? };
        for dynamic in [false, true] {
            let mut linker = Linker::<u32>::new(&engine);
            if dynamic {
                linker.root().func_new("mix", |_, _, args, results| {
                    assert_eq!(
                        args,
                        &[
                            Val::U32(u32::MAX),
                            Val::S64(i64::MIN),
                            Val::Float32(-0.0),
                            Val::Float64(f64::INFINITY)
                        ]
                    );
                    results[0] = Val::U64(u64::MAX);
                    Ok(())
                })?;
            } else {
                linker
                    .root()
                    .func_wrap("mix", |_, (a, b, c, d): (u32, i64, f32, f64)| {
                        assert_eq!(a, u32::MAX);
                        assert_eq!(b, i64::MIN);
                        assert_eq!(c.to_bits(), (-0.0f32).to_bits());
                        assert_eq!(d, f64::INFINITY);
                        Ok((u64::MAX,))
                    })?;
            }
            linker
                .root()
                .func_wrap_data("float", |_, (x,): (f64,)| Ok((x,)))?;
            linker
                .root()
                .func_wrap_data("clock", |_, (): ()| Ok((u64::MAX,)))?;
            linker.root().func_wrap_data("notify", |count, (): ()| {
                *count += 1;
                Ok(())
            })?;
            let mut store = Store::new(&engine, 0);
            let instance = linker.instantiate(&mut store, &component)?;
            let mix = instance.get_typed_func::<(u32, i64, f32, f64), (u64,)>(&mut store, "mix")?;
            assert_eq!(
                mix.call(&mut store, (u32::MAX, i64::MIN, -0.0, f64::INFINITY))?,
                (u64::MAX,)
            );
            let float = instance.get_typed_func::<(f64,), (f64,)>(&mut store, "float")?;
            for x in [-0.0f64, f64::INFINITY, f64::NEG_INFINITY, f64::MIN_POSITIVE] {
                assert_eq!(float.call(&mut store, (x,))?.0.to_bits(), x.to_bits());
            }
            let clock = instance.get_typed_func::<(), (u64,)>(&mut store, "clock")?;
            assert_eq!(clock.call(&mut store, ())?, (u64::MAX,));
            let notify = instance.get_typed_func::<(), ()>(&mut store, "notify")?;
            notify.call(&mut store, ())?;
            assert_eq!(*store.data(), 1);
            if concurrent {
                store.assert_concurrent_state_empty();
            }
        }
    }
    Ok(())
}
