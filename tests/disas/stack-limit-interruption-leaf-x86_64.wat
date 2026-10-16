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
;;       addq    $0x10, %r10
;;       cmpq    %rsp, %r10
;;       ja      0x6a
;;   3c: movq    8(%rdi), %r8
;;       movq    %rsp, %rsi
;;       movq    0x18(%r8), %r9
;;       cmpq    %r9, %rsi
;;       jb      0x60
;;   50: subl    $1, %edx
;;       testl   %edx, %edx
;;       jne     0x43
;;   5b: movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   60: callq   0x186
;;   65: jmp     0x50
;;   6a: ud2
;;
;; wasm[0]::function[2]::caller:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %rsi
;;       movq    0x18(%rsi), %r8
;;       movq    %rsp, %rsi
;;       cmpq    %r8, %rsi
;;       jb      0xa8
;;   98: movq    %rdi, %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   a8: callq   0x186
;;   ad: movq    %rdi, %rsi
;;   b0: jmp     0x9b
