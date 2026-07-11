;;! target = 'riscv64'
;;! test = 'optimize'
;;! flags = '-Wgc'

;; RISC-V's G baseline does not include the V extension. A constant-length GC
;; array.copy must therefore remain inline but use scalar chunks instead of
;; emitting an i8x16 load/store that the backend cannot lower.
;;
;; Seven i32 elements are 28 bytes, which should decompose into three i64
;; chunks and one i32 chunk. Every load must precede every store to preserve
;; memmove semantics for overlapping arrays.

(module
  (type $a (array (mut i32)))

  (func $copy (param (ref $a) i32 (ref $a) i32)
    (array.copy $a $a
      (local.get 0) (local.get 1)
      (local.get 2) (local.get 3)
      (i32.const 7))
  )
)
;; function u0:0(i64 vmctx, i64, i32, i32, i32, i32) tail {
;;     region0 = 8 "VMContext+0x8"
;;     region1 = 67108888 "VMStoreContext+0x18"
;;     region2 = 67108896 "VMStoreContext+0x20"
;;     region3 = 67108904 "VMStoreContext+0x28"
;;     region4 = 536870912 "GcHeap"
;;     gv0 = vmctx
;;     gv1 = load.i64 notrap aligned readonly can_move region0 gv0+8
;;     gv2 = load.i64 notrap aligned region1 gv1+24
;;     stack_limit = gv2
;;
;;                                 block0(v0: i64, v1: i64, v2: i32, v3: i32, v4: i32, v5: i32):
;; @002a                               trapz v2, user16
;; @002a                               v8 = load.i64 notrap aligned readonly can_move region0 v0+8
;; @002a                               v9 = load.i64 notrap aligned readonly can_move region2 v8+32
;; @002a                               v7 = uextend.i64 v2
;; @002a                               v10 = iadd v9, v7
;; @002a                               v11 = iconst.i64 16
;; @002a                               v12 = iadd v10, v11  ; v11 = 16
;; @002a                               v13 = load.i32 user2 readonly region4 v12
;; @002a                               v15 = uextend.i64 v3
;;                                     v78 = iconst.i64 7
;; @002a                               v19 = iadd v15, v78  ; v78 = 7
;; @002a                               v14 = uextend.i64 v13
;; @002a                               v20 = icmp ugt v19, v14
;; @002a                               trapnz v20, user17
;; @002a                               trapz v4, user16
;; @002a                               v31 = uextend.i64 v4
;; @002a                               v34 = iadd v9, v31
;; @002a                               v36 = iadd v34, v11  ; v11 = 16
;; @002a                               v37 = load.i32 user2 readonly region4 v36
;; @002a                               v39 = uextend.i64 v5
;; @002a                               v43 = iadd v39, v78  ; v78 = 7
;; @002a                               v38 = uextend.i64 v37
;; @002a                               v44 = icmp ugt v43, v38
;; @002a                               trapnz v44, user17
;; @002a                               v63 = load.i64 notrap aligned region3 v8+40
;; @002a                               v25 = iconst.i64 20
;; @002a                               v26 = iadd v10, v25  ; v25 = 20
;;                                     v86 = iconst.i64 2
;;                                     v87 = ishl v15, v86  ; v86 = 2
;; @002a                               v30 = iadd v26, v87
;;                                     v91 = iconst.i64 28
;; @002a                               v65 = uadd_overflow_trap v30, v91, user2  ; v91 = 28
;; @002a                               v64 = iadd v9, v63
;; @002a                               v66 = icmp ugt v65, v64
;; @002a                               trapnz v66, user2
;; @002a                               v50 = iadd v34, v25  ; v25 = 20
;;                                     v89 = ishl v39, v86  ; v86 = 2
;; @002a                               v54 = iadd v50, v89
;; @002a                               v72 = uadd_overflow_trap v54, v91, user2  ; v91 = 28
;; @002a                               v73 = icmp ugt v72, v64
;; @002a                               trapnz v73, user2
;; @002a                               v74 = load.i64 notrap aligned little region4 v54
;; @002a                               v75 = load.i64 notrap aligned little region4 v54+8
;; @002a                               v76 = load.i64 notrap aligned little region4 v54+16
;; @002a                               v77 = load.i32 notrap aligned little region4 v54+24
;; @002a                               store notrap aligned little region4 v74, v30
;; @002a                               store notrap aligned little region4 v75, v30+8
;; @002a                               store notrap aligned little region4 v76, v30+16
;; @002a                               store notrap aligned little region4 v77, v30+24
;; @002e                               jump block1
;;
;;                                 block1:
;; @002e                               return
;; }
