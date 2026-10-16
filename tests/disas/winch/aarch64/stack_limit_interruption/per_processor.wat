;;! target = "aarch64"
;;! test = "winch"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=processor:16"]

;; Winch reads the per-processor stack limit through the thread pointer at
;; function entry and at loop headers.
(module
  (func $spin (param i32)
    (loop $l
      (br_if $l (local.tee 0 (i32.sub (local.get 0) (i32.const 1)))))))
;; wasm[0]::function[0]::spin:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       str     x28, [sp, #-0x10]!
;;       mov     x28, sp
;;       ldur    x16, [x0, #8]
;;       ldur    x16, [x16, #0x90]
;;       mov     x17, #0
;;       movk    x17, #0x20
;;       add     x16, x16, x17
;;       cmp     sp, x16
;;       b.lo    #0xec
;;   2c: mov     x9, x0
;;       sub     x28, x28, #0x18
;;       mov     sp, x28
;;       stur    x0, [x28, #0x10]
;;       stur    x1, [x28, #8]
;;       stur    w2, [x28, #4]
;;       mrs     x2, tpidr_el1
;;       ldur    x2, [x2, #0x10]
;;       mov     x3, x28
;;       cmp     x3, x2, uxtx
;;       b.hs    #0x80
;;       b       #0x5c
;;   5c: sub     x28, x28, #8
;;       mov     sp, x28
;;       stur    x3, [x28]
;;       mov     x0, x9
;;       ldur    x1, [x28]
;;       bl      #0x168
;;   74: add     x28, x28, #8
;;       mov     sp, x28
;;       ldur    x9, [x28, #0x10]
;;       mrs     x2, tpidr_el1
;;       ldur    x2, [x2, #0x10]
;;       mov     x3, x28
;;       cmp     x3, x2, uxtx
;;       b.hs    #0xbc
;;       b       #0x98
;;   98: sub     x28, x28, #8
;;       mov     sp, x28
;;       stur    x3, [x28]
;;       mov     x0, x9
;;       ldur    x1, [x28]
;;       bl      #0x168
;;   b0: add     x28, x28, #8
;;       mov     sp, x28
;;       ldur    x9, [x28, #0x10]
;;       ldur    w0, [x28, #4]
;;       sub     w0, w0, #1
;;       stur    w0, [x28, #4]
;;       tst     w0, w0
;;       b.ne    #0x80
;;       b       #0xd4
;;   d4: add     x28, x28, #0x18
;;       mov     sp, x28
;;       mov     sp, x28
;;       ldr     x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;   ec: udf     #0xc11f
