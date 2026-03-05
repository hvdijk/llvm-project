; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy  --dump-section=DXIL=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 1
; CHECK: DIExpression: 1
; CHECK: DIFile: 1
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubrange: 1
; CHECK: DISubroutineType: 1



declare void @llvm.dbg.value(metadata, metadata, metadata)

define i32 @func(ptr %0) !dbg !3 {
  call void @llvm.dbg.value(metadata ptr %0, metadata !6, metadata !DIExpression()), !dbg !10
  ret i32 0
}

!llvm.module.flags = !{!0}
!llvm.dbg.cu = !{!1}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C11, file: !2, producer: "clang", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!2 = !DIFile(filename: "file.c", directory: "/")
!3 = distinct !DISubprogram(name: "func", scope: !2, file: !2, line: 46, type: !4, scopeLine: 48, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !1)
!4 = distinct !DISubroutineType(types: !5)
!5 = !{}
!6 = !DILocalVariable(name: "op", arg: 5, scope: !3, file: !2, line: 47, type: !7)
!7 = !DICompositeType(tag: DW_TAG_array_type, size: 2624, elements: !8)
!8 = !{!9}
!9 = !DISubrange(count: 41)
!10 = !DILocation(line: 0, scope: !3)
