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
;;       add     x16, x16, #0x10
;;       cmp     sp, x16
;;       b.lo    #0x78
;;   3c: ldr     x7, [x2, #8]
;;       mov     x1, sp
;;       ldr     x8, [x7, #0x18]
;;       cmp     x1, x8
;;       b.lo    #0x6c
;;   50: mov     x0, x2
;;       sub     w4, w4, #1
;;       cbz     w4, #0x64
;;   5c: mov     x2, x0
;;       b       #0x44
;;   64: ldp     x29, x30, [sp], #0x10
;;       ret
;;   6c: mov     x0, x2
;;   70: bl      #0x1ac
;;   74: b       #0x54
;;   78: udf     #0xc11f
;;
;; wasm[0]::function[2]::caller:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldr     x6, [x2, #8]
;;       ldr     x6, [x6, #0x18]
;;       mov     x1, sp
;;       cmp     x1, x6
;;       b.lo    #0xb0
;;   9c: mov     x3, x2
;;       mov     x2, x3
;;       bl      #0
;;   a8: ldp     x29, x30, [sp], #0x10
;;       ret
;;   b0: mov     x0, x2
;;   b4: bl      #0x1ac
;;   b8: mov     x3, x0
;;   bc: b       #0xa0
