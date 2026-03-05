; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy  --dump-section=DXIL=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DISubprogram: 1


; Make sure we emit this diagnostic only once (which means we don't visit the
; same DISubprogram twice.

define void @tinkywinky() !dbg !3 { ret void }

!llvm.module.flags = !{!4}
!llvm.dbg.cu = !{!0}
!0 = distinct !DICompileUnit(language: 12, file: !1)
!1 = !DIFile(filename: "/home/davide", directory: "/home/davide")
!3 = distinct !DISubprogram(name: "patatino", isDefinition: true)
!4 = !{i32 2, !"Debug Info Version", i32 3}
