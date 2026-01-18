
wl.ko:     formato del fichero elf64-x86-64


Desensamblado de la sección .text:

00000000001843c0 <wl_dpc_rxwork>:
  1843c0:	e8 00 00 00 00       	call   1843c5 <wl_dpc_rxwork+0x5>
  1843c5:	55                   	push   %rbp
  1843c6:	48 8b 7f 20          	mov    0x20(%rdi),%rdi
  1843ca:	48 89 e5             	mov    %rsp,%rbp
  1843cd:	e8 ae fd ff ff       	call   184180 <wl_dpc>
  1843d2:	5d                   	pop    %rbp
  1843d3:	31 ff                	xor    %edi,%edi
  1843d5:	e9 00 00 00 00       	jmp    1843da <wl_dpc_rxwork+0x1a>
  1843da:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

00000000001843e0 <__pfx_wl_isr>:
  1843e0:	90                   	nop
  1843e1:	90                   	nop
  1843e2:	90                   	nop
  1843e3:	90                   	nop
  1843e4:	90                   	nop
  1843e5:	90                   	nop
  1843e6:	90                   	nop
  1843e7:	90                   	nop
  1843e8:	90                   	nop
  1843e9:	90                   	nop
  1843ea:	90                   	nop
  1843eb:	90                   	nop
  1843ec:	90                   	nop
  1843ed:	90                   	nop
  1843ee:	90                   	nop
  1843ef:	90                   	nop

00000000001843f0 <wl_isr>:
  1843f0:	e8 00 00 00 00       	call   1843f5 <wl_isr+0x5>
  1843f5:	55                   	push   %rbp
  1843f6:	48 89 e5             	mov    %rsp,%rbp
  1843f9:	41 56                	push   %r14
  1843fb:	41 55                	push   %r13
  1843fd:	4c 8d 6e 44          	lea    0x44(%rsi),%r13
  184401:	41 54                	push   %r12
  184403:	4c 89 ef             	mov    %r13,%rdi
  184406:	49 89 f4             	mov    %rsi,%r12
  184409:	53                   	push   %rbx
  18440a:	48 83 ec 10          	sub    $0x10,%rsp
  18440e:	65 48 8b 04 25 28 00 	mov    %gs:0x28,%rax
  184415:	00 00 
  184417:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  18441b:	31 c0                	xor    %eax,%eax
  18441d:	c6 45 d7 00          	movb   $0x0,-0x29(%rbp)
  184421:	e8 00 00 00 00       	call   184426 <wl_isr+0x36>
  184426:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
  18442b:	48 8d 75 d7          	lea    -0x29(%rbp),%rsi
  18442f:	e8 00 00 00 00       	call   184434 <wl_isr+0x44>
  184434:	89 c3                	mov    %eax,%ebx
  184436:	84 c0                	test   %al,%al
  184438:	74 51                	je     18448b <wl_isr+0x9b>
  18443a:	44 0f b6 75 d7       	movzbl -0x29(%rbp),%r14d
  18443f:	41 80 fe 01          	cmp    $0x1,%r14b
  184443:	0f 87 00 00 00 00    	ja     184449 <wl_isr+0x59>
  184449:	41 83 e6 01          	and    $0x1,%r14d
  18444d:	74 3c                	je     18448b <wl_isr+0x9b>
  18444f:	45 0f b6 b4 24 d8 01 	movzbl 0x1d8(%r12),%r14d
  184456:	00 00 
  184458:	41 80 fe 01          	cmp    $0x1,%r14b
  18445c:	0f 87 00 00 00 00    	ja     184462 <wl_isr+0x72>
  184462:	41 83 e6 01          	and    $0x1,%r14d
  184466:	75 54                	jne    1844bc <wl_isr+0xcc>
  184468:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 18446f <wl_isr+0x7f>
  18446f:	49 8d 94 24 b0 01 00 	lea    0x1b0(%r12),%rdx
  184476:	00 
  184477:	bf 00 20 00 00       	mov    $0x2000,%edi
  18447c:	e8 00 00 00 00       	call   184481 <wl_isr+0x91>
  184481:	84 c0                	test   %al,%al
  184483:	74 06                	je     18448b <wl_isr+0x9b>
  184485:	f0 41 ff 44 24 60    	lock incl 0x60(%r12)
  18448b:	4c 89 ef             	mov    %r13,%rdi
  18448e:	e8 00 00 00 00       	call   184493 <wl_isr+0xa3>
  184493:	0f b6 c3             	movzbl %bl,%eax
  184496:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  18449a:	65 48 2b 14 25 28 00 	sub    %gs:0x28,%rdx
  1844a1:	00 00 
  1844a3:	75 2d                	jne    1844d2 <wl_isr+0xe2>
  1844a5:	48 83 c4 10          	add    $0x10,%rsp
  1844a9:	5b                   	pop    %rbx
  1844aa:	41 5c                	pop    %r12
  1844ac:	41 5d                	pop    %r13
  1844ae:	41 5e                	pop    %r14
  1844b0:	5d                   	pop    %rbp
  1844b1:	31 d2                	xor    %edx,%edx
  1844b3:	31 f6                	xor    %esi,%esi
  1844b5:	31 ff                	xor    %edi,%edi
  1844b7:	e9 00 00 00 00       	jmp    1844bc <wl_isr+0xcc>
  1844bc:	49 8d 7c 24 70       	lea    0x70(%r12),%rdi
  1844c1:	f0 49 0f ba 6c 24 78 	lock btsq $0x0,0x78(%r12)
  1844c8:	00 
  1844c9:	72 c0                	jb     18448b <wl_isr+0x9b>
  1844cb:	e8 00 00 00 00       	call   1844d0 <wl_isr+0xe0>
  1844d0:	eb b9                	jmp    18448b <wl_isr+0x9b>
  1844d2:	e8 00 00 00 00       	call   1844d7 <wl_isr+0xe7>
  1844d7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  1844de:	00 00 

00000000001844e0 <__pfx_wl_start>:
  1844e0:	90                   	nop
  1844e1:	90                   	nop
  1844e2:	90                   	nop
  1844e3:	90                   	nop
  1844e4:	90                   	nop
  1844e5:	90                   	nop
  1844e6:	90                   	nop
  1844e7:	90                   	nop
  1844e8:	90                   	nop
  1844e9:	90                   	nop
  1844ea:	90                   	nop
  1844eb:	90                   	nop
  1844ec:	90                   	nop
  1844ed:	90                   	nop
  1844ee:	90                   	nop
  1844ef:	90                   	nop

00000000001844f0 <wl_start>:
  1844f0:	e8 00 00 00 00       	call   1844f5 <wl_start+0x5>
  1844f5:	48 85 f6             	test   %rsi,%rsi
  1844f8:	0f 84 6e 01 00 00    	je     18466c <wl_start+0x17c>
  1844fe:	55                   	push   %rbp
  1844ff:	48 89 e5             	mov    %rsp,%rbp
  184502:	41 56                	push   %r14
  184504:	41 55                	push   %r13
  184506:	41 54                	push   %r12
  184508:	49 89 fc             	mov    %rdi,%r12
  18450b:	53                   	push   %rbx
  18450c:	4c 8b b6 80 0a 00 00 	mov    0xa80(%rsi),%r14
  184513:	49 8b 5e 08          	mov    0x8(%r14),%rbx
  184517:	48 c7 47 08 00 00 00 	movq   $0x0,0x8(%rdi)
  18451e:	00 
  18451f:	44 0f b6 ab d8 01 00 	movzbl 0x1d8(%rbx),%r13d
  184526:	00 
  184527:	41 80 fd 01          	cmp    $0x1,%r13b
  18452b:	0f 87 00 00 00 00    	ja     184531 <wl_start+0x41>
  184531:	41 83 e5 01          	and    $0x1,%r13d
  184535:	0f 85 c0 00 00 00    	jne    1845fb <wl_start+0x10b>
  18453b:	4c 8d ab 44 01 00 00 	lea    0x144(%rbx),%r13
  184542:	4c 89 ef             	mov    %r13,%rdi
  184545:	e8 00 00 00 00       	call   18454a <wl_start+0x5a>
  18454a:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 184550 <wl_start+0x60>
  184550:	85 c0                	test   %eax,%eax
  184552:	7e 0c                	jle    184560 <wl_start+0x70>
  184554:	3b 83 58 01 00 00    	cmp    0x158(%rbx),%eax
  18455a:	0f 8e e2 00 00 00    	jle    184642 <wl_start+0x152>
  184560:	48 83 bb 48 01 00 00 	cmpq   $0x0,0x148(%rbx)
  184567:	00 
  184568:	0f 84 ae 00 00 00    	je     18461c <wl_start+0x12c>
  18456e:	48 8b 83 50 01 00 00 	mov    0x150(%rbx),%rax
  184575:	4c 89 60 08          	mov    %r12,0x8(%rax)
  184579:	4c 89 a3 50 01 00 00 	mov    %r12,0x150(%rbx)
  184580:	44 0f b6 a3 40 01 00 	movzbl 0x140(%rbx),%r12d
  184587:	00 
  184588:	83 83 58 01 00 00 01 	addl   $0x1,0x158(%rbx)
  18458f:	41 80 fc 01          	cmp    $0x1,%r12b
  184593:	0f 87 00 00 00 00    	ja     184599 <wl_start+0xa9>
  184599:	41 83 e4 01          	and    $0x1,%r12d
  18459d:	75 3f                	jne    1845de <wl_start+0xee>
  18459f:	44                   	rex.R
