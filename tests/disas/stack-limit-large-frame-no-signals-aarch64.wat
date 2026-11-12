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
;;       ldr     x7, [x7, #0xa0]
;;       mov     x8, sp
;;       cmp     x8, x7
;;       b.lo    #0x34
;;   24: add     x2, x4, #1
;;       ldr     x19, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;   34: mov     w3, #0
;;   38: mov     x2, x19
;;   3c: bl      #0xebc
;;   40: mov     x2, x19
;;   44: bl      #0xef4
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
;;   98: bl      #0xf28
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
;;       bl      #0xf28
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
;;       b.lo    #0x30c
;;  120: ldur    x0, [sp]
;;       ldr     x3, [x0, #0x40]
;;       mov     w1, w4
;;       sub     x2, x3, #0xb
;;       cmp     x1, x2
;;       b.hi    #0x484
;;  138: ldr     x2, [x0, #0x38]
;;       stur    x0, [sp]
;;       add     x0, x2, #3
;;       ldr     x0, [x0, w4, uxtw]
;;       stur    x0, [sp, #0x30]
;;       sub     x0, x3, #0xd
;;       cmp     x1, x0
;;       b.hi    #0x46c
;;  158: add     x0, x2, #5
;;       ldr     x0, [x0, w4, uxtw]
;;       stur    x0, [sp, #0x28]
;;       sub     x0, x3, #0xf
;;       cmp     x1, x0
;;       b.hi    #0x454
;;  170: add     x0, x2, #7
;;       ldr     x0, [x0, w4, uxtw]
;;       stur    x0, [sp, #0x20]
;;       sub     x0, x3, #0x13
;;       cmp     x1, x0
;;       b.hi    #0x43c
;;  188: add     x0, x2, #0xb
;;       ldr     x0, [x0, w4, uxtw]
;;       stur    x0, [sp, #0x18]
;;       sub     x0, x3, #0x15
;;       cmp     x1, x0
;;       b.hi    #0x424
;;  1a0: add     x0, x2, #0xd
;;       ldr     x0, [x0, w4, uxtw]
;;       stur    x0, [sp, #0x10]
;;       sub     x0, x3, #0x19
;;       cmp     x1, x0
;;       b.hi    #0x40c
;;  1b8: add     x0, x2, #0x11
;;       ldr     x0, [x0, w4, uxtw]
;;       stur    x0, [sp, #8]
;;       sub     x0, x3, #0x1b
;;       cmp     x1, x0
;;       b.hi    #0x3f4
;;  1d0: add     x0, x2, #0x13
;;       ldr     x25, [x0, w4, uxtw]
;;       sub     x0, x3, #0x1f
;;       cmp     x1, x0
;;       b.hi    #0x3dc
;;  1e4: add     x0, x2, #0x17
;;       ldr     x26, [x0, w4, uxtw]
;;       sub     x0, x3, #0x25
;;       cmp     x1, x0
;;       b.hi    #0x3c4
;;  1f8: add     x0, x2, #0x1d
;;       ldr     x27, [x0, w4, uxtw]
;;       sub     x0, x3, #0x27
;;       cmp     x1, x0
;;       b.hi    #0x3ac
;;  20c: add     x0, x2, #0x1f
;;       ldr     x28, [x0, w4, uxtw]
;;       sub     x0, x3, #0x2d
;;       cmp     x1, x0
;;       b.hi    #0x394
;;  220: add     x0, x2, #0x25
;;       ldr     x19, [x0, w4, uxtw]
;;       sub     x0, x3, #0x31
;;       cmp     x1, x0
;;       b.hi    #0x37c
;;  234: add     x0, x2, #0x29
;;       ldr     x20, [x0, w4, uxtw]
;;       sub     x0, x3, #0x33
;;       cmp     x1, x0
;;       b.hi    #0x364
;;  248: add     x0, x2, #0x2b
;;       ldr     x21, [x0, w4, uxtw]
;;       sub     x0, x3, #0x37
;;       cmp     x1, x0
;;       b.hi    #0x34c
;;  25c: add     x0, x2, #0x2f
;;       ldr     x22, [x0, w4, uxtw]
;;       sub     x0, x3, #0x3d
;;       cmp     x1, x0
;;       b.hi    #0x334
;;  270: add     x0, x2, #0x35
;;       ldr     x23, [x0, w4, uxtw]
;;       sub     x0, x3, #0x43
;;       cmp     x1, x0
;;       b.hi    #0x31c
;;  284: add     x0, x2, #0x3b
;;       ldr     x24, [x0, w4, uxtw]
;;       ldur    x3, [sp]
;;       mov     x2, x3
;;       bl      #0
;;  298: ldur    x0, [sp, #0x30]
;;       ldur    x3, [sp, #0x28]
;;       add     x0, x0, x3
;;       ldur    x1, [sp, #0x20]
;;       ldur    x3, [sp, #0x18]
;;       add     x1, x1, x3
;;       add     x0, x0, x1
;;       ldur    x1, [sp, #0x10]
;;       ldur    x3, [sp, #8]
;;       add     x1, x1, x3
;;       add     x2, x25, x26
;;       add     x1, x1, x2
;;       add     x0, x0, x1
;;       add     x1, x27, x28
;;       add     x2, x19, x20
;;       add     x1, x1, x2
;;       add     x2, x21, x22
;;       add     x3, x23, x24
;;       add     x2, x2, x3
;;       add     x1, x1, x2
;;       add     x2, x0, x1
;;       add     sp, sp, #0x40
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;  30c: mov     x1, sp
;;  310: ldur    x0, [sp]
;;  314: bl      #0xf28
;;  318: b       #0x124
;;  31c: mov     w3, #1
;;  320: ldur    x2, [sp]
;;  324: bl      #0xebc
;;  328: ldur    x2, [sp]
;;  32c: bl      #0xef4
;;  330: udf     #0xc11f
;;  334: mov     w3, #1
;;  338: ldur    x2, [sp]
;;  33c: bl      #0xebc
;;  340: ldur    x2, [sp]
;;  344: bl      #0xef4
;;  348: udf     #0xc11f
;;  34c: mov     w3, #1
;;  350: ldur    x2, [sp]
;;  354: bl      #0xebc
;;  358: ldur    x2, [sp]
;;  35c: bl      #0xef4
;;  360: udf     #0xc11f
;;  364: mov     w3, #1
;;  368: ldur    x2, [sp]
;;  36c: bl      #0xebc
;;  370: ldur    x2, [sp]
;;  374: bl      #0xef4
;;  378: udf     #0xc11f
;;  37c: mov     w3, #1
;;  380: ldur    x2, [sp]
;;  384: bl      #0xebc
;;  388: ldur    x2, [sp]
;;  38c: bl      #0xef4
;;  390: udf     #0xc11f
;;  394: mov     w3, #1
;;  398: ldur    x2, [sp]
;;  39c: bl      #0xebc
;;  3a0: ldur    x2, [sp]
;;  3a4: bl      #0xef4
;;  3a8: udf     #0xc11f
;;  3ac: mov     w3, #1
;;  3b0: ldur    x2, [sp]
;;  3b4: bl      #0xebc
;;  3b8: ldur    x2, [sp]
;;  3bc: bl      #0xef4
;;  3c0: udf     #0xc11f
;;  3c4: mov     w3, #1
;;  3c8: ldur    x2, [sp]
;;  3cc: bl      #0xebc
;;  3d0: ldur    x2, [sp]
;;  3d4: bl      #0xef4
;;  3d8: udf     #0xc11f
;;  3dc: mov     w3, #1
;;  3e0: ldur    x2, [sp]
;;  3e4: bl      #0xebc
;;  3e8: ldur    x2, [sp]
;;  3ec: bl      #0xef4
;;  3f0: udf     #0xc11f
;;  3f4: mov     w3, #1
;;  3f8: ldur    x2, [sp]
;;  3fc: bl      #0xebc
;;  400: ldur    x2, [sp]
;;  404: bl      #0xef4
;;  408: udf     #0xc11f
;;  40c: mov     w3, #1
;;  410: ldur    x2, [sp]
;;  414: bl      #0xebc
;;  418: ldur    x2, [sp]
;;  41c: bl      #0xef4
;;  420: udf     #0xc11f
;;  424: mov     w3, #1
;;  428: ldur    x2, [sp]
;;  42c: bl      #0xebc
;;  430: ldur    x2, [sp]
;;  434: bl      #0xef4
;;  438: udf     #0xc11f
;;  43c: mov     w3, #1
;;  440: ldur    x2, [sp]
;;  444: bl      #0xebc
;;  448: ldur    x2, [sp]
;;  44c: bl      #0xef4
;;  450: udf     #0xc11f
;;  454: mov     w3, #1
;;  458: ldur    x2, [sp]
;;  45c: bl      #0xebc
;;  460: ldur    x2, [sp]
;;  464: bl      #0xef4
;;  468: udf     #0xc11f
;;  46c: mov     w3, #1
;;  470: ldur    x2, [sp]
;;  474: bl      #0xebc
;;  478: ldur    x2, [sp]
;;  47c: bl      #0xef4
;;  480: udf     #0xc11f
;;  484: stur    x0, [sp]
;;  488: mov     w3, #1
;;  48c: ldur    x2, [sp]
;;  490: bl      #0xebc
;;  494: ldur    x2, [sp]
;;  498: bl      #0xef4
;;  49c: udf     #0xc11f
;;
;; wasm[0]::function[3]::large_leaf:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mrs     x17, tpidr_el1
;;       ldur    x17, [x17, #0x10]
;;       subs    x16, sp, #0x130
;;       csel    x16, x16, xzr, hs
;;       cmp     x16, x17
;;       b.hs    #0x4d0
;;  4c0: mov     x0, x2
;;       mov     x1, x16
;;       bl      #0xf28
;;  4cc: ldur    x30, [x29, #8]
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       sub     sp, sp, #0xd0
;;       ldr     x12, [x2, #8]
;;       ldr     x12, [x12, #0xa0]
;;       mov     x13, sp
;;       cmp     x13, x12
;;       b.lo    #0xe2c
;;  4fc: ldr     x14, [x2, #0x40]
;;       mov     w15, w4
;;       sub     x0, x14, #0x10
;;       cmp     x15, x0
;;       b.hi    #0xe14
;;  510: ldr     x0, [x2, #0x38]
;;       stur    x2, [sp]
;;       add     x1, x0, w4, uxtw
;;       ldr     x2, [x1, #8]
;;       stur    x2, [sp, #0xc0]
;;       sub     x0, x14, #0x18
;;       cmp     x15, x0
;;       b.hi    #0xdfc
;;  530: ldr     x3, [x1, #0x10]
;;       stur    x3, [sp, #0xb8]
;;       sub     x0, x14, #0x20
;;       cmp     x15, x0
;;       b.hi    #0xde4
;;  544: ldr     x4, [x1, #0x18]
;;       stur    x4, [sp, #0xb0]
;;       sub     x0, x14, #0x28
;;       cmp     x15, x0
;;       b.hi    #0xdcc
;;  558: ldr     x5, [x1, #0x20]
;;       stur    x5, [sp, #0xa8]
;;       sub     x0, x14, #0x30
;;       cmp     x15, x0
;;       b.hi    #0xdb4
;;  56c: ldr     x6, [x1, #0x28]
;;       stur    x6, [sp, #0xa0]
;;       sub     x0, x14, #0x38
;;       cmp     x15, x0
;;       b.hi    #0xd9c
;;  580: ldr     x7, [x1, #0x30]
;;       stur    x7, [sp, #0x98]
;;       sub     x0, x14, #0x40
;;       cmp     x15, x0
;;       b.hi    #0xd84
;;  594: ldr     x8, [x1, #0x38]
;;       stur    x8, [sp, #0x90]
;;       sub     x0, x14, #0x48
;;       cmp     x15, x0
;;       b.hi    #0xd6c
;;  5a8: ldr     x9, [x1, #0x40]
;;       stur    x9, [sp, #0x88]
;;       sub     x0, x14, #0x50
;;       cmp     x15, x0
;;       b.hi    #0xd54
;;  5bc: ldr     x10, [x1, #0x48]
;;       stur    x10, [sp, #0x80]
;;       sub     x0, x14, #0x58
;;       cmp     x15, x0
;;       b.hi    #0xd3c
;;  5d0: ldr     x11, [x1, #0x50]
;;       stur    x11, [sp, #0x78]
;;       sub     x0, x14, #0x60
;;       cmp     x15, x0
;;       b.hi    #0xd24
;;  5e4: ldr     x12, [x1, #0x58]
;;       stur    x12, [sp, #0x70]
;;       sub     x0, x14, #0x68
;;       cmp     x15, x0
;;       b.hi    #0xd0c
;;  5f8: ldr     x13, [x1, #0x60]
;;       stur    x13, [sp, #0x68]
;;       sub     x0, x14, #0x70
;;       cmp     x15, x0
;;       b.hi    #0xcf4
;;  60c: ldr     x19, [x1, #0x68]
;;       stur    x19, [sp, #0x60]
;;       sub     x0, x14, #0x78
;;       cmp     x15, x0
;;       b.hi    #0xcdc
;;  620: ldr     x20, [x1, #0x70]
;;       stur    x20, [sp, #0x58]
;;       sub     x0, x14, #0x80
;;       cmp     x15, x0
;;       b.hi    #0xcc4
;;  634: ldr     x21, [x1, #0x78]
;;       stur    x21, [sp, #0x50]
;;       sub     x0, x14, #0x88
;;       cmp     x15, x0
;;       b.hi    #0xcac
;;  648: ldr     x22, [x1, #0x80]
;;       stur    x22, [sp, #0x48]
;;       sub     x0, x14, #0x90
;;       cmp     x15, x0
;;       b.hi    #0xc94
;;  65c: ldr     x23, [x1, #0x88]
;;       stur    x23, [sp, #0x40]
;;       sub     x0, x14, #0x98
;;       cmp     x15, x0
;;       b.hi    #0xc7c
;;  670: ldr     x24, [x1, #0x90]
;;       stur    x24, [sp, #0x38]
;;       sub     x0, x14, #0xa0
;;       cmp     x15, x0
;;       b.hi    #0xc64
;;  684: ldr     x25, [x1, #0x98]
;;       stur    x25, [sp, #0x30]
;;       sub     x0, x14, #0xa8
;;       cmp     x15, x0
;;       b.hi    #0xc4c
;;  698: ldr     x26, [x1, #0xa0]
;;       stur    x26, [sp, #0x28]
;;       sub     x0, x14, #0xb0
;;       cmp     x15, x0
;;       b.hi    #0xc34
;;  6ac: ldr     x27, [x1, #0xa8]
;;       stur    x27, [sp, #0x20]
;;       sub     x0, x14, #0xb8
;;       cmp     x15, x0
;;       b.hi    #0xc1c
;;  6c0: ldr     x28, [x1, #0xb0]
;;       stur    x28, [sp, #0x18]
;;       sub     x0, x14, #0xc0
;;       cmp     x15, x0
;;       b.hi    #0xc04
;;  6d4: ldr     x0, [x1, #0xb8]
;;       stur    x0, [sp, #0x10]
;;       sub     x0, x14, #0xc8
;;       cmp     x15, x0
;;       b.hi    #0xbec
;;  6e8: ldr     x2, [x1, #0xc0]
;;       stur    x2, [sp, #8]
;;       sub     x0, x14, #0xd0
;;       cmp     x15, x0
;;       b.hi    #0xbd4
;;  6fc: ldr     x2, [x1, #0xc8]
;;       sub     x3, x14, #0xd8
;;       cmp     x15, x3
;;       b.hi    #0xbbc
;;  70c: ldr     x3, [x1, #0xd0]
;;       sub     x4, x14, #0xe0
;;       cmp     x15, x4
;;       b.hi    #0xba4
;;  71c: ldr     x4, [x1, #0xd8]
;;       sub     x5, x14, #0xe8
;;       cmp     x15, x5
;;       b.hi    #0xb8c
;;  72c: ldr     x5, [x1, #0xe0]
;;       sub     x7, x14, #0xf0
;;       cmp     x15, x7
;;       b.hi    #0xb74
;;  73c: ldr     x6, [x1, #0xe8]
;;       sub     x9, x14, #0xf8
;;       cmp     x15, x9
;;       b.hi    #0xb5c
;;  74c: ldr     x7, [x1, #0xf0]
;;       sub     x11, x14, #0x100
;;       cmp     x15, x11
;;       b.hi    #0xb44
;;  75c: ldr     x8, [x1, #0xf8]
;;       sub     x13, x14, #0x108
;;       cmp     x15, x13
;;       b.hi    #0xb2c
;;  76c: ldr     x9, [x1, #0x100]
;;       sub     x0, x14, #0x110
;;       cmp     x15, x0
;;       b.hi    #0xb14
;;  77c: ldr     x10, [x1, #0x108]
;;       sub     x0, x14, #0x118
;;       cmp     x15, x0
;;       b.hi    #0xafc
;;  78c: ldr     x11, [x1, #0x110]
;;       sub     x0, x14, #0x120
;;       cmp     x15, x0
;;       b.hi    #0xae4
;;  79c: ldr     x12, [x1, #0x118]
;;       sub     x0, x14, #0x128
;;       cmp     x15, x0
;;       b.hi    #0xacc
;;  7ac: ldr     x13, [x1, #0x120]
;;       sub     x0, x14, #0x130
;;       cmp     x15, x0
;;       b.hi    #0xab4
;;  7bc: ldr     x19, [x1, #0x128]
;;       sub     x0, x14, #0x138
;;       cmp     x15, x0
;;       b.hi    #0xa9c
;;  7cc: ldr     x20, [x1, #0x130]
;;       sub     x0, x14, #0x140
;;       cmp     x15, x0
;;       b.hi    #0xa84
;;  7dc: ldr     x21, [x1, #0x138]
;;       sub     x0, x14, #0x148
;;       cmp     x15, x0
;;       b.hi    #0xa6c
;;  7ec: ldr     x22, [x1, #0x140]
;;       sub     x0, x14, #0x150
;;       cmp     x15, x0
;;       b.hi    #0xa54
;;  7fc: ldr     x23, [x1, #0x148]
;;       sub     x0, x14, #0x158
;;       cmp     x15, x0
;;       b.hi    #0xa3c
;;  80c: ldr     x24, [x1, #0x150]
;;       sub     x0, x14, #0x160
;;       cmp     x15, x0
;;       b.hi    #0xa24
;;  81c: ldr     x25, [x1, #0x158]
;;       sub     x0, x14, #0x168
;;       cmp     x15, x0
;;       b.hi    #0xa0c
;;  82c: ldr     x26, [x1, #0x160]
;;       sub     x0, x14, #0x170
;;       cmp     x15, x0
;;       b.hi    #0x9f4
;;  83c: ldr     x27, [x1, #0x168]
;;       sub     x0, x14, #0x178
;;       cmp     x15, x0
;;       b.hi    #0x9dc
;;  84c: ldr     x28, [x1, #0x170]
;;       sub     x0, x14, #0x180
;;       cmp     x15, x0
;;       b.hi    #0x9c4
;;  85c: ldr     x0, [x1, #0x178]
;;       sub     x14, x14, #0x188
;;       cmp     x15, x14
;;       b.hi    #0x9ac
;;  86c: ldr     x1, [x1, #0x180]
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
;;  9ac: mov     w3, #1
;;  9b0: ldur    x2, [sp]
;;  9b4: bl      #0xebc
;;  9b8: ldur    x2, [sp]
;;  9bc: bl      #0xef4
;;  9c0: udf     #0xc11f
;;  9c4: mov     w3, #1
;;  9c8: ldur    x2, [sp]
;;  9cc: bl      #0xebc
;;  9d0: ldur    x2, [sp]
;;  9d4: bl      #0xef4
;;  9d8: udf     #0xc11f
;;  9dc: mov     w3, #1
;;  9e0: ldur    x2, [sp]
;;  9e4: bl      #0xebc
;;  9e8: ldur    x2, [sp]
;;  9ec: bl      #0xef4
;;  9f0: udf     #0xc11f
;;  9f4: mov     w3, #1
;;  9f8: ldur    x2, [sp]
;;  9fc: bl      #0xebc
;;  a00: ldur    x2, [sp]
;;  a04: bl      #0xef4
;;  a08: udf     #0xc11f
;;  a0c: mov     w3, #1
;;  a10: ldur    x2, [sp]
;;  a14: bl      #0xebc
;;  a18: ldur    x2, [sp]
;;  a1c: bl      #0xef4
;;  a20: udf     #0xc11f
;;  a24: mov     w3, #1
;;  a28: ldur    x2, [sp]
;;  a2c: bl      #0xebc
;;  a30: ldur    x2, [sp]
;;  a34: bl      #0xef4
;;  a38: udf     #0xc11f
;;  a3c: mov     w3, #1
;;  a40: ldur    x2, [sp]
;;  a44: bl      #0xebc
;;  a48: ldur    x2, [sp]
;;  a4c: bl      #0xef4
;;  a50: udf     #0xc11f
;;  a54: mov     w3, #1
;;  a58: ldur    x2, [sp]
;;  a5c: bl      #0xebc
;;  a60: ldur    x2, [sp]
;;  a64: bl      #0xef4
;;  a68: udf     #0xc11f
;;  a6c: mov     w3, #1
;;  a70: ldur    x2, [sp]
;;  a74: bl      #0xebc
;;  a78: ldur    x2, [sp]
;;  a7c: bl      #0xef4
;;  a80: udf     #0xc11f
;;  a84: mov     w3, #1
;;  a88: ldur    x2, [sp]
;;  a8c: bl      #0xebc
;;  a90: ldur    x2, [sp]
;;  a94: bl      #0xef4
;;  a98: udf     #0xc11f
;;  a9c: mov     w3, #1
;;  aa0: ldur    x2, [sp]
;;  aa4: bl      #0xebc
;;  aa8: ldur    x2, [sp]
;;  aac: bl      #0xef4
;;  ab0: udf     #0xc11f
;;  ab4: mov     w3, #1
;;  ab8: ldur    x2, [sp]
;;  abc: bl      #0xebc
;;  ac0: ldur    x2, [sp]
;;  ac4: bl      #0xef4
;;  ac8: udf     #0xc11f
;;  acc: mov     w3, #1
;;  ad0: ldur    x2, [sp]
;;  ad4: bl      #0xebc
;;  ad8: ldur    x2, [sp]
;;  adc: bl      #0xef4
;;  ae0: udf     #0xc11f
;;  ae4: mov     w3, #1
;;  ae8: ldur    x2, [sp]
;;  aec: bl      #0xebc
;;  af0: ldur    x2, [sp]
;;  af4: bl      #0xef4
;;  af8: udf     #0xc11f
;;  afc: mov     w3, #1
;;  b00: ldur    x2, [sp]
;;  b04: bl      #0xebc
;;  b08: ldur    x2, [sp]
;;  b0c: bl      #0xef4
;;  b10: udf     #0xc11f
;;  b14: mov     w3, #1
;;  b18: ldur    x2, [sp]
;;  b1c: bl      #0xebc
;;  b20: ldur    x2, [sp]
;;  b24: bl      #0xef4
;;  b28: udf     #0xc11f
;;  b2c: mov     w3, #1
;;  b30: ldur    x2, [sp]
;;  b34: bl      #0xebc
;;  b38: ldur    x2, [sp]
;;  b3c: bl      #0xef4
;;  b40: udf     #0xc11f
;;  b44: mov     w3, #1
;;  b48: ldur    x2, [sp]
;;  b4c: bl      #0xebc
;;  b50: ldur    x2, [sp]
;;  b54: bl      #0xef4
;;  b58: udf     #0xc11f
;;  b5c: mov     w3, #1
;;  b60: ldur    x2, [sp]
;;  b64: bl      #0xebc
;;  b68: ldur    x2, [sp]
;;  b6c: bl      #0xef4
;;  b70: udf     #0xc11f
;;  b74: mov     w3, #1
;;  b78: ldur    x2, [sp]
;;  b7c: bl      #0xebc
;;  b80: ldur    x2, [sp]
;;  b84: bl      #0xef4
;;  b88: udf     #0xc11f
;;  b8c: mov     w3, #1
;;  b90: ldur    x2, [sp]
;;  b94: bl      #0xebc
;;  b98: ldur    x2, [sp]
;;  b9c: bl      #0xef4
;;  ba0: udf     #0xc11f
;;  ba4: mov     w3, #1
;;  ba8: ldur    x2, [sp]
;;  bac: bl      #0xebc
;;  bb0: ldur    x2, [sp]
;;  bb4: bl      #0xef4
;;  bb8: udf     #0xc11f
;;  bbc: mov     w3, #1
;;  bc0: ldur    x2, [sp]
;;  bc4: bl      #0xebc
;;  bc8: ldur    x2, [sp]
;;  bcc: bl      #0xef4
;;  bd0: udf     #0xc11f
;;  bd4: mov     w3, #1
;;  bd8: ldur    x2, [sp]
;;  bdc: bl      #0xebc
;;  be0: ldur    x2, [sp]
;;  be4: bl      #0xef4
;;  be8: udf     #0xc11f
;;  bec: mov     w3, #1
;;  bf0: ldur    x2, [sp]
;;  bf4: bl      #0xebc
;;  bf8: ldur    x2, [sp]
;;  bfc: bl      #0xef4
;;  c00: udf     #0xc11f
;;  c04: mov     w3, #1
;;  c08: ldur    x2, [sp]
;;  c0c: bl      #0xebc
;;  c10: ldur    x2, [sp]
;;  c14: bl      #0xef4
;;  c18: udf     #0xc11f
;;  c1c: mov     w3, #1
;;  c20: ldur    x2, [sp]
;;  c24: bl      #0xebc
;;  c28: ldur    x2, [sp]
;;  c2c: bl      #0xef4
;;  c30: udf     #0xc11f
;;  c34: mov     w3, #1
;;  c38: ldur    x2, [sp]
;;  c3c: bl      #0xebc
;;  c40: ldur    x2, [sp]
;;  c44: bl      #0xef4
;;  c48: udf     #0xc11f
;;  c4c: mov     w3, #1
;;  c50: ldur    x2, [sp]
;;  c54: bl      #0xebc
;;  c58: ldur    x2, [sp]
;;  c5c: bl      #0xef4
;;  c60: udf     #0xc11f
;;  c64: mov     w3, #1
;;  c68: ldur    x2, [sp]
;;  c6c: bl      #0xebc
;;  c70: ldur    x2, [sp]
;;  c74: bl      #0xef4
;;  c78: udf     #0xc11f
;;  c7c: mov     w3, #1
;;  c80: ldur    x2, [sp]
;;  c84: bl      #0xebc
;;  c88: ldur    x2, [sp]
;;  c8c: bl      #0xef4
;;  c90: udf     #0xc11f
;;  c94: mov     w3, #1
;;  c98: ldur    x2, [sp]
;;  c9c: bl      #0xebc
;;  ca0: ldur    x2, [sp]
;;  ca4: bl      #0xef4
;;  ca8: udf     #0xc11f
;;  cac: mov     w3, #1
;;  cb0: ldur    x2, [sp]
;;  cb4: bl      #0xebc
;;  cb8: ldur    x2, [sp]
;;  cbc: bl      #0xef4
;;  cc0: udf     #0xc11f
;;  cc4: mov     w3, #1
;;  cc8: ldur    x2, [sp]
;;  ccc: bl      #0xebc
;;  cd0: ldur    x2, [sp]
;;  cd4: bl      #0xef4
;;  cd8: udf     #0xc11f
;;  cdc: mov     w3, #1
;;  ce0: ldur    x2, [sp]
;;  ce4: bl      #0xebc
;;  ce8: ldur    x2, [sp]
;;  cec: bl      #0xef4
;;  cf0: udf     #0xc11f
;;  cf4: mov     w3, #1
;;  cf8: ldur    x2, [sp]
;;  cfc: bl      #0xebc
;;  d00: ldur    x2, [sp]
;;  d04: bl      #0xef4
;;  d08: udf     #0xc11f
;;  d0c: mov     w3, #1
;;  d10: ldur    x2, [sp]
;;  d14: bl      #0xebc
;;  d18: ldur    x2, [sp]
;;  d1c: bl      #0xef4
;;  d20: udf     #0xc11f
;;  d24: mov     w3, #1
;;  d28: ldur    x2, [sp]
;;  d2c: bl      #0xebc
;;  d30: ldur    x2, [sp]
;;  d34: bl      #0xef4
;;  d38: udf     #0xc11f
;;  d3c: mov     w3, #1
;;  d40: ldur    x2, [sp]
;;  d44: bl      #0xebc
;;  d48: ldur    x2, [sp]
;;  d4c: bl      #0xef4
;;  d50: udf     #0xc11f
;;  d54: mov     w3, #1
;;  d58: ldur    x2, [sp]
;;  d5c: bl      #0xebc
;;  d60: ldur    x2, [sp]
;;  d64: bl      #0xef4
;;  d68: udf     #0xc11f
;;  d6c: mov     w3, #1
;;  d70: ldur    x2, [sp]
;;  d74: bl      #0xebc
;;  d78: ldur    x2, [sp]
;;  d7c: bl      #0xef4
;;  d80: udf     #0xc11f
;;  d84: mov     w3, #1
;;  d88: ldur    x2, [sp]
;;  d8c: bl      #0xebc
;;  d90: ldur    x2, [sp]
;;  d94: bl      #0xef4
;;  d98: udf     #0xc11f
;;  d9c: mov     w3, #1
;;  da0: ldur    x2, [sp]
;;  da4: bl      #0xebc
;;  da8: ldur    x2, [sp]
;;  dac: bl      #0xef4
;;  db0: udf     #0xc11f
;;  db4: mov     w3, #1
;;  db8: ldur    x2, [sp]
;;  dbc: bl      #0xebc
;;  dc0: ldur    x2, [sp]
;;  dc4: bl      #0xef4
;;  dc8: udf     #0xc11f
;;  dcc: mov     w3, #1
;;  dd0: ldur    x2, [sp]
;;  dd4: bl      #0xebc
;;  dd8: ldur    x2, [sp]
;;  ddc: bl      #0xef4
;;  de0: udf     #0xc11f
;;  de4: mov     w3, #1
;;  de8: ldur    x2, [sp]
;;  dec: bl      #0xebc
;;  df0: ldur    x2, [sp]
;;  df4: bl      #0xef4
;;  df8: udf     #0xc11f
;;  dfc: mov     w3, #1
;;  e00: ldur    x2, [sp]
;;  e04: bl      #0xebc
;;  e08: ldur    x2, [sp]
;;  e0c: bl      #0xef4
;;  e10: udf     #0xc11f
;;  e14: stur    x2, [sp]
;;  e18: mov     w3, #1
;;  e1c: bl      #0xebc
;;  e20: ldur    x2, [sp]
;;  e24: bl      #0xef4
;;  e28: udf     #0xc11f
;;  e2c: stur    x2, [sp]
;;  e30: mov     w3, #0
;;  e34: bl      #0xebc
;;  e38: ldur    x2, [sp]
;;  e3c: bl      #0xef4
;;  e40: udf     #0xc11f
