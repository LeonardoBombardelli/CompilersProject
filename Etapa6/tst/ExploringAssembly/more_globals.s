	.file	"more_globals.c"
	.text
	.globl	a
	.data
	.align 4
	.type	a, @object
	.size	a, 4
a:
	.long	3
	.globl	c
	.align 4
	.type	c, @object
	.size	c, 4
c:
	.long	5
	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	a(%rip), %eax
	movl	%eax, -4(%rbp)
	movl	$13, %eax
	popq	%rbp
	ret
	.size	main, .-main
	.ident	"GCC: (GNU) 10.2.0"
	.section	.note.GNU-stack,"",@progbits
