;;! target = "x86_64-unknown-linux-gnu"
;;! test = "compile"
;;! flags = "-Ccompiler=cranelift -Ccranelift-has_sse41=false  -Osignals-based-traps=n"

(module
  (func (export "i64.trunc_f64_u") (param f64) (result i64)
    (i64.trunc_f64_u (local.get 0))
  )
)
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movq    %rbx, 0x10(%rsp)
;;       movq    8(%rdi), %rax
;;       movq    %rdi, %rbx
;;       movq    %rsp, %rcx
;;       cmpq    0x18(%rax), %rcx
;;       jb      0x115
;;   21: ucomisd %xmm0, %xmm0
;;       movdqu  %xmm0, (%rsp)
;;       jp      0xfe
;;       jne     0xfe
;;   36: movq    %rbx, %rdi
;;       movdqu  (%rsp), %xmm0
;;       callq   0x259
;;       movabsq $13830554455654793216, %rax
;;       movq    %rax, %xmm1
;;       ucomisd %xmm0, %xmm1
;;       jae     0xe7
;;   5c: ucomisd 0xcc(%rip), %xmm0
;;       jae     0xd0
;;   6a: movdqu  (%rsp), %xmm2
;;       movabsq $0x43e0000000000000, %rcx
;;       movq    %rcx, %xmm1
;;       ucomisd %xmm1, %xmm2
;;       jae     0x9f
;;       jp      0x129
;;   8e: cvttsd2si %xmm2, %rax
;;       cmpq    $0, %rax
;;       jge     0xc2
;;   9d: ud2
;;       movaps  %xmm2, %xmm0
;;       subsd   %xmm1, %xmm0
;;       cvttsd2si %xmm0, %rax
;;       cmpq    $0, %rax
;;       jl      0x12b
;;   b5: movabsq $9223372036854775808, %rcx
;;       addq    %rcx, %rax
;;       movq    0x10(%rsp), %rbx
;;       addq    $0x20, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   d0: movl    $6, %esi
;;   d5: movq    %rbx, %rdi
;;   d8: callq   0x286
;;   dd: movq    %rbx, %rdi
;;   e0: callq   0x2b7
;;   e5: ud2
;;   e7: movl    $6, %esi
;;   ec: movq    %rbx, %rdi
;;   ef: callq   0x286
;;   f4: movq    %rbx, %rdi
;;   f7: callq   0x2b7
;;   fc: ud2
;;   fe: movl    $8, %esi
;;  103: movq    %rbx, %rdi
;;  106: callq   0x286
;;  10b: movq    %rbx, %rdi
;;  10e: callq   0x2b7
;;  113: ud2
;;  115: xorl    %esi, %esi
;;  117: movq    %rbx, %rdi
;;  11a: callq   0x286
;;  11f: movq    %rbx, %rdi
;;  122: callq   0x2b7
;;  127: ud2
;;  129: ud2
;;  12b: ud2
;;  12d: addb    %al, (%rax)
;;  12f: addb    %al, (%rax)
;;  131: addb    %al, (%rax)
;;  133: addb    %al, (%rax)
;;  135: addb    %dh, %al
;;  137: addb    %al, (%r8)
;;  13a: addb    %al, (%rax)
;;  13c: addb    %al, (%rax)
;;  13e: addb    %al, (%rax)
