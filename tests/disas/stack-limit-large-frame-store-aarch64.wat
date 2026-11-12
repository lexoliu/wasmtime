;;! target = "aarch64"
;;! test = "compile"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=store", "-Wstack-limit-large-frame=64", "-Ccollector=null"]

;; As the processor-local test, with the limit read through the store context.
;; The prologue compares against `stack_limit`, the published word, and not
;; `real_stack_limit`, which `$large_leaf`'s ordinary trap check reads.
(module
  (memory 1)
  (func $callee (param i64) (result i64)
    (i64.add (local.get 0) (i64.const 1)))

  ;; A class A function (it calls wasm) whose frame is below the threshold.
  (func $small (param i64) (result i64)
    (call $callee (local.get 0)))

  ;; A class A function whose frame is above the threshold: sixteen values
  ;; are live across the call.
  (func $large_caller (param i64) (result i64)
    (local $a i64) (local $b i64) (local $c i64) (local $d i64)
    (local $e i64) (local $f i64) (local $g i64) (local $h i64)
    (local $i i64) (local $j i64) (local $k i64) (local $l i64)
    (local $m i64) (local $n i64) (local $o i64) (local $p i64)
    (local.set $a (i64.load offset=3 (i32.wrap_i64 (local.get 0))))
    (local.set $b (i64.load offset=5 (i32.wrap_i64 (local.get 0))))
    (local.set $c (i64.load offset=7 (i32.wrap_i64 (local.get 0))))
    (local.set $d (i64.load offset=11 (i32.wrap_i64 (local.get 0))))
    (local.set $e (i64.load offset=13 (i32.wrap_i64 (local.get 0))))
    (local.set $f (i64.load offset=17 (i32.wrap_i64 (local.get 0))))
    (local.set $g (i64.load offset=19 (i32.wrap_i64 (local.get 0))))
    (local.set $h (i64.load offset=23 (i32.wrap_i64 (local.get 0))))
    (local.set $i (i64.load offset=29 (i32.wrap_i64 (local.get 0))))
    (local.set $j (i64.load offset=31 (i32.wrap_i64 (local.get 0))))
    (local.set $k (i64.load offset=37 (i32.wrap_i64 (local.get 0))))
    (local.set $l (i64.load offset=41 (i32.wrap_i64 (local.get 0))))
    (local.set $m (i64.load offset=43 (i32.wrap_i64 (local.get 0))))
    (local.set $n (i64.load offset=47 (i32.wrap_i64 (local.get 0))))
    (local.set $o (i64.load offset=53 (i32.wrap_i64 (local.get 0))))
    (local.set $p (i64.load offset=59 (i32.wrap_i64 (local.get 0))))
    (drop (call $callee (local.get 0)))
    (i64.add (i64.add (i64.add (i64.add (local.get $a) (local.get $b))
                               (i64.add (local.get $c) (local.get $d)))
                      (i64.add (i64.add (local.get $e) (local.get $f))
                               (i64.add (local.get $g) (local.get $h))))
             (i64.add (i64.add (i64.add (local.get $i) (local.get $j))
                               (i64.add (local.get $k) (local.get $l)))
                      (i64.add (i64.add (local.get $m) (local.get $n))
                               (i64.add (local.get $o) (local.get $p))))))

  ;; A class B function (it calls no wasm) whose frame is above the
  ;; threshold: forty-eight loaded values are live until the sum at the end.
  (func $large_leaf (param i64) (result i64)
    (local $v0 i64)
    (local $v1 i64)
    (local $v2 i64)
    (local $v3 i64)
    (local $v4 i64)
    (local $v5 i64)
    (local $v6 i64)
    (local $v7 i64)
    (local $v8 i64)
    (local $v9 i64)
    (local $v10 i64)
    (local $v11 i64)
    (local $v12 i64)
    (local $v13 i64)
    (local $v14 i64)
    (local $v15 i64)
    (local $v16 i64)
    (local $v17 i64)
    (local $v18 i64)
    (local $v19 i64)
    (local $v20 i64)
    (local $v21 i64)
    (local $v22 i64)
    (local $v23 i64)
    (local $v24 i64)
    (local $v25 i64)
    (local $v26 i64)
    (local $v27 i64)
    (local $v28 i64)
    (local $v29 i64)
    (local $v30 i64)
    (local $v31 i64)
    (local $v32 i64)
    (local $v33 i64)
    (local $v34 i64)
    (local $v35 i64)
    (local $v36 i64)
    (local $v37 i64)
    (local $v38 i64)
    (local $v39 i64)
    (local $v40 i64)
    (local $v41 i64)
    (local $v42 i64)
    (local $v43 i64)
    (local $v44 i64)
    (local $v45 i64)
    (local $v46 i64)
    (local $v47 i64)
    (local.set $v0 (i64.load offset=8 (i32.wrap_i64 (local.get 0))))
    (local.set $v1 (i64.load offset=16 (i32.wrap_i64 (local.get 0))))
    (local.set $v2 (i64.load offset=24 (i32.wrap_i64 (local.get 0))))
    (local.set $v3 (i64.load offset=32 (i32.wrap_i64 (local.get 0))))
    (local.set $v4 (i64.load offset=40 (i32.wrap_i64 (local.get 0))))
    (local.set $v5 (i64.load offset=48 (i32.wrap_i64 (local.get 0))))
    (local.set $v6 (i64.load offset=56 (i32.wrap_i64 (local.get 0))))
    (local.set $v7 (i64.load offset=64 (i32.wrap_i64 (local.get 0))))
    (local.set $v8 (i64.load offset=72 (i32.wrap_i64 (local.get 0))))
    (local.set $v9 (i64.load offset=80 (i32.wrap_i64 (local.get 0))))
    (local.set $v10 (i64.load offset=88 (i32.wrap_i64 (local.get 0))))
    (local.set $v11 (i64.load offset=96 (i32.wrap_i64 (local.get 0))))
    (local.set $v12 (i64.load offset=104 (i32.wrap_i64 (local.get 0))))
    (local.set $v13 (i64.load offset=112 (i32.wrap_i64 (local.get 0))))
    (local.set $v14 (i64.load offset=120 (i32.wrap_i64 (local.get 0))))
    (local.set $v15 (i64.load offset=128 (i32.wrap_i64 (local.get 0))))
    (local.set $v16 (i64.load offset=136 (i32.wrap_i64 (local.get 0))))
    (local.set $v17 (i64.load offset=144 (i32.wrap_i64 (local.get 0))))
    (local.set $v18 (i64.load offset=152 (i32.wrap_i64 (local.get 0))))
    (local.set $v19 (i64.load offset=160 (i32.wrap_i64 (local.get 0))))
    (local.set $v20 (i64.load offset=168 (i32.wrap_i64 (local.get 0))))
    (local.set $v21 (i64.load offset=176 (i32.wrap_i64 (local.get 0))))
    (local.set $v22 (i64.load offset=184 (i32.wrap_i64 (local.get 0))))
    (local.set $v23 (i64.load offset=192 (i32.wrap_i64 (local.get 0))))
    (local.set $v24 (i64.load offset=200 (i32.wrap_i64 (local.get 0))))
    (local.set $v25 (i64.load offset=208 (i32.wrap_i64 (local.get 0))))
    (local.set $v26 (i64.load offset=216 (i32.wrap_i64 (local.get 0))))
    (local.set $v27 (i64.load offset=224 (i32.wrap_i64 (local.get 0))))
    (local.set $v28 (i64.load offset=232 (i32.wrap_i64 (local.get 0))))
    (local.set $v29 (i64.load offset=240 (i32.wrap_i64 (local.get 0))))
    (local.set $v30 (i64.load offset=248 (i32.wrap_i64 (local.get 0))))
    (local.set $v31 (i64.load offset=256 (i32.wrap_i64 (local.get 0))))
    (local.set $v32 (i64.load offset=264 (i32.wrap_i64 (local.get 0))))
    (local.set $v33 (i64.load offset=272 (i32.wrap_i64 (local.get 0))))
    (local.set $v34 (i64.load offset=280 (i32.wrap_i64 (local.get 0))))
    (local.set $v35 (i64.load offset=288 (i32.wrap_i64 (local.get 0))))
    (local.set $v36 (i64.load offset=296 (i32.wrap_i64 (local.get 0))))
    (local.set $v37 (i64.load offset=304 (i32.wrap_i64 (local.get 0))))
    (local.set $v38 (i64.load offset=312 (i32.wrap_i64 (local.get 0))))
    (local.set $v39 (i64.load offset=320 (i32.wrap_i64 (local.get 0))))
    (local.set $v40 (i64.load offset=328 (i32.wrap_i64 (local.get 0))))
    (local.set $v41 (i64.load offset=336 (i32.wrap_i64 (local.get 0))))
    (local.set $v42 (i64.load offset=344 (i32.wrap_i64 (local.get 0))))
    (local.set $v43 (i64.load offset=352 (i32.wrap_i64 (local.get 0))))
    (local.set $v44 (i64.load offset=360 (i32.wrap_i64 (local.get 0))))
    (local.set $v45 (i64.load offset=368 (i32.wrap_i64 (local.get 0))))
    (local.set $v46 (i64.load offset=376 (i32.wrap_i64 (local.get 0))))
    (local.set $v47 (i64.load offset=384 (i32.wrap_i64 (local.get 0))))
    (local.get $v0)
    (local.get $v1) (i64.add)
    (local.get $v2) (i64.add)
    (local.get $v3) (i64.add)
    (local.get $v4) (i64.add)
    (local.get $v5) (i64.add)
    (local.get $v6) (i64.add)
    (local.get $v7) (i64.add)
    (local.get $v8) (i64.add)
    (local.get $v9) (i64.add)
    (local.get $v10) (i64.add)
    (local.get $v11) (i64.add)
    (local.get $v12) (i64.add)
    (local.get $v13) (i64.add)
    (local.get $v14) (i64.add)
    (local.get $v15) (i64.add)
    (local.get $v16) (i64.add)
    (local.get $v17) (i64.add)
    (local.get $v18) (i64.add)
    (local.get $v19) (i64.add)
    (local.get $v20) (i64.add)
    (local.get $v21) (i64.add)
    (local.get $v22) (i64.add)
    (local.get $v23) (i64.add)
    (local.get $v24) (i64.add)
    (local.get $v25) (i64.add)
    (local.get $v26) (i64.add)
    (local.get $v27) (i64.add)
    (local.get $v28) (i64.add)
    (local.get $v29) (i64.add)
    (local.get $v30) (i64.add)
    (local.get $v31) (i64.add)
    (local.get $v32) (i64.add)
    (local.get $v33) (i64.add)
    (local.get $v34) (i64.add)
    (local.get $v35) (i64.add)
    (local.get $v36) (i64.add)
    (local.get $v37) (i64.add)
    (local.get $v38) (i64.add)
    (local.get $v39) (i64.add)
    (local.get $v40) (i64.add)
    (local.get $v41) (i64.add)
    (local.get $v42) (i64.add)
    (local.get $v43) (i64.add)
    (local.get $v44) (i64.add)
    (local.get $v45) (i64.add)
    (local.get $v46) (i64.add)
    (local.get $v47) (i64.add)
  ))
;; wasm[0]::function[0]::callee:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       add     x2, x4, #1
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;
;; wasm[0]::function[1]::small:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldr     x7, [x2, #8]
;;       ldr     x7, [x7, #0x18]
;;       mov     x8, sp
;;       cmp     x8, x7
;;       b.lo    #0x50
;;   3c: mov     x3, x2
;;       mov     x2, x3
;;       bl      #0
;;   48: ldp     x29, x30, [sp], #0x10
;;       ret
;;   50: mov     x1, sp
;;   54: mov     x0, x2
;;   58: bl      #0x53c
;;   5c: mov     x3, x0
;;   60: b       #0x40
;;
;; wasm[0]::function[2]::large_caller:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldur    x16, [x2, #8]
;;       ldur    x16, [x16, #0x18]
;;       subs    x17, sp, #0x90
;;       csel    x17, x17, xzr, hs
;;       cmp     x17, x16
;;       b.hs    #0xb0
;;   a0: mov     x0, x2
;;       mov     x1, x17
;;       bl      #0x53c
;;   ac: ldur    x30, [x29, #8]
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       sub     sp, sp, #0x30
;;       ldr     x0, [x2, #8]
;;       ldr     x0, [x0, #0x18]
;;       mov     x1, sp
;;       cmp     x1, x0
;;       b.lo    #0x1fc
;;   dc: mov     x0, x2
;;       ldr     x1, [x0, #0x38]
;;       add     x2, x1, #3
;;       ldr     x2, [x2, w4, uxtw]
;;       stur    x2, [sp, #0x28]
;;       add     x2, x1, #5
;;       ldr     x2, [x2, w4, uxtw]
;;       stur    x2, [sp, #0x20]
;;       add     x2, x1, #7
;;       ldr     x2, [x2, w4, uxtw]
;;       stur    x2, [sp, #0x18]
;;       add     x2, x1, #0xb
;;       ldr     x2, [x2, w4, uxtw]
;;       stur    x2, [sp, #0x10]
;;       add     x2, x1, #0xd
;;       ldr     x2, [x2, w4, uxtw]
;;       stur    x2, [sp, #8]
;;       add     x2, x1, #0x11
;;       ldr     x2, [x2, w4, uxtw]
;;       stur    x2, [sp]
;;       add     x2, x1, #0x13
;;       ldr     x25, [x2, w4, uxtw]
;;       add     x2, x1, #0x17
;;       ldr     x27, [x2, w4, uxtw]
;;       add     x2, x1, #0x1d
;;       ldr     x26, [x2, w4, uxtw]
;;       add     x2, x1, #0x1f
;;       ldr     x28, [x2, w4, uxtw]
;;       add     x2, x1, #0x25
;;       ldr     x19, [x2, w4, uxtw]
;;       add     x2, x1, #0x29
;;       ldr     x20, [x2, w4, uxtw]
;;       add     x2, x1, #0x2b
;;       ldr     x21, [x2, w4, uxtw]
;;       add     x2, x1, #0x2f
;;       ldr     x22, [x2, w4, uxtw]
;;       add     x2, x1, #0x35
;;       ldr     x23, [x2, w4, uxtw]
;;       add     x1, x1, #0x3b
;;       ldr     x24, [x1, w4, uxtw]
;;       mov     x3, x0
;;       mov     x2, x3
;;       bl      #0
;;  188: ldur    x0, [sp, #0x28]
;;       ldur    x2, [sp, #0x20]
;;       add     x0, x0, x2
;;       ldur    x1, [sp, #0x18]
;;       ldur    x2, [sp, #0x10]
;;       add     x1, x1, x2
;;       add     x0, x0, x1
;;       ldur    x1, [sp, #8]
;;       ldur    x2, [sp]
;;       add     x1, x1, x2
;;       add     x2, x25, x27
;;       add     x1, x1, x2
;;       add     x0, x0, x1
;;       add     x1, x26, x28
;;       add     x2, x19, x20
;;       add     x1, x1, x2
;;       add     x2, x21, x22
;;       add     x3, x23, x24
;;       add     x2, x2, x3
;;       add     x1, x1, x2
;;       add     x2, x0, x1
;;       add     sp, sp, #0x30
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;  1fc: mov     x1, sp
;;  200: mov     x0, x2
;;  204: bl      #0x53c
;;  208: b       #0xe0
;;
;; wasm[0]::function[3]::large_leaf:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldur    x16, [x2, #8]
;;       ldur    x16, [x16, #0x18]
;;       subs    x17, sp, #0x110
;;       csel    x17, x17, xzr, hs
;;       cmp     x17, x16
;;       b.hs    #0x250
;;  240: mov     x0, x2
;;       mov     x1, x17
;;       bl      #0x53c
;;  24c: ldur    x30, [x29, #8]
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       sub     sp, sp, #0xc0
;;       ldr     x0, [x2, #0x38]
;;       add     x1, x0, w4, uxtw
;;       ldr     x0, [x1, #8]
;;       stur    x0, [sp, #0xb0]
;;       ldr     x2, [x1, #0x10]
;;       ldr     x3, [x1, #0x18]
;;       ldr     x4, [x1, #0x20]
;;       ldr     x5, [x1, #0x28]
;;       ldr     x6, [x1, #0x30]
;;       ldr     x7, [x1, #0x38]
;;       ldr     x8, [x1, #0x40]
;;       ldr     x9, [x1, #0x48]
;;       ldr     x10, [x1, #0x50]
;;       ldr     x11, [x1, #0x58]
;;       ldr     x12, [x1, #0x60]
;;       ldr     x13, [x1, #0x68]
;;       ldr     x14, [x1, #0x70]
;;       ldr     x15, [x1, #0x78]
;;       ldr     x19, [x1, #0x80]
;;       ldr     x20, [x1, #0x88]
;;       ldr     x21, [x1, #0x90]
;;       ldr     x22, [x1, #0x98]
;;       ldr     x23, [x1, #0xa0]
;;       ldr     x24, [x1, #0xa8]
;;       ldr     x25, [x1, #0xb0]
;;       ldr     x26, [x1, #0xb8]
;;       ldr     x27, [x1, #0xc0]
;;       ldr     x28, [x1, #0xc8]
;;       ldr     x0, [x1, #0xd0]
;;       stur    x0, [sp, #0xa8]
;;       ldr     x0, [x1, #0xd8]
;;       stur    x0, [sp, #0xa0]
;;       ldr     x0, [x1, #0xe0]
;;       stur    x0, [sp, #0x98]
;;       ldr     x0, [x1, #0xe8]
;;       stur    x0, [sp, #0x90]
;;       ldr     x0, [x1, #0xf0]
;;       stur    x0, [sp, #0x88]
;;       ldr     x0, [x1, #0xf8]
;;       stur    x0, [sp, #0x80]
;;       ldr     x0, [x1, #0x100]
;;       stur    x0, [sp, #0x78]
;;       ldr     x0, [x1, #0x108]
;;       stur    x0, [sp, #0x70]
;;       ldr     x0, [x1, #0x110]
;;       stur    x0, [sp, #0x68]
;;       ldr     x0, [x1, #0x118]
;;       stur    x0, [sp, #0x60]
;;       ldr     x0, [x1, #0x120]
;;       stur    x0, [sp, #0x58]
;;       ldr     x0, [x1, #0x128]
;;       stur    x0, [sp, #0x50]
;;       ldr     x0, [x1, #0x130]
;;       stur    x0, [sp, #0x48]
;;       ldr     x0, [x1, #0x138]
;;       stur    x0, [sp, #0x40]
;;       ldr     x0, [x1, #0x140]
;;       stur    x0, [sp, #0x38]
;;       ldr     x0, [x1, #0x148]
;;       stur    x0, [sp, #0x30]
;;       ldr     x0, [x1, #0x150]
;;       stur    x0, [sp, #0x28]
;;       ldr     x0, [x1, #0x158]
;;       stur    x0, [sp, #0x20]
;;       ldr     x0, [x1, #0x160]
;;       stur    x0, [sp, #0x18]
;;       ldr     x0, [x1, #0x168]
;;       stur    x0, [sp, #0x10]
;;       ldr     x0, [x1, #0x170]
;;       stur    x0, [sp, #8]
;;       ldr     x0, [x1, #0x178]
;;       stur    x0, [sp]
;;       ldr     x1, [x1, #0x180]
;;       ldur    x0, [sp, #0xb0]
;;       add     x0, x0, x2
;;       add     x0, x0, x3
;;       add     x0, x0, x4
;;       add     x0, x0, x5
;;       add     x0, x0, x6
;;       add     x0, x0, x7
;;       add     x0, x0, x8
;;       add     x0, x0, x9
;;       add     x0, x0, x10
;;       add     x0, x0, x11
;;       add     x0, x0, x12
;;       add     x0, x0, x13
;;       add     x0, x0, x14
;;       add     x0, x0, x15
;;       add     x0, x0, x19
;;       add     x0, x0, x20
;;       add     x0, x0, x21
;;       add     x0, x0, x22
;;       add     x0, x0, x23
;;       add     x0, x0, x24
;;       add     x0, x0, x25
;;       add     x0, x0, x26
;;       add     x0, x0, x27
;;       add     x0, x0, x28
;;       ldur    x2, [sp, #0xa8]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0xa0]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x98]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x90]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x88]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x80]
;;       add     x0, x0, x2
;;       ldur    x4, [sp, #0x78]
;;       add     x0, x0, x4
;;       ldur    x7, [sp, #0x70]
;;       add     x0, x0, x7
;;       ldur    x10, [sp, #0x68]
;;       add     x0, x0, x10
;;       ldur    x13, [sp, #0x60]
;;       add     x0, x0, x13
;;       ldur    x2, [sp, #0x58]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x50]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x48]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x40]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x38]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x30]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x28]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x20]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x18]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #0x10]
;;       add     x0, x0, x2
;;       ldur    x2, [sp, #8]
;;       add     x0, x0, x2
;;       ldur    x2, [sp]
;;       add     x0, x0, x2
;;       add     x2, x0, x1
;;       add     sp, sp, #0xc0
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
