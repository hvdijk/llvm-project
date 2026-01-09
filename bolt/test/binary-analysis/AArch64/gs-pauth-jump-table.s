// RUN: %clang %cflags -march=armv8.3-a %s -o %t.exe
// RUN: llvm-bolt-binary-analysis --scanners=pauth                         %t.exe 2>&1 | FileCheck %s

	.text

	.globl	f
	.type	f,@function
f:
	ret
	.size	f, .-f

	.globl	g
	.type	g,@function
g:
	ret
	.size	g, .-g

	.globl	h
	.type	h,@function
h:
	ret
	.size	h, .-h

	.globl	i
	.type	i,@function
i:
	ret
	.size	i, .-i

	.globl	jumptable
	.type	jumptable,@function
jumptable:
	pacibsp
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp
	sub	w16, w0, #2
	cmp	w16, #65
	b.hi	.Li
	cmp	x16, #65
	csel	x16, x16, xzr, ls
	adrp	x17, .Ljt
	add	x17, x17, :lo12:.Ljt
	ldrsw	x16, [x17, x16, lsl #2]
.Lanchor:
	adr	x17, .Lanchor
	add	x16, x17, x16
// CHECK-NOT: non-protected call found in function jumptable
	br	x16
.Lf:
	bl	f
	lsl	w0, w0, #1
	ldp	x29, x30, [sp], #16
	autibsp
	ret
.Lg:
	bl	g
	add	w0, w0, w0, lsl #1
	ldp	x29, x30, [sp], #16
	autibsp
	ret
.Lh:
	bl	h
	add	w0, w0, w0, lsl #2
	ldp	x29, x30, [sp], #16
	autibsp
	ret
.Li:
	bl	i
	lsl	w8, w0, #3
	sub	w0, w8, w0
	ldp	x29, x30, [sp], #16
	autibsp
	ret
	.size	jumptable, .-jumptable

	.section	.rodata,"a",@progbits
	.p2align	2, 0x0
.Ljt:
	.word	.Lf-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lf-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lg-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lh-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lh-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lh-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Li-.Lanchor
	.word	.Lh-.Lanchor

	# Past the end of the jump table; make sure we do not interpret this as an offset.
	.word	0

	.text
        .globl  main
        .type   main,@function
main:
        mov x0, 0
        ret
        .size   main, .-main
