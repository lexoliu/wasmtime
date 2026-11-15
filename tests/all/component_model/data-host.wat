(component
  (import "increment" (func $increment (param "n" u32) (result u32)))
  (core func $increment (canon lower (func $increment)))
  (core module $m
    (import "" "increment" (func $increment (param i32) (result i32)))
    (func (export "run") (param i32) (result i32)
      (call $increment (local.get 0))))
  (core instance $i (instantiate $m (with "" (instance
    (export "increment" (func $increment))))))
  (func (export "run") (param "n" u32) (result u32)
    (canon lift (core func $i "run"))))
