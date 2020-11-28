	.file	"testing.ling"
	.text
	.globl	foo
	.type	foo, @function
foo:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$4, %eax
	popq	%rbp
	ret
	.size	foo, .-foo
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$4, -4(%rbp)
	movl	-4(%rbp), %edx
	movl	%edx, %eax
	addl	%eax, %eax
	addl	%edx, %eax
	sall	$2, %eax
	addl	$5, %eax
	movl	%eax, -8(%rbp)
	cmpl	$53, -8(%rbp)
	jne	.L4
	movl	$90, -8(%rbp)
.L4:
	addl	$1, -8(%rbp)
	movl	-8(%rbp), %eax
	popq	%rbp
	ret
	.size	main, .-main
	.ident	"GCC: (GNU) 10.2.0"
	.section	.note.GNU-stack,"",@progbits
