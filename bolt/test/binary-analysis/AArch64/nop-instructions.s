// RUN: %clang %cflags -march=armv8.3-a %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pacret %t.exe 2>&1 | FileCheck %s

// Test that nop instructions can be used with no impact on trusted registers.

        .text

        .globl  without_nop
        .type   without_nop,@function
without_nop:
// CHECK-NOT: without_nop
        ret
        .size   without_nop, .-without_nop

        .globl  with_nop
        .type   with_nop,@function
with_nop:
// CHECK-NOT: with_nop
        nop
        ret
        .size   with_nop, .-with_nop
