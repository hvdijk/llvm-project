; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy  --dump-section=DXIL=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIFlagAllCallsDescribed: 2
; CHECK: DIFlagLValueReference: 1
; CHECK: DIFlagRValueReference: 1
; CHECK: DIFlagTypePassByReference: 1
; CHECK: DIFlagTypePassByValue: 1
; CHECK: DISubprogram: 17


!llvm.module.flags = !{!2}
!llvm.dbg.cu = !{!0}
!0 = distinct !DICompileUnit(language: 0, file: !1)
!1 = !DIFile(filename: "-", directory: "")
!2 = !{i32 2, !"Debug Info Version", i32 3}

define void @invalid_file() !dbg !3 { ret void }
!3 = distinct !DISubprogram(file: !0)

define void @line_specified_with_no_file() !dbg !4 { ret void }
!4 = distinct !DISubprogram(line: 1)

define void @invalid_subroutine_type() !dbg !5 { ret void }
!5 = distinct !DISubprogram(type: !0)

define void @invalid_containing_type() !dbg !6 { ret void }
!6 = distinct !DISubprogram(containingType: !0)

define void @invalid_template_params() !dbg !7 { ret void }
!7 = distinct !DISubprogram(templateParams: !0)

define void @invalid_template_parameter() !dbg !8 { ret void }
!8 = distinct !DISubprogram(templateParams: !{!0})

define void @invalid_subprogram_declaration() !dbg !9 { ret void }
!9 = distinct !DISubprogram(declaration: !0)

define void @invalid_retained_nodes_list() !dbg !10 { ret void }
!10 = distinct !DISubprogram(retainedNodes: !0)

define void @invalid_retained_nodes_expected() !dbg !11 { ret void }
!11 = distinct !DISubprogram(retainedNodes: !{!0})

define void @invalid_reference_flags_reference() !dbg !12 { ret void }
!12 = distinct !DISubprogram(flags: DIFlagLValueReference | DIFlagRValueReference)

define void @invalid_reference_flags_pass_by() !dbg !13 { ret void }
!13 = distinct !DISubprogram(flags: DIFlagTypePassByValue | DIFlagTypePassByReference)

define void @subprogram_definitions_must_have_a_compile_unit() !dbg !14 { ret void }
!14 = distinct !DISubprogram()

define void @invalid_unit_type() !dbg !15 { ret void }
!15 = distinct !DISubprogram(unit: !{})

; FIXME: should something verify `isDefinition` is not a lie? is it meaningful
; to mistmatch it with respect to the LLVM IR function?
define void @subprogram_declarations_must_not_have_a_compile_unit() !dbg !16 { ret void }
!16 = distinct !DISubprogram(isDefinition: false, unit: !0)

define void @invalid_thrown_types_list() !dbg !17 { ret void }
!17 = distinct !DISubprogram(isDefinition: false, thrownTypes: !0)

define void @invalid_thrown_type() !dbg !18 { ret void }
!18 = distinct !DISubprogram(isDefinition: false, thrownTypes: !{!0})

define void @DIFlagAllCallsDescribed_must_be_attached_to_a_definition() !dbg !19 { ret void }
!19 = distinct !DISubprogram(isDefinition: false, flags: DIFlagAllCallsDescribed)

