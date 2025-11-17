
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
        .global _entry
_entry:
        # 设置栈指针
        # 为每个 CPU 分配一个栈
        # 栈大小为 4096 字节
        la sp, stack0
    80000000:	00004117          	auipc	sp,0x4
    80000004:	00010113          	mv	sp,sp
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid      # 读取 hart id (CPU ID)
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1        # hart id 从 0 开始，栈从 stack0+4096 开始
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        
        # 跳转到 C 代码的 start 函数
        call start
    80000016:	0e1000ef          	jal	800008f6 <start>

000000008000001a <spin>:

        # 如果 start 返回，则进入死循环
spin:
        wfi                   # 等待中断
    8000001a:	10500073          	wfi
        j spin
    8000001e:	bff5                	j	8000001a <spin>

0000000080000020 <console_init>:
// 初始化控制台
void 
console_init(void) 
{
    // 初始化UART
    uart_init();
    80000020:	73d0006f          	j	80000f5c <uart_init>

0000000080000024 <console_putc>:
}

// 输出单个字符到控制台
void 
console_putc(char c) 
{
    80000024:	1101                	addi	sp,sp,-32 # 80003fe0 <digits+0xe90>
    80000026:	ec06                	sd	ra,24(sp)
    // 处理特殊字符
    if (c == '\n') {
    80000028:	4729                	li	a4,10
    8000002a:	02e50563          	beq	a0,a4,80000054 <console_putc+0x30>
        // 换行符需要CR+LF
        uart_putc('\r');
        uart_putc('\n');
    } else if (c == '\b') {
    8000002e:	4721                	li	a4,8
    80000030:	00e50663          	beq	a0,a4,8000003c <console_putc+0x18>
        uart_putc('\b');
    } else {
        // 普通字符直接输出
        uart_putc(c);
    }
}
    80000034:	60e2                	ld	ra,24(sp)
    80000036:	6105                	addi	sp,sp,32
        uart_putc('\b');
    80000038:	7410006f          	j	80000f78 <uart_putc>
    8000003c:	e42a                	sd	a0,8(sp)
        uart_putc('\b');
    8000003e:	73b000ef          	jal	80000f78 <uart_putc>
        uart_putc(' ');
    80000042:	02000513          	li	a0,32
    80000046:	733000ef          	jal	80000f78 <uart_putc>
        uart_putc('\b');
    8000004a:	6522                	ld	a0,8(sp)
}
    8000004c:	60e2                	ld	ra,24(sp)
    8000004e:	6105                	addi	sp,sp,32
        uart_putc('\b');
    80000050:	7290006f          	j	80000f78 <uart_putc>
    80000054:	e42a                	sd	a0,8(sp)
        uart_putc('\r');
    80000056:	4535                	li	a0,13
    80000058:	b7fd                	j	80000046 <console_putc+0x22>

000000008000005a <console_puts>:

// 输出字符串到控制台
void 
console_puts(const char *s) 
{
    while (*s != '\0') {
    8000005a:	00054783          	lbu	a5,0(a0) # 1000 <_entry-0x7ffff000>
    8000005e:	cfb9                	beqz	a5,800000bc <console_puts+0x62>
{
    80000060:	1101                	addi	sp,sp,-32
    80000062:	e822                	sd	s0,16(sp)
    80000064:	e426                	sd	s1,8(sp)
    80000066:	e04a                	sd	s2,0(sp)
    80000068:	ec06                	sd	ra,24(sp)
    8000006a:	842a                	mv	s0,a0
    if (c == '\n') {
    8000006c:	4929                	li	s2,10
    } else if (c == '\b') {
    8000006e:	44a1                	li	s1,8
    80000070:	a031                	j	8000007c <console_puts+0x22>
        uart_putc(c);
    80000072:	707000ef          	jal	80000f78 <uart_putc>
    while (*s != '\0') {
    80000076:	00044783          	lbu	a5,0(s0)
    8000007a:	c785                	beqz	a5,800000a2 <console_puts+0x48>
        uart_putc(c);
    8000007c:	853e                	mv	a0,a5
        console_putc(*s++);
    8000007e:	0405                	addi	s0,s0,1
    if (c == '\n') {
    80000080:	03278763          	beq	a5,s2,800000ae <console_puts+0x54>
    } else if (c == '\b') {
    80000084:	fe9797e3          	bne	a5,s1,80000072 <console_puts+0x18>
        uart_putc('\b');
    80000088:	8526                	mv	a0,s1
    8000008a:	6ef000ef          	jal	80000f78 <uart_putc>
        uart_putc(' ');
    8000008e:	02000513          	li	a0,32
    80000092:	6e7000ef          	jal	80000f78 <uart_putc>
        uart_putc('\b');
    80000096:	8526                	mv	a0,s1
    80000098:	6e1000ef          	jal	80000f78 <uart_putc>
    while (*s != '\0') {
    8000009c:	00044783          	lbu	a5,0(s0)
    800000a0:	fff1                	bnez	a5,8000007c <console_puts+0x22>
    }
}
    800000a2:	60e2                	ld	ra,24(sp)
    800000a4:	6442                	ld	s0,16(sp)
    800000a6:	64a2                	ld	s1,8(sp)
    800000a8:	6902                	ld	s2,0(sp)
    800000aa:	6105                	addi	sp,sp,32
    800000ac:	8082                	ret
        uart_putc('\r');
    800000ae:	4535                	li	a0,13
    800000b0:	6c9000ef          	jal	80000f78 <uart_putc>
        uart_putc('\n');
    800000b4:	854a                	mv	a0,s2
    800000b6:	6c3000ef          	jal	80000f78 <uart_putc>
}
    800000ba:	bf75                	j	80000076 <console_puts+0x1c>
    800000bc:	8082                	ret

00000000800000be <clear_screen>:

// 清除屏幕 - ANSI转义序列
void 
clear_screen(void) 
{
    800000be:	1141                	addi	sp,sp,-16
    // ESC [ 2 J - 清除整个屏幕
    // ESC [ H - 光标移动到左上角 (1,1)
    console_puts("\033[2J");
    800000c0:	00002517          	auipc	a0,0x2
    800000c4:	f5050513          	addi	a0,a0,-176 # 80002010 <etext+0x10>
{
    800000c8:	e406                	sd	ra,8(sp)
    console_puts("\033[2J");
    800000ca:	f91ff0ef          	jal	8000005a <console_puts>
    console_puts("\033[H");
}
    800000ce:	60a2                	ld	ra,8(sp)
    console_puts("\033[H");
    800000d0:	00002517          	auipc	a0,0x2
    800000d4:	f5050513          	addi	a0,a0,-176 # 80002020 <etext+0x20>
}
    800000d8:	0141                	addi	sp,sp,16
    console_puts("\033[H");
    800000da:	b741                	j	8000005a <console_puts>

00000000800000dc <console_goto_xy>:
    // 缓冲区用于构造ANSI序列
    char buf[16];
    char *p = buf;
    
    // ESC [ row ; col H
    *p++ = '\033';
    800000dc:	6799                	lui	a5,0x6
{
    800000de:	7139                	addi	sp,sp,-64
    *p++ = '\033';
    800000e0:	b1b78793          	addi	a5,a5,-1253 # 5b1b <_entry-0x7fffa4e5>
    int temp = y;
    char y_digits[10];
    int y_idx = 0;
    
    do {
        y_digits[y_idx++] = (temp % 10) + '0';
    800000e4:	66666337          	lui	t1,0x66666
{
    800000e8:	fc06                	sd	ra,56(sp)
    *p++ = '\033';
    800000ea:	02f11023          	sh	a5,32(sp)
    int temp = y;
    800000ee:	880a                	mv	a6,sp
{
    800000f0:	86aa                	mv	a3,a0
    *p++ = '\033';
    800000f2:	860a                	mv	a2,sp
        y_digits[y_idx++] = (temp % 10) + '0';
    800000f4:	66730313          	addi	t1,t1,1639 # 66666667 <_entry-0x19999999>
        temp /= 10;
    } while (temp > 0);
    800000f8:	4e25                	li	t3,9
        y_digits[y_idx++] = (temp % 10) + '0';
    800000fa:	026587b3          	mul	a5,a1,t1
    800000fe:	41f5d71b          	sraiw	a4,a1,0x1f
    80000102:	852e                	mv	a0,a1
    80000104:	88b2                	mv	a7,a2
    } while (temp > 0);
    80000106:	0605                	addi	a2,a2,1
        y_digits[y_idx++] = (temp % 10) + '0';
    80000108:	9789                	srai	a5,a5,0x22
    8000010a:	9f99                	subw	a5,a5,a4
    8000010c:	0027971b          	slliw	a4,a5,0x2
    80000110:	9f3d                	addw	a4,a4,a5
    80000112:	0017171b          	slliw	a4,a4,0x1
    80000116:	9d99                	subw	a1,a1,a4
    80000118:	0305859b          	addiw	a1,a1,48
    8000011c:	feb60fa3          	sb	a1,-1(a2)
        temp /= 10;
    80000120:	85be                	mv	a1,a5
    } while (temp > 0);
    80000122:	fcae4ce3          	blt	t3,a0,800000fa <console_goto_xy+0x1e>
    80000126:	410888bb          	subw	a7,a7,a6
    8000012a:	02089593          	slli	a1,a7,0x20
    8000012e:	9181                	srli	a1,a1,0x20
    80000130:	1008                	addi	a0,sp,32
    *p++ = '[';
    80000132:	02210313          	addi	t1,sp,34
    80000136:	058d                	addi	a1,a1,3
    80000138:	01180733          	add	a4,a6,a7
    8000013c:	95aa                	add	a1,a1,a0
    8000013e:	879a                	mv	a5,t1
    
    // 反向输出
    while (y_idx > 0) {
        *p++ = y_digits[--y_idx];
    80000140:	00074603          	lbu	a2,0(a4)
    80000144:	0785                	addi	a5,a5,1
    while (y_idx > 0) {
    80000146:	177d                	addi	a4,a4,-1
        *p++ = y_digits[--y_idx];
    80000148:	fec78fa3          	sb	a2,-1(a5)
    while (y_idx > 0) {
    8000014c:	feb79ae3          	bne	a5,a1,80000140 <console_goto_xy+0x64>
    80000150:	9346                	add	t1,t1,a7
    }
    
    *p++ = ';';
    80000152:	03b00793          	li	a5,59
    80000156:	080c                	addi	a1,sp,16
    temp = x;
    char x_digits[10];
    int x_idx = 0;
    
    do {
        x_digits[x_idx++] = (temp % 10) + '0';
    80000158:	66666e37          	lui	t3,0x66666
    *p++ = ';';
    8000015c:	00f300a3          	sb	a5,1(t1)
    80000160:	862e                	mv	a2,a1
        x_digits[x_idx++] = (temp % 10) + '0';
    80000162:	667e0e13          	addi	t3,t3,1639 # 66666667 <_entry-0x19999999>
        temp /= 10;
    } while (temp > 0);
    80000166:	4ea5                	li	t4,9
        x_digits[x_idx++] = (temp % 10) + '0';
    80000168:	03c68733          	mul	a4,a3,t3
    8000016c:	41f6d79b          	sraiw	a5,a3,0x1f
    80000170:	8836                	mv	a6,a3
    80000172:	88b2                	mv	a7,a2
    } while (temp > 0);
    80000174:	0605                	addi	a2,a2,1
        x_digits[x_idx++] = (temp % 10) + '0';
    80000176:	9709                	srai	a4,a4,0x22
    80000178:	9f1d                	subw	a4,a4,a5
    8000017a:	0027179b          	slliw	a5,a4,0x2
    8000017e:	9fb9                	addw	a5,a5,a4
    80000180:	0017979b          	slliw	a5,a5,0x1
    80000184:	40f687bb          	subw	a5,a3,a5
    80000188:	0307879b          	addiw	a5,a5,48
    8000018c:	fef60fa3          	sb	a5,-1(a2)
        temp /= 10;
    80000190:	86ba                	mv	a3,a4
    } while (temp > 0);
    80000192:	fd0ecbe3          	blt	t4,a6,80000168 <console_goto_xy+0x8c>
    80000196:	40b888bb          	subw	a7,a7,a1
    8000019a:	02089693          	slli	a3,a7,0x20
    8000019e:	9281                	srli	a3,a3,0x20
    800001a0:	01158733          	add	a4,a1,a7
    800001a4:	00330593          	addi	a1,t1,3
    800001a8:	95b6                	add	a1,a1,a3
    *p++ = ';';
    800001aa:	00230793          	addi	a5,t1,2
    
    // 反向输出
    while (x_idx > 0) {
        *p++ = x_digits[--x_idx];
    800001ae:	00074603          	lbu	a2,0(a4)
    800001b2:	86be                	mv	a3,a5
    800001b4:	0785                	addi	a5,a5,1
    800001b6:	00c68023          	sb	a2,0(a3)
    while (x_idx > 0) {
    800001ba:	177d                	addi	a4,a4,-1
    800001bc:	feb799e3          	bne	a5,a1,800001ae <console_goto_xy+0xd2>
    800001c0:	9346                	add	t1,t1,a7
    }
    
    *p++ = 'H';
    800001c2:	04800793          	li	a5,72
    *p = '\0';
    800001c6:	00030223          	sb	zero,4(t1)
    *p++ = 'H';
    800001ca:	00f301a3          	sb	a5,3(t1)
    
    // 发送序列
    console_puts(buf);
    800001ce:	e8dff0ef          	jal	8000005a <console_puts>
    800001d2:	70e2                	ld	ra,56(sp)
    800001d4:	6121                	addi	sp,sp,64
    800001d6:	8082                	ret

00000000800001d8 <memset_simple>:

// 简单的内存设置函数（类似memset）
void* memset_simple(void *dst, int c, uint n) {
    char *d = (char*)dst;
    int i;
    for (i = 0; i < n; i++) {
    800001d8:	87aa                	mv	a5,a0
    800001da:	00c50733          	add	a4,a0,a2
    800001de:	00c05763          	blez	a2,800001ec <memset_simple+0x14>
        d[i] = c;
    800001e2:	00b78023          	sb	a1,0(a5)
    for (i = 0; i < n; i++) {
    800001e6:	0785                	addi	a5,a5,1
    800001e8:	fee79de3          	bne	a5,a4,800001e2 <memset_simple+0xa>
    }
    return dst;
}
    800001ec:	8082                	ret

00000000800001ee <alloc_page>:
// 分配一个物理页面
void* alloc_page(void) {
    struct run *r;
    
    // 检查是否有空闲页面
    if (pmm.freelist == 0) {
    800001ee:	0000c797          	auipc	a5,0xc
    800001f2:	e2278793          	addi	a5,a5,-478 # 8000c010 <pmm>
    800001f6:	6388                	ld	a0,0(a5)
    800001f8:	c115                	beqz	a0,8000021c <alloc_page+0x2e>
    // 取出链表头部页面
    r = pmm.freelist;
    pmm.freelist = r->next;
    
    // 更新统计信息
    pmm.free_pages--;
    800001fa:	6b90                	ld	a2,16(a5)
    pmm.used_pages++;
    800001fc:	6f94                	ld	a3,24(a5)
    pmm.freelist = r->next;
    800001fe:	610c                	ld	a1,0(a0)
    pmm.free_pages--;
    80000200:	167d                	addi	a2,a2,-1
    pmm.used_pages++;
    80000202:	0685                	addi	a3,a3,1
    80000204:	6705                	lui	a4,0x1
    80000206:	ef94                	sd	a3,24(a5)
    pmm.free_pages--;
    80000208:	eb90                	sd	a2,16(a5)
    pmm.freelist = r->next;
    8000020a:	e38c                	sd	a1,0(a5)
    for (i = 0; i < n; i++) {
    8000020c:	972a                	add	a4,a4,a0
    8000020e:	87aa                	mv	a5,a0
        d[i] = c;
    80000210:	4695                	li	a3,5
    80000212:	00d78023          	sb	a3,0(a5)
    for (i = 0; i < n; i++) {
    80000216:	0785                	addi	a5,a5,1
    80000218:	fee79de3          	bne	a5,a4,80000212 <alloc_page+0x24>
    
    // 清零页面内容（安全考虑）
    memset_simple((char*)r, 5, PGSIZE);
    
    return (void*)r;
}
    8000021c:	8082                	ret

000000008000021e <free_page>:
// 释放一个物理页面
void free_page(void* pa) {
    struct run *r;
    
    // 地址有效性检查
    if (((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP) {
    8000021e:	4745                	li	a4,17
    80000220:	076e                	slli	a4,a4,0x1b
    80000222:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80000224:	0000d797          	auipc	a5,0xd
    80000228:	ddc78793          	addi	a5,a5,-548 # 8000d000 <end>
    8000022c:	00f537b3          	sltu	a5,a0,a5
    80000230:	00a73733          	sltu	a4,a4,a0
    80000234:	8f5d                	or	a4,a4,a5
    80000236:	87aa                	mv	a5,a0
    80000238:	ef05                	bnez	a4,80000270 <free_page+0x52>
    8000023a:	6705                	lui	a4,0x1
    8000023c:	fff70613          	addi	a2,a4,-1 # fff <_entry-0x7ffff001>
    80000240:	8e69                	and	a2,a2,a0
    80000242:	972a                	add	a4,a4,a0
        d[i] = c;
    80000244:	4685                	li	a3,1
    if (((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP) {
    80000246:	e60d                	bnez	a2,80000270 <free_page+0x52>
        d[i] = c;
    80000248:	00d78023          	sb	a3,0(a5)
    for (i = 0; i < n; i++) {
    8000024c:	0785                	addi	a5,a5,1
    8000024e:	fee79de3          	bne	a5,a4,80000248 <free_page+0x2a>
    // 填充垃圾数据（帮助检测悬空引用）
    memset_simple(pa, 1, PGSIZE);
    
    // 将页面添加到空闲链表头部
    r = (struct run*)pa;
    r->next = pmm.freelist;
    80000252:	0000c797          	auipc	a5,0xc
    80000256:	dbe78793          	addi	a5,a5,-578 # 8000c010 <pmm>
    pmm.freelist = r;
    
    // 更新统计信息
    pmm.free_pages++;
    8000025a:	6b98                	ld	a4,16(a5)
    r->next = pmm.freelist;
    8000025c:	6390                	ld	a2,0(a5)
    if (pmm.used_pages > 0) {
    8000025e:	6f94                	ld	a3,24(a5)
    pmm.free_pages++;
    80000260:	0705                	addi	a4,a4,1
    r->next = pmm.freelist;
    80000262:	e110                	sd	a2,0(a0)
    pmm.freelist = r;
    80000264:	e388                	sd	a0,0(a5)
    pmm.free_pages++;
    80000266:	eb98                	sd	a4,16(a5)
    if (pmm.used_pages > 0) {
    80000268:	c299                	beqz	a3,8000026e <free_page+0x50>
        pmm.used_pages--;
    8000026a:	16fd                	addi	a3,a3,-1
    8000026c:	ef94                	sd	a3,24(a5)
    }
}
    8000026e:	8082                	ret
        printf("free_page: 无效地址 0x%p\n", pa);
    80000270:	85aa                	mv	a1,a0
    80000272:	00002517          	auipc	a0,0x2
    80000276:	db650513          	addi	a0,a0,-586 # 80002028 <etext+0x28>
    8000027a:	0af0006f          	j	80000b28 <printf>

000000008000027e <freerange>:
void freerange(void *pa_start, void *pa_end) {
    8000027e:	1101                	addi	sp,sp,-32
    80000280:	e426                	sd	s1,8(sp)
    p = (char*)PGROUNDUP((uint64)pa_start);
    80000282:	6485                	lui	s1,0x1
    80000284:	fff48793          	addi	a5,s1,-1 # fff <_entry-0x7ffff001>
void freerange(void *pa_start, void *pa_end) {
    80000288:	e822                	sd	s0,16(sp)
    p = (char*)PGROUNDUP((uint64)pa_start);
    8000028a:	00f50433          	add	s0,a0,a5
    8000028e:	77fd                	lui	a5,0xfffff
    80000290:	8c7d                	and	s0,s0,a5
void freerange(void *pa_start, void *pa_end) {
    80000292:	ec06                	sd	ra,24(sp)
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000294:	9426                	add	s0,s0,s1
    80000296:	0085ee63          	bltu	a1,s0,800002b2 <freerange+0x34>
    8000029a:	e04a                	sd	s2,0(sp)
    8000029c:	892e                	mv	s2,a1
        free_page(p);
    8000029e:	80040513          	addi	a0,s0,-2048
    800002a2:	80050513          	addi	a0,a0,-2048
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800002a6:	9426                	add	s0,s0,s1
        free_page(p);
    800002a8:	f77ff0ef          	jal	8000021e <free_page>
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800002ac:	fe8979e3          	bgeu	s2,s0,8000029e <freerange+0x20>
    800002b0:	6902                	ld	s2,0(sp)
}
    800002b2:	60e2                	ld	ra,24(sp)
    800002b4:	6442                	ld	s0,16(sp)
    800002b6:	64a2                	ld	s1,8(sp)
    800002b8:	6105                	addi	sp,sp,32
    800002ba:	8082                	ret

00000000800002bc <pmm_init>:
void pmm_init(void) {
    800002bc:	7179                	addi	sp,sp,-48
    printf("初始化物理内存管理器...\n");
    800002be:	00002517          	auipc	a0,0x2
    800002c2:	d8a50513          	addi	a0,a0,-630 # 80002048 <etext+0x48>
void pmm_init(void) {
    800002c6:	f406                	sd	ra,40(sp)
    800002c8:	f022                	sd	s0,32(sp)
    800002ca:	ec26                	sd	s1,24(sp)
    800002cc:	e84a                	sd	s2,16(sp)
    800002ce:	e44e                	sd	s3,8(sp)
    printf("初始化物理内存管理器...\n");
    800002d0:	059000ef          	jal	80000b28 <printf>
    char *start = (char*)PGROUNDUP((uint64)end);
    800002d4:	77fd                	lui	a5,0xfffff
    800002d6:	0000e417          	auipc	s0,0xe
    800002da:	d2940413          	addi	s0,s0,-727 # 8000dfff <end+0xfff>
    800002de:	8c7d                	and	s0,s0,a5
    printf("内存范围: 0x%p - 0x%p\n", start, stop);
    800002e0:	4645                	li	a2,17
    800002e2:	066e                	slli	a2,a2,0x1b
    800002e4:	85a2                	mv	a1,s0
    800002e6:	00002517          	auipc	a0,0x2
    800002ea:	d8a50513          	addi	a0,a0,-630 # 80002070 <etext+0x70>
    800002ee:	03b000ef          	jal	80000b28 <printf>
    printf("内核结束地址: 0x%p\n", end);
    800002f2:	0000d597          	auipc	a1,0xd
    800002f6:	d0e58593          	addi	a1,a1,-754 # 8000d000 <end>
    800002fa:	00002517          	auipc	a0,0x2
    800002fe:	d9650513          	addi	a0,a0,-618 # 80002090 <etext+0x90>
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000302:	44c5                	li	s1,17
    printf("内核结束地址: 0x%p\n", end);
    80000304:	025000ef          	jal	80000b28 <printf>
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000308:	04ee                	slli	s1,s1,0x1b
    8000030a:	408487b3          	sub	a5,s1,s0
    8000030e:	83b1                	srli	a5,a5,0xc
    printf("总页面数: %d\n", (int)pmm.total_pages);
    80000310:	0007859b          	sext.w	a1,a5
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000314:	0000c997          	auipc	s3,0xc
    80000318:	cfc98993          	addi	s3,s3,-772 # 8000c010 <pmm>
    printf("总页面数: %d\n", (int)pmm.total_pages);
    8000031c:	00002517          	auipc	a0,0x2
    80000320:	d9450513          	addi	a0,a0,-620 # 800020b0 <etext+0xb0>
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000324:	00f9b423          	sd	a5,8(s3)
    char *start = (char*)PGROUNDUP((uint64)end);
    80000328:	6905                	lui	s2,0x1
    printf("总页面数: %d\n", (int)pmm.total_pages);
    8000032a:	7fe000ef          	jal	80000b28 <printf>
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    8000032e:	012407b3          	add	a5,s0,s2
    80000332:	00f4e863          	bltu	s1,a5,80000342 <pmm_init+0x86>
        free_page(p);
    80000336:	8522                	mv	a0,s0
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000338:	944a                	add	s0,s0,s2
        free_page(p);
    8000033a:	ee5ff0ef          	jal	8000021e <free_page>
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    8000033e:	fe941ce3          	bne	s0,s1,80000336 <pmm_init+0x7a>
    printf("物理内存管理器初始化完成\n");
    80000342:	00002517          	auipc	a0,0x2
    80000346:	d8650513          	addi	a0,a0,-634 # 800020c8 <etext+0xc8>
    8000034a:	7de000ef          	jal	80000b28 <printf>
}
    8000034e:	7402                	ld	s0,32(sp)
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
    80000350:	0109a583          	lw	a1,16(s3)
}
    80000354:	70a2                	ld	ra,40(sp)
    80000356:	64e2                	ld	s1,24(sp)
    80000358:	6942                	ld	s2,16(sp)
    8000035a:	69a2                	ld	s3,8(sp)
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
    8000035c:	00002517          	auipc	a0,0x2
    80000360:	d9450513          	addi	a0,a0,-620 # 800020f0 <etext+0xf0>
}
    80000364:	6145                	addi	sp,sp,48
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
    80000366:	7c20006f          	j	80000b28 <printf>

000000008000036a <alloc_pages>:

// 分配连续的n个页面（简单实现）
void* alloc_pages(int n) {
    if (n <= 0) return 0;
    8000036a:	04a05a63          	blez	a0,800003be <alloc_pages+0x54>
    if (n == 1) return alloc_page();
    8000036e:	4785                	li	a5,1
    80000370:	00f50f63          	beq	a0,a5,8000038e <alloc_pages+0x24>
void* alloc_pages(int n) {
    80000374:	1141                	addi	sp,sp,-16
    80000376:	85aa                	mv	a1,a0
    
    // 简单实现：仅支持单页分配
    // 实际的伙伴系统实现会更复杂
    printf("alloc_pages: 暂不支持多页分配 (n=%d)\n", n);
    80000378:	00002517          	auipc	a0,0x2
    8000037c:	d9050513          	addi	a0,a0,-624 # 80002108 <etext+0x108>
void* alloc_pages(int n) {
    80000380:	e406                	sd	ra,8(sp)
    printf("alloc_pages: 暂不支持多页分配 (n=%d)\n", n);
    80000382:	7a6000ef          	jal	80000b28 <printf>
    return 0;
}
    80000386:	60a2                	ld	ra,8(sp)
    if (n <= 0) return 0;
    80000388:	4501                	li	a0,0
}
    8000038a:	0141                	addi	sp,sp,16
    8000038c:	8082                	ret
    if (pmm.freelist == 0) {
    8000038e:	0000c797          	auipc	a5,0xc
    80000392:	c8278793          	addi	a5,a5,-894 # 8000c010 <pmm>
    80000396:	6388                	ld	a0,0(a5)
    80000398:	c11d                	beqz	a0,800003be <alloc_pages+0x54>
    pmm.free_pages--;
    8000039a:	6b90                	ld	a2,16(a5)
    pmm.used_pages++;
    8000039c:	6f94                	ld	a3,24(a5)
    pmm.freelist = r->next;
    8000039e:	610c                	ld	a1,0(a0)
    pmm.free_pages--;
    800003a0:	167d                	addi	a2,a2,-1
    pmm.used_pages++;
    800003a2:	0685                	addi	a3,a3,1
    800003a4:	6705                	lui	a4,0x1
    800003a6:	ef94                	sd	a3,24(a5)
    pmm.free_pages--;
    800003a8:	eb90                	sd	a2,16(a5)
    pmm.freelist = r->next;
    800003aa:	e38c                	sd	a1,0(a5)
    for (i = 0; i < n; i++) {
    800003ac:	972a                	add	a4,a4,a0
    800003ae:	87aa                	mv	a5,a0
        d[i] = c;
    800003b0:	4695                	li	a3,5
    800003b2:	00d78023          	sb	a3,0(a5)
    for (i = 0; i < n; i++) {
    800003b6:	0785                	addi	a5,a5,1
    800003b8:	fee79de3          	bne	a5,a4,800003b2 <alloc_pages+0x48>
    800003bc:	8082                	ret
    if (n <= 0) return 0;
    800003be:	4501                	li	a0,0
}
    800003c0:	8082                	ret

00000000800003c2 <get_free_pages>:

// 获取空闲页面数量
uint64 get_free_pages(void) {
    return pmm.free_pages;
}
    800003c2:	0000c517          	auipc	a0,0xc
    800003c6:	c5e53503          	ld	a0,-930(a0) # 8000c020 <pmm+0x10>
    800003ca:	8082                	ret

00000000800003cc <print_memory_stats>:

// 打印内存使用统计
void print_memory_stats(void) {
    800003cc:	1141                	addi	sp,sp,-16
    printf("=== 内存使用统计 ===\n");
    800003ce:	00002517          	auipc	a0,0x2
    800003d2:	d6a50513          	addi	a0,a0,-662 # 80002138 <etext+0x138>
void print_memory_stats(void) {
    800003d6:	e406                	sd	ra,8(sp)
    800003d8:	e022                	sd	s0,0(sp)
    printf("总页面数:   %d\n", (int)pmm.total_pages);
    800003da:	0000c417          	auipc	s0,0xc
    800003de:	c3640413          	addi	s0,s0,-970 # 8000c010 <pmm>
    printf("=== 内存使用统计 ===\n");
    800003e2:	746000ef          	jal	80000b28 <printf>
    printf("总页面数:   %d\n", (int)pmm.total_pages);
    800003e6:	440c                	lw	a1,8(s0)
    800003e8:	00002517          	auipc	a0,0x2
    800003ec:	d7050513          	addi	a0,a0,-656 # 80002158 <etext+0x158>
    800003f0:	738000ef          	jal	80000b28 <printf>
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
    800003f4:	480c                	lw	a1,16(s0)
    800003f6:	00002517          	auipc	a0,0x2
    800003fa:	cfa50513          	addi	a0,a0,-774 # 800020f0 <etext+0xf0>
    800003fe:	72a000ef          	jal	80000b28 <printf>
    printf("已用页面数: %d\n", (int)pmm.used_pages);
    80000402:	4c0c                	lw	a1,24(s0)
    80000404:	00002517          	auipc	a0,0x2
    80000408:	d6c50513          	addi	a0,a0,-660 # 80002170 <etext+0x170>
    8000040c:	71c000ef          	jal	80000b28 <printf>
    printf("总内存:     %d KB\n", (int)(pmm.total_pages * PGSIZE / 1024));
    80000410:	640c                	ld	a1,8(s0)
    80000412:	00002517          	auipc	a0,0x2
    80000416:	d7650513          	addi	a0,a0,-650 # 80002188 <etext+0x188>
    8000041a:	02259793          	slli	a5,a1,0x22
    8000041e:	4227d593          	srai	a1,a5,0x22
    80000422:	058a                	slli	a1,a1,0x2
    80000424:	704000ef          	jal	80000b28 <printf>
    printf("空闲内存:   %d KB\n", (int)(pmm.free_pages * PGSIZE / 1024));
    80000428:	680c                	ld	a1,16(s0)
    8000042a:	00002517          	auipc	a0,0x2
    8000042e:	d7650513          	addi	a0,a0,-650 # 800021a0 <etext+0x1a0>
    80000432:	02259793          	slli	a5,a1,0x22
    80000436:	4227d593          	srai	a1,a5,0x22
    8000043a:	058a                	slli	a1,a1,0x2
    8000043c:	6ec000ef          	jal	80000b28 <printf>
    printf("已用内存:   %d KB\n", (int)(pmm.used_pages * PGSIZE / 1024));
    80000440:	6c0c                	ld	a1,24(s0)
    80000442:	00002517          	auipc	a0,0x2
    80000446:	d7650513          	addi	a0,a0,-650 # 800021b8 <etext+0x1b8>
    8000044a:	02259793          	slli	a5,a1,0x22
    8000044e:	4227d593          	srai	a1,a5,0x22
    80000452:	058a                	slli	a1,a1,0x2
    80000454:	6d4000ef          	jal	80000b28 <printf>
    
    if (pmm.total_pages > 0) {
    80000458:	641c                	ld	a5,8(s0)
    8000045a:	eb91                	bnez	a5,8000046e <print_memory_stats+0xa2>
        int usage = (int)((pmm.used_pages * 100) / pmm.total_pages);
        printf("内存使用率: %d%%\n", usage);
    }
    printf("==================\n");
    8000045c:	6402                	ld	s0,0(sp)
    8000045e:	60a2                	ld	ra,8(sp)
    printf("==================\n");
    80000460:	00002517          	auipc	a0,0x2
    80000464:	d8850513          	addi	a0,a0,-632 # 800021e8 <etext+0x1e8>
    80000468:	0141                	addi	sp,sp,16
    printf("==================\n");
    8000046a:	6be0006f          	j	80000b28 <printf>
        int usage = (int)((pmm.used_pages * 100) / pmm.total_pages);
    8000046e:	6c0c                	ld	a1,24(s0)
    80000470:	06400713          	li	a4,100
        printf("内存使用率: %d%%\n", usage);
    80000474:	00002517          	auipc	a0,0x2
    80000478:	d5c50513          	addi	a0,a0,-676 # 800021d0 <etext+0x1d0>
        int usage = (int)((pmm.used_pages * 100) / pmm.total_pages);
    8000047c:	02e585b3          	mul	a1,a1,a4
    80000480:	02f5d5b3          	divu	a1,a1,a5
        printf("内存使用率: %d%%\n", usage);
    80000484:	2581                	sext.w	a1,a1
    80000486:	6a2000ef          	jal	80000b28 <printf>
    8000048a:	6402                	ld	s0,0(sp)
    8000048c:	60a2                	ld	ra,8(sp)
    printf("==================\n");
    8000048e:	00002517          	auipc	a0,0x2
    80000492:	d5a50513          	addi	a0,a0,-678 # 800021e8 <etext+0x1e8>
    80000496:	0141                	addi	sp,sp,16
    printf("==================\n");
    80000498:	6900006f          	j	80000b28 <printf>

000000008000049c <test_physical_memory>:

// 声明外部变量
extern pagetable_t kernel_pagetable;

// 测试物理内存分配器
void test_physical_memory(void) {
    8000049c:	1101                	addi	sp,sp,-32
    printf("\n=== 物理内存分配器测试 ===\n");
    8000049e:	00002517          	auipc	a0,0x2
    800004a2:	d6250513          	addi	a0,a0,-670 # 80002200 <etext+0x200>
void test_physical_memory(void) {
    800004a6:	ec06                	sd	ra,24(sp)
    800004a8:	e822                	sd	s0,16(sp)
    printf("\n=== 物理内存分配器测试 ===\n");
    800004aa:	67e000ef          	jal	80000b28 <printf>
    
    // 测试基本分配和释放
    printf("1. 测试基本分配...\n");
    800004ae:	00002517          	auipc	a0,0x2
    800004b2:	d7a50513          	addi	a0,a0,-646 # 80002228 <etext+0x228>
    800004b6:	672000ef          	jal	80000b28 <printf>
    void *page1 = alloc_page();
    800004ba:	d35ff0ef          	jal	800001ee <alloc_page>
    800004be:	842a                	mv	s0,a0
    void *page2 = alloc_page();
    800004c0:	d2fff0ef          	jal	800001ee <alloc_page>
    
    if (page1 == 0 || page2 == 0) {
    800004c4:	cc55                	beqz	s0,80000580 <test_physical_memory+0xe4>
    800004c6:	e426                	sd	s1,8(sp)
    800004c8:	84aa                	mv	s1,a0
    800004ca:	c955                	beqz	a0,8000057e <test_physical_memory+0xe2>
        printf("ERROR: 内存分配失败\n");
        return;
    }
    
    printf("分配页面1: 0x%p\n", page1);
    800004cc:	85a2                	mv	a1,s0
    800004ce:	00002517          	auipc	a0,0x2
    800004d2:	d9a50513          	addi	a0,a0,-614 # 80002268 <etext+0x268>
    800004d6:	652000ef          	jal	80000b28 <printf>
    printf("分配页面2: 0x%p\n", page2);
    800004da:	85a6                	mv	a1,s1
    800004dc:	00002517          	auipc	a0,0x2
    800004e0:	da450513          	addi	a0,a0,-604 # 80002280 <etext+0x280>
    800004e4:	644000ef          	jal	80000b28 <printf>
    
    // 检查页面不同且对齐
    if (page1 == page2) {
    800004e8:	0a940d63          	beq	s0,s1,800005a2 <test_physical_memory+0x106>
        printf("ERROR: 分配了相同的页面\n");
        return;
    }
    
    if (((uint64)page1 & 0xFFF) != 0 || ((uint64)page2 & 0xFFF) != 0) {
    800004ec:	009467b3          	or	a5,s0,s1
    800004f0:	17d2                	slli	a5,a5,0x34
    800004f2:	cb91                	beqz	a5,80000506 <test_physical_memory+0x6a>
        printf("ERROR: 页面未对齐\n");
    800004f4:	64a2                	ld	s1,8(sp)
    800004f6:	00002517          	auipc	a0,0x2
    800004fa:	dca50513          	addi	a0,a0,-566 # 800022c0 <etext+0x2c0>
    // 清理
    free_page(page2);
    free_page(page3);
    
    printf("物理内存分配器测试完成\n");
}
    800004fe:	6442                	ld	s0,16(sp)
    80000500:	60e2                	ld	ra,24(sp)
    80000502:	6105                	addi	sp,sp,32
    printf("物理内存分配器测试完成\n");
    80000504:	a515                	j	80000b28 <printf>
    printf("✓ 页面不同且正确对齐\n");
    80000506:	00002517          	auipc	a0,0x2
    8000050a:	dd250513          	addi	a0,a0,-558 # 800022d8 <etext+0x2d8>
    8000050e:	61a000ef          	jal	80000b28 <printf>
    printf("2. 测试数据写入...\n");
    80000512:	00002517          	auipc	a0,0x2
    80000516:	dee50513          	addi	a0,a0,-530 # 80002300 <etext+0x300>
    8000051a:	60e000ef          	jal	80000b28 <printf>
    *(int*)page1 = 0x12345678;
    8000051e:	123457b7          	lui	a5,0x12345
    80000522:	67878793          	addi	a5,a5,1656 # 12345678 <_entry-0x6dcba988>
    *(int*)page2 = 0xABCDEF00;
    80000526:	abcdf737          	lui	a4,0xabcdf
    *(int*)page1 = 0x12345678;
    8000052a:	c01c                	sw	a5,0(s0)
    *(int*)page2 = 0xABCDEF00;
    8000052c:	f0070713          	addi	a4,a4,-256 # ffffffffabcdef00 <end+0xffffffff2bcd1f00>
    80000530:	c098                	sw	a4,0(s1)
    if (*(int*)page1 != 0x12345678 || *(int*)page2 != 0xABCDEF00) {
    80000532:	4018                	lw	a4,0(s0)
    80000534:	04f71e63          	bne	a4,a5,80000590 <test_physical_memory+0xf4>
    printf("✓ 数据写入成功\n");
    80000538:	00002517          	auipc	a0,0x2
    8000053c:	e0850513          	addi	a0,a0,-504 # 80002340 <etext+0x340>
    80000540:	e04a                	sd	s2,0(sp)
    80000542:	5e6000ef          	jal	80000b28 <printf>
    printf("3. 测试释放和重分配...\n");
    80000546:	00002517          	auipc	a0,0x2
    8000054a:	e1250513          	addi	a0,a0,-494 # 80002358 <etext+0x358>
    8000054e:	5da000ef          	jal	80000b28 <printf>
    uint64 free_before = get_free_pages();
    80000552:	e71ff0ef          	jal	800003c2 <get_free_pages>
    80000556:	892a                	mv	s2,a0
    free_page(page1);
    80000558:	8522                	mv	a0,s0
    8000055a:	cc5ff0ef          	jal	8000021e <free_page>
    uint64 free_after = get_free_pages();
    8000055e:	e65ff0ef          	jal	800003c2 <get_free_pages>
    if (free_after != free_before + 1) {
    80000562:	00190793          	addi	a5,s2,1 # 1001 <_entry-0x7fffefff>
    80000566:	04a78463          	beq	a5,a0,800005ae <test_physical_memory+0x112>
        printf("ERROR: 释放后空闲页面数不正确\n");
    8000056a:	00002517          	auipc	a0,0x2
    8000056e:	e0e50513          	addi	a0,a0,-498 # 80002378 <etext+0x378>
}
    80000572:	6442                	ld	s0,16(sp)
    printf("物理内存分配器测试完成\n");
    80000574:	64a2                	ld	s1,8(sp)
    80000576:	6902                	ld	s2,0(sp)
}
    80000578:	60e2                	ld	ra,24(sp)
    8000057a:	6105                	addi	sp,sp,32
    printf("物理内存分配器测试完成\n");
    8000057c:	a375                	j	80000b28 <printf>
    8000057e:	64a2                	ld	s1,8(sp)
}
    80000580:	6442                	ld	s0,16(sp)
    80000582:	60e2                	ld	ra,24(sp)
        printf("ERROR: 内存分配失败\n");
    80000584:	00002517          	auipc	a0,0x2
    80000588:	cc450513          	addi	a0,a0,-828 # 80002248 <etext+0x248>
}
    8000058c:	6105                	addi	sp,sp,32
    printf("物理内存分配器测试完成\n");
    8000058e:	ab69                	j	80000b28 <printf>
}
    80000590:	6442                	ld	s0,16(sp)
        printf("ERROR: 数据写入失败\n");
    80000592:	64a2                	ld	s1,8(sp)
}
    80000594:	60e2                	ld	ra,24(sp)
        printf("ERROR: 数据写入失败\n");
    80000596:	00002517          	auipc	a0,0x2
    8000059a:	d8a50513          	addi	a0,a0,-630 # 80002320 <etext+0x320>
}
    8000059e:	6105                	addi	sp,sp,32
    printf("物理内存分配器测试完成\n");
    800005a0:	a361                	j	80000b28 <printf>
        printf("ERROR: 分配了相同的页面\n");
    800005a2:	64a2                	ld	s1,8(sp)
    800005a4:	00002517          	auipc	a0,0x2
    800005a8:	cf450513          	addi	a0,a0,-780 # 80002298 <etext+0x298>
    800005ac:	bf89                	j	800004fe <test_physical_memory+0x62>
    void *page3 = alloc_page();
    800005ae:	c41ff0ef          	jal	800001ee <alloc_page>
    printf("重新分配页面: 0x%p\n", page3);
    800005b2:	85aa                	mv	a1,a0
    void *page3 = alloc_page();
    800005b4:	842a                	mv	s0,a0
    printf("重新分配页面: 0x%p\n", page3);
    800005b6:	00002517          	auipc	a0,0x2
    800005ba:	df250513          	addi	a0,a0,-526 # 800023a8 <etext+0x3a8>
    800005be:	56a000ef          	jal	80000b28 <printf>
    printf("✓ 释放和重分配成功\n");
    800005c2:	00002517          	auipc	a0,0x2
    800005c6:	e0650513          	addi	a0,a0,-506 # 800023c8 <etext+0x3c8>
    800005ca:	55e000ef          	jal	80000b28 <printf>
    free_page(page2);
    800005ce:	8526                	mv	a0,s1
    800005d0:	c4fff0ef          	jal	8000021e <free_page>
    free_page(page3);
    800005d4:	8522                	mv	a0,s0
    800005d6:	c49ff0ef          	jal	8000021e <free_page>
    printf("物理内存分配器测试完成\n");
    800005da:	00002517          	auipc	a0,0x2
    800005de:	e0e50513          	addi	a0,a0,-498 # 800023e8 <etext+0x3e8>
    800005e2:	bf41                	j	80000572 <test_physical_memory+0xd6>

00000000800005e4 <test_pagetable>:

// 测试页表功能
void test_pagetable(void) {
    800005e4:	7179                	addi	sp,sp,-48
    printf("\n=== 页表管理系统测试 ===\n");
    800005e6:	00002517          	auipc	a0,0x2
    800005ea:	e2a50513          	addi	a0,a0,-470 # 80002410 <etext+0x410>
void test_pagetable(void) {
    800005ee:	f406                	sd	ra,40(sp)
    printf("\n=== 页表管理系统测试 ===\n");
    800005f0:	538000ef          	jal	80000b28 <printf>
    
    // 创建测试页表
    printf("1. 创建页表...\n");
    800005f4:	00002517          	auipc	a0,0x2
    800005f8:	e4450513          	addi	a0,a0,-444 # 80002438 <etext+0x438>
    800005fc:	52c000ef          	jal	80000b28 <printf>
    pagetable_t pt = create_pagetable();
    80000600:	247000ef          	jal	80001046 <create_pagetable>
    if (pt == 0) {
    80000604:	10050d63          	beqz	a0,8000071e <test_pagetable+0x13a>
        printf("ERROR: 页表创建失败\n");
        return;
    }
    printf("✓ 页表创建成功: 0x%p\n", pt);
    80000608:	85aa                	mv	a1,a0
    8000060a:	f022                	sd	s0,32(sp)
    8000060c:	842a                	mv	s0,a0
    8000060e:	00002517          	auipc	a0,0x2
    80000612:	e6250513          	addi	a0,a0,-414 # 80002470 <etext+0x470>
    80000616:	ec26                	sd	s1,24(sp)
    80000618:	510000ef          	jal	80000b28 <printf>
    
    // 测试基本映射
    printf("2. 测试页面映射...\n");
    8000061c:	00002517          	auipc	a0,0x2
    80000620:	e7450513          	addi	a0,a0,-396 # 80002490 <etext+0x490>
    80000624:	504000ef          	jal	80000b28 <printf>
    uint64 va = 0x1000000;  // 虚拟地址
    void *pa_page = alloc_page();
    80000628:	bc7ff0ef          	jal	800001ee <alloc_page>
    8000062c:	84aa                	mv	s1,a0
    if (pa_page == 0) {
    8000062e:	10050463          	beqz	a0,80000736 <test_pagetable+0x152>
        destroy_pagetable(pt);
        return;
    }
    
    uint64 pa = (uint64)pa_page;
    printf("映射 VA:0x%p -> PA:0x%p\n", (void*)va, (void*)pa);
    80000632:	862a                	mv	a2,a0
    80000634:	010005b7          	lui	a1,0x1000
    80000638:	00002517          	auipc	a0,0x2
    8000063c:	ea050513          	addi	a0,a0,-352 # 800024d8 <etext+0x4d8>
    80000640:	4e8000ef          	jal	80000b28 <printf>
    
    if (map_page(pt, va, pa, PTE_R | PTE_W) != 0) {
    80000644:	8626                	mv	a2,s1
    80000646:	8522                	mv	a0,s0
    80000648:	4699                	li	a3,6
    8000064a:	010005b7          	lui	a1,0x1000
    8000064e:	2ef000ef          	jal	8000113c <map_page>
    80000652:	ed51                	bnez	a0,800006ee <test_pagetable+0x10a>
        printf("ERROR: 页面映射失败\n");
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    printf("✓ 页面映射成功\n");
    80000654:	00002517          	auipc	a0,0x2
    80000658:	ec450513          	addi	a0,a0,-316 # 80002518 <etext+0x518>
    8000065c:	4cc000ef          	jal	80000b28 <printf>
    
    // 测试地址转换
    printf("3. 测试地址转换...\n");
    80000660:	00002517          	auipc	a0,0x2
    80000664:	ed050513          	addi	a0,a0,-304 # 80002530 <etext+0x530>
    80000668:	4c0000ef          	jal	80000b28 <printf>
    pte_t *pte = walk_lookup(pt, va);
    8000066c:	8522                	mv	a0,s0
    8000066e:	010005b7          	lui	a1,0x1000
    80000672:	1fb000ef          	jal	8000106c <walk_lookup>
    if (pte == 0 || (*pte & PTE_V) == 0) {
    80000676:	c95d                	beqz	a0,8000072c <test_pagetable+0x148>
    80000678:	6110                	ld	a2,0(a0)
    8000067a:	00167713          	andi	a4,a2,1
    8000067e:	c75d                	beqz	a4,8000072c <test_pagetable+0x148>
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    
    uint64 pa_found = PTE2PA(*pte);
    80000680:	8229                	srli	a2,a2,0xa
    80000682:	0632                	slli	a2,a2,0xc
    if (pa_found != pa) {
    80000684:	08c49563          	bne	s1,a2,8000070e <test_pagetable+0x12a>
    80000688:	e42a                	sd	a0,8(sp)
               (void*)pa, (void*)pa_found);
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    printf("✓ 地址转换正确\n");
    8000068a:	00002517          	auipc	a0,0x2
    8000068e:	f1e50513          	addi	a0,a0,-226 # 800025a8 <etext+0x5a8>
    80000692:	496000ef          	jal	80000b28 <printf>
    
    // 测试权限位
    printf("4. 测试权限位...\n");
    80000696:	00002517          	auipc	a0,0x2
    8000069a:	f2a50513          	addi	a0,a0,-214 # 800025c0 <etext+0x5c0>
    8000069e:	48a000ef          	jal	80000b28 <printf>
    if ((*pte & PTE_R) == 0 || (*pte & PTE_W) == 0) {
    800006a2:	67a2                	ld	a5,8(sp)
    800006a4:	4719                	li	a4,6
        printf("ERROR: 权限位设置错误\n");
    800006a6:	00002517          	auipc	a0,0x2
    800006aa:	f3250513          	addi	a0,a0,-206 # 800025d8 <etext+0x5d8>
    if ((*pte & PTE_R) == 0 || (*pte & PTE_W) == 0) {
    800006ae:	639c                	ld	a5,0(a5)
    800006b0:	00e7f6b3          	and	a3,a5,a4
    800006b4:	04e69163          	bne	a3,a4,800006f6 <test_pagetable+0x112>
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    
    if (*pte & PTE_X) {
    800006b8:	8ba1                	andi	a5,a5,8
        printf("ERROR: 意外的执行权限\n");
    800006ba:	00002517          	auipc	a0,0x2
    800006be:	f3e50513          	addi	a0,a0,-194 # 800025f8 <etext+0x5f8>
    if (*pte & PTE_X) {
    800006c2:	eb95                	bnez	a5,800006f6 <test_pagetable+0x112>
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    printf("✓ 权限位设置正确 [RW-]\n");
    800006c4:	00002517          	auipc	a0,0x2
    800006c8:	f5450513          	addi	a0,a0,-172 # 80002618 <etext+0x618>
    800006cc:	45c000ef          	jal	80000b28 <printf>
    
    // 清理
    free_page(pa_page);
    800006d0:	8526                	mv	a0,s1
    800006d2:	b4dff0ef          	jal	8000021e <free_page>
    destroy_pagetable(pt);
    800006d6:	8522                	mv	a0,s0
    800006d8:	18f000ef          	jal	80001066 <destroy_pagetable>
    printf("页表管理系统测试完成\n");
    800006dc:	7402                	ld	s0,32(sp)
    800006de:	64e2                	ld	s1,24(sp)
}
    800006e0:	70a2                	ld	ra,40(sp)
    printf("页表管理系统测试完成\n");
    800006e2:	00002517          	auipc	a0,0x2
    800006e6:	f5e50513          	addi	a0,a0,-162 # 80002640 <etext+0x640>
}
    800006ea:	6145                	addi	sp,sp,48
    printf("页表管理系统测试完成\n");
    800006ec:	a935                	j	80000b28 <printf>
        printf("ERROR: 页面映射失败\n");
    800006ee:	00002517          	auipc	a0,0x2
    800006f2:	e0a50513          	addi	a0,a0,-502 # 800024f8 <etext+0x4f8>
    800006f6:	432000ef          	jal	80000b28 <printf>
        free_page(pa_page);
    800006fa:	8526                	mv	a0,s1
    800006fc:	b23ff0ef          	jal	8000021e <free_page>
        destroy_pagetable(pt);
    80000700:	8522                	mv	a0,s0
    80000702:	7402                	ld	s0,32(sp)
    80000704:	64e2                	ld	s1,24(sp)
}
    80000706:	70a2                	ld	ra,40(sp)
    80000708:	6145                	addi	sp,sp,48
        destroy_pagetable(pt);
    8000070a:	15d0006f          	j	80001066 <destroy_pagetable>
        printf("ERROR: 地址转换错误, 期望:0x%p, 实际:0x%p\n", 
    8000070e:	85a6                	mv	a1,s1
    80000710:	00002517          	auipc	a0,0x2
    80000714:	e6050513          	addi	a0,a0,-416 # 80002570 <etext+0x570>
    80000718:	410000ef          	jal	80000b28 <printf>
        free_page(pa_page);
    8000071c:	bff9                	j	800006fa <test_pagetable+0x116>
}
    8000071e:	70a2                	ld	ra,40(sp)
        printf("ERROR: 页表创建失败\n");
    80000720:	00002517          	auipc	a0,0x2
    80000724:	d3050513          	addi	a0,a0,-720 # 80002450 <etext+0x450>
}
    80000728:	6145                	addi	sp,sp,48
        printf("ERROR: 页表创建失败\n");
    8000072a:	aefd                	j	80000b28 <printf>
        printf("ERROR: 页表遍历失败\n");
    8000072c:	00002517          	auipc	a0,0x2
    80000730:	e2450513          	addi	a0,a0,-476 # 80002550 <etext+0x550>
    80000734:	b7c9                	j	800006f6 <test_pagetable+0x112>
        printf("ERROR: 分配物理页面失败\n");
    80000736:	00002517          	auipc	a0,0x2
    8000073a:	d7a50513          	addi	a0,a0,-646 # 800024b0 <etext+0x4b0>
    8000073e:	3ea000ef          	jal	80000b28 <printf>
        destroy_pagetable(pt);
    80000742:	8522                	mv	a0,s0
    80000744:	7402                	ld	s0,32(sp)
    80000746:	64e2                	ld	s1,24(sp)
}
    80000748:	70a2                	ld	ra,40(sp)
    8000074a:	6145                	addi	sp,sp,48
        destroy_pagetable(pt);
    8000074c:	11b0006f          	j	80001066 <destroy_pagetable>

0000000080000750 <test_virtual_memory>:

// 测试虚拟内存激活
void test_virtual_memory(void) {
    80000750:	1141                	addi	sp,sp,-16
    printf("\n=== 虚拟内存系统测试 ===\n");
    80000752:	00002517          	auipc	a0,0x2
    80000756:	f0e50513          	addi	a0,a0,-242 # 80002660 <etext+0x660>
void test_virtual_memory(void) {
    8000075a:	e406                	sd	ra,8(sp)
    printf("\n=== 虚拟内存系统测试 ===\n");
    8000075c:	3cc000ef          	jal	80000b28 <printf>
    
    printf("启用分页前的状态:\n");
    80000760:	00002517          	auipc	a0,0x2
    80000764:	f2850513          	addi	a0,a0,-216 # 80002688 <etext+0x688>
    80000768:	3c0000ef          	jal	80000b28 <printf>
// 内联汇编函数：读写satp寄存器
static inline uint64
r_satp()
{
  uint64 x;
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000076c:	180025f3          	csrr	a1,satp
    printf("当前satp值: 0x%p\n", (void*)r_satp());
    80000770:	00002517          	auipc	a0,0x2
    80000774:	f3850513          	addi	a0,a0,-200 # 800026a8 <etext+0x6a8>
    80000778:	3b0000ef          	jal	80000b28 <printf>
    
    // 显示内存统计
    print_memory_stats();
    8000077c:	c51ff0ef          	jal	800003cc <print_memory_stats>
    
    // 初始化并激活虚拟内存
    printf("\n正在启用虚拟内存...\n");
    80000780:	00002517          	auipc	a0,0x2
    80000784:	f4050513          	addi	a0,a0,-192 # 800026c0 <etext+0x6c0>
    80000788:	3a0000ef          	jal	80000b28 <printf>
    kvminit();
    8000078c:	5f7000ef          	jal	80001582 <kvminit>
    
    if (kernel_pagetable == 0) {
    80000790:	0000c797          	auipc	a5,0xc
    80000794:	8707b783          	ld	a5,-1936(a5) # 8000c000 <kernel_pagetable>
    80000798:	cbb1                	beqz	a5,800007ec <test_virtual_memory+0x9c>
        printf("ERROR: 内核页表初始化失败\n");
        return;
    }
    
    kvminithart();
    8000079a:	635000ef          	jal	800015ce <kvminithart>
    
    printf("\n启用分页后的状态:\n");
    8000079e:	00002517          	auipc	a0,0x2
    800007a2:	f6a50513          	addi	a0,a0,-150 # 80002708 <etext+0x708>
    800007a6:	382000ef          	jal	80000b28 <printf>
    800007aa:	180025f3          	csrr	a1,satp
    printf("当前satp值: 0x%p\n", (void*)r_satp());
    800007ae:	00002517          	auipc	a0,0x2
    800007b2:	efa50513          	addi	a0,a0,-262 # 800026a8 <etext+0x6a8>
    800007b6:	372000ef          	jal	80000b28 <printf>
    
    // 测试内核代码仍然可执行
    printf("✓ 内核代码仍然可执行\n");
    800007ba:	00002517          	auipc	a0,0x2
    800007be:	f6e50513          	addi	a0,a0,-146 # 80002728 <etext+0x728>
    800007c2:	366000ef          	jal	80000b28 <printf>
    
    // 测试内核数据仍然可访问
    printf("✓ 内核数据仍然可访问\n");
    800007c6:	00002517          	auipc	a0,0x2
    800007ca:	f8a50513          	addi	a0,a0,-118 # 80002750 <etext+0x750>
    800007ce:	35a000ef          	jal	80000b28 <printf>
    
    // 测试设备访问仍然正常
    printf("✓ 设备访问仍然正常\n");
    800007d2:	00002517          	auipc	a0,0x2
    800007d6:	fa650513          	addi	a0,a0,-90 # 80002778 <etext+0x778>
    800007da:	34e000ef          	jal	80000b28 <printf>
    
    printf("虚拟内存系统测试完成\n");
}
    800007de:	60a2                	ld	ra,8(sp)
    printf("虚拟内存系统测试完成\n");
    800007e0:	00002517          	auipc	a0,0x2
    800007e4:	fb850513          	addi	a0,a0,-72 # 80002798 <etext+0x798>
}
    800007e8:	0141                	addi	sp,sp,16
    printf("虚拟内存系统测试完成\n");
    800007ea:	ae3d                	j	80000b28 <printf>
}
    800007ec:	60a2                	ld	ra,8(sp)
        printf("ERROR: 内核页表初始化失败\n");
    800007ee:	00002517          	auipc	a0,0x2
    800007f2:	ef250513          	addi	a0,a0,-270 # 800026e0 <etext+0x6e0>
}
    800007f6:	0141                	addi	sp,sp,16
        printf("ERROR: 内核页表初始化失败\n");
    800007f8:	ae05                	j	80000b28 <printf>

00000000800007fa <show_pagetable_demo>:

// 展示页表结构（简化版）
void show_pagetable_demo(void) {
    800007fa:	7179                	addi	sp,sp,-48
    printf("\n=== 页表结构演示 ===\n");
    800007fc:	00002517          	auipc	a0,0x2
    80000800:	fbc50513          	addi	a0,a0,-68 # 800027b8 <etext+0x7b8>
void show_pagetable_demo(void) {
    80000804:	e84a                	sd	s2,16(sp)
    80000806:	f406                	sd	ra,40(sp)
    
    if (kernel_pagetable == 0) {
    80000808:	0000b917          	auipc	s2,0xb
    8000080c:	7f890913          	addi	s2,s2,2040 # 8000c000 <kernel_pagetable>
    printf("\n=== 页表结构演示 ===\n");
    80000810:	318000ef          	jal	80000b28 <printf>
    if (kernel_pagetable == 0) {
    80000814:	00093583          	ld	a1,0(s2)
    80000818:	c5f9                	beqz	a1,800008e6 <show_pagetable_demo+0xec>
        printf("内核页表未初始化\n");
        return;
    }
    
    printf("内核页表根地址: 0x%p\n", kernel_pagetable);
    8000081a:	00002517          	auipc	a0,0x2
    8000081e:	fde50513          	addi	a0,a0,-34 # 800027f8 <etext+0x7f8>
    80000822:	ec26                	sd	s1,24(sp)
    80000824:	e44e                	sd	s3,8(sp)
    80000826:	f022                	sd	s0,32(sp)
    80000828:	300000ef          	jal	80000b28 <printf>
    printf("页表结构（仅显示前几个有效项）:\n");
    8000082c:	00002517          	auipc	a0,0x2
    80000830:	fec50513          	addi	a0,a0,-20 # 80002818 <etext+0x818>
    80000834:	2f4000ef          	jal	80000b28 <printf>
    80000838:	4481                	li	s1,0
    
    // 简单显示页表的前几个项
    for (int i = 0; i < 10; i++) {
    8000083a:	49a9                	li	s3,10
    8000083c:	a021                	j	80000844 <show_pagetable_demo+0x4a>
    8000083e:	0485                	addi	s1,s1,1
    80000840:	05348b63          	beq	s1,s3,80000896 <show_pagetable_demo+0x9c>
        pte_t pte = kernel_pagetable[i];
    80000844:	00093783          	ld	a5,0(s2)
    80000848:	00349713          	slli	a4,s1,0x3
    8000084c:	97ba                	add	a5,a5,a4
    8000084e:	6380                	ld	s0,0(a5)
        if (pte & PTE_V) {
    80000850:	00147793          	andi	a5,s0,1
    80000854:	d7ed                	beqz	a5,8000083e <show_pagetable_demo+0x44>
            printf("  [%d] PTE=0x%p -> PA=0x%p [", i, (void*)pte, (void*)PTE2PA(pte));
    80000856:	00a45693          	srli	a3,s0,0xa
    8000085a:	06b2                	slli	a3,a3,0xc
    8000085c:	8622                	mv	a2,s0
    8000085e:	0004859b          	sext.w	a1,s1
    80000862:	00002517          	auipc	a0,0x2
    80000866:	fe650513          	addi	a0,a0,-26 # 80002848 <etext+0x848>
    8000086a:	2be000ef          	jal	80000b28 <printf>
            if (pte & PTE_R) printf("R");
    8000086e:	00247793          	andi	a5,s0,2
    80000872:	eb8d                	bnez	a5,800008a4 <show_pagetable_demo+0xaa>
            if (pte & PTE_W) printf("W");
    80000874:	00447793          	andi	a5,s0,4
    80000878:	ef9d                	bnez	a5,800008b6 <show_pagetable_demo+0xbc>
            if (pte & PTE_X) printf("X");
    8000087a:	00847793          	andi	a5,s0,8
    8000087e:	e7a9                	bnez	a5,800008c8 <show_pagetable_demo+0xce>
            if (pte & PTE_U) printf("U");
    80000880:	8841                	andi	s0,s0,16
    80000882:	e839                	bnez	s0,800008d8 <show_pagetable_demo+0xde>
            printf("]\n");
    80000884:	00002517          	auipc	a0,0x2
    80000888:	00450513          	addi	a0,a0,4 # 80002888 <etext+0x888>
    for (int i = 0; i < 10; i++) {
    8000088c:	0485                	addi	s1,s1,1
            printf("]\n");
    8000088e:	29a000ef          	jal	80000b28 <printf>
    for (int i = 0; i < 10; i++) {
    80000892:	fb3499e3          	bne	s1,s3,80000844 <show_pagetable_demo+0x4a>
    80000896:	7402                	ld	s0,32(sp)
        }
    }
}
    80000898:	70a2                	ld	ra,40(sp)
    8000089a:	64e2                	ld	s1,24(sp)
    8000089c:	69a2                	ld	s3,8(sp)
    8000089e:	6942                	ld	s2,16(sp)
    800008a0:	6145                	addi	sp,sp,48
    800008a2:	8082                	ret
            if (pte & PTE_R) printf("R");
    800008a4:	00002517          	auipc	a0,0x2
    800008a8:	fc450513          	addi	a0,a0,-60 # 80002868 <etext+0x868>
    800008ac:	27c000ef          	jal	80000b28 <printf>
            if (pte & PTE_W) printf("W");
    800008b0:	00447793          	andi	a5,s0,4
    800008b4:	d3f9                	beqz	a5,8000087a <show_pagetable_demo+0x80>
    800008b6:	00002517          	auipc	a0,0x2
    800008ba:	fba50513          	addi	a0,a0,-70 # 80002870 <etext+0x870>
    800008be:	26a000ef          	jal	80000b28 <printf>
            if (pte & PTE_X) printf("X");
    800008c2:	00847793          	andi	a5,s0,8
    800008c6:	dfcd                	beqz	a5,80000880 <show_pagetable_demo+0x86>
    800008c8:	00002517          	auipc	a0,0x2
    800008cc:	fb050513          	addi	a0,a0,-80 # 80002878 <etext+0x878>
            if (pte & PTE_U) printf("U");
    800008d0:	8841                	andi	s0,s0,16
            if (pte & PTE_X) printf("X");
    800008d2:	256000ef          	jal	80000b28 <printf>
            if (pte & PTE_U) printf("U");
    800008d6:	d45d                	beqz	s0,80000884 <show_pagetable_demo+0x8a>
    800008d8:	00002517          	auipc	a0,0x2
    800008dc:	fa850513          	addi	a0,a0,-88 # 80002880 <etext+0x880>
    800008e0:	248000ef          	jal	80000b28 <printf>
    800008e4:	b745                	j	80000884 <show_pagetable_demo+0x8a>
}
    800008e6:	70a2                	ld	ra,40(sp)
    800008e8:	6942                	ld	s2,16(sp)
        printf("内核页表未初始化\n");
    800008ea:	00002517          	auipc	a0,0x2
    800008ee:	eee50513          	addi	a0,a0,-274 # 800027d8 <etext+0x7d8>
}
    800008f2:	6145                	addi	sp,sp,48
        printf("内核页表未初始化\n");
    800008f4:	ac15                	j	80000b28 <printf>

00000000800008f6 <start>:


// C语言入口点，从entry.S跳转而来
void
start(void)
{
    800008f6:	1141                	addi	sp,sp,-16
    800008f8:	e406                	sd	ra,8(sp)
    // 初始化printf系统
    printf_init();
    800008fa:	65e000ef          	jal	80000f58 <printf_init>
    
    // 清屏并输出欢迎信息
    clear_screen();
    800008fe:	fc0ff0ef          	jal	800000be <clear_screen>
    printf("=====================================\n");
    80000902:	00002517          	auipc	a0,0x2
    80000906:	f8e50513          	addi	a0,a0,-114 # 80002890 <etext+0x890>
    8000090a:	21e000ef          	jal	80000b28 <printf>
    printf("     实验3：页表与内存管理测试       \n");
    8000090e:	00002517          	auipc	a0,0x2
    80000912:	faa50513          	addi	a0,a0,-86 # 800028b8 <etext+0x8b8>
    80000916:	212000ef          	jal	80000b28 <printf>
    printf("=====================================\n");
    8000091a:	00002517          	auipc	a0,0x2
    8000091e:	f7650513          	addi	a0,a0,-138 # 80002890 <etext+0x890>
    80000922:	206000ef          	jal	80000b28 <printf>
    
    
    // 初始化物理内存管理器
    printf("\n=== 第1步：初始化物理内存管理器 ===\n");
    80000926:	00002517          	auipc	a0,0x2
    8000092a:	fca50513          	addi	a0,a0,-54 # 800028f0 <etext+0x8f0>
    8000092e:	1fa000ef          	jal	80000b28 <printf>
    pmm_init();
    80000932:	98bff0ef          	jal	800002bc <pmm_init>
    
    // 测试物理内存分配器
    test_physical_memory();
    80000936:	b67ff0ef          	jal	8000049c <test_physical_memory>
    
    // 测试页表管理系统
    test_pagetable();
    8000093a:	cabff0ef          	jal	800005e4 <test_pagetable>
    
    // 测试虚拟内存系统
    test_virtual_memory();
    8000093e:	e13ff0ef          	jal	80000750 <test_virtual_memory>
    
    // 展示页表结构
    show_pagetable_demo();
    80000942:	eb9ff0ef          	jal	800007fa <show_pagetable_demo>
    
    // 最终内存统计
    printf("\n=== 最终内存统计 ===\n");
    80000946:	00002517          	auipc	a0,0x2
    8000094a:	fe250513          	addi	a0,a0,-30 # 80002928 <etext+0x928>
    8000094e:	1da000ef          	jal	80000b28 <printf>
    print_memory_stats();
    80000952:	a7bff0ef          	jal	800003cc <print_memory_stats>
    
    // 总结
    printf("\n=====================================\n");
    80000956:	00002517          	auipc	a0,0x2
    8000095a:	ff250513          	addi	a0,a0,-14 # 80002948 <etext+0x948>
    8000095e:	1ca000ef          	jal	80000b28 <printf>
    printf("        实验3测试全部完成!           \n");
    80000962:	00002517          	auipc	a0,0x2
    80000966:	00e50513          	addi	a0,a0,14 # 80002970 <etext+0x970>
    8000096a:	1be000ef          	jal	80000b28 <printf>
    printf("=====================================\n");
    8000096e:	00002517          	auipc	a0,0x2
    80000972:	f2250513          	addi	a0,a0,-222 # 80002890 <etext+0x890>
    80000976:	1b2000ef          	jal	80000b28 <printf>
    printf("已实现功能:\n");
    8000097a:	00002517          	auipc	a0,0x2
    8000097e:	02650513          	addi	a0,a0,38 # 800029a0 <etext+0x9a0>
    80000982:	1a6000ef          	jal	80000b28 <printf>
    printf("✓ Sv39页表机制理解和实现\n");
    80000986:	00002517          	auipc	a0,0x2
    8000098a:	03250513          	addi	a0,a0,50 # 800029b8 <etext+0x9b8>
    8000098e:	19a000ef          	jal	80000b28 <printf>
    printf("✓ 物理内存分配器 (pmm_init, alloc_page, free_page)\n");
    80000992:	00002517          	auipc	a0,0x2
    80000996:	04e50513          	addi	a0,a0,78 # 800029e0 <etext+0x9e0>
    8000099a:	18e000ef          	jal	80000b28 <printf>
    printf("✓ 页表管理系统 (create_pagetable, map_page, walk)\n");
    8000099e:	00002517          	auipc	a0,0x2
    800009a2:	08250513          	addi	a0,a0,130 # 80002a20 <etext+0xa20>
    800009a6:	182000ef          	jal	80000b28 <printf>
    printf("✓ 虚拟内存激活 (kvminit, kvminithart)\n");
    800009aa:	00002517          	auipc	a0,0x2
    800009ae:	0b650513          	addi	a0,a0,182 # 80002a60 <etext+0xa60>
    800009b2:	176000ef          	jal	80000b28 <printf>
    printf("✓ 地址转换和权限管理\n");
    800009b6:	00002517          	auipc	a0,0x2
    800009ba:	0da50513          	addi	a0,a0,218 # 80002a90 <etext+0xa90>
    800009be:	16a000ef          	jal	80000b28 <printf>
    printf("✓ 内存统计和调试功能\n\n");
    800009c2:	00002517          	auipc	a0,0x2
    800009c6:	0f650513          	addi	a0,a0,246 # 80002ab8 <etext+0xab8>
    800009ca:	15e000ef          	jal	80000b28 <printf>
    
    printf("关键技术点验证:\n");
    800009ce:	00002517          	auipc	a0,0x2
    800009d2:	11250513          	addi	a0,a0,274 # 80002ae0 <etext+0xae0>
    800009d6:	152000ef          	jal	80000b28 <printf>
    printf("• 39位虚拟地址三级页表遍历\n");
    800009da:	00002517          	auipc	a0,0x2
    800009de:	11e50513          	addi	a0,a0,286 # 80002af8 <etext+0xaf8>
    800009e2:	146000ef          	jal	80000b28 <printf>
    printf("• 物理页面链表管理\n");
    800009e6:	00002517          	auipc	a0,0x2
    800009ea:	14250513          	addi	a0,a0,322 # 80002b28 <etext+0xb28>
    800009ee:	13a000ef          	jal	80000b28 <printf>
    printf("• PTE权限位设置和检查\n");
    800009f2:	00002517          	auipc	a0,0x2
    800009f6:	15650513          	addi	a0,a0,342 # 80002b48 <etext+0xb48>
    800009fa:	12e000ef          	jal	80000b28 <printf>
    printf("• satp寄存器配置和TLB刷新\n");
    800009fe:	00002517          	auipc	a0,0x2
    80000a02:	17250513          	addi	a0,a0,370 # 80002b70 <etext+0xb70>
    80000a06:	122000ef          	jal	80000b28 <printf>
    printf("• 内核恒等映射建立\n");
    80000a0a:	00002517          	auipc	a0,0x2
    80000a0e:	18e50513          	addi	a0,a0,398 # 80002b98 <etext+0xb98>
    80000a12:	116000ef          	jal	80000b28 <printf>
    printf("• 内存分配统计和泄漏检测\n\n");
    80000a16:	00002517          	auipc	a0,0x2
    80000a1a:	1a250513          	addi	a0,a0,418 # 80002bb8 <etext+0xbb8>
    80000a1e:	10a000ef          	jal	80000b28 <printf>
    
    // 进入空循环，防止程序退出
    printf("系统已就绪，进入待机状态...\n");
    80000a22:	00002517          	auipc	a0,0x2
    80000a26:	1be50513          	addi	a0,a0,446 # 80002be0 <etext+0xbe0>
    80000a2a:	0fe000ef          	jal	80000b28 <printf>
    while(1) {
        // 空循环或低功耗等待
        asm volatile("wfi");  // wait for interrupt，低功耗等待
    80000a2e:	10500073          	wfi
    80000a32:	10500073          	wfi
    while(1) {
    80000a36:	bfe5                	j	80000a2e <start+0x138>

0000000080000a38 <print_number>:
#define COLOR_WHITE      7

// 数字转换函数 - 将数字转换为指定进制的字符串
static void 
print_number(long long num, int base, int is_signed) 
{
    80000a38:	7139                	addi	sp,sp,-64
    80000a3a:	fc06                	sd	ra,56(sp)
    80000a3c:	f822                	sd	s0,48(sp)
    80000a3e:	f426                	sd	s1,40(sp)
    int idx = 0;
    unsigned long long unum;
    
    // 处理符号问题
    int negative = 0;
    if (is_signed && num < 0) {
    80000a40:	06055763          	bgez	a0,80000aae <print_number+0x76>
    80000a44:	8a05                	andi	a2,a2,1
    80000a46:	c625                	beqz	a2,80000aae <print_number+0x76>
        negative = 1;
        unum = (unsigned long long)(-num);  // 转为正数处理
    80000a48:	40a00533          	neg	a0,a0
        negative = 1;
    80000a4c:	4305                	li	t1,1
    // 处理特殊情况: 0
    if (unum == 0) {
        buf[idx++] = '0';
    } else {
        // 将数字转换为字符，从低位到高位
        while (unum != 0) {
    80000a4e:	840a                	mv	s0,sp
    80000a50:	868a                	mv	a3,sp
    int idx = 0;
    80000a52:	4701                	li	a4,0
    80000a54:	00002897          	auipc	a7,0x2
    80000a58:	6fc88893          	addi	a7,a7,1788 # 80003150 <digits>
            buf[idx++] = digits[unum % base];
    80000a5c:	02b577b3          	remu	a5,a0,a1
    80000a60:	882a                	mv	a6,a0
    80000a62:	863a                	mv	a2,a4
        while (unum != 0) {
    80000a64:	0685                	addi	a3,a3,1
            buf[idx++] = digits[unum % base];
    80000a66:	2705                	addiw	a4,a4,1
    80000a68:	97c6                	add	a5,a5,a7
    80000a6a:	0007c783          	lbu	a5,0(a5)
            unum /= base;
    80000a6e:	02b55533          	divu	a0,a0,a1
            buf[idx++] = digits[unum % base];
    80000a72:	fef68fa3          	sb	a5,-1(a3)
        while (unum != 0) {
    80000a76:	feb873e3          	bgeu	a6,a1,80000a5c <print_number+0x24>
        }
    }
    
    // 添加负号（如果需要）
    if (negative) {
    80000a7a:	04030263          	beqz	t1,80000abe <print_number+0x86>
        buf[idx++] = '-';
    80000a7e:	970a                	add	a4,a4,sp
    80000a80:	02d00793          	li	a5,45
    80000a84:	2609                	addiw	a2,a2,2
    80000a86:	00f70023          	sb	a5,0(a4)
    }
    
    // 反向输出字符
    while (idx > 0) {
    80000a8a:	367d                	addiw	a2,a2,-1
    80000a8c:	1602                	slli	a2,a2,0x20
    80000a8e:	9201                	srli	a2,a2,0x20
    80000a90:	fff10493          	addi	s1,sp,-1
    80000a94:	9432                	add	s0,s0,a2
        console_putc(buf[--idx]);
    80000a96:	00044503          	lbu	a0,0(s0)
    while (idx > 0) {
    80000a9a:	147d                	addi	s0,s0,-1
        console_putc(buf[--idx]);
    80000a9c:	d88ff0ef          	jal	80000024 <console_putc>
    while (idx > 0) {
    80000aa0:	fe941be3          	bne	s0,s1,80000a96 <print_number+0x5e>
    }
}
    80000aa4:	70e2                	ld	ra,56(sp)
    80000aa6:	7442                	ld	s0,48(sp)
    80000aa8:	74a2                	ld	s1,40(sp)
    80000aaa:	6121                	addi	sp,sp,64
    80000aac:	8082                	ret
    if (unum == 0) {
    80000aae:	e911                	bnez	a0,80000ac2 <print_number+0x8a>
        buf[idx++] = '0';
    80000ab0:	03000793          	li	a5,48
    80000ab4:	00f10023          	sb	a5,0(sp)
    80000ab8:	4605                	li	a2,1
    80000aba:	840a                	mv	s0,sp
    80000abc:	b7f9                	j	80000a8a <print_number+0x52>
    80000abe:	863a                	mv	a2,a4
    80000ac0:	b7e9                	j	80000a8a <print_number+0x52>
    int negative = 0;
    80000ac2:	4301                	li	t1,0
    80000ac4:	b769                	j	80000a4e <print_number+0x16>

0000000080000ac6 <print_ptr>:

// 打印指针地址
static void 
print_ptr(uint64 ptr) 
{
    80000ac6:	7179                	addi	sp,sp,-48
    80000ac8:	ec26                	sd	s1,24(sp)
    80000aca:	84aa                	mv	s1,a0
    console_puts("0x");
    80000acc:	00002517          	auipc	a0,0x2
    80000ad0:	14450513          	addi	a0,a0,324 # 80002c10 <etext+0xc10>
{
    80000ad4:	f022                	sd	s0,32(sp)
    80000ad6:	f406                	sd	ra,40(sp)
    80000ad8:	e84a                	sd	s2,16(sp)
    80000ada:	e44e                	sd	s3,8(sp)
    // 对于64位指针，我们需要输出16个十六进制数字
    int i;
    int leading_zeros = 1;  // 是否跳过前导零
    
    // 从高位到低位，每4位一组转换为一个十六进制数字
    for (i = 60; i >= 0; i -= 4) {
    80000adc:	03c00413          	li	s0,60
    console_puts("0x");
    80000ae0:	d7aff0ef          	jal	8000005a <console_puts>
        int digit = (ptr >> i) & 0xf;
    80000ae4:	0084d7b3          	srl	a5,s1,s0
    80000ae8:	8bbd                	andi	a5,a5,15
        
        // 跳过前导零，但至少输出一个0
        if (digit == 0 && leading_zeros && i != 0) {
    80000aea:	e799                	bnez	a5,80000af8 <print_ptr+0x32>
    80000aec:	c411                	beqz	s0,80000af8 <print_ptr+0x32>
    for (i = 60; i >= 0; i -= 4) {
    80000aee:	3471                	addiw	s0,s0,-4
        int digit = (ptr >> i) & 0xf;
    80000af0:	0084d7b3          	srl	a5,s1,s0
    80000af4:	8bbd                	andi	a5,a5,15
        if (digit == 0 && leading_zeros && i != 0) {
    80000af6:	dbfd                	beqz	a5,80000aec <print_ptr+0x26>
    80000af8:	00002997          	auipc	s3,0x2
    80000afc:	65898993          	addi	s3,s3,1624 # 80003150 <digits>
    for (i = 60; i >= 0; i -= 4) {
    80000b00:	5971                	li	s2,-4
    80000b02:	a011                	j	80000b06 <print_ptr+0x40>
        int digit = (ptr >> i) & 0xf;
    80000b04:	8bbd                	andi	a5,a5,15
            continue;
        }
        
        leading_zeros = 0;
        console_putc(digits[digit]);
    80000b06:	97ce                	add	a5,a5,s3
    80000b08:	0007c503          	lbu	a0,0(a5)
    for (i = 60; i >= 0; i -= 4) {
    80000b0c:	3471                	addiw	s0,s0,-4
        console_putc(digits[digit]);
    80000b0e:	d16ff0ef          	jal	80000024 <console_putc>
        int digit = (ptr >> i) & 0xf;
    80000b12:	0084d7b3          	srl	a5,s1,s0
    for (i = 60; i >= 0; i -= 4) {
    80000b16:	ff2417e3          	bne	s0,s2,80000b04 <print_ptr+0x3e>
    }
}
    80000b1a:	70a2                	ld	ra,40(sp)
    80000b1c:	7402                	ld	s0,32(sp)
    80000b1e:	64e2                	ld	s1,24(sp)
    80000b20:	6942                	ld	s2,16(sp)
    80000b22:	69a2                	ld	s3,8(sp)
    80000b24:	6145                	addi	sp,sp,48
    80000b26:	8082                	ret

0000000080000b28 <printf>:

// 格式化输出到控制台
int 
printf(const char *fmt, ...) 
{
    80000b28:	7175                	addi	sp,sp,-144
    80000b2a:	e0a2                	sd	s0,64(sp)
    80000b2c:	fcbe                	sd	a5,120(sp)
    80000b2e:	e486                	sd	ra,72(sp)
    80000b30:	f84a                	sd	s2,48(sp)
    80000b32:	ecae                	sd	a1,88(sp)
    80000b34:	f0b2                	sd	a2,96(sp)
    80000b36:	f4b6                	sd	a3,104(sp)
    80000b38:	f8ba                	sd	a4,112(sp)
    80000b3a:	e142                	sd	a6,128(sp)
    80000b3c:	e546                	sd	a7,136(sp)
    80000b3e:	842a                	mv	s0,a0
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
    80000b40:	00054503          	lbu	a0,0(a0)
    va_start(ap, fmt);
    80000b44:	08bc                	addi	a5,sp,88
    80000b46:	e43e                	sd	a5,8(sp)
    for (const char *p = fmt; *p; p++) {
    80000b48:	0e050c63          	beqz	a0,80000c40 <printf+0x118>
    80000b4c:	f44e                	sd	s3,40(sp)
    80000b4e:	f052                	sd	s4,32(sp)
    80000b50:	ec56                	sd	s5,24(sp)
    80000b52:	fc26                	sd	s1,56(sp)
    int count = 0;
    80000b54:	4901                	li	s2,0
        if (*p != '%') {
    80000b56:	02500993          	li	s3,37
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
    80000b5a:	4ad5                	li	s5,21
    80000b5c:	00002a17          	auipc	s4,0x2
    80000b60:	544a0a13          	addi	s4,s4,1348 # 800030a0 <etext+0x10a0>
            count++;
    80000b64:	2905                	addiw	s2,s2,1
        if (*p != '%') {
    80000b66:	0b351e63          	bne	a0,s3,80000c22 <printf+0xfa>
        switch (*p) {
    80000b6a:	00144783          	lbu	a5,1(s0)
        p++;
    80000b6e:	00140493          	addi	s1,s0,1
        switch (*p) {
    80000b72:	0b378c63          	beq	a5,s3,80000c2a <printf+0x102>
    80000b76:	f9d7879b          	addiw	a5,a5,-99
    80000b7a:	0ff7f793          	zext.b	a5,a5
    80000b7e:	00fae763          	bltu	s5,a5,80000b8c <printf+0x64>
    80000b82:	078a                	slli	a5,a5,0x2
    80000b84:	97d2                	add	a5,a5,s4
    80000b86:	439c                	lw	a5,0(a5)
    80000b88:	97d2                	add	a5,a5,s4
    80000b8a:	8782                	jr	a5
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
    80000b8c:	02500513          	li	a0,37
    80000b90:	c94ff0ef          	jal	80000024 <console_putc>
                console_putc(*p);
    80000b94:	00144503          	lbu	a0,1(s0)
    80000b98:	c8cff0ef          	jal	80000024 <console_putc>
    for (const char *p = fmt; *p; p++) {
    80000b9c:	0014c503          	lbu	a0,1(s1)
    80000ba0:	00148413          	addi	s0,s1,1
    80000ba4:	f161                	bnez	a0,80000b64 <printf+0x3c>
        count++;
    }
    
    va_end(ap);
    return count;
}
    80000ba6:	60a6                	ld	ra,72(sp)
    80000ba8:	6406                	ld	s0,64(sp)
    80000baa:	74e2                	ld	s1,56(sp)
    80000bac:	79a2                	ld	s3,40(sp)
    80000bae:	7a02                	ld	s4,32(sp)
    80000bb0:	6ae2                	ld	s5,24(sp)
    80000bb2:	854a                	mv	a0,s2
    80000bb4:	7942                	ld	s2,48(sp)
    80000bb6:	6149                	addi	sp,sp,144
    80000bb8:	8082                	ret
                print_number(va_arg(ap, unsigned int), 16, 0);
    80000bba:	67a2                	ld	a5,8(sp)
    80000bbc:	4601                	li	a2,0
    80000bbe:	45c1                	li	a1,16
    80000bc0:	0007e503          	lwu	a0,0(a5)
    80000bc4:	07a1                	addi	a5,a5,8
    80000bc6:	e43e                	sd	a5,8(sp)
    80000bc8:	e71ff0ef          	jal	80000a38 <print_number>
                break;
    80000bcc:	bfc1                	j	80000b9c <printf+0x74>
                print_number(va_arg(ap, unsigned int), 10, 0);
    80000bce:	67a2                	ld	a5,8(sp)
    80000bd0:	4601                	li	a2,0
    80000bd2:	45a9                	li	a1,10
    80000bd4:	0007e503          	lwu	a0,0(a5)
    80000bd8:	07a1                	addi	a5,a5,8
    80000bda:	e43e                	sd	a5,8(sp)
    80000bdc:	e5dff0ef          	jal	80000a38 <print_number>
                break;
    80000be0:	bf75                	j	80000b9c <printf+0x74>
                    const char *s = va_arg(ap, const char *);
    80000be2:	67a2                	ld	a5,8(sp)
    80000be4:	6388                	ld	a0,0(a5)
    80000be6:	07a1                	addi	a5,a5,8
    80000be8:	e43e                	sd	a5,8(sp)
                    if (s == 0) {
    80000bea:	c521                	beqz	a0,80000c32 <printf+0x10a>
                        console_puts(s);
    80000bec:	c6eff0ef          	jal	8000005a <console_puts>
    80000bf0:	b775                	j	80000b9c <printf+0x74>
                print_ptr(va_arg(ap, uint64));
    80000bf2:	67a2                	ld	a5,8(sp)
    80000bf4:	6388                	ld	a0,0(a5)
    80000bf6:	07a1                	addi	a5,a5,8
    80000bf8:	e43e                	sd	a5,8(sp)
    80000bfa:	ecdff0ef          	jal	80000ac6 <print_ptr>
                break;
    80000bfe:	bf79                	j	80000b9c <printf+0x74>
                print_number(va_arg(ap, int), 10, 1);
    80000c00:	67a2                	ld	a5,8(sp)
    80000c02:	4605                	li	a2,1
    80000c04:	45a9                	li	a1,10
    80000c06:	4388                	lw	a0,0(a5)
    80000c08:	07a1                	addi	a5,a5,8
    80000c0a:	e43e                	sd	a5,8(sp)
    80000c0c:	e2dff0ef          	jal	80000a38 <print_number>
                break;
    80000c10:	b771                	j	80000b9c <printf+0x74>
                console_putc(va_arg(ap, int));
    80000c12:	67a2                	ld	a5,8(sp)
    80000c14:	0007c503          	lbu	a0,0(a5)
    80000c18:	07a1                	addi	a5,a5,8
    80000c1a:	e43e                	sd	a5,8(sp)
    80000c1c:	c08ff0ef          	jal	80000024 <console_putc>
                break;
    80000c20:	bfb5                	j	80000b9c <printf+0x74>
            console_putc(*p);
    80000c22:	c02ff0ef          	jal	80000024 <console_putc>
            continue;
    80000c26:	84a2                	mv	s1,s0
    80000c28:	bf95                	j	80000b9c <printf+0x74>
                console_putc('%');
    80000c2a:	854e                	mv	a0,s3
    80000c2c:	bf8ff0ef          	jal	80000024 <console_putc>
                break;
    80000c30:	b7b5                	j	80000b9c <printf+0x74>
                        console_puts("(null)");
    80000c32:	00002517          	auipc	a0,0x2
    80000c36:	fe650513          	addi	a0,a0,-26 # 80002c18 <etext+0xc18>
    80000c3a:	c20ff0ef          	jal	8000005a <console_puts>
    80000c3e:	bfb9                	j	80000b9c <printf+0x74>
}
    80000c40:	60a6                	ld	ra,72(sp)
    80000c42:	6406                	ld	s0,64(sp)
    int count = 0;
    80000c44:	4901                	li	s2,0
}
    80000c46:	854a                	mv	a0,s2
    80000c48:	7942                	ld	s2,48(sp)
    80000c4a:	6149                	addi	sp,sp,144
    80000c4c:	8082                	ret

0000000080000c4e <sprintf>:

// 格式化输出到缓冲区
int 
sprintf(char *buf, const char *fmt, ...) 
{
    80000c4e:	7151                	addi	sp,sp,-240
    80000c50:	edbe                	sd	a5,216(sp)
    80000c52:	f1c2                	sd	a6,224(sp)
    80000c54:	e1b2                	sd	a2,192(sp)
    80000c56:	e5b6                	sd	a3,200(sp)
    80000c58:	e9ba                	sd	a4,208(sp)
    80000c5a:	f5c6                	sd	a7,232(sp)
    va_start(ap, fmt);
    
    // 这是一个简化的实现，仅支持基本功能
    // 在实际项目中，应该复用printf的代码逻辑，但输出到缓冲区
    
    for (const char *p = fmt; *p; p++) {
    80000c5c:	0005c703          	lbu	a4,0(a1) # 1000000 <_entry-0x7f000000>
    va_start(ap, fmt);
    80000c60:	019c                	addi	a5,sp,192
    80000c62:	e43e                	sd	a5,8(sp)
{
    80000c64:	882a                	mv	a6,a0
    int count = 0;
    80000c66:	4501                	li	a0,0
    for (const char *p = fmt; *p; p++) {
    80000c68:	c725                	beqz	a4,80000cd0 <sprintf+0x82>
    80000c6a:	87c2                	mv	a5,a6
        if (*p != '%') {
    80000c6c:	02500893          	li	a7,37
            continue;
        }
        
        p++;
        
        switch (*p) {
    80000c70:	06400313          	li	t1,100
    80000c74:	00180e93          	addi	t4,a6,1
    80000c78:	07300e13          	li	t3,115
    80000c7c:	a821                	j	80000c94 <sprintf+0x46>
            buf[idx++] = *p;
    80000c7e:	2505                	addiw	a0,a0,1
    80000c80:	00e78023          	sb	a4,0(a5)
            continue;
    80000c84:	86ae                	mv	a3,a1
    80000c86:	00a807b3          	add	a5,a6,a0
    for (const char *p = fmt; *p; p++) {
    80000c8a:	0016c703          	lbu	a4,1(a3)
    80000c8e:	00168593          	addi	a1,a3,1
    80000c92:	cf15                	beqz	a4,80000cce <sprintf+0x80>
        p++;
    80000c94:	00158693          	addi	a3,a1,1
        if (*p != '%') {
    80000c98:	ff1713e3          	bne	a4,a7,80000c7e <sprintf+0x30>
        switch (*p) {
    80000c9c:	0015c703          	lbu	a4,1(a1)
    80000ca0:	06670b63          	beq	a4,t1,80000d16 <sprintf+0xc8>
    80000ca4:	05c70063          	beq	a4,t3,80000ce4 <sprintf+0x96>
    80000ca8:	03170863          	beq	a4,a7,80000cd8 <sprintf+0x8a>
                buf[idx++] = '%';
                count++;
                break;
                
            default:   // 未知格式符
                buf[idx++] = '%';
    80000cac:	01178023          	sb	a7,0(a5)
                buf[idx++] = *p;
    80000cb0:	0015c703          	lbu	a4,1(a1)
                buf[idx++] = '%';
    80000cb4:	0015079b          	addiw	a5,a0,1
                buf[idx++] = *p;
    80000cb8:	97c2                	add	a5,a5,a6
    80000cba:	2509                	addiw	a0,a0,2
    80000cbc:	00e78023          	sb	a4,0(a5)
                count += 2;
                break;
    80000cc0:	00a807b3          	add	a5,a6,a0
    for (const char *p = fmt; *p; p++) {
    80000cc4:	0016c703          	lbu	a4,1(a3)
    80000cc8:	00168593          	addi	a1,a3,1
    80000ccc:	f761                	bnez	a4,80000c94 <sprintf+0x46>
        }
    }
    
    // 添加字符串结束符
    buf[idx] = '\0';
    80000cce:	883e                	mv	a6,a5
    80000cd0:	00080023          	sb	zero,0(a6)
    
    va_end(ap);
    return count;
}
    80000cd4:	616d                	addi	sp,sp,240
    80000cd6:	8082                	ret
                buf[idx++] = '%';
    80000cd8:	2505                	addiw	a0,a0,1
    80000cda:	01178023          	sb	a7,0(a5)
                break;
    80000cde:	00a807b3          	add	a5,a6,a0
    80000ce2:	b765                	j	80000c8a <sprintf+0x3c>
                const char *s = va_arg(ap, const char *);
    80000ce4:	6722                	ld	a4,8(sp)
    80000ce6:	00073f03          	ld	t5,0(a4)
    80000cea:	0721                	addi	a4,a4,8
    80000cec:	e43a                	sd	a4,8(sp)
                if (s == 0) {
    80000cee:	0e0f0763          	beqz	t5,80000ddc <sprintf+0x18e>
                    while (*s) {
    80000cf2:	000f4603          	lbu	a2,0(t5)
    80000cf6:	85be                	mv	a1,a5
                const char *s = va_arg(ap, const char *);
    80000cf8:	877a                	mv	a4,t5
                    while (*s) {
    80000cfa:	da41                	beqz	a2,80000c8a <sprintf+0x3c>
                        buf[idx++] = *s++;
    80000cfc:	00c58023          	sb	a2,0(a1)
                    while (*s) {
    80000d00:	00174603          	lbu	a2,1(a4)
                        buf[idx++] = *s++;
    80000d04:	0705                	addi	a4,a4,1
                    while (*s) {
    80000d06:	0585                	addi	a1,a1,1
    80000d08:	fa75                	bnez	a2,80000cfc <sprintf+0xae>
                        buf[idx++] = *s++;
    80000d0a:	41e7073b          	subw	a4,a4,t5
    80000d0e:	9d39                	addw	a0,a0,a4
    80000d10:	00a807b3          	add	a5,a6,a0
    80000d14:	bf9d                	j	80000c8a <sprintf+0x3c>
                int num = va_arg(ap, int);
    80000d16:	6722                	ld	a4,8(sp)
    80000d18:	00072f03          	lw	t5,0(a4)
    80000d1c:	0721                	addi	a4,a4,8
    80000d1e:	e43a                	sd	a4,8(sp)
                if (num < 0) {
    80000d20:	020f4f63          	bltz	t5,80000d5e <sprintf+0x110>
                if (unum == 0) {
    80000d24:	0c0f1d63          	bnez	t5,80000dfe <sprintf+0x1b0>
                    temp_buf[temp_idx++] = '0';
    80000d28:	03000713          	li	a4,48
    80000d2c:	00e10823          	sb	a4,16(sp)
    80000d30:	4285                	li	t0,1
    80000d32:	0818                	addi	a4,sp,16
    80000d34:	fff2861b          	addiw	a2,t0,-1
    80000d38:	1602                	slli	a2,a2,0x20
    80000d3a:	9201                	srli	a2,a2,0x20
    80000d3c:	00ae85b3          	add	a1,t4,a0
    80000d40:	9732                	add	a4,a4,a2
    80000d42:	95b2                	add	a1,a1,a2
                    buf[idx++] = temp_buf[--temp_idx];
    80000d44:	00074603          	lbu	a2,0(a4)
                while (temp_idx > 0) {
    80000d48:	0785                	addi	a5,a5,1
    80000d4a:	177d                	addi	a4,a4,-1
                    buf[idx++] = temp_buf[--temp_idx];
    80000d4c:	fec78fa3          	sb	a2,-1(a5)
                while (temp_idx > 0) {
    80000d50:	feb79ae3          	bne	a5,a1,80000d44 <sprintf+0xf6>
    80000d54:	0055053b          	addw	a0,a0,t0
    80000d58:	00a807b3          	add	a5,a6,a0
    80000d5c:	b73d                	j	80000c8a <sprintf+0x3c>
    80000d5e:	ed52                	sd	s4,152(sp)
                    unum = -num;
    80000d60:	fd22                	sd	s0,184(sp)
    80000d62:	f926                	sd	s1,176(sp)
    80000d64:	f54a                	sd	s2,168(sp)
    80000d66:	f14e                	sd	s3,160(sp)
    80000d68:	41e00f3b          	negw	t5,t5
                    negative = 1;
    80000d6c:	4a05                	li	s4,1
                    while (unum > 0) {
    80000d6e:	0818                	addi	a4,sp,16
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000d70:	4485                	li	s1,1
    80000d72:	66666437          	lui	s0,0x66666
                    negative = 1;
    80000d76:	8fba                	mv	t6,a4
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000d78:	9c99                	subw	s1,s1,a4
    80000d7a:	66740413          	addi	s0,s0,1639 # 66666667 <_entry-0x19999999>
    80000d7e:	00002997          	auipc	s3,0x2
    80000d82:	3d298993          	addi	s3,s3,978 # 80003150 <digits>
                    while (unum > 0) {
    80000d86:	4925                	li	s2,9
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000d88:	028f05b3          	mul	a1,t5,s0
    80000d8c:	41ff561b          	sraiw	a2,t5,0x1f
    80000d90:	83fa                	mv	t2,t5
    80000d92:	01f482bb          	addw	t0,s1,t6
                    while (unum > 0) {
    80000d96:	0f85                	addi	t6,t6,1
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000d98:	9589                	srai	a1,a1,0x22
    80000d9a:	9d91                	subw	a1,a1,a2
    80000d9c:	0025961b          	slliw	a2,a1,0x2
    80000da0:	9e2d                	addw	a2,a2,a1
    80000da2:	0016161b          	slliw	a2,a2,0x1
    80000da6:	40cf063b          	subw	a2,t5,a2
    80000daa:	1602                	slli	a2,a2,0x20
    80000dac:	9201                	srli	a2,a2,0x20
    80000dae:	964e                	add	a2,a2,s3
    80000db0:	00064603          	lbu	a2,0(a2)
                        unum /= 10;
    80000db4:	8f2e                	mv	t5,a1
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000db6:	fecf8fa3          	sb	a2,-1(t6)
                    while (unum > 0) {
    80000dba:	fc7967e3          	bltu	s2,t2,80000d88 <sprintf+0x13a>
                if (negative) {
    80000dbe:	000a0963          	beqz	s4,80000dd0 <sprintf+0x182>
            buf[idx++] = *p;
    80000dc2:	2505                	addiw	a0,a0,1
                    buf[idx++] = '-';
    80000dc4:	02d00613          	li	a2,45
    80000dc8:	00c78023          	sb	a2,0(a5)
                while (temp_idx > 0) {
    80000dcc:	00a807b3          	add	a5,a6,a0
    80000dd0:	746a                	ld	s0,184(sp)
    80000dd2:	74ca                	ld	s1,176(sp)
    80000dd4:	792a                	ld	s2,168(sp)
    80000dd6:	798a                	ld	s3,160(sp)
    80000dd8:	6a6a                	ld	s4,152(sp)
    80000dda:	bfa9                	j	80000d34 <sprintf+0xe6>
    80000ddc:	00001617          	auipc	a2,0x1
    80000de0:	22460613          	addi	a2,a2,548 # 80002000 <etext>
                    for (int i = 0; null_str[i]; i++) {
    80000de4:	02800713          	li	a4,40
                        buf[idx++] = null_str[i];
    80000de8:	00e78023          	sb	a4,0(a5)
                    for (int i = 0; null_str[i]; i++) {
    80000dec:	00164703          	lbu	a4,1(a2)
                        buf[idx++] = null_str[i];
    80000df0:	2505                	addiw	a0,a0,1
                    for (int i = 0; null_str[i]; i++) {
    80000df2:	0785                	addi	a5,a5,1
    80000df4:	0605                	addi	a2,a2,1
    80000df6:	fb6d                	bnez	a4,80000de8 <sprintf+0x19a>
                break;
    80000df8:	00a807b3          	add	a5,a6,a0
    80000dfc:	b5e1                	j	80000cc4 <sprintf+0x76>
    80000dfe:	ed52                	sd	s4,152(sp)
    80000e00:	fd22                	sd	s0,184(sp)
    80000e02:	f926                	sd	s1,176(sp)
    80000e04:	f54a                	sd	s2,168(sp)
    80000e06:	f14e                	sd	s3,160(sp)
                int negative = 0;
    80000e08:	4a01                	li	s4,0
    80000e0a:	b795                	j	80000d6e <sprintf+0x120>

0000000080000e0c <printf_color>:

// 带颜色的格式化输出
int 
printf_color(int color, const char *fmt, ...) 
{
    80000e0c:	7119                	addi	sp,sp,-128
    80000e0e:	fc26                	sd	s1,56(sp)
    80000e10:	84aa                	mv	s1,a0
    // 设置前景色 - ANSI转义序列
    console_puts("\033[3");
    80000e12:	00002517          	auipc	a0,0x2
    80000e16:	e0e50513          	addi	a0,a0,-498 # 80002c20 <etext+0xc20>
{
    80000e1a:	f4be                	sd	a5,104(sp)
    80000e1c:	e486                	sd	ra,72(sp)
    80000e1e:	e8b2                	sd	a2,80(sp)
    80000e20:	ecb6                	sd	a3,88(sp)
    80000e22:	f0ba                	sd	a4,96(sp)
    80000e24:	f8c2                	sd	a6,112(sp)
    80000e26:	fcc6                	sd	a7,120(sp)
    80000e28:	e0a2                	sd	s0,64(sp)
    80000e2a:	f84a                	sd	s2,48(sp)
    80000e2c:	842e                	mv	s0,a1
    console_puts("\033[3");
    80000e2e:	a2cff0ef          	jal	8000005a <console_puts>
    console_putc('0' + (color & 0x7));  // 转换为0-7
    80000e32:	0074f513          	andi	a0,s1,7
    80000e36:	03050513          	addi	a0,a0,48
    80000e3a:	9eaff0ef          	jal	80000024 <console_putc>
    console_puts("m");
    80000e3e:	00002517          	auipc	a0,0x2
    80000e42:	dea50513          	addi	a0,a0,-534 # 80002c28 <etext+0xc28>
    80000e46:	a14ff0ef          	jal	8000005a <console_puts>
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
    80000e4a:	00044503          	lbu	a0,0(s0)
    va_start(ap, fmt);
    80000e4e:	089c                	addi	a5,sp,80
    80000e50:	e43e                	sd	a5,8(sp)
    for (const char *p = fmt; *p; p++) {
    80000e52:	10050163          	beqz	a0,80000f54 <printf_color+0x148>
    80000e56:	f44e                	sd	s3,40(sp)
    80000e58:	f052                	sd	s4,32(sp)
    80000e5a:	ec56                	sd	s5,24(sp)
    int count = 0;
    80000e5c:	4901                	li	s2,0
        if (*p != '%') {
    80000e5e:	02500993          	li	s3,37
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
    80000e62:	4ad5                	li	s5,21
    80000e64:	00002a17          	auipc	s4,0x2
    80000e68:	294a0a13          	addi	s4,s4,660 # 800030f8 <etext+0x10f8>
            count++;
    80000e6c:	2905                	addiw	s2,s2,1
        if (*p != '%') {
    80000e6e:	0d351463          	bne	a0,s3,80000f36 <printf_color+0x12a>
        switch (*p) {
    80000e72:	00144783          	lbu	a5,1(s0)
        p++;
    80000e76:	00140493          	addi	s1,s0,1
        switch (*p) {
    80000e7a:	0d378263          	beq	a5,s3,80000f3e <printf_color+0x132>
    80000e7e:	f9d7879b          	addiw	a5,a5,-99
    80000e82:	0ff7f793          	zext.b	a5,a5
    80000e86:	00fae763          	bltu	s5,a5,80000e94 <printf_color+0x88>
    80000e8a:	078a                	slli	a5,a5,0x2
    80000e8c:	97d2                	add	a5,a5,s4
    80000e8e:	439c                	lw	a5,0(a5)
    80000e90:	97d2                	add	a5,a5,s4
    80000e92:	8782                	jr	a5
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
    80000e94:	02500513          	li	a0,37
    80000e98:	98cff0ef          	jal	80000024 <console_putc>
                console_putc(*p);
    80000e9c:	00144503          	lbu	a0,1(s0)
    80000ea0:	984ff0ef          	jal	80000024 <console_putc>
    for (const char *p = fmt; *p; p++) {
    80000ea4:	0014c503          	lbu	a0,1(s1)
    80000ea8:	00148413          	addi	s0,s1,1
    80000eac:	f161                	bnez	a0,80000e6c <printf_color+0x60>
    80000eae:	79a2                	ld	s3,40(sp)
    80000eb0:	7a02                	ld	s4,32(sp)
    80000eb2:	6ae2                	ld	s5,24(sp)
    }
    
    va_end(ap);
    
    // 重置颜色
    console_puts("\033[0m");
    80000eb4:	00002517          	auipc	a0,0x2
    80000eb8:	d7c50513          	addi	a0,a0,-644 # 80002c30 <etext+0xc30>
    80000ebc:	99eff0ef          	jal	8000005a <console_puts>
    
    return count;
}
    80000ec0:	60a6                	ld	ra,72(sp)
    80000ec2:	6406                	ld	s0,64(sp)
    80000ec4:	74e2                	ld	s1,56(sp)
    80000ec6:	854a                	mv	a0,s2
    80000ec8:	7942                	ld	s2,48(sp)
    80000eca:	6109                	addi	sp,sp,128
    80000ecc:	8082                	ret
                print_number(va_arg(ap, unsigned int), 16, 0);
    80000ece:	67a2                	ld	a5,8(sp)
    80000ed0:	4601                	li	a2,0
    80000ed2:	45c1                	li	a1,16
    80000ed4:	0007e503          	lwu	a0,0(a5)
    80000ed8:	07a1                	addi	a5,a5,8
    80000eda:	e43e                	sd	a5,8(sp)
    80000edc:	b5dff0ef          	jal	80000a38 <print_number>
                break;
    80000ee0:	b7d1                	j	80000ea4 <printf_color+0x98>
                print_number(va_arg(ap, unsigned int), 10, 0);
    80000ee2:	67a2                	ld	a5,8(sp)
    80000ee4:	4601                	li	a2,0
    80000ee6:	45a9                	li	a1,10
    80000ee8:	0007e503          	lwu	a0,0(a5)
    80000eec:	07a1                	addi	a5,a5,8
    80000eee:	e43e                	sd	a5,8(sp)
    80000ef0:	b49ff0ef          	jal	80000a38 <print_number>
                break;
    80000ef4:	bf45                	j	80000ea4 <printf_color+0x98>
                    const char *s = va_arg(ap, const char *);
    80000ef6:	67a2                	ld	a5,8(sp)
    80000ef8:	6388                	ld	a0,0(a5)
    80000efa:	07a1                	addi	a5,a5,8
    80000efc:	e43e                	sd	a5,8(sp)
                    if (s == 0) {
    80000efe:	c521                	beqz	a0,80000f46 <printf_color+0x13a>
                        console_puts(s);
    80000f00:	95aff0ef          	jal	8000005a <console_puts>
    80000f04:	b745                	j	80000ea4 <printf_color+0x98>
                print_ptr(va_arg(ap, uint64));
    80000f06:	67a2                	ld	a5,8(sp)
    80000f08:	6388                	ld	a0,0(a5)
    80000f0a:	07a1                	addi	a5,a5,8
    80000f0c:	e43e                	sd	a5,8(sp)
    80000f0e:	bb9ff0ef          	jal	80000ac6 <print_ptr>
                break;
    80000f12:	bf49                	j	80000ea4 <printf_color+0x98>
                print_number(va_arg(ap, int), 10, 1);
    80000f14:	67a2                	ld	a5,8(sp)
    80000f16:	4605                	li	a2,1
    80000f18:	45a9                	li	a1,10
    80000f1a:	4388                	lw	a0,0(a5)
    80000f1c:	07a1                	addi	a5,a5,8
    80000f1e:	e43e                	sd	a5,8(sp)
    80000f20:	b19ff0ef          	jal	80000a38 <print_number>
                break;
    80000f24:	b741                	j	80000ea4 <printf_color+0x98>
                console_putc(va_arg(ap, int));
    80000f26:	67a2                	ld	a5,8(sp)
    80000f28:	0007c503          	lbu	a0,0(a5)
    80000f2c:	07a1                	addi	a5,a5,8
    80000f2e:	e43e                	sd	a5,8(sp)
    80000f30:	8f4ff0ef          	jal	80000024 <console_putc>
                break;
    80000f34:	bf85                	j	80000ea4 <printf_color+0x98>
            console_putc(*p);
    80000f36:	8eeff0ef          	jal	80000024 <console_putc>
            continue;
    80000f3a:	84a2                	mv	s1,s0
    80000f3c:	b7a5                	j	80000ea4 <printf_color+0x98>
                console_putc('%');
    80000f3e:	854e                	mv	a0,s3
    80000f40:	8e4ff0ef          	jal	80000024 <console_putc>
                break;
    80000f44:	b785                	j	80000ea4 <printf_color+0x98>
                        console_puts("(null)");
    80000f46:	00002517          	auipc	a0,0x2
    80000f4a:	cd250513          	addi	a0,a0,-814 # 80002c18 <etext+0xc18>
    80000f4e:	90cff0ef          	jal	8000005a <console_puts>
    80000f52:	bf89                	j	80000ea4 <printf_color+0x98>
    int count = 0;
    80000f54:	4901                	li	s2,0
    80000f56:	bfb9                	j	80000eb4 <printf_color+0xa8>

0000000080000f58 <printf_init>:
// 初始化printf系统
void 
printf_init(void) 
{
    // 初始化控制台
    console_init();
    80000f58:	8c8ff06f          	j	80000020 <console_init>

0000000080000f5c <uart_init>:
// 向寄存器写入值
static inline void 
uart_write_reg(int reg, uint8 v)
{
    volatile uint8 *p = (uint8*)UART0;
    p[reg] = v;
    80000f5c:	100007b7          	lui	a5,0x10000
    80000f60:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80000f64:	10000737          	lui	a4,0x10000
    80000f68:	468d                	li	a3,3
    80000f6a:	87ba                	mv	a5,a4
    80000f6c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    80000f70:	4705                	li	a4,1
    80000f72:	00e78123          	sb	a4,2(a5)
    // 设置8位数据位，1位停止位，无奇偶校验(8N1)
    uart_write_reg(LCR, 0x03);
    
    // 启用FIFO
    uart_write_reg(FCR, 0x01);
}
    80000f76:	8082                	ret

0000000080000f78 <uart_putc>:
    return p[reg];
    80000f78:	10000737          	lui	a4,0x10000
    80000f7c:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000f7e:	100006b7          	lui	a3,0x10000
    80000f82:	00074783          	lbu	a5,0(a4)
// 发送单个字符
void 
uart_putc(char c)
{
    // 等待发送缓冲区空闲
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
    80000f86:	0207f793          	andi	a5,a5,32
    80000f8a:	dfe5                	beqz	a5,80000f82 <uart_putc+0xa>
    p[reg] = v;
    80000f8c:	00a68023          	sb	a0,0(a3) # 10000000 <_entry-0x70000000>
        ;
    
    // 发送字符
    uart_write_reg(THR, c);
}
    80000f90:	8082                	ret

0000000080000f92 <uart_puts>:

// 发送字符串
void 
uart_puts(const char *s)
{
    while(*s != '\0') {
    80000f92:	00054683          	lbu	a3,0(a0)
    80000f96:	c28d                	beqz	a3,80000fb8 <uart_puts+0x26>
    return p[reg];
    80000f98:	10000737          	lui	a4,0x10000
    80000f9c:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000f9e:	10000637          	lui	a2,0x10000
        uart_putc(*s++);
    80000fa2:	0505                	addi	a0,a0,1
    return p[reg];
    80000fa4:	00074783          	lbu	a5,0(a4)
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
    80000fa8:	0207f793          	andi	a5,a5,32
    80000fac:	dfe5                	beqz	a5,80000fa4 <uart_puts+0x12>
    p[reg] = v;
    80000fae:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>
    while(*s != '\0') {
    80000fb2:	00054683          	lbu	a3,0(a0)
    80000fb6:	f6f5                	bnez	a3,80000fa2 <uart_puts+0x10>
    }
    80000fb8:	8082                	ret

0000000080000fba <walk_lookup.part.0>:
    }
    
    // 从根页表开始，逐级向下查找
    for (int level = 2; level > 0; level--) {
        // 计算当前级别的页表索引
        int index = PX(level, va);
    80000fba:	01e5d793          	srli	a5,a1,0x1e
        pte_t *pte = &pt[index];
        
        // 检查页表项是否有效
        if ((*pte & PTE_V) == 0) {
    80000fbe:	078e                	slli	a5,a5,0x3
    80000fc0:	953e                	add	a0,a0,a5
    80000fc2:	6118                	ld	a4,0(a0)
            return 0;  // 页表项无效，路径不存在
        }
        
        // 检查是否为中间级页表项（R/W/X都为0）
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    80000fc4:	4785                	li	a5,1
        if ((*pte & PTE_V) == 0) {
    80000fc6:	00f77693          	andi	a3,a4,15
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    80000fca:	02f69763          	bne	a3,a5,80000ff8 <walk_lookup.part.0+0x3e>
        int index = PX(level, va);
    80000fce:	0155d793          	srli	a5,a1,0x15
            return 0;  // 这是叶子页面，不应该在中间级出现
        }
        
        // 获取下一级页表的物理地址
        pt = (pagetable_t)PTE2PA(*pte);
    80000fd2:	8329                	srli	a4,a4,0xa
        pte_t *pte = &pt[index];
    80000fd4:	1ff7f793          	andi	a5,a5,511
        pt = (pagetable_t)PTE2PA(*pte);
    80000fd8:	0732                	slli	a4,a4,0xc
        if ((*pte & PTE_V) == 0) {
    80000fda:	078e                	slli	a5,a5,0x3
    80000fdc:	97ba                	add	a5,a5,a4
    80000fde:	6388                	ld	a0,0(a5)
    80000fe0:	00f57793          	andi	a5,a0,15
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    80000fe4:	00d79a63          	bne	a5,a3,80000ff8 <walk_lookup.part.0+0x3e>
    }
    
    // 返回叶子级页表项的地址
    return &pt[PX(0, va)];
    80000fe8:	81b1                	srli	a1,a1,0xc
    80000fea:	1ff5f593          	andi	a1,a1,511
        pt = (pagetable_t)PTE2PA(*pte);
    80000fee:	8129                	srli	a0,a0,0xa
    return &pt[PX(0, va)];
    80000ff0:	058e                	slli	a1,a1,0x3
        pt = (pagetable_t)PTE2PA(*pte);
    80000ff2:	0532                	slli	a0,a0,0xc
    return &pt[PX(0, va)];
    80000ff4:	952e                	add	a0,a0,a1
    80000ff6:	8082                	ret
        return 0;  // 地址超出范围
    80000ff8:	4501                	li	a0,0
}
    80000ffa:	8082                	ret

0000000080000ffc <destroy_pagetable.part.0>:
void destroy_pagetable(pagetable_t pt) {
    80000ffc:	7179                	addi	sp,sp,-48
    80000ffe:	ec26                	sd	s1,24(sp)
    80001000:	6485                	lui	s1,0x1
    80001002:	f022                	sd	s0,32(sp)
    80001004:	e84a                	sd	s2,16(sp)
    80001006:	e44e                	sd	s3,8(sp)
    80001008:	f406                	sd	ra,40(sp)
    8000100a:	89aa                	mv	s3,a0
    8000100c:	842a                	mv	s0,a0
    8000100e:	94aa                	add	s1,s1,a0
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001010:	4905                	li	s2,1
    80001012:	a021                	j	8000101a <destroy_pagetable.part.0+0x1e>
    for (int i = 0; i < 512; i++) {
    80001014:	0421                	addi	s0,s0,8
    80001016:	00940f63          	beq	s0,s1,80001034 <destroy_pagetable.part.0+0x38>
        pte_t pte = pt[i];
    8000101a:	6008                	ld	a0,0(s0)
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000101c:	00f57793          	andi	a5,a0,15
    80001020:	ff279ae3          	bne	a5,s2,80001014 <destroy_pagetable.part.0+0x18>
            uint64 child_pa = PTE2PA(pte);
    80001024:	8129                	srli	a0,a0,0xa
    80001026:	0532                	slli	a0,a0,0xc
    if (pt == 0) return;
    80001028:	d575                	beqz	a0,80001014 <destroy_pagetable.part.0+0x18>
    for (int i = 0; i < 512; i++) {
    8000102a:	0421                	addi	s0,s0,8
    8000102c:	fd1ff0ef          	jal	80000ffc <destroy_pagetable.part.0>
    80001030:	fe9415e3          	bne	s0,s1,8000101a <destroy_pagetable.part.0+0x1e>
}
    80001034:	7402                	ld	s0,32(sp)
    80001036:	70a2                	ld	ra,40(sp)
    80001038:	64e2                	ld	s1,24(sp)
    8000103a:	6942                	ld	s2,16(sp)
    free_page((void*)pt);
    8000103c:	854e                	mv	a0,s3
}
    8000103e:	69a2                	ld	s3,8(sp)
    80001040:	6145                	addi	sp,sp,48
    free_page((void*)pt);
    80001042:	9dcff06f          	j	8000021e <free_page>

0000000080001046 <create_pagetable>:
pagetable_t create_pagetable(void) {
    80001046:	1141                	addi	sp,sp,-16
    80001048:	e406                	sd	ra,8(sp)
    pt = (pagetable_t)alloc_page();
    8000104a:	9a4ff0ef          	jal	800001ee <alloc_page>
    if (pt == 0) {
    8000104e:	c909                	beqz	a0,80001060 <create_pagetable+0x1a>
    80001050:	6705                	lui	a4,0x1
    80001052:	972a                	add	a4,a4,a0
    80001054:	87aa                	mv	a5,a0
        pt[i] = 0;
    80001056:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
    8000105a:	07a1                	addi	a5,a5,8
    8000105c:	fee79de3          	bne	a5,a4,80001056 <create_pagetable+0x10>
}
    80001060:	60a2                	ld	ra,8(sp)
    80001062:	0141                	addi	sp,sp,16
    80001064:	8082                	ret

0000000080001066 <destroy_pagetable>:
    if (pt == 0) return;
    80001066:	c111                	beqz	a0,8000106a <destroy_pagetable+0x4>
    80001068:	bf51                	j	80000ffc <destroy_pagetable.part.0>
}
    8000106a:	8082                	ret

000000008000106c <walk_lookup>:
    if (va >= MAXVA) {
    8000106c:	57fd                	li	a5,-1
    8000106e:	83e9                	srli	a5,a5,0x1a
    80001070:	00b7e363          	bltu	a5,a1,80001076 <walk_lookup+0xa>
    80001074:	b799                	j	80000fba <walk_lookup.part.0>
}
    80001076:	4501                	li	a0,0
    80001078:	8082                	ret

000000008000107a <walk_create>:

// 页表遍历 - 创建模式（必要时创建新页表）
pte_t* walk_create(pagetable_t pt, uint64 va) {
    if (va >= MAXVA) {
    8000107a:	57fd                	li	a5,-1
pte_t* walk_create(pagetable_t pt, uint64 va) {
    8000107c:	7179                	addi	sp,sp,-48
    if (va >= MAXVA) {
    8000107e:	01a7d713          	srli	a4,a5,0x1a
    80001082:	4609                	li	a2,2
pte_t* walk_create(pagetable_t pt, uint64 va) {
    80001084:	f406                	sd	ra,40(sp)
    80001086:	87b2                	mv	a5,a2
    80001088:	4805                	li	a6,1
    if (va >= MAXVA) {
    8000108a:	08b76863          	bltu	a4,a1,8000111a <walk_create+0xa0>
        return 0;
    }
    
    // 从根页表开始，逐级向下查找或创建
    for (int level = 2; level > 0; level--) {
        int index = PX(level, va);
    8000108e:	0037969b          	slliw	a3,a5,0x3
    80001092:	9ebd                	addw	a3,a3,a5
    80001094:	26b1                	addiw	a3,a3,12
    80001096:	00d5d6b3          	srl	a3,a1,a3
        pte_t *pte = &pt[index];
    8000109a:	1ff6f693          	andi	a3,a3,511
    8000109e:	068e                	slli	a3,a3,0x3
    800010a0:	96aa                	add	a3,a3,a0
        
        if (*pte & PTE_V) {
    800010a2:	6288                	ld	a0,0(a3)
    800010a4:	00157713          	andi	a4,a0,1
    800010a8:	c705                	beqz	a4,800010d0 <walk_create+0x56>
            // 页表项已存在，检查是否为中间级页表项
            if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    800010aa:	00e57713          	andi	a4,a0,14
    800010ae:	ef35                	bnez	a4,8000112a <walk_create+0xb0>
                printf("walk_create: 遇到叶子页面在级别 %d\n", level);
                return 0;
            }
            // 获取下一级页表
            pt = (pagetable_t)PTE2PA(*pte);
    800010b0:	8129                	srli	a0,a0,0xa
    800010b2:	0532                	slli	a0,a0,0xc
    for (int level = 2; level > 0; level--) {
    800010b4:	4785                	li	a5,1
    800010b6:	01061b63          	bne	a2,a6,800010cc <walk_create+0x52>
        }
    }
    
    // 返回叶子级页表项的地址
    return &pt[PX(0, va)];
}
    800010ba:	70a2                	ld	ra,40(sp)
    return &pt[PX(0, va)];
    800010bc:	00c5d793          	srli	a5,a1,0xc
    800010c0:	1ff7f793          	andi	a5,a5,511
    800010c4:	078e                	slli	a5,a5,0x3
    800010c6:	953e                	add	a0,a0,a5
}
    800010c8:	6145                	addi	sp,sp,48
    800010ca:	8082                	ret
    800010cc:	863e                	mv	a2,a5
    800010ce:	b7c1                	j	8000108e <walk_create+0x14>
    800010d0:	ec2e                	sd	a1,24(sp)
    800010d2:	e432                	sd	a2,8(sp)
    800010d4:	e036                	sd	a3,0(sp)
    pt = (pagetable_t)alloc_page();
    800010d6:	e83e                	sd	a5,16(sp)
    800010d8:	916ff0ef          	jal	800001ee <alloc_page>
    if (pt == 0) {
    800010dc:	6682                	ld	a3,0(sp)
    800010de:	6622                	ld	a2,8(sp)
    800010e0:	65e2                	ld	a1,24(sp)
    800010e2:	4805                	li	a6,1
    800010e4:	c105                	beqz	a0,80001104 <walk_create+0x8a>
    800010e6:	6705                	lui	a4,0x1
    800010e8:	972a                	add	a4,a4,a0
    800010ea:	87aa                	mv	a5,a0
        pt[i] = 0;
    800010ec:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
    800010f0:	07a1                	addi	a5,a5,8
    800010f2:	fef71de3          	bne	a4,a5,800010ec <walk_create+0x72>
            *pte = PA2PTE((uint64)new_pt) | PTE_V;
    800010f6:	00c55793          	srli	a5,a0,0xc
    800010fa:	07aa                	slli	a5,a5,0xa
    800010fc:	0017e793          	ori	a5,a5,1
    80001100:	e29c                	sd	a5,0(a3)
            pt = new_pt;
    80001102:	bf4d                	j	800010b4 <walk_create+0x3a>
                printf("walk_create: 分配页表失败在级别 %d\n", level);
    80001104:	65c2                	ld	a1,16(sp)
    80001106:	00002517          	auipc	a0,0x2
    8000110a:	b8a50513          	addi	a0,a0,-1142 # 80002c90 <etext+0xc90>
    8000110e:	a1bff0ef          	jal	80000b28 <printf>
        return 0;
    80001112:	4501                	li	a0,0
}
    80001114:	70a2                	ld	ra,40(sp)
    80001116:	6145                	addi	sp,sp,48
    80001118:	8082                	ret
        printf("walk_create: 地址超出范围 0x%p\n", (void*)va);
    8000111a:	00002517          	auipc	a0,0x2
    8000111e:	b1e50513          	addi	a0,a0,-1250 # 80002c38 <etext+0xc38>
    80001122:	a07ff0ef          	jal	80000b28 <printf>
        return 0;
    80001126:	4501                	li	a0,0
    80001128:	b7f5                	j	80001114 <walk_create+0x9a>
                printf("walk_create: 遇到叶子页面在级别 %d\n", level);
    8000112a:	85be                	mv	a1,a5
    8000112c:	00002517          	auipc	a0,0x2
    80001130:	b3450513          	addi	a0,a0,-1228 # 80002c60 <etext+0xc60>
    80001134:	9f5ff0ef          	jal	80000b28 <printf>
        return 0;
    80001138:	4501                	li	a0,0
    8000113a:	bfe9                	j	80001114 <walk_create+0x9a>

000000008000113c <map_page>:
// 建立单页映射
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    pte_t *pte;
    
    // 检查地址对齐
    if ((va % PGSIZE) != 0) {
    8000113c:	6785                	lui	a5,0x1
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    8000113e:	1101                	addi	sp,sp,-32
    if ((va % PGSIZE) != 0) {
    80001140:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    80001142:	ec06                	sd	ra,24(sp)
    if ((va % PGSIZE) != 0) {
    80001144:	8fed                	and	a5,a5,a1
    80001146:	e7a9                	bnez	a5,80001190 <map_page+0x54>
        printf("map_page: 虚拟地址未对齐 0x%p\n", (void*)va);
        return -1;
    }
    
    if ((pa % PGSIZE) != 0) {
    80001148:	03461793          	slli	a5,a2,0x34
    8000114c:	eb8d                	bnez	a5,8000117e <map_page+0x42>
    8000114e:	e822                	sd	s0,16(sp)
    80001150:	e436                	sd	a3,8(sp)
    80001152:	e032                	sd	a2,0(sp)
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
        return -1;
    }
    
    // 获取页表项地址（必要时创建中间级页表）
    pte = walk_create(pt, va);
    80001154:	842e                	mv	s0,a1
    80001156:	f25ff0ef          	jal	8000107a <walk_create>
    if (pte == 0) {
    8000115a:	6602                	ld	a2,0(sp)
    8000115c:	66a2                	ld	a3,8(sp)
    8000115e:	cd31                	beqz	a0,800011ba <map_page+0x7e>
        printf("map_page: walk_create失败\n");
        return -1;
    }
    
    // 检查是否已经映射
    if (*pte & PTE_V) {
    80001160:	611c                	ld	a5,0(a0)
    80001162:	0017f713          	andi	a4,a5,1
    80001166:	ef0d                	bnez	a4,800011a0 <map_page+0x64>
               (void*)va, (void*)PTE2PA(*pte));
        return -1;
    }
    
    // 设置页表项
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001168:	8231                	srli	a2,a2,0xc
    8000116a:	062a                	slli	a2,a2,0xa
    8000116c:	8e55                	or	a2,a2,a3
    
    return 0;
    8000116e:	6442                	ld	s0,16(sp)
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001170:	00166613          	ori	a2,a2,1
    80001174:	e110                	sd	a2,0(a0)
    return 0;
    80001176:	4501                	li	a0,0
}
    80001178:	60e2                	ld	ra,24(sp)
    8000117a:	6105                	addi	sp,sp,32
    8000117c:	8082                	ret
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
    8000117e:	85b2                	mv	a1,a2
    80001180:	00002517          	auipc	a0,0x2
    80001184:	b6850513          	addi	a0,a0,-1176 # 80002ce8 <etext+0xce8>
    80001188:	9a1ff0ef          	jal	80000b28 <printf>
        return -1;
    8000118c:	557d                	li	a0,-1
    8000118e:	b7ed                	j	80001178 <map_page+0x3c>
        printf("map_page: 虚拟地址未对齐 0x%p\n", (void*)va);
    80001190:	00002517          	auipc	a0,0x2
    80001194:	b3050513          	addi	a0,a0,-1232 # 80002cc0 <etext+0xcc0>
    80001198:	991ff0ef          	jal	80000b28 <printf>
        return -1;
    8000119c:	557d                	li	a0,-1
    8000119e:	bfe9                	j	80001178 <map_page+0x3c>
               (void*)va, (void*)PTE2PA(*pte));
    800011a0:	83a9                	srli	a5,a5,0xa
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    800011a2:	85a2                	mv	a1,s0
    800011a4:	00c79613          	slli	a2,a5,0xc
    800011a8:	00002517          	auipc	a0,0x2
    800011ac:	b8850513          	addi	a0,a0,-1144 # 80002d30 <etext+0xd30>
    800011b0:	979ff0ef          	jal	80000b28 <printf>
        return -1;
    800011b4:	557d                	li	a0,-1
        return -1;
    800011b6:	6442                	ld	s0,16(sp)
    800011b8:	b7c1                	j	80001178 <map_page+0x3c>
        printf("map_page: walk_create失败\n");
    800011ba:	00002517          	auipc	a0,0x2
    800011be:	b5650513          	addi	a0,a0,-1194 # 80002d10 <etext+0xd10>
    800011c2:	967ff0ef          	jal	80000b28 <printf>
        return -1;
    800011c6:	557d                	li	a0,-1
        return -1;
    800011c8:	6442                	ld	s0,16(sp)
    800011ca:	b77d                	j	80001178 <map_page+0x3c>

00000000800011cc <map_range>:

// 建立连续页面映射
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    800011cc:	715d                	addi	sp,sp,-80
    800011ce:	f44e                	sd	s3,40(sp)
    uint64 a, last;
    
    // 检查对齐
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
    800011d0:	6985                	lui	s3,0x1
    800011d2:	00c5e7b3          	or	a5,a1,a2
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    800011d6:	fc26                	sd	s1,56(sp)
    800011d8:	84ae                	mv	s1,a1
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
    800011da:	fff98593          	addi	a1,s3,-1 # fff <_entry-0x7ffff001>
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    800011de:	e486                	sd	ra,72(sp)
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
    800011e0:	8fed                	and	a5,a5,a1
    800011e2:	e7c5                	bnez	a5,8000128a <map_range+0xbe>
        printf("map_range: 地址或大小未对齐\n");
        return -1;
    }
    
    if (size == 0) {
    800011e4:	ce21                	beqz	a2,8000123c <map_range+0x70>
    if ((pa % PGSIZE) != 0) {
    800011e6:	03469793          	slli	a5,a3,0x34
    800011ea:	efb9                	bnez	a5,80001248 <map_range+0x7c>
        return 0;
    }
    
    a = va;
    last = va + size - PGSIZE;
    800011ec:	80060613          	addi	a2,a2,-2048
    800011f0:	e0a2                	sd	s0,64(sp)
    800011f2:	80060613          	addi	a2,a2,-2048
    a = va;
    800011f6:	8426                	mv	s0,s1
    800011f8:	f84a                	sd	s2,48(sp)
    800011fa:	f052                	sd	s4,32(sp)
    800011fc:	ec56                	sd	s5,24(sp)
    800011fe:	8a2a                	mv	s4,a0
    80001200:	8aba                	mv	s5,a4
    last = va + size - PGSIZE;
    80001202:	94b2                	add	s1,s1,a2
    80001204:	40868933          	sub	s2,a3,s0
    80001208:	a011                	j	8000120c <map_range+0x40>
    
    // 逐页建立映射
    for (; ; a += PGSIZE, pa += PGSIZE) {
    8000120a:	944e                	add	s0,s0,s3
    pte = walk_create(pt, va);
    8000120c:	85a2                	mv	a1,s0
    8000120e:	8552                	mv	a0,s4
    80001210:	e6bff0ef          	jal	8000107a <walk_create>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001214:	012407b3          	add	a5,s0,s2
    80001218:	83b1                	srli	a5,a5,0xc
    8000121a:	07aa                	slli	a5,a5,0xa
    8000121c:	0157e7b3          	or	a5,a5,s5
    80001220:	0017e793          	ori	a5,a5,1
    if (pte == 0) {
    80001224:	c93d                	beqz	a0,8000129a <map_range+0xce>
    if (*pte & PTE_V) {
    80001226:	6118                	ld	a4,0(a0)
    80001228:	00177693          	andi	a3,a4,1
    8000122c:	ee95                	bnez	a3,80001268 <map_range+0x9c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000122e:	e11c                	sd	a5,0(a0)
            printf("map_range: 映射失败在地址 0x%p\n", (void*)a);
            // TODO: 这里应该清理已经建立的映射
            return -1;
        }
        
        if (a == last) {
    80001230:	fc849de3          	bne	s1,s0,8000120a <map_range+0x3e>
    80001234:	6406                	ld	s0,64(sp)
    80001236:	7942                	ld	s2,48(sp)
    80001238:	7a02                	ld	s4,32(sp)
    8000123a:	6ae2                	ld	s5,24(sp)
        return 0;
    8000123c:	4501                	li	a0,0
            break;
        }
    }
    
    return 0;
}
    8000123e:	60a6                	ld	ra,72(sp)
    80001240:	74e2                	ld	s1,56(sp)
    80001242:	79a2                	ld	s3,40(sp)
    80001244:	6161                	addi	sp,sp,80
    80001246:	8082                	ret
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
    80001248:	85b6                	mv	a1,a3
    8000124a:	00002517          	auipc	a0,0x2
    8000124e:	a9e50513          	addi	a0,a0,-1378 # 80002ce8 <etext+0xce8>
    80001252:	8d7ff0ef          	jal	80000b28 <printf>
            printf("map_range: 映射失败在地址 0x%p\n", (void*)a);
    80001256:	85a6                	mv	a1,s1
    80001258:	00002517          	auipc	a0,0x2
    8000125c:	b2850513          	addi	a0,a0,-1240 # 80002d80 <etext+0xd80>
    80001260:	8c9ff0ef          	jal	80000b28 <printf>
        return -1;
    80001264:	557d                	li	a0,-1
    80001266:	bfe1                	j	8000123e <map_range+0x72>
               (void*)va, (void*)PTE2PA(*pte));
    80001268:	8329                	srli	a4,a4,0xa
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    8000126a:	85a2                	mv	a1,s0
    8000126c:	00c71613          	slli	a2,a4,0xc
    80001270:	00002517          	auipc	a0,0x2
    80001274:	ac050513          	addi	a0,a0,-1344 # 80002d30 <etext+0xd30>
    80001278:	e422                	sd	s0,8(sp)
    8000127a:	8afff0ef          	jal	80000b28 <printf>
        return -1;
    8000127e:	65a2                	ld	a1,8(sp)
    80001280:	6406                	ld	s0,64(sp)
    80001282:	7942                	ld	s2,48(sp)
    80001284:	7a02                	ld	s4,32(sp)
    80001286:	6ae2                	ld	s5,24(sp)
    80001288:	bfc1                	j	80001258 <map_range+0x8c>
        printf("map_range: 地址或大小未对齐\n");
    8000128a:	00002517          	auipc	a0,0x2
    8000128e:	ace50513          	addi	a0,a0,-1330 # 80002d58 <etext+0xd58>
    80001292:	897ff0ef          	jal	80000b28 <printf>
        return -1;
    80001296:	557d                	li	a0,-1
    80001298:	b75d                	j	8000123e <map_range+0x72>
        printf("map_page: walk_create失败\n");
    8000129a:	00002517          	auipc	a0,0x2
    8000129e:	a7650513          	addi	a0,a0,-1418 # 80002d10 <etext+0xd10>
    800012a2:	887ff0ef          	jal	80000b28 <printf>
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    800012a6:	85a2                	mv	a1,s0
    800012a8:	7942                	ld	s2,48(sp)
    800012aa:	6406                	ld	s0,64(sp)
    800012ac:	7a02                	ld	s4,32(sp)
    800012ae:	6ae2                	ld	s5,24(sp)
    800012b0:	b765                	j	80001258 <map_range+0x8c>

00000000800012b2 <dump_pagetable>:

// 打印页表内容（调试用）
void dump_pagetable(pagetable_t pt, int level) {
    800012b2:	715d                	addi	sp,sp,-80
    800012b4:	e0a2                	sd	s0,64(sp)
    800012b6:	f44e                	sd	s3,40(sp)
    800012b8:	f052                	sd	s4,32(sp)
    800012ba:	ec56                	sd	s5,24(sp)
    // 缩进显示层级
    for (int indent = 0; indent < (3 - level); indent++) {
    800012bc:	4a0d                	li	s4,3
void dump_pagetable(pagetable_t pt, int level) {
    800012be:	e486                	sd	ra,72(sp)
    800012c0:	fc26                	sd	s1,56(sp)
    800012c2:	f84a                	sd	s2,48(sp)
    800012c4:	e85a                	sd	s6,16(sp)
    for (int indent = 0; indent < (3 - level); indent++) {
    800012c6:	4789                	li	a5,2
void dump_pagetable(pagetable_t pt, int level) {
    800012c8:	8aae                	mv	s5,a1
    800012ca:	89aa                	mv	s3,a0
    for (int indent = 0; indent < (3 - level); indent++) {
    800012cc:	40ba0a3b          	subw	s4,s4,a1
    800012d0:	4401                	li	s0,0
    800012d2:	00b7cb63          	blt	a5,a1,800012e8 <dump_pagetable+0x36>
        printf("  ");
    800012d6:	00002517          	auipc	a0,0x2
    800012da:	afa50513          	addi	a0,a0,-1286 # 80002dd0 <etext+0xdd0>
    for (int indent = 0; indent < (3 - level); indent++) {
    800012de:	2405                	addiw	s0,s0,1
        printf("  ");
    800012e0:	849ff0ef          	jal	80000b28 <printf>
    for (int indent = 0; indent < (3 - level); indent++) {
    800012e4:	ff4449e3          	blt	s0,s4,800012d6 <dump_pagetable+0x24>
    }
    
    printf("页表级别 %d (物理地址: 0x%p)\n", level, pt);
    800012e8:	864e                	mv	a2,s3
    800012ea:	85d6                	mv	a1,s5
    800012ec:	00002517          	auipc	a0,0x2
    800012f0:	abc50513          	addi	a0,a0,-1348 # 80002da8 <etext+0xda8>
    800012f4:	835ff0ef          	jal	80000b28 <printf>
    
    // 遍历页表项
    for (int i = 0; i < 512; i++) {
    800012f8:	4901                	li	s2,0
        pte_t pte = pt[i];
        
        if (pte & PTE_V) {
            // 显示缩进
            for (int indent = 0; indent < (3 - level); indent++) {
    800012fa:	4b09                	li	s6,2
    800012fc:	a039                	j	8000130a <dump_pagetable+0x58>
    for (int i = 0; i < 512; i++) {
    800012fe:	2905                	addiw	s2,s2,1
    80001300:	20000793          	li	a5,512
    80001304:	09a1                	addi	s3,s3,8
    80001306:	08f90063          	beq	s2,a5,80001386 <dump_pagetable+0xd4>
        pte_t pte = pt[i];
    8000130a:	0009b483          	ld	s1,0(s3)
        if (pte & PTE_V) {
    8000130e:	0014f793          	andi	a5,s1,1
    80001312:	d7f5                	beqz	a5,800012fe <dump_pagetable+0x4c>
            for (int indent = 0; indent < (3 - level); indent++) {
    80001314:	4401                	li	s0,0
    80001316:	0d5b4363          	blt	s6,s5,800013dc <dump_pagetable+0x12a>
                printf("  ");
    8000131a:	00002517          	auipc	a0,0x2
    8000131e:	ab650513          	addi	a0,a0,-1354 # 80002dd0 <etext+0xdd0>
            for (int indent = 0; indent < (3 - level); indent++) {
    80001322:	2405                	addiw	s0,s0,1
                printf("  ");
    80001324:	805ff0ef          	jal	80000b28 <printf>
            for (int indent = 0; indent < (3 - level); indent++) {
    80001328:	ff4449e3          	blt	s0,s4,8000131a <dump_pagetable+0x68>
            }
            
            printf("  [%d] PTE=0x%p", i, (void*)pte);
    8000132c:	85ca                	mv	a1,s2
    8000132e:	8626                	mv	a2,s1
    80001330:	00002517          	auipc	a0,0x2
    80001334:	aa850513          	addi	a0,a0,-1368 # 80002dd8 <etext+0xdd8>
    80001338:	ff0ff0ef          	jal	80000b28 <printf>
            
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
                // 中间级页表项
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    8000133c:	00a4d593          	srli	a1,s1,0xa
    80001340:	05b2                	slli	a1,a1,0xc
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001342:	01505563          	blez	s5,8000134c <dump_pagetable+0x9a>
    80001346:	00e4f793          	andi	a5,s1,14
    8000134a:	c7dd                	beqz	a5,800013f8 <dump_pagetable+0x146>
                if (level > 0) {
                    dump_pagetable((pagetable_t)PTE2PA(pte), level - 1);
                }
            } else {
                // 叶子页表项
                printf(" -> 页面 0x%p [", (void*)PTE2PA(pte));
    8000134c:	00002517          	auipc	a0,0x2
    80001350:	ab450513          	addi	a0,a0,-1356 # 80002e00 <etext+0xe00>
    80001354:	fd4ff0ef          	jal	80000b28 <printf>
                if (pte & PTE_R) printf("R");
    80001358:	0024f793          	andi	a5,s1,2
    8000135c:	ef9d                	bnez	a5,8000139a <dump_pagetable+0xe8>
                if (pte & PTE_W) printf("W");  
    8000135e:	0044f793          	andi	a5,s1,4
    80001362:	e7a9                	bnez	a5,800013ac <dump_pagetable+0xfa>
                if (pte & PTE_X) printf("X");
    80001364:	0084f793          	andi	a5,s1,8
    80001368:	ebb9                	bnez	a5,800013be <dump_pagetable+0x10c>
                if (pte & PTE_U) printf("U");
    8000136a:	88c1                	andi	s1,s1,16
    8000136c:	e0ad                	bnez	s1,800013ce <dump_pagetable+0x11c>
                printf("]\n");
    8000136e:	00001517          	auipc	a0,0x1
    80001372:	51a50513          	addi	a0,a0,1306 # 80002888 <etext+0x888>
    80001376:	fb2ff0ef          	jal	80000b28 <printf>
    for (int i = 0; i < 512; i++) {
    8000137a:	2905                	addiw	s2,s2,1
    8000137c:	20000793          	li	a5,512
    80001380:	09a1                	addi	s3,s3,8
    80001382:	f8f914e3          	bne	s2,a5,8000130a <dump_pagetable+0x58>
            }
        }
    }
}
    80001386:	60a6                	ld	ra,72(sp)
    80001388:	6406                	ld	s0,64(sp)
    8000138a:	74e2                	ld	s1,56(sp)
    8000138c:	7942                	ld	s2,48(sp)
    8000138e:	79a2                	ld	s3,40(sp)
    80001390:	7a02                	ld	s4,32(sp)
    80001392:	6ae2                	ld	s5,24(sp)
    80001394:	6b42                	ld	s6,16(sp)
    80001396:	6161                	addi	sp,sp,80
    80001398:	8082                	ret
                if (pte & PTE_R) printf("R");
    8000139a:	00001517          	auipc	a0,0x1
    8000139e:	4ce50513          	addi	a0,a0,1230 # 80002868 <etext+0x868>
    800013a2:	f86ff0ef          	jal	80000b28 <printf>
                if (pte & PTE_W) printf("W");  
    800013a6:	0044f793          	andi	a5,s1,4
    800013aa:	dfcd                	beqz	a5,80001364 <dump_pagetable+0xb2>
    800013ac:	00001517          	auipc	a0,0x1
    800013b0:	4c450513          	addi	a0,a0,1220 # 80002870 <etext+0x870>
    800013b4:	f74ff0ef          	jal	80000b28 <printf>
                if (pte & PTE_X) printf("X");
    800013b8:	0084f793          	andi	a5,s1,8
    800013bc:	d7dd                	beqz	a5,8000136a <dump_pagetable+0xb8>
    800013be:	00001517          	auipc	a0,0x1
    800013c2:	4ba50513          	addi	a0,a0,1210 # 80002878 <etext+0x878>
                if (pte & PTE_U) printf("U");
    800013c6:	88c1                	andi	s1,s1,16
                if (pte & PTE_X) printf("X");
    800013c8:	f60ff0ef          	jal	80000b28 <printf>
                if (pte & PTE_U) printf("U");
    800013cc:	d0cd                	beqz	s1,8000136e <dump_pagetable+0xbc>
    800013ce:	00001517          	auipc	a0,0x1
    800013d2:	4b250513          	addi	a0,a0,1202 # 80002880 <etext+0x880>
    800013d6:	f52ff0ef          	jal	80000b28 <printf>
    800013da:	bf51                	j	8000136e <dump_pagetable+0xbc>
            printf("  [%d] PTE=0x%p", i, (void*)pte);
    800013dc:	85ca                	mv	a1,s2
    800013de:	8626                	mv	a2,s1
    800013e0:	00002517          	auipc	a0,0x2
    800013e4:	9f850513          	addi	a0,a0,-1544 # 80002dd8 <etext+0xdd8>
    800013e8:	f40ff0ef          	jal	80000b28 <printf>
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    800013ec:	00a4d593          	srli	a1,s1,0xa
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013f0:	00e4f793          	andi	a5,s1,14
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    800013f4:	05b2                	slli	a1,a1,0xc
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013f6:	fbb9                	bnez	a5,8000134c <dump_pagetable+0x9a>
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    800013f8:	00002517          	auipc	a0,0x2
    800013fc:	9f050513          	addi	a0,a0,-1552 # 80002de8 <etext+0xde8>
    80001400:	e42e                	sd	a1,8(sp)
    80001402:	f26ff0ef          	jal	80000b28 <printf>
                    dump_pagetable((pagetable_t)PTE2PA(pte), level - 1);
    80001406:	6522                	ld	a0,8(sp)
    80001408:	fffa859b          	addiw	a1,s5,-1
    8000140c:	ea7ff0ef          	jal	800012b2 <dump_pagetable>
    80001410:	b5fd                	j	800012fe <dump_pagetable+0x4c>

0000000080001412 <va2pa>:
// 地址转换：虚拟地址转物理地址
uint64 va2pa(pagetable_t pt, uint64 va) {
    pte_t *pte;
    uint64 pa;
    
    if (va >= MAXVA) {
    80001412:	577d                	li	a4,-1
    80001414:	8369                	srli	a4,a4,0x1a
    80001416:	02b76963          	bltu	a4,a1,80001448 <va2pa+0x36>
uint64 va2pa(pagetable_t pt, uint64 va) {
    8000141a:	1141                	addi	sp,sp,-16
    8000141c:	e022                	sd	s0,0(sp)
    8000141e:	e406                	sd	ra,8(sp)
    80001420:	842e                	mv	s0,a1
    if (va >= MAXVA) {
    80001422:	b99ff0ef          	jal	80000fba <walk_lookup.part.0>
        return 0;
    }
    
    pte = walk_lookup(pt, va);
    if (pte == 0) {
    80001426:	cd09                	beqz	a0,80001440 <va2pa+0x2e>
        return 0;  // 未映射
    }
    
    if ((*pte & PTE_V) == 0) {
    80001428:	611c                	ld	a5,0(a0)
    8000142a:	0017f513          	andi	a0,a5,1
    8000142e:	c909                	beqz	a0,80001440 <va2pa+0x2e>
        return 0;  // 无效映射
    }
    
    pa = PTE2PA(*pte);
    80001430:	00a7d713          	srli	a4,a5,0xa
    return pa + (va & (PGSIZE - 1));  // 加上页内偏移
    80001434:	03441793          	slli	a5,s0,0x34
    pa = PTE2PA(*pte);
    80001438:	0732                	slli	a4,a4,0xc
    return pa + (va & (PGSIZE - 1));  // 加上页内偏移
    8000143a:	93d1                	srli	a5,a5,0x34
    8000143c:	00f70533          	add	a0,a4,a5
}
    80001440:	60a2                	ld	ra,8(sp)
    80001442:	6402                	ld	s0,0(sp)
    80001444:	0141                	addi	sp,sp,16
    80001446:	8082                	ret
        return 0;
    80001448:	4501                	li	a0,0
}
    8000144a:	8082                	ret

000000008000144c <kvmmake>:
#ifndef PX
#define PX(level, va) ((((uint64) (va)) >> (PGSHIFT + (9 * (level)))) & 0x1FF)
#endif

// 创建内核页表
pagetable_t kvmmake(void) {
    8000144c:	1101                	addi	sp,sp,-32
    pagetable_t kpgtbl;
    
    printf("创建内核页表...\n");
    8000144e:	00002517          	auipc	a0,0x2
    80001452:	9ca50513          	addi	a0,a0,-1590 # 80002e18 <etext+0xe18>
pagetable_t kvmmake(void) {
    80001456:	ec06                	sd	ra,24(sp)
    80001458:	e822                	sd	s0,16(sp)
    printf("创建内核页表...\n");
    8000145a:	eceff0ef          	jal	80000b28 <printf>
    pt = (pagetable_t)alloc_page();
    8000145e:	d91fe0ef          	jal	800001ee <alloc_page>
    if (pt == 0) {
    80001462:	c945                	beqz	a0,80001512 <kvmmake+0xc6>
    80001464:	6705                	lui	a4,0x1
    80001466:	e426                	sd	s1,8(sp)
    80001468:	842a                	mv	s0,a0
    8000146a:	972a                	add	a4,a4,a0
    8000146c:	87aa                	mv	a5,a0
        pt[i] = 0;
    8000146e:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
    80001472:	07a1                	addi	a5,a5,8
    80001474:	fee79de3          	bne	a5,a4,8000146e <kvmmake+0x22>
    if (kpgtbl == 0) {
        printf("kvmmake: 创建页表失败\n");
        return 0;
    }
    
    printf("映射UART设备...\n");
    80001478:	00002517          	auipc	a0,0x2
    8000147c:	9d850513          	addi	a0,a0,-1576 # 80002e50 <etext+0xe50>
    80001480:	ea8ff0ef          	jal	80000b28 <printf>
    pte = walk_create(pt, va);
    80001484:	8522                	mv	a0,s0
    80001486:	100005b7          	lui	a1,0x10000
    8000148a:	bf1ff0ef          	jal	8000107a <walk_create>
    if (pte == 0) {
    8000148e:	0e050363          	beqz	a0,80001574 <kvmmake+0x128>
    if (*pte & PTE_V) {
    80001492:	611c                	ld	a5,0(a0)
    80001494:	0017f713          	andi	a4,a5,1
    80001498:	ef45                	bnez	a4,80001550 <kvmmake+0x104>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000149a:	040007b7          	lui	a5,0x4000
    8000149e:	079d                	addi	a5,a5,7 # 4000007 <_entry-0x7bfffff9>
    800014a0:	e11c                	sd	a5,0(a0)
    if (map_page(kpgtbl, UART0, UART0, PTE_R | PTE_W) != 0) {
        printf("kvmmake: UART映射失败\n");
        goto fail;
    }
    
    printf("映射内核代码段...\n");
    800014a2:	00002517          	auipc	a0,0x2
    800014a6:	9c650513          	addi	a0,a0,-1594 # 80002e68 <etext+0xe68>
    800014aa:	e7eff0ef          	jal	80000b28 <printf>
    // 映射内核代码段（只读+可执行）
    uint64 code_size = PGROUNDUP((uint64)etext - KERNBASE);
    if (map_range(kpgtbl, KERNBASE, code_size, KERNBASE, PTE_R | PTE_X) != 0) {
    800014ae:	4685                	li	a3,1
    800014b0:	06fe                	slli	a3,a3,0x1f
    uint64 code_size = PGROUNDUP((uint64)etext - KERNBASE);
    800014b2:	80002617          	auipc	a2,0x80002
    800014b6:	b4d60613          	addi	a2,a2,-1203 # 2fff <_entry-0x7fffd001>
    800014ba:	74fd                	lui	s1,0xfffff
    if (map_range(kpgtbl, KERNBASE, code_size, KERNBASE, PTE_R | PTE_X) != 0) {
    800014bc:	8522                	mv	a0,s0
    800014be:	85b6                	mv	a1,a3
    800014c0:	8e65                	and	a2,a2,s1
    800014c2:	4729                	li	a4,10
    800014c4:	d09ff0ef          	jal	800011cc <map_range>
    800014c8:	e12d                	bnez	a0,8000152a <kvmmake+0xde>
        printf("kvmmake: 内核代码段映射失败\n");
        goto fail;
    }
    
    printf("映射内核数据段...\n");
    800014ca:	00002517          	auipc	a0,0x2
    800014ce:	a0650513          	addi	a0,a0,-1530 # 80002ed0 <etext+0xed0>
    800014d2:	e56ff0ef          	jal	80000b28 <printf>
    // 映射内核数据段（读写）
    uint64 data_size = PGROUNDUP(PHYSTOP - (uint64)etext);
    800014d6:	00088637          	lui	a2,0x88
    800014da:	0605                	addi	a2,a2,1 # 88001 <_entry-0x7ff77fff>
    800014dc:	0632                	slli	a2,a2,0xc
    800014de:	00001797          	auipc	a5,0x1
    800014e2:	b2278793          	addi	a5,a5,-1246 # 80002000 <etext>
    800014e6:	167d                	addi	a2,a2,-1
    800014e8:	8e1d                	sub	a2,a2,a5
    if (map_range(kpgtbl, (uint64)etext, data_size, (uint64)etext, PTE_R | PTE_W) != 0) {
    800014ea:	8e65                	and	a2,a2,s1
    800014ec:	86be                	mv	a3,a5
    800014ee:	85be                	mv	a1,a5
    800014f0:	8522                	mv	a0,s0
    800014f2:	4719                	li	a4,6
    800014f4:	cd9ff0ef          	jal	800011cc <map_range>
    800014f8:	e529                	bnez	a0,80001542 <kvmmake+0xf6>
        printf("kvmmake: 内核数据段映射失败\n");
        goto fail;
    }
    
    printf("内核页表创建成功\n");
    800014fa:	00002517          	auipc	a0,0x2
    800014fe:	a1e50513          	addi	a0,a0,-1506 # 80002f18 <etext+0xf18>
    80001502:	e26ff0ef          	jal	80000b28 <printf>
    return kpgtbl;
    
fail:
    destroy_pagetable(kpgtbl);
    return 0;
}
    80001506:	60e2                	ld	ra,24(sp)
    80001508:	8522                	mv	a0,s0
    8000150a:	6442                	ld	s0,16(sp)
    return kpgtbl;
    8000150c:	64a2                	ld	s1,8(sp)
}
    8000150e:	6105                	addi	sp,sp,32
    80001510:	8082                	ret
        printf("kvmmake: 创建页表失败\n");
    80001512:	00002517          	auipc	a0,0x2
    80001516:	91e50513          	addi	a0,a0,-1762 # 80002e30 <etext+0xe30>
    8000151a:	e0eff0ef          	jal	80000b28 <printf>
        return 0;
    8000151e:	4401                	li	s0,0
}
    80001520:	60e2                	ld	ra,24(sp)
    80001522:	8522                	mv	a0,s0
    80001524:	6442                	ld	s0,16(sp)
    80001526:	6105                	addi	sp,sp,32
    80001528:	8082                	ret
        printf("kvmmake: 内核代码段映射失败\n");
    8000152a:	00002517          	auipc	a0,0x2
    8000152e:	97e50513          	addi	a0,a0,-1666 # 80002ea8 <etext+0xea8>
    80001532:	df6ff0ef          	jal	80000b28 <printf>
    if (pt == 0) return;
    80001536:	8522                	mv	a0,s0
    80001538:	ac5ff0ef          	jal	80000ffc <destroy_pagetable.part.0>
        return 0;
    8000153c:	4401                	li	s0,0
    8000153e:	64a2                	ld	s1,8(sp)
    80001540:	b7c5                	j	80001520 <kvmmake+0xd4>
        printf("kvmmake: 内核数据段映射失败\n");
    80001542:	00002517          	auipc	a0,0x2
    80001546:	9ae50513          	addi	a0,a0,-1618 # 80002ef0 <etext+0xef0>
    8000154a:	ddeff0ef          	jal	80000b28 <printf>
        goto fail;
    8000154e:	b7e5                	j	80001536 <kvmmake+0xea>
               (void*)va, (void*)PTE2PA(*pte));
    80001550:	83a9                	srli	a5,a5,0xa
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    80001552:	00c79613          	slli	a2,a5,0xc
    80001556:	100005b7          	lui	a1,0x10000
    8000155a:	00001517          	auipc	a0,0x1
    8000155e:	7d650513          	addi	a0,a0,2006 # 80002d30 <etext+0xd30>
    80001562:	dc6ff0ef          	jal	80000b28 <printf>
        printf("kvmmake: UART映射失败\n");
    80001566:	00002517          	auipc	a0,0x2
    8000156a:	92250513          	addi	a0,a0,-1758 # 80002e88 <etext+0xe88>
    8000156e:	dbaff0ef          	jal	80000b28 <printf>
        goto fail;
    80001572:	b7d1                	j	80001536 <kvmmake+0xea>
        printf("map_page: walk_create失败\n");
    80001574:	00001517          	auipc	a0,0x1
    80001578:	79c50513          	addi	a0,a0,1948 # 80002d10 <etext+0xd10>
    8000157c:	dacff0ef          	jal	80000b28 <printf>
        return -1;
    80001580:	b7dd                	j	80001566 <kvmmake+0x11a>

0000000080001582 <kvminit>:

// 初始化内核虚拟内存
void kvminit(void) {
    80001582:	1141                	addi	sp,sp,-16
    printf("=== 初始化内核虚拟内存 ===\n");
    80001584:	00002517          	auipc	a0,0x2
    80001588:	9b450513          	addi	a0,a0,-1612 # 80002f38 <etext+0xf38>
void kvminit(void) {
    8000158c:	e406                	sd	ra,8(sp)
    printf("=== 初始化内核虚拟内存 ===\n");
    8000158e:	d9aff0ef          	jal	80000b28 <printf>
    
    // 创建内核页表
    kernel_pagetable = kvmmake();
    80001592:	ebbff0ef          	jal	8000144c <kvmmake>
    80001596:	0000b797          	auipc	a5,0xb
    8000159a:	a6a7b523          	sd	a0,-1430(a5) # 8000c000 <kernel_pagetable>
    if (kernel_pagetable == 0) {
    8000159e:	c105                	beqz	a0,800015be <kvminit+0x3c>
        printf("kvminit: 内核页表创建失败!\n");
        return;
    }
    
    printf("内核页表地址: 0x%p\n", kernel_pagetable);
    800015a0:	85aa                	mv	a1,a0
    800015a2:	00002517          	auipc	a0,0x2
    800015a6:	9e650513          	addi	a0,a0,-1562 # 80002f88 <etext+0xf88>
    800015aa:	d7eff0ef          	jal	80000b28 <printf>
    printf("内核虚拟内存初始化完成\n");
}
    800015ae:	60a2                	ld	ra,8(sp)
    printf("内核虚拟内存初始化完成\n");
    800015b0:	00002517          	auipc	a0,0x2
    800015b4:	9f850513          	addi	a0,a0,-1544 # 80002fa8 <etext+0xfa8>
}
    800015b8:	0141                	addi	sp,sp,16
    printf("内核虚拟内存初始化完成\n");
    800015ba:	d6eff06f          	j	80000b28 <printf>
}
    800015be:	60a2                	ld	ra,8(sp)
        printf("kvminit: 内核页表创建失败!\n");
    800015c0:	00002517          	auipc	a0,0x2
    800015c4:	9a050513          	addi	a0,a0,-1632 # 80002f60 <etext+0xf60>
}
    800015c8:	0141                	addi	sp,sp,16
        printf("kvminit: 内核页表创建失败!\n");
    800015ca:	d5eff06f          	j	80000b28 <printf>

00000000800015ce <kvminithart>:

// 激活内核页表（启用虚拟内存）
void kvminithart(void) {
    800015ce:	1101                	addi	sp,sp,-32
    printf("=== 激活虚拟内存系统 ===\n");
    800015d0:	00002517          	auipc	a0,0x2
    800015d4:	a0050513          	addi	a0,a0,-1536 # 80002fd0 <etext+0xfd0>
void kvminithart(void) {
    800015d8:	ec06                	sd	ra,24(sp)
    printf("=== 激活虚拟内存系统 ===\n");
    800015da:	d4eff0ef          	jal	80000b28 <printf>
    
    if (kernel_pagetable == 0) {
    800015de:	0000b717          	auipc	a4,0xb
    800015e2:	a2273703          	ld	a4,-1502(a4) # 8000c000 <kernel_pagetable>
    800015e6:	cf39                	beqz	a4,80001644 <kvminithart+0x76>
    800015e8:	180025f3          	csrr	a1,satp
        printf("kvminithart: 内核页表未初始化!\n");
        return;
    }
    
    printf("当前satp寄存器值: 0x%p\n", (void*)r_satp());
    800015ec:	00002517          	auipc	a0,0x2
    800015f0:	a3450513          	addi	a0,a0,-1484 # 80003020 <etext+0x1020>
    800015f4:	d34ff0ef          	jal	80000b28 <printf>
// 内存屏障指令
static inline void
sfence_vma()
{
  // 刷新TLB的全部条目
  asm volatile("sfence.vma zero, zero");
    800015f8:	12000073          	sfence.vma
    
    // 刷新TLB
    sfence_vma();
    
    // 设置satp寄存器，启用Sv39分页模式
    uint64 satp_val = MAKE_SATP(kernel_pagetable);
    800015fc:	0000b597          	auipc	a1,0xb
    80001600:	a045b583          	ld	a1,-1532(a1) # 8000c000 <kernel_pagetable>
    80001604:	57fd                	li	a5,-1
    80001606:	17fe                	slli	a5,a5,0x3f
    80001608:	81b1                	srli	a1,a1,0xc
    8000160a:	8ddd                	or	a1,a1,a5
    printf("设置satp寄存器: 0x%p\n", (void*)satp_val);
    8000160c:	00002517          	auipc	a0,0x2
    80001610:	a3450513          	addi	a0,a0,-1484 # 80003040 <etext+0x1040>
    80001614:	e42e                	sd	a1,8(sp)
    80001616:	d12ff0ef          	jal	80000b28 <printf>
  asm volatile("csrw satp, %0" : : "r" (x));
    8000161a:	65a2                	ld	a1,8(sp)
    8000161c:	18059073          	csrw	satp,a1
  asm volatile("sfence.vma zero, zero");
    80001620:	12000073          	sfence.vma
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001624:	180025f3          	csrr	a1,satp
    w_satp(satp_val);
    
    // 再次刷新TLB
    sfence_vma();
    
    printf("新的satp寄存器值: 0x%p\n", (void*)r_satp());
    80001628:	00002517          	auipc	a0,0x2
    8000162c:	a3850513          	addi	a0,a0,-1480 # 80003060 <etext+0x1060>
    80001630:	cf8ff0ef          	jal	80000b28 <printf>
    printf("虚拟内存系统已激活!\n");
    80001634:	60e2                	ld	ra,24(sp)
    printf("虚拟内存系统已激活!\n");
    80001636:	00002517          	auipc	a0,0x2
    8000163a:	a4a50513          	addi	a0,a0,-1462 # 80003080 <etext+0x1080>
    8000163e:	6105                	addi	sp,sp,32
    printf("虚拟内存系统已激活!\n");
    80001640:	ce8ff06f          	j	80000b28 <printf>
    80001644:	60e2                	ld	ra,24(sp)
        printf("kvminithart: 内核页表未初始化!\n");
    80001646:	00002517          	auipc	a0,0x2
    8000164a:	9b250513          	addi	a0,a0,-1614 # 80002ff8 <etext+0xff8>
    8000164e:	6105                	addi	sp,sp,32
        printf("kvminithart: 内核页表未初始化!\n");
    80001650:	cd8ff06f          	j	80000b28 <printf>
	...
