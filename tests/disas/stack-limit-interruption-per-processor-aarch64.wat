;;! target = "aarch64"
;;! test = "compile"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=processor:16"]

;; With the stack limit in the executing processor's local block, every
;; resumable check reads it through the thread pointer, with no load of the
;; store context. `$leaf` still has no check, `$spin` checks at its loop
;; header, and `$caller` at entry.
(module
  (func $leaf (param i32) (result i32)
    (i32.add (local.get 0) (i32.const 1)))
  (func $spin (param i32)
    (loop $l
      (br_if $l (local.tee 0 (i32.sub (local.get 0) (i32.const 1))))))
  (func $caller (param i32) (result i32)
    (call $leaf (local.get 0))))
;; wasm[0]::function[0]::leaf:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       add     w2, w4, #1
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;
;; wasm[0]::function[1]::spin:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldur    x16, [x2, #8]
;;       ldur    x16, [x16, #0x90]
;;       add     x16, x16, #0x10
;;       cmp     sp, x16
;;       b.lo    #0x7c
;;   3c: mrs     x8, tpidr_el1
;;       ldur    x8, [x8, #0x10]
;;       mov     x9, sp
;;       cmp     x9, x8
;;       b.lo    #0x6c
;;   50: mov     x0, x2
;;       sub     w4, w4, #1
;;       cbz     w4, #0x64
;;   5c: mov     x2, x0
;;       b       #0x3c
;;   64: ldp     x29, x30, [sp], #0x10
;;       ret
;;   6c: mov     x1, sp
;;   70: mov     x0, x2
;;   74: bl      #0x1b0
;;   78: b       #0x54
;;   7c: udf     #0xc11f
;;
;; wasm[0]::function[2]::caller:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mrs     x6, tpidr_el1
;;       ldur    x6, [x6, #0x10]
;;       mov     x7, sp
;;       cmp     x7, x6
;;       b.lo    #0xb0
;;   9c: mov     x3, x2
;;       mov     x2, x3
;;       bl      #0
;;   a8: ldp     x29, x30, [sp], #0x10
;;       ret
;;   b0: mov     x1, sp
;;   b4: mov     x0, x2
;;   b8: bl      #0x1b0
;;   bc: mov     x3, x0
;;   c0: b       #0xa0
