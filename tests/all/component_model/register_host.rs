use object::{Object, ObjectSymbol};
use wasmtime::component::{Component, Linker, Val};
use wasmtime::{Config, Engine, Result, Store};

#[test]
fn typed_and_dynamic_scalar_hosts_after_aot() -> Result<()> {
    for concurrent in [false, true] {
        let mut config = Config::new();
        config.concurrency_support(concurrent);
        let engine = Engine::new(&config)?;
        let artifact = engine.precompile_component(include_bytes!("register-host.wat"))?;
        let object = object::File::parse(&*artifact)?;
        let register_symbols = object
            .symbols()
            .filter(|symbol| {
                symbol
                    .name()
                    .is_ok_and(|name| name.starts_with("component-register-trampolines["))
            })
            .count();
        if wasmtime_environ::component::supports_register_host_abi(&target_lexicon::HOST) {
            // Four imports, each with a Wasm and an array entrypoint.
            assert_eq!(register_symbols, 8);
        } else {
            assert_eq!(register_symbols, 0);
        }
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

#[test]
fn maximum_flat_parameters_preserve_argument_order() -> Result<()> {
    type Args = (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
    );
    let expected: Args = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, u64::MAX);
    let engine = Engine::default();
    let component = Component::new(&engine, include_str!("register-host-many.wat"))?;
    let mut linker = Linker::new(&engine);
    linker
        .root()
        .func_wrap_data("many", move |_: &mut (), args: Args| {
            // Rust tuple Debug/PartialEq implementations stop before this arity.
            let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) = args;
            assert_eq!(
                [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p],
                [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, u64::MAX]
            );
            Ok((p,))
        })?;
    let mut store = Store::new(&engine, ());
    let instance = linker.instantiate(&mut store, &component)?;
    let run = instance.get_typed_func::<Args, (u64,)>(&mut store, "run")?;
    assert_eq!(run.call(&mut store, expected)?, (u64::MAX,));
    Ok(())
}
