// RUN: %clang %cflags -march=armv8.3-a %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pacret %t.exe 2>&1 | FileCheck %s

// Test that system instructions are assumed to impact trusted registers.

        .text

        .globl  with_hint
        .type   with_hint,@function
with_hint:
// CHECK: non-protected ret found in function with_hint
        hint    #0x7f
        ret
        .size   with_hint, .-with_hint

        .globl  with_svc
        .type   with_svc,@function
with_svc:
// CHECK: non-protected ret found in function with_svc
        svc     #0xffff
        ret
        .size   with_svc, .-with_svc
