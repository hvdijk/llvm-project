// RUN: %clang %cflags -march=armv8.3-a -fuse-ld=lld -Wl,--emit-relocs -Wl,-z,relro %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pauth %t.exe 2>&1 | FileCheck -check-prefixes=RELRO %s
// RUN: %clang %cflags -march=armv8.3-a -fuse-ld=lld -Wl,--emit-relocs -Wl,-z,norelro %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pauth %t.exe 2>&1 | FileCheck -check-prefixes=NORELRO %s
// RUN: %clang %cflags -march=armv8.3-a -fuse-ld=lld -Wl,-z,relro %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pauth %t.exe 2>&1 | FileCheck -check-prefixes=RELRO %s
// RUN: %clang %cflags -march=armv8.3-a -fuse-ld=lld -Wl,-z,norelro %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pauth %t.exe 2>&1 | FileCheck -check-prefixes=NORELRO %s
        .text

// RELRO-NOT:getputs
// NORELRO:GS-PAUTH: signing oracle found in function getputs
        .globl  getputs
        .type   getputs,@function
getputs:
        adrp    x16, :got:puts
        ldr     x16, [x16, :got_lo12:puts]
        paciza  x16
        mov     x0, x16
        ret
        .size   getputs, .-getputs

        .globl  _start
        .type   _start,@function
_start:
        mov x0, 0
        ret
        .size   _start, .-_start
