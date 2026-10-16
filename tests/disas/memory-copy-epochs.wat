;;! target = 'x86_64'
;;! test = 'optimize'
;;! flags = '-Wepoch-interruption'

(module
  (memory 1)
  (func $copy (param i32 i32 i32)
    (memory.copy (local.get 0) (local.get 1) (local.get 2))
  )
)
;; function u0:0(i64 vmctx, i64, i32, i32, i32) tail {
;;     region0 = 8 "VMContext+0x8"
;;     region1 = 67108888 "VMStoreContext+0x18"
;;     region2 = 24 "VMContext+0x18"
;;     region3 = 1744830464 "EpochCounter+0x0"
;;     region4 = 67108872 "VMStoreContext+0x8"
;;     region5 = 603979776 "VMMemoryDefinition+0x0"
;;     region6 = 603979784 "VMMemoryDefinition+0x8"
;;     gv0 = vmctx
;;     gv1 = load.i64 notrap aligned readonly can_move region0 gv0+8
;;     gv2 = load.i64 notrap aligned region1 gv1+24
;;     sig0 = (i64 vmctx) -> i64 tail
;;     sig1 = (i64 vmctx, i64, i64, i64) -> i8 tail
;;     fn0 = colocated u805306368:13 sig0
;;     fn1 = colocated u805306368:1 sig1
;;     stack_limit = gv2
;;
;;                                 block0(v0: i64, v1: i64, v2: i32, v3: i32, v4: i32):
;; @001e                               v5 = load.i64 notrap aligned region2 v0+24
;; @001e                               v6 = load.i64 notrap aligned region3 v5
;; @001e                               v7 = load.i64 notrap aligned readonly can_move region0 v0+8
;; @001e                               v8 = load.i64 notrap aligned region4 v7+8
;; @001e                               v9 = icmp uge v6, v8
;; @001e                               brif v9, block3, block2(v8)
;;
;;                                 block3 cold:
;; @001e                               v10 = call fn0(v0)
;; @001e                               jump block2(v10)
;;
;;                                 block2(v60: i64):
;; @0025                               v14 = load.i64 notrap aligned region6 v0+64
;; @0025                               v15 = uextend.i64 v2
;; @0025                               v16 = uextend.i64 v4
;; @0025                               v19 = iadd v15, v16
;; @0025                               v20 = icmp ugt v19, v14
;; @0025                               trapnz v20, heap_oob
;; @0025                               v27 = uextend.i64 v3
;; @0025                               v31 = iadd v27, v16
;; @0025                               v32 = icmp ugt v31, v14
;; @0025                               trapnz v32, heap_oob
;; @0025                               v21 = load.i64 notrap aligned readonly can_move region5 v0+56
;; @0025                               v37 = iadd v21, v27
;; @0025                               v25 = iadd v21, v15
;; @0025                               v40 = icmp ugt v37, v25
;; @0025                               brif v40, block6, block7
;;
;;                                 block4(v42: i64, v43: i64, v44: i64, v47: i64):
;; @0025                               v46 = load.i64 notrap aligned region3 v5
;; @0025                               v48 = icmp uge v46, v47
;; @0025                               brif v48, block9, block8(v47)
;;
;;                                 block5(v88: i64, v89: i64, v90: i64, v94: i64):
;; @0025                               v93 = load.i64 notrap aligned region3 v5
;; @0025                               v96 = icmp uge v93, v94
;; @0025                               brif v96, block17, block16
;;
;;                                 block6:
;;                                     v111 = iconst.i64 0x0800_0000
;;                                     v112 = icmp.i64 ugt v16, v111  ; v111 = 0x0800_0000
;; @0025                               brif v112, block4(v25, v37, v16, v60), block5(v25, v37, v16, v60)
;;
;;                                 block9 cold:
;; @0025                               v50 = load.i64 notrap aligned region4 v7+8
;; @0025                               v51 = icmp.i64 uge v46, v50
;; @0025                               brif v51, block10, block8(v50)
;;
;;                                 block10 cold:
;; @0025                               v52 = call fn0(v0)
;; @0025                               jump block8(v52)
;;
;;                                 block8(v61: i64):
;; @0025                               v53 = call fn1(v0, v42, v43, v111)  ; v111 = 0x0800_0000
;; @0025                               v56 = isub.i64 v44, v111  ; v111 = 0x0800_0000
;; @0025                               v57 = icmp ugt v56, v111  ; v111 = 0x0800_0000
;; @0025                               v54 = iadd.i64 v42, v111  ; v111 = 0x0800_0000
;; @0025                               v55 = iadd.i64 v43, v111  ; v111 = 0x0800_0000
;; @0025                               brif v57, block4(v54, v55, v56, v61), block5(v54, v55, v56, v61)
;;
;;                                 block7:
;; @0025                               v39 = iconst.i64 0x0800_0000
;; @0025                               v64 = icmp.i64 ugt v16, v39  ; v39 = 0x0800_0000
;; @0025                               v62 = iadd.i64 v25, v16
;; @0025                               v63 = iadd.i64 v37, v16
;; @0025                               brif v64, block11(v62, v63, v16, v60), block12(v62, v63, v16, v60)
;;
;;                                 block11(v65: i64, v66: i64, v67: i64, v72: i64):
;; @0025                               v71 = load.i64 notrap aligned region3 v5
;; @0025                               v73 = icmp uge v71, v72
;; @0025                               brif v73, block14, block13(v72)
;;
;;                                 block14 cold:
;; @0025                               v75 = load.i64 notrap aligned region4 v7+8
;; @0025                               v76 = icmp.i64 uge v71, v75
;; @0025                               brif v76, block15, block13(v75)
;;
;;                                 block15 cold:
;; @0025                               v77 = call fn0(v0)
;; @0025                               jump block13(v77)
;;
;;                                 block13(v82: i64):
;;                                     v106 = iconst.i64 0x0800_0000
;;                                     v107 = isub.i64 v65, v106  ; v106 = 0x0800_0000
;;                                     v108 = isub.i64 v66, v106  ; v106 = 0x0800_0000
;; @0025                               v78 = call fn1(v0, v107, v108, v106)  ; v106 = 0x0800_0000
;;                                     v109 = isub.i64 v67, v106  ; v106 = 0x0800_0000
;;                                     v110 = icmp ugt v109, v106  ; v106 = 0x0800_0000
;; @0025                               brif v110, block11(v107, v108, v109, v82), block12(v107, v108, v109, v82)
;;
;;                                 block12(v83: i64, v84: i64, v85: i64, v95: i64):
;; @0025                               v86 = isub v83, v85
;; @0025                               v87 = isub v84, v85
;; @0025                               jump block5(v86, v87, v85, v95)
;;
;;                                 block17 cold:
;; @0025                               v98 = load.i64 notrap aligned region4 v7+8
;; @0025                               v99 = icmp.i64 uge v93, v98
;; @0025                               brif v99, block18, block16
;;
;;                                 block18 cold:
;; @0025                               v100 = call fn0(v0)
;; @0025                               jump block16
;;
;;                                 block16:
;; @0025                               v101 = call fn1(v0, v88, v89, v90)
;; @0029                               jump block1
;;
;;                                 block1:
;; @0029                               return
;; }
