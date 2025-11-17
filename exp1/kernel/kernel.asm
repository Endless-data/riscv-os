
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00002117          	auipc	sp,0x2
    80000004:	00010113          	mv	sp,sp
    80000008:	00000517          	auipc	a0,0x0
    8000000c:	0a850513          	addi	a0,a0,168 # 800000b0 <bss_end>
    80000010:	00000597          	auipc	a1,0x0
    80000014:	0a058593          	addi	a1,a1,160 # 800000b0 <bss_end>
    80000018:	00b50763          	beq	a0,a1,80000026 <_entry+0x26>
    8000001c:	00052023          	sw	zero,0(a0)
    80000020:	0511                	addi	a0,a0,4
    80000022:	feb54de3          	blt	a0,a1,8000001c <_entry+0x1c>
    80000026:	006000ef          	jal	8000002c <start>
    8000002a:	a001                	j	8000002a <_entry+0x2a>

000000008000002c <start>:
    8000002c:	1141                	addi	sp,sp,-16 # 80001ff0 <bss_end+0x1f40>
    8000002e:	e406                	sd	ra,8(sp)
    80000030:	012000ef          	jal	80000042 <uart_init>
    80000034:	00000517          	auipc	a0,0x0
    80000038:	06c50513          	addi	a0,a0,108 # 800000a0 <uart_puts+0x28>
    8000003c:	03c000ef          	jal	80000078 <uart_puts>
    80000040:	a001                	j	80000040 <start+0x14>

0000000080000042 <uart_init>:
    80000042:	100007b7          	lui	a5,0x10000
    80000046:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    8000004a:	10000737          	lui	a4,0x10000
    8000004e:	468d                	li	a3,3
    80000050:	87ba                	mv	a5,a4
    80000052:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    80000056:	4705                	li	a4,1
    80000058:	00e78123          	sb	a4,2(a5)
    8000005c:	8082                	ret

000000008000005e <uart_putc>:
    8000005e:	10000737          	lui	a4,0x10000
    80000062:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000064:	100006b7          	lui	a3,0x10000
    80000068:	00074783          	lbu	a5,0(a4)
    8000006c:	0207f793          	andi	a5,a5,32
    80000070:	dfe5                	beqz	a5,80000068 <uart_putc+0xa>
    80000072:	00a68023          	sb	a0,0(a3) # 10000000 <_entry-0x70000000>
    80000076:	8082                	ret

0000000080000078 <uart_puts>:
    80000078:	00054683          	lbu	a3,0(a0)
    8000007c:	c28d                	beqz	a3,8000009e <uart_puts+0x26>
    8000007e:	10000737          	lui	a4,0x10000
    80000082:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000084:	10000637          	lui	a2,0x10000
    80000088:	0505                	addi	a0,a0,1
    8000008a:	00074783          	lbu	a5,0(a4)
    8000008e:	0207f793          	andi	a5,a5,32
    80000092:	dfe5                	beqz	a5,8000008a <uart_puts+0x12>
    80000094:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>
    80000098:	00054683          	lbu	a3,0(a0)
    8000009c:	f6f5                	bnez	a3,80000088 <uart_puts+0x10>
    8000009e:	8082                	ret
