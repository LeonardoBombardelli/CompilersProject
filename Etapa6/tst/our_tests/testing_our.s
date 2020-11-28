	.file	""
	.text
	.globl	foo
	.type	foo, @function
foo:
	pushq	%rsp
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movl	$4, %eax
	movl	%eax, -12(%rbp)
	movq	%rbp, %rsp
	popq	%rbp
	popq	%rsp
	ret
	movq	%rbp, %rsp
	popq	%rbp
	popq	%rsp
	ret
	.globl	main
	.type	main, @function
main:
	pushq	%rsp
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	subq	$4, %rsp
	subq	$4, %rsp
	movl	$4, %eax
	movl	%eax, -20(%rbp)
	movl	$5, %eax
	movl	$12, %ebx
	movl	-20(%rbp), %ecx
	imul	%ecx, %ebx
	addl	%ebx, %eax
	movl	%eax, -16(%rbp)
	movl	-16(%rbp), %eax
	movl	$53, %ebx
	cmp	%eax, %ebx
	je	L3
	jne	L2
L2:
	movl	$1, %ecx
	movl	$2, %edi
	cmp	%ecx, %edi
	je	L1
	jne	L4
L1:
	movl	-16(%rbp), %edx
	movl	$4, %esi
	cmp	%edx, %esi
	jl	L4
	jge	L4
L3:
	movl	$90, %r10d
	movl	%r10d, -16(%rbp)
L4:
	movl	-16(%rbp), %r10d
	movl	$1, %r11d
	addl	%r11d, %r10d
	movl	%r10d, -16(%rbp)
	movl	-16(%rbp), %r10d
	movl	%r10d, -12(%rbp)
	movl	-12(%rbp), %eax
	movq	%rbp, %rsp
	popq	%rbp
	popq	%rsp
	ret
	movl	-12(%rbp), %eax
	movq	%rbp, %rsp
	popq	%rbp
	popq	%rsp
	ret
