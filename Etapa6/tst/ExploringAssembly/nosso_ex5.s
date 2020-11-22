	.file	""
	.text
	.globl	foo
	.type	foo, @function
foo:
	pushq	%rbp
	movq	%rsp, %rbp
	subq 	$20, %rsp
	movl	$2, %eax
	imul	-16(%rbp), %eax
	movl	%eax, -12(%rbp)
	movq	%rbp, %rsp
	popq	%rbp
	ret
	.size	foo, .-foo
	.globl	main
	.type	main, @function
main:
	pushq	%rsp
	pushq	%rbp
	movq	%rsp, %rbp
	subq 	$16, %rsp
	subq 	$4, %rsp
	movq	$5, -16(%rsp)
	call	foo
	movl	-12(%rsp), %eax
	movl	%eax, -16(%rbp)
	movq	%rbp, %rsp
	popq	%rbp
	subq	$8, %rsp
	ret
	.size	main, .-main
	.ident	""
	.section	.note.GNU-stack,"",@progbits
