;;! target = "aarch64"
;;! test = "compile"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=processor:16", "-Wstack-limit-large-frame=64", "-Osignals-based-traps=n", "-Ccollector=null"]

;; The prologue check calls and never traps, so it does not depend on signals-based
;; traps being on.
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
;;       str     x19, [sp, #-0x10]!
;;       ldr     x7, [x2, #8]
;;       mov     x19, x2
;;       ldr     x7, [x7, #0x90]
;;       mov     x8, sp
;;       cmp     x8, x7
;;       b.lo    #0x34
;;   24: add     x2, x4, #1
;;       ldr     x19, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;   34: mov     w3, #0
;;   38: mov     x2, x19
;;   3c: bl      #0xf3c
;;   40: mov     x2, x19
;;   44: bl      #0xf74
;;   48: udf     #0xc11f
;;
;; wasm[0]::function[1]::small:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mrs     x6, tpidr_el1
;;       ldur    x6, [x6, #0x10]
;;       mov     x7, sp
;;       cmp     x7, x6
;;       b.lo    #0x90
;;   7c: mov     x3, x2
;;       mov     x2, x3
;;       bl      #0
;;   88: ldp     x29, x30, [sp], #0x10
;;       ret
;;   90: mov     x1, sp
;;   94: mov     x0, x2
;;   98: bl      #0xfa8
;;   9c: mov     x3, x0
;;   a0: b       #0x80
;;
;; wasm[0]::function[2]::large_caller:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mrs     x17, tpidr_el1
;;       ldur    x17, [x17, #0x10]
;;       subs    x16, sp, #0xa0
;;       csel    x16, x16, xzr, hs
;;       cmp     x16, x17
;;       b.hs    #0xf0
;;   e0: mov     x0, x2
;;       mov     x1, x16
;;       bl      #0xfa8
;;   ec: ldur    x30, [x29, #8]
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       sub     sp, sp, #0x40
;;       stur    x2, [sp]
;;       mrs     x0, tpidr_el1
;;       ldur    x0, [x0, #0x10]
;;       mov     x1, sp
;;       cmp     x1, x0
;;       b.lo    #0x348
;;  120: ldur    x0, [sp]
;;       ldr     x2, [x0, #0x40]
;;       mov     w1, w4
;;       sub     x2, x2, #0xb
;;       cmp     x1, x2
;;       b.hi    #0x4f8
;;  138: ldr     x2, [x0, #0x38]
;;       add     x3, x2, #3
;;       ldr     x3, [x3, w4, uxtw]
;;       stur    x3, [sp, #0x30]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0xd
;;       cmp     x1, x3
;;       b.hi    #0x4dc
;;  158: add     x3, x2, #5
;;       ldr     x3, [x3, w4, uxtw]
;;       stur    x3, [sp, #0x28]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0xf
;;       cmp     x1, x3
;;       b.hi    #0x4c0
;;  174: add     x3, x2, #7
;;       ldr     x3, [x3, w4, uxtw]
;;       stur    x3, [sp, #0x20]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x13
;;       cmp     x1, x3
;;       b.hi    #0x4a4
;;  190: add     x3, x2, #0xb
;;       ldr     x3, [x3, w4, uxtw]
;;       stur    x3, [sp, #0x18]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x15
;;       cmp     x1, x3
;;       b.hi    #0x488
;;  1ac: add     x3, x2, #0xd
;;       ldr     x3, [x3, w4, uxtw]
;;       stur    x3, [sp, #0x10]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x19
;;       cmp     x1, x3
;;       b.hi    #0x46c
;;  1c8: add     x3, x2, #0x11
;;       ldr     x3, [x3, w4, uxtw]
;;       stur    x3, [sp, #8]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x1b
;;       cmp     x1, x3
;;       b.hi    #0x450
;;  1e4: add     x3, x2, #0x13
;;       ldr     x25, [x3, w4, uxtw]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x1f
;;       cmp     x1, x3
;;       b.hi    #0x434
;;  1fc: add     x3, x2, #0x17
;;       ldr     x26, [x3, w4, uxtw]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x25
;;       cmp     x1, x3
;;       b.hi    #0x418
;;  214: add     x3, x2, #0x1d
;;       ldr     x27, [x3, w4, uxtw]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x27
;;       cmp     x1, x3
;;       b.hi    #0x3fc
;;  22c: add     x3, x2, #0x1f
;;       ldr     x28, [x3, w4, uxtw]
;;       ldr     x3, [x0, #0x40]
;;       sub     x3, x3, #0x2d
;;       cmp     x1, x3
;;       b.hi    #0x3e0
;;  244: add     x3, x2, #0x25
;;       ldr     x19, [x3, w4, uxtw]
;;       ldr     x5, [x0, #0x40]
;;       sub     x5, x5, #0x31
;;       cmp     x1, x5
;;       b.hi    #0x3c4
;;  25c: add     x5, x2, #0x29
;;       ldr     x20, [x5, w4, uxtw]
;;       ldr     x6, [x0, #0x40]
;;       sub     x6, x6, #0x33
;;       cmp     x1, x6
;;       b.hi    #0x3a8
;;  274: add     x7, x2, #0x2b
;;       ldr     x21, [x7, w4, uxtw]
;;       ldr     x8, [x0, #0x40]
;;       sub     x8, x8, #0x37
;;       cmp     x1, x8
;;       b.hi    #0x38c
;;  28c: add     x9, x2, #0x2f
;;       ldr     x22, [x9, w4, uxtw]
;;       ldr     x10, [x0, #0x40]
;;       sub     x10, x10, #0x3d
;;       cmp     x1, x10
;;       b.hi    #0x370
;;  2a4: add     x11, x2, #0x35
;;       ldr     x23, [x11, w4, uxtw]
;;       ldr     x12, [x0, #0x40]
;;       stur    x0, [sp]
;;       sub     x12, x12, #0x43
;;       cmp     x1, x12
;;       b.hi    #0x358
;;  2c0: add     x13, x2, #0x3b
;;       ldr     x24, [x13, w4, uxtw]
;;       ldur    x3, [sp]
;;       mov     x2, x3
;;       bl      #0
;;  2d4: ldur    x0, [sp, #0x30]
;;       ldur    x3, [sp, #0x28]
;;       add     x15, x0, x3
;;       ldur    x0, [sp, #0x20]
;;       ldur    x3, [sp, #0x18]
;;       add     x0, x0, x3
;;       add     x15, x15, x0
;;       ldur    x0, [sp, #0x10]
;;       ldur    x3, [sp, #8]
;;       add     x0, x0, x3
;;       add     x1, x25, x26
;;       add     x0, x0, x1
;;       add     x15, x15, x0
;;       add     x0, x27, x28
;;       add     x1, x19, x20
;;       add     x0, x0, x1
;;       add     x1, x21, x22
;;       add     x2, x23, x24
;;       add     x1, x1, x2
;;       add     x0, x0, x1
;;       add     x2, x15, x0
;;       add     sp, sp, #0x40
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;  348: mov     x1, sp
;;  34c: ldur    x0, [sp]
;;  350: bl      #0xfa8
;;  354: b       #0x124
;;  358: mov     w3, #1
;;  35c: ldur    x2, [sp]
;;  360: bl      #0xf3c
;;  364: ldur    x2, [sp]
;;  368: bl      #0xf74
;;  36c: udf     #0xc11f
;;  370: stur    x0, [sp]
;;  374: mov     w3, #1
;;  378: ldur    x2, [sp]
;;  37c: bl      #0xf3c
;;  380: ldur    x2, [sp]
;;  384: bl      #0xf74
;;  388: udf     #0xc11f
;;  38c: stur    x0, [sp]
;;  390: mov     w3, #1
;;  394: ldur    x2, [sp]
;;  398: bl      #0xf3c
;;  39c: ldur    x2, [sp]
;;  3a0: bl      #0xf74
;;  3a4: udf     #0xc11f
;;  3a8: stur    x0, [sp]
;;  3ac: mov     w3, #1
;;  3b0: ldur    x2, [sp]
;;  3b4: bl      #0xf3c
;;  3b8: ldur    x2, [sp]
;;  3bc: bl      #0xf74
;;  3c0: udf     #0xc11f
;;  3c4: stur    x0, [sp]
;;  3c8: mov     w3, #1
;;  3cc: ldur    x2, [sp]
;;  3d0: bl      #0xf3c
;;  3d4: ldur    x2, [sp]
;;  3d8: bl      #0xf74
;;  3dc: udf     #0xc11f
;;  3e0: stur    x0, [sp]
;;  3e4: mov     w3, #1
;;  3e8: ldur    x2, [sp]
;;  3ec: bl      #0xf3c
;;  3f0: ldur    x2, [sp]
;;  3f4: bl      #0xf74
;;  3f8: udf     #0xc11f
;;  3fc: stur    x0, [sp]
;;  400: mov     w3, #1
;;  404: ldur    x2, [sp]
;;  408: bl      #0xf3c
;;  40c: ldur    x2, [sp]
;;  410: bl      #0xf74
;;  414: udf     #0xc11f
;;  418: stur    x0, [sp]
;;  41c: mov     w3, #1
;;  420: ldur    x2, [sp]
;;  424: bl      #0xf3c
;;  428: ldur    x2, [sp]
;;  42c: bl      #0xf74
;;  430: udf     #0xc11f
;;  434: stur    x0, [sp]
;;  438: mov     w3, #1
;;  43c: ldur    x2, [sp]
;;  440: bl      #0xf3c
;;  444: ldur    x2, [sp]
;;  448: bl      #0xf74
;;  44c: udf     #0xc11f
;;  450: stur    x0, [sp]
;;  454: mov     w3, #1
;;  458: ldur    x2, [sp]
;;  45c: bl      #0xf3c
;;  460: ldur    x2, [sp]
;;  464: bl      #0xf74
;;  468: udf     #0xc11f
;;  46c: stur    x0, [sp]
;;  470: mov     w3, #1
;;  474: ldur    x2, [sp]
;;  478: bl      #0xf3c
;;  47c: ldur    x2, [sp]
;;  480: bl      #0xf74
;;  484: udf     #0xc11f
;;  488: stur    x0, [sp]
;;  48c: mov     w3, #1
;;  490: ldur    x2, [sp]
;;  494: bl      #0xf3c
;;  498: ldur    x2, [sp]
;;  49c: bl      #0xf74
;;  4a0: udf     #0xc11f
;;  4a4: stur    x0, [sp]
;;  4a8: mov     w3, #1
;;  4ac: ldur    x2, [sp]
;;  4b0: bl      #0xf3c
;;  4b4: ldur    x2, [sp]
;;  4b8: bl      #0xf74
;;  4bc: udf     #0xc11f
;;  4c0: stur    x0, [sp]
;;  4c4: mov     w3, #1
;;  4c8: ldur    x2, [sp]
;;  4cc: bl      #0xf3c
;;  4d0: ldur    x2, [sp]
;;  4d4: bl      #0xf74
;;  4d8: udf     #0xc11f
;;  4dc: stur    x0, [sp]
;;  4e0: mov     w3, #1
;;  4e4: ldur    x2, [sp]
;;  4e8: bl      #0xf3c
;;  4ec: ldur    x2, [sp]
;;  4f0: bl      #0xf74
;;  4f4: udf     #0xc11f
;;  4f8: stur    x0, [sp]
;;  4fc: mov     w3, #1
;;  500: ldur    x2, [sp]
;;  504: bl      #0xf3c
;;  508: ldur    x2, [sp]
;;  50c: bl      #0xf74
;;  510: udf     #0xc11f
;;
;; wasm[0]::function[3]::large_leaf:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mrs     x17, tpidr_el1
;;       ldur    x17, [x17, #0x10]
;;       subs    x16, sp, #0x130
;;       csel    x16, x16, xzr, hs
;;       cmp     x16, x17
;;       b.hs    #0x550
;;  540: mov     x0, x2
;;       mov     x1, x16
;;       bl      #0xfa8
;;  54c: ldur    x30, [x29, #8]
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       sub     sp, sp, #0xd0
;;       ldr     x12, [x2, #8]
;;       ldr     x12, [x12, #0x90]
;;       mov     x13, sp
;;       cmp     x13, x12
;;       b.lo    #0xeac
;;  57c: ldr     x14, [x2, #0x40]
;;       mov     w15, w4
;;       sub     x0, x14, #0x10
;;       cmp     x15, x0
;;       b.hi    #0xe94
;;  590: ldr     x0, [x2, #0x38]
;;       stur    x2, [sp]
;;       add     x1, x0, w4, uxtw
;;       ldr     x2, [x1, #8]
;;       stur    x2, [sp, #0xc0]
;;       sub     x0, x14, #0x18
;;       cmp     x15, x0
;;       b.hi    #0xe7c
;;  5b0: ldr     x3, [x1, #0x10]
;;       stur    x3, [sp, #0xb8]
;;       sub     x0, x14, #0x20
;;       cmp     x15, x0
;;       b.hi    #0xe64
;;  5c4: ldr     x4, [x1, #0x18]
;;       stur    x4, [sp, #0xb0]
;;       sub     x0, x14, #0x28
;;       cmp     x15, x0
;;       b.hi    #0xe4c
;;  5d8: ldr     x5, [x1, #0x20]
;;       stur    x5, [sp, #0xa8]
;;       sub     x0, x14, #0x30
;;       cmp     x15, x0
;;       b.hi    #0xe34
;;  5ec: ldr     x6, [x1, #0x28]
;;       stur    x6, [sp, #0xa0]
;;       sub     x0, x14, #0x38
;;       cmp     x15, x0
;;       b.hi    #0xe1c
;;  600: ldr     x7, [x1, #0x30]
;;       stur    x7, [sp, #0x98]
;;       sub     x0, x14, #0x40
;;       cmp     x15, x0
;;       b.hi    #0xe04
;;  614: ldr     x8, [x1, #0x38]
;;       stur    x8, [sp, #0x90]
;;       sub     x0, x14, #0x48
;;       cmp     x15, x0
;;       b.hi    #0xdec
;;  628: ldr     x9, [x1, #0x40]
;;       stur    x9, [sp, #0x88]
;;       sub     x0, x14, #0x50
;;       cmp     x15, x0
;;       b.hi    #0xdd4
;;  63c: ldr     x10, [x1, #0x48]
;;       stur    x10, [sp, #0x80]
;;       sub     x0, x14, #0x58
;;       cmp     x15, x0
;;       b.hi    #0xdbc
;;  650: ldr     x11, [x1, #0x50]
;;       stur    x11, [sp, #0x78]
;;       sub     x0, x14, #0x60
;;       cmp     x15, x0
;;       b.hi    #0xda4
;;  664: ldr     x12, [x1, #0x58]
;;       stur    x12, [sp, #0x70]
;;       sub     x0, x14, #0x68
;;       cmp     x15, x0
;;       b.hi    #0xd8c
;;  678: ldr     x13, [x1, #0x60]
;;       stur    x13, [sp, #0x68]
;;       sub     x0, x14, #0x70
;;       cmp     x15, x0
;;       b.hi    #0xd74
;;  68c: ldr     x19, [x1, #0x68]
;;       stur    x19, [sp, #0x60]
;;       sub     x0, x14, #0x78
;;       cmp     x15, x0
;;       b.hi    #0xd5c
;;  6a0: ldr     x20, [x1, #0x70]
;;       stur    x20, [sp, #0x58]
;;       sub     x0, x14, #0x80
;;       cmp     x15, x0
;;       b.hi    #0xd44
;;  6b4: ldr     x21, [x1, #0x78]
;;       stur    x21, [sp, #0x50]
;;       sub     x0, x14, #0x88
;;       cmp     x15, x0
;;       b.hi    #0xd2c
;;  6c8: ldr     x22, [x1, #0x80]
;;       stur    x22, [sp, #0x48]
;;       sub     x0, x14, #0x90
;;       cmp     x15, x0
;;       b.hi    #0xd14
;;  6dc: ldr     x23, [x1, #0x88]
;;       stur    x23, [sp, #0x40]
;;       sub     x0, x14, #0x98
;;       cmp     x15, x0
;;       b.hi    #0xcfc
;;  6f0: ldr     x24, [x1, #0x90]
;;       stur    x24, [sp, #0x38]
;;       sub     x0, x14, #0xa0
;;       cmp     x15, x0
;;       b.hi    #0xce4
;;  704: ldr     x25, [x1, #0x98]
;;       stur    x25, [sp, #0x30]
;;       sub     x0, x14, #0xa8
;;       cmp     x15, x0
;;       b.hi    #0xccc
;;  718: ldr     x26, [x1, #0xa0]
;;       stur    x26, [sp, #0x28]
;;       sub     x0, x14, #0xb0
;;       cmp     x15, x0
;;       b.hi    #0xcb4
;;  72c: ldr     x27, [x1, #0xa8]
;;       stur    x27, [sp, #0x20]
;;       sub     x0, x14, #0xb8
;;       cmp     x15, x0
;;       b.hi    #0xc9c
;;  740: ldr     x28, [x1, #0xb0]
;;       stur    x28, [sp, #0x18]
;;       sub     x0, x14, #0xc0
;;       cmp     x15, x0
;;       b.hi    #0xc84
;;  754: ldr     x0, [x1, #0xb8]
;;       stur    x0, [sp, #0x10]
;;       sub     x0, x14, #0xc8
;;       cmp     x15, x0
;;       b.hi    #0xc6c
;;  768: ldr     x2, [x1, #0xc0]
;;       stur    x2, [sp, #8]
;;       sub     x0, x14, #0xd0
;;       cmp     x15, x0
;;       b.hi    #0xc54
;;  77c: ldr     x2, [x1, #0xc8]
;;       sub     x3, x14, #0xd8
;;       cmp     x15, x3
;;       b.hi    #0xc3c
;;  78c: ldr     x3, [x1, #0xd0]
;;       sub     x4, x14, #0xe0
;;       cmp     x15, x4
;;       b.hi    #0xc24
;;  79c: ldr     x4, [x1, #0xd8]
;;       sub     x5, x14, #0xe8
;;       cmp     x15, x5
;;       b.hi    #0xc0c
;;  7ac: ldr     x5, [x1, #0xe0]
;;       sub     x7, x14, #0xf0
;;       cmp     x15, x7
;;       b.hi    #0xbf4
;;  7bc: ldr     x6, [x1, #0xe8]
;;       sub     x9, x14, #0xf8
;;       cmp     x15, x9
;;       b.hi    #0xbdc
;;  7cc: ldr     x7, [x1, #0xf0]
;;       sub     x11, x14, #0x100
;;       cmp     x15, x11
;;       b.hi    #0xbc4
;;  7dc: ldr     x8, [x1, #0xf8]
;;       sub     x13, x14, #0x108
;;       cmp     x15, x13
;;       b.hi    #0xbac
;;  7ec: ldr     x9, [x1, #0x100]
;;       sub     x0, x14, #0x110
;;       cmp     x15, x0
;;       b.hi    #0xb94
;;  7fc: ldr     x10, [x1, #0x108]
;;       sub     x0, x14, #0x118
;;       cmp     x15, x0
;;       b.hi    #0xb7c
;;  80c: ldr     x11, [x1, #0x110]
;;       sub     x0, x14, #0x120
;;       cmp     x15, x0
;;       b.hi    #0xb64
;;  81c: ldr     x12, [x1, #0x118]
;;       sub     x0, x14, #0x128
;;       cmp     x15, x0
;;       b.hi    #0xb4c
;;  82c: ldr     x13, [x1, #0x120]
;;       sub     x0, x14, #0x130
;;       cmp     x15, x0
;;       b.hi    #0xb34
;;  83c: ldr     x19, [x1, #0x128]
;;       sub     x0, x14, #0x138
;;       cmp     x15, x0
;;       b.hi    #0xb1c
;;  84c: ldr     x20, [x1, #0x130]
;;       sub     x0, x14, #0x140
;;       cmp     x15, x0
;;       b.hi    #0xb04
;;  85c: ldr     x21, [x1, #0x138]
;;       sub     x0, x14, #0x148
;;       cmp     x15, x0
;;       b.hi    #0xaec
;;  86c: ldr     x22, [x1, #0x140]
;;       sub     x0, x14, #0x150
;;       cmp     x15, x0
;;       b.hi    #0xad4
;;  87c: ldr     x23, [x1, #0x148]
;;       sub     x0, x14, #0x158
;;       cmp     x15, x0
;;       b.hi    #0xabc
;;  88c: ldr     x24, [x1, #0x150]
;;       sub     x0, x14, #0x160
;;       cmp     x15, x0
;;       b.hi    #0xaa4
;;  89c: ldr     x25, [x1, #0x158]
;;       sub     x0, x14, #0x168
;;       cmp     x15, x0
;;       b.hi    #0xa8c
;;  8ac: ldr     x26, [x1, #0x160]
;;       sub     x0, x14, #0x170
;;       cmp     x15, x0
;;       b.hi    #0xa74
;;  8bc: ldr     x27, [x1, #0x168]
;;       sub     x0, x14, #0x178
;;       cmp     x15, x0
;;       b.hi    #0xa5c
;;  8cc: ldr     x28, [x1, #0x170]
;;       sub     x0, x14, #0x180
;;       cmp     x15, x0
;;       b.hi    #0xa44
;;  8dc: ldr     x0, [x1, #0x178]
;;       sub     x14, x14, #0x188
;;       cmp     x15, x14
;;       b.hi    #0xa2c
;;  8ec: ldr     x1, [x1, #0x180]
;;       ldur    x14, [sp, #0xb8]
;;       ldur    x15, [sp, #0xc0]
;;       add     x14, x15, x14
;;       ldur    x15, [sp, #0xb0]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0xa8]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0xa0]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x98]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x90]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x88]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x80]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x78]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x70]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x68]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x60]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x58]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x50]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x48]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x40]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x38]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x30]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x28]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x20]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x18]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #0x10]
;;       add     x14, x14, x15
;;       ldur    x15, [sp, #8]
;;       add     x14, x14, x15
;;       add     x2, x14, x2
;;       add     x2, x2, x3
;;       add     x2, x2, x4
;;       add     x2, x2, x5
;;       add     x2, x2, x6
;;       add     x2, x2, x7
;;       add     x2, x2, x8
;;       add     x2, x2, x9
;;       add     x2, x2, x10
;;       add     x2, x2, x11
;;       add     x2, x2, x12
;;       add     x2, x2, x13
;;       add     x2, x2, x19
;;       add     x2, x2, x20
;;       add     x2, x2, x21
;;       add     x2, x2, x22
;;       add     x2, x2, x23
;;       add     x2, x2, x24
;;       add     x2, x2, x25
;;       add     x2, x2, x26
;;       add     x2, x2, x27
;;       add     x2, x2, x28
;;       add     x0, x2, x0
;;       add     x2, x0, x1
;;       add     sp, sp, #0xd0
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;  a2c: mov     w3, #1
;;  a30: ldur    x2, [sp]
;;  a34: bl      #0xf3c
;;  a38: ldur    x2, [sp]
;;  a3c: bl      #0xf74
;;  a40: udf     #0xc11f
;;  a44: mov     w3, #1
;;  a48: ldur    x2, [sp]
;;  a4c: bl      #0xf3c
;;  a50: ldur    x2, [sp]
;;  a54: bl      #0xf74
;;  a58: udf     #0xc11f
;;  a5c: mov     w3, #1
;;  a60: ldur    x2, [sp]
;;  a64: bl      #0xf3c
;;  a68: ldur    x2, [sp]
;;  a6c: bl      #0xf74
;;  a70: udf     #0xc11f
;;  a74: mov     w3, #1
;;  a78: ldur    x2, [sp]
;;  a7c: bl      #0xf3c
;;  a80: ldur    x2, [sp]
;;  a84: bl      #0xf74
;;  a88: udf     #0xc11f
;;  a8c: mov     w3, #1
;;  a90: ldur    x2, [sp]
;;  a94: bl      #0xf3c
;;  a98: ldur    x2, [sp]
;;  a9c: bl      #0xf74
;;  aa0: udf     #0xc11f
;;  aa4: mov     w3, #1
;;  aa8: ldur    x2, [sp]
;;  aac: bl      #0xf3c
;;  ab0: ldur    x2, [sp]
;;  ab4: bl      #0xf74
;;  ab8: udf     #0xc11f
;;  abc: mov     w3, #1
;;  ac0: ldur    x2, [sp]
;;  ac4: bl      #0xf3c
;;  ac8: ldur    x2, [sp]
;;  acc: bl      #0xf74
;;  ad0: udf     #0xc11f
;;  ad4: mov     w3, #1
;;  ad8: ldur    x2, [sp]
;;  adc: bl      #0xf3c
;;  ae0: ldur    x2, [sp]
;;  ae4: bl      #0xf74
;;  ae8: udf     #0xc11f
;;  aec: mov     w3, #1
;;  af0: ldur    x2, [sp]
;;  af4: bl      #0xf3c
;;  af8: ldur    x2, [sp]
;;  afc: bl      #0xf74
;;  b00: udf     #0xc11f
;;  b04: mov     w3, #1
;;  b08: ldur    x2, [sp]
;;  b0c: bl      #0xf3c
;;  b10: ldur    x2, [sp]
;;  b14: bl      #0xf74
;;  b18: udf     #0xc11f
;;  b1c: mov     w3, #1
;;  b20: ldur    x2, [sp]
;;  b24: bl      #0xf3c
;;  b28: ldur    x2, [sp]
;;  b2c: bl      #0xf74
;;  b30: udf     #0xc11f
;;  b34: mov     w3, #1
;;  b38: ldur    x2, [sp]
;;  b3c: bl      #0xf3c
;;  b40: ldur    x2, [sp]
;;  b44: bl      #0xf74
;;  b48: udf     #0xc11f
;;  b4c: mov     w3, #1
;;  b50: ldur    x2, [sp]
;;  b54: bl      #0xf3c
;;  b58: ldur    x2, [sp]
;;  b5c: bl      #0xf74
;;  b60: udf     #0xc11f
;;  b64: mov     w3, #1
;;  b68: ldur    x2, [sp]
;;  b6c: bl      #0xf3c
;;  b70: ldur    x2, [sp]
;;  b74: bl      #0xf74
;;  b78: udf     #0xc11f
;;  b7c: mov     w3, #1
;;  b80: ldur    x2, [sp]
;;  b84: bl      #0xf3c
;;  b88: ldur    x2, [sp]
;;  b8c: bl      #0xf74
;;  b90: udf     #0xc11f
;;  b94: mov     w3, #1
;;  b98: ldur    x2, [sp]
;;  b9c: bl      #0xf3c
;;  ba0: ldur    x2, [sp]
;;  ba4: bl      #0xf74
;;  ba8: udf     #0xc11f
;;  bac: mov     w3, #1
;;  bb0: ldur    x2, [sp]
;;  bb4: bl      #0xf3c
;;  bb8: ldur    x2, [sp]
;;  bbc: bl      #0xf74
;;  bc0: udf     #0xc11f
;;  bc4: mov     w3, #1
;;  bc8: ldur    x2, [sp]
;;  bcc: bl      #0xf3c
;;  bd0: ldur    x2, [sp]
;;  bd4: bl      #0xf74
;;  bd8: udf     #0xc11f
;;  bdc: mov     w3, #1
;;  be0: ldur    x2, [sp]
;;  be4: bl      #0xf3c
;;  be8: ldur    x2, [sp]
;;  bec: bl      #0xf74
;;  bf0: udf     #0xc11f
;;  bf4: mov     w3, #1
;;  bf8: ldur    x2, [sp]
;;  bfc: bl      #0xf3c
;;  c00: ldur    x2, [sp]
;;  c04: bl      #0xf74
;;  c08: udf     #0xc11f
;;  c0c: mov     w3, #1
;;  c10: ldur    x2, [sp]
;;  c14: bl      #0xf3c
;;  c18: ldur    x2, [sp]
;;  c1c: bl      #0xf74
;;  c20: udf     #0xc11f
;;  c24: mov     w3, #1
;;  c28: ldur    x2, [sp]
;;  c2c: bl      #0xf3c
;;  c30: ldur    x2, [sp]
;;  c34: bl      #0xf74
;;  c38: udf     #0xc11f
;;  c3c: mov     w3, #1
;;  c40: ldur    x2, [sp]
;;  c44: bl      #0xf3c
;;  c48: ldur    x2, [sp]
;;  c4c: bl      #0xf74
;;  c50: udf     #0xc11f
;;  c54: mov     w3, #1
;;  c58: ldur    x2, [sp]
;;  c5c: bl      #0xf3c
;;  c60: ldur    x2, [sp]
;;  c64: bl      #0xf74
;;  c68: udf     #0xc11f
;;  c6c: mov     w3, #1
;;  c70: ldur    x2, [sp]
;;  c74: bl      #0xf3c
;;  c78: ldur    x2, [sp]
;;  c7c: bl      #0xf74
;;  c80: udf     #0xc11f
;;  c84: mov     w3, #1
;;  c88: ldur    x2, [sp]
;;  c8c: bl      #0xf3c
;;  c90: ldur    x2, [sp]
;;  c94: bl      #0xf74
;;  c98: udf     #0xc11f
;;  c9c: mov     w3, #1
;;  ca0: ldur    x2, [sp]
;;  ca4: bl      #0xf3c
;;  ca8: ldur    x2, [sp]
;;  cac: bl      #0xf74
;;  cb0: udf     #0xc11f
;;  cb4: mov     w3, #1
;;  cb8: ldur    x2, [sp]
;;  cbc: bl      #0xf3c
;;  cc0: ldur    x2, [sp]
;;  cc4: bl      #0xf74
;;  cc8: udf     #0xc11f
;;  ccc: mov     w3, #1
;;  cd0: ldur    x2, [sp]
;;  cd4: bl      #0xf3c
;;  cd8: ldur    x2, [sp]
;;  cdc: bl      #0xf74
;;  ce0: udf     #0xc11f
;;  ce4: mov     w3, #1
;;  ce8: ldur    x2, [sp]
;;  cec: bl      #0xf3c
;;  cf0: ldur    x2, [sp]
;;  cf4: bl      #0xf74
;;  cf8: udf     #0xc11f
;;  cfc: mov     w3, #1
;;  d00: ldur    x2, [sp]
;;  d04: bl      #0xf3c
;;  d08: ldur    x2, [sp]
;;  d0c: bl      #0xf74
;;  d10: udf     #0xc11f
;;  d14: mov     w3, #1
;;  d18: ldur    x2, [sp]
;;  d1c: bl      #0xf3c
;;  d20: ldur    x2, [sp]
;;  d24: bl      #0xf74
;;  d28: udf     #0xc11f
;;  d2c: mov     w3, #1
;;  d30: ldur    x2, [sp]
;;  d34: bl      #0xf3c
;;  d38: ldur    x2, [sp]
;;  d3c: bl      #0xf74
;;  d40: udf     #0xc11f
;;  d44: mov     w3, #1
;;  d48: ldur    x2, [sp]
;;  d4c: bl      #0xf3c
;;  d50: ldur    x2, [sp]
;;  d54: bl      #0xf74
;;  d58: udf     #0xc11f
;;  d5c: mov     w3, #1
;;  d60: ldur    x2, [sp]
;;  d64: bl      #0xf3c
;;  d68: ldur    x2, [sp]
;;  d6c: bl      #0xf74
;;  d70: udf     #0xc11f
;;  d74: mov     w3, #1
;;  d78: ldur    x2, [sp]
;;  d7c: bl      #0xf3c
;;  d80: ldur    x2, [sp]
;;  d84: bl      #0xf74
;;  d88: udf     #0xc11f
;;  d8c: mov     w3, #1
;;  d90: ldur    x2, [sp]
;;  d94: bl      #0xf3c
;;  d98: ldur    x2, [sp]
;;  d9c: bl      #0xf74
;;  da0: udf     #0xc11f
;;  da4: mov     w3, #1
;;  da8: ldur    x2, [sp]
;;  dac: bl      #0xf3c
;;  db0: ldur    x2, [sp]
;;  db4: bl      #0xf74
;;  db8: udf     #0xc11f
;;  dbc: mov     w3, #1
;;  dc0: ldur    x2, [sp]
;;  dc4: bl      #0xf3c
;;  dc8: ldur    x2, [sp]
;;  dcc: bl      #0xf74
;;  dd0: udf     #0xc11f
;;  dd4: mov     w3, #1
;;  dd8: ldur    x2, [sp]
;;  ddc: bl      #0xf3c
;;  de0: ldur    x2, [sp]
;;  de4: bl      #0xf74
;;  de8: udf     #0xc11f
;;  dec: mov     w3, #1
;;  df0: ldur    x2, [sp]
;;  df4: bl      #0xf3c
;;  df8: ldur    x2, [sp]
;;  dfc: bl      #0xf74
;;  e00: udf     #0xc11f
;;  e04: mov     w3, #1
;;  e08: ldur    x2, [sp]
;;  e0c: bl      #0xf3c
;;  e10: ldur    x2, [sp]
;;  e14: bl      #0xf74
;;  e18: udf     #0xc11f
;;  e1c: mov     w3, #1
;;  e20: ldur    x2, [sp]
;;  e24: bl      #0xf3c
;;  e28: ldur    x2, [sp]
;;  e2c: bl      #0xf74
;;  e30: udf     #0xc11f
;;  e34: mov     w3, #1
;;  e38: ldur    x2, [sp]
;;  e3c: bl      #0xf3c
;;  e40: ldur    x2, [sp]
;;  e44: bl      #0xf74
;;  e48: udf     #0xc11f
;;  e4c: mov     w3, #1
;;  e50: ldur    x2, [sp]
;;  e54: bl      #0xf3c
;;  e58: ldur    x2, [sp]
;;  e5c: bl      #0xf74
;;  e60: udf     #0xc11f
;;  e64: mov     w3, #1
;;  e68: ldur    x2, [sp]
;;  e6c: bl      #0xf3c
;;  e70: ldur    x2, [sp]
;;  e74: bl      #0xf74
;;  e78: udf     #0xc11f
;;  e7c: mov     w3, #1
;;  e80: ldur    x2, [sp]
;;  e84: bl      #0xf3c
;;  e88: ldur    x2, [sp]
;;  e8c: bl      #0xf74
;;  e90: udf     #0xc11f
;;  e94: stur    x2, [sp]
;;  e98: mov     w3, #1
;;  e9c: bl      #0xf3c
;;  ea0: ldur    x2, [sp]
;;  ea4: bl      #0xf74
;;  ea8: udf     #0xc11f
;;  eac: stur    x2, [sp]
;;  eb0: mov     w3, #0
;;  eb4: bl      #0xf3c
;;  eb8: ldur    x2, [sp]
;;  ebc: bl      #0xf74
;;  ec0: udf     #0xc11f
