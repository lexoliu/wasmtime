;;! target = "x86_64"
;;! test = "winch"
;;! flags = ["-Wstack-limit-interruption=y", "-Wstack-limit-location=processor:16"]

;; Winch reads the per-processor stack limit through the thread pointer at
;; function entry and at loop headers.
(module
  (func $spin (param i32)
    (loop $l
      (br_if $l (local.tee 0 (i32.sub (local.get 0) (i32.const 1)))))))
;; wasm[0]::function[0]::spin:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r11
;;       movq    0x90(%r11), %r11
;;       addq    $0x30, %r11
;;       cmpq    %rsp, %r11
;;       ja      0xcf
;;   1f: movq    %rdi, %r14
;;       subq    $0x20, %rsp
;;       movq    %rdi, 0x18(%rsp)
;;       movq    %rsi, 0x10(%rsp)
;;       movl    %edx, 0xc(%rsp)
;;       movq    %fs:0x10, %rcx
;;       movq    %rsp, %rdx
;;       cmpq    %rcx, %rdx
;;       jae     0x74
;;   4c: pushq   %rdx
;;       subq    $8, %rsp
;;       movq    %r14, %rdi
;;       movq    8(%rsp), %rsi
;;       callq   0x12e
;;       addq    $8, %rsp
;;       addq    $8, %rsp
;;       movq    0x18(%rsp), %r14
;;       movq    %fs:0x10, %rcx
;;       movq    %rsp, %rdx
;;       cmpq    %rcx, %rdx
;;       jae     0xb1
;;   89: pushq   %rdx
;;       subq    $8, %rsp
;;       movq    %r14, %rdi
;;       movq    8(%rsp), %rsi
;;       callq   0x12e
;;       addq    $8, %rsp
;;       addq    $8, %rsp
;;       movq    0x18(%rsp), %r14
;;       movl    0xc(%rsp), %eax
;;       subl    $1, %eax
;;       movl    %eax, 0xc(%rsp)
;;       testl   %eax, %eax
;;       jne     0x74
;;   c6: addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   cf: ud2
