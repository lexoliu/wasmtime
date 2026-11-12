;;! target = "x86_64"
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
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       leaq    1(%rdx), %rax
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;
;; wasm[0]::function[1]::small:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %rsi
;;       movq    %rsp, %r8
;;       cmpq    0x18(%rsi), %r8
;;       jb      0x45
;;   35: movq    %rdi, %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   45: movq    %rsp, %rsi
;;   48: callq   0x6c6
;;   4d: movq    %rdi, %rsi
;;   50: jmp     0x38
;;
;; wasm[0]::function[2]::large_caller:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       xorl    %eax, %eax
;;       movq    %rsp, %r11
;;       subq    $0xa0, %r11
;;       cmovbq  %rax, %r11
;;       cmpq    %r10, %r11
;;       jae     0x93
;;   85: movq    %rsi, %r10
;;       movq    %r11, %rsi
;;       callq   0x6c6
;;       movq    %r10, %rsi
;;       subq    $0x90, %rsp
;;       movq    %rbx, 0x60(%rsp)
;;       movq    %r12, 0x68(%rsp)
;;       movq    %r13, 0x70(%rsp)
;;       movq    %r14, 0x78(%rsp)
;;       movq    %r15, 0x80(%rsp)
;;       movq    8(%rdi), %rax
;;       movq    %rsp, %rcx
;;       cmpq    0x18(%rax), %rcx
;;       jb      0x1ee
;;   c7: movq    0x38(%rdi), %rcx
;;       movl    %edx, %esi
;;       movq    3(%rcx, %rsi), %r8
;;       movq    %r8, 0x50(%rsp)
;;       movq    5(%rcx, %rsi), %r8
;;       movq    %r8, 0x48(%rsp)
;;       movq    7(%rcx, %rsi), %r8
;;       movq    %r8, 0x40(%rsp)
;;       movq    0xb(%rcx, %rsi), %r9
;;       movq    %r9, 0x38(%rsp)
;;       movq    0xd(%rcx, %rsi), %r8
;;       movq    %r8, 0x30(%rsp)
;;       movq    0x11(%rcx, %rsi), %r8
;;       movq    %r8, 0x28(%rsp)
;;       movq    0x13(%rcx, %rsi), %r8
;;       movq    %r8, 0x20(%rsp)
;;       movq    0x17(%rcx, %rsi), %r15
;;       movq    0x1d(%rcx, %rsi), %r8
;;       movq    %r8, 0x18(%rsp)
;;       movq    0x1f(%rcx, %rsi), %r8
;;       movq    %r8, 0x10(%rsp)
;;       movq    0x25(%rcx, %rsi), %r8
;;       movq    %r8, 8(%rsp)
;;       movq    0x29(%rcx, %rsi), %rbx
;;       movq    0x2b(%rcx, %rsi), %r8
;;       movq    %r8, (%rsp)
;;       movq    0x2f(%rcx, %rsi), %r12
;;       movq    0x35(%rcx, %rsi), %r13
;;       movq    0x3b(%rcx, %rsi), %r14
;;       movq    %rdi, %rsi
;;       callq   0
;;       movq    0x50(%rsp), %rsi
;;       movq    0x48(%rsp), %r8
;;       leaq    (%rsi, %r8), %rcx
;;       movq    0x40(%rsp), %r8
;;       movq    0x38(%rsp), %r9
;;       leaq    (%r8, %r9), %rax
;;       addq    %rax, %rcx
;;       movq    0x30(%rsp), %rax
;;       movq    0x28(%rsp), %r8
;;       leaq    (%rax, %r8), %rdx
;;       movq    0x20(%rsp), %r8
;;       leaq    (%r8, %r15), %rax
;;       addq    %rdx, %rax
;;       addq    %rcx, %rax
;;       movq    0x18(%rsp), %rcx
;;       movq    0x10(%rsp), %r8
;;       addq    %r8, %rcx
;;       movq    8(%rsp), %r8
;;       leaq    (%r8, %rbx), %rdx
;;       addq    %rdx, %rcx
;;       movq    (%rsp), %r8
;;       leaq    (%r8, %r12), %rdx
;;       leaq    (%r13, %r14), %rsi
;;       addq    %rsi, %rdx
;;       addq    %rdx, %rcx
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
;;  1ee: movq    %rsp, %rsi
;;  1f1: callq   0x6c6
;;  1f6: jmp     0xc7
;;
;; wasm[0]::function[3]::large_leaf:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       xorl    %eax, %eax
;;       movq    %rsp, %r11
;;       subq    $0x150, %r11
;;       cmovbq  %rax, %r11
;;       cmpq    %r10, %r11
;;       jae     0x233
;;  225: movq    %rsi, %r10
;;       movq    %r11, %rsi
;;       callq   0x6c6
;;       movq    %r10, %rsi
;;       subq    $0x150, %rsp
;;       movq    %rbx, 0x120(%rsp)
;;       movq    %r12, 0x128(%rsp)
;;       movq    %r13, 0x130(%rsp)
;;       movq    %r14, 0x138(%rsp)
;;       movq    %r15, 0x140(%rsp)
;;       movq    0x38(%rdi), %rax
;;       movl    %edx, %edx
;;       movq    8(%rax, %rdx), %rcx
;;       movq    %rcx, 0x118(%rsp)
;;       movq    0x10(%rax, %rdx), %rsi
;;       movq    0x18(%rax, %rdx), %rdi
;;       movq    0x20(%rax, %rdx), %r8
;;       movq    0x28(%rax, %rdx), %r9
;;       movq    0x30(%rax, %rdx), %r10
;;       movq    0x38(%rax, %rdx), %r11
;;       movq    0x40(%rax, %rdx), %rbx
;;       movq    0x48(%rax, %rdx), %r12
;;       movq    0x50(%rax, %rdx), %r13
;;       movq    0x58(%rax, %rdx), %r14
;;       movq    0x60(%rax, %rdx), %r15
;;       movq    0x68(%rax, %rdx), %rcx
;;       movq    %rcx, 0x110(%rsp)
;;       movq    0x70(%rax, %rdx), %rcx
;;       movq    %rcx, 0x108(%rsp)
;;       movq    0x78(%rax, %rdx), %rcx
;;       movq    %rcx, 0x100(%rsp)
;;       movq    0x80(%rax, %rdx), %rcx
;;       movq    %rcx, 0xf8(%rsp)
;;       movq    0x88(%rax, %rdx), %rcx
;;       movq    %rcx, 0xf0(%rsp)
;;       movq    0x90(%rax, %rdx), %rcx
;;       movq    %rcx, 0xe8(%rsp)
;;       movq    0x98(%rax, %rdx), %rcx
;;       movq    %rcx, 0xe0(%rsp)
;;       movq    0xa0(%rax, %rdx), %rcx
;;       movq    %rcx, 0xd8(%rsp)
;;       movq    0xa8(%rax, %rdx), %rcx
;;       movq    %rcx, 0xd0(%rsp)
;;       movq    0xb0(%rax, %rdx), %rcx
;;       movq    %rcx, 0xc8(%rsp)
;;       movq    0xb8(%rax, %rdx), %rcx
;;       movq    %rcx, 0xc0(%rsp)
;;       movq    0xc0(%rax, %rdx), %rcx
;;       movq    %rcx, 0xb8(%rsp)
;;       movq    0xc8(%rax, %rdx), %rcx
;;       movq    %rcx, 0xb0(%rsp)
;;       movq    0xd0(%rax, %rdx), %rcx
;;       movq    %rcx, 0xa8(%rsp)
;;       movq    0xd8(%rax, %rdx), %rcx
;;       movq    %rcx, 0xa0(%rsp)
;;       movq    0xe0(%rax, %rdx), %rcx
;;       movq    %rcx, 0x98(%rsp)
;;       movq    0xe8(%rax, %rdx), %rcx
;;       movq    %rcx, 0x90(%rsp)
;;       movq    0xf0(%rax, %rdx), %rcx
;;       movq    %rcx, 0x88(%rsp)
;;       movq    0xf8(%rax, %rdx), %rcx
;;       movq    %rcx, 0x80(%rsp)
;;       movq    0x100(%rax, %rdx), %rcx
;;       movq    %rcx, 0x78(%rsp)
;;       movq    0x108(%rax, %rdx), %rcx
;;       movq    %rcx, 0x70(%rsp)
;;       movq    0x110(%rax, %rdx), %rcx
;;       movq    %rcx, 0x68(%rsp)
;;       movq    0x118(%rax, %rdx), %rcx
;;       movq    %rcx, 0x60(%rsp)
;;       movq    0x120(%rax, %rdx), %rcx
;;       movq    %rcx, 0x58(%rsp)
;;       movq    0x128(%rax, %rdx), %rcx
;;       movq    %rcx, 0x50(%rsp)
;;       movq    0x130(%rax, %rdx), %rcx
;;       movq    %rcx, 0x48(%rsp)
;;       movq    0x138(%rax, %rdx), %rcx
;;       movq    %rcx, 0x40(%rsp)
;;       movq    0x140(%rax, %rdx), %rcx
;;       movq    %rcx, 0x38(%rsp)
;;       movq    0x148(%rax, %rdx), %rcx
;;       movq    %rcx, 0x30(%rsp)
;;       movq    0x150(%rax, %rdx), %rcx
;;       movq    %rcx, 0x28(%rsp)
;;       movq    0x158(%rax, %rdx), %rcx
;;       movq    %rcx, 0x20(%rsp)
;;       movq    0x160(%rax, %rdx), %rcx
;;       movq    %rcx, 0x18(%rsp)
;;       movq    0x168(%rax, %rdx), %rcx
;;       movq    %rcx, 0x10(%rsp)
;;       movq    0x170(%rax, %rdx), %rcx
;;       movq    %rcx, 8(%rsp)
;;       movq    0x178(%rax, %rdx), %rcx
;;       movq    %rcx, (%rsp)
;;       movq    0x180(%rax, %rdx), %rax
;;       movq    0x118(%rsp), %rcx
;;       addq    %rsi, %rcx
;;       addq    %rdi, %rcx
;;       addq    %r8, %rcx
;;       addq    %r9, %rcx
;;       addq    %r10, %rcx
;;       addq    %r11, %rcx
;;       addq    %rbx, %rcx
;;       addq    %r12, %rcx
;;       addq    %r13, %rcx
;;       addq    %r14, %rcx
;;       addq    %r15, %rcx
;;       movq    0x110(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x108(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x100(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xf8(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xf0(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xe8(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xe0(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xd8(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xd0(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xc8(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xc0(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xb8(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0xb0(%rsp), %r9
;;       addq    %r9, %rcx
;;       movq    0xa8(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0xa0(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x98(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x90(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x88(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x80(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x78(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x70(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x68(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x60(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x58(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x50(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x48(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x40(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x38(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x30(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x28(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x20(%rsp), %rdx
;;       addq    %rdx, %rcx
;;       movq    0x18(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    0x10(%rsp), %rsi
;;       addq    %rsi, %rcx
;;       movq    8(%rsp), %r9
;;       addq    %r9, %rcx
;;       movq    (%rsp), %rdx
;;       addq    %rdx, %rcx
;;       addq    %rcx, %rax
;;       movq    0x120(%rsp), %rbx
;;       movq    0x128(%rsp), %r12
;;       movq    0x130(%rsp), %r13
;;       movq    0x138(%rsp), %r14
;;       movq    0x140(%rsp), %r15
;;       addq    $0x150, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
