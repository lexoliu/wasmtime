;;! target = "x86_64-unknown-linux-gnu"
;;! test = "compile"
;;! flags = "-Ccompiler=cranelift -Ccranelift-has_sse41=false  -Osignals-based-traps=n"

(module
  (func (export "i32.trunc_f32_u") (param f32) (result i32)
    (i32.trunc_f32_u (local.get 0))
  )
)
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movq    %rbx, 0x10(%rsp)
;;       movdqu  %xmm0, (%rsp)
;;       movq    8(%rdi), %rax
;;       movq    %rdi, %rbx
;;       movq    %rsp, %rcx
;;       cmpq    0x18(%rax), %rcx
;;       jb      0x10a
;;   26: xorpd   %xmm0, %xmm0
;;       movdqu  (%rsp), %xmm1
;;       cvtss2sd %xmm1, %xmm0
;;       ucomisd %xmm0, %xmm0
;;       jp      0xf3
;;       jne     0xf3
;;   43: movq    %rbx, %rdi
;;       callq   0x257
;;       movabsq $13830554455654793216, %rax
;;       movq    %rax, %xmm1
;;       ucomisd %xmm0, %xmm1
;;       jae     0xdc
;;   64: ucomisd 0xc4(%rip), %xmm0
;;       jae     0xc5
;;   72: movdqu  (%rsp), %xmm2
;;       movl    $0x4f000000, %ecx
;;       movd    %ecx, %xmm1
;;       ucomiss %xmm1, %xmm2
;;       jae     0x9e
;;       jp      0x11e
;;   8f: cvttss2si %xmm2, %eax
;;       cmpl    $0, %eax
;;       jge     0xb7
;;   9c: ud2
;;       movaps  %xmm2, %xmm0
;;       subss   %xmm1, %xmm0
;;       cvttss2si %xmm0, %eax
;;       cmpl    $0, %eax
;;       jl      0x120
;;   b2: addl    $0x80000000, %eax
;;       movq    0x10(%rsp), %rbx
;;       addq    $0x20, %rsp
;;       movq    %rbp, %rsp
;;       popq    %rbp
;;       retq
;;   c5: movl    $6, %esi
;;   ca: movq    %rbx, %rdi
;;   cd: callq   0x284
;;   d2: movq    %rbx, %rdi
;;   d5: callq   0x2b5
;;   da: ud2
;;   dc: movl    $6, %esi
;;   e1: movq    %rbx, %rdi
;;   e4: callq   0x284
;;   e9: movq    %rbx, %rdi
;;   ec: callq   0x2b5
;;   f1: ud2
;;   f3: movl    $8, %esi
;;   f8: movq    %rbx, %rdi
;;   fb: callq   0x284
;;  100: movq    %rbx, %rdi
;;  103: callq   0x2b5
;;  108: ud2
;;  10a: xorl    %esi, %esi
;;  10c: movq    %rbx, %rdi
;;  10f: callq   0x284
;;  114: movq    %rbx, %rdi
;;  117: callq   0x2b5
;;  11c: ud2
;;  11e: ud2
;;  120: ud2
;;  122: addb    %al, (%rax)
;;  124: addb    %al, (%rax)
;;  126: addb    %al, (%rax)
;;  128: addb    %al, (%rax)
;;  12a: addb    %al, (%rax)
;;  12c: addb    %al, (%rax)
;;  12e: addb    %al, (%rax)
;;  130: addb    %al, (%rax)
;;  132: addb    %al, (%rax)
;;  134: addb    %al, (%rax)
;;  136: lock addb %al, (%r8)
;;  13a: addb    %al, (%rax)
;;  13c: addb    %al, (%rax)
;;  13e: addb    %al, (%rax)
