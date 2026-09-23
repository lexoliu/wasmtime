.intel_syntax noprefix
.text
.global _main
_main:
    pcmpeqd xmm0, xmm0
    mov rax, rsp
    xor ecx, ecx
    mov cx, ss
    push rcx
    push rax
    pushfq
    xor ecx, ecx
    mov cx, cs
    push rcx
    lea rax, [rip + returned]
    push rax
    jmp helios_x86_interrupt_timer
returned:
    pmovmskb eax, xmm0
    cmp eax, 65535
    setne al
    movzx eax, al
    ret

.global helios_x86_interrupt_dispatch
helios_x86_interrupt_dispatch:
    pxor xmm0, xmm0
    ret

.global helios_x86_exception_dispatch
helios_x86_exception_dispatch:
    ud2
