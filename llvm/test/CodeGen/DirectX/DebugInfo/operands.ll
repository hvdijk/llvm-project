; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy  --dump-section=DXIL=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIAssignID: 1


;; Check that badly formed assignment tracking metadata is caught either
;; while parsing or by the verifier.


!1 = distinct !DIAssignID(0)
!1000 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
