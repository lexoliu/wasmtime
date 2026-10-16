;;! target = "x86_64"
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
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       leal    1(%rdx), %eax
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;
;; wasm[0]::function[1]::spin:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x90(%r10), %r10
;;       addq    $0x30, %r10
;;       cmpq    %rsp, %r10
;;       ja      0xb2
;;   3c: subq    $0x20, %rsp
;;       movq    %r12, (%rsp)
;;       movq    %r13, 8(%rsp)
;;       movq    %r14, 0x10(%rsp)
;;       movq    %r15, 0x18(%rsp)
;;       movq    %rdx, %r14
;;       movq    8(%rdi), %r13
;;       movq    %rdi, %r15
;;       movq    %rsp, %r12
;;       movq    0x18(%r13), %r9
;;       cmpq    %r9, %r12
;;       jb      0x9f
;;   6d: movq    %r14, %rdx
;;       subl    $1, %edx
;;       testl   %edx, %edx
;;       je      0x83
;;   7b: movq    %rdx, %r14
;;       jmp     0x60
;;   83: movq    (%rsp), %r12
;;       movq    8(%rsp), %r13
;;       movq    0x10(%rsp), %r14
;;       movq    0x18(%rsp), %r15
;;       addq    $0x20, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   9f: movq    %r12, %rsi
;;   a2: movq    %r15, %rdi
;;   a5: callq   0x1ef
;;   aa: movq    %r14, %rdx
;;   ad: jmp     0x70
;;   b2: ud2
;;
;; wasm[0]::function[2]::caller:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x10, %rsp
;;       movq    %r12, (%rsp)
;;       movq    %r13, 8(%rsp)
;;       movq    %rdx, %r12
;;       movq    8(%rdi), %r8
;;       movq    %rdi, %r13
;;       movq    0x18(%r8), %rdi
;;       movq    %rsp, %rsi
;;       cmpq    %rdi, %rsi
;;       jb      0x10b
;;   eb: movq    %r12, %rdx
;;       movq    %r13, %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    (%rsp), %r12
;;       movq    8(%rsp), %r13
;;       addq    $0x10, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;  10b: movq    %r13, %rdi
;;  10e: callq   0x1ef
;;  113: movq    %r12, %rdx
;;  116: movq    %r13, %rsi
;;  119: jmp     0xf1
