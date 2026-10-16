;;! target = "x86_64"
;;! test = "compile"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=processor:16"]

;; With the stack limit in the executing processor's local block, every
;; resumable check reads it through the thread pointer, with no load of the
;; store context. `$leaf` still has no check, `$spin` checks at its loop
;; header, and `$caller` at entry.
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
;;       ja      0x68
;;   3c: cmpq    %fs:0x10, %rsp
;;       jb      0x5b
;;   4b: subl    $1, %edx
;;       testl   %edx, %edx
;;       jne     0x3c
;;   56: movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   5b: movq    %rsp, %rsi
;;   5e: callq   0x184
;;   63: jmp     0x4b
;;   68: ud2
;;
;; wasm[0]::function[2]::caller:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       cmpq    %fs:0x10, %rsp
;;       jb      0xa3
;;   93: movq    %rdi, %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   a3: movq    %rsp, %rsi
;;   a6: callq   0x184
;;   ab: movq    %rdi, %rsi
;;   ae: jmp     0x96
