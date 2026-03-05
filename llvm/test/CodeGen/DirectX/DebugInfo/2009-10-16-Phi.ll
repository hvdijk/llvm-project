; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy  --dump-section=DXIL=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat





define i32 @foo() {
E:
   br label %B2
B1:
   br label %B2
B2:
   %0 = phi i32 [ 0, %E ], [ 1, %B1 ], !dbg !0
   ret i32 %0
}

!0 = !{i32 42}
