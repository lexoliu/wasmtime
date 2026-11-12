;;! target = "riscv64"
;;! test = "compile"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=processor:16", "-Wstack-limit-large-frame=64", "-Ccollector=null"]

;; With a 64-byte threshold, `$small` keeps its prologue, and `$large_caller`
;; (class A) and `$large_leaf` (class B, with no trap check of its own) call
;; the stack-limit builtin from the prologue, before the frame is probed or
;; the clobbers are saved, against the limit word of the executing processor.
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
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       addi    a0, a2, 1
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
;;
;; wasm[0]::function[1]::small:
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       ld      a1, 0x10(tp)
;;       mv      a3, sp
;;       bltu    a3, a1, 0x24
;;       mv      a1, a0
;;       mv      a0, a1
;;       auipc   ra, 0
;;       jalr    ra, ra, -0x48
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
;;       mv      a1, sp
;;       auipc   ra, 0
;;       jalr    ra, ra, 0x52c
;;       mv      a1, a0
;;       j       -0x2c
;;
;; wasm[0]::function[2]::large_caller:
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       ld      t5, 0x10(tp)
;;       addi    t6, sp, -0xa0
;;       sltu    t4, sp, t6
;;       addi    t4, t4, -1
;;       and     t6, t6, t4
;;       bgeu    t6, t5, 0x1c
;;       mv      t4, a1
;;       mv      a1, t6
;;       auipc   ra, 0
;;       jalr    ra, ra, 0x4ec
;;       ld      ra, 8(s0)
;;       mv      a1, t4
;;       addi    sp, sp, -0x90
;;       sd      s1, 0x88(sp)
;;       sd      s2, 0x80(sp)
;;       sd      s3, 0x78(sp)
;;       sd      s4, 0x70(sp)
;;       sd      s5, 0x68(sp)
;;       sd      s6, 0x60(sp)
;;       sd      s7, 0x58(sp)
;;       sd      s8, 0x50(sp)
;;       sd      s9, 0x48(sp)
;;       sd      s10, 0x40(sp)
;;       sd      s11, 0x38(sp)
;;       ld      a1, 0x10(tp)
;;       mv      a3, sp
;;       bltu    a3, a1, 0x104
;;       ld      a1, 0x38(a0)
;;       slli    a3, a2, 0x20
;;       srli    a3, a3, 0x20
;;       add     a1, a1, a3
;;       ld      a3, 3(a1)
;;       sd      a3, 0x20(sp)
;;       ld      a3, 5(a1)
;;       sd      a3, 0x18(sp)
;;       ld      a3, 7(a1)
;;       sd      a3, 0x10(sp)
;;       ld      s6, 0xb(a1)
;;       ld      a3, 0xd(a1)
;;       sd      a3, 8(sp)
;;       ld      s7, 0x11(a1)
;;       ld      s8, 0x13(a1)
;;       ld      s1, 0x17(a1)
;;       ld      a3, 0x1d(a1)
;;       sd      a3, 0(sp)
;;       ld      s9, 0x1f(a1)
;;       ld      s10, 0x25(a1)
;;       ld      s2, 0x29(a1)
;;       ld      s11, 0x2b(a1)
;;       ld      s3, 0x2f(a1)
;;       ld      s4, 0x35(a1)
;;       ld      s5, 0x3b(a1)
;;       mv      a1, a0
;;       auipc   ra, 0
;;       jalr    ra, ra, -0x158
;;       ld      a0, 0x20(sp)
;;       ld      a3, 0x18(sp)
;;       add     a0, a0, a3
;;       ld      a3, 0x10(sp)
;;       add     a1, a3, s6
;;       add     a0, a0, a1
;;       ld      a3, 8(sp)
;;       add     a1, a3, s7
;;       add     a2, s8, s1
;;       add     a1, a1, a2
;;       add     a0, a0, a1
;;       ld      a3, 0(sp)
;;       add     a1, a3, s9
;;       add     a2, s10, s2
;;       add     a1, a1, a2
;;       add     a2, s11, s3
;;       add     a3, s4, s5
;;       add     a2, a2, a3
;;       add     a1, a1, a2
;;       add     a0, a0, a1
;;       ld      s1, 0x88(sp)
;;       ld      s2, 0x80(sp)
;;       ld      s3, 0x78(sp)
;;       ld      s4, 0x70(sp)
;;       ld      s5, 0x68(sp)
;;       ld      s6, 0x60(sp)
;;       ld      s7, 0x58(sp)
;;       ld      s8, 0x50(sp)
;;       ld      s9, 0x48(sp)
;;       ld      s10, 0x40(sp)
;;       ld      s11, 0x38(sp)
;;       addi    sp, sp, 0x90
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
;;       mv      a1, sp
;;       auipc   ra, 0
;;       jalr    ra, ra, 0x39c
;;       j       -0x10c
;;
;; wasm[0]::function[3]::large_leaf:
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       ld      t5, 0x10(tp)
;;       addi    t6, sp, -0x130
;;       sltu    t4, sp, t6
;;       addi    t4, t4, -1
;;       and     t6, t6, t4
;;       bgeu    t6, t5, 0x1c
;;       mv      t4, a1
;;       mv      a1, t6
;;       auipc   ra, 0
;;       jalr    ra, ra, 0x360
;;       ld      ra, 8(s0)
;;       mv      a1, t4
;;       addi    sp, sp, -0x130
;;       sd      s1, 0x128(sp)
;;       sd      s2, 0x120(sp)
;;       sd      s3, 0x118(sp)
;;       sd      s4, 0x110(sp)
;;       sd      s5, 0x108(sp)
;;       sd      s6, 0x100(sp)
;;       sd      s7, 0xf8(sp)
;;       sd      s8, 0xf0(sp)
;;       sd      s9, 0xe8(sp)
;;       sd      s10, 0xe0(sp)
;;       sd      s11, 0xd8(sp)
;;       ld      a0, 0x38(a0)
;;       slli    a1, a2, 0x20
;;       srli    a1, a1, 0x20
;;       add     a1, a0, a1
;;       ld      a0, 8(a1)
;;       sd      a0, 0xc0(sp)
;;       ld      a2, 0x10(a1)
;;       ld      a3, 0x18(a1)
;;       ld      a4, 0x20(a1)
;;       ld      a5, 0x28(a1)
;;       ld      t0, 0x30(a1)
;;       ld      t1, 0x38(a1)
;;       ld      t2, 0x40(a1)
;;       ld      s1, 0x48(a1)
;;       ld      a6, 0x50(a1)
;;       ld      a7, 0x58(a1)
;;       ld      s2, 0x60(a1)
;;       ld      s3, 0x68(a1)
;;       ld      s4, 0x70(a1)
;;       ld      s5, 0x78(a1)
;;       ld      s6, 0x80(a1)
;;       ld      s7, 0x88(a1)
;;       ld      s8, 0x90(a1)
;;       ld      s9, 0x98(a1)
;;       ld      s10, 0xa0(a1)
;;       ld      s11, 0xa8(a1)
;;       ld      t3, 0xb0(a1)
;;       ld      t4, 0xb8(a1)
;;       ld      a0, 0xc0(a1)
;;       sd      a0, 0xb8(sp)
;;       ld      a0, 0xc8(a1)
;;       sd      a0, 0xb0(sp)
;;       ld      a0, 0xd0(a1)
;;       sd      a0, 0xa8(sp)
;;       ld      a0, 0xd8(a1)
;;       sd      a0, 0xa0(sp)
;;       ld      a0, 0xe0(a1)
;;       sd      a0, 0x98(sp)
;;       ld      a0, 0xe8(a1)
;;       sd      a0, 0x90(sp)
;;       ld      a0, 0xf0(a1)
;;       sd      a0, 0x88(sp)
;;       ld      a0, 0xf8(a1)
;;       sd      a0, 0x80(sp)
;;       ld      a0, 0x100(a1)
;;       sd      a0, 0x78(sp)
;;       ld      a0, 0x108(a1)
;;       sd      a0, 0x70(sp)
;;       ld      a0, 0x110(a1)
;;       sd      a0, 0x68(sp)
;;       ld      a0, 0x118(a1)
;;       sd      a0, 0x60(sp)
;;       ld      a0, 0x120(a1)
;;       sd      a0, 0x58(sp)
;;       ld      a0, 0x128(a1)
;;       sd      a0, 0x50(sp)
;;       ld      a0, 0x130(a1)
;;       sd      a0, 0x48(sp)
;;       ld      a0, 0x138(a1)
;;       sd      a0, 0x40(sp)
;;       ld      a0, 0x140(a1)
;;       sd      a0, 0x38(sp)
;;       ld      a0, 0x148(a1)
;;       sd      a0, 0x30(sp)
;;       ld      a0, 0x150(a1)
;;       sd      a0, 0x28(sp)
;;       ld      a0, 0x158(a1)
;;       sd      a0, 0x20(sp)
;;       ld      a0, 0x160(a1)
;;       sd      a0, 0x18(sp)
;;       ld      a0, 0x168(a1)
;;       sd      a0, 0x10(sp)
;;       ld      a0, 0x170(a1)
;;       sd      a0, 8(sp)
;;       ld      a0, 0x178(a1)
;;       sd      a0, 0(sp)
;;       ld      a1, 0x180(a1)
;;       ld      a0, 0xc0(sp)
;;       add     a0, a0, a2
;;       add     a0, a0, a3
;;       add     a0, a0, a4
;;       add     a0, a0, a5
;;       add     a0, a0, t0
;;       add     a0, a0, t1
;;       add     a0, a0, t2
;;       add     a0, a0, s1
;;       add     a0, a0, a6
;;       add     a0, a0, a7
;;       add     a0, a0, s2
;;       add     a0, a0, s3
;;       add     a0, a0, s4
;;       add     a0, a0, s5
;;       add     a0, a0, s6
;;       add     a0, a0, s7
;;       add     a0, a0, s8
;;       add     a0, a0, s9
;;       add     a0, a0, s10
;;       add     a0, a0, s11
;;       add     a0, a0, t3
;;       add     a0, a0, t4
;;       ld      a2, 0xb8(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0xb0(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0xa8(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0xa0(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x98(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x90(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x88(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x80(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x78(sp)
;;       add     a0, a0, a2
;;       ld      a5, 0x70(sp)
;;       add     a0, a0, a5
;;       ld      a2, 0x68(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x60(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x58(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x50(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x48(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x40(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x38(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x30(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x28(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x20(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x18(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0x10(sp)
;;       add     a0, a0, a2
;;       ld      a2, 8(sp)
;;       add     a0, a0, a2
;;       ld      a2, 0(sp)
;;       add     a0, a0, a2
;;       add     a0, a0, a1
;;       ld      s1, 0x128(sp)
;;       ld      s2, 0x120(sp)
;;       ld      s3, 0x118(sp)
;;       ld      s4, 0x110(sp)
;;       ld      s5, 0x108(sp)
;;       ld      s6, 0x100(sp)
;;       ld      s7, 0xf8(sp)
;;       ld      s8, 0xf0(sp)
;;       ld      s9, 0xe8(sp)
;;       ld      s10, 0xe0(sp)
;;       ld      s11, 0xd8(sp)
;;       addi    sp, sp, 0x130
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
