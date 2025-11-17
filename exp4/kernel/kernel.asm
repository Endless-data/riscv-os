
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
        .global _entry
_entry:
        # 设置栈指针
        # 为每个 CPU 分配一个栈
        # 栈大小为 4096 字节
        la sp, stack0
    80000000:	00005117          	auipc	sp,0x5
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
    80000016:	645000ef          	jal	80000e5a <start>

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
    80000020:	24a0106f          	j	8000126a <uart_init>

0000000080000024 <console_putc>:
}

// 输出单个字符到控制台
void 
console_putc(char c) 
{
    80000024:	1101                	addi	sp,sp,-32 # 80004fe0 <exception_names+0xfe0>
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
    80000038:	24e0106f          	j	80001286 <uart_putc>
    8000003c:	e42a                	sd	a0,8(sp)
        uart_putc('\b');
    8000003e:	248010ef          	jal	80001286 <uart_putc>
        uart_putc(' ');
    80000042:	02000513          	li	a0,32
    80000046:	240010ef          	jal	80001286 <uart_putc>
        uart_putc('\b');
    8000004a:	6522                	ld	a0,8(sp)
}
    8000004c:	60e2                	ld	ra,24(sp)
    8000004e:	6105                	addi	sp,sp,32
        uart_putc('\b');
    80000050:	2360106f          	j	80001286 <uart_putc>
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
    80000072:	214010ef          	jal	80001286 <uart_putc>
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
    8000008a:	1fc010ef          	jal	80001286 <uart_putc>
        uart_putc(' ');
    8000008e:	02000513          	li	a0,32
    80000092:	1f4010ef          	jal	80001286 <uart_putc>
        uart_putc('\b');
    80000096:	8526                	mv	a0,s1
    80000098:	1ee010ef          	jal	80001286 <uart_putc>
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
    800000b0:	1d6010ef          	jal	80001286 <uart_putc>
        uart_putc('\n');
    800000b4:	854a                	mv	a0,s2
    800000b6:	1d0010ef          	jal	80001286 <uart_putc>
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
    800001ee:	0000d797          	auipc	a5,0xd
    800001f2:	e3278793          	addi	a5,a5,-462 # 8000d020 <pmm>
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
    80000224:	0000e797          	auipc	a5,0xe
    80000228:	ddc78793          	addi	a5,a5,-548 # 8000e000 <end>
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
    80000252:	0000d797          	auipc	a5,0xd
    80000256:	dce78793          	addi	a5,a5,-562 # 8000d020 <pmm>
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
    8000027a:	7720006f          	j	800009ec <printf>

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
    800002d0:	71c000ef          	jal	800009ec <printf>
    char *start = (char*)PGROUNDUP((uint64)end);
    800002d4:	77fd                	lui	a5,0xfffff
    800002d6:	0000f417          	auipc	s0,0xf
    800002da:	d2940413          	addi	s0,s0,-727 # 8000efff <end+0xfff>
    800002de:	8c7d                	and	s0,s0,a5
    printf("内存范围: 0x%p - 0x%p\n", start, stop);
    800002e0:	4645                	li	a2,17
    800002e2:	066e                	slli	a2,a2,0x1b
    800002e4:	85a2                	mv	a1,s0
    800002e6:	00002517          	auipc	a0,0x2
    800002ea:	d8a50513          	addi	a0,a0,-630 # 80002070 <etext+0x70>
    800002ee:	6fe000ef          	jal	800009ec <printf>
    printf("内核结束地址: 0x%p\n", end);
    800002f2:	0000e597          	auipc	a1,0xe
    800002f6:	d0e58593          	addi	a1,a1,-754 # 8000e000 <end>
    800002fa:	00002517          	auipc	a0,0x2
    800002fe:	d9650513          	addi	a0,a0,-618 # 80002090 <etext+0x90>
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000302:	44c5                	li	s1,17
    printf("内核结束地址: 0x%p\n", end);
    80000304:	6e8000ef          	jal	800009ec <printf>
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000308:	04ee                	slli	s1,s1,0x1b
    8000030a:	408487b3          	sub	a5,s1,s0
    8000030e:	83b1                	srli	a5,a5,0xc
    printf("总页面数: %d\n", (int)pmm.total_pages);
    80000310:	0007859b          	sext.w	a1,a5
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000314:	0000d997          	auipc	s3,0xd
    80000318:	d0c98993          	addi	s3,s3,-756 # 8000d020 <pmm>
    printf("总页面数: %d\n", (int)pmm.total_pages);
    8000031c:	00002517          	auipc	a0,0x2
    80000320:	d9450513          	addi	a0,a0,-620 # 800020b0 <etext+0xb0>
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    80000324:	00f9b423          	sd	a5,8(s3)
    char *start = (char*)PGROUNDUP((uint64)end);
    80000328:	6905                	lui	s2,0x1
    printf("总页面数: %d\n", (int)pmm.total_pages);
    8000032a:	6c2000ef          	jal	800009ec <printf>
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
    8000034a:	6a2000ef          	jal	800009ec <printf>
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
    80000366:	6860006f          	j	800009ec <printf>

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
    80000382:	66a000ef          	jal	800009ec <printf>
    return 0;
}
    80000386:	60a2                	ld	ra,8(sp)
    if (n <= 0) return 0;
    80000388:	4501                	li	a0,0
}
    8000038a:	0141                	addi	sp,sp,16
    8000038c:	8082                	ret
    if (pmm.freelist == 0) {
    8000038e:	0000d797          	auipc	a5,0xd
    80000392:	c9278793          	addi	a5,a5,-878 # 8000d020 <pmm>
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
    800003c2:	0000d517          	auipc	a0,0xd
    800003c6:	c6e53503          	ld	a0,-914(a0) # 8000d030 <pmm+0x10>
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
    800003da:	0000d417          	auipc	s0,0xd
    800003de:	c4640413          	addi	s0,s0,-954 # 8000d020 <pmm>
    printf("=== 内存使用统计 ===\n");
    800003e2:	60a000ef          	jal	800009ec <printf>
    printf("总页面数:   %d\n", (int)pmm.total_pages);
    800003e6:	440c                	lw	a1,8(s0)
    800003e8:	00002517          	auipc	a0,0x2
    800003ec:	d7050513          	addi	a0,a0,-656 # 80002158 <etext+0x158>
    800003f0:	5fc000ef          	jal	800009ec <printf>
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
    800003f4:	480c                	lw	a1,16(s0)
    800003f6:	00002517          	auipc	a0,0x2
    800003fa:	cfa50513          	addi	a0,a0,-774 # 800020f0 <etext+0xf0>
    800003fe:	5ee000ef          	jal	800009ec <printf>
    printf("已用页面数: %d\n", (int)pmm.used_pages);
    80000402:	4c0c                	lw	a1,24(s0)
    80000404:	00002517          	auipc	a0,0x2
    80000408:	d6c50513          	addi	a0,a0,-660 # 80002170 <etext+0x170>
    8000040c:	5e0000ef          	jal	800009ec <printf>
    printf("总内存:     %d KB\n", (int)(pmm.total_pages * PGSIZE / 1024));
    80000410:	640c                	ld	a1,8(s0)
    80000412:	00002517          	auipc	a0,0x2
    80000416:	d7650513          	addi	a0,a0,-650 # 80002188 <etext+0x188>
    8000041a:	02259793          	slli	a5,a1,0x22
    8000041e:	4227d593          	srai	a1,a5,0x22
    80000422:	058a                	slli	a1,a1,0x2
    80000424:	5c8000ef          	jal	800009ec <printf>
    printf("空闲内存:   %d KB\n", (int)(pmm.free_pages * PGSIZE / 1024));
    80000428:	680c                	ld	a1,16(s0)
    8000042a:	00002517          	auipc	a0,0x2
    8000042e:	d7650513          	addi	a0,a0,-650 # 800021a0 <etext+0x1a0>
    80000432:	02259793          	slli	a5,a1,0x22
    80000436:	4227d593          	srai	a1,a5,0x22
    8000043a:	058a                	slli	a1,a1,0x2
    8000043c:	5b0000ef          	jal	800009ec <printf>
    printf("已用内存:   %d KB\n", (int)(pmm.used_pages * PGSIZE / 1024));
    80000440:	6c0c                	ld	a1,24(s0)
    80000442:	00002517          	auipc	a0,0x2
    80000446:	d7650513          	addi	a0,a0,-650 # 800021b8 <etext+0x1b8>
    8000044a:	02259793          	slli	a5,a1,0x22
    8000044e:	4227d593          	srai	a1,a5,0x22
    80000452:	058a                	slli	a1,a1,0x2
    80000454:	598000ef          	jal	800009ec <printf>
    
    if (pmm.total_pages > 0) {
    80000458:	641c                	ld	a5,8(s0)
    8000045a:	eb89                	bnez	a5,8000046c <print_memory_stats+0xa0>
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
    8000046a:	a349                	j	800009ec <printf>
        int usage = (int)((pmm.used_pages * 100) / pmm.total_pages);
    8000046c:	6c0c                	ld	a1,24(s0)
    8000046e:	06400713          	li	a4,100
        printf("内存使用率: %d%%\n", usage);
    80000472:	00002517          	auipc	a0,0x2
    80000476:	d5e50513          	addi	a0,a0,-674 # 800021d0 <etext+0x1d0>
        int usage = (int)((pmm.used_pages * 100) / pmm.total_pages);
    8000047a:	02e585b3          	mul	a1,a1,a4
    8000047e:	02f5d5b3          	divu	a1,a1,a5
        printf("内存使用率: %d%%\n", usage);
    80000482:	2581                	sext.w	a1,a1
    80000484:	568000ef          	jal	800009ec <printf>
    80000488:	6402                	ld	s0,0(sp)
    8000048a:	60a2                	ld	ra,8(sp)
    printf("==================\n");
    8000048c:	00002517          	auipc	a0,0x2
    80000490:	d5c50513          	addi	a0,a0,-676 # 800021e8 <etext+0x1e8>
    80000494:	0141                	addi	sp,sp,16
    printf("==================\n");
    80000496:	ab99                	j	800009ec <printf>

0000000080000498 <test_timer_interrupt>:
#include "defs.h"
#include "memlayout.h"
#include "riscv.h"

// ==================== 测试1：时钟中断测试 ====================
void test_timer_interrupt(void) {
    80000498:	715d                	addi	sp,sp,-80
    printf("正在测试时钟中断...\n");
    8000049a:	00002517          	auipc	a0,0x2
    8000049e:	d6650513          	addi	a0,a0,-666 # 80002200 <etext+0x200>
void test_timer_interrupt(void) {
    800004a2:	e486                	sd	ra,72(sp)
    800004a4:	ec56                	sd	s5,24(sp)
    800004a6:	e0a2                	sd	s0,64(sp)
    800004a8:	fc26                	sd	s1,56(sp)
    800004aa:	f84a                	sd	s2,48(sp)
    800004ac:	f44e                	sd	s3,40(sp)
    800004ae:	f052                	sd	s4,32(sp)
    printf("正在测试时钟中断...\n");
    800004b0:	53c000ef          	jal	800009ec <printf>
    
    // 记录中断前的时间
    uint64 start_time = get_time();
    800004b4:	509000ef          	jal	800011bc <get_time>
    800004b8:	8aaa                	mv	s5,a0

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800004ba:	100027f3          	csrr	a5,sstatus

// 使能设备中断
static inline void
intr_on()
{
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800004be:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800004c2:	10079073          	csrw	sstatus,a5
    // 使能中断
    intr_on();
    
    // 在时钟中断处理函数中增加计数
    // 等待几次中断
    int initial_count = get_interrupt_count();
    800004c6:	507000ef          	jal	800011cc <get_interrupt_count>
    800004ca:	892a                	mv	s2,a0
        if (current > last_printed) {
            printf("  第 %d 次中断已发生\n", current);
            last_printed = current;
        }
        // 简单延时
        for (volatile int i = 0; i < 1000000; i++);
    800004cc:	000f4437          	lui	s0,0xf4
    printf("等待 5 次中断...\n");
    800004d0:	00002517          	auipc	a0,0x2
    800004d4:	d5050513          	addi	a0,a0,-688 # 80002220 <etext+0x220>
    800004d8:	514000ef          	jal	800009ec <printf>
        for (volatile int i = 0; i < 1000000; i++);
    800004dc:	23f40413          	addi	s0,s0,575 # f423f <_entry-0x7ff0bdc1>
    int last_printed = 0;
    800004e0:	4981                	li	s3,0
    while ((get_interrupt_count() - initial_count) < 5) {
    800004e2:	4a11                	li	s4,4
    800004e4:	4e9000ef          	jal	800011cc <get_interrupt_count>
    800004e8:	4125053b          	subw	a0,a0,s2
    800004ec:	02aa4863          	blt	s4,a0,8000051c <test_timer_interrupt+0x84>
        int current = get_interrupt_count() - initial_count;
    800004f0:	4dd000ef          	jal	800011cc <get_interrupt_count>
    800004f4:	412504bb          	subw	s1,a0,s2
        if (current > last_printed) {
    800004f8:	0499c863          	blt	s3,s1,80000548 <test_timer_interrupt+0xb0>
        for (volatile int i = 0; i < 1000000; i++);
    800004fc:	c602                	sw	zero,12(sp)
    800004fe:	47b2                	lw	a5,12(sp)
    80000500:	fef442e3          	blt	s0,a5,800004e4 <test_timer_interrupt+0x4c>
    80000504:	47b2                	lw	a5,12(sp)
    80000506:	2785                	addiw	a5,a5,1
    80000508:	c63e                	sw	a5,12(sp)
    8000050a:	47b2                	lw	a5,12(sp)
    8000050c:	fef45ce3          	bge	s0,a5,80000504 <test_timer_interrupt+0x6c>
    while ((get_interrupt_count() - initial_count) < 5) {
    80000510:	4bd000ef          	jal	800011cc <get_interrupt_count>
    80000514:	4125053b          	subw	a0,a0,s2
    80000518:	fcaa5ce3          	bge	s4,a0,800004f0 <test_timer_interrupt+0x58>
    }
    
    uint64 end_time = get_time();
    8000051c:	4a1000ef          	jal	800011bc <get_time>
    80000520:	842a                	mv	s0,a0
    interrupt_count = get_interrupt_count() - initial_count;
    80000522:	4ab000ef          	jal	800011cc <get_interrupt_count>
    printf("时钟测试完成: %d 次中断，耗时 %d 周期\n",
    80000526:	4154063b          	subw	a2,s0,s5
           interrupt_count, (int)(end_time - start_time));
}
    8000052a:	6406                	ld	s0,64(sp)
    8000052c:	60a6                	ld	ra,72(sp)
    8000052e:	74e2                	ld	s1,56(sp)
    80000530:	79a2                	ld	s3,40(sp)
    80000532:	7a02                	ld	s4,32(sp)
    80000534:	6ae2                	ld	s5,24(sp)
    printf("时钟测试完成: %d 次中断，耗时 %d 周期\n",
    80000536:	412505bb          	subw	a1,a0,s2
}
    8000053a:	7942                	ld	s2,48(sp)
    printf("时钟测试完成: %d 次中断，耗时 %d 周期\n",
    8000053c:	00002517          	auipc	a0,0x2
    80000540:	d1c50513          	addi	a0,a0,-740 # 80002258 <etext+0x258>
}
    80000544:	6161                	addi	sp,sp,80
    printf("时钟测试完成: %d 次中断，耗时 %d 周期\n",
    80000546:	a15d                	j	800009ec <printf>
            printf("  第 %d 次中断已发生\n", current);
    80000548:	85a6                	mv	a1,s1
    8000054a:	00002517          	auipc	a0,0x2
    8000054e:	cee50513          	addi	a0,a0,-786 # 80002238 <etext+0x238>
    80000552:	49a000ef          	jal	800009ec <printf>
            last_printed = current;
    80000556:	89a6                	mv	s3,s1
    80000558:	b755                	j	800004fc <test_timer_interrupt+0x64>

000000008000055a <test_exception_handling>:

// ==================== 测试2：异常处理测试 ====================
void test_exception_handling(void) {
    8000055a:	1141                	addi	sp,sp,-16
    printf("正在测试异常处理...\n");
    8000055c:	00002517          	auipc	a0,0x2
    80000560:	d3450513          	addi	a0,a0,-716 # 80002290 <etext+0x290>
void test_exception_handling(void) {
    80000564:	e406                	sd	ra,8(sp)
    printf("正在测试异常处理...\n");
    80000566:	486000ef          	jal	800009ec <printf>
    
    // 测试除零异常（如果支持）
    printf("注意: RISC-V上除零可能不会触发异常\n");
    8000056a:	00002517          	auipc	a0,0x2
    8000056e:	d4650513          	addi	a0,a0,-698 # 800022b0 <etext+0x2b0>
    80000572:	47a000ef          	jal	800009ec <printf>
    
    // 测试非法指令异常
    printf("测试非法指令处理 (已跳过以避免panic)\n");
    80000576:	00002517          	auipc	a0,0x2
    8000057a:	d7250513          	addi	a0,a0,-654 # 800022e8 <etext+0x2e8>
    8000057e:	46e000ef          	jal	800009ec <printf>
    // 实际执行会导致panic: 
    // asm volatile(".word 0x00000000");
    
    // 测试内存访问异常
    printf("测试内存访问异常 (已跳过以避免panic)\n");
    80000582:	00002517          	auipc	a0,0x2
    80000586:	d9e50513          	addi	a0,a0,-610 # 80002320 <etext+0x320>
    8000058a:	462000ef          	jal	800009ec <printf>
    // 实际执行会导致panic: 
    // volatile int *bad_ptr = (int*)0x0; int x = *bad_ptr;

    // 2. 测试指令地址未对齐异常 (scause = 0)
    printf("  [2] 测试指令地址未对齐 (已跳过以避免panic)\n");
    8000058e:	00002517          	auipc	a0,0x2
    80000592:	dca50513          	addi	a0,a0,-566 # 80002358 <etext+0x358>
    80000596:	456000ef          	jal	800009ec <printf>
    // 尝试跳转到一个奇数地址。RISC-V要求跳转地址是2字节对齐的。
    // asm volatile("jr %0" :: "r"(0x80000001));
    
    printf("异常测试完成\n");
}
    8000059a:	60a2                	ld	ra,8(sp)
    printf("异常测试完成\n");
    8000059c:	00002517          	auipc	a0,0x2
    800005a0:	dfc50513          	addi	a0,a0,-516 # 80002398 <etext+0x398>
}
    800005a4:	0141                	addi	sp,sp,16
    printf("异常测试完成\n");
    800005a6:	a199                	j	800009ec <printf>

00000000800005a8 <test_interrupt_overhead>:

// ==================== 测试3：中断性能测试 ====================
void test_interrupt_overhead(void) {
    800005a8:	715d                	addi	sp,sp,-80
    printf("正在测试中断开销...\n");
    800005aa:	00002517          	auipc	a0,0x2
    800005ae:	e0650513          	addi	a0,a0,-506 # 800023b0 <etext+0x3b0>
void test_interrupt_overhead(void) {
    800005b2:	e486                	sd	ra,72(sp)
    800005b4:	e0a2                	sd	s0,64(sp)
    800005b6:	fc26                	sd	s1,56(sp)
    800005b8:	f84a                	sd	s2,48(sp)
    800005ba:	f44e                	sd	s3,40(sp)
    800005bc:	f052                	sd	s4,32(sp)
    800005be:	ec56                	sd	s5,24(sp)
    800005c0:	e85a                	sd	s6,16(sp)
    printf("正在测试中断开销...\n");
    800005c2:	42a000ef          	jal	800009ec <printf>
    
    // 测量中断处理的时间开销
    printf("测量中断处理开销...\n");
    800005c6:	00002517          	auipc	a0,0x2
    800005ca:	e0a50513          	addi	a0,a0,-502 # 800023d0 <etext+0x3d0>
    800005ce:	41e000ef          	jal	800009ec <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800005d2:	100027f3          	csrr	a5,sstatus

// 禁用设备中断
static inline void
intr_off()
{
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800005d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800005d8:	10079073          	csrw	sstatus,a5
    
    // 禁用中断，测量基准性能
    intr_off();
    uint64 start_no_intr = get_time();
    800005dc:	3e1000ef          	jal	800011bc <get_time>
    volatile int sum = 0;
    for (int i = 0; i < 500000000; i++) {
    800005e0:	1dcd66b7          	lui	a3,0x1dcd6
    uint64 start_no_intr = get_time();
    800005e4:	842a                	mv	s0,a0
    volatile int sum = 0;
    800005e6:	c602                	sw	zero,12(sp)
    for (int i = 0; i < 500000000; i++) {
    800005e8:	50068693          	addi	a3,a3,1280 # 1dcd6500 <_entry-0x62329b00>
    800005ec:	4781                	li	a5,0
        sum += i;
    800005ee:	4732                	lw	a4,12(sp)
    800005f0:	9f3d                	addw	a4,a4,a5
    800005f2:	c63a                	sw	a4,12(sp)
    for (int i = 0; i < 500000000; i++) {
    800005f4:	2785                	addiw	a5,a5,1
    800005f6:	fed79ce3          	bne	a5,a3,800005ee <test_interrupt_overhead+0x46>
    }
    uint64 end_no_intr = get_time();
    800005fa:	3c3000ef          	jal	800011bc <get_time>
    800005fe:	8a2a                	mv	s4,a0
    uint64 cycles_no_intr = end_no_intr - start_no_intr;
    80000600:	408509b3          	sub	s3,a0,s0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000604:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000608:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000060c:	10079073          	csrw	sstatus,a5
    
    // 使能中断，测量有中断时的性能
    intr_on();
    int intr_before = get_interrupt_count();
    80000610:	3bd000ef          	jal	800011cc <get_interrupt_count>
    80000614:	8aaa                	mv	s5,a0
    uint64 start_with_intr = get_time();
    80000616:	3a7000ef          	jal	800011bc <get_time>
    sum = 0;
    for (int i = 0; i < 500000000; i++) {
    8000061a:	1dcd66b7          	lui	a3,0x1dcd6
    uint64 start_with_intr = get_time();
    8000061e:	8b2a                	mv	s6,a0
    sum = 0;
    80000620:	c602                	sw	zero,12(sp)
    for (int i = 0; i < 500000000; i++) {
    80000622:	50068693          	addi	a3,a3,1280 # 1dcd6500 <_entry-0x62329b00>
    80000626:	4781                	li	a5,0
        sum += i;
    80000628:	4732                	lw	a4,12(sp)
    8000062a:	9f3d                	addw	a4,a4,a5
    8000062c:	c63a                	sw	a4,12(sp)
    for (int i = 0; i < 500000000; i++) {
    8000062e:	2785                	addiw	a5,a5,1
    80000630:	fed79ce3          	bne	a5,a3,80000628 <test_interrupt_overhead+0x80>
    }
    uint64 end_with_intr = get_time();
    80000634:	389000ef          	jal	800011bc <get_time>
    80000638:	892a                	mv	s2,a0
    int intr_after = get_interrupt_count();
    8000063a:	393000ef          	jal	800011cc <get_interrupt_count>
    8000063e:	84aa                	mv	s1,a0
    
    // 测量上下文切换的成本
    int interrupts_occurred = intr_after - intr_before;
    uint64 overhead = cycles_with_intr - cycles_no_intr;
    
    printf("无中断时性能: %d 周期\n", (int)cycles_no_intr);
    80000640:	0009859b          	sext.w	a1,s3
    80000644:	00002517          	auipc	a0,0x2
    80000648:	dac50513          	addi	a0,a0,-596 # 800023f0 <etext+0x3f0>
    8000064c:	3a0000ef          	jal	800009ec <printf>
    uint64 cycles_with_intr = end_with_intr - start_with_intr;
    80000650:	41690933          	sub	s2,s2,s6
    printf("有中断时性能: %d 周期\n", (int)cycles_with_intr);
    80000654:	0009059b          	sext.w	a1,s2
    80000658:	00002517          	auipc	a0,0x2
    8000065c:	db850513          	addi	a0,a0,-584 # 80002410 <etext+0x410>
    80000660:	38c000ef          	jal	800009ec <printf>
    int interrupts_occurred = intr_after - intr_before;
    80000664:	415484bb          	subw	s1,s1,s5
    printf("发生中断次数: %d\n", interrupts_occurred);
    80000668:	85a6                	mv	a1,s1
    uint64 overhead = cycles_with_intr - cycles_no_intr;
    8000066a:	41440433          	sub	s0,s0,s4
    printf("发生中断次数: %d\n", interrupts_occurred);
    8000066e:	00002517          	auipc	a0,0x2
    80000672:	dc250513          	addi	a0,a0,-574 # 80002430 <etext+0x430>
    80000676:	376000ef          	jal	800009ec <printf>
    uint64 overhead = cycles_with_intr - cycles_no_intr;
    8000067a:	944a                	add	s0,s0,s2
    printf("总开销: %d 周期\n", (int)overhead);
    8000067c:	0004059b          	sext.w	a1,s0
    80000680:	00002517          	auipc	a0,0x2
    80000684:	dc850513          	addi	a0,a0,-568 # 80002448 <etext+0x448>
    80000688:	364000ef          	jal	800009ec <printf>
    
    // 分析中断频率对系统性能的影响
    if (interrupts_occurred > 0) {
    8000068c:	02905363          	blez	s1,800006b2 <test_interrupt_overhead+0x10a>
        printf("每次中断平均开销: %d 周期\n", 
               (int)(overhead / interrupts_occurred));
    80000690:	02945433          	divu	s0,s0,s1
        printf("每次中断平均开销: %d 周期\n", 
    80000694:	00002517          	auipc	a0,0x2
    80000698:	dcc50513          	addi	a0,a0,-564 # 80002460 <etext+0x460>
    8000069c:	2401                	sext.w	s0,s0
    8000069e:	85a2                	mv	a1,s0
    800006a0:	34c000ef          	jal	800009ec <printf>
        printf("上下文切换成本估计: ~%d 周期\n",
    800006a4:	85a2                	mv	a1,s0
    800006a6:	00002517          	auipc	a0,0x2
    800006aa:	de250513          	addi	a0,a0,-542 # 80002488 <etext+0x488>
    800006ae:	33e000ef          	jal	800009ec <printf>
               (int)(overhead / interrupts_occurred));
    }
    
    printf("中断开销测试完成\n");
}
    800006b2:	6406                	ld	s0,64(sp)
    800006b4:	60a6                	ld	ra,72(sp)
    800006b6:	74e2                	ld	s1,56(sp)
    800006b8:	7942                	ld	s2,48(sp)
    800006ba:	79a2                	ld	s3,40(sp)
    800006bc:	7a02                	ld	s4,32(sp)
    800006be:	6ae2                	ld	s5,24(sp)
    800006c0:	6b42                	ld	s6,16(sp)
    printf("中断开销测试完成\n");
    800006c2:	00002517          	auipc	a0,0x2
    800006c6:	df650513          	addi	a0,a0,-522 # 800024b8 <etext+0x4b8>
}
    800006ca:	6161                	addi	sp,sp,80
    printf("中断开销测试完成\n");
    800006cc:	a605                	j	800009ec <printf>

00000000800006ce <main>:

// ==================== 主函数 ====================
void
main(void)
{
    800006ce:	1141                	addi	sp,sp,-16
    800006d0:	e406                	sd	ra,8(sp)
    // 初始化printf系统
    printf_init();
    800006d2:	74a000ef          	jal	80000e1c <printf_init>
    
    // 清屏并输出欢迎信息
    clear_screen();
    800006d6:	9e9ff0ef          	jal	800000be <clear_screen>
    printf("=====================================\n");
    800006da:	00002517          	auipc	a0,0x2
    800006de:	dfe50513          	addi	a0,a0,-514 # 800024d8 <etext+0x4d8>
    800006e2:	30a000ef          	jal	800009ec <printf>
    printf("  实验4：中断处理与时钟管理测试     \n");
    800006e6:	00002517          	auipc	a0,0x2
    800006ea:	e1a50513          	addi	a0,a0,-486 # 80002500 <etext+0x500>
    800006ee:	2fe000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    800006f2:	00002517          	auipc	a0,0x2
    800006f6:	de650513          	addi	a0,a0,-538 # 800024d8 <etext+0x4d8>
    800006fa:	2f2000ef          	jal	800009ec <printf>
// 读写线程指针（hartid）
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    800006fe:	8592                	mv	a1,tp
    printf("Hart ID: %d\n", (int)r_tp());
    80000700:	00002517          	auipc	a0,0x2
    80000704:	e3850513          	addi	a0,a0,-456 # 80002538 <etext+0x538>
    80000708:	2581                	sext.w	a1,a1
    8000070a:	2e2000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    8000070e:	00002517          	auipc	a0,0x2
    80000712:	dca50513          	addi	a0,a0,-566 # 800024d8 <etext+0x4d8>
    80000716:	2d6000ef          	jal	800009ec <printf>
    
    // 初始化中断系统
    printf("\n[步骤1] 初始化中断系统\n");
    8000071a:	00002517          	auipc	a0,0x2
    8000071e:	e2e50513          	addi	a0,a0,-466 # 80002548 <etext+0x548>
    80000722:	2ca000ef          	jal	800009ec <printf>
    trapinit();
    80000726:	7ca000ef          	jal	80000ef0 <trapinit>
    
    // 显示初始状态
    printf("\n[步骤2] 系统初始状态\n");
    8000072a:	00002517          	auipc	a0,0x2
    8000072e:	e4650513          	addi	a0,a0,-442 # 80002570 <etext+0x570>
    80000732:	2ba000ef          	jal	800009ec <printf>
    show_interrupt_stats();
    80000736:	2a1000ef          	jal	800011d6 <show_interrupt_stats>
    
    printf("\n");
    8000073a:	00002517          	auipc	a0,0x2
    8000073e:	e5650513          	addi	a0,a0,-426 # 80002590 <etext+0x590>
    80000742:	2aa000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    80000746:	00002517          	auipc	a0,0x2
    8000074a:	d9250513          	addi	a0,a0,-622 # 800024d8 <etext+0x4d8>
    8000074e:	29e000ef          	jal	800009ec <printf>
    printf("      开始运行测试...                \n");
    80000752:	00002517          	auipc	a0,0x2
    80000756:	e4650513          	addi	a0,a0,-442 # 80002598 <etext+0x598>
    8000075a:	292000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    8000075e:	00002517          	auipc	a0,0x2
    80000762:	d7a50513          	addi	a0,a0,-646 # 800024d8 <etext+0x4d8>
    80000766:	286000ef          	jal	800009ec <printf>
    
    // 运行三个核心测试
    printf("\n[测试1] 时钟中断测试\n");
    8000076a:	00002517          	auipc	a0,0x2
    8000076e:	e5e50513          	addi	a0,a0,-418 # 800025c8 <etext+0x5c8>
    80000772:	27a000ef          	jal	800009ec <printf>
    printf("-------------------------------------\n");
    80000776:	00002517          	auipc	a0,0x2
    8000077a:	e7250513          	addi	a0,a0,-398 # 800025e8 <etext+0x5e8>
    8000077e:	26e000ef          	jal	800009ec <printf>
    test_timer_interrupt();
    80000782:	d17ff0ef          	jal	80000498 <test_timer_interrupt>
    
    printf("\n[测试2] 异常处理测试\n");
    80000786:	00002517          	auipc	a0,0x2
    8000078a:	e8a50513          	addi	a0,a0,-374 # 80002610 <etext+0x610>
    8000078e:	25e000ef          	jal	800009ec <printf>
    printf("-------------------------------------\n");
    80000792:	00002517          	auipc	a0,0x2
    80000796:	e5650513          	addi	a0,a0,-426 # 800025e8 <etext+0x5e8>
    8000079a:	252000ef          	jal	800009ec <printf>
    test_exception_handling();
    8000079e:	dbdff0ef          	jal	8000055a <test_exception_handling>
    
    printf("\n[测试3] 中断开销测试\n");
    800007a2:	00002517          	auipc	a0,0x2
    800007a6:	e8e50513          	addi	a0,a0,-370 # 80002630 <etext+0x630>
    800007aa:	242000ef          	jal	800009ec <printf>
    printf("-------------------------------------\n");
    800007ae:	00002517          	auipc	a0,0x2
    800007b2:	e3a50513          	addi	a0,a0,-454 # 800025e8 <etext+0x5e8>
    800007b6:	236000ef          	jal	800009ec <printf>
    test_interrupt_overhead();
    800007ba:	defff0ef          	jal	800005a8 <test_interrupt_overhead>
    
    // 最终统计
    printf("\n");
    800007be:	00002517          	auipc	a0,0x2
    800007c2:	dd250513          	addi	a0,a0,-558 # 80002590 <etext+0x590>
    800007c6:	226000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    800007ca:	00002517          	auipc	a0,0x2
    800007ce:	d0e50513          	addi	a0,a0,-754 # 800024d8 <etext+0x4d8>
    800007d2:	21a000ef          	jal	800009ec <printf>
    printf("      最终统计信息                   \n");
    800007d6:	00002517          	auipc	a0,0x2
    800007da:	e7a50513          	addi	a0,a0,-390 # 80002650 <etext+0x650>
    800007de:	20e000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    800007e2:	00002517          	auipc	a0,0x2
    800007e6:	cf650513          	addi	a0,a0,-778 # 800024d8 <etext+0x4d8>
    800007ea:	202000ef          	jal	800009ec <printf>
    show_interrupt_stats();
    800007ee:	1e9000ef          	jal	800011d6 <show_interrupt_stats>
    
    // 总结
    printf("\n");
    800007f2:	00002517          	auipc	a0,0x2
    800007f6:	d9e50513          	addi	a0,a0,-610 # 80002590 <etext+0x590>
    800007fa:	1f2000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    800007fe:	00002517          	auipc	a0,0x2
    80000802:	cda50513          	addi	a0,a0,-806 # 800024d8 <etext+0x4d8>
    80000806:	1e6000ef          	jal	800009ec <printf>
    printf("      所有测试完成!                  \n");
    8000080a:	00002517          	auipc	a0,0x2
    8000080e:	e7650513          	addi	a0,a0,-394 # 80002680 <etext+0x680>
    80000812:	1da000ef          	jal	800009ec <printf>
    printf("=====================================\n");
    80000816:	00002517          	auipc	a0,0x2
    8000081a:	cc250513          	addi	a0,a0,-830 # 800024d8 <etext+0x4d8>
    8000081e:	1ce000ef          	jal	800009ec <printf>
    printf("已实现功能:\n");
    80000822:	00002517          	auipc	a0,0x2
    80000826:	e8e50513          	addi	a0,a0,-370 # 800026b0 <etext+0x6b0>
    8000082a:	1c2000ef          	jal	800009ec <printf>
    printf("  * 中断向量表配置 (stvec)\n");
    8000082e:	00002517          	auipc	a0,0x2
    80000832:	e9a50513          	addi	a0,a0,-358 # 800026c8 <etext+0x6c8>
    80000836:	1b6000ef          	jal	800009ec <printf>
    printf("  * 时钟中断处理\n");
    8000083a:	00002517          	auipc	a0,0x2
    8000083e:	eb650513          	addi	a0,a0,-330 # 800026f0 <etext+0x6f0>
    80000842:	1aa000ef          	jal	800009ec <printf>
    printf("  * 异常处理框架\n");
    80000846:	00002517          	auipc	a0,0x2
    8000084a:	ec250513          	addi	a0,a0,-318 # 80002708 <etext+0x708>
    8000084e:	19e000ef          	jal	800009ec <printf>
    printf("  * 中断使能/禁用控制\n");
    80000852:	00002517          	auipc	a0,0x2
    80000856:	ece50513          	addi	a0,a0,-306 # 80002720 <etext+0x720>
    8000085a:	192000ef          	jal	800009ec <printf>
    printf("  * 性能测量\n");
    8000085e:	00002517          	auipc	a0,0x2
    80000862:	ee250513          	addi	a0,a0,-286 # 80002740 <etext+0x740>
    80000866:	186000ef          	jal	800009ec <printf>
    printf("  * 上下文保存/恢复\n");
    8000086a:	00002517          	auipc	a0,0x2
    8000086e:	eee50513          	addi	a0,a0,-274 # 80002758 <etext+0x758>
    80000872:	17a000ef          	jal	800009ec <printf>
    printf("\n");
    80000876:	00002517          	auipc	a0,0x2
    8000087a:	d1a50513          	addi	a0,a0,-742 # 80002590 <etext+0x590>
    8000087e:	16e000ef          	jal	800009ec <printf>
    printf("关键技术验证:\n");
    80000882:	00002517          	auipc	a0,0x2
    80000886:	ef650513          	addi	a0,a0,-266 # 80002778 <etext+0x778>
    8000088a:	162000ef          	jal	800009ec <printf>
    printf("  * CSR寄存器操作\n");
    8000088e:	00002517          	auipc	a0,0x2
    80000892:	f0250513          	addi	a0,a0,-254 # 80002790 <etext+0x790>
    80000896:	156000ef          	jal	800009ec <printf>
    printf("  * M模式到S模式转换\n");
    8000089a:	00002517          	auipc	a0,0x2
    8000089e:	f0e50513          	addi	a0,a0,-242 # 800027a8 <etext+0x7a8>
    800008a2:	14a000ef          	jal	800009ec <printf>
    printf("  * 中断委托\n");
    800008a6:	00002517          	auipc	a0,0x2
    800008aa:	f2250513          	addi	a0,a0,-222 # 800027c8 <etext+0x7c8>
    800008ae:	13e000ef          	jal	800009ec <printf>
    printf("  * 时钟配置 (stimecmp)\n");
    800008b2:	00002517          	auipc	a0,0x2
    800008b6:	f2e50513          	addi	a0,a0,-210 # 800027e0 <etext+0x7e0>
    800008ba:	132000ef          	jal	800009ec <printf>
    printf("  * 内核中断处理流程\n");
    800008be:	00002517          	auipc	a0,0x2
    800008c2:	f4250513          	addi	a0,a0,-190 # 80002800 <etext+0x800>
    800008c6:	126000ef          	jal	800009ec <printf>
    printf("  * 寄存器保存/恢复 (kernelvec.S)\n");
    800008ca:	00002517          	auipc	a0,0x2
    800008ce:	f5650513          	addi	a0,a0,-170 # 80002820 <etext+0x820>
    800008d2:	11a000ef          	jal	800009ec <printf>
    printf("  * 中断开销分析\n");
    800008d6:	00002517          	auipc	a0,0x2
    800008da:	f7a50513          	addi	a0,a0,-134 # 80002850 <etext+0x850>
    800008de:	10e000ef          	jal	800009ec <printf>
    printf("\n");
    800008e2:	00002517          	auipc	a0,0x2
    800008e6:	cae50513          	addi	a0,a0,-850 # 80002590 <etext+0x590>
    800008ea:	102000ef          	jal	800009ec <printf>
    
    // 保持中断使能，进入待机状态
    printf("系统就绪。按 Ctrl+A, X 退出QEMU\n");
    800008ee:	60a2                	ld	ra,8(sp)
    printf("系统就绪。按 Ctrl+A, X 退出QEMU\n");
    800008f0:	00002517          	auipc	a0,0x2
    800008f4:	f7850513          	addi	a0,a0,-136 # 80002868 <etext+0x868>
    800008f8:	0141                	addi	sp,sp,16
    printf("系统就绪。按 Ctrl+A, X 退出QEMU\n");
    800008fa:	a8cd                	j	800009ec <printf>

00000000800008fc <print_number>:
#define COLOR_WHITE      7

// 数字转换函数 - 将数字转换为指定进制的字符串
static void 
print_number(long long num, int base, int is_signed) 
{
    800008fc:	7139                	addi	sp,sp,-64
    800008fe:	fc06                	sd	ra,56(sp)
    80000900:	f822                	sd	s0,48(sp)
    80000902:	f426                	sd	s1,40(sp)
    int idx = 0;
    unsigned long long unum;
    
    // 处理符号问题
    int negative = 0;
    if (is_signed && num < 0) {
    80000904:	06055763          	bgez	a0,80000972 <print_number+0x76>
    80000908:	8a05                	andi	a2,a2,1
    8000090a:	c625                	beqz	a2,80000972 <print_number+0x76>
        negative = 1;
        unum = (unsigned long long)(-num);  // 转为正数处理
    8000090c:	40a00533          	neg	a0,a0
        negative = 1;
    80000910:	4305                	li	t1,1
    // 处理特殊情况: 0
    if (unum == 0) {
        buf[idx++] = '0';
    } else {
        // 将数字转换为字符，从低位到高位
        while (unum != 0) {
    80000912:	840a                	mv	s0,sp
    80000914:	868a                	mv	a3,sp
    int idx = 0;
    80000916:	4701                	li	a4,0
    80000918:	00003897          	auipc	a7,0x3
    8000091c:	99888893          	addi	a7,a7,-1640 # 800032b0 <digits>
            buf[idx++] = digits[unum % base];
    80000920:	02b577b3          	remu	a5,a0,a1
    80000924:	882a                	mv	a6,a0
    80000926:	863a                	mv	a2,a4
        while (unum != 0) {
    80000928:	0685                	addi	a3,a3,1
            buf[idx++] = digits[unum % base];
    8000092a:	2705                	addiw	a4,a4,1 # 1001 <_entry-0x7fffefff>
    8000092c:	97c6                	add	a5,a5,a7
    8000092e:	0007c783          	lbu	a5,0(a5)
            unum /= base;
    80000932:	02b55533          	divu	a0,a0,a1
            buf[idx++] = digits[unum % base];
    80000936:	fef68fa3          	sb	a5,-1(a3)
        while (unum != 0) {
    8000093a:	feb873e3          	bgeu	a6,a1,80000920 <print_number+0x24>
        }
    }
    
    // 添加负号（如果需要）
    if (negative) {
    8000093e:	04030263          	beqz	t1,80000982 <print_number+0x86>
        buf[idx++] = '-';
    80000942:	970a                	add	a4,a4,sp
    80000944:	02d00793          	li	a5,45
    80000948:	2609                	addiw	a2,a2,2
    8000094a:	00f70023          	sb	a5,0(a4)
    }
    
    // 反向输出字符
    while (idx > 0) {
    8000094e:	367d                	addiw	a2,a2,-1
    80000950:	1602                	slli	a2,a2,0x20
    80000952:	9201                	srli	a2,a2,0x20
    80000954:	fff10493          	addi	s1,sp,-1
    80000958:	9432                	add	s0,s0,a2
        console_putc(buf[--idx]);
    8000095a:	00044503          	lbu	a0,0(s0)
    while (idx > 0) {
    8000095e:	147d                	addi	s0,s0,-1
        console_putc(buf[--idx]);
    80000960:	ec4ff0ef          	jal	80000024 <console_putc>
    while (idx > 0) {
    80000964:	fe941be3          	bne	s0,s1,8000095a <print_number+0x5e>
    }
}
    80000968:	70e2                	ld	ra,56(sp)
    8000096a:	7442                	ld	s0,48(sp)
    8000096c:	74a2                	ld	s1,40(sp)
    8000096e:	6121                	addi	sp,sp,64
    80000970:	8082                	ret
    if (unum == 0) {
    80000972:	e911                	bnez	a0,80000986 <print_number+0x8a>
        buf[idx++] = '0';
    80000974:	03000793          	li	a5,48
    80000978:	00f10023          	sb	a5,0(sp)
    8000097c:	4605                	li	a2,1
    8000097e:	840a                	mv	s0,sp
    80000980:	b7f9                	j	8000094e <print_number+0x52>
    80000982:	863a                	mv	a2,a4
    80000984:	b7e9                	j	8000094e <print_number+0x52>
    int negative = 0;
    80000986:	4301                	li	t1,0
    80000988:	b769                	j	80000912 <print_number+0x16>

000000008000098a <print_ptr>:

// 打印指针地址
static void 
print_ptr(uint64 ptr) 
{
    8000098a:	7179                	addi	sp,sp,-48
    8000098c:	ec26                	sd	s1,24(sp)
    8000098e:	84aa                	mv	s1,a0
    console_puts("0x");
    80000990:	00002517          	auipc	a0,0x2
    80000994:	f0850513          	addi	a0,a0,-248 # 80002898 <etext+0x898>
{
    80000998:	f022                	sd	s0,32(sp)
    8000099a:	f406                	sd	ra,40(sp)
    8000099c:	e84a                	sd	s2,16(sp)
    8000099e:	e44e                	sd	s3,8(sp)
    // 对于64位指针，我们需要输出16个十六进制数字
    int i;
    int leading_zeros = 1;  // 是否跳过前导零
    
    // 从高位到低位，每4位一组转换为一个十六进制数字
    for (i = 60; i >= 0; i -= 4) {
    800009a0:	03c00413          	li	s0,60
    console_puts("0x");
    800009a4:	eb6ff0ef          	jal	8000005a <console_puts>
        int digit = (ptr >> i) & 0xf;
    800009a8:	0084d7b3          	srl	a5,s1,s0
    800009ac:	8bbd                	andi	a5,a5,15
        
        // 跳过前导零，但至少输出一个0
        if (digit == 0 && leading_zeros && i != 0) {
    800009ae:	e799                	bnez	a5,800009bc <print_ptr+0x32>
    800009b0:	c411                	beqz	s0,800009bc <print_ptr+0x32>
    for (i = 60; i >= 0; i -= 4) {
    800009b2:	3471                	addiw	s0,s0,-4
        int digit = (ptr >> i) & 0xf;
    800009b4:	0084d7b3          	srl	a5,s1,s0
    800009b8:	8bbd                	andi	a5,a5,15
        if (digit == 0 && leading_zeros && i != 0) {
    800009ba:	dbfd                	beqz	a5,800009b0 <print_ptr+0x26>
    800009bc:	00003997          	auipc	s3,0x3
    800009c0:	8f498993          	addi	s3,s3,-1804 # 800032b0 <digits>
    for (i = 60; i >= 0; i -= 4) {
    800009c4:	5971                	li	s2,-4
    800009c6:	a011                	j	800009ca <print_ptr+0x40>
        int digit = (ptr >> i) & 0xf;
    800009c8:	8bbd                	andi	a5,a5,15
            continue;
        }
        
        leading_zeros = 0;
        console_putc(digits[digit]);
    800009ca:	97ce                	add	a5,a5,s3
    800009cc:	0007c503          	lbu	a0,0(a5)
    for (i = 60; i >= 0; i -= 4) {
    800009d0:	3471                	addiw	s0,s0,-4
        console_putc(digits[digit]);
    800009d2:	e52ff0ef          	jal	80000024 <console_putc>
        int digit = (ptr >> i) & 0xf;
    800009d6:	0084d7b3          	srl	a5,s1,s0
    for (i = 60; i >= 0; i -= 4) {
    800009da:	ff2417e3          	bne	s0,s2,800009c8 <print_ptr+0x3e>
    }
}
    800009de:	70a2                	ld	ra,40(sp)
    800009e0:	7402                	ld	s0,32(sp)
    800009e2:	64e2                	ld	s1,24(sp)
    800009e4:	6942                	ld	s2,16(sp)
    800009e6:	69a2                	ld	s3,8(sp)
    800009e8:	6145                	addi	sp,sp,48
    800009ea:	8082                	ret

00000000800009ec <printf>:

// 格式化输出到控制台
int 
printf(const char *fmt, ...) 
{
    800009ec:	7175                	addi	sp,sp,-144
    800009ee:	e0a2                	sd	s0,64(sp)
    800009f0:	fcbe                	sd	a5,120(sp)
    800009f2:	e486                	sd	ra,72(sp)
    800009f4:	f84a                	sd	s2,48(sp)
    800009f6:	ecae                	sd	a1,88(sp)
    800009f8:	f0b2                	sd	a2,96(sp)
    800009fa:	f4b6                	sd	a3,104(sp)
    800009fc:	f8ba                	sd	a4,112(sp)
    800009fe:	e142                	sd	a6,128(sp)
    80000a00:	e546                	sd	a7,136(sp)
    80000a02:	842a                	mv	s0,a0
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
    80000a04:	00054503          	lbu	a0,0(a0)
    va_start(ap, fmt);
    80000a08:	08bc                	addi	a5,sp,88
    80000a0a:	e43e                	sd	a5,8(sp)
    for (const char *p = fmt; *p; p++) {
    80000a0c:	0e050c63          	beqz	a0,80000b04 <printf+0x118>
    80000a10:	f44e                	sd	s3,40(sp)
    80000a12:	f052                	sd	s4,32(sp)
    80000a14:	ec56                	sd	s5,24(sp)
    80000a16:	fc26                	sd	s1,56(sp)
    int count = 0;
    80000a18:	4901                	li	s2,0
        if (*p != '%') {
    80000a1a:	02500993          	li	s3,37
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
    80000a1e:	4ad5                	li	s5,21
    80000a20:	00002a17          	auipc	s4,0x2
    80000a24:	7e0a0a13          	addi	s4,s4,2016 # 80003200 <etext+0x1200>
            count++;
    80000a28:	2905                	addiw	s2,s2,1 # 1001 <_entry-0x7fffefff>
        if (*p != '%') {
    80000a2a:	0b351e63          	bne	a0,s3,80000ae6 <printf+0xfa>
        switch (*p) {
    80000a2e:	00144783          	lbu	a5,1(s0)
        p++;
    80000a32:	00140493          	addi	s1,s0,1
        switch (*p) {
    80000a36:	0b378c63          	beq	a5,s3,80000aee <printf+0x102>
    80000a3a:	f9d7879b          	addiw	a5,a5,-99
    80000a3e:	0ff7f793          	zext.b	a5,a5
    80000a42:	00fae763          	bltu	s5,a5,80000a50 <printf+0x64>
    80000a46:	078a                	slli	a5,a5,0x2
    80000a48:	97d2                	add	a5,a5,s4
    80000a4a:	439c                	lw	a5,0(a5)
    80000a4c:	97d2                	add	a5,a5,s4
    80000a4e:	8782                	jr	a5
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
    80000a50:	02500513          	li	a0,37
    80000a54:	dd0ff0ef          	jal	80000024 <console_putc>
                console_putc(*p);
    80000a58:	00144503          	lbu	a0,1(s0)
    80000a5c:	dc8ff0ef          	jal	80000024 <console_putc>
    for (const char *p = fmt; *p; p++) {
    80000a60:	0014c503          	lbu	a0,1(s1)
    80000a64:	00148413          	addi	s0,s1,1
    80000a68:	f161                	bnez	a0,80000a28 <printf+0x3c>
        count++;
    }
    
    va_end(ap);
    return count;
}
    80000a6a:	60a6                	ld	ra,72(sp)
    80000a6c:	6406                	ld	s0,64(sp)
    80000a6e:	74e2                	ld	s1,56(sp)
    80000a70:	79a2                	ld	s3,40(sp)
    80000a72:	7a02                	ld	s4,32(sp)
    80000a74:	6ae2                	ld	s5,24(sp)
    80000a76:	854a                	mv	a0,s2
    80000a78:	7942                	ld	s2,48(sp)
    80000a7a:	6149                	addi	sp,sp,144
    80000a7c:	8082                	ret
                print_number(va_arg(ap, unsigned int), 16, 0);
    80000a7e:	67a2                	ld	a5,8(sp)
    80000a80:	4601                	li	a2,0
    80000a82:	45c1                	li	a1,16
    80000a84:	0007e503          	lwu	a0,0(a5)
    80000a88:	07a1                	addi	a5,a5,8
    80000a8a:	e43e                	sd	a5,8(sp)
    80000a8c:	e71ff0ef          	jal	800008fc <print_number>
                break;
    80000a90:	bfc1                	j	80000a60 <printf+0x74>
                print_number(va_arg(ap, unsigned int), 10, 0);
    80000a92:	67a2                	ld	a5,8(sp)
    80000a94:	4601                	li	a2,0
    80000a96:	45a9                	li	a1,10
    80000a98:	0007e503          	lwu	a0,0(a5)
    80000a9c:	07a1                	addi	a5,a5,8
    80000a9e:	e43e                	sd	a5,8(sp)
    80000aa0:	e5dff0ef          	jal	800008fc <print_number>
                break;
    80000aa4:	bf75                	j	80000a60 <printf+0x74>
                    const char *s = va_arg(ap, const char *);
    80000aa6:	67a2                	ld	a5,8(sp)
    80000aa8:	6388                	ld	a0,0(a5)
    80000aaa:	07a1                	addi	a5,a5,8
    80000aac:	e43e                	sd	a5,8(sp)
                    if (s == 0) {
    80000aae:	c521                	beqz	a0,80000af6 <printf+0x10a>
                        console_puts(s);
    80000ab0:	daaff0ef          	jal	8000005a <console_puts>
    80000ab4:	b775                	j	80000a60 <printf+0x74>
                print_ptr(va_arg(ap, uint64));
    80000ab6:	67a2                	ld	a5,8(sp)
    80000ab8:	6388                	ld	a0,0(a5)
    80000aba:	07a1                	addi	a5,a5,8
    80000abc:	e43e                	sd	a5,8(sp)
    80000abe:	ecdff0ef          	jal	8000098a <print_ptr>
                break;
    80000ac2:	bf79                	j	80000a60 <printf+0x74>
                print_number(va_arg(ap, int), 10, 1);
    80000ac4:	67a2                	ld	a5,8(sp)
    80000ac6:	4605                	li	a2,1
    80000ac8:	45a9                	li	a1,10
    80000aca:	4388                	lw	a0,0(a5)
    80000acc:	07a1                	addi	a5,a5,8
    80000ace:	e43e                	sd	a5,8(sp)
    80000ad0:	e2dff0ef          	jal	800008fc <print_number>
                break;
    80000ad4:	b771                	j	80000a60 <printf+0x74>
                console_putc(va_arg(ap, int));
    80000ad6:	67a2                	ld	a5,8(sp)
    80000ad8:	0007c503          	lbu	a0,0(a5)
    80000adc:	07a1                	addi	a5,a5,8
    80000ade:	e43e                	sd	a5,8(sp)
    80000ae0:	d44ff0ef          	jal	80000024 <console_putc>
                break;
    80000ae4:	bfb5                	j	80000a60 <printf+0x74>
            console_putc(*p);
    80000ae6:	d3eff0ef          	jal	80000024 <console_putc>
            continue;
    80000aea:	84a2                	mv	s1,s0
    80000aec:	bf95                	j	80000a60 <printf+0x74>
                console_putc('%');
    80000aee:	854e                	mv	a0,s3
    80000af0:	d34ff0ef          	jal	80000024 <console_putc>
                break;
    80000af4:	b7b5                	j	80000a60 <printf+0x74>
                        console_puts("(null)");
    80000af6:	00002517          	auipc	a0,0x2
    80000afa:	daa50513          	addi	a0,a0,-598 # 800028a0 <etext+0x8a0>
    80000afe:	d5cff0ef          	jal	8000005a <console_puts>
    80000b02:	bfb9                	j	80000a60 <printf+0x74>
}
    80000b04:	60a6                	ld	ra,72(sp)
    80000b06:	6406                	ld	s0,64(sp)
    int count = 0;
    80000b08:	4901                	li	s2,0
}
    80000b0a:	854a                	mv	a0,s2
    80000b0c:	7942                	ld	s2,48(sp)
    80000b0e:	6149                	addi	sp,sp,144
    80000b10:	8082                	ret

0000000080000b12 <sprintf>:

// 格式化输出到缓冲区
int 
sprintf(char *buf, const char *fmt, ...) 
{
    80000b12:	7151                	addi	sp,sp,-240
    80000b14:	edbe                	sd	a5,216(sp)
    80000b16:	f1c2                	sd	a6,224(sp)
    80000b18:	e1b2                	sd	a2,192(sp)
    80000b1a:	e5b6                	sd	a3,200(sp)
    80000b1c:	e9ba                	sd	a4,208(sp)
    80000b1e:	f5c6                	sd	a7,232(sp)
    va_start(ap, fmt);
    
    // 这是一个简化的实现，仅支持基本功能
    // 在实际项目中，应该复用printf的代码逻辑，但输出到缓冲区
    
    for (const char *p = fmt; *p; p++) {
    80000b20:	0005c703          	lbu	a4,0(a1)
    va_start(ap, fmt);
    80000b24:	019c                	addi	a5,sp,192
    80000b26:	e43e                	sd	a5,8(sp)
{
    80000b28:	882a                	mv	a6,a0
    int count = 0;
    80000b2a:	4501                	li	a0,0
    for (const char *p = fmt; *p; p++) {
    80000b2c:	c725                	beqz	a4,80000b94 <sprintf+0x82>
    80000b2e:	87c2                	mv	a5,a6
        if (*p != '%') {
    80000b30:	02500893          	li	a7,37
            continue;
        }
        
        p++;
        
        switch (*p) {
    80000b34:	06400313          	li	t1,100
    80000b38:	00180e93          	addi	t4,a6,1
    80000b3c:	07300e13          	li	t3,115
    80000b40:	a821                	j	80000b58 <sprintf+0x46>
            buf[idx++] = *p;
    80000b42:	2505                	addiw	a0,a0,1
    80000b44:	00e78023          	sb	a4,0(a5)
            continue;
    80000b48:	86ae                	mv	a3,a1
    80000b4a:	00a807b3          	add	a5,a6,a0
    for (const char *p = fmt; *p; p++) {
    80000b4e:	0016c703          	lbu	a4,1(a3)
    80000b52:	00168593          	addi	a1,a3,1
    80000b56:	cf15                	beqz	a4,80000b92 <sprintf+0x80>
        p++;
    80000b58:	00158693          	addi	a3,a1,1
        if (*p != '%') {
    80000b5c:	ff1713e3          	bne	a4,a7,80000b42 <sprintf+0x30>
        switch (*p) {
    80000b60:	0015c703          	lbu	a4,1(a1)
    80000b64:	06670b63          	beq	a4,t1,80000bda <sprintf+0xc8>
    80000b68:	05c70063          	beq	a4,t3,80000ba8 <sprintf+0x96>
    80000b6c:	03170863          	beq	a4,a7,80000b9c <sprintf+0x8a>
                buf[idx++] = '%';
                count++;
                break;
                
            default:   // 未知格式符
                buf[idx++] = '%';
    80000b70:	01178023          	sb	a7,0(a5)
                buf[idx++] = *p;
    80000b74:	0015c703          	lbu	a4,1(a1)
                buf[idx++] = '%';
    80000b78:	0015079b          	addiw	a5,a0,1
                buf[idx++] = *p;
    80000b7c:	97c2                	add	a5,a5,a6
    80000b7e:	2509                	addiw	a0,a0,2
    80000b80:	00e78023          	sb	a4,0(a5)
                count += 2;
                break;
    80000b84:	00a807b3          	add	a5,a6,a0
    for (const char *p = fmt; *p; p++) {
    80000b88:	0016c703          	lbu	a4,1(a3)
    80000b8c:	00168593          	addi	a1,a3,1
    80000b90:	f761                	bnez	a4,80000b58 <sprintf+0x46>
        }
    }
    
    // 添加字符串结束符
    buf[idx] = '\0';
    80000b92:	883e                	mv	a6,a5
    80000b94:	00080023          	sb	zero,0(a6)
    
    va_end(ap);
    return count;
}
    80000b98:	616d                	addi	sp,sp,240
    80000b9a:	8082                	ret
                buf[idx++] = '%';
    80000b9c:	2505                	addiw	a0,a0,1
    80000b9e:	01178023          	sb	a7,0(a5)
                break;
    80000ba2:	00a807b3          	add	a5,a6,a0
    80000ba6:	b765                	j	80000b4e <sprintf+0x3c>
                const char *s = va_arg(ap, const char *);
    80000ba8:	6722                	ld	a4,8(sp)
    80000baa:	00073f03          	ld	t5,0(a4)
    80000bae:	0721                	addi	a4,a4,8
    80000bb0:	e43a                	sd	a4,8(sp)
                if (s == 0) {
    80000bb2:	0e0f0763          	beqz	t5,80000ca0 <sprintf+0x18e>
                    while (*s) {
    80000bb6:	000f4603          	lbu	a2,0(t5)
    80000bba:	85be                	mv	a1,a5
                const char *s = va_arg(ap, const char *);
    80000bbc:	877a                	mv	a4,t5
                    while (*s) {
    80000bbe:	da41                	beqz	a2,80000b4e <sprintf+0x3c>
                        buf[idx++] = *s++;
    80000bc0:	00c58023          	sb	a2,0(a1)
                    while (*s) {
    80000bc4:	00174603          	lbu	a2,1(a4)
                        buf[idx++] = *s++;
    80000bc8:	0705                	addi	a4,a4,1
                    while (*s) {
    80000bca:	0585                	addi	a1,a1,1
    80000bcc:	fa75                	bnez	a2,80000bc0 <sprintf+0xae>
                        buf[idx++] = *s++;
    80000bce:	41e7073b          	subw	a4,a4,t5
    80000bd2:	9d39                	addw	a0,a0,a4
    80000bd4:	00a807b3          	add	a5,a6,a0
    80000bd8:	bf9d                	j	80000b4e <sprintf+0x3c>
                int num = va_arg(ap, int);
    80000bda:	6722                	ld	a4,8(sp)
    80000bdc:	00072f03          	lw	t5,0(a4)
    80000be0:	0721                	addi	a4,a4,8
    80000be2:	e43a                	sd	a4,8(sp)
                if (num < 0) {
    80000be4:	020f4f63          	bltz	t5,80000c22 <sprintf+0x110>
                if (unum == 0) {
    80000be8:	0c0f1d63          	bnez	t5,80000cc2 <sprintf+0x1b0>
                    temp_buf[temp_idx++] = '0';
    80000bec:	03000713          	li	a4,48
    80000bf0:	00e10823          	sb	a4,16(sp)
    80000bf4:	4285                	li	t0,1
    80000bf6:	0818                	addi	a4,sp,16
    80000bf8:	fff2861b          	addiw	a2,t0,-1
    80000bfc:	1602                	slli	a2,a2,0x20
    80000bfe:	9201                	srli	a2,a2,0x20
    80000c00:	00ae85b3          	add	a1,t4,a0
    80000c04:	9732                	add	a4,a4,a2
    80000c06:	95b2                	add	a1,a1,a2
                    buf[idx++] = temp_buf[--temp_idx];
    80000c08:	00074603          	lbu	a2,0(a4)
                while (temp_idx > 0) {
    80000c0c:	0785                	addi	a5,a5,1
    80000c0e:	177d                	addi	a4,a4,-1
                    buf[idx++] = temp_buf[--temp_idx];
    80000c10:	fec78fa3          	sb	a2,-1(a5)
                while (temp_idx > 0) {
    80000c14:	feb79ae3          	bne	a5,a1,80000c08 <sprintf+0xf6>
    80000c18:	0055053b          	addw	a0,a0,t0
    80000c1c:	00a807b3          	add	a5,a6,a0
    80000c20:	b73d                	j	80000b4e <sprintf+0x3c>
    80000c22:	ed52                	sd	s4,152(sp)
                    unum = -num;
    80000c24:	fd22                	sd	s0,184(sp)
    80000c26:	f926                	sd	s1,176(sp)
    80000c28:	f54a                	sd	s2,168(sp)
    80000c2a:	f14e                	sd	s3,160(sp)
    80000c2c:	41e00f3b          	negw	t5,t5
                    negative = 1;
    80000c30:	4a05                	li	s4,1
                    while (unum > 0) {
    80000c32:	0818                	addi	a4,sp,16
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000c34:	4485                	li	s1,1
    80000c36:	66666437          	lui	s0,0x66666
                    negative = 1;
    80000c3a:	8fba                	mv	t6,a4
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000c3c:	9c99                	subw	s1,s1,a4
    80000c3e:	66740413          	addi	s0,s0,1639 # 66666667 <_entry-0x19999999>
    80000c42:	00002997          	auipc	s3,0x2
    80000c46:	66e98993          	addi	s3,s3,1646 # 800032b0 <digits>
                    while (unum > 0) {
    80000c4a:	4925                	li	s2,9
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000c4c:	028f05b3          	mul	a1,t5,s0
    80000c50:	41ff561b          	sraiw	a2,t5,0x1f
    80000c54:	83fa                	mv	t2,t5
    80000c56:	01f482bb          	addw	t0,s1,t6
                    while (unum > 0) {
    80000c5a:	0f85                	addi	t6,t6,1
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000c5c:	9589                	srai	a1,a1,0x22
    80000c5e:	9d91                	subw	a1,a1,a2
    80000c60:	0025961b          	slliw	a2,a1,0x2
    80000c64:	9e2d                	addw	a2,a2,a1
    80000c66:	0016161b          	slliw	a2,a2,0x1
    80000c6a:	40cf063b          	subw	a2,t5,a2
    80000c6e:	1602                	slli	a2,a2,0x20
    80000c70:	9201                	srli	a2,a2,0x20
    80000c72:	964e                	add	a2,a2,s3
    80000c74:	00064603          	lbu	a2,0(a2)
                        unum /= 10;
    80000c78:	8f2e                	mv	t5,a1
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000c7a:	fecf8fa3          	sb	a2,-1(t6)
                    while (unum > 0) {
    80000c7e:	fc7967e3          	bltu	s2,t2,80000c4c <sprintf+0x13a>
                if (negative) {
    80000c82:	000a0963          	beqz	s4,80000c94 <sprintf+0x182>
            buf[idx++] = *p;
    80000c86:	2505                	addiw	a0,a0,1
                    buf[idx++] = '-';
    80000c88:	02d00613          	li	a2,45
    80000c8c:	00c78023          	sb	a2,0(a5)
                while (temp_idx > 0) {
    80000c90:	00a807b3          	add	a5,a6,a0
    80000c94:	746a                	ld	s0,184(sp)
    80000c96:	74ca                	ld	s1,176(sp)
    80000c98:	792a                	ld	s2,168(sp)
    80000c9a:	798a                	ld	s3,160(sp)
    80000c9c:	6a6a                	ld	s4,152(sp)
    80000c9e:	bfa9                	j	80000bf8 <sprintf+0xe6>
    80000ca0:	00001617          	auipc	a2,0x1
    80000ca4:	36060613          	addi	a2,a2,864 # 80002000 <etext>
                    for (int i = 0; null_str[i]; i++) {
    80000ca8:	02800713          	li	a4,40
                        buf[idx++] = null_str[i];
    80000cac:	00e78023          	sb	a4,0(a5)
                    for (int i = 0; null_str[i]; i++) {
    80000cb0:	00164703          	lbu	a4,1(a2)
                        buf[idx++] = null_str[i];
    80000cb4:	2505                	addiw	a0,a0,1
                    for (int i = 0; null_str[i]; i++) {
    80000cb6:	0785                	addi	a5,a5,1
    80000cb8:	0605                	addi	a2,a2,1
    80000cba:	fb6d                	bnez	a4,80000cac <sprintf+0x19a>
                break;
    80000cbc:	00a807b3          	add	a5,a6,a0
    80000cc0:	b5e1                	j	80000b88 <sprintf+0x76>
    80000cc2:	ed52                	sd	s4,152(sp)
    80000cc4:	fd22                	sd	s0,184(sp)
    80000cc6:	f926                	sd	s1,176(sp)
    80000cc8:	f54a                	sd	s2,168(sp)
    80000cca:	f14e                	sd	s3,160(sp)
                int negative = 0;
    80000ccc:	4a01                	li	s4,0
    80000cce:	b795                	j	80000c32 <sprintf+0x120>

0000000080000cd0 <printf_color>:

// 带颜色的格式化输出
int 
printf_color(int color, const char *fmt, ...) 
{
    80000cd0:	7119                	addi	sp,sp,-128
    80000cd2:	fc26                	sd	s1,56(sp)
    80000cd4:	84aa                	mv	s1,a0
    // 设置前景色 - ANSI转义序列
    console_puts("\033[3");
    80000cd6:	00002517          	auipc	a0,0x2
    80000cda:	bd250513          	addi	a0,a0,-1070 # 800028a8 <etext+0x8a8>
{
    80000cde:	f4be                	sd	a5,104(sp)
    80000ce0:	e486                	sd	ra,72(sp)
    80000ce2:	e8b2                	sd	a2,80(sp)
    80000ce4:	ecb6                	sd	a3,88(sp)
    80000ce6:	f0ba                	sd	a4,96(sp)
    80000ce8:	f8c2                	sd	a6,112(sp)
    80000cea:	fcc6                	sd	a7,120(sp)
    80000cec:	e0a2                	sd	s0,64(sp)
    80000cee:	f84a                	sd	s2,48(sp)
    80000cf0:	842e                	mv	s0,a1
    console_puts("\033[3");
    80000cf2:	b68ff0ef          	jal	8000005a <console_puts>
    console_putc('0' + (color & 0x7));  // 转换为0-7
    80000cf6:	0074f513          	andi	a0,s1,7
    80000cfa:	03050513          	addi	a0,a0,48
    80000cfe:	b26ff0ef          	jal	80000024 <console_putc>
    console_puts("m");
    80000d02:	00002517          	auipc	a0,0x2
    80000d06:	bae50513          	addi	a0,a0,-1106 # 800028b0 <etext+0x8b0>
    80000d0a:	b50ff0ef          	jal	8000005a <console_puts>
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
    80000d0e:	00044503          	lbu	a0,0(s0)
    va_start(ap, fmt);
    80000d12:	089c                	addi	a5,sp,80
    80000d14:	e43e                	sd	a5,8(sp)
    for (const char *p = fmt; *p; p++) {
    80000d16:	10050163          	beqz	a0,80000e18 <printf_color+0x148>
    80000d1a:	f44e                	sd	s3,40(sp)
    80000d1c:	f052                	sd	s4,32(sp)
    80000d1e:	ec56                	sd	s5,24(sp)
    int count = 0;
    80000d20:	4901                	li	s2,0
        if (*p != '%') {
    80000d22:	02500993          	li	s3,37
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
    80000d26:	4ad5                	li	s5,21
    80000d28:	00002a17          	auipc	s4,0x2
    80000d2c:	530a0a13          	addi	s4,s4,1328 # 80003258 <etext+0x1258>
            count++;
    80000d30:	2905                	addiw	s2,s2,1
        if (*p != '%') {
    80000d32:	0d351463          	bne	a0,s3,80000dfa <printf_color+0x12a>
        switch (*p) {
    80000d36:	00144783          	lbu	a5,1(s0)
        p++;
    80000d3a:	00140493          	addi	s1,s0,1
        switch (*p) {
    80000d3e:	0d378263          	beq	a5,s3,80000e02 <printf_color+0x132>
    80000d42:	f9d7879b          	addiw	a5,a5,-99
    80000d46:	0ff7f793          	zext.b	a5,a5
    80000d4a:	00fae763          	bltu	s5,a5,80000d58 <printf_color+0x88>
    80000d4e:	078a                	slli	a5,a5,0x2
    80000d50:	97d2                	add	a5,a5,s4
    80000d52:	439c                	lw	a5,0(a5)
    80000d54:	97d2                	add	a5,a5,s4
    80000d56:	8782                	jr	a5
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
    80000d58:	02500513          	li	a0,37
    80000d5c:	ac8ff0ef          	jal	80000024 <console_putc>
                console_putc(*p);
    80000d60:	00144503          	lbu	a0,1(s0)
    80000d64:	ac0ff0ef          	jal	80000024 <console_putc>
    for (const char *p = fmt; *p; p++) {
    80000d68:	0014c503          	lbu	a0,1(s1)
    80000d6c:	00148413          	addi	s0,s1,1
    80000d70:	f161                	bnez	a0,80000d30 <printf_color+0x60>
    80000d72:	79a2                	ld	s3,40(sp)
    80000d74:	7a02                	ld	s4,32(sp)
    80000d76:	6ae2                	ld	s5,24(sp)
    }
    
    va_end(ap);
    
    // 重置颜色
    console_puts("\033[0m");
    80000d78:	00002517          	auipc	a0,0x2
    80000d7c:	b4050513          	addi	a0,a0,-1216 # 800028b8 <etext+0x8b8>
    80000d80:	adaff0ef          	jal	8000005a <console_puts>
    
    return count;
}
    80000d84:	60a6                	ld	ra,72(sp)
    80000d86:	6406                	ld	s0,64(sp)
    80000d88:	74e2                	ld	s1,56(sp)
    80000d8a:	854a                	mv	a0,s2
    80000d8c:	7942                	ld	s2,48(sp)
    80000d8e:	6109                	addi	sp,sp,128
    80000d90:	8082                	ret
                print_number(va_arg(ap, unsigned int), 16, 0);
    80000d92:	67a2                	ld	a5,8(sp)
    80000d94:	4601                	li	a2,0
    80000d96:	45c1                	li	a1,16
    80000d98:	0007e503          	lwu	a0,0(a5)
    80000d9c:	07a1                	addi	a5,a5,8
    80000d9e:	e43e                	sd	a5,8(sp)
    80000da0:	b5dff0ef          	jal	800008fc <print_number>
                break;
    80000da4:	b7d1                	j	80000d68 <printf_color+0x98>
                print_number(va_arg(ap, unsigned int), 10, 0);
    80000da6:	67a2                	ld	a5,8(sp)
    80000da8:	4601                	li	a2,0
    80000daa:	45a9                	li	a1,10
    80000dac:	0007e503          	lwu	a0,0(a5)
    80000db0:	07a1                	addi	a5,a5,8
    80000db2:	e43e                	sd	a5,8(sp)
    80000db4:	b49ff0ef          	jal	800008fc <print_number>
                break;
    80000db8:	bf45                	j	80000d68 <printf_color+0x98>
                    const char *s = va_arg(ap, const char *);
    80000dba:	67a2                	ld	a5,8(sp)
    80000dbc:	6388                	ld	a0,0(a5)
    80000dbe:	07a1                	addi	a5,a5,8
    80000dc0:	e43e                	sd	a5,8(sp)
                    if (s == 0) {
    80000dc2:	c521                	beqz	a0,80000e0a <printf_color+0x13a>
                        console_puts(s);
    80000dc4:	a96ff0ef          	jal	8000005a <console_puts>
    80000dc8:	b745                	j	80000d68 <printf_color+0x98>
                print_ptr(va_arg(ap, uint64));
    80000dca:	67a2                	ld	a5,8(sp)
    80000dcc:	6388                	ld	a0,0(a5)
    80000dce:	07a1                	addi	a5,a5,8
    80000dd0:	e43e                	sd	a5,8(sp)
    80000dd2:	bb9ff0ef          	jal	8000098a <print_ptr>
                break;
    80000dd6:	bf49                	j	80000d68 <printf_color+0x98>
                print_number(va_arg(ap, int), 10, 1);
    80000dd8:	67a2                	ld	a5,8(sp)
    80000dda:	4605                	li	a2,1
    80000ddc:	45a9                	li	a1,10
    80000dde:	4388                	lw	a0,0(a5)
    80000de0:	07a1                	addi	a5,a5,8
    80000de2:	e43e                	sd	a5,8(sp)
    80000de4:	b19ff0ef          	jal	800008fc <print_number>
                break;
    80000de8:	b741                	j	80000d68 <printf_color+0x98>
                console_putc(va_arg(ap, int));
    80000dea:	67a2                	ld	a5,8(sp)
    80000dec:	0007c503          	lbu	a0,0(a5)
    80000df0:	07a1                	addi	a5,a5,8
    80000df2:	e43e                	sd	a5,8(sp)
    80000df4:	a30ff0ef          	jal	80000024 <console_putc>
                break;
    80000df8:	bf85                	j	80000d68 <printf_color+0x98>
            console_putc(*p);
    80000dfa:	a2aff0ef          	jal	80000024 <console_putc>
            continue;
    80000dfe:	84a2                	mv	s1,s0
    80000e00:	b7a5                	j	80000d68 <printf_color+0x98>
                console_putc('%');
    80000e02:	854e                	mv	a0,s3
    80000e04:	a20ff0ef          	jal	80000024 <console_putc>
                break;
    80000e08:	b785                	j	80000d68 <printf_color+0x98>
                        console_puts("(null)");
    80000e0a:	00002517          	auipc	a0,0x2
    80000e0e:	a9650513          	addi	a0,a0,-1386 # 800028a0 <etext+0x8a0>
    80000e12:	a48ff0ef          	jal	8000005a <console_puts>
    80000e16:	bf89                	j	80000d68 <printf_color+0x98>
    int count = 0;
    80000e18:	4901                	li	s2,0
    80000e1a:	bfb9                	j	80000d78 <printf_color+0xa8>

0000000080000e1c <printf_init>:
// 初始化printf系统
void 
printf_init(void) 
{
    // 初始化控制台
    console_init();
    80000e1c:	a04ff06f          	j	80000020 <console_init>

0000000080000e20 <timerinit>:
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000e20:	304027f3          	csrr	a5,mie

// 初始化时钟
void timerinit(void)
{
  // 使能machine-mode的timer中断
  w_mie(r_mie() | MIE_STIE);
    80000e24:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80000e28:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000e2c:	30a027f3          	csrr	a5,0x30a
  
  // 使能sstc扩展 (stimecmp)
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000e30:	577d                	li	a4,-1
    80000e32:	177e                	slli	a4,a4,0x3f
    80000e34:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000e36:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80000e3a:	306027f3          	csrr	a5,mcounteren
  
  // 允许supervisor访问stimecmp和time
  w_mcounteren(r_mcounteren() | 2);
    80000e3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000e42:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80000e46:	c01027f3          	rdtime	a5
  
  // 请求第一次定时器中断（约0.1秒后）
  w_stimecmp(r_time() + 1000000);
    80000e4a:	000f4737          	lui	a4,0xf4
    80000e4e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000e52:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000e54:	14d79073          	csrw	stimecmp,a5
}
    80000e58:	8082                	ret

0000000080000e5a <start>:
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000e5a:	300027f3          	csrr	a5,mstatus
// 机器模式启动初始化
void start(void)
{
  // 设置M Previous Privilege mode为Supervisor，用于mret
  uint64 x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
    80000e5e:	76f9                	lui	a3,0xffffe
    80000e60:	7ff68693          	addi	a3,a3,2047 # ffffffffffffe7ff <end+0xffffffff7fff07ff>
  x |= MSTATUS_MPP_S;
    80000e64:	6705                	lui	a4,0x1
  x &= ~MSTATUS_MPP_MASK;
    80000e66:	8ff5                	and	a5,a5,a3
  x |= MSTATUS_MPP_S;
    80000e68:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000e6c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000e6e:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000e72:	00000797          	auipc	a5,0x0
    80000e76:	85c78793          	addi	a5,a5,-1956 # 800006ce <main>
    80000e7a:	34179073          	csrw	mepc,a5
}

static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    80000e7e:	4781                	li	a5,0
    80000e80:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000e84:	67c1                	lui	a5,0x10
    80000e86:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000e88:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80000e8c:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000e90:	104027f3          	csrr	a5,sie
  // 将所有中断和异常委托给supervisor mode
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  
  // 使能supervisor的外部中断和定时器中断
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000e94:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    80000e98:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80000e9c:	57fd                	li	a5,-1
    80000e9e:	00a7d713          	srli	a4,a5,0xa
    80000ea2:	3b071073          	csrw	pmpaddr0,a4
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80000ea6:	473d                	li	a4,15
    80000ea8:	3a071073          	csrw	pmpcfg0,a4
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000eac:	30402773          	csrr	a4,mie
  w_mie(r_mie() | MIE_STIE);
    80000eb0:	02076713          	ori	a4,a4,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80000eb4:	30471073          	csrw	mie,a4
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000eb8:	30a02773          	csrr	a4,0x30a
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000ebc:	17fe                	slli	a5,a5,0x3f
    80000ebe:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000ec0:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80000ec4:	306027f3          	csrr	a5,mcounteren
  w_mcounteren(r_mcounteren() | 2);
    80000ec8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000ecc:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80000ed0:	c01027f3          	rdtime	a5
  w_stimecmp(r_time() + 1000000);
    80000ed4:	000f4737          	lui	a4,0xf4
    80000ed8:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000edc:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000ede:	14d79073          	csrw	stimecmp,a5
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000ee2:	f14027f3          	csrr	a5,mhartid
  // 初始化时钟中断
  timerinit();

  // 保存hart id到tp寄存器
  int id = r_mhartid();
  w_tp(id);
    80000ee6:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80000ee8:	823e                	mv	tp,a5

  // 切换到supervisor mode并跳转到main
  asm volatile("mret");
    80000eea:	30200073          	mret
}
    80000eee:	8082                	ret

0000000080000ef0 <trapinit>:

// 初始化trap系统
void trapinit(void)
{
    80000ef0:	1141                	addi	sp,sp,-16
  printf("初始化中断系统...\n");
    80000ef2:	00002517          	auipc	a0,0x2
    80000ef6:	9ee50513          	addi	a0,a0,-1554 # 800028e0 <etext+0x8e0>
{
    80000efa:	e406                	sd	ra,8(sp)
  printf("初始化中断系统...\n");
    80000efc:	af1ff0ef          	jal	800009ec <printf>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80000f00:	00001797          	auipc	a5,0x1
    80000f04:	a7078793          	addi	a5,a5,-1424 # 80001970 <kernelvec>
    80000f08:	10579073          	csrw	stvec,a5
  asm volatile("csrr %0, stvec" : "=r" (x) );
    80000f0c:	105025f3          	csrr	a1,stvec
  
  // 设置supervisor trap vector
  extern void kernelvec();
  w_stvec((uint64)kernelvec);
  
  printf("✓ 中断向量表设置完成: 0x%p\n", (void*)r_stvec());
    80000f10:	00002517          	auipc	a0,0x2
    80000f14:	9f050513          	addi	a0,a0,-1552 # 80002900 <etext+0x900>
    80000f18:	ad5ff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000f1c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000f20:	8b89                	andi	a5,a5,2
  printf("✓ 当前中断状态: %s\n", intr_get() ? "已使能" : "已禁用");
    80000f22:	00002597          	auipc	a1,0x2
    80000f26:	99e58593          	addi	a1,a1,-1634 # 800028c0 <etext+0x8c0>
    80000f2a:	e789                	bnez	a5,80000f34 <trapinit+0x44>
    80000f2c:	00002597          	auipc	a1,0x2
    80000f30:	9a458593          	addi	a1,a1,-1628 # 800028d0 <etext+0x8d0>
}
    80000f34:	60a2                	ld	ra,8(sp)
  printf("✓ 当前中断状态: %s\n", intr_get() ? "已使能" : "已禁用");
    80000f36:	00002517          	auipc	a0,0x2
    80000f3a:	9f250513          	addi	a0,a0,-1550 # 80002928 <etext+0x928>
}
    80000f3e:	0141                	addi	sp,sp,16
  printf("✓ 当前中断状态: %s\n", intr_get() ? "已使能" : "已禁用");
    80000f40:	b475                	j	800009ec <printf>

0000000080000f42 <clockintr>:

// 处理时钟中断
void clockintr(void)
{
  ticks++;
    80000f42:	0000c797          	auipc	a5,0xc
    80000f46:	0c67b783          	ld	a5,198(a5) # 8000d008 <ticks>
    80000f4a:	0785                	addi	a5,a5,1
    80000f4c:	0000c717          	auipc	a4,0xc
    80000f50:	0af73e23          	sd	a5,188(a4) # 8000d008 <ticks>
  interrupt_count++;
    80000f54:	0000c797          	auipc	a5,0xc
    80000f58:	0ac7a783          	lw	a5,172(a5) # 8000d000 <interrupt_count>
    80000f5c:	2785                	addiw	a5,a5,1
    80000f5e:	0000c717          	auipc	a4,0xc
    80000f62:	0af72123          	sw	a5,162(a4) # 8000d000 <interrupt_count>
  asm volatile("csrr %0, time" : "=r" (x) );
    80000f66:	c01027f3          	rdtime	a5
  
  // 请求下一次定时器中断
  w_stimecmp(r_time() + 1000000);
    80000f6a:	000f4737          	lui	a4,0xf4
    80000f6e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000f72:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000f74:	14d79073          	csrw	stimecmp,a5
}
    80000f78:	8082                	ret

0000000080000f7a <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80000f7a:	14202773          	csrr	a4,scause
int devintr(void)
{
  uint64 scause = r_scause();
  
  // 检查是否是supervisor timer interrupt
  if (scause == 0x8000000000000005L) {
    80000f7e:	57fd                	li	a5,-1
    clockintr();
    return 2;
  }
  
  // 检查是否是supervisor external interrupt
  if (scause == 0x8000000000000009L) {
    80000f80:	553d                	li	a0,-17
    80000f82:	8105                	srli	a0,a0,0x1
  if (scause == 0x8000000000000005L) {
    80000f84:	17fe                	slli	a5,a5,0x3f
  if (scause == 0x8000000000000009L) {
    80000f86:	953a                	add	a0,a0,a4
  if (scause == 0x8000000000000005L) {
    80000f88:	0795                	addi	a5,a5,5
  if (scause == 0x8000000000000009L) {
    80000f8a:	00153513          	seqz	a0,a0
  if (scause == 0x8000000000000005L) {
    80000f8e:	00f70363          	beq	a4,a5,80000f94 <devintr+0x1a>
    // UART或其他外部中断
    return 1;
  }
  
  return 0;
}
    80000f92:	8082                	ret
  ticks++;
    80000f94:	0000c797          	auipc	a5,0xc
    80000f98:	0747b783          	ld	a5,116(a5) # 8000d008 <ticks>
    80000f9c:	0785                	addi	a5,a5,1
    80000f9e:	0000c717          	auipc	a4,0xc
    80000fa2:	06f73523          	sd	a5,106(a4) # 8000d008 <ticks>
  interrupt_count++;
    80000fa6:	0000c797          	auipc	a5,0xc
    80000faa:	05a7a783          	lw	a5,90(a5) # 8000d000 <interrupt_count>
    80000fae:	2785                	addiw	a5,a5,1
    80000fb0:	0000c717          	auipc	a4,0xc
    80000fb4:	04f72823          	sw	a5,80(a4) # 8000d000 <interrupt_count>
  asm volatile("csrr %0, time" : "=r" (x) );
    80000fb8:	c01027f3          	rdtime	a5
  w_stimecmp(r_time() + 1000000);
    80000fbc:	000f4737          	lui	a4,0xf4
    80000fc0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000fc4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000fc6:	14d79073          	csrw	stimecmp,a5
    return 2;
    80000fca:	4509                	li	a0,2
}
    80000fcc:	8082                	ret

0000000080000fce <panic>:
  panic("Unhandled exception");
}

// panic函数 - 系统致命错误
void panic(const char *s)
{
    80000fce:	1141                	addi	sp,sp,-16
    80000fd0:	e022                	sd	s0,0(sp)
    80000fd2:	842a                	mv	s0,a0
  printf("\n!!! PANIC !!!\n");
    80000fd4:	00002517          	auipc	a0,0x2
    80000fd8:	97450513          	addi	a0,a0,-1676 # 80002948 <etext+0x948>
{
    80000fdc:	e406                	sd	ra,8(sp)
  printf("\n!!! PANIC !!!\n");
    80000fde:	a0fff0ef          	jal	800009ec <printf>
  printf("%s\n", s);
    80000fe2:	85a2                	mv	a1,s0
    80000fe4:	00002517          	auipc	a0,0x2
    80000fe8:	95c50513          	addi	a0,a0,-1700 # 80002940 <etext+0x940>
    80000fec:	a01ff0ef          	jal	800009ec <printf>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000ff0:	8592                	mv	a1,tp
  printf("Hart %d\n", (int)r_tp());
    80000ff2:	00002517          	auipc	a0,0x2
    80000ff6:	96650513          	addi	a0,a0,-1690 # 80002958 <etext+0x958>
    80000ffa:	2581                	sext.w	a1,a1
    80000ffc:	9f1ff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001000:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001004:	14302673          	csrr	a2,stval
  printf("sepc=0x%p stval=0x%p\n", (void*)r_sepc(), (void*)r_stval());
    80001008:	00002517          	auipc	a0,0x2
    8000100c:	96050513          	addi	a0,a0,-1696 # 80002968 <etext+0x968>
    80001010:	9ddff0ef          	jal	800009ec <printf>
  printf("系统已停止。\n");
    80001014:	00002517          	auipc	a0,0x2
    80001018:	96c50513          	addi	a0,a0,-1684 # 80002980 <etext+0x980>
    8000101c:	9d1ff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001020:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001024:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001026:	10079073          	csrw	sstatus,a5
  
  // 禁用中断并进入无限循环
  intr_off();
  for(;;)
    8000102a:	a001                	j	8000102a <panic+0x5c>

000000008000102c <kerneltrap>:
{
    8000102c:	1101                	addi	sp,sp,-32
    8000102e:	ec06                	sd	ra,24(sp)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001030:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001034:	10002773          	csrr	a4,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001038:	142025f3          	csrr	a1,scause
  if ((sstatus & SSTATUS_SPP) == 0) {
    8000103c:	10077793          	andi	a5,a4,256
    80001040:	c7dd                	beqz	a5,800010ee <kerneltrap+0xc2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001042:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001046:	8b89                	andi	a5,a5,2
  if (intr_get() != 0) {
    80001048:	ebcd                	bnez	a5,800010fa <kerneltrap+0xce>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000104a:	142026f3          	csrr	a3,scause
  if (scause == 0x8000000000000005L) {
    8000104e:	57fd                	li	a5,-1
    80001050:	17fe                	slli	a5,a5,0x3f
    80001052:	0795                	addi	a5,a5,5
    80001054:	04f68b63          	beq	a3,a5,800010aa <kerneltrap+0x7e>
  if (scause == 0x8000000000000009L) {
    80001058:	57fd                	li	a5,-1
    8000105a:	17fe                	slli	a5,a5,0x3f
    8000105c:	07a5                	addi	a5,a5,9
    8000105e:	08f68163          	beq	a3,a5,800010e0 <kerneltrap+0xb4>
    printf("\n!!! 未知的中断/异常 !!!\n");
    80001062:	00002517          	auipc	a0,0x2
    80001066:	97e50513          	addi	a0,a0,-1666 # 800029e0 <etext+0x9e0>
    8000106a:	e032                	sd	a2,0(sp)
    8000106c:	e42e                	sd	a1,8(sp)
    8000106e:	97fff0ef          	jal	800009ec <printf>
    printf("scause=0x%p\n", (void*)scause);
    80001072:	65a2                	ld	a1,8(sp)
    80001074:	00002517          	auipc	a0,0x2
    80001078:	99450513          	addi	a0,a0,-1644 # 80002a08 <etext+0xa08>
    8000107c:	971ff0ef          	jal	800009ec <printf>
    printf("sepc=0x%p\n", (void*)sepc);
    80001080:	6582                	ld	a1,0(sp)
    80001082:	00002517          	auipc	a0,0x2
    80001086:	99650513          	addi	a0,a0,-1642 # 80002a18 <etext+0xa18>
    8000108a:	963ff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000108e:	143025f3          	csrr	a1,stval
    printf("stval=0x%p\n", (void*)r_stval());
    80001092:	00002517          	auipc	a0,0x2
    80001096:	99650513          	addi	a0,a0,-1642 # 80002a28 <etext+0xa28>
    8000109a:	953ff0ef          	jal	800009ec <printf>
    panic("kerneltrap");
    8000109e:	00002517          	auipc	a0,0x2
    800010a2:	99a50513          	addi	a0,a0,-1638 # 80002a38 <etext+0xa38>
    800010a6:	f29ff0ef          	jal	80000fce <panic>
  ticks++;
    800010aa:	0000c797          	auipc	a5,0xc
    800010ae:	f5e7b783          	ld	a5,-162(a5) # 8000d008 <ticks>
    800010b2:	0785                	addi	a5,a5,1
    800010b4:	0000c697          	auipc	a3,0xc
    800010b8:	f4f6ba23          	sd	a5,-172(a3) # 8000d008 <ticks>
  interrupt_count++;
    800010bc:	0000c797          	auipc	a5,0xc
    800010c0:	f447a783          	lw	a5,-188(a5) # 8000d000 <interrupt_count>
    800010c4:	2785                	addiw	a5,a5,1
    800010c6:	0000c697          	auipc	a3,0xc
    800010ca:	f2f6ad23          	sw	a5,-198(a3) # 8000d000 <interrupt_count>
  asm volatile("csrr %0, time" : "=r" (x) );
    800010ce:	c01027f3          	rdtime	a5
  w_stimecmp(r_time() + 1000000);
    800010d2:	000f46b7          	lui	a3,0xf4
    800010d6:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    800010da:	97b6                	add	a5,a5,a3
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800010dc:	14d79073          	csrw	stimecmp,a5
  asm volatile("csrw sepc, %0" : : "r" (x));
    800010e0:	14161073          	csrw	sepc,a2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800010e4:	10071073          	csrw	sstatus,a4
}
    800010e8:	60e2                	ld	ra,24(sp)
    800010ea:	6105                	addi	sp,sp,32
    800010ec:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800010ee:	00002517          	auipc	a0,0x2
    800010f2:	8aa50513          	addi	a0,a0,-1878 # 80002998 <etext+0x998>
    800010f6:	ed9ff0ef          	jal	80000fce <panic>
    panic("kerneltrap: interrupts enabled");
    800010fa:	00002517          	auipc	a0,0x2
    800010fe:	8c650513          	addi	a0,a0,-1850 # 800029c0 <etext+0x9c0>
    80001102:	ecdff0ef          	jal	80000fce <panic>

0000000080001106 <handle_exception>:
{
    80001106:	7179                	addi	sp,sp,-48
    80001108:	f022                	sd	s0,32(sp)
    8000110a:	e84a                	sd	s2,16(sp)
  uint64 exception_code = scause & 0x7FFFFFFFFFFFFFFF;
    8000110c:	00151413          	slli	s0,a0,0x1
{
    80001110:	892a                	mv	s2,a0
  printf("\n=== 异常发生 ===\n");
    80001112:	00002517          	auipc	a0,0x2
    80001116:	93650513          	addi	a0,a0,-1738 # 80002a48 <etext+0xa48>
{
    8000111a:	ec26                	sd	s1,24(sp)
    8000111c:	e44e                	sd	s3,8(sp)
    8000111e:	f406                	sd	ra,40(sp)
    80001120:	84ae                	mv	s1,a1
    80001122:	89b2                	mv	s3,a2
  printf("\n=== 异常发生 ===\n");
    80001124:	8c9ff0ef          	jal	800009ec <printf>
  if (exception_code < 16) {
    80001128:	00191793          	slli	a5,s2,0x1
    8000112c:	8395                	srli	a5,a5,0x5
  uint64 exception_code = scause & 0x7FFFFFFFFFFFFFFF;
    8000112e:	8005                	srli	s0,s0,0x1
  if (exception_code < 16) {
    80001130:	e7bd                	bnez	a5,8000119e <handle_exception+0x98>
    printf("异常类型: %s\n", exception_names[exception_code]);
    80001132:	00003797          	auipc	a5,0x3
    80001136:	ece78793          	addi	a5,a5,-306 # 80004000 <exception_names>
    8000113a:	00341713          	slli	a4,s0,0x3
    8000113e:	97ba                	add	a5,a5,a4
    80001140:	638c                	ld	a1,0(a5)
    80001142:	00002517          	auipc	a0,0x2
    80001146:	91e50513          	addi	a0,a0,-1762 # 80002a60 <etext+0xa60>
    8000114a:	8a3ff0ef          	jal	800009ec <printf>
  printf("异常地址 (sepc): 0x%p\n", (void*)sepc);
    8000114e:	85a6                	mv	a1,s1
    80001150:	00002517          	auipc	a0,0x2
    80001154:	95050513          	addi	a0,a0,-1712 # 80002aa0 <etext+0xaa0>
    80001158:	895ff0ef          	jal	800009ec <printf>
  printf("异常值 (stval): 0x%p\n", (void*)stval);
    8000115c:	85ce                	mv	a1,s3
    8000115e:	00002517          	auipc	a0,0x2
    80001162:	96250513          	addi	a0,a0,-1694 # 80002ac0 <etext+0xac0>
    80001166:	887ff0ef          	jal	800009ec <printf>
  printf("scause: 0x%p\n", (void*)scause);
    8000116a:	85ca                	mv	a1,s2
    8000116c:	00002517          	auipc	a0,0x2
    80001170:	97450513          	addi	a0,a0,-1676 # 80002ae0 <etext+0xae0>
    80001174:	879ff0ef          	jal	800009ec <printf>
  if (exception_code == 2) {
    80001178:	4789                	li	a5,2
    8000117a:	02f41b63          	bne	s0,a5,800011b0 <handle_exception+0xaa>
    printf("跳过非法指令...\n");
    8000117e:	00002517          	auipc	a0,0x2
    80001182:	97250513          	addi	a0,a0,-1678 # 80002af0 <etext+0xaf0>
    80001186:	867ff0ef          	jal	800009ec <printf>
    w_sepc(sepc + 4);
    8000118a:	0491                	addi	s1,s1,4
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000118c:	14149073          	csrw	sepc,s1
}
    80001190:	70a2                	ld	ra,40(sp)
    80001192:	7402                	ld	s0,32(sp)
    80001194:	64e2                	ld	s1,24(sp)
    80001196:	6942                	ld	s2,16(sp)
    80001198:	69a2                	ld	s3,8(sp)
    8000119a:	6145                	addi	sp,sp,48
    8000119c:	8082                	ret
    printf("异常类型: Unknown (code=%d)\n", (int)exception_code);
    8000119e:	0004059b          	sext.w	a1,s0
    800011a2:	00002517          	auipc	a0,0x2
    800011a6:	8d650513          	addi	a0,a0,-1834 # 80002a78 <etext+0xa78>
    800011aa:	843ff0ef          	jal	800009ec <printf>
    800011ae:	b745                	j	8000114e <handle_exception+0x48>
  panic("Unhandled exception");
    800011b0:	00002517          	auipc	a0,0x2
    800011b4:	95850513          	addi	a0,a0,-1704 # 80002b08 <etext+0xb08>
    800011b8:	e17ff0ef          	jal	80000fce <panic>

00000000800011bc <get_time>:
  asm volatile("csrr %0, time" : "=r" (x) );
    800011bc:	c0102573          	rdtime	a0

// 获取当前时间（以ticks为单位）
uint64 get_time(void)
{
  return r_time();
}
    800011c0:	8082                	ret

00000000800011c2 <get_ticks>:

// 获取ticks计数
uint64 get_ticks(void)
{
  return ticks;
}
    800011c2:	0000c517          	auipc	a0,0xc
    800011c6:	e4653503          	ld	a0,-442(a0) # 8000d008 <ticks>
    800011ca:	8082                	ret

00000000800011cc <get_interrupt_count>:

// 获取中断计数
int get_interrupt_count(void)
{
  return interrupt_count;
}
    800011cc:	0000c517          	auipc	a0,0xc
    800011d0:	e3452503          	lw	a0,-460(a0) # 8000d000 <interrupt_count>
    800011d4:	8082                	ret

00000000800011d6 <show_interrupt_stats>:

// 显示中断统计信息
void show_interrupt_stats(void)
{
    800011d6:	1141                	addi	sp,sp,-16
  printf("\n=== 中断统计信息 ===\n");
    800011d8:	00002517          	auipc	a0,0x2
    800011dc:	94850513          	addi	a0,a0,-1720 # 80002b20 <etext+0xb20>
{
    800011e0:	e406                	sd	ra,8(sp)
  printf("\n=== 中断统计信息 ===\n");
    800011e2:	80bff0ef          	jal	800009ec <printf>
  printf("时间计数(ticks): %d\n", (int)ticks);
    800011e6:	0000c597          	auipc	a1,0xc
    800011ea:	e225b583          	ld	a1,-478(a1) # 8000d008 <ticks>
    800011ee:	00002517          	auipc	a0,0x2
    800011f2:	95250513          	addi	a0,a0,-1710 # 80002b40 <etext+0xb40>
    800011f6:	2581                	sext.w	a1,a1
    800011f8:	ff4ff0ef          	jal	800009ec <printf>
  printf("中断总数: %d\n", interrupt_count);
    800011fc:	0000c597          	auipc	a1,0xc
    80001200:	e045a583          	lw	a1,-508(a1) # 8000d000 <interrupt_count>
    80001204:	00002517          	auipc	a0,0x2
    80001208:	95c50513          	addi	a0,a0,-1700 # 80002b60 <etext+0xb60>
    8000120c:	fe0ff0ef          	jal	800009ec <printf>
    80001210:	c01025f3          	rdtime	a1
  printf("当前时间: %d cycles\n", (int)r_time());
    80001214:	00002517          	auipc	a0,0x2
    80001218:	96450513          	addi	a0,a0,-1692 # 80002b78 <etext+0xb78>
    8000121c:	2581                	sext.w	a1,a1
    8000121e:	fceff0ef          	jal	800009ec <printf>
  printf("当前状态寄存器:\n");
    80001222:	00002517          	auipc	a0,0x2
    80001226:	97650513          	addi	a0,a0,-1674 # 80002b98 <etext+0xb98>
    8000122a:	fc2ff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000122e:	100025f3          	csrr	a1,sstatus
    80001232:	10002673          	csrr	a2,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001236:	8205                	srli	a2,a2,0x1
  printf("  sstatus: 0x%p [SIE=%d]\n", 
    80001238:	8a05                	andi	a2,a2,1
    8000123a:	00002517          	auipc	a0,0x2
    8000123e:	97650513          	addi	a0,a0,-1674 # 80002bb0 <etext+0xbb0>
    80001242:	faaff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001246:	104025f3          	csrr	a1,sie
         (void*)r_sstatus(), intr_get());
  printf("  sie: 0x%p\n", (void*)r_sie());
    8000124a:	00002517          	auipc	a0,0x2
    8000124e:	98650513          	addi	a0,a0,-1658 # 80002bd0 <etext+0xbd0>
    80001252:	f9aff0ef          	jal	800009ec <printf>
  asm volatile("csrr %0, stvec" : "=r" (x) );
    80001256:	105025f3          	csrr	a1,stvec
  printf("  stvec: 0x%p\n", (void*)r_stvec());
}
    8000125a:	60a2                	ld	ra,8(sp)
  printf("  stvec: 0x%p\n", (void*)r_stvec());
    8000125c:	00002517          	auipc	a0,0x2
    80001260:	98450513          	addi	a0,a0,-1660 # 80002be0 <etext+0xbe0>
}
    80001264:	0141                	addi	sp,sp,16
  printf("  stvec: 0x%p\n", (void*)r_stvec());
    80001266:	f86ff06f          	j	800009ec <printf>

000000008000126a <uart_init>:
// 向寄存器写入值
static inline void 
uart_write_reg(int reg, uint8 v)
{
    volatile uint8 *p = (uint8*)UART0;
    p[reg] = v;
    8000126a:	100007b7          	lui	a5,0x10000
    8000126e:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80001272:	10000737          	lui	a4,0x10000
    80001276:	468d                	li	a3,3
    80001278:	87ba                	mv	a5,a4
    8000127a:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    8000127e:	4705                	li	a4,1
    80001280:	00e78123          	sb	a4,2(a5)
    // 设置8位数据位，1位停止位，无奇偶校验(8N1)
    uart_write_reg(LCR, 0x03);
    
    // 启用FIFO
    uart_write_reg(FCR, 0x01);
}
    80001284:	8082                	ret

0000000080001286 <uart_putc>:
    return p[reg];
    80001286:	10000737          	lui	a4,0x10000
    8000128a:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000128c:	100006b7          	lui	a3,0x10000
    80001290:	00074783          	lbu	a5,0(a4)
// 发送单个字符
void 
uart_putc(char c)
{
    // 等待发送缓冲区空闲
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
    80001294:	0207f793          	andi	a5,a5,32
    80001298:	dfe5                	beqz	a5,80001290 <uart_putc+0xa>
    p[reg] = v;
    8000129a:	00a68023          	sb	a0,0(a3) # 10000000 <_entry-0x70000000>
        ;
    
    // 发送字符
    uart_write_reg(THR, c);
}
    8000129e:	8082                	ret

00000000800012a0 <uart_puts>:

// 发送字符串
void 
uart_puts(const char *s)
{
    while(*s != '\0') {
    800012a0:	00054683          	lbu	a3,0(a0)
    800012a4:	c28d                	beqz	a3,800012c6 <uart_puts+0x26>
    return p[reg];
    800012a6:	10000737          	lui	a4,0x10000
    800012aa:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800012ac:	10000637          	lui	a2,0x10000
        uart_putc(*s++);
    800012b0:	0505                	addi	a0,a0,1
    return p[reg];
    800012b2:	00074783          	lbu	a5,0(a4)
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
    800012b6:	0207f793          	andi	a5,a5,32
    800012ba:	dfe5                	beqz	a5,800012b2 <uart_puts+0x12>
    p[reg] = v;
    800012bc:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>
    while(*s != '\0') {
    800012c0:	00054683          	lbu	a3,0(a0)
    800012c4:	f6f5                	bnez	a3,800012b0 <uart_puts+0x10>
    }
    800012c6:	8082                	ret

00000000800012c8 <walk_lookup.part.0>:
    }
    
    // 从根页表开始，逐级向下查找
    for (int level = 2; level > 0; level--) {
        // 计算当前级别的页表索引
        int index = PX(level, va);
    800012c8:	01e5d793          	srli	a5,a1,0x1e
        pte_t *pte = &pt[index];
        
        // 检查页表项是否有效
        if ((*pte & PTE_V) == 0) {
    800012cc:	078e                	slli	a5,a5,0x3
    800012ce:	953e                	add	a0,a0,a5
    800012d0:	6118                	ld	a4,0(a0)
            return 0;  // 页表项无效，路径不存在
        }
        
        // 检查是否为中间级页表项（R/W/X都为0）
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    800012d2:	4785                	li	a5,1
        if ((*pte & PTE_V) == 0) {
    800012d4:	00f77693          	andi	a3,a4,15
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    800012d8:	02f69763          	bne	a3,a5,80001306 <walk_lookup.part.0+0x3e>
        int index = PX(level, va);
    800012dc:	0155d793          	srli	a5,a1,0x15
            return 0;  // 这是叶子页面，不应该在中间级出现
        }
        
        // 获取下一级页表的物理地址
        pt = (pagetable_t)PTE2PA(*pte);
    800012e0:	8329                	srli	a4,a4,0xa
        pte_t *pte = &pt[index];
    800012e2:	1ff7f793          	andi	a5,a5,511
        pt = (pagetable_t)PTE2PA(*pte);
    800012e6:	0732                	slli	a4,a4,0xc
        if ((*pte & PTE_V) == 0) {
    800012e8:	078e                	slli	a5,a5,0x3
    800012ea:	97ba                	add	a5,a5,a4
    800012ec:	6388                	ld	a0,0(a5)
    800012ee:	00f57793          	andi	a5,a0,15
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    800012f2:	00d79a63          	bne	a5,a3,80001306 <walk_lookup.part.0+0x3e>
    }
    
    // 返回叶子级页表项的地址
    return &pt[PX(0, va)];
    800012f6:	81b1                	srli	a1,a1,0xc
    800012f8:	1ff5f593          	andi	a1,a1,511
        pt = (pagetable_t)PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
    return &pt[PX(0, va)];
    800012fe:	058e                	slli	a1,a1,0x3
        pt = (pagetable_t)PTE2PA(*pte);
    80001300:	0532                	slli	a0,a0,0xc
    return &pt[PX(0, va)];
    80001302:	952e                	add	a0,a0,a1
    80001304:	8082                	ret
        return 0;  // 地址超出范围
    80001306:	4501                	li	a0,0
}
    80001308:	8082                	ret

000000008000130a <destroy_pagetable.part.0>:
void destroy_pagetable(pagetable_t pt) {
    8000130a:	7179                	addi	sp,sp,-48
    8000130c:	ec26                	sd	s1,24(sp)
    8000130e:	6485                	lui	s1,0x1
    80001310:	f022                	sd	s0,32(sp)
    80001312:	e84a                	sd	s2,16(sp)
    80001314:	e44e                	sd	s3,8(sp)
    80001316:	f406                	sd	ra,40(sp)
    80001318:	89aa                	mv	s3,a0
    8000131a:	842a                	mv	s0,a0
    8000131c:	94aa                	add	s1,s1,a0
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000131e:	4905                	li	s2,1
    80001320:	a021                	j	80001328 <destroy_pagetable.part.0+0x1e>
    for (int i = 0; i < 512; i++) {
    80001322:	0421                	addi	s0,s0,8
    80001324:	00940f63          	beq	s0,s1,80001342 <destroy_pagetable.part.0+0x38>
        pte_t pte = pt[i];
    80001328:	6008                	ld	a0,0(s0)
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000132a:	00f57793          	andi	a5,a0,15
    8000132e:	ff279ae3          	bne	a5,s2,80001322 <destroy_pagetable.part.0+0x18>
            uint64 child_pa = PTE2PA(pte);
    80001332:	8129                	srli	a0,a0,0xa
    80001334:	0532                	slli	a0,a0,0xc
    if (pt == 0) return;
    80001336:	d575                	beqz	a0,80001322 <destroy_pagetable.part.0+0x18>
    for (int i = 0; i < 512; i++) {
    80001338:	0421                	addi	s0,s0,8
    8000133a:	fd1ff0ef          	jal	8000130a <destroy_pagetable.part.0>
    8000133e:	fe9415e3          	bne	s0,s1,80001328 <destroy_pagetable.part.0+0x1e>
}
    80001342:	7402                	ld	s0,32(sp)
    80001344:	70a2                	ld	ra,40(sp)
    80001346:	64e2                	ld	s1,24(sp)
    80001348:	6942                	ld	s2,16(sp)
    free_page((void*)pt);
    8000134a:	854e                	mv	a0,s3
}
    8000134c:	69a2                	ld	s3,8(sp)
    8000134e:	6145                	addi	sp,sp,48
    free_page((void*)pt);
    80001350:	ecffe06f          	j	8000021e <free_page>

0000000080001354 <create_pagetable>:
pagetable_t create_pagetable(void) {
    80001354:	1141                	addi	sp,sp,-16
    80001356:	e406                	sd	ra,8(sp)
    pt = (pagetable_t)alloc_page();
    80001358:	e97fe0ef          	jal	800001ee <alloc_page>
    if (pt == 0) {
    8000135c:	c909                	beqz	a0,8000136e <create_pagetable+0x1a>
    8000135e:	6705                	lui	a4,0x1
    80001360:	972a                	add	a4,a4,a0
    80001362:	87aa                	mv	a5,a0
        pt[i] = 0;
    80001364:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
    80001368:	07a1                	addi	a5,a5,8
    8000136a:	fee79de3          	bne	a5,a4,80001364 <create_pagetable+0x10>
}
    8000136e:	60a2                	ld	ra,8(sp)
    80001370:	0141                	addi	sp,sp,16
    80001372:	8082                	ret

0000000080001374 <destroy_pagetable>:
    if (pt == 0) return;
    80001374:	c111                	beqz	a0,80001378 <destroy_pagetable+0x4>
    80001376:	bf51                	j	8000130a <destroy_pagetable.part.0>
}
    80001378:	8082                	ret

000000008000137a <walk_lookup>:
    if (va >= MAXVA) {
    8000137a:	57fd                	li	a5,-1
    8000137c:	83e9                	srli	a5,a5,0x1a
    8000137e:	00b7e363          	bltu	a5,a1,80001384 <walk_lookup+0xa>
    80001382:	b799                	j	800012c8 <walk_lookup.part.0>
}
    80001384:	4501                	li	a0,0
    80001386:	8082                	ret

0000000080001388 <walk_create>:

// 页表遍历 - 创建模式（必要时创建新页表）
pte_t* walk_create(pagetable_t pt, uint64 va) {
    if (va >= MAXVA) {
    80001388:	57fd                	li	a5,-1
pte_t* walk_create(pagetable_t pt, uint64 va) {
    8000138a:	7179                	addi	sp,sp,-48
    if (va >= MAXVA) {
    8000138c:	01a7d713          	srli	a4,a5,0x1a
    80001390:	4609                	li	a2,2
pte_t* walk_create(pagetable_t pt, uint64 va) {
    80001392:	f406                	sd	ra,40(sp)
    80001394:	87b2                	mv	a5,a2
    80001396:	4805                	li	a6,1
    if (va >= MAXVA) {
    80001398:	08b76863          	bltu	a4,a1,80001428 <walk_create+0xa0>
        return 0;
    }
    
    // 从根页表开始，逐级向下查找或创建
    for (int level = 2; level > 0; level--) {
        int index = PX(level, va);
    8000139c:	0037969b          	slliw	a3,a5,0x3
    800013a0:	9ebd                	addw	a3,a3,a5
    800013a2:	26b1                	addiw	a3,a3,12
    800013a4:	00d5d6b3          	srl	a3,a1,a3
        pte_t *pte = &pt[index];
    800013a8:	1ff6f693          	andi	a3,a3,511
    800013ac:	068e                	slli	a3,a3,0x3
    800013ae:	96aa                	add	a3,a3,a0
        
        if (*pte & PTE_V) {
    800013b0:	6288                	ld	a0,0(a3)
    800013b2:	00157713          	andi	a4,a0,1
    800013b6:	c705                	beqz	a4,800013de <walk_create+0x56>
            // 页表项已存在，检查是否为中间级页表项
            if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
    800013b8:	00e57713          	andi	a4,a0,14
    800013bc:	ef35                	bnez	a4,80001438 <walk_create+0xb0>
                printf("walk_create: 遇到叶子页面在级别 %d\n", level);
                return 0;
            }
            // 获取下一级页表
            pt = (pagetable_t)PTE2PA(*pte);
    800013be:	8129                	srli	a0,a0,0xa
    800013c0:	0532                	slli	a0,a0,0xc
    for (int level = 2; level > 0; level--) {
    800013c2:	4785                	li	a5,1
    800013c4:	01061b63          	bne	a2,a6,800013da <walk_create+0x52>
        }
    }
    
    // 返回叶子级页表项的地址
    return &pt[PX(0, va)];
}
    800013c8:	70a2                	ld	ra,40(sp)
    return &pt[PX(0, va)];
    800013ca:	00c5d793          	srli	a5,a1,0xc
    800013ce:	1ff7f793          	andi	a5,a5,511
    800013d2:	078e                	slli	a5,a5,0x3
    800013d4:	953e                	add	a0,a0,a5
}
    800013d6:	6145                	addi	sp,sp,48
    800013d8:	8082                	ret
    800013da:	863e                	mv	a2,a5
    800013dc:	b7c1                	j	8000139c <walk_create+0x14>
    800013de:	ec2e                	sd	a1,24(sp)
    800013e0:	e432                	sd	a2,8(sp)
    800013e2:	e036                	sd	a3,0(sp)
    pt = (pagetable_t)alloc_page();
    800013e4:	e83e                	sd	a5,16(sp)
    800013e6:	e09fe0ef          	jal	800001ee <alloc_page>
    if (pt == 0) {
    800013ea:	6682                	ld	a3,0(sp)
    800013ec:	6622                	ld	a2,8(sp)
    800013ee:	65e2                	ld	a1,24(sp)
    800013f0:	4805                	li	a6,1
    800013f2:	c105                	beqz	a0,80001412 <walk_create+0x8a>
    800013f4:	6705                	lui	a4,0x1
    800013f6:	972a                	add	a4,a4,a0
    800013f8:	87aa                	mv	a5,a0
        pt[i] = 0;
    800013fa:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
    800013fe:	07a1                	addi	a5,a5,8
    80001400:	fef71de3          	bne	a4,a5,800013fa <walk_create+0x72>
            *pte = PA2PTE((uint64)new_pt) | PTE_V;
    80001404:	00c55793          	srli	a5,a0,0xc
    80001408:	07aa                	slli	a5,a5,0xa
    8000140a:	0017e793          	ori	a5,a5,1
    8000140e:	e29c                	sd	a5,0(a3)
            pt = new_pt;
    80001410:	bf4d                	j	800013c2 <walk_create+0x3a>
                printf("walk_create: 分配页表失败在级别 %d\n", level);
    80001412:	65c2                	ld	a1,16(sp)
    80001414:	00002517          	auipc	a0,0x2
    80001418:	9b450513          	addi	a0,a0,-1612 # 80002dc8 <etext+0xdc8>
    8000141c:	dd0ff0ef          	jal	800009ec <printf>
        return 0;
    80001420:	4501                	li	a0,0
}
    80001422:	70a2                	ld	ra,40(sp)
    80001424:	6145                	addi	sp,sp,48
    80001426:	8082                	ret
        printf("walk_create: 地址超出范围 0x%p\n", (void*)va);
    80001428:	00002517          	auipc	a0,0x2
    8000142c:	94850513          	addi	a0,a0,-1720 # 80002d70 <etext+0xd70>
    80001430:	dbcff0ef          	jal	800009ec <printf>
        return 0;
    80001434:	4501                	li	a0,0
    80001436:	b7f5                	j	80001422 <walk_create+0x9a>
                printf("walk_create: 遇到叶子页面在级别 %d\n", level);
    80001438:	85be                	mv	a1,a5
    8000143a:	00002517          	auipc	a0,0x2
    8000143e:	95e50513          	addi	a0,a0,-1698 # 80002d98 <etext+0xd98>
    80001442:	daaff0ef          	jal	800009ec <printf>
        return 0;
    80001446:	4501                	li	a0,0
    80001448:	bfe9                	j	80001422 <walk_create+0x9a>

000000008000144a <map_page>:
// 建立单页映射
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    pte_t *pte;
    
    // 检查地址对齐
    if ((va % PGSIZE) != 0) {
    8000144a:	6785                	lui	a5,0x1
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    8000144c:	1101                	addi	sp,sp,-32
    if ((va % PGSIZE) != 0) {
    8000144e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    80001450:	ec06                	sd	ra,24(sp)
    if ((va % PGSIZE) != 0) {
    80001452:	8fed                	and	a5,a5,a1
    80001454:	e7a9                	bnez	a5,8000149e <map_page+0x54>
        printf("map_page: 虚拟地址未对齐 0x%p\n", (void*)va);
        return -1;
    }
    
    if ((pa % PGSIZE) != 0) {
    80001456:	03461793          	slli	a5,a2,0x34
    8000145a:	eb8d                	bnez	a5,8000148c <map_page+0x42>
    8000145c:	e822                	sd	s0,16(sp)
    8000145e:	e436                	sd	a3,8(sp)
    80001460:	e032                	sd	a2,0(sp)
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
        return -1;
    }
    
    // 获取页表项地址（必要时创建中间级页表）
    pte = walk_create(pt, va);
    80001462:	842e                	mv	s0,a1
    80001464:	f25ff0ef          	jal	80001388 <walk_create>
    if (pte == 0) {
    80001468:	6602                	ld	a2,0(sp)
    8000146a:	66a2                	ld	a3,8(sp)
    8000146c:	cd31                	beqz	a0,800014c8 <map_page+0x7e>
        printf("map_page: walk_create失败\n");
        return -1;
    }
    
    // 检查是否已经映射
    if (*pte & PTE_V) {
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	0017f713          	andi	a4,a5,1
    80001474:	ef0d                	bnez	a4,800014ae <map_page+0x64>
               (void*)va, (void*)PTE2PA(*pte));
        return -1;
    }
    
    // 设置页表项
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001476:	8231                	srli	a2,a2,0xc
    80001478:	062a                	slli	a2,a2,0xa
    8000147a:	8e55                	or	a2,a2,a3
    
    return 0;
    8000147c:	6442                	ld	s0,16(sp)
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000147e:	00166613          	ori	a2,a2,1
    80001482:	e110                	sd	a2,0(a0)
    return 0;
    80001484:	4501                	li	a0,0
}
    80001486:	60e2                	ld	ra,24(sp)
    80001488:	6105                	addi	sp,sp,32
    8000148a:	8082                	ret
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
    8000148c:	85b2                	mv	a1,a2
    8000148e:	00002517          	auipc	a0,0x2
    80001492:	99250513          	addi	a0,a0,-1646 # 80002e20 <etext+0xe20>
    80001496:	d56ff0ef          	jal	800009ec <printf>
        return -1;
    8000149a:	557d                	li	a0,-1
    8000149c:	b7ed                	j	80001486 <map_page+0x3c>
        printf("map_page: 虚拟地址未对齐 0x%p\n", (void*)va);
    8000149e:	00002517          	auipc	a0,0x2
    800014a2:	95a50513          	addi	a0,a0,-1702 # 80002df8 <etext+0xdf8>
    800014a6:	d46ff0ef          	jal	800009ec <printf>
        return -1;
    800014aa:	557d                	li	a0,-1
    800014ac:	bfe9                	j	80001486 <map_page+0x3c>
               (void*)va, (void*)PTE2PA(*pte));
    800014ae:	83a9                	srli	a5,a5,0xa
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    800014b0:	85a2                	mv	a1,s0
    800014b2:	00c79613          	slli	a2,a5,0xc
    800014b6:	00002517          	auipc	a0,0x2
    800014ba:	9b250513          	addi	a0,a0,-1614 # 80002e68 <etext+0xe68>
    800014be:	d2eff0ef          	jal	800009ec <printf>
        return -1;
    800014c2:	557d                	li	a0,-1
        return -1;
    800014c4:	6442                	ld	s0,16(sp)
    800014c6:	b7c1                	j	80001486 <map_page+0x3c>
        printf("map_page: walk_create失败\n");
    800014c8:	00002517          	auipc	a0,0x2
    800014cc:	98050513          	addi	a0,a0,-1664 # 80002e48 <etext+0xe48>
    800014d0:	d1cff0ef          	jal	800009ec <printf>
        return -1;
    800014d4:	557d                	li	a0,-1
        return -1;
    800014d6:	6442                	ld	s0,16(sp)
    800014d8:	b77d                	j	80001486 <map_page+0x3c>

00000000800014da <map_range>:

// 建立连续页面映射
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    800014da:	715d                	addi	sp,sp,-80
    800014dc:	f44e                	sd	s3,40(sp)
    uint64 a, last;
    
    // 检查对齐
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
    800014de:	6985                	lui	s3,0x1
    800014e0:	00c5e7b3          	or	a5,a1,a2
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    800014e4:	fc26                	sd	s1,56(sp)
    800014e6:	84ae                	mv	s1,a1
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
    800014e8:	fff98593          	addi	a1,s3,-1 # fff <_entry-0x7ffff001>
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    800014ec:	e486                	sd	ra,72(sp)
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
    800014ee:	8fed                	and	a5,a5,a1
    800014f0:	e7c5                	bnez	a5,80001598 <map_range+0xbe>
        printf("map_range: 地址或大小未对齐\n");
        return -1;
    }
    
    if (size == 0) {
    800014f2:	ce21                	beqz	a2,8000154a <map_range+0x70>
    if ((pa % PGSIZE) != 0) {
    800014f4:	03469793          	slli	a5,a3,0x34
    800014f8:	efb9                	bnez	a5,80001556 <map_range+0x7c>
        return 0;
    }
    
    a = va;
    last = va + size - PGSIZE;
    800014fa:	80060613          	addi	a2,a2,-2048
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	80060613          	addi	a2,a2,-2048
    a = va;
    80001504:	8426                	mv	s0,s1
    80001506:	f84a                	sd	s2,48(sp)
    80001508:	f052                	sd	s4,32(sp)
    8000150a:	ec56                	sd	s5,24(sp)
    8000150c:	8a2a                	mv	s4,a0
    8000150e:	8aba                	mv	s5,a4
    last = va + size - PGSIZE;
    80001510:	94b2                	add	s1,s1,a2
    80001512:	40868933          	sub	s2,a3,s0
    80001516:	a011                	j	8000151a <map_range+0x40>
    
    // 逐页建立映射
    for (; ; a += PGSIZE, pa += PGSIZE) {
    80001518:	944e                	add	s0,s0,s3
    pte = walk_create(pt, va);
    8000151a:	85a2                	mv	a1,s0
    8000151c:	8552                	mv	a0,s4
    8000151e:	e6bff0ef          	jal	80001388 <walk_create>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001522:	012407b3          	add	a5,s0,s2
    80001526:	83b1                	srli	a5,a5,0xc
    80001528:	07aa                	slli	a5,a5,0xa
    8000152a:	0157e7b3          	or	a5,a5,s5
    8000152e:	0017e793          	ori	a5,a5,1
    if (pte == 0) {
    80001532:	c93d                	beqz	a0,800015a8 <map_range+0xce>
    if (*pte & PTE_V) {
    80001534:	6118                	ld	a4,0(a0)
    80001536:	00177693          	andi	a3,a4,1
    8000153a:	ee95                	bnez	a3,80001576 <map_range+0x9c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000153c:	e11c                	sd	a5,0(a0)
            printf("map_range: 映射失败在地址 0x%p\n", (void*)a);
            // TODO: 这里应该清理已经建立的映射
            return -1;
        }
        
        if (a == last) {
    8000153e:	fc849de3          	bne	s1,s0,80001518 <map_range+0x3e>
    80001542:	6406                	ld	s0,64(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	7a02                	ld	s4,32(sp)
    80001548:	6ae2                	ld	s5,24(sp)
        return 0;
    8000154a:	4501                	li	a0,0
            break;
        }
    }
    
    return 0;
}
    8000154c:	60a6                	ld	ra,72(sp)
    8000154e:	74e2                	ld	s1,56(sp)
    80001550:	79a2                	ld	s3,40(sp)
    80001552:	6161                	addi	sp,sp,80
    80001554:	8082                	ret
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
    80001556:	85b6                	mv	a1,a3
    80001558:	00002517          	auipc	a0,0x2
    8000155c:	8c850513          	addi	a0,a0,-1848 # 80002e20 <etext+0xe20>
    80001560:	c8cff0ef          	jal	800009ec <printf>
            printf("map_range: 映射失败在地址 0x%p\n", (void*)a);
    80001564:	85a6                	mv	a1,s1
    80001566:	00002517          	auipc	a0,0x2
    8000156a:	95250513          	addi	a0,a0,-1710 # 80002eb8 <etext+0xeb8>
    8000156e:	c7eff0ef          	jal	800009ec <printf>
        return -1;
    80001572:	557d                	li	a0,-1
    80001574:	bfe1                	j	8000154c <map_range+0x72>
               (void*)va, (void*)PTE2PA(*pte));
    80001576:	8329                	srli	a4,a4,0xa
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    80001578:	85a2                	mv	a1,s0
    8000157a:	00c71613          	slli	a2,a4,0xc
    8000157e:	00002517          	auipc	a0,0x2
    80001582:	8ea50513          	addi	a0,a0,-1814 # 80002e68 <etext+0xe68>
    80001586:	e422                	sd	s0,8(sp)
    80001588:	c64ff0ef          	jal	800009ec <printf>
        return -1;
    8000158c:	65a2                	ld	a1,8(sp)
    8000158e:	6406                	ld	s0,64(sp)
    80001590:	7942                	ld	s2,48(sp)
    80001592:	7a02                	ld	s4,32(sp)
    80001594:	6ae2                	ld	s5,24(sp)
    80001596:	bfc1                	j	80001566 <map_range+0x8c>
        printf("map_range: 地址或大小未对齐\n");
    80001598:	00002517          	auipc	a0,0x2
    8000159c:	8f850513          	addi	a0,a0,-1800 # 80002e90 <etext+0xe90>
    800015a0:	c4cff0ef          	jal	800009ec <printf>
        return -1;
    800015a4:	557d                	li	a0,-1
    800015a6:	b75d                	j	8000154c <map_range+0x72>
        printf("map_page: walk_create失败\n");
    800015a8:	00002517          	auipc	a0,0x2
    800015ac:	8a050513          	addi	a0,a0,-1888 # 80002e48 <etext+0xe48>
    800015b0:	c3cff0ef          	jal	800009ec <printf>
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    800015b4:	85a2                	mv	a1,s0
    800015b6:	7942                	ld	s2,48(sp)
    800015b8:	6406                	ld	s0,64(sp)
    800015ba:	7a02                	ld	s4,32(sp)
    800015bc:	6ae2                	ld	s5,24(sp)
    800015be:	b765                	j	80001566 <map_range+0x8c>

00000000800015c0 <dump_pagetable>:

// 打印页表内容（调试用）
void dump_pagetable(pagetable_t pt, int level) {
    800015c0:	715d                	addi	sp,sp,-80
    800015c2:	e0a2                	sd	s0,64(sp)
    800015c4:	f44e                	sd	s3,40(sp)
    800015c6:	f052                	sd	s4,32(sp)
    800015c8:	ec56                	sd	s5,24(sp)
    // 缩进显示层级
    for (int indent = 0; indent < (3 - level); indent++) {
    800015ca:	4a0d                	li	s4,3
void dump_pagetable(pagetable_t pt, int level) {
    800015cc:	e486                	sd	ra,72(sp)
    800015ce:	fc26                	sd	s1,56(sp)
    800015d0:	f84a                	sd	s2,48(sp)
    800015d2:	e85a                	sd	s6,16(sp)
    for (int indent = 0; indent < (3 - level); indent++) {
    800015d4:	4789                	li	a5,2
void dump_pagetable(pagetable_t pt, int level) {
    800015d6:	8aae                	mv	s5,a1
    800015d8:	89aa                	mv	s3,a0
    for (int indent = 0; indent < (3 - level); indent++) {
    800015da:	40ba0a3b          	subw	s4,s4,a1
    800015de:	4401                	li	s0,0
    800015e0:	00b7cb63          	blt	a5,a1,800015f6 <dump_pagetable+0x36>
        printf("  ");
    800015e4:	00002517          	auipc	a0,0x2
    800015e8:	92450513          	addi	a0,a0,-1756 # 80002f08 <etext+0xf08>
    for (int indent = 0; indent < (3 - level); indent++) {
    800015ec:	2405                	addiw	s0,s0,1
        printf("  ");
    800015ee:	bfeff0ef          	jal	800009ec <printf>
    for (int indent = 0; indent < (3 - level); indent++) {
    800015f2:	ff4449e3          	blt	s0,s4,800015e4 <dump_pagetable+0x24>
    }
    
    printf("页表级别 %d (物理地址: 0x%p)\n", level, pt);
    800015f6:	864e                	mv	a2,s3
    800015f8:	85d6                	mv	a1,s5
    800015fa:	00002517          	auipc	a0,0x2
    800015fe:	8e650513          	addi	a0,a0,-1818 # 80002ee0 <etext+0xee0>
    80001602:	beaff0ef          	jal	800009ec <printf>
    
    // 遍历页表项
    for (int i = 0; i < 512; i++) {
    80001606:	4901                	li	s2,0
        pte_t pte = pt[i];
        
        if (pte & PTE_V) {
            // 显示缩进
            for (int indent = 0; indent < (3 - level); indent++) {
    80001608:	4b09                	li	s6,2
    8000160a:	a039                	j	80001618 <dump_pagetable+0x58>
    for (int i = 0; i < 512; i++) {
    8000160c:	2905                	addiw	s2,s2,1
    8000160e:	20000793          	li	a5,512
    80001612:	09a1                	addi	s3,s3,8
    80001614:	08f90063          	beq	s2,a5,80001694 <dump_pagetable+0xd4>
        pte_t pte = pt[i];
    80001618:	0009b483          	ld	s1,0(s3)
        if (pte & PTE_V) {
    8000161c:	0014f793          	andi	a5,s1,1
    80001620:	d7f5                	beqz	a5,8000160c <dump_pagetable+0x4c>
            for (int indent = 0; indent < (3 - level); indent++) {
    80001622:	4401                	li	s0,0
    80001624:	0d5b4363          	blt	s6,s5,800016ea <dump_pagetable+0x12a>
                printf("  ");
    80001628:	00002517          	auipc	a0,0x2
    8000162c:	8e050513          	addi	a0,a0,-1824 # 80002f08 <etext+0xf08>
            for (int indent = 0; indent < (3 - level); indent++) {
    80001630:	2405                	addiw	s0,s0,1
                printf("  ");
    80001632:	bbaff0ef          	jal	800009ec <printf>
            for (int indent = 0; indent < (3 - level); indent++) {
    80001636:	ff4449e3          	blt	s0,s4,80001628 <dump_pagetable+0x68>
            }
            
            printf("  [%d] PTE=0x%p", i, (void*)pte);
    8000163a:	85ca                	mv	a1,s2
    8000163c:	8626                	mv	a2,s1
    8000163e:	00002517          	auipc	a0,0x2
    80001642:	8d250513          	addi	a0,a0,-1838 # 80002f10 <etext+0xf10>
    80001646:	ba6ff0ef          	jal	800009ec <printf>
            
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
                // 中间级页表项
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    8000164a:	00a4d593          	srli	a1,s1,0xa
    8000164e:	05b2                	slli	a1,a1,0xc
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001650:	01505563          	blez	s5,8000165a <dump_pagetable+0x9a>
    80001654:	00e4f793          	andi	a5,s1,14
    80001658:	c7dd                	beqz	a5,80001706 <dump_pagetable+0x146>
                if (level > 0) {
                    dump_pagetable((pagetable_t)PTE2PA(pte), level - 1);
                }
            } else {
                // 叶子页表项
                printf(" -> 页面 0x%p [", (void*)PTE2PA(pte));
    8000165a:	00002517          	auipc	a0,0x2
    8000165e:	8de50513          	addi	a0,a0,-1826 # 80002f38 <etext+0xf38>
    80001662:	b8aff0ef          	jal	800009ec <printf>
                if (pte & PTE_R) printf("R");
    80001666:	0024f793          	andi	a5,s1,2
    8000166a:	ef9d                	bnez	a5,800016a8 <dump_pagetable+0xe8>
                if (pte & PTE_W) printf("W");  
    8000166c:	0044f793          	andi	a5,s1,4
    80001670:	e7a9                	bnez	a5,800016ba <dump_pagetable+0xfa>
                if (pte & PTE_X) printf("X");
    80001672:	0084f793          	andi	a5,s1,8
    80001676:	ebb9                	bnez	a5,800016cc <dump_pagetable+0x10c>
                if (pte & PTE_U) printf("U");
    80001678:	88c1                	andi	s1,s1,16
    8000167a:	e0ad                	bnez	s1,800016dc <dump_pagetable+0x11c>
                printf("]\n");
    8000167c:	00002517          	auipc	a0,0x2
    80001680:	8f450513          	addi	a0,a0,-1804 # 80002f70 <etext+0xf70>
    80001684:	b68ff0ef          	jal	800009ec <printf>
    for (int i = 0; i < 512; i++) {
    80001688:	2905                	addiw	s2,s2,1
    8000168a:	20000793          	li	a5,512
    8000168e:	09a1                	addi	s3,s3,8
    80001690:	f8f914e3          	bne	s2,a5,80001618 <dump_pagetable+0x58>
            }
        }
    }
}
    80001694:	60a6                	ld	ra,72(sp)
    80001696:	6406                	ld	s0,64(sp)
    80001698:	74e2                	ld	s1,56(sp)
    8000169a:	7942                	ld	s2,48(sp)
    8000169c:	79a2                	ld	s3,40(sp)
    8000169e:	7a02                	ld	s4,32(sp)
    800016a0:	6ae2                	ld	s5,24(sp)
    800016a2:	6b42                	ld	s6,16(sp)
    800016a4:	6161                	addi	sp,sp,80
    800016a6:	8082                	ret
                if (pte & PTE_R) printf("R");
    800016a8:	00002517          	auipc	a0,0x2
    800016ac:	8a850513          	addi	a0,a0,-1880 # 80002f50 <etext+0xf50>
    800016b0:	b3cff0ef          	jal	800009ec <printf>
                if (pte & PTE_W) printf("W");  
    800016b4:	0044f793          	andi	a5,s1,4
    800016b8:	dfcd                	beqz	a5,80001672 <dump_pagetable+0xb2>
    800016ba:	00002517          	auipc	a0,0x2
    800016be:	89e50513          	addi	a0,a0,-1890 # 80002f58 <etext+0xf58>
    800016c2:	b2aff0ef          	jal	800009ec <printf>
                if (pte & PTE_X) printf("X");
    800016c6:	0084f793          	andi	a5,s1,8
    800016ca:	d7dd                	beqz	a5,80001678 <dump_pagetable+0xb8>
    800016cc:	00002517          	auipc	a0,0x2
    800016d0:	89450513          	addi	a0,a0,-1900 # 80002f60 <etext+0xf60>
                if (pte & PTE_U) printf("U");
    800016d4:	88c1                	andi	s1,s1,16
                if (pte & PTE_X) printf("X");
    800016d6:	b16ff0ef          	jal	800009ec <printf>
                if (pte & PTE_U) printf("U");
    800016da:	d0cd                	beqz	s1,8000167c <dump_pagetable+0xbc>
    800016dc:	00002517          	auipc	a0,0x2
    800016e0:	88c50513          	addi	a0,a0,-1908 # 80002f68 <etext+0xf68>
    800016e4:	b08ff0ef          	jal	800009ec <printf>
    800016e8:	bf51                	j	8000167c <dump_pagetable+0xbc>
            printf("  [%d] PTE=0x%p", i, (void*)pte);
    800016ea:	85ca                	mv	a1,s2
    800016ec:	8626                	mv	a2,s1
    800016ee:	00002517          	auipc	a0,0x2
    800016f2:	82250513          	addi	a0,a0,-2014 # 80002f10 <etext+0xf10>
    800016f6:	af6ff0ef          	jal	800009ec <printf>
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    800016fa:	00a4d593          	srli	a1,s1,0xa
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800016fe:	00e4f793          	andi	a5,s1,14
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    80001702:	05b2                	slli	a1,a1,0xc
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001704:	fbb9                	bnez	a5,8000165a <dump_pagetable+0x9a>
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
    80001706:	00002517          	auipc	a0,0x2
    8000170a:	81a50513          	addi	a0,a0,-2022 # 80002f20 <etext+0xf20>
    8000170e:	e42e                	sd	a1,8(sp)
    80001710:	adcff0ef          	jal	800009ec <printf>
                    dump_pagetable((pagetable_t)PTE2PA(pte), level - 1);
    80001714:	6522                	ld	a0,8(sp)
    80001716:	fffa859b          	addiw	a1,s5,-1
    8000171a:	ea7ff0ef          	jal	800015c0 <dump_pagetable>
    8000171e:	b5fd                	j	8000160c <dump_pagetable+0x4c>

0000000080001720 <va2pa>:
// 地址转换：虚拟地址转物理地址
uint64 va2pa(pagetable_t pt, uint64 va) {
    pte_t *pte;
    uint64 pa;
    
    if (va >= MAXVA) {
    80001720:	577d                	li	a4,-1
    80001722:	8369                	srli	a4,a4,0x1a
    80001724:	02b76963          	bltu	a4,a1,80001756 <va2pa+0x36>
uint64 va2pa(pagetable_t pt, uint64 va) {
    80001728:	1141                	addi	sp,sp,-16
    8000172a:	e022                	sd	s0,0(sp)
    8000172c:	e406                	sd	ra,8(sp)
    8000172e:	842e                	mv	s0,a1
    if (va >= MAXVA) {
    80001730:	b99ff0ef          	jal	800012c8 <walk_lookup.part.0>
        return 0;
    }
    
    pte = walk_lookup(pt, va);
    if (pte == 0) {
    80001734:	cd09                	beqz	a0,8000174e <va2pa+0x2e>
        return 0;  // 未映射
    }
    
    if ((*pte & PTE_V) == 0) {
    80001736:	611c                	ld	a5,0(a0)
    80001738:	0017f513          	andi	a0,a5,1
    8000173c:	c909                	beqz	a0,8000174e <va2pa+0x2e>
        return 0;  // 无效映射
    }
    
    pa = PTE2PA(*pte);
    8000173e:	00a7d713          	srli	a4,a5,0xa
    return pa + (va & (PGSIZE - 1));  // 加上页内偏移
    80001742:	03441793          	slli	a5,s0,0x34
    pa = PTE2PA(*pte);
    80001746:	0732                	slli	a4,a4,0xc
    return pa + (va & (PGSIZE - 1));  // 加上页内偏移
    80001748:	93d1                	srli	a5,a5,0x34
    8000174a:	00f70533          	add	a0,a4,a5
}
    8000174e:	60a2                	ld	ra,8(sp)
    80001750:	6402                	ld	s0,0(sp)
    80001752:	0141                	addi	sp,sp,16
    80001754:	8082                	ret
        return 0;
    80001756:	4501                	li	a0,0
}
    80001758:	8082                	ret

000000008000175a <kvmmake>:
#ifndef PX
#define PX(level, va) ((((uint64) (va)) >> (PGSHIFT + (9 * (level)))) & 0x1FF)
#endif

// 创建内核页表
pagetable_t kvmmake(void) {
    8000175a:	1101                	addi	sp,sp,-32
    pagetable_t kpgtbl;
    
    printf("创建内核页表...\n");
    8000175c:	00002517          	auipc	a0,0x2
    80001760:	81c50513          	addi	a0,a0,-2020 # 80002f78 <etext+0xf78>
pagetable_t kvmmake(void) {
    80001764:	ec06                	sd	ra,24(sp)
    80001766:	e822                	sd	s0,16(sp)
    printf("创建内核页表...\n");
    80001768:	a84ff0ef          	jal	800009ec <printf>
    pt = (pagetable_t)alloc_page();
    8000176c:	a83fe0ef          	jal	800001ee <alloc_page>
    if (pt == 0) {
    80001770:	c945                	beqz	a0,80001820 <kvmmake+0xc6>
    80001772:	6705                	lui	a4,0x1
    80001774:	e426                	sd	s1,8(sp)
    80001776:	842a                	mv	s0,a0
    80001778:	972a                	add	a4,a4,a0
    8000177a:	87aa                	mv	a5,a0
        pt[i] = 0;
    8000177c:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
    80001780:	07a1                	addi	a5,a5,8
    80001782:	fee79de3          	bne	a5,a4,8000177c <kvmmake+0x22>
    if (kpgtbl == 0) {
        printf("kvmmake: 创建页表失败\n");
        return 0;
    }
    
    printf("映射UART设备...\n");
    80001786:	00002517          	auipc	a0,0x2
    8000178a:	82a50513          	addi	a0,a0,-2006 # 80002fb0 <etext+0xfb0>
    8000178e:	a5eff0ef          	jal	800009ec <printf>
    pte = walk_create(pt, va);
    80001792:	8522                	mv	a0,s0
    80001794:	100005b7          	lui	a1,0x10000
    80001798:	bf1ff0ef          	jal	80001388 <walk_create>
    if (pte == 0) {
    8000179c:	0e050363          	beqz	a0,80001882 <kvmmake+0x128>
    if (*pte & PTE_V) {
    800017a0:	611c                	ld	a5,0(a0)
    800017a2:	0017f713          	andi	a4,a5,1
    800017a6:	ef45                	bnez	a4,8000185e <kvmmake+0x104>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800017a8:	040007b7          	lui	a5,0x4000
    800017ac:	079d                	addi	a5,a5,7 # 4000007 <_entry-0x7bfffff9>
    800017ae:	e11c                	sd	a5,0(a0)
    if (map_page(kpgtbl, UART0, UART0, PTE_R | PTE_W) != 0) {
        printf("kvmmake: UART映射失败\n");
        goto fail;
    }
    
    printf("映射内核代码段...\n");
    800017b0:	00002517          	auipc	a0,0x2
    800017b4:	81850513          	addi	a0,a0,-2024 # 80002fc8 <etext+0xfc8>
    800017b8:	a34ff0ef          	jal	800009ec <printf>
    // 映射内核代码段（只读+可执行）
    uint64 code_size = PGROUNDUP((uint64)etext - KERNBASE);
    if (map_range(kpgtbl, KERNBASE, code_size, KERNBASE, PTE_R | PTE_X) != 0) {
    800017bc:	4685                	li	a3,1
    800017be:	06fe                	slli	a3,a3,0x1f
    uint64 code_size = PGROUNDUP((uint64)etext - KERNBASE);
    800017c0:	80002617          	auipc	a2,0x80002
    800017c4:	83f60613          	addi	a2,a2,-1985 # 2fff <_entry-0x7fffd001>
    800017c8:	74fd                	lui	s1,0xfffff
    if (map_range(kpgtbl, KERNBASE, code_size, KERNBASE, PTE_R | PTE_X) != 0) {
    800017ca:	8522                	mv	a0,s0
    800017cc:	85b6                	mv	a1,a3
    800017ce:	8e65                	and	a2,a2,s1
    800017d0:	4729                	li	a4,10
    800017d2:	d09ff0ef          	jal	800014da <map_range>
    800017d6:	e12d                	bnez	a0,80001838 <kvmmake+0xde>
        printf("kvmmake: 内核代码段映射失败\n");
        goto fail;
    }
    
    printf("映射内核数据段...\n");
    800017d8:	00002517          	auipc	a0,0x2
    800017dc:	85850513          	addi	a0,a0,-1960 # 80003030 <etext+0x1030>
    800017e0:	a0cff0ef          	jal	800009ec <printf>
    // 映射内核数据段（读写）
    uint64 data_size = PGROUNDUP(PHYSTOP - (uint64)etext);
    800017e4:	00088637          	lui	a2,0x88
    800017e8:	0605                	addi	a2,a2,1 # 88001 <_entry-0x7ff77fff>
    800017ea:	0632                	slli	a2,a2,0xc
    800017ec:	00001797          	auipc	a5,0x1
    800017f0:	81478793          	addi	a5,a5,-2028 # 80002000 <etext>
    800017f4:	167d                	addi	a2,a2,-1
    800017f6:	8e1d                	sub	a2,a2,a5
    if (map_range(kpgtbl, (uint64)etext, data_size, (uint64)etext, PTE_R | PTE_W) != 0) {
    800017f8:	8e65                	and	a2,a2,s1
    800017fa:	86be                	mv	a3,a5
    800017fc:	85be                	mv	a1,a5
    800017fe:	8522                	mv	a0,s0
    80001800:	4719                	li	a4,6
    80001802:	cd9ff0ef          	jal	800014da <map_range>
    80001806:	e529                	bnez	a0,80001850 <kvmmake+0xf6>
        printf("kvmmake: 内核数据段映射失败\n");
        goto fail;
    }
    
    printf("内核页表创建成功\n");
    80001808:	00002517          	auipc	a0,0x2
    8000180c:	87050513          	addi	a0,a0,-1936 # 80003078 <etext+0x1078>
    80001810:	9dcff0ef          	jal	800009ec <printf>
    return kpgtbl;
    
fail:
    destroy_pagetable(kpgtbl);
    return 0;
}
    80001814:	60e2                	ld	ra,24(sp)
    80001816:	8522                	mv	a0,s0
    80001818:	6442                	ld	s0,16(sp)
    return kpgtbl;
    8000181a:	64a2                	ld	s1,8(sp)
}
    8000181c:	6105                	addi	sp,sp,32
    8000181e:	8082                	ret
        printf("kvmmake: 创建页表失败\n");
    80001820:	00001517          	auipc	a0,0x1
    80001824:	77050513          	addi	a0,a0,1904 # 80002f90 <etext+0xf90>
    80001828:	9c4ff0ef          	jal	800009ec <printf>
        return 0;
    8000182c:	4401                	li	s0,0
}
    8000182e:	60e2                	ld	ra,24(sp)
    80001830:	8522                	mv	a0,s0
    80001832:	6442                	ld	s0,16(sp)
    80001834:	6105                	addi	sp,sp,32
    80001836:	8082                	ret
        printf("kvmmake: 内核代码段映射失败\n");
    80001838:	00001517          	auipc	a0,0x1
    8000183c:	7d050513          	addi	a0,a0,2000 # 80003008 <etext+0x1008>
    80001840:	9acff0ef          	jal	800009ec <printf>
    if (pt == 0) return;
    80001844:	8522                	mv	a0,s0
    80001846:	ac5ff0ef          	jal	8000130a <destroy_pagetable.part.0>
        return 0;
    8000184a:	4401                	li	s0,0
    8000184c:	64a2                	ld	s1,8(sp)
    8000184e:	b7c5                	j	8000182e <kvmmake+0xd4>
        printf("kvmmake: 内核数据段映射失败\n");
    80001850:	00002517          	auipc	a0,0x2
    80001854:	80050513          	addi	a0,a0,-2048 # 80003050 <etext+0x1050>
    80001858:	994ff0ef          	jal	800009ec <printf>
        goto fail;
    8000185c:	b7e5                	j	80001844 <kvmmake+0xea>
               (void*)va, (void*)PTE2PA(*pte));
    8000185e:	83a9                	srli	a5,a5,0xa
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
    80001860:	00c79613          	slli	a2,a5,0xc
    80001864:	100005b7          	lui	a1,0x10000
    80001868:	00001517          	auipc	a0,0x1
    8000186c:	60050513          	addi	a0,a0,1536 # 80002e68 <etext+0xe68>
    80001870:	97cff0ef          	jal	800009ec <printf>
        printf("kvmmake: UART映射失败\n");
    80001874:	00001517          	auipc	a0,0x1
    80001878:	77450513          	addi	a0,a0,1908 # 80002fe8 <etext+0xfe8>
    8000187c:	970ff0ef          	jal	800009ec <printf>
        goto fail;
    80001880:	b7d1                	j	80001844 <kvmmake+0xea>
        printf("map_page: walk_create失败\n");
    80001882:	00001517          	auipc	a0,0x1
    80001886:	5c650513          	addi	a0,a0,1478 # 80002e48 <etext+0xe48>
    8000188a:	962ff0ef          	jal	800009ec <printf>
        return -1;
    8000188e:	b7dd                	j	80001874 <kvmmake+0x11a>

0000000080001890 <kvminit>:

// 初始化内核虚拟内存
void kvminit(void) {
    80001890:	1141                	addi	sp,sp,-16
    printf("=== 初始化内核虚拟内存 ===\n");
    80001892:	00002517          	auipc	a0,0x2
    80001896:	80650513          	addi	a0,a0,-2042 # 80003098 <etext+0x1098>
void kvminit(void) {
    8000189a:	e406                	sd	ra,8(sp)
    printf("=== 初始化内核虚拟内存 ===\n");
    8000189c:	950ff0ef          	jal	800009ec <printf>
    
    // 创建内核页表
    kernel_pagetable = kvmmake();
    800018a0:	ebbff0ef          	jal	8000175a <kvmmake>
    800018a4:	0000b797          	auipc	a5,0xb
    800018a8:	76a7b623          	sd	a0,1900(a5) # 8000d010 <kernel_pagetable>
    if (kernel_pagetable == 0) {
    800018ac:	c105                	beqz	a0,800018cc <kvminit+0x3c>
        printf("kvminit: 内核页表创建失败!\n");
        return;
    }
    
    printf("内核页表地址: 0x%p\n", kernel_pagetable);
    800018ae:	85aa                	mv	a1,a0
    800018b0:	00002517          	auipc	a0,0x2
    800018b4:	83850513          	addi	a0,a0,-1992 # 800030e8 <etext+0x10e8>
    800018b8:	934ff0ef          	jal	800009ec <printf>
    printf("内核虚拟内存初始化完成\n");
}
    800018bc:	60a2                	ld	ra,8(sp)
    printf("内核虚拟内存初始化完成\n");
    800018be:	00002517          	auipc	a0,0x2
    800018c2:	84a50513          	addi	a0,a0,-1974 # 80003108 <etext+0x1108>
}
    800018c6:	0141                	addi	sp,sp,16
    printf("内核虚拟内存初始化完成\n");
    800018c8:	924ff06f          	j	800009ec <printf>
}
    800018cc:	60a2                	ld	ra,8(sp)
        printf("kvminit: 内核页表创建失败!\n");
    800018ce:	00001517          	auipc	a0,0x1
    800018d2:	7f250513          	addi	a0,a0,2034 # 800030c0 <etext+0x10c0>
}
    800018d6:	0141                	addi	sp,sp,16
        printf("kvminit: 内核页表创建失败!\n");
    800018d8:	914ff06f          	j	800009ec <printf>

00000000800018dc <kvminithart>:

// 激活内核页表（启用虚拟内存）
void kvminithart(void) {
    800018dc:	1101                	addi	sp,sp,-32
    printf("=== 激活虚拟内存系统 ===\n");
    800018de:	00002517          	auipc	a0,0x2
    800018e2:	85250513          	addi	a0,a0,-1966 # 80003130 <etext+0x1130>
void kvminithart(void) {
    800018e6:	ec06                	sd	ra,24(sp)
    printf("=== 激活虚拟内存系统 ===\n");
    800018e8:	904ff0ef          	jal	800009ec <printf>
    
    if (kernel_pagetable == 0) {
    800018ec:	0000b717          	auipc	a4,0xb
    800018f0:	72473703          	ld	a4,1828(a4) # 8000d010 <kernel_pagetable>
    800018f4:	cf39                	beqz	a4,80001952 <kvminithart+0x76>
  asm volatile("csrr %0, satp" : "=r" (x) );
    800018f6:	180025f3          	csrr	a1,satp
        printf("kvminithart: 内核页表未初始化!\n");
        return;
    }
    
    printf("当前satp寄存器值: 0x%p\n", (void*)r_satp());
    800018fa:	00002517          	auipc	a0,0x2
    800018fe:	88650513          	addi	a0,a0,-1914 # 80003180 <etext+0x1180>
    80001902:	8eaff0ef          	jal	800009ec <printf>
// 内存屏障指令 - 刷新TLB
static inline void
sfence_vma()
{
  // 刷新TLB的全部条目
  asm volatile("sfence.vma zero, zero");
    80001906:	12000073          	sfence.vma
    
    // 刷新TLB
    sfence_vma();
    
    // 设置satp寄存器，启用Sv39分页模式
    uint64 satp_val = MAKE_SATP(kernel_pagetable);
    8000190a:	0000b597          	auipc	a1,0xb
    8000190e:	7065b583          	ld	a1,1798(a1) # 8000d010 <kernel_pagetable>
    80001912:	57fd                	li	a5,-1
    80001914:	17fe                	slli	a5,a5,0x3f
    80001916:	81b1                	srli	a1,a1,0xc
    80001918:	8ddd                	or	a1,a1,a5
    printf("设置satp寄存器: 0x%p\n", (void*)satp_val);
    8000191a:	00002517          	auipc	a0,0x2
    8000191e:	88650513          	addi	a0,a0,-1914 # 800031a0 <etext+0x11a0>
    80001922:	e42e                	sd	a1,8(sp)
    80001924:	8c8ff0ef          	jal	800009ec <printf>
  asm volatile("csrw satp, %0" : : "r" (x));
    80001928:	65a2                	ld	a1,8(sp)
    8000192a:	18059073          	csrw	satp,a1
  asm volatile("sfence.vma zero, zero");
    8000192e:	12000073          	sfence.vma
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001932:	180025f3          	csrr	a1,satp
    w_satp(satp_val);
    
    // 再次刷新TLB
    sfence_vma();
    
    printf("新的satp寄存器值: 0x%p\n", (void*)r_satp());
    80001936:	00002517          	auipc	a0,0x2
    8000193a:	88a50513          	addi	a0,a0,-1910 # 800031c0 <etext+0x11c0>
    8000193e:	8aeff0ef          	jal	800009ec <printf>
    printf("虚拟内存系统已激活!\n");
    80001942:	60e2                	ld	ra,24(sp)
    printf("虚拟内存系统已激活!\n");
    80001944:	00002517          	auipc	a0,0x2
    80001948:	89c50513          	addi	a0,a0,-1892 # 800031e0 <etext+0x11e0>
    8000194c:	6105                	addi	sp,sp,32
    printf("虚拟内存系统已激活!\n");
    8000194e:	89eff06f          	j	800009ec <printf>
    80001952:	60e2                	ld	ra,24(sp)
        printf("kvminithart: 内核页表未初始化!\n");
    80001954:	00002517          	auipc	a0,0x2
    80001958:	80450513          	addi	a0,a0,-2044 # 80003158 <etext+0x1158>
    8000195c:	6105                	addi	sp,sp,32
        printf("kvminithart: 内核页表未初始化!\n");
    8000195e:	88eff06f          	j	800009ec <printf>
	...

0000000080001970 <kernelvec>:
        .align 4

kernelvec:
        # 为保存寄存器预留空间
        # 在栈上保存256字节用于存储所有寄存器
        addi sp, sp, -256
    80001970:	7111                	addi	sp,sp,-256

        # 保存调用者保存的寄存器 (caller-saved registers)
        sd ra, 0(sp)
    80001972:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)    # 不保存sp，因为我们在使用它
        sd gp, 16(sp)
    80001974:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80001976:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80001978:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000197a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000197c:	f81e                	sd	t2,48(sp)
        sd s0, 56(sp)
    8000197e:	fc22                	sd	s0,56(sp)
        sd s1, 64(sp)
    80001980:	e0a6                	sd	s1,64(sp)
        sd a0, 72(sp)
    80001982:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80001984:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80001986:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80001988:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    8000198a:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    8000198c:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000198e:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80001990:	e146                	sd	a7,128(sp)
        sd s2, 136(sp)
    80001992:	e54a                	sd	s2,136(sp)
        sd s3, 144(sp)
    80001994:	e94e                	sd	s3,144(sp)
        sd s4, 152(sp)
    80001996:	ed52                	sd	s4,152(sp)
        sd s5, 160(sp)
    80001998:	f156                	sd	s5,160(sp)
        sd s6, 168(sp)
    8000199a:	f55a                	sd	s6,168(sp)
        sd s7, 176(sp)
    8000199c:	f95e                	sd	s7,176(sp)
        sd s8, 184(sp)
    8000199e:	fd62                	sd	s8,184(sp)
        sd s9, 192(sp)
    800019a0:	e1e6                	sd	s9,192(sp)
        sd s10, 200(sp)
    800019a2:	e5ea                	sd	s10,200(sp)
        sd s11, 208(sp)
    800019a4:	e9ee                	sd	s11,208(sp)
        sd t3, 216(sp)
    800019a6:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800019a8:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800019aa:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800019ac:	f9fe                	sd	t6,240(sp)

        # 调用C语言的trap处理函数
        call kerneltrap
    800019ae:	e7eff0ef          	jal	8000102c <kerneltrap>

        # 恢复寄存器
        ld ra, 0(sp)
    800019b2:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)    # 不恢复sp
        ld gp, 16(sp)
    800019b4:	61c2                	ld	gp,16(sp)
        # 不恢复tp (hartid)，避免CPU切换问题
        ld t0, 32(sp)
    800019b6:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800019b8:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800019ba:	73c2                	ld	t2,48(sp)
        ld s0, 56(sp)
    800019bc:	7462                	ld	s0,56(sp)
        ld s1, 64(sp)
    800019be:	6486                	ld	s1,64(sp)
        ld a0, 72(sp)
    800019c0:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800019c2:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800019c4:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800019c6:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800019c8:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800019ca:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800019cc:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800019ce:	688a                	ld	a7,128(sp)
        ld s2, 136(sp)
    800019d0:	692a                	ld	s2,136(sp)
        ld s3, 144(sp)
    800019d2:	69ca                	ld	s3,144(sp)
        ld s4, 152(sp)
    800019d4:	6a6a                	ld	s4,152(sp)
        ld s5, 160(sp)
    800019d6:	7a8a                	ld	s5,160(sp)
        ld s6, 168(sp)
    800019d8:	7b2a                	ld	s6,168(sp)
        ld s7, 176(sp)
    800019da:	7bca                	ld	s7,176(sp)
        ld s8, 184(sp)
    800019dc:	7c6a                	ld	s8,184(sp)
        ld s9, 192(sp)
    800019de:	6c8e                	ld	s9,192(sp)
        ld s10, 200(sp)
    800019e0:	6d2e                	ld	s10,200(sp)
        ld s11, 208(sp)
    800019e2:	6dce                	ld	s11,208(sp)
        ld t3, 216(sp)
    800019e4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800019e6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800019e8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800019ea:	7fce                	ld	t6,240(sp)

        # 恢复栈指针
        addi sp, sp, 256
    800019ec:	6111                	addi	sp,sp,256
        # 从trap返回
        # sret指令会：
        # 1. 将PC设置为sepc的值
        # 2. 将特权级设置为sstatus.SPP
        # 3. 将sstatus.SPIE复制到sstatus.SIE
        sret
    800019ee:	10200073          	sret
    800019f2:	00000013          	nop
    800019f6:	00000013          	nop
    800019fa:	00000013          	nop
	...
