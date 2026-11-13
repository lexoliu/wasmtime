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
;;       ja      0x88
;;   5c: cmpq    %fs:0x10, %rsp
;;       jb      0x7b
;;   6b: subl    $1, %edx
;;       testl   %edx, %edx
;;       jne     0x5c
;;   76: movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   7b: movq    %rsp, %rsi
;;   7e: callq   0x1c4
;;   83: jmp     0x6b
;;   88: ud2
;;
;; wasm[0]::function[2]::caller:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       cmpq    %fs:0x10, %rsp
;;       jb      0xe3
;;   d3: movq    %rdi, %rsi
;;       movq    %rsi, %rdi
;;       callq   0
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   e3: movq    %rsp, %rsi
;;   e6: callq   0x1c4
;;   eb: movq    %rdi, %rsi
;;   ee: jmp     0xd6
