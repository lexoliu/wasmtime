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
;;       cmpq    0x90(%rdi), %r8
;;       jb      0x37
;;   26: leaq    1(%rdx), %rax
;;       movq    (%rsp), %r12
;;       addq    $0x10, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   37: xorl    %esi, %esi
;;   39: movq    %r12, %rdi
;;   3c: callq   0x1211
;;   41: movq    %r12, %rdi
;;   44: callq   0x1242
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
;;   86: callq   0x126f
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
;;       callq   0x126f
;;       movq    %r10, %rsi
;;       subq    $0x90, %rsp
;;       movq    %rbx, 0x60(%rsp)
;;       movq    %r12, 0x68(%rsp)
;;       movq    %r13, 0x70(%rsp)
;;       movq    %r14, 0x78(%rsp)
;;       movq    %r15, 0x80(%rsp)
;;       cmpq    %fs:0x10, %rsp
;;       jb      0x344
;;  103: movq    0x40(%rdi), %rcx
;;       movl    %edx, %eax
;;       subq    $0xb, %rcx
;;       cmpq    %rcx, %rax
;;       ja      0x4c8
;;  116: movq    0x38(%rdi), %rcx
;;       movq    3(%rcx, %rax), %rsi
;;       movq    %rsi, 0x58(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0xd, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x4af
;;  135: movq    5(%rcx, %rax), %rsi
;;       movq    %rsi, 0x50(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0xf, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x496
;;  150: movq    7(%rcx, %rax), %rsi
;;       movq    %rsi, 0x48(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x13, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x47d
;;  16b: movq    0xb(%rcx, %rax), %rsi
;;       movq    %rsi, 0x40(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x15, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x464
;;  186: movq    0xd(%rcx, %rax), %rsi
;;       movq    %rsi, 0x38(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x19, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x44b
;;  1a1: movq    0x11(%rcx, %rax), %rsi
;;       movq    %rsi, 0x30(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x1b, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x432
;;  1bc: movq    0x13(%rcx, %rax), %rsi
;;       movq    %rsi, 0x28(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x1f, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x419
;;  1d7: movq    0x17(%rcx, %rax), %rsi
;;       movq    %rsi, 0x20(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x25, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x400
;;  1f2: movq    0x1d(%rcx, %rax), %rsi
;;       movq    %rsi, 0x18(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x27, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x3e7
;;  20d: movq    0x1f(%rcx, %rax), %rsi
;;       movq    %rsi, 0x10(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x2d, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x3ce
;;  228: movq    0x25(%rcx, %rax), %r8
;;       movq    %r8, 8(%rsp)
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x31, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x3b5
;;  243: movq    0x29(%rcx, %rax), %r12
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x33, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x39c
;;  259: movq    0x2b(%rcx, %rax), %r13
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x37, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x383
;;  26f: movq    0x2f(%rcx, %rax), %r14
;;       movq    0x40(%rdi), %rsi
;;       subq    $0x3d, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x36a
;;  285: movq    0x35(%rcx, %rax), %r15
;;       movq    0x40(%rdi), %rsi
;;       movq    %rdi, (%rsp)
;;       subq    $0x43, %rsi
;;       cmpq    %rsi, %rax
;;       ja      0x351
;;  29f: movq    0x3b(%rcx, %rax), %rbx
;;       movq    (%rsp), %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    0x58(%rsp), %rax
;;       movq    0x50(%rsp), %rsi
;;       leaq    (%rax, %rsi), %rcx
;;       movq    0x48(%rsp), %rax
;;       movq    0x40(%rsp), %rsi
;;       addq    %rsi, %rax
;;       addq    %rax, %rcx
;;       movq    0x38(%rsp), %rax
;;       movq    0x30(%rsp), %rsi
;;       leaq    (%rax, %rsi), %rdx
;;       movq    0x20(%rsp), %rsi
;;       movq    0x28(%rsp), %rdi
;;       leaq    (%rdi, %rsi), %rax
;;       addq    %rdx, %rax
;;       addq    %rax, %rcx
;;       movq    0x18(%rsp), %rax
;;       movq    0x10(%rsp), %rsi
;;       leaq    (%rax, %rsi), %rdx
;;       movq    8(%rsp), %r8
;;       leaq    (%r8, %r12), %rax
;;       addq    %rax, %rdx
;;       leaq    (%r13, %r14), %rsi
;;       leaq    (%r15, %rbx), %rax
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
;;  344: movq    %rsp, %rsi
;;  347: callq   0x126f
;;  34c: jmp     0x103
;;  351: movl    $1, %esi
;;  356: movq    (%rsp), %rdi
;;  35a: callq   0x1211
;;  35f: movq    (%rsp), %rdi
;;  363: callq   0x1242
;;  368: ud2
;;  36a: movq    %rdi, (%rsp)
;;  36e: movl    $1, %esi
;;  373: callq   0x1211
;;  378: movq    (%rsp), %rdi
;;  37c: callq   0x1242
;;  381: ud2
;;  383: movq    %rdi, (%rsp)
;;  387: movl    $1, %esi
;;  38c: callq   0x1211
;;  391: movq    (%rsp), %rdi
;;  395: callq   0x1242
;;  39a: ud2
;;  39c: movq    %rdi, (%rsp)
;;  3a0: movl    $1, %esi
;;  3a5: callq   0x1211
;;  3aa: movq    (%rsp), %rdi
;;  3ae: callq   0x1242
;;  3b3: ud2
;;  3b5: movq    %rdi, (%rsp)
;;  3b9: movl    $1, %esi
;;  3be: callq   0x1211
;;  3c3: movq    (%rsp), %rdi
;;  3c7: callq   0x1242
;;  3cc: ud2
;;  3ce: movq    %rdi, (%rsp)
;;  3d2: movl    $1, %esi
;;  3d7: callq   0x1211
;;  3dc: movq    (%rsp), %rdi
;;  3e0: callq   0x1242
;;  3e5: ud2
;;  3e7: movq    %rdi, (%rsp)
;;  3eb: movl    $1, %esi
;;  3f0: callq   0x1211
;;  3f5: movq    (%rsp), %rdi
;;  3f9: callq   0x1242
;;  3fe: ud2
;;  400: movq    %rdi, (%rsp)
;;  404: movl    $1, %esi
;;  409: callq   0x1211
;;  40e: movq    (%rsp), %rdi
;;  412: callq   0x1242
;;  417: ud2
;;  419: movq    %rdi, (%rsp)
;;  41d: movl    $1, %esi
;;  422: callq   0x1211
;;  427: movq    (%rsp), %rdi
;;  42b: callq   0x1242
;;  430: ud2
;;  432: movq    %rdi, (%rsp)
;;  436: movl    $1, %esi
;;  43b: callq   0x1211
;;  440: movq    (%rsp), %rdi
;;  444: callq   0x1242
;;  449: ud2
;;  44b: movq    %rdi, (%rsp)
;;  44f: movl    $1, %esi
;;  454: callq   0x1211
;;  459: movq    (%rsp), %rdi
;;  45d: callq   0x1242
;;  462: ud2
;;  464: movq    %rdi, (%rsp)
;;  468: movl    $1, %esi
;;  46d: callq   0x1211
;;  472: movq    (%rsp), %rdi
;;  476: callq   0x1242
;;  47b: ud2
;;  47d: movq    %rdi, (%rsp)
;;  481: movl    $1, %esi
;;  486: callq   0x1211
;;  48b: movq    (%rsp), %rdi
;;  48f: callq   0x1242
;;  494: ud2
;;  496: movq    %rdi, (%rsp)
;;  49a: movl    $1, %esi
;;  49f: callq   0x1211
;;  4a4: movq    (%rsp), %rdi
;;  4a8: callq   0x1242
;;  4ad: ud2
;;  4af: movq    %rdi, (%rsp)
;;  4b3: movl    $1, %esi
;;  4b8: callq   0x1211
;;  4bd: movq    (%rsp), %rdi
;;  4c1: callq   0x1242
;;  4c6: ud2
;;  4c8: movq    %rdi, (%rsp)
;;  4cc: movl    $1, %esi
;;  4d1: callq   0x1211
;;  4d6: movq    (%rsp), %rdi
;;  4da: callq   0x1242
;;  4df: ud2
;;
;; wasm[0]::function[3]::large_leaf:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       xorl    %eax, %eax
;;       movq    %rsp, %r11
;;       subq    $0x170, %r11
;;       cmovbq  %rax, %r11
;;       cmpq    %fs:0x10, %r11
;;       jae     0x531
;;  523: movq    %rsi, %r10
;;       movq    %r11, %rsi
;;       callq   0x126f
;;       movq    %r10, %rsi
;;       subq    $0x160, %rsp
;;       movq    %rbx, 0x130(%rsp)
;;       movq    %r12, 0x138(%rsp)
;;       movq    %r13, 0x140(%rsp)
;;       movq    %r14, 0x148(%rsp)
;;       movq    %r15, 0x150(%rsp)
;;       movq    8(%rdi), %r11
;;       movq    %rsp, %rax
;;       cmpq    0x90(%r11), %rax
;;       jb      0x118f
;;  574: movq    0x40(%rdi), %rcx
;;       movl    %edx, %eax
;;       movq    %rcx, %rdx
;;       subq    $0x10, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1176
;;  58a: movq    0x38(%rdi), %rsi
;;       movq    %rdi, (%rsp)
;;       movq    8(%rsi, %rax), %rdi
;;       movq    %rdi, 0x120(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x18, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x115d
;;  5af: movq    0x10(%rsi, %rax), %r8
;;       movq    %r8, 0x118(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x20, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1144
;;  5cc: movq    0x18(%rsi, %rax), %r9
;;       movq    %r9, 0x110(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x28, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x112b
;;  5e9: movq    0x20(%rsi, %rax), %r10
;;       movq    %r10, 0x108(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x30, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1112
;;  606: movq    0x28(%rsi, %rax), %r11
;;       movq    %r11, 0x100(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x38, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10f9
;;  623: movq    0x30(%rsi, %rax), %rbx
;;       movq    %rbx, 0xf8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x40, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10e0
;;  640: movq    0x38(%rsi, %rax), %r12
;;       movq    %r12, 0xf0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x48, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10c7
;;  65d: movq    0x40(%rsi, %rax), %r13
;;       movq    %r13, 0xe8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x50, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x10ae
;;  67a: movq    0x48(%rsi, %rax), %r14
;;       movq    %r14, 0xe0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x58, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1095
;;  697: movq    0x50(%rsi, %rax), %r15
;;       movq    %r15, 0xd8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x60, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x107c
;;  6b4: movq    0x58(%rsi, %rax), %rdx
;;       movq    %rdx, 0xd0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x68, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1063
;;  6d1: movq    0x60(%rsi, %rax), %rdi
;;       movq    %rdi, 0xc8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x70, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x104a
;;  6ee: movq    0x68(%rsi, %rax), %r8
;;       movq    %r8, 0xc0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x78, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1031
;;  70b: movq    0x70(%rsi, %rax), %r9
;;       movq    %r9, 0xb8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x80, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0x1018
;;  72b: movq    0x78(%rsi, %rax), %r10
;;       movq    %r10, 0xb0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x88, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfff
;;  74b: movq    0x80(%rsi, %rax), %r11
;;       movq    %r11, 0xa8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x90, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfe6
;;  76e: movq    0x88(%rsi, %rax), %rbx
;;       movq    %rbx, 0xa0(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x98, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfcd
;;  791: movq    0x90(%rsi, %rax), %r12
;;       movq    %r12, 0x98(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xa0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xfb4
;;  7b4: movq    0x98(%rsi, %rax), %r13
;;       movq    %r13, 0x90(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xa8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf9b
;;  7d7: movq    0xa0(%rsi, %rax), %r14
;;       movq    %r14, 0x88(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xb0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf82
;;  7fa: movq    0xa8(%rsi, %rax), %r15
;;       movq    %r15, 0x80(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xb8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf69
;;  81d: movq    0xb0(%rsi, %rax), %rdx
;;       movq    %rdx, 0x78(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xc0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf50
;;  83d: movq    0xb8(%rsi, %rax), %rdi
;;       movq    %rdi, 0x70(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xc8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf37
;;  85d: movq    0xc0(%rsi, %rax), %r8
;;       movq    %r8, 0x68(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xd0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf1e
;;  87d: movq    0xc8(%rsi, %rax), %r9
;;       movq    %r9, 0x60(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xd8, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xf05
;;  89d: movq    0xd0(%rsi, %rax), %r10
;;       movq    %r10, 0x58(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0xe0, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xeec
;;  8bd: movq    0xd8(%rsi, %rax), %r11
;;       movq    %r11, 0x50(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0xe8, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0xed3
;;  8dd: movq    0xe0(%rsi, %rax), %rbx
;;       movq    %rbx, 0x48(%rsp)
;;       movq    %rcx, %rdi
;;       subq    $0xf0, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0xeba
;;  8fd: movq    0xe8(%rsi, %rax), %r12
;;       movq    %r12, 0x40(%rsp)
;;       movq    %rcx, %r8
;;       subq    $0xf8, %r8
;;       cmpq    %r8, %rax
;;       ja      0xea1
;;  91d: movq    0xf0(%rsi, %rax), %r13
;;       movq    %r13, 0x38(%rsp)
;;       movq    %rcx, %r10
;;       subq    $0x100, %r10
;;       cmpq    %r10, %rax
;;       ja      0xe88
;;  93d: movq    0xf8(%rsi, %rax), %r14
;;       movq    %r14, 0x30(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x108, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe6f
;;  95d: movq    0x100(%rsi, %rax), %r15
;;       movq    %r15, 0x28(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x110, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe56
;;  97d: movq    0x108(%rsi, %rax), %rdx
;;       movq    %rdx, 0x20(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x118, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe3d
;;  99d: movq    0x110(%rsi, %rax), %rdi
;;       movq    %rdi, 0x18(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x120, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe24
;;  9bd: movq    0x118(%rsi, %rax), %r8
;;       movq    %r8, 0x10(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x128, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xe0b
;;  9dd: movq    0x120(%rsi, %rax), %r9
;;       movq    %r9, 8(%rsp)
;;       movq    %rcx, %rdx
;;       subq    $0x130, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xdf2
;;  9fd: movq    0x128(%rsi, %rax), %r9
;;       movq    %rcx, %rdx
;;       subq    $0x138, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xdd9
;;  a18: movq    0x130(%rsi, %rax), %r10
;;       movq    %rcx, %rdx
;;       subq    $0x140, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xdc0
;;  a33: movq    0x138(%rsi, %rax), %r11
;;       movq    %rcx, %rdx
;;       subq    $0x148, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xda7
;;  a4e: movq    0x140(%rsi, %rax), %rbx
;;       movq    %rcx, %rdx
;;       subq    $0x150, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd8e
;;  a69: movq    0x148(%rsi, %rax), %r12
;;       movq    %rcx, %rdx
;;       subq    $0x158, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd75
;;  a84: movq    0x150(%rsi, %rax), %r13
;;       movq    %rcx, %rdx
;;       subq    $0x160, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd5c
;;  a9f: movq    0x158(%rsi, %rax), %r14
;;       movq    %rcx, %rdx
;;       subq    $0x168, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd43
;;  aba: movq    0x160(%rsi, %rax), %r15
;;       movq    %rcx, %rdx
;;       subq    $0x170, %rdx
;;       cmpq    %rdx, %rax
;;       ja      0xd2a
;;  ad5: movq    0x168(%rsi, %rax), %rdx
;;       movq    %rcx, %rdi
;;       subq    $0x178, %rdi
;;       cmpq    %rdi, %rax
;;       ja      0xd11
;;  af0: movq    0x170(%rsi, %rax), %rdi
;;       movq    %rcx, %r8
;;       subq    $0x180, %r8
;;       cmpq    %r8, %rax
;;       ja      0xcf8
;;  b0b: movq    0x178(%rsi, %rax), %r8
;;       subq    $0x188, %rcx
;;       cmpq    %rcx, %rax
;;       ja      0xcdf
;;  b23: movq    0x180(%rsi, %rax), %rax
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
;;  cdf: movl    $1, %esi
;;  ce4: movq    (%rsp), %rdi
;;  ce8: callq   0x1211
;;  ced: movq    (%rsp), %rdi
;;  cf1: callq   0x1242
;;  cf6: ud2
;;  cf8: movl    $1, %esi
;;  cfd: movq    (%rsp), %rdi
;;  d01: callq   0x1211
;;  d06: movq    (%rsp), %rdi
;;  d0a: callq   0x1242
;;  d0f: ud2
;;  d11: movl    $1, %esi
;;  d16: movq    (%rsp), %rdi
;;  d1a: callq   0x1211
;;  d1f: movq    (%rsp), %rdi
;;  d23: callq   0x1242
;;  d28: ud2
;;  d2a: movl    $1, %esi
;;  d2f: movq    (%rsp), %rdi
;;  d33: callq   0x1211
;;  d38: movq    (%rsp), %rdi
;;  d3c: callq   0x1242
;;  d41: ud2
;;  d43: movl    $1, %esi
;;  d48: movq    (%rsp), %rdi
;;  d4c: callq   0x1211
;;  d51: movq    (%rsp), %rdi
;;  d55: callq   0x1242
;;  d5a: ud2
;;  d5c: movl    $1, %esi
;;  d61: movq    (%rsp), %rdi
;;  d65: callq   0x1211
;;  d6a: movq    (%rsp), %rdi
;;  d6e: callq   0x1242
;;  d73: ud2
;;  d75: movl    $1, %esi
;;  d7a: movq    (%rsp), %rdi
;;  d7e: callq   0x1211
;;  d83: movq    (%rsp), %rdi
;;  d87: callq   0x1242
;;  d8c: ud2
;;  d8e: movl    $1, %esi
;;  d93: movq    (%rsp), %rdi
;;  d97: callq   0x1211
;;  d9c: movq    (%rsp), %rdi
;;  da0: callq   0x1242
;;  da5: ud2
;;  da7: movl    $1, %esi
;;  dac: movq    (%rsp), %rdi
;;  db0: callq   0x1211
;;  db5: movq    (%rsp), %rdi
;;  db9: callq   0x1242
;;  dbe: ud2
;;  dc0: movl    $1, %esi
;;  dc5: movq    (%rsp), %rdi
;;  dc9: callq   0x1211
;;  dce: movq    (%rsp), %rdi
;;  dd2: callq   0x1242
;;  dd7: ud2
;;  dd9: movl    $1, %esi
;;  dde: movq    (%rsp), %rdi
;;  de2: callq   0x1211
;;  de7: movq    (%rsp), %rdi
;;  deb: callq   0x1242
;;  df0: ud2
;;  df2: movl    $1, %esi
;;  df7: movq    (%rsp), %rdi
;;  dfb: callq   0x1211
;;  e00: movq    (%rsp), %rdi
;;  e04: callq   0x1242
;;  e09: ud2
;;  e0b: movl    $1, %esi
;;  e10: movq    (%rsp), %rdi
;;  e14: callq   0x1211
;;  e19: movq    (%rsp), %rdi
;;  e1d: callq   0x1242
;;  e22: ud2
;;  e24: movl    $1, %esi
;;  e29: movq    (%rsp), %rdi
;;  e2d: callq   0x1211
;;  e32: movq    (%rsp), %rdi
;;  e36: callq   0x1242
;;  e3b: ud2
;;  e3d: movl    $1, %esi
;;  e42: movq    (%rsp), %rdi
;;  e46: callq   0x1211
;;  e4b: movq    (%rsp), %rdi
;;  e4f: callq   0x1242
;;  e54: ud2
;;  e56: movl    $1, %esi
;;  e5b: movq    (%rsp), %rdi
;;  e5f: callq   0x1211
;;  e64: movq    (%rsp), %rdi
;;  e68: callq   0x1242
;;  e6d: ud2
;;  e6f: movl    $1, %esi
;;  e74: movq    (%rsp), %rdi
;;  e78: callq   0x1211
;;  e7d: movq    (%rsp), %rdi
;;  e81: callq   0x1242
;;  e86: ud2
;;  e88: movl    $1, %esi
;;  e8d: movq    (%rsp), %rdi
;;  e91: callq   0x1211
;;  e96: movq    (%rsp), %rdi
;;  e9a: callq   0x1242
;;  e9f: ud2
;;  ea1: movl    $1, %esi
;;  ea6: movq    (%rsp), %rdi
;;  eaa: callq   0x1211
;;  eaf: movq    (%rsp), %rdi
;;  eb3: callq   0x1242
;;  eb8: ud2
;;  eba: movl    $1, %esi
;;  ebf: movq    (%rsp), %rdi
;;  ec3: callq   0x1211
;;  ec8: movq    (%rsp), %rdi
;;  ecc: callq   0x1242
;;  ed1: ud2
;;  ed3: movl    $1, %esi
;;  ed8: movq    (%rsp), %rdi
;;  edc: callq   0x1211
;;  ee1: movq    (%rsp), %rdi
;;  ee5: callq   0x1242
;;  eea: ud2
;;  eec: movl    $1, %esi
;;  ef1: movq    (%rsp), %rdi
;;  ef5: callq   0x1211
;;  efa: movq    (%rsp), %rdi
;;  efe: callq   0x1242
;;  f03: ud2
;;  f05: movl    $1, %esi
;;  f0a: movq    (%rsp), %rdi
;;  f0e: callq   0x1211
;;  f13: movq    (%rsp), %rdi
;;  f17: callq   0x1242
;;  f1c: ud2
;;  f1e: movl    $1, %esi
;;  f23: movq    (%rsp), %rdi
;;  f27: callq   0x1211
;;  f2c: movq    (%rsp), %rdi
;;  f30: callq   0x1242
;;  f35: ud2
;;  f37: movl    $1, %esi
;;  f3c: movq    (%rsp), %rdi
;;  f40: callq   0x1211
;;  f45: movq    (%rsp), %rdi
;;  f49: callq   0x1242
;;  f4e: ud2
;;  f50: movl    $1, %esi
;;  f55: movq    (%rsp), %rdi
;;  f59: callq   0x1211
;;  f5e: movq    (%rsp), %rdi
;;  f62: callq   0x1242
;;  f67: ud2
;;  f69: movl    $1, %esi
;;  f6e: movq    (%rsp), %rdi
;;  f72: callq   0x1211
;;  f77: movq    (%rsp), %rdi
;;  f7b: callq   0x1242
;;  f80: ud2
;;  f82: movl    $1, %esi
;;  f87: movq    (%rsp), %rdi
;;  f8b: callq   0x1211
;;  f90: movq    (%rsp), %rdi
;;  f94: callq   0x1242
;;  f99: ud2
;;  f9b: movl    $1, %esi
;;  fa0: movq    (%rsp), %rdi
;;  fa4: callq   0x1211
;;  fa9: movq    (%rsp), %rdi
;;  fad: callq   0x1242
;;  fb2: ud2
;;  fb4: movl    $1, %esi
;;  fb9: movq    (%rsp), %rdi
;;  fbd: callq   0x1211
;;  fc2: movq    (%rsp), %rdi
;;  fc6: callq   0x1242
;;  fcb: ud2
;;  fcd: movl    $1, %esi
;;  fd2: movq    (%rsp), %rdi
;;  fd6: callq   0x1211
;;  fdb: movq    (%rsp), %rdi
;;  fdf: callq   0x1242
;;  fe4: ud2
;;  fe6: movl    $1, %esi
;;  feb: movq    (%rsp), %rdi
;;  fef: callq   0x1211
;;  ff4: movq    (%rsp), %rdi
;;  ff8: callq   0x1242
;;  ffd: ud2
;;  fff: movl    $1, %esi
;; 1004: movq    (%rsp), %rdi
;; 1008: callq   0x1211
;; 100d: movq    (%rsp), %rdi
;; 1011: callq   0x1242
;; 1016: ud2
;; 1018: movl    $1, %esi
;; 101d: movq    (%rsp), %rdi
;; 1021: callq   0x1211
;; 1026: movq    (%rsp), %rdi
;; 102a: callq   0x1242
;; 102f: ud2
;; 1031: movl    $1, %esi
;; 1036: movq    (%rsp), %rdi
;; 103a: callq   0x1211
;; 103f: movq    (%rsp), %rdi
;; 1043: callq   0x1242
;; 1048: ud2
;; 104a: movl    $1, %esi
;; 104f: movq    (%rsp), %rdi
;; 1053: callq   0x1211
;; 1058: movq    (%rsp), %rdi
;; 105c: callq   0x1242
;; 1061: ud2
;; 1063: movl    $1, %esi
;; 1068: movq    (%rsp), %rdi
;; 106c: callq   0x1211
;; 1071: movq    (%rsp), %rdi
;; 1075: callq   0x1242
;; 107a: ud2
;; 107c: movl    $1, %esi
;; 1081: movq    (%rsp), %rdi
;; 1085: callq   0x1211
;; 108a: movq    (%rsp), %rdi
;; 108e: callq   0x1242
;; 1093: ud2
;; 1095: movl    $1, %esi
;; 109a: movq    (%rsp), %rdi
;; 109e: callq   0x1211
;; 10a3: movq    (%rsp), %rdi
;; 10a7: callq   0x1242
;; 10ac: ud2
;; 10ae: movl    $1, %esi
;; 10b3: movq    (%rsp), %rdi
;; 10b7: callq   0x1211
;; 10bc: movq    (%rsp), %rdi
;; 10c0: callq   0x1242
;; 10c5: ud2
;; 10c7: movl    $1, %esi
;; 10cc: movq    (%rsp), %rdi
;; 10d0: callq   0x1211
;; 10d5: movq    (%rsp), %rdi
;; 10d9: callq   0x1242
;; 10de: ud2
;; 10e0: movl    $1, %esi
;; 10e5: movq    (%rsp), %rdi
;; 10e9: callq   0x1211
;; 10ee: movq    (%rsp), %rdi
;; 10f2: callq   0x1242
;; 10f7: ud2
;; 10f9: movl    $1, %esi
;; 10fe: movq    (%rsp), %rdi
;; 1102: callq   0x1211
;; 1107: movq    (%rsp), %rdi
;; 110b: callq   0x1242
;; 1110: ud2
;; 1112: movl    $1, %esi
;; 1117: movq    (%rsp), %rdi
;; 111b: callq   0x1211
;; 1120: movq    (%rsp), %rdi
;; 1124: callq   0x1242
;; 1129: ud2
;; 112b: movl    $1, %esi
;; 1130: movq    (%rsp), %rdi
;; 1134: callq   0x1211
;; 1139: movq    (%rsp), %rdi
;; 113d: callq   0x1242
;; 1142: ud2
;; 1144: movl    $1, %esi
;; 1149: movq    (%rsp), %rdi
;; 114d: callq   0x1211
;; 1152: movq    (%rsp), %rdi
;; 1156: callq   0x1242
;; 115b: ud2
;; 115d: movl    $1, %esi
;; 1162: movq    (%rsp), %rdi
;; 1166: callq   0x1211
;; 116b: movq    (%rsp), %rdi
;; 116f: callq   0x1242
;; 1174: ud2
;; 1176: movq    %rdi, (%rsp)
;; 117a: movl    $1, %esi
;; 117f: callq   0x1211
;; 1184: movq    (%rsp), %rdi
;; 1188: callq   0x1242
;; 118d: ud2
;; 118f: movq    %rdi, (%rsp)
;; 1193: xorl    %esi, %esi
;; 1195: callq   0x1211
;; 119a: movq    (%rsp), %rdi
;; 119e: callq   0x1242
;; 11a3: ud2
