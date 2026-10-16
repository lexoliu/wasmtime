;;! target = "aarch64"
;;! test = "compile"
;;! flags = ["-Wstack-limit-interruption=y"]

;; With stack-limit interruption, a function that calls no wasm has no
;; interruption check at entry: `$leaf` compiles with no call and no frame.
;; `$spin` checks the published limit at its loop header only, and
;; `$caller`, which calls wasm, keeps the resumable check at entry.
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
;;       add     x16, x16, #0x30
;;       cmp     sp, x16
;;       b.lo    #0x98
;;   3c: stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       mov     x21, x4
;;       ldr     x19, [x2, #8]
;;       mov     x22, x2
;;       mov     x20, sp
;;       ldr     x9, [x19, #0x18]
;;       cmp     x20, x9
;;       b.lo    #0x84
;;   60: mov     x4, x21
;;       sub     w4, w4, #1
;;       cbz     w4, #0x74
;;   6c: mov     x21, x4
;;       b       #0x54
;;   74: ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;   84: mov     x2, x22
;;   88: mov     x3, x20
;;   8c: bl      #0x1e4
;;   90: mov     x4, x21
;;   94: b       #0x64
;;   98: udf     #0xc11f
;;
;; wasm[0]::function[2]::caller:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x19, x20, [sp, #-0x10]!
;;       mov     x19, x4
;;       ldr     x7, [x2, #8]
;;       mov     x20, x2
;;       ldr     x7, [x7, #0x18]
;;       mov     x3, sp
;;       cmp     x3, x7
;;       b.lo    #0xe4
;;   c8: mov     x3, x20
;;       mov     x4, x19
;;       mov     x2, x3
;;       bl      #0
;;   d8: ldp     x19, x20, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;   e4: mov     x2, x20
;;   e8: bl      #0x1e4
;;   ec: mov     x3, x20
;;   f0: mov     x4, x19
;;   f4: b       #0xd0
