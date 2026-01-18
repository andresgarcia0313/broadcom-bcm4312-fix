
wl.ko:     formato del fichero elf64-x86-64


Desensamblado de la sección .text:

0000000000184180 <wl_dpc>:
  184180:	e8 00 00 00 00       	call   184185 <wl_dpc+0x5>
  184185:	55                   	push   %rbp
  184186:	48 89 e5             	mov    %rsp,%rbp
  184189:	41 55                	push   %r13
  18418b:	41 54                	push   %r12
  18418d:	53                   	push   %rbx
  18418e:	48 89 fb             	mov    %rdi,%rbx
  184191:	48 83 ec 10          	sub    $0x10,%rsp
  184195:	44 0f b6 a7 d8 01 00 	movzbl 0x1d8(%rdi),%r12d
  18419c:	00 
  18419d:	65 48 8b 04 25 28 00 	mov    %gs:0x28,%rax
  1841a4:	00 00 
  1841a6:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  1841aa:	31 c0                	xor    %eax,%eax
  1841ac:	41 80 fc 01          	cmp    $0x1,%r12b
  1841b0:	0f 87 00 00 00 00    	ja     1841b6 <wl_dpc+0x36>
  1841b6:	41 83 e4 01          	and    $0x1,%r12d
  1841ba:	75 77                	jne    184233 <wl_dpc+0xb3>
  1841bc:	48 8d 7b 28          	lea    0x28(%rbx),%rdi
  1841c0:	e8 00 00 00 00       	call   1841c5 <wl_dpc+0x45>
  1841c5:	48 8b 43 08          	mov    0x8(%rbx),%rax
  1841c9:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  1841cd:	41 89 c4             	mov    %eax,%r12d
  1841d0:	41 83 e4 01          	and    $0x1,%r12d
  1841d4:	3c 01                	cmp    $0x1,%al
  1841d6:	0f 87 00 00 00 00    	ja     1841dc <wl_dpc+0x5c>
  1841dc:	45 84 e4             	test   %r12b,%r12b
  1841df:	75 5d                	jne    18423e <wl_dpc+0xbe>
  1841e1:	0f b6 83 d8 01 00 00 	movzbl 0x1d8(%rbx),%eax
  1841e8:	41 89 c4             	mov    %eax,%r12d
  1841eb:	41 83 e4 01          	and    $0x1,%r12d
  1841ef:	3c 01                	cmp    $0x1,%al
  1841f1:	0f 87 00 00 00 00    	ja     1841f7 <wl_dpc+0x77>
  1841f7:	45 84 e4             	test   %r12b,%r12b
  1841fa:	0f 84 4e 01 00 00    	je     18434e <wl_dpc+0x1ce>
  184200:	48 8d 7b 40          	lea    0x40(%rbx),%rdi
  184204:	e8 00 00 00 00       	call   184209 <wl_dpc+0x89>
  184209:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  18420d:	65 48 2b 04 25 28 00 	sub    %gs:0x28,%rax
  184214:	00 00 
  184216:	0f 85 83 01 00 00    	jne    18439f <wl_dpc+0x21f>
  18421c:	48 83 c4 10          	add    $0x10,%rsp
  184220:	5b                   	pop    %rbx
  184221:	41 5c                	pop    %r12
  184223:	41 5d                	pop    %r13
  184225:	5d                   	pop    %rbp
  184226:	31 c0                	xor    %eax,%eax
  184228:	31 d2                	xor    %edx,%edx
  18422a:	31 f6                	xor    %esi,%esi
  18422c:	31 ff                	xor    %edi,%edi
  18422e:	e9 00 00 00 00       	jmp    184233 <wl_dpc+0xb3>
  184233:	48 8d 7b 40          	lea    0x40(%rbx),%rdi
  184237:	e8 00 00 00 00       	call   18423c <wl_dpc+0xbc>
  18423c:	eb 87                	jmp    1841c5 <wl_dpc+0x45>
  18423e:	44 0f b6 a3 cc 00 00 	movzbl 0xcc(%rbx),%r12d
  184245:	00 
  184246:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
  18424d:	41 80 fc 01          	cmp    $0x1,%r12b
  184251:	0f 87 00 00 00 00    	ja     184257 <wl_dpc+0xd7>
  184257:	41 83 e4 01          	and    $0x1,%r12d
  18425b:	0f 85 f3 00 00 00    	jne    184354 <wl_dpc+0x1d4>
  184261:	48 8b 7b 10          	mov    0x10(%rbx),%rdi
  184265:	48 8d 55 dc          	lea    -0x24(%rbp),%rdx
  184269:	be 01 00 00 00       	mov    $0x1,%esi
  18426e:	e8 00 00 00 00       	call   184273 <wl_dpc+0xf3>
  184273:	88 83 cc 00 00 00    	mov    %al,0xcc(%rbx)
  184279:	8b 45 dc             	mov    -0x24(%rbp),%eax
  18427c:	89 83 14 02 00 00    	mov    %eax,0x214(%rbx)
  184282:	48 8b 43 08          	mov    0x8(%rbx),%rax
  184286:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  18428a:	41 89 c4             	mov    %eax,%r12d
  18428d:	41 83 e4 01          	and    $0x1,%r12d
  184291:	3c 01                	cmp    $0x1,%al
  184293:	0f 87 00 00 00 00    	ja     184299 <wl_dpc+0x119>
  184299:	45 84 e4             	test   %r12b,%r12b
  18429c:	0f 84 3f ff ff ff    	je     1841e1 <wl_dpc+0x61>
  1842a2:	44 0f b6 ab cc 00 00 	movzbl 0xcc(%rbx),%r13d
  1842a9:	00 
  1842aa:	41 80 fd 01          	cmp    $0x1,%r13b
  1842ae:	0f 87 00 00 00 00    	ja     1842b4 <wl_dpc+0x134>
  1842b4:	41 83 e5 01          	and    $0x1,%r13d
  1842b8:	44 0f b6 a3 d8 01 00 	movzbl 0x1d8(%rbx),%r12d
  1842bf:	00 
  1842c0:	74 28                	je     1842ea <wl_dpc+0x16a>
  1842c2:	41 80 fc 01          	cmp    $0x1,%r12b
  1842c6:	0f 87 00 00 00 00    	ja     1842cc <wl_dpc+0x14c>
  1842cc:	41 83 e4 01          	and    $0x1,%r12d
  1842d0:	0f 84 a6 00 00 00    	je     18437c <wl_dpc+0x1fc>
  1842d6:	48 8d 7b 70          	lea    0x70(%rbx),%rdi
  1842da:	f0 48 0f ba 6b 78 00 	lock btsq $0x0,0x78(%rbx)
  1842e1:	72 3e                	jb     184321 <wl_dpc+0x1a1>
  1842e3:	e8 00 00 00 00       	call   1842e8 <wl_dpc+0x168>
  1842e8:	eb 37                	jmp    184321 <wl_dpc+0x1a1>
  1842ea:	41 80 fc 01          	cmp    $0x1,%r12b
  1842ee:	0f 87 00 00 00 00    	ja     1842f4 <wl_dpc+0x174>
  1842f4:	41 83 e4 01          	and    $0x1,%r12d
  1842f8:	0f 84 98 00 00 00    	je     184396 <wl_dpc+0x216>
  1842fe:	4c 8d 6b 44          	lea    0x44(%rbx),%r13
  184302:	4c 89 ef             	mov    %r13,%rdi
  184305:	e8 00 00 00 00       	call   18430a <wl_dpc+0x18a>
  18430a:	48 8b 7b 10          	mov    0x10(%rbx),%rdi
  18430e:	49 89 c4             	mov    %rax,%r12
  184311:	e8 00 00 00 00       	call   184316 <wl_dpc+0x196>
  184316:	4c 89 e6             	mov    %r12,%rsi
  184319:	4c 89 ef             	mov    %r13,%rdi
  18431c:	e8 00 00 00 00       	call   184321 <wl_dpc+0x1a1>
  184321:	0f b6 83 d8 01 00 00 	movzbl 0x1d8(%rbx),%eax
  184328:	41 89 c4             	mov    %eax,%r12d
  18432b:	41 83 e4 01          	and    $0x1,%r12d
  18432f:	3c 01                	cmp    $0x1,%al
  184331:	0f 87 00 00 00 00    	ja     184337 <wl_dpc+0x1b7>
  184337:	45 84 e4             	test   %r12b,%r12b
  18433a:	0f 85 c0 fe ff ff    	jne    184200 <wl_dpc+0x80>
  184340:	48 8d 7b 28          	lea    0x28(%rbx),%rdi
  184344:	e8 00 00 00 00       	call   184349 <wl_dpc+0x1c9>
  184349:	e9 bb fe ff ff       	jmp    184209 <wl_dpc+0x89>
  18434e:	f0 ff 4b 60          	lock decl 0x60(%rbx)
  184352:	eb cd                	jmp    184321 <wl_dpc+0x1a1>
  184354:	4c 8d 6b 44          	lea    0x44(%rbx),%r13
  184358:	4c 89 ef             	mov    %r13,%rdi
  18435b:	e8 00 00 00 00       	call   184360 <wl_dpc+0x1e0>
  184360:	48 8b 7b 10          	mov    0x10(%rbx),%rdi
  184364:	49 89 c4             	mov    %rax,%r12
  184367:	e8 00 00 00 00       	call   18436c <wl_dpc+0x1ec>
  18436c:	4c 89 e6             	mov    %r12,%rsi
  18436f:	4c 89 ef             	mov    %r13,%rdi
  184372:	e8 00 00 00 00       	call   184377 <wl_dpc+0x1f7>
  184377:	e9 e5 fe ff ff       	jmp    184261 <wl_dpc+0xe1>
  18437c:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 184383 <wl_dpc+0x203>
  184383:	48 8d 93 b0 01 00 00 	lea    0x1b0(%rbx),%rdx
  18438a:	bf 00 20 00 00       	mov    $0x2000,%edi
  18438f:	e8                   	.byte 0xe8
