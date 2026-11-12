;;! target = "x86_64"
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
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x10, %rsp
;;       movq    %r12, (%rsp)
;;       movq    %rdi, %r10
;;       movq    8(%r10), %rdi
;;       movq    %r10, %r12
;;       movq    %rsp, %r8
;;       cmpq    0xa0(%rdi), %r8
;;       jb      0x37
;;   26: leaq    1(%rdx), %rax
;;       movq    (%rsp), %r12
;;       addq    $0x10, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   37: xorl    %esi, %esi
;;   39: movq    %r12, %rdi
;;   3c: callq   0x11f1
;;   41: movq    %r12, %rdi
;;   44: callq   0x1222
;;   49: ud2
;;
;; wasm[0]::function[1]::small:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       cmpq    %fs:0x10, %rsp
;;       jb      0x83
;;   73: movq    %rdi, %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   83: movq    %rsp, %rsi
;;   86: callq   0x124f
;;   8b: movq    %rdi, %rsi
;;   8e: jmp     0x76
;;
;; wasm[0]::function[2]::large_caller:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       xorl    %eax, %eax
;;       movq    %rsp, %r11
;;       subq    $0xa0, %r11
;;       cmovbq  %rax, %r11
;;       cmpq    %fs:0x10, %r11
;;       jae     0xd1
;;   c3: movq    %rsi, %r10
;;       movq    %r11, %rsi
;;       callq   0x124f
;;       movq    %r10, %rsi
;;       subq    $0x90, %rsp
;;       movq    %rbx, 0x60(%rsp)
;;       movq    %r12, 0x68(%rsp)
;;       movq    %r13, 0x70(%rsp)
;;       movq    %r14, 0x78(%rsp)
;;       movq    %r15, 0x80(%rsp)
;;       cmpq    %fs:0x10, %rsp
;;       jb      0x333
;;  103: movq    0x40(%rdi), %rcx
;;       movl    %edx, %eax
;;       movq    %rcx, %rsi
;;       subq    $0xb, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x4b7
;;  119: movq    0x38(%rdi), %rsi
;;       movq    %rdi, (%rsp)
;;       movq    3(%rsi, %rax), %rdi
;;       movq    %rdi, 0x58(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0xd, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x49e
;;  13b: movq    5(%rsi, %rax), %rdi
;;       movq    %rdi, 0x50(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0xf, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x485
;;  155: movq    7(%rsi, %rax), %rdi
;;       movq    %rdi, 0x48(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x13, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x46c
;;  16f: movq    0xb(%rsi, %rax), %rdi
;;       movq    %rdi, 0x40(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x15, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x453
;;  189: movq    0xd(%rsi, %rax), %rdi
;;       movq    %rdi, 0x38(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x19, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x43a
;;  1a3: movq    0x11(%rsi, %rax), %rdi
;;       movq    %rdi, 0x30(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x1b, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x421
;;  1bd: movq    0x13(%rsi, %rax), %rdi
;;       movq    %rdi, 0x28(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x1f, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x408
;;  1d7: movq    0x17(%rsi, %rax), %rdi
;;       movq    %rdi, 0x20(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x25, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x3ef
;;  1f1: movq    0x1d(%rsi, %rax), %rdi
;;       movq    %rdi, 0x18(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x27, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x3d6
;;  20b: movq    0x1f(%rsi, %rax), %rdi
;;       movq    %rdi, 0x10(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x2d, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x3bd
;;  225: movq    0x25(%rsi, %rax), %r8
;;       movq    %r8, 8(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0x31, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x3a4
;;  23f: movq    0x29(%rsi, %rax), %rbx
;;       movq    %rcx, %rdi
;;       subq    $0x33, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x38b
;;  254: movq    0x2b(%rsi, %rax), %r12
;;       movq    %rcx, %rdi
;;       subq    $0x37, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x372
;;  269: movq    0x2f(%rsi, %rax), %r13
;;       movq    %rcx, %rdi
;;       subq    $0x3d, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0x359
;;  27e: movq    0x35(%rsi, %rax), %r15
;;       subq    $0x43, %rcx
;;       cmpq    %rcx, %rax
;;       ja      0x340
;;  290: movq    0x3b(%rsi, %rax), %r14
;;       movq    (%rsp), %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    0x58(%rsp), %rax
;;       movq    0x50(%rsp), %rdi
;;       leaq    (%rax, %rdi), %rcx
;;       movq    0x48(%rsp), %rax
;;       movq    0x40(%rsp), %rdi
;;       addq    %rdi, %rax
;;       addq    %rax, %rcx
;;       movq    0x38(%rsp), %rax
;;       movq    0x30(%rsp), %rdi
;;       leaq    (%rax, %rdi), %rdx
;;       movq    0x28(%rsp), %rax
;;       movq    0x20(%rsp), %rdi
;;       addq    %rdi, %rax
;;       addq    %rdx, %rax
;;       addq    %rax, %rcx
;;       movq    0x18(%rsp), %rax
;;       movq    0x10(%rsp), %rdi
;;       leaq    (%rax, %rdi), %rdx
;;       movq    8(%rsp), %r8
;;       leaq    (%r8, %rbx), %rax
;;       addq    %rax, %rdx
;;       leaq    (%r12, %r13), %rsi
;;       leaq    (%r15, %r14), %rax
;;       addq    %rsi, %rax
;;       addq    %rdx, %rax
;;       addq    %rcx, %rax
;;       movq    0x60(%rsp), %rbx
;;       movq    0x68(%rsp), %r12
;;       movq    0x70(%rsp), %r13
;;       movq    0x78(%rsp), %r14
;;       movq    0x80(%rsp), %r15
;;       addq    $0x90, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;  333: movq    %rsp, %rsi
;;  336: callq   0x124f
;;  33b: jmp     0x103
;;  340: movl    $1, %esi
;;  345: movq    (%rsp), %rdi
;;  349: callq   0x11f1
;;  34e: movq    (%rsp), %rdi
;;  352: callq   0x1222
;;  357: ud2
;;  359: movl    $1, %esi
;;  35e: movq    (%rsp), %rdi
;;  362: callq   0x11f1
;;  367: movq    (%rsp), %rdi
;;  36b: callq   0x1222
;;  370: ud2
;;  372: movl    $1, %esi
;;  377: movq    (%rsp), %rdi
;;  37b: callq   0x11f1
;;  380: movq    (%rsp), %rdi
;;  384: callq   0x1222
;;  389: ud2
;;  38b: movl    $1, %esi
;;  390: movq    (%rsp), %rdi
;;  394: callq   0x11f1
;;  399: movq    (%rsp), %rdi
;;  39d: callq   0x1222
;;  3a2: ud2
;;  3a4: movl    $1, %esi
;;  3a9: movq    (%rsp), %rdi
;;  3ad: callq   0x11f1
;;  3b2: movq    (%rsp), %rdi
;;  3b6: callq   0x1222
;;  3bb: ud2
;;  3bd: movl    $1, %esi
;;  3c2: movq    (%rsp), %rdi
;;  3c6: callq   0x11f1
;;  3cb: movq    (%rsp), %rdi
;;  3cf: callq   0x1222
;;  3d4: ud2
;;  3d6: movl    $1, %esi
;;  3db: movq    (%rsp), %rdi
;;  3df: callq   0x11f1
;;  3e4: movq    (%rsp), %rdi
;;  3e8: callq   0x1222
;;  3ed: ud2
;;  3ef: movl    $1, %esi
;;  3f4: movq    (%rsp), %rdi
;;  3f8: callq   0x11f1
;;  3fd: movq    (%rsp), %rdi
;;  401: callq   0x1222
;;  406: ud2
;;  408: movl    $1, %esi
;;  40d: movq    (%rsp), %rdi
;;  411: callq   0x11f1
;;  416: movq    (%rsp), %rdi
;;  41a: callq   0x1222
;;  41f: ud2
;;  421: movl    $1, %esi
;;  426: movq    (%rsp), %rdi
;;  42a: callq   0x11f1
;;  42f: movq    (%rsp), %rdi
;;  433: callq   0x1222
;;  438: ud2
;;  43a: movl    $1, %esi
;;  43f: movq    (%rsp), %rdi
;;  443: callq   0x11f1
;;  448: movq    (%rsp), %rdi
;;  44c: callq   0x1222
;;  451: ud2
;;  453: movl    $1, %esi
;;  458: movq    (%rsp), %rdi
;;  45c: callq   0x11f1
;;  461: movq    (%rsp), %rdi
;;  465: callq   0x1222
;;  46a: ud2
;;  46c: movl    $1, %esi
;;  471: movq    (%rsp), %rdi
;;  475: callq   0x11f1
;;  47a: movq    (%rsp), %rdi
;;  47e: callq   0x1222
;;  483: ud2
;;  485: movl    $1, %esi
;;  48a: movq    (%rsp), %rdi
;;  48e: callq   0x11f1
;;  493: movq    (%rsp), %rdi
;;  497: callq   0x1222
;;  49c: ud2
;;  49e: movl    $1, %esi
;;  4a3: movq    (%rsp), %rdi
;;  4a7: callq   0x11f1
;;  4ac: movq    (%rsp), %rdi
;;  4b0: callq   0x1222
;;  4b5: ud2
;;  4b7: movq    %rdi, (%rsp)
;;  4bb: movl    $1, %esi
;;  4c0: callq   0x11f1
;;  4c5: movq    (%rsp), %rdi
;;  4c9: callq   0x1222
;;  4ce: ud2
;;
;; wasm[0]::function[3]::large_leaf:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       xorl    %eax, %eax
;;       movq    %rsp, %r11
;;       subq    $0x170, %r11
;;       cmovbq  %rax, %r11
;;       cmpq    %fs:0x10, %r11
;;       jae     0x511
;;  503: movq    %rsi, %r10
;;       movq    %r11, %rsi
;;       callq   0x124f
;;       movq    %r10, %rsi
;;       subq    $0x160, %rsp
;;       movq    %rbx, 0x130(%rsp)
;;       movq    %r12, 0x138(%rsp)
;;       movq    %r13, 0x140(%rsp)
;;       movq    %r14, 0x148(%rsp)
;;       movq    %r15, 0x150(%rsp)
;;       movq    8(%rdi), %r11
;;       movq    %rsp, %rax
;;       cmpq    0xa0(%r11), %rax
;;       jb      0x116f
;;  554: movq    0x40(%rdi), %rcx
;;       movl    %edx, %eax
;;       movq    %rcx, %rdx
;;       subq    $0x10, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1156
;;  56a: movq    0x38(%rdi), %rsi
;;       movq    %rdi, (%rsp)
;;       movq    8(%rsi, %rax), %rdi
;;       movq    %rdi, 0x120(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x18, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x113d
;;  58f: movq    0x10(%rsi, %rax), %r8
;;       movq    %r8, 0x118(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x20, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1124
;;  5ac: movq    0x18(%rsi, %rax), %r9
;;       movq    %r9, 0x110(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x28, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x110b
;;  5c9: movq    0x20(%rsi, %rax), %r10
;;       movq    %r10, 0x108(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x30, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10f2
;;  5e6: movq    0x28(%rsi, %rax), %r11
;;       movq    %r11, 0x100(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x38, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10d9
;;  603: movq    0x30(%rsi, %rax), %rbx
;;       movq    %rbx, 0xf8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x40, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10c0
;;  620: movq    0x38(%rsi, %rax), %r12
;;       movq    %r12, 0xf0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x48, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10a7
;;  63d: movq    0x40(%rsi, %rax), %r13
;;       movq    %r13, 0xe8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x50, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x108e
;;  65a: movq    0x48(%rsi, %rax), %r14
;;       movq    %r14, 0xe0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x58, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1075
;;  677: movq    0x50(%rsi, %rax), %r15
;;       movq    %r15, 0xd8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x60, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x105c
;;  694: movq    0x58(%rsi, %rax), %rdx
;;       movq    %rdx, 0xd0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x68, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1043
;;  6b1: movq    0x60(%rsi, %rax), %rdi
;;       movq    %rdi, 0xc8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x70, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x102a
;;  6ce: movq    0x68(%rsi, %rax), %r8
;;       movq    %r8, 0xc0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x78, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1011
;;  6eb: movq    0x70(%rsi, %rax), %r9
;;       movq    %r9, 0xb8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x80, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xff8
;;  70b: movq    0x78(%rsi, %rax), %r10
;;       movq    %r10, 0xb0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x88, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfdf
;;  72b: movq    0x80(%rsi, %rax), %r11
;;       movq    %r11, 0xa8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x90, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfc6
;;  74e: movq    0x88(%rsi, %rax), %rbx
;;       movq    %rbx, 0xa0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x98, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfad
;;  771: movq    0x90(%rsi, %rax), %r12
;;       movq    %r12, 0x98(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xa0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf94
;;  794: movq    0x98(%rsi, %rax), %r13
;;       movq    %r13, 0x90(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xa8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf7b
;;  7b7: movq    0xa0(%rsi, %rax), %r14
;;       movq    %r14, 0x88(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xb0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf62
;;  7da: movq    0xa8(%rsi, %rax), %r15
;;       movq    %r15, 0x80(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xb8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf49
;;  7fd: movq    0xb0(%rsi, %rax), %rdx
;;       movq    %rdx, 0x78(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xc0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf30
;;  81d: movq    0xb8(%rsi, %rax), %rdi
;;       movq    %rdi, 0x70(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xc8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf17
;;  83d: movq    0xc0(%rsi, %rax), %r8
;;       movq    %r8, 0x68(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xd0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xefe
;;  85d: movq    0xc8(%rsi, %rax), %r9
;;       movq    %r9, 0x60(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xd8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xee5
;;  87d: movq    0xd0(%rsi, %rax), %r10
;;       movq    %r10, 0x58(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xe0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xecc
;;  89d: movq    0xd8(%rsi, %rax), %r11
;;       movq    %r11, 0x50(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0xe8, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0xeb3
;;  8bd: movq    0xe0(%rsi, %rax), %rbx
;;       movq    %rbx, 0x48(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0xf0, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0xe9a
;;  8dd: movq    0xe8(%rsi, %rax), %r12
;;       movq    %r12, 0x40(%rsp)
;;       movq    %rcx, %r8
;;       subq    $0xf8, %r8
;;       cmpq    %r8, %rax
;;       ja      0xe81
;;  8fd: movq    0xf0(%rsi, %rax), %r13
;;       movq    %r13, 0x38(%rsp)
;;       movq    %rcx, %r10
;;       subq    $0x100, %r10
;;       cmpq    %r10, %rax
;;       ja      0xe68
;;  91d: movq    0xf8(%rsi, %rax), %r14
;;       movq    %r14, 0x30(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x108, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe4f
;;  93d: movq    0x100(%rsi, %rax), %r15
;;       movq    %r15, 0x28(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x110, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe36
;;  95d: movq    0x108(%rsi, %rax), %rdx
;;       movq    %rdx, 0x20(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x118, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe1d
;;  97d: movq    0x110(%rsi, %rax), %rdi
;;       movq    %rdi, 0x18(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x120, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe04
;;  99d: movq    0x118(%rsi, %rax), %r8
;;       movq    %r8, 0x10(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x128, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xdeb
;;  9bd: movq    0x120(%rsi, %rax), %r9
;;       movq    %r9, 8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x130, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xdd2
;;  9dd: movq    0x128(%rsi, %rax), %r9
;;       movq    %rcx, %rdx
;;       subq    $0x138, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xdb9
;;  9f8: movq    0x130(%rsi, %rax), %r10
;;       movq    %rcx, %rdx
;;       subq    $0x140, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xda0
;;  a13: movq    0x138(%rsi, %rax), %r11
;;       movq    %rcx, %rdx
;;       subq    $0x148, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd87
;;  a2e: movq    0x140(%rsi, %rax), %rbx
;;       movq    %rcx, %rdx
;;       subq    $0x150, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd6e
;;  a49: movq    0x148(%rsi, %rax), %r12
;;       movq    %rcx, %rdx
;;       subq    $0x158, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd55
;;  a64: movq    0x150(%rsi, %rax), %r13
;;       movq    %rcx, %rdx
;;       subq    $0x160, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd3c
;;  a7f: movq    0x158(%rsi, %rax), %r14
;;       movq    %rcx, %rdx
;;       subq    $0x168, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd23
;;  a9a: movq    0x160(%rsi, %rax), %r15
;;       movq    %rcx, %rdx
;;       subq    $0x170, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd0a
;;  ab5: movq    0x168(%rsi, %rax), %rdx
;;       movq    %rcx, %rdi
;;       subq    $0x178, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0xcf1
;;  ad0: movq    0x170(%rsi, %rax), %rdi
;;       movq    %rcx, %r8
;;       subq    $0x180, %r8
;;       cmpq    %r8, %rax
;;       ja      0xcd8
;;  aeb: movq    0x178(%rsi, %rax), %r8
;;       subq    $0x188, %rcx
;;       cmpq    %rcx, %rax
;;       ja      0xcbf
;;  b03: movq    0x180(%rsi, %rax), %rax
;;       movq    0x118(%rsp), %rcx
;;       movq    0x120(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x110(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x108(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x100(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xf8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xf0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xe8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xe0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xd8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xd0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xc8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xc0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xb8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xb0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xa8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xa0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x98(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x90(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x88(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x80(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x78(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x70(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x68(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x60(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x58(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x50(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x48(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x40(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x38(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x30(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x28(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x20(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x18(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x10(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       addq    %r9, %rcx
;;       addq    %r10, %rcx
;;       addq    %r11, %rcx
;;       addq    %rbx, %rcx
;;       addq    %r12, %rcx
;;       addq    %r13, %rcx
;;       addq    %r14, %rcx
;;       addq    %r15, %rcx
;;       addq    %rdx, %rcx
;;       addq    %rdi, %rcx
;;       addq    %r8, %rcx
;;       addq    %rcx, %rax
;;       movq    0x130(%rsp), %rbx
;;       movq    0x138(%rsp), %r12
;;       movq    0x140(%rsp), %r13
;;       movq    0x148(%rsp), %r14
;;       movq    0x150(%rsp), %r15
;;       addq    $0x160, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;  cbf: movl    $1, %esi
;;  cc4: movq    (%rsp), %rdi
;;  cc8: callq   0x11f1
;;  ccd: movq    (%rsp), %rdi
;;  cd1: callq   0x1222
;;  cd6: ud2
;;  cd8: movl    $1, %esi
;;  cdd: movq    (%rsp), %rdi
;;  ce1: callq   0x11f1
;;  ce6: movq    (%rsp), %rdi
;;  cea: callq   0x1222
;;  cef: ud2
;;  cf1: movl    $1, %esi
;;  cf6: movq    (%rsp), %rdi
;;  cfa: callq   0x11f1
;;  cff: movq    (%rsp), %rdi
;;  d03: callq   0x1222
;;  d08: ud2
;;  d0a: movl    $1, %esi
;;  d0f: movq    (%rsp), %rdi
;;  d13: callq   0x11f1
;;  d18: movq    (%rsp), %rdi
;;  d1c: callq   0x1222
;;  d21: ud2
;;  d23: movl    $1, %esi
;;  d28: movq    (%rsp), %rdi
;;  d2c: callq   0x11f1
;;  d31: movq    (%rsp), %rdi
;;  d35: callq   0x1222
;;  d3a: ud2
;;  d3c: movl    $1, %esi
;;  d41: movq    (%rsp), %rdi
;;  d45: callq   0x11f1
;;  d4a: movq    (%rsp), %rdi
;;  d4e: callq   0x1222
;;  d53: ud2
;;  d55: movl    $1, %esi
;;  d5a: movq    (%rsp), %rdi
;;  d5e: callq   0x11f1
;;  d63: movq    (%rsp), %rdi
;;  d67: callq   0x1222
;;  d6c: ud2
;;  d6e: movl    $1, %esi
;;  d73: movq    (%rsp), %rdi
;;  d77: callq   0x11f1
;;  d7c: movq    (%rsp), %rdi
;;  d80: callq   0x1222
;;  d85: ud2
;;  d87: movl    $1, %esi
;;  d8c: movq    (%rsp), %rdi
;;  d90: callq   0x11f1
;;  d95: movq    (%rsp), %rdi
;;  d99: callq   0x1222
;;  d9e: ud2
;;  da0: movl    $1, %esi
;;  da5: movq    (%rsp), %rdi
;;  da9: callq   0x11f1
;;  dae: movq    (%rsp), %rdi
;;  db2: callq   0x1222
;;  db7: ud2
;;  db9: movl    $1, %esi
;;  dbe: movq    (%rsp), %rdi
;;  dc2: callq   0x11f1
;;  dc7: movq    (%rsp), %rdi
;;  dcb: callq   0x1222
;;  dd0: ud2
;;  dd2: movl    $1, %esi
;;  dd7: movq    (%rsp), %rdi
;;  ddb: callq   0x11f1
;;  de0: movq    (%rsp), %rdi
;;  de4: callq   0x1222
;;  de9: ud2
;;  deb: movl    $1, %esi
;;  df0: movq    (%rsp), %rdi
;;  df4: callq   0x11f1
;;  df9: movq    (%rsp), %rdi
;;  dfd: callq   0x1222
;;  e02: ud2
;;  e04: movl    $1, %esi
;;  e09: movq    (%rsp), %rdi
;;  e0d: callq   0x11f1
;;  e12: movq    (%rsp), %rdi
;;  e16: callq   0x1222
;;  e1b: ud2
;;  e1d: movl    $1, %esi
;;  e22: movq    (%rsp), %rdi
;;  e26: callq   0x11f1
;;  e2b: movq    (%rsp), %rdi
;;  e2f: callq   0x1222
;;  e34: ud2
;;  e36: movl    $1, %esi
;;  e3b: movq    (%rsp), %rdi
;;  e3f: callq   0x11f1
;;  e44: movq    (%rsp), %rdi
;;  e48: callq   0x1222
;;  e4d: ud2
;;  e4f: movl    $1, %esi
;;  e54: movq    (%rsp), %rdi
;;  e58: callq   0x11f1
;;  e5d: movq    (%rsp), %rdi
;;  e61: callq   0x1222
;;  e66: ud2
;;  e68: movl    $1, %esi
;;  e6d: movq    (%rsp), %rdi
;;  e71: callq   0x11f1
;;  e76: movq    (%rsp), %rdi
;;  e7a: callq   0x1222
;;  e7f: ud2
;;  e81: movl    $1, %esi
;;  e86: movq    (%rsp), %rdi
;;  e8a: callq   0x11f1
;;  e8f: movq    (%rsp), %rdi
;;  e93: callq   0x1222
;;  e98: ud2
;;  e9a: movl    $1, %esi
;;  e9f: movq    (%rsp), %rdi
;;  ea3: callq   0x11f1
;;  ea8: movq    (%rsp), %rdi
;;  eac: callq   0x1222
;;  eb1: ud2
;;  eb3: movl    $1, %esi
;;  eb8: movq    (%rsp), %rdi
;;  ebc: callq   0x11f1
;;  ec1: movq    (%rsp), %rdi
;;  ec5: callq   0x1222
;;  eca: ud2
;;  ecc: movl    $1, %esi
;;  ed1: movq    (%rsp), %rdi
;;  ed5: callq   0x11f1
;;  eda: movq    (%rsp), %rdi
;;  ede: callq   0x1222
;;  ee3: ud2
;;  ee5: movl    $1, %esi
;;  eea: movq    (%rsp), %rdi
;;  eee: callq   0x11f1
;;  ef3: movq    (%rsp), %rdi
;;  ef7: callq   0x1222
;;  efc: ud2
;;  efe: movl    $1, %esi
;;  f03: movq    (%rsp), %rdi
;;  f07: callq   0x11f1
;;  f0c: movq    (%rsp), %rdi
;;  f10: callq   0x1222
;;  f15: ud2
;;  f17: movl    $1, %esi
;;  f1c: movq    (%rsp), %rdi
;;  f20: callq   0x11f1
;;  f25: movq    (%rsp), %rdi
;;  f29: callq   0x1222
;;  f2e: ud2
;;  f30: movl    $1, %esi
;;  f35: movq    (%rsp), %rdi
;;  f39: callq   0x11f1
;;  f3e: movq    (%rsp), %rdi
;;  f42: callq   0x1222
;;  f47: ud2
;;  f49: movl    $1, %esi
;;  f4e: movq    (%rsp), %rdi
;;  f52: callq   0x11f1
;;  f57: movq    (%rsp), %rdi
;;  f5b: callq   0x1222
;;  f60: ud2
;;  f62: movl    $1, %esi
;;  f67: movq    (%rsp), %rdi
;;  f6b: callq   0x11f1
;;  f70: movq    (%rsp), %rdi
;;  f74: callq   0x1222
;;  f79: ud2
;;  f7b: movl    $1, %esi
;;  f80: movq    (%rsp), %rdi
;;  f84: callq   0x11f1
;;  f89: movq    (%rsp), %rdi
;;  f8d: callq   0x1222
;;  f92: ud2
;;  f94: movl    $1, %esi
;;  f99: movq    (%rsp), %rdi
;;  f9d: callq   0x11f1
;;  fa2: movq    (%rsp), %rdi
;;  fa6: callq   0x1222
;;  fab: ud2
;;  fad: movl    $1, %esi
;;  fb2: movq    (%rsp), %rdi
;;  fb6: callq   0x11f1
;;  fbb: movq    (%rsp), %rdi
;;  fbf: callq   0x1222
;;  fc4: ud2
;;  fc6: movl    $1, %esi
;;  fcb: movq    (%rsp), %rdi
;;  fcf: callq   0x11f1
;;  fd4: movq    (%rsp), %rdi
;;  fd8: callq   0x1222
;;  fdd: ud2
;;  fdf: movl    $1, %esi
;;  fe4: movq    (%rsp), %rdi
;;  fe8: callq   0x11f1
;;  fed: movq    (%rsp), %rdi
;;  ff1: callq   0x1222
;;  ff6: ud2
;;  ff8: movl    $1, %esi
;;  ffd: movq    (%rsp), %rdi
;; 1001: callq   0x11f1
;; 1006: movq    (%rsp), %rdi
;; 100a: callq   0x1222
;; 100f: ud2
;; 1011: movl    $1, %esi
;; 1016: movq    (%rsp), %rdi
;; 101a: callq   0x11f1
;; 101f: movq    (%rsp), %rdi
;; 1023: callq   0x1222
;; 1028: ud2
;; 102a: movl    $1, %esi
;; 102f: movq    (%rsp), %rdi
;; 1033: callq   0x11f1
;; 1038: movq    (%rsp), %rdi
;; 103c: callq   0x1222
;; 1041: ud2
;; 1043: movl    $1, %esi
;; 1048: movq    (%rsp), %rdi
;; 104c: callq   0x11f1
;; 1051: movq    (%rsp), %rdi
;; 1055: callq   0x1222
;; 105a: ud2
;; 105c: movl    $1, %esi
;; 1061: movq    (%rsp), %rdi
;; 1065: callq   0x11f1
;; 106a: movq    (%rsp), %rdi
;; 106e: callq   0x1222
;; 1073: ud2
;; 1075: movl    $1, %esi
;; 107a: movq    (%rsp), %rdi
;; 107e: callq   0x11f1
;; 1083: movq    (%rsp), %rdi
;; 1087: callq   0x1222
;; 108c: ud2
;; 108e: movl    $1, %esi
;; 1093: movq    (%rsp), %rdi
;; 1097: callq   0x11f1
;; 109c: movq    (%rsp), %rdi
;; 10a0: callq   0x1222
;; 10a5: ud2
;; 10a7: movl    $1, %esi
;; 10ac: movq    (%rsp), %rdi
;; 10b0: callq   0x11f1
;; 10b5: movq    (%rsp), %rdi
;; 10b9: callq   0x1222
;; 10be: ud2
;; 10c0: movl    $1, %esi
;; 10c5: movq    (%rsp), %rdi
;; 10c9: callq   0x11f1
;; 10ce: movq    (%rsp), %rdi
;; 10d2: callq   0x1222
;; 10d7: ud2
;; 10d9: movl    $1, %esi
;; 10de: movq    (%rsp), %rdi
;; 10e2: callq   0x11f1
;; 10e7: movq    (%rsp), %rdi
;; 10eb: callq   0x1222
;; 10f0: ud2
;; 10f2: movl    $1, %esi
;; 10f7: movq    (%rsp), %rdi
;; 10fb: callq   0x11f1
;; 1100: movq    (%rsp), %rdi
;; 1104: callq   0x1222
;; 1109: ud2
;; 110b: movl    $1, %esi
;; 1110: movq    (%rsp), %rdi
;; 1114: callq   0x11f1
;; 1119: movq    (%rsp), %rdi
;; 111d: callq   0x1222
;; 1122: ud2
;; 1124: movl    $1, %esi
;; 1129: movq    (%rsp), %rdi
;; 112d: callq   0x11f1
;; 1132: movq    (%rsp), %rdi
;; 1136: callq   0x1222
;; 113b: ud2
;; 113d: movl    $1, %esi
;; 1142: movq    (%rsp), %rdi
;; 1146: callq   0x11f1
;; 114b: movq    (%rsp), %rdi
;; 114f: callq   0x1222
;; 1154: ud2
;; 1156: movq    %rdi, (%rsp)
;; 115a: movl    $1, %esi
;; 115f: callq   0x11f1
;; 1164: movq    (%rsp), %rdi
;; 1168: callq   0x1222
;; 116d: ud2
;; 116f: movq    %rdi, (%rsp)
;; 1173: xorl    %esi, %esi
;; 1175: callq   0x11f1
;; 117a: movq    (%rsp), %rdi
;; 117e: callq   0x1222
;; 1183: ud2
