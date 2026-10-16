;;! target = "riscv64"
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
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       addiw   a0, a2, 1
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
;;
;; wasm[0]::function[1]::spin:
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       ld      t6, 8(a0)
;;       ld      t6, 0x90(t6)
;;       addi    t6, t6, 0x10
;;       bgeu    sp, t6, 8
;;       .byte   0x00, 0x00, 0x00, 0x00
;;       ld      a1, 0x10(tp)
;;       mv      a3, sp
;;       bltu    a3, a1, 0x1c
;;       addiw   a2, a2, -1
;;       bnez    a2, -0x10
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
;;       mv      a1, sp
;;       auipc   ra, 0
;;       jalr    ra, ra, 0x170
;;       j       -0x24
;;
;; wasm[0]::function[2]::caller:
;;       addi    sp, sp, -0x10
;;       sd      ra, 8(sp)
;;       sd      s0, 0(sp)
;;       mv      s0, sp
;;       ld      a1, 0x10(tp)
;;       mv      a3, sp
;;       bltu    a3, a1, 0x24
;;       mv      a1, a0
;;       mv      a0, a1
;;       auipc   ra, 0
;;       jalr    ra, ra, -0xa0
;;       ld      ra, 8(sp)
;;       ld      s0, 0(sp)
;;       addi    sp, sp, 0x10
;;       ret
;;       mv      a1, sp
;;       auipc   ra, 0
;;       jalr    ra, ra, 0x124
;;       mv      a1, a0
;;       j       -0x2c
