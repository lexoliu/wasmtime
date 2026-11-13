;;! target = "aarch64"
;;! test = "compile"
;;! flags = ["-Ccranelift-use_bti", "-Ccranelift-sign_return_address", "-Wtail-call", "-Wexceptions"]
;;! objdump = "--funcs all"

(module
  (type $t (func (param i32) (result i32)))
  (table 1 funcref)
  (elem (i32.const 0) $callee)
  (tag $e)

  (func $callee (type $t) (local.get 0))

  ;; A function with a frame and a call.
  (func (export "call") (param i32) (result i32)
    (call $callee (local.get 0)))

  ;; An indirect tail call.
  (func (export "tail") (param i32) (result i32)
    (return_call_indirect (type $t) (local.get 0) (i32.const 0)))

  ;; A `br_table` with a default target.
  (func (export "table") (param i32) (result i32)
    (block $d
      (block $b
        (block $a
          (br_table $a $b $d (local.get 0)))
        (return (i32.const 10)))
      (return (i32.const 20)))
    (i32.const 30))

  ;; An exception handler block.
  (func (export "catch") (param i32) (result i32)
    (block $h
      (try_table (catch $e $h)
        (call $callee (local.get 0))
        drop
        throw $e)
      (return (i32.const 1)))
    (i32.const 2))
)
;; wasm[0]::function[0]::callee:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mov     x2, x4
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;
;; wasm[0]::function[1]:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldur    x16, [x2, #8]
;;       ldur    x16, [x16, #0x18]
;;       add     x16, x16, #0x10
;;       cmp     sp, x16
;;       b.lo    #0x58
;;   44: mov     x3, x2
;;       bl      #0
;;   4c: ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;   58: udf     #0xc11f
;;       ╰─╼ trap: Normal(StackOverflow)
;;
;; wasm[0]::function[2]:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldur    x16, [x2, #8]
;;       ldur    x16, [x16, #0x18]
;;       add     x16, x16, #0x20
;;       cmp     sp, x16
;;       b.lo    #0x104
;;   84: stp     x19, x20, [sp, #-0x10]!
;;       mov     x20, x4
;;       ldr     x0, [x2, #0x38]
;;       ldr     x1, [x2, #0x30]
;;       mov     x5, x2
;;       mov     x2, #0
;;       cmp     w0, wzr
;;       csel    x0, x2, x1, eq
;;       ldr     x0, [x0]
;;       ╰─╼ trap: Normal(TableOutOfBounds)
;;       and     x2, x0, #0xfffffffffffffffe
;;       cbz     x0, #0xec
;;   b0: mov     x19, x5
;;       ldr     w0, [x2, #0x10]
;;       ╰─╼ trap: Normal(IndirectCallToNull)
;;       ldr     x1, [x19, #0x28]
;;       ldr     w1, [x1]
;;       cmp     w0, w1
;;       b.ne    #0x108
;;   c8: ldr     x1, [x2, #8]
;;       ldr     x2, [x2, #0x18]
;;       mov     x3, x19
;;       mov     x4, x20
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       mov     x16, x1
;;       br      x16
;;   ec: mov     w3, #0
;;       mov     x4, #0
;;       mov     x19, x5
;;       mov     x2, x19
;;       bl      #0x8d0
;;       b       #0xb4
;;  104: udf     #0xc11f
;;       ╰─╼ trap: Normal(StackOverflow)
;;       udf     #0xc11f
;;       ╰─╼ trap: Normal(BadSignature)
;;
;; wasm[0]::function[3]:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       cmp     w4, #2
;;       mov     x8, #2
;;       csel    x8, x4, x8, lo
;;       adr     x7, #0x14c
;;       ldrsw   x8, [x7, w8, uxtw #2]
;;       add     x7, x7, x8
;;       br      x7
;;  14c: udf     #0x20
;;       udf     #0xc
;;       udf     #0x34
;;       bti     j
;;       mov     w2, #0x14
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;  16c: bti     j
;;  170: mov     w2, #0xa
;;  174: ldp     x29, x30, [sp], #0x10
;;  178: autiaz
;;  17c: ret
;;  180: bti     j
;;  184: mov     w2, #0x1e
;;  188: ldp     x29, x30, [sp], #0x10
;;  18c: autiaz
;;  190: ret
;;
;; wasm[0]::function[4]:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldur    x16, [x2, #8]
;;       ldur    x16, [x16, #0x18]
;;       add     x16, x16, #0xb0
;;       cmp     sp, x16
;;       b.lo    #0x310
;;  1c4: stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       stur    x2, [sp]
;;       ldur    x2, [sp]
;;       ldur    x3, [sp]
;;       bl      #0
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: tag=0, context at [SP+0x0], handler=0x200
;;       b       #0x208
;;  200: bti     j
;;       b       #0x294
;;  208: mov     x0, x2
;;       ldur    x2, [sp]
;;       bl      #0x9a0
;;  214: mov     x19, x2
;;       ldur    x2, [sp]
;;       ldr     x0, [x2, #0x20]
;;       ldr     w3, [x0]
;;       mov     w1, w3
;;       add     x1, x1, #0x20
;;       ldr     w2, [x0, #4]
;;       cmp     x1, x2
;;       b.hi    #0x2d0
;;  238: add     w1, w3, #0x20
;;       str     w1, [x0]
;;       mov     w1, #2
;;       movk    w1, #0x400, lsl #16
;;       ldur    x2, [sp]
;;       ldr     x0, [x2, #8]
;;       ldr     x2, [x0, #0x20]
;;       add     x0, x2, w3, uxtw
;;       str     w1, [x2, w3, uxtw]
;;       ╰─╼ trap: GcHeapCorrupt
;;       ldur    x2, [sp]
;;       ldr     x1, [x2, #0x28]
;;       ldr     w1, [x1, #8]
;;       str     w1, [x0, #4]
;;       ╰─╼ trap: GcHeapCorrupt
;;       mov     x1, #0x20
;;       str     w1, [x0, #8]
;;       ╰─╼ trap: GcHeapCorrupt
;;       mov     x2, x19
;;       str     w2, [x0, #0x10]
;;       ╰─╼ trap: GcHeapCorrupt
;;       mov     w1, #0
;;       str     w1, [x0, #0x14]
;;       ╰─╼ trap: GcHeapCorrupt
;;       ldur    x2, [sp]
;;       bl      #0x9ec
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: tag=0, context at [SP+0x0], handler=0x290
;;       b       #0x30c
;;  290: bti     j
;;       bti     j
;;       mov     w2, #2
;;       add     sp, sp, #0x10
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;  2d0: mov     w3, #2
;;  2d4: movk    w3, #0x400, lsl #16
;;  2d8: ldur    x2, [sp]
;;  2dc: ldr     x0, [x2, #0x28]
;;  2e0: ldr     w4, [x0, #8]
;;  2e4: mov     w5, #0x20
;;  2e8: mov     w6, #0x10
;;  2ec: bl      #0x924
;;  2f0: ldur    x0, [sp]
;;  2f4: ldr     x0, [x0, #8]
;;  2f8: ldr     x0, [x0, #0x20]
;;  2fc: add     x0, x0, w2, uxtw
;;  300: mov     x3, x2
;;  304: mov     x2, x19
;;  308: b       #0x278
;;  30c: udf     #0xc11f
;;       ╰─╼ trap: Normal(UnreachableCodeReached)
;;  310: udf     #0xc11f
;;       ╰─╼ trap: Normal(StackOverflow)
;;
;; wasm[0]::array_to_wasm_trampoline[0]:
;;       paciasp
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       ldr     w4, [x2]
;;       stur    x2, [sp]
;;       mov     x3, x29
;;       ldr     x5, [x0, #8]
;;       str     x3, [x5, #0x48]
;;       mov     x3, sp
;;       str     x3, [x5, #0x40]
;;       adr     x3, #0x3bc
;;       str     x3, [x5, #0x50]
;;       mov     x2, x0
;;       mov     x3, x1
;;       stur    x5, [sp, #8]
;;       bl      #0
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x3bc
;;  37c: ldur    x0, [sp]
;;       str     w2, [x0]
;;       mov     w0, #1
;;       add     sp, sp, #0x10
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiasp
;;       ret
;;  3bc: bti     j
;;  3c0: mov     x0, #1
;;  3c4: ldur    x5, [sp, #8]
;;  3c8: str     x0, [x5, #0x88]
;;  3cc: mov     w0, #0
;;  3d0: add     sp, sp, #0x10
;;  3d4: ldp     d8, d9, [sp], #0x10
;;  3d8: ldp     d10, d11, [sp], #0x10
;;  3dc: ldp     d12, d13, [sp], #0x10
;;  3e0: ldp     d14, d15, [sp], #0x10
;;  3e4: ldp     x19, x20, [sp], #0x10
;;  3e8: ldp     x21, x22, [sp], #0x10
;;  3ec: ldp     x23, x24, [sp], #0x10
;;  3f0: ldp     x25, x26, [sp], #0x10
;;  3f4: ldp     x27, x28, [sp], #0x10
;;  3f8: ldp     x29, x30, [sp], #0x10
;;  3fc: autiasp
;;  400: ret
;;
;; wasm[0]::array_to_wasm_trampoline[1]:
;;       paciasp
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       ldr     w4, [x2]
;;       stur    x2, [sp]
;;       mov     x3, x29
;;       ldr     x5, [x0, #8]
;;       str     x3, [x5, #0x48]
;;       mov     x3, sp
;;       str     x3, [x5, #0x40]
;;       adr     x3, #0x4ac
;;       str     x3, [x5, #0x50]
;;       mov     x2, x0
;;       mov     x3, x1
;;       stur    x5, [sp, #8]
;;       bl      #0x20
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x4ac
;;  46c: ldur    x0, [sp]
;;       str     w2, [x0]
;;       mov     w0, #1
;;       add     sp, sp, #0x10
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiasp
;;       ret
;;  4ac: bti     j
;;  4b0: mov     x0, #1
;;  4b4: ldur    x5, [sp, #8]
;;  4b8: str     x0, [x5, #0x88]
;;  4bc: mov     w0, #0
;;  4c0: add     sp, sp, #0x10
;;  4c4: ldp     d8, d9, [sp], #0x10
;;  4c8: ldp     d10, d11, [sp], #0x10
;;  4cc: ldp     d12, d13, [sp], #0x10
;;  4d0: ldp     d14, d15, [sp], #0x10
;;  4d4: ldp     x19, x20, [sp], #0x10
;;  4d8: ldp     x21, x22, [sp], #0x10
;;  4dc: ldp     x23, x24, [sp], #0x10
;;  4e0: ldp     x25, x26, [sp], #0x10
;;  4e4: ldp     x27, x28, [sp], #0x10
;;  4e8: ldp     x29, x30, [sp], #0x10
;;  4ec: autiasp
;;  4f0: ret
;;
;; wasm[0]::array_to_wasm_trampoline[2]:
;;       paciasp
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       ldr     w4, [x2]
;;       stur    x2, [sp]
;;       mov     x3, x29
;;       ldr     x5, [x0, #8]
;;       str     x3, [x5, #0x48]
;;       mov     x3, sp
;;       str     x3, [x5, #0x40]
;;       adr     x3, #0x59c
;;       str     x3, [x5, #0x50]
;;       mov     x2, x0
;;       mov     x3, x1
;;       stur    x5, [sp, #8]
;;       bl      #0x60
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x59c
;;  55c: ldur    x0, [sp]
;;       str     w2, [x0]
;;       mov     w0, #1
;;       add     sp, sp, #0x10
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiasp
;;       ret
;;  59c: bti     j
;;  5a0: mov     x0, #1
;;  5a4: ldur    x5, [sp, #8]
;;  5a8: str     x0, [x5, #0x88]
;;  5ac: mov     w0, #0
;;  5b0: add     sp, sp, #0x10
;;  5b4: ldp     d8, d9, [sp], #0x10
;;  5b8: ldp     d10, d11, [sp], #0x10
;;  5bc: ldp     d12, d13, [sp], #0x10
;;  5c0: ldp     d14, d15, [sp], #0x10
;;  5c4: ldp     x19, x20, [sp], #0x10
;;  5c8: ldp     x21, x22, [sp], #0x10
;;  5cc: ldp     x23, x24, [sp], #0x10
;;  5d0: ldp     x25, x26, [sp], #0x10
;;  5d4: ldp     x27, x28, [sp], #0x10
;;  5d8: ldp     x29, x30, [sp], #0x10
;;  5dc: autiasp
;;  5e0: ret
;;
;; wasm[0]::array_to_wasm_trampoline[3]:
;;       paciasp
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       ldr     w4, [x2]
;;       stur    x2, [sp]
;;       mov     x3, x29
;;       ldr     x5, [x0, #8]
;;       str     x3, [x5, #0x48]
;;       mov     x3, sp
;;       str     x3, [x5, #0x40]
;;       adr     x3, #0x68c
;;       str     x3, [x5, #0x50]
;;       mov     x2, x0
;;       mov     x3, x1
;;       stur    x5, [sp, #8]
;;       bl      #0x120
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x68c
;;  64c: ldur    x0, [sp]
;;       str     w2, [x0]
;;       mov     w0, #1
;;       add     sp, sp, #0x10
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiasp
;;       ret
;;  68c: bti     j
;;  690: mov     x0, #1
;;  694: ldur    x5, [sp, #8]
;;  698: str     x0, [x5, #0x88]
;;  69c: mov     w0, #0
;;  6a0: add     sp, sp, #0x10
;;  6a4: ldp     d8, d9, [sp], #0x10
;;  6a8: ldp     d10, d11, [sp], #0x10
;;  6ac: ldp     d12, d13, [sp], #0x10
;;  6b0: ldp     d14, d15, [sp], #0x10
;;  6b4: ldp     x19, x20, [sp], #0x10
;;  6b8: ldp     x21, x22, [sp], #0x10
;;  6bc: ldp     x23, x24, [sp], #0x10
;;  6c0: ldp     x25, x26, [sp], #0x10
;;  6c4: ldp     x27, x28, [sp], #0x10
;;  6c8: ldp     x29, x30, [sp], #0x10
;;  6cc: autiasp
;;  6d0: ret
;;
;; wasm[0]::array_to_wasm_trampoline[4]:
;;       paciasp
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       ldr     w4, [x2]
;;       stur    x2, [sp]
;;       mov     x3, x29
;;       ldr     x5, [x0, #8]
;;       str     x3, [x5, #0x48]
;;       mov     x3, sp
;;       str     x3, [x5, #0x40]
;;       adr     x3, #0x77c
;;       str     x3, [x5, #0x50]
;;       mov     x2, x0
;;       mov     x3, x1
;;       stur    x5, [sp, #8]
;;       bl      #0x1a0
;;       ├─╼ exception frame offset: SP = FP - 0xa0
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x77c
;;  73c: ldur    x0, [sp]
;;       str     w2, [x0]
;;       mov     w0, #1
;;       add     sp, sp, #0x10
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiasp
;;       ret
;;  77c: bti     j
;;  780: mov     x0, #1
;;  784: ldur    x5, [sp, #8]
;;  788: str     x0, [x5, #0x88]
;;  78c: mov     w0, #0
;;  790: add     sp, sp, #0x10
;;  794: ldp     d8, d9, [sp], #0x10
;;  798: ldp     d10, d11, [sp], #0x10
;;  79c: ldp     d12, d13, [sp], #0x10
;;  7a0: ldp     d14, d15, [sp], #0x10
;;  7a4: ldp     x19, x20, [sp], #0x10
;;  7a8: ldp     x21, x22, [sp], #0x10
;;  7ac: ldp     x23, x24, [sp], #0x10
;;  7b0: ldp     x25, x26, [sp], #0x10
;;  7b4: ldp     x27, x28, [sp], #0x10
;;  7b8: ldp     x29, x30, [sp], #0x10
;;  7bc: autiasp
;;  7c0: ret
;;
;; signatures[0]::wasm_to_array_trampoline:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       str     x19, [sp, #-0x10]!
;;       sub     sp, sp, #0x10
;;       mov     x1, x2
;;       mov     x19, x3
;;       mov     x14, x29
;;       ldr     x13, [x3, #8]
;;       str     x14, [x13, #0x30]
;;       ldur    x30, [x29, #8]
;;       xpaclri
;;       mov     x0, x30
;;       str     x0, [x13, #0x38]
;;       mov     x2, sp
;;       stur    w4, [sp]
;;       mov     x0, x1
;;       ldr     x4, [x0, #8]
;;       mov     x3, #1
;;       mov     x1, x19
;;       blr     x4
;;  81c: tst     w0, #0xff
;;       b.eq    #0x83c
;;  824: ldur    w2, [sp]
;;       add     sp, sp, #0x10
;;       ldr     x19, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;  83c: mov     x3, x19
;;  840: ldr     x0, [x3, #0x10]
;;  844: ldr     x1, [x0, #0x150]
;;  848: mov     x0, x3
;;  84c: blr     x1
;;  850: udf     #0xc11f
;;
;; signatures[1]::wasm_to_array_trampoline:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       str     x19, [sp, #-0x10]!
;;       mov     x19, x3
;;       mov     x12, x29
;;       ldr     x11, [x3, #8]
;;       str     x12, [x11, #0x30]
;;       ldur    x30, [x29, #8]
;;       xpaclri
;;       mov     x14, x30
;;       str     x14, [x11, #0x38]
;;       ldr     x15, [x2, #8]
;;       mov     x0, x2
;;       mov     x2, sp
;;       mov     x3, #0
;;       mov     x1, x19
;;       blr     x15
;;  8a0: tst     w0, #0xff
;;       b.eq    #0x8b8
;;  8a8: ldr     x19, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;  8b8: mov     x3, x19
;;  8bc: ldr     x0, [x3, #0x10]
;;  8c0: ldr     x1, [x0, #0x150]
;;  8c4: mov     x0, x3
;;  8c8: blr     x1
;;  8cc: udf     #0xc11f
;;
;; wasmtime_builtin_table_get_lazy_init_func_ref:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mov     x10, x29
;;       ldr     x9, [x2, #8]
;;       str     x10, [x9, #0x30]
;;       ldur    x30, [x29, #8]
;;       xpaclri
;;       mov     x12, x30
;;       str     x12, [x9, #0x38]
;;       ldr     x13, [x2, #0x10]
;;       ldr     x13, [x13, #0x38]
;;       mov     x1, x3
;;       mov     x0, x2
;;       mov     x2, x4
;;       blr     x13
;;  914: mov     x2, x0
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;
;; wasmtime_builtin_gc_alloc_raw:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x19, x20, [sp, #-0x10]!
;;       mov     x20, x2
;;       mov     x13, x29
;;       ldr     x12, [x2, #8]
;;       str     x13, [x12, #0x30]
;;       ldur    x30, [x29, #8]
;;       xpaclri
;;       mov     x15, x30
;;       str     x15, [x12, #0x38]
;;       ldr     x19, [x2, #0x10]
;;       ldr     x7, [x19, #0xc8]
;;       mov     x2, x4
;;       mov     x4, x6
;;       mov     x1, x3
;;       mov     x3, x5
;;       mov     x0, x20
;;       blr     x7
;;       cbz     w0, #0x990
;;  97c: mov     x2, x0
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;  990: ldr     x1, [x19, #0x150]
;;  994: mov     x0, x20
;;  998: blr     x1
;;  99c: udf     #0xc11f
;;
;; wasmtime_builtin_get_instance_id:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mov     x8, x29
;;       ldr     x7, [x2, #8]
;;       str     x8, [x7, #0x30]
;;       ldur    x30, [x29, #8]
;;       xpaclri
;;       mov     x10, x30
;;       str     x10, [x7, #0x38]
;;       ldr     x11, [x2, #0x10]
;;       ldr     x11, [x11, #0x160]
;;       mov     x0, x2
;;       blr     x11
;;  9dc: mov     x2, x0
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;
;; wasmtime_builtin_throw_ref:
;;       bti     c
;;       paciaz
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x19, x20, [sp, #-0x10]!
;;       mov     x20, x2
;;       mov     x10, x29
;;       ldr     x9, [x2, #8]
;;       str     x10, [x9, #0x30]
;;       ldur    x30, [x29, #8]
;;       xpaclri
;;       mov     x12, x30
;;       str     x12, [x9, #0x38]
;;       ldr     x19, [x2, #0x10]
;;       ldr     x13, [x19, #0x168]
;;       mov     x1, x3
;;       mov     x0, x20
;;       blr     x13
;;  a34: tst     w0, #0xff
;;       mov     x2, x0
;;       b.eq    #0xa50
;;  a40: ldp     x19, x20, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       autiaz
;;       ret
;;  a50: ldr     x15, [x19, #0x150]
;;  a54: mov     x0, x20
;;  a58: blr     x15
;;  a5c: udf     #0xc11f
