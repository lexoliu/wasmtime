(component
  (import "text" (func $text (result string)))
  (core module $memory
    (memory (export "memory") 1)
    (global $allocations (mut i32) (i32.const 0))
    (func (export "realloc") (param i32 i32 i32 i32) (result i32)
      (global.set $allocations (i32.add (global.get $allocations) (i32.const 1)))
      (i32.const 64))
    (func (export "allocations") (result i32) (global.get $allocations)))
  (core instance $memory (instantiate $memory))
  (core func $text (canon lower (func $text)
    (memory $memory "memory") (realloc (func $memory "realloc"))))
  (core module $m
    (import "" "text" (func $text (param i32)))
    (func (export "run") (result i32)
      (call $text (i32.const 0))
      (i32.const 0)))
  (core instance $i (instantiate $m (with "" (instance
    (export "text" (func $text))))))
  (func (export "run") (result string)
    (canon lift (core func $i "run") (memory $memory "memory")))
  (func (export "allocations") (result u32)
    (canon lift (core func $memory "allocations"))))
