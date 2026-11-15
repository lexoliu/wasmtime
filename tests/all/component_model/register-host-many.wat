(component
  (import "many" (func $many
    (param "a" u64) (param "b" u64) (param "c" u64) (param "d" u64)
    (param "e" u64) (param "f" u64) (param "g" u64) (param "h" u64)
    (param "i" u64) (param "j" u64) (param "k" u64) (param "l" u64)
    (param "m" u64) (param "n" u64) (param "o" u64) (param "p" u64)
    (result u64)))
  (core func $many (canon lower (func $many)))
  (core module $m
    (import "" "many" (func $many
      (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)
      (result i64)))
    (func (export "run")
      (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)
      (result i64)
      (call $many
        (local.get 0) (local.get 1) (local.get 2) (local.get 3)
        (local.get 4) (local.get 5) (local.get 6) (local.get 7)
        (local.get 8) (local.get 9) (local.get 10) (local.get 11)
        (local.get 12) (local.get 13) (local.get 14) (local.get 15))))
  (core instance $i (instantiate $m (with "" (instance (export "many" (func $many))))))
  (func (export "run")
    (param "a" u64) (param "b" u64) (param "c" u64) (param "d" u64)
    (param "e" u64) (param "f" u64) (param "g" u64) (param "h" u64)
    (param "i" u64) (param "j" u64) (param "k" u64) (param "l" u64)
    (param "m" u64) (param "n" u64) (param "o" u64) (param "p" u64)
    (result u64) (canon lift (core func $i "run"))))
