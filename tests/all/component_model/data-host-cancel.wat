(component
            (import "f" (func $f async))

            (core module $m
                (import "" "f" (func $f (result i32)))
                (import "" "cancel" (func $cancel (param i32) (result i32)))
                (import "" "drop" (func $drop (param i32)))
                (func (export "run")
                    (local i32)

                    ;; start the subtask, asserting it's `STARTED`
                    call $f
                    local.tee 0
                    i32.const 0xf
                    i32.and
                    i32.const 1 ;; STARTED
                    i32.ne
                    if unreachable end

                    ;; extract the task id
                    local.get 0
                    i32.const 4
                    i32.shr_u
                    local.set 0

                    ;; cancel the subtask asserting it's `RETURN_CANCELLED`
                    local.get 0
                    call $cancel
                    i32.const 4 ;; RETURN_CANCELLED
                    i32.ne
                    if unreachable end

                    ;; drop the subtask
                    local.get 0
                    call $drop
                )
            )
            (core func $f (canon lower (func $f) async))
            (core func $cancel (canon subtask.cancel))
            (core func $drop (canon subtask.drop))
            (core instance $i (instantiate $m
                (with "" (instance
                    (export "f" (func $f))
                    (export "cancel" (func $cancel))
                    (export "drop" (func $drop))
                ))
            ))

            (func (export "f") async
                (canon lift (core func $i "run")))


        )
