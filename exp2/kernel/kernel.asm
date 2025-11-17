
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
.section .text.boot  # 放在代码段最开始
.global _entry       # 导出符号，使其对链接器可见

_entry:
    # 设置栈指针
    la sp, stack_top  # 加载栈顶地址到sp寄存器
    80000000:	00002117          	auipc	sp,0x2
    80000004:	00010113          	mv	sp,sp

    # 清零BSS段
    la a0, bss_start  # BSS段开始地址
    80000008:	00001517          	auipc	a0,0x1
    8000000c:	cc850513          	addi	a0,a0,-824 # 80000cd0 <bss_end>
    la a1, bss_end    # BSS段结束地址
    80000010:	00001597          	auipc	a1,0x1
    80000014:	cc058593          	addi	a1,a1,-832 # 80000cd0 <bss_end>
    
    # 当BSS段开始等于结束时，说明没有BSS段，直接跳过清零
    beq a0, a1, 2f
    80000018:	00b50763          	beq	a0,a1,80000026 <_entry+0x26>

1:  # 循环清零BSS段
    sw zero, (a0)     # 将0存储到当前地址
    8000001c:	00052023          	sw	zero,0(a0)
    addi a0, a0, 4    # 地址+4
    80000020:	0511                	addi	a0,a0,4
    blt a0, a1, 1b    # 如果未到结束地址，继续循环
    80000022:	feb54de3          	blt	a0,a1,8000001c <_entry+0x1c>

2:  # 清零完成，跳转到C入口函数
    call start        # 调用C函数入口点
    80000026:	2f6000ef          	jal	8000031c <start>

    # 不应该从start函数返回，但如果返回了则进入死循环
    8000002a:	a001                	j	8000002a <_entry+0x2a>

000000008000002c <console_init>:
// 初始化控制台
void 
console_init(void) 
{
    // 初始化UART
    uart_init();
    8000002c:	09f0006f          	j	800008ca <uart_init>

0000000080000030 <console_putc>:
}

// 输出单个字符到控制台
void 
console_putc(char c) 
{
    80000030:	1101                	addi	sp,sp,-32 # 80001fe0 <bss_end+0x1310>
    80000032:	ec06                	sd	ra,24(sp)
    // 处理特殊字符
    if (c == '\n') {
    80000034:	4729                	li	a4,10
    80000036:	02e50563          	beq	a0,a4,80000060 <console_putc+0x30>
        // 换行符需要CR+LF
        uart_putc('\r');
        uart_putc('\n');
    } else if (c == '\b') {
    8000003a:	4721                	li	a4,8
    8000003c:	00e50663          	beq	a0,a4,80000048 <console_putc+0x18>
        uart_putc('\b');
    } else {
        // 普通字符直接输出
        uart_putc(c);
    }
}
    80000040:	60e2                	ld	ra,24(sp)
    80000042:	6105                	addi	sp,sp,32
        uart_putc('\b');
    80000044:	0a30006f          	j	800008e6 <uart_putc>
    80000048:	e42a                	sd	a0,8(sp)
        uart_putc('\b');
    8000004a:	09d000ef          	jal	800008e6 <uart_putc>
        uart_putc(' ');
    8000004e:	02000513          	li	a0,32
    80000052:	095000ef          	jal	800008e6 <uart_putc>
        uart_putc('\b');
    80000056:	6522                	ld	a0,8(sp)
}
    80000058:	60e2                	ld	ra,24(sp)
    8000005a:	6105                	addi	sp,sp,32
        uart_putc('\b');
    8000005c:	08b0006f          	j	800008e6 <uart_putc>
    80000060:	e42a                	sd	a0,8(sp)
        uart_putc('\r');
    80000062:	4535                	li	a0,13
    80000064:	b7fd                	j	80000052 <console_putc+0x22>

0000000080000066 <console_puts>:

// 输出字符串到控制台
void 
console_puts(const char *s) 
{
    while (*s != '\0') {
    80000066:	00054783          	lbu	a5,0(a0)
    8000006a:	cfb9                	beqz	a5,800000c8 <console_puts+0x62>
{
    8000006c:	1101                	addi	sp,sp,-32
    8000006e:	e822                	sd	s0,16(sp)
    80000070:	e426                	sd	s1,8(sp)
    80000072:	e04a                	sd	s2,0(sp)
    80000074:	ec06                	sd	ra,24(sp)
    80000076:	842a                	mv	s0,a0
    if (c == '\n') {
    80000078:	4929                	li	s2,10
    } else if (c == '\b') {
    8000007a:	44a1                	li	s1,8
    8000007c:	a031                	j	80000088 <console_puts+0x22>
        uart_putc(c);
    8000007e:	069000ef          	jal	800008e6 <uart_putc>
    while (*s != '\0') {
    80000082:	00044783          	lbu	a5,0(s0)
    80000086:	c785                	beqz	a5,800000ae <console_puts+0x48>
        uart_putc(c);
    80000088:	853e                	mv	a0,a5
        console_putc(*s++);
    8000008a:	0405                	addi	s0,s0,1
    if (c == '\n') {
    8000008c:	03278763          	beq	a5,s2,800000ba <console_puts+0x54>
    } else if (c == '\b') {
    80000090:	fe9797e3          	bne	a5,s1,8000007e <console_puts+0x18>
        uart_putc('\b');
    80000094:	8526                	mv	a0,s1
    80000096:	051000ef          	jal	800008e6 <uart_putc>
        uart_putc(' ');
    8000009a:	02000513          	li	a0,32
    8000009e:	049000ef          	jal	800008e6 <uart_putc>
        uart_putc('\b');
    800000a2:	8526                	mv	a0,s1
    800000a4:	043000ef          	jal	800008e6 <uart_putc>
    while (*s != '\0') {
    800000a8:	00044783          	lbu	a5,0(s0)
    800000ac:	fff1                	bnez	a5,80000088 <console_puts+0x22>
    }
}
    800000ae:	60e2                	ld	ra,24(sp)
    800000b0:	6442                	ld	s0,16(sp)
    800000b2:	64a2                	ld	s1,8(sp)
    800000b4:	6902                	ld	s2,0(sp)
    800000b6:	6105                	addi	sp,sp,32
    800000b8:	8082                	ret
        uart_putc('\r');
    800000ba:	4535                	li	a0,13
    800000bc:	02b000ef          	jal	800008e6 <uart_putc>
        uart_putc('\n');
    800000c0:	854a                	mv	a0,s2
    800000c2:	025000ef          	jal	800008e6 <uart_putc>
}
    800000c6:	bf75                	j	80000082 <console_puts+0x1c>
    800000c8:	8082                	ret

00000000800000ca <clear_screen>:

// 清除屏幕 - ANSI转义序列
void 
clear_screen(void) 
{
    800000ca:	1141                	addi	sp,sp,-16
    // ESC [ 2 J - 清除整个屏幕
    // ESC [ H - 光标移动到左上角 (1,1)
    console_puts("\033[2J");
    800000cc:	00001517          	auipc	a0,0x1
    800000d0:	86450513          	addi	a0,a0,-1948 # 80000930 <uart_puts+0x30>
{
    800000d4:	e406                	sd	ra,8(sp)
    console_puts("\033[2J");
    800000d6:	f91ff0ef          	jal	80000066 <console_puts>
    console_puts("\033[H");
}
    800000da:	60a2                	ld	ra,8(sp)
    console_puts("\033[H");
    800000dc:	00001517          	auipc	a0,0x1
    800000e0:	85c50513          	addi	a0,a0,-1956 # 80000938 <uart_puts+0x38>
}
    800000e4:	0141                	addi	sp,sp,16
    console_puts("\033[H");
    800000e6:	b741                	j	80000066 <console_puts>

00000000800000e8 <console_goto_xy>:
    // 缓冲区用于构造ANSI序列
    char buf[16];
    char *p = buf;
    
    // ESC [ row ; col H
    *p++ = '\033';
    800000e8:	6799                	lui	a5,0x6
{
    800000ea:	7139                	addi	sp,sp,-64
    *p++ = '\033';
    800000ec:	b1b78793          	addi	a5,a5,-1253 # 5b1b <_entry-0x7fffa4e5>
    int temp = y;
    char y_digits[10];
    int y_idx = 0;
    
    do {
        y_digits[y_idx++] = (temp % 10) + '0';
    800000f0:	66666337          	lui	t1,0x66666
{
    800000f4:	fc06                	sd	ra,56(sp)
    *p++ = '\033';
    800000f6:	02f11023          	sh	a5,32(sp)
    int temp = y;
    800000fa:	880a                	mv	a6,sp
{
    800000fc:	86aa                	mv	a3,a0
    *p++ = '\033';
    800000fe:	860a                	mv	a2,sp
        y_digits[y_idx++] = (temp % 10) + '0';
    80000100:	66730313          	addi	t1,t1,1639 # 66666667 <_entry-0x19999999>
        temp /= 10;
    } while (temp > 0);
    80000104:	4e25                	li	t3,9
        y_digits[y_idx++] = (temp % 10) + '0';
    80000106:	026587b3          	mul	a5,a1,t1
    8000010a:	41f5d71b          	sraiw	a4,a1,0x1f
    8000010e:	852e                	mv	a0,a1
    80000110:	88b2                	mv	a7,a2
    } while (temp > 0);
    80000112:	0605                	addi	a2,a2,1
        y_digits[y_idx++] = (temp % 10) + '0';
    80000114:	9789                	srai	a5,a5,0x22
    80000116:	9f99                	subw	a5,a5,a4
    80000118:	0027971b          	slliw	a4,a5,0x2
    8000011c:	9f3d                	addw	a4,a4,a5
    8000011e:	0017171b          	slliw	a4,a4,0x1
    80000122:	9d99                	subw	a1,a1,a4
    80000124:	0305859b          	addiw	a1,a1,48
    80000128:	feb60fa3          	sb	a1,-1(a2)
        temp /= 10;
    8000012c:	85be                	mv	a1,a5
    } while (temp > 0);
    8000012e:	fcae4ce3          	blt	t3,a0,80000106 <console_goto_xy+0x1e>
    80000132:	410888bb          	subw	a7,a7,a6
    80000136:	02089593          	slli	a1,a7,0x20
    8000013a:	9181                	srli	a1,a1,0x20
    8000013c:	1008                	addi	a0,sp,32
    *p++ = '[';
    8000013e:	02210313          	addi	t1,sp,34
    80000142:	058d                	addi	a1,a1,3
    80000144:	01180733          	add	a4,a6,a7
    80000148:	95aa                	add	a1,a1,a0
    8000014a:	879a                	mv	a5,t1
    
    // 反向输出
    while (y_idx > 0) {
        *p++ = y_digits[--y_idx];
    8000014c:	00074603          	lbu	a2,0(a4)
    80000150:	0785                	addi	a5,a5,1
    while (y_idx > 0) {
    80000152:	177d                	addi	a4,a4,-1
        *p++ = y_digits[--y_idx];
    80000154:	fec78fa3          	sb	a2,-1(a5)
    while (y_idx > 0) {
    80000158:	feb79ae3          	bne	a5,a1,8000014c <console_goto_xy+0x64>
    8000015c:	9346                	add	t1,t1,a7
    }
    
    *p++ = ';';
    8000015e:	03b00793          	li	a5,59
    80000162:	080c                	addi	a1,sp,16
    temp = x;
    char x_digits[10];
    int x_idx = 0;
    
    do {
        x_digits[x_idx++] = (temp % 10) + '0';
    80000164:	66666e37          	lui	t3,0x66666
    *p++ = ';';
    80000168:	00f300a3          	sb	a5,1(t1)
    8000016c:	862e                	mv	a2,a1
        x_digits[x_idx++] = (temp % 10) + '0';
    8000016e:	667e0e13          	addi	t3,t3,1639 # 66666667 <_entry-0x19999999>
        temp /= 10;
    } while (temp > 0);
    80000172:	4ea5                	li	t4,9
        x_digits[x_idx++] = (temp % 10) + '0';
    80000174:	03c68733          	mul	a4,a3,t3
    80000178:	41f6d79b          	sraiw	a5,a3,0x1f
    8000017c:	8836                	mv	a6,a3
    8000017e:	88b2                	mv	a7,a2
    } while (temp > 0);
    80000180:	0605                	addi	a2,a2,1
        x_digits[x_idx++] = (temp % 10) + '0';
    80000182:	9709                	srai	a4,a4,0x22
    80000184:	9f1d                	subw	a4,a4,a5
    80000186:	0027179b          	slliw	a5,a4,0x2
    8000018a:	9fb9                	addw	a5,a5,a4
    8000018c:	0017979b          	slliw	a5,a5,0x1
    80000190:	40f687bb          	subw	a5,a3,a5
    80000194:	0307879b          	addiw	a5,a5,48
    80000198:	fef60fa3          	sb	a5,-1(a2)
        temp /= 10;
    8000019c:	86ba                	mv	a3,a4
    } while (temp > 0);
    8000019e:	fd0ecbe3          	blt	t4,a6,80000174 <console_goto_xy+0x8c>
    800001a2:	40b888bb          	subw	a7,a7,a1
    800001a6:	02089693          	slli	a3,a7,0x20
    800001aa:	9281                	srli	a3,a3,0x20
    800001ac:	01158733          	add	a4,a1,a7
    800001b0:	00330593          	addi	a1,t1,3
    800001b4:	95b6                	add	a1,a1,a3
    *p++ = ';';
    800001b6:	00230793          	addi	a5,t1,2
    
    // 反向输出
    while (x_idx > 0) {
        *p++ = x_digits[--x_idx];
    800001ba:	00074603          	lbu	a2,0(a4)
    800001be:	86be                	mv	a3,a5
    800001c0:	0785                	addi	a5,a5,1
    800001c2:	00c68023          	sb	a2,0(a3)
    while (x_idx > 0) {
    800001c6:	177d                	addi	a4,a4,-1
    800001c8:	feb799e3          	bne	a5,a1,800001ba <console_goto_xy+0xd2>
    800001cc:	9346                	add	t1,t1,a7
    }
    
    *p++ = 'H';
    800001ce:	04800793          	li	a5,72
    *p = '\0';
    800001d2:	00030223          	sb	zero,4(t1)
    *p++ = 'H';
    800001d6:	00f301a3          	sb	a5,3(t1)
    
    // 发送序列
    console_puts(buf);
    800001da:	e8dff0ef          	jal	80000066 <console_puts>
    800001de:	70e2                	ld	ra,56(sp)
    800001e0:	6121                	addi	sp,sp,64
    800001e2:	8082                	ret

00000000800001e4 <test_printf_basic>:
#include "types.h"
#include "printf.h"
#include "console.h"

// 测试printf基本功能
void test_printf_basic() {
    800001e4:	1141                	addi	sp,sp,-16
    printf("测试整数: %d\n", 42);
    800001e6:	02a00593          	li	a1,42
    800001ea:	00000517          	auipc	a0,0x0
    800001ee:	75650513          	addi	a0,a0,1878 # 80000940 <uart_puts+0x40>
void test_printf_basic() {
    800001f2:	e406                	sd	ra,8(sp)
    printf("测试整数: %d\n", 42);
    800001f4:	2a2000ef          	jal	80000496 <printf>
    printf("测试负数: %d\n", -123);
    800001f8:	f8500593          	li	a1,-123
    800001fc:	00000517          	auipc	a0,0x0
    80000200:	75c50513          	addi	a0,a0,1884 # 80000958 <uart_puts+0x58>
    80000204:	292000ef          	jal	80000496 <printf>
    printf("测试零值: %d\n", 0);
    80000208:	4581                	li	a1,0
    8000020a:	00000517          	auipc	a0,0x0
    8000020e:	76650513          	addi	a0,a0,1894 # 80000970 <uart_puts+0x70>
    80000212:	284000ef          	jal	80000496 <printf>
    printf("测试十六进制: 0x%x\n", 0xABC);
    80000216:	6585                	lui	a1,0x1
    80000218:	abc58593          	addi	a1,a1,-1348 # abc <_entry-0x7ffff544>
    8000021c:	00000517          	auipc	a0,0x0
    80000220:	76c50513          	addi	a0,a0,1900 # 80000988 <uart_puts+0x88>
    80000224:	272000ef          	jal	80000496 <printf>
    printf("测试字符串: %s\n", "你好，世界");
    80000228:	00000597          	auipc	a1,0x0
    8000022c:	78058593          	addi	a1,a1,1920 # 800009a8 <uart_puts+0xa8>
    80000230:	00000517          	auipc	a0,0x0
    80000234:	78850513          	addi	a0,a0,1928 # 800009b8 <uart_puts+0xb8>
    80000238:	25e000ef          	jal	80000496 <printf>
    printf("测试字符: %c\n", 'X');
    8000023c:	05800593          	li	a1,88
    80000240:	00000517          	auipc	a0,0x0
    80000244:	79050513          	addi	a0,a0,1936 # 800009d0 <uart_puts+0xd0>
    80000248:	24e000ef          	jal	80000496 <printf>
    printf("测试百分号: %%\n");
}
    8000024c:	60a2                	ld	ra,8(sp)
    printf("测试百分号: %%\n");
    8000024e:	00000517          	auipc	a0,0x0
    80000252:	79a50513          	addi	a0,a0,1946 # 800009e8 <uart_puts+0xe8>
}
    80000256:	0141                	addi	sp,sp,16
    printf("测试百分号: %%\n");
    80000258:	ac3d                	j	80000496 <printf>

000000008000025a <test_printf_edge_cases>:

// 测试printf边缘情况
void test_printf_edge_cases() {
    8000025a:	1141                	addi	sp,sp,-16
    8000025c:	e022                	sd	s0,0(sp)
    printf("INT_MAX: %d\n", 2147483647);
    8000025e:	80000437          	lui	s0,0x80000
    80000262:	fff44593          	not	a1,s0
    80000266:	00000517          	auipc	a0,0x0
    8000026a:	79a50513          	addi	a0,a0,1946 # 80000a00 <uart_puts+0x100>
void test_printf_edge_cases() {
    8000026e:	e406                	sd	ra,8(sp)
    printf("INT_MAX: %d\n", 2147483647);
    80000270:	226000ef          	jal	80000496 <printf>
    printf("INT_MIN: %d\n", -2147483648);
    80000274:	85a2                	mv	a1,s0
    80000276:	00000517          	auipc	a0,0x0
    8000027a:	79a50513          	addi	a0,a0,1946 # 80000a10 <uart_puts+0x110>
    8000027e:	218000ef          	jal	80000496 <printf>
    printf("NULL字符串: %s\n", (char*)0);
    80000282:	4581                	li	a1,0
    80000284:	00000517          	auipc	a0,0x0
    80000288:	79c50513          	addi	a0,a0,1948 # 80000a20 <uart_puts+0x120>
    8000028c:	20a000ef          	jal	80000496 <printf>
    printf("空字符串: %s\n", "");
}
    80000290:	6402                	ld	s0,0(sp)
    80000292:	60a2                	ld	ra,8(sp)
    printf("空字符串: %s\n", "");
    80000294:	00000597          	auipc	a1,0x0
    80000298:	7dc58593          	addi	a1,a1,2012 # 80000a70 <uart_puts+0x170>
    8000029c:	00000517          	auipc	a0,0x0
    800002a0:	79c50513          	addi	a0,a0,1948 # 80000a38 <uart_puts+0x138>
}
    800002a4:	0141                	addi	sp,sp,16
    printf("空字符串: %s\n", "");
    800002a6:	aac5                	j	80000496 <printf>

00000000800002a8 <test_color_output>:

// 测试颜色输出
void test_color_output() {
    800002a8:	1141                	addi	sp,sp,-16
    printf_color(1, "红色文本\n");
    800002aa:	00000597          	auipc	a1,0x0
    800002ae:	7a658593          	addi	a1,a1,1958 # 80000a50 <uart_puts+0x150>
    800002b2:	4505                	li	a0,1
void test_color_output() {
    800002b4:	e406                	sd	ra,8(sp)
    printf_color(1, "红色文本\n");
    800002b6:	4c4000ef          	jal	8000077a <printf_color>
    printf_color(2, "绿色文本 %d\n", 123);
    800002ba:	07b00613          	li	a2,123
    800002be:	00000597          	auipc	a1,0x0
    800002c2:	7a258593          	addi	a1,a1,1954 # 80000a60 <uart_puts+0x160>
    800002c6:	4509                	li	a0,2
    800002c8:	4b2000ef          	jal	8000077a <printf_color>
    printf_color(3, "黄色文本 %s\n", "测试");
    800002cc:	00000597          	auipc	a1,0x0
    800002d0:	7b458593          	addi	a1,a1,1972 # 80000a80 <uart_puts+0x180>
    800002d4:	00000617          	auipc	a2,0x0
    800002d8:	7a460613          	addi	a2,a2,1956 # 80000a78 <uart_puts+0x178>
    800002dc:	450d                	li	a0,3
    800002de:	49c000ef          	jal	8000077a <printf_color>
    printf_color(4, "蓝色文本\n");
}
    800002e2:	60a2                	ld	ra,8(sp)
    printf_color(4, "蓝色文本\n");
    800002e4:	00000597          	auipc	a1,0x0
    800002e8:	7b458593          	addi	a1,a1,1972 # 80000a98 <uart_puts+0x198>
    800002ec:	4511                	li	a0,4
}
    800002ee:	0141                	addi	sp,sp,16
    printf_color(4, "蓝色文本\n");
    800002f0:	a169                	j	8000077a <printf_color>

00000000800002f2 <test_clear_screen>:

// 测试清屏功能
void test_clear_screen() {
    800002f2:	1141                	addi	sp,sp,-16
    printf("按任意键清屏...\n");
    800002f4:	00000517          	auipc	a0,0x0
    800002f8:	7b450513          	addi	a0,a0,1972 # 80000aa8 <uart_puts+0x1a8>
void test_clear_screen() {
    800002fc:	e406                	sd	ra,8(sp)
    printf("按任意键清屏...\n");
    800002fe:	198000ef          	jal	80000496 <printf>
    // 在实际系统中，这里应该等待键盘输入
    
    clear_screen();
    80000302:	dc9ff0ef          	jal	800000ca <clear_screen>
    console_goto_xy(10, 6);
    80000306:	4529                	li	a0,10
    80000308:	4599                	li	a1,6
    8000030a:	ddfff0ef          	jal	800000e8 <console_goto_xy>
    printf("这是清屏后在指定位置(10,6)的输出\n");
}
    8000030e:	60a2                	ld	ra,8(sp)
    printf("这是清屏后在指定位置(10,6)的输出\n");
    80000310:	00000517          	auipc	a0,0x0
    80000314:	7b050513          	addi	a0,a0,1968 # 80000ac0 <uart_puts+0x1c0>
}
    80000318:	0141                	addi	sp,sp,16
    printf("这是清屏后在指定位置(10,6)的输出\n");
    8000031a:	aab5                	j	80000496 <printf>

000000008000031c <start>:

// C语言入口点，从entry.S跳转而来
void
start(void)
{
    8000031c:	1141                	addi	sp,sp,-16
    8000031e:	e406                	sd	ra,8(sp)
    // 初始化printf系统
    printf_init();
    80000320:	5a6000ef          	jal	800008c6 <printf_init>
    
    // 清屏并输出欢迎信息
    clear_screen();
    80000324:	da7ff0ef          	jal	800000ca <clear_screen>
    printf("===================================\n");
    80000328:	00000517          	auipc	a0,0x0
    8000032c:	7c850513          	addi	a0,a0,1992 # 80000af0 <uart_puts+0x1f0>
    80000330:	166000ef          	jal	80000496 <printf>
    printf("      增强版内核 printf 测试       \n");
    80000334:	00000517          	auipc	a0,0x0
    80000338:	7e450513          	addi	a0,a0,2020 # 80000b18 <uart_puts+0x218>
    8000033c:	15a000ef          	jal	80000496 <printf>
    printf("===================================\n\n");
    80000340:	00001517          	auipc	a0,0x1
    80000344:	80850513          	addi	a0,a0,-2040 # 80000b48 <uart_puts+0x248>
    80000348:	14e000ef          	jal	80000496 <printf>
    
    // 测试基本功能
    printf("--- 基本功能测试 ---\n");
    8000034c:	00001517          	auipc	a0,0x1
    80000350:	82450513          	addi	a0,a0,-2012 # 80000b70 <uart_puts+0x270>
    80000354:	142000ef          	jal	80000496 <printf>
    test_printf_basic();
    80000358:	e8dff0ef          	jal	800001e4 <test_printf_basic>
    printf("\n");
    8000035c:	00000517          	auipc	a0,0x0
    80000360:	68450513          	addi	a0,a0,1668 # 800009e0 <uart_puts+0xe0>
    80000364:	132000ef          	jal	80000496 <printf>
    
    // 测试边缘情况
    printf("--- 边缘情况测试 ---\n");
    80000368:	00001517          	auipc	a0,0x1
    8000036c:	82850513          	addi	a0,a0,-2008 # 80000b90 <uart_puts+0x290>
    80000370:	126000ef          	jal	80000496 <printf>
    test_printf_edge_cases();
    80000374:	ee7ff0ef          	jal	8000025a <test_printf_edge_cases>
    printf("\n");
    80000378:	00000517          	auipc	a0,0x0
    8000037c:	66850513          	addi	a0,a0,1640 # 800009e0 <uart_puts+0xe0>
    80000380:	116000ef          	jal	80000496 <printf>
    
    // 测试颜色输出
    printf("--- 颜色输出测试 ---\n");
    80000384:	00001517          	auipc	a0,0x1
    80000388:	82c50513          	addi	a0,a0,-2004 # 80000bb0 <uart_puts+0x2b0>
    8000038c:	10a000ef          	jal	80000496 <printf>
    test_color_output();
    80000390:	f19ff0ef          	jal	800002a8 <test_color_output>
    printf("\n");
    80000394:	00000517          	auipc	a0,0x0
    80000398:	64c50513          	addi	a0,a0,1612 # 800009e0 <uart_puts+0xe0>
    8000039c:	0fa000ef          	jal	80000496 <printf>
    
    // 测试清屏功能
    test_clear_screen();
    800003a0:	f53ff0ef          	jal	800002f2 <test_clear_screen>
    
    // 进入空循环，防止程序退出
    while(1) {
    800003a4:	a001                	j	800003a4 <start+0x88>

00000000800003a6 <print_number>:
#define COLOR_WHITE      7

// 数字转换函数 - 将数字转换为指定进制的字符串
static void 
print_number(long long num, int base, int is_signed) 
{
    800003a6:	7139                	addi	sp,sp,-64
    800003a8:	fc06                	sd	ra,56(sp)
    800003aa:	f822                	sd	s0,48(sp)
    800003ac:	f426                	sd	s1,40(sp)
    int idx = 0;
    unsigned long long unum;
    
    // 处理符号问题
    int negative = 0;
    if (is_signed && num < 0) {
    800003ae:	06055763          	bgez	a0,8000041c <print_number+0x76>
    800003b2:	8a05                	andi	a2,a2,1
    800003b4:	c625                	beqz	a2,8000041c <print_number+0x76>
        negative = 1;
        unum = (unsigned long long)(-num);  // 转为正数处理
    800003b6:	40a00533          	neg	a0,a0
        negative = 1;
    800003ba:	4305                	li	t1,1
    // 处理特殊情况: 0
    if (unum == 0) {
        buf[idx++] = '0';
    } else {
        // 将数字转换为字符，从低位到高位
        while (unum != 0) {
    800003bc:	840a                	mv	s0,sp
    800003be:	868a                	mv	a3,sp
    int idx = 0;
    800003c0:	4701                	li	a4,0
    800003c2:	00001897          	auipc	a7,0x1
    800003c6:	8e688893          	addi	a7,a7,-1818 # 80000ca8 <digits>
            buf[idx++] = digits[unum % base];
    800003ca:	02b577b3          	remu	a5,a0,a1
    800003ce:	882a                	mv	a6,a0
    800003d0:	863a                	mv	a2,a4
        while (unum != 0) {
    800003d2:	0685                	addi	a3,a3,1
            buf[idx++] = digits[unum % base];
    800003d4:	2705                	addiw	a4,a4,1
    800003d6:	97c6                	add	a5,a5,a7
    800003d8:	0007c783          	lbu	a5,0(a5)
            unum /= base;
    800003dc:	02b55533          	divu	a0,a0,a1
            buf[idx++] = digits[unum % base];
    800003e0:	fef68fa3          	sb	a5,-1(a3)
        while (unum != 0) {
    800003e4:	feb873e3          	bgeu	a6,a1,800003ca <print_number+0x24>
        }
    }
    
    // 添加负号（如果需要）
    if (negative) {
    800003e8:	04030263          	beqz	t1,8000042c <print_number+0x86>
        buf[idx++] = '-';
    800003ec:	970a                	add	a4,a4,sp
    800003ee:	02d00793          	li	a5,45
    800003f2:	2609                	addiw	a2,a2,2
    800003f4:	00f70023          	sb	a5,0(a4)
    }
    
    // 反向输出字符
    while (idx > 0) {
    800003f8:	367d                	addiw	a2,a2,-1
    800003fa:	1602                	slli	a2,a2,0x20
    800003fc:	9201                	srli	a2,a2,0x20
    800003fe:	fff10493          	addi	s1,sp,-1
    80000402:	9432                	add	s0,s0,a2
        console_putc(buf[--idx]);
    80000404:	00044503          	lbu	a0,0(s0) # ffffffff80000000 <stack_top+0xfffffffeffffe000>
    while (idx > 0) {
    80000408:	147d                	addi	s0,s0,-1
        console_putc(buf[--idx]);
    8000040a:	c27ff0ef          	jal	80000030 <console_putc>
    while (idx > 0) {
    8000040e:	fe941be3          	bne	s0,s1,80000404 <print_number+0x5e>
    }
}
    80000412:	70e2                	ld	ra,56(sp)
    80000414:	7442                	ld	s0,48(sp)
    80000416:	74a2                	ld	s1,40(sp)
    80000418:	6121                	addi	sp,sp,64
    8000041a:	8082                	ret
    if (unum == 0) {
    8000041c:	e911                	bnez	a0,80000430 <print_number+0x8a>
        buf[idx++] = '0';
    8000041e:	03000793          	li	a5,48
    80000422:	00f10023          	sb	a5,0(sp)
    80000426:	4605                	li	a2,1
    80000428:	840a                	mv	s0,sp
    8000042a:	b7f9                	j	800003f8 <print_number+0x52>
    8000042c:	863a                	mv	a2,a4
    8000042e:	b7e9                	j	800003f8 <print_number+0x52>
    int negative = 0;
    80000430:	4301                	li	t1,0
    80000432:	b769                	j	800003bc <print_number+0x16>

0000000080000434 <print_ptr>:

// 打印指针地址
static void 
print_ptr(uint64 ptr) 
{
    80000434:	7179                	addi	sp,sp,-48
    80000436:	ec26                	sd	s1,24(sp)
    80000438:	84aa                	mv	s1,a0
    console_puts("0x");
    8000043a:	00000517          	auipc	a0,0x0
    8000043e:	79650513          	addi	a0,a0,1942 # 80000bd0 <uart_puts+0x2d0>
{
    80000442:	f022                	sd	s0,32(sp)
    80000444:	f406                	sd	ra,40(sp)
    80000446:	e84a                	sd	s2,16(sp)
    80000448:	e44e                	sd	s3,8(sp)
    // 对于64位指针，我们需要输出16个十六进制数字
    int i;
    int leading_zeros = 1;  // 是否跳过前导零
    
    // 从高位到低位，每4位一组转换为一个十六进制数字
    for (i = 60; i >= 0; i -= 4) {
    8000044a:	03c00413          	li	s0,60
    console_puts("0x");
    8000044e:	c19ff0ef          	jal	80000066 <console_puts>
        int digit = (ptr >> i) & 0xf;
    80000452:	0084d7b3          	srl	a5,s1,s0
    80000456:	8bbd                	andi	a5,a5,15
        
        // 跳过前导零，但至少输出一个0
        if (digit == 0 && leading_zeros && i != 0) {
    80000458:	e799                	bnez	a5,80000466 <print_ptr+0x32>
    8000045a:	c411                	beqz	s0,80000466 <print_ptr+0x32>
    for (i = 60; i >= 0; i -= 4) {
    8000045c:	3471                	addiw	s0,s0,-4
        int digit = (ptr >> i) & 0xf;
    8000045e:	0084d7b3          	srl	a5,s1,s0
    80000462:	8bbd                	andi	a5,a5,15
        if (digit == 0 && leading_zeros && i != 0) {
    80000464:	dbfd                	beqz	a5,8000045a <print_ptr+0x26>
    80000466:	00001997          	auipc	s3,0x1
    8000046a:	84298993          	addi	s3,s3,-1982 # 80000ca8 <digits>
    for (i = 60; i >= 0; i -= 4) {
    8000046e:	5971                	li	s2,-4
    80000470:	a011                	j	80000474 <print_ptr+0x40>
        int digit = (ptr >> i) & 0xf;
    80000472:	8bbd                	andi	a5,a5,15
            continue;
        }
        
        leading_zeros = 0;
        console_putc(digits[digit]);
    80000474:	97ce                	add	a5,a5,s3
    80000476:	0007c503          	lbu	a0,0(a5)
    for (i = 60; i >= 0; i -= 4) {
    8000047a:	3471                	addiw	s0,s0,-4
        console_putc(digits[digit]);
    8000047c:	bb5ff0ef          	jal	80000030 <console_putc>
        int digit = (ptr >> i) & 0xf;
    80000480:	0084d7b3          	srl	a5,s1,s0
    for (i = 60; i >= 0; i -= 4) {
    80000484:	ff2417e3          	bne	s0,s2,80000472 <print_ptr+0x3e>
    }
}
    80000488:	70a2                	ld	ra,40(sp)
    8000048a:	7402                	ld	s0,32(sp)
    8000048c:	64e2                	ld	s1,24(sp)
    8000048e:	6942                	ld	s2,16(sp)
    80000490:	69a2                	ld	s3,8(sp)
    80000492:	6145                	addi	sp,sp,48
    80000494:	8082                	ret

0000000080000496 <printf>:

// 格式化输出到控制台
int 
printf(const char *fmt, ...) 
{
    80000496:	7175                	addi	sp,sp,-144
    80000498:	e0a2                	sd	s0,64(sp)
    8000049a:	fcbe                	sd	a5,120(sp)
    8000049c:	e486                	sd	ra,72(sp)
    8000049e:	f84a                	sd	s2,48(sp)
    800004a0:	ecae                	sd	a1,88(sp)
    800004a2:	f0b2                	sd	a2,96(sp)
    800004a4:	f4b6                	sd	a3,104(sp)
    800004a6:	f8ba                	sd	a4,112(sp)
    800004a8:	e142                	sd	a6,128(sp)
    800004aa:	e546                	sd	a7,136(sp)
    800004ac:	842a                	mv	s0,a0
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
    800004ae:	00054503          	lbu	a0,0(a0)
    va_start(ap, fmt);
    800004b2:	08bc                	addi	a5,sp,88
    800004b4:	e43e                	sd	a5,8(sp)
    for (const char *p = fmt; *p; p++) {
    800004b6:	0e050c63          	beqz	a0,800005ae <printf+0x118>
    800004ba:	f44e                	sd	s3,40(sp)
    800004bc:	f052                	sd	s4,32(sp)
    800004be:	ec56                	sd	s5,24(sp)
    800004c0:	fc26                	sd	s1,56(sp)
    int count = 0;
    800004c2:	4901                	li	s2,0
        if (*p != '%') {
    800004c4:	02500993          	li	s3,37
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
    800004c8:	4ad5                	li	s5,21
    800004ca:	00000a17          	auipc	s4,0x0
    800004ce:	72ea0a13          	addi	s4,s4,1838 # 80000bf8 <uart_puts+0x2f8>
            count++;
    800004d2:	2905                	addiw	s2,s2,1
        if (*p != '%') {
    800004d4:	0b351e63          	bne	a0,s3,80000590 <printf+0xfa>
        switch (*p) {
    800004d8:	00144783          	lbu	a5,1(s0)
        p++;
    800004dc:	00140493          	addi	s1,s0,1
        switch (*p) {
    800004e0:	0b378c63          	beq	a5,s3,80000598 <printf+0x102>
    800004e4:	f9d7879b          	addiw	a5,a5,-99
    800004e8:	0ff7f793          	zext.b	a5,a5
    800004ec:	00fae763          	bltu	s5,a5,800004fa <printf+0x64>
    800004f0:	078a                	slli	a5,a5,0x2
    800004f2:	97d2                	add	a5,a5,s4
    800004f4:	439c                	lw	a5,0(a5)
    800004f6:	97d2                	add	a5,a5,s4
    800004f8:	8782                	jr	a5
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
    800004fa:	02500513          	li	a0,37
    800004fe:	b33ff0ef          	jal	80000030 <console_putc>
                console_putc(*p);
    80000502:	00144503          	lbu	a0,1(s0)
    80000506:	b2bff0ef          	jal	80000030 <console_putc>
    for (const char *p = fmt; *p; p++) {
    8000050a:	0014c503          	lbu	a0,1(s1)
    8000050e:	00148413          	addi	s0,s1,1
    80000512:	f161                	bnez	a0,800004d2 <printf+0x3c>
        count++;
    }
    
    va_end(ap);
    return count;
}
    80000514:	60a6                	ld	ra,72(sp)
    80000516:	6406                	ld	s0,64(sp)
    80000518:	74e2                	ld	s1,56(sp)
    8000051a:	79a2                	ld	s3,40(sp)
    8000051c:	7a02                	ld	s4,32(sp)
    8000051e:	6ae2                	ld	s5,24(sp)
    80000520:	854a                	mv	a0,s2
    80000522:	7942                	ld	s2,48(sp)
    80000524:	6149                	addi	sp,sp,144
    80000526:	8082                	ret
                print_number(va_arg(ap, unsigned int), 16, 0);
    80000528:	67a2                	ld	a5,8(sp)
    8000052a:	4601                	li	a2,0
    8000052c:	45c1                	li	a1,16
    8000052e:	0007e503          	lwu	a0,0(a5)
    80000532:	07a1                	addi	a5,a5,8
    80000534:	e43e                	sd	a5,8(sp)
    80000536:	e71ff0ef          	jal	800003a6 <print_number>
                break;
    8000053a:	bfc1                	j	8000050a <printf+0x74>
                print_number(va_arg(ap, unsigned int), 10, 0);
    8000053c:	67a2                	ld	a5,8(sp)
    8000053e:	4601                	li	a2,0
    80000540:	45a9                	li	a1,10
    80000542:	0007e503          	lwu	a0,0(a5)
    80000546:	07a1                	addi	a5,a5,8
    80000548:	e43e                	sd	a5,8(sp)
    8000054a:	e5dff0ef          	jal	800003a6 <print_number>
                break;
    8000054e:	bf75                	j	8000050a <printf+0x74>
                    const char *s = va_arg(ap, const char *);
    80000550:	67a2                	ld	a5,8(sp)
    80000552:	6388                	ld	a0,0(a5)
    80000554:	07a1                	addi	a5,a5,8
    80000556:	e43e                	sd	a5,8(sp)
                    if (s == 0) {
    80000558:	c521                	beqz	a0,800005a0 <printf+0x10a>
                        console_puts(s);
    8000055a:	b0dff0ef          	jal	80000066 <console_puts>
    8000055e:	b775                	j	8000050a <printf+0x74>
                print_ptr(va_arg(ap, uint64));
    80000560:	67a2                	ld	a5,8(sp)
    80000562:	6388                	ld	a0,0(a5)
    80000564:	07a1                	addi	a5,a5,8
    80000566:	e43e                	sd	a5,8(sp)
    80000568:	ecdff0ef          	jal	80000434 <print_ptr>
                break;
    8000056c:	bf79                	j	8000050a <printf+0x74>
                print_number(va_arg(ap, int), 10, 1);
    8000056e:	67a2                	ld	a5,8(sp)
    80000570:	4605                	li	a2,1
    80000572:	45a9                	li	a1,10
    80000574:	4388                	lw	a0,0(a5)
    80000576:	07a1                	addi	a5,a5,8
    80000578:	e43e                	sd	a5,8(sp)
    8000057a:	e2dff0ef          	jal	800003a6 <print_number>
                break;
    8000057e:	b771                	j	8000050a <printf+0x74>
                console_putc(va_arg(ap, int));
    80000580:	67a2                	ld	a5,8(sp)
    80000582:	0007c503          	lbu	a0,0(a5)
    80000586:	07a1                	addi	a5,a5,8
    80000588:	e43e                	sd	a5,8(sp)
    8000058a:	aa7ff0ef          	jal	80000030 <console_putc>
                break;
    8000058e:	bfb5                	j	8000050a <printf+0x74>
            console_putc(*p);
    80000590:	aa1ff0ef          	jal	80000030 <console_putc>
            continue;
    80000594:	84a2                	mv	s1,s0
    80000596:	bf95                	j	8000050a <printf+0x74>
                console_putc('%');
    80000598:	854e                	mv	a0,s3
    8000059a:	a97ff0ef          	jal	80000030 <console_putc>
                break;
    8000059e:	b7b5                	j	8000050a <printf+0x74>
                        console_puts("(null)");
    800005a0:	00000517          	auipc	a0,0x0
    800005a4:	63850513          	addi	a0,a0,1592 # 80000bd8 <uart_puts+0x2d8>
    800005a8:	abfff0ef          	jal	80000066 <console_puts>
    800005ac:	bfb9                	j	8000050a <printf+0x74>
}
    800005ae:	60a6                	ld	ra,72(sp)
    800005b0:	6406                	ld	s0,64(sp)
    int count = 0;
    800005b2:	4901                	li	s2,0
}
    800005b4:	854a                	mv	a0,s2
    800005b6:	7942                	ld	s2,48(sp)
    800005b8:	6149                	addi	sp,sp,144
    800005ba:	8082                	ret

00000000800005bc <sprintf>:

// 格式化输出到缓冲区
int 
sprintf(char *buf, const char *fmt, ...) 
{
    800005bc:	7151                	addi	sp,sp,-240
    800005be:	edbe                	sd	a5,216(sp)
    800005c0:	f1c2                	sd	a6,224(sp)
    800005c2:	e1b2                	sd	a2,192(sp)
    800005c4:	e5b6                	sd	a3,200(sp)
    800005c6:	e9ba                	sd	a4,208(sp)
    800005c8:	f5c6                	sd	a7,232(sp)
    va_start(ap, fmt);
    
    // 这是一个简化的实现，仅支持基本功能
    // 在实际项目中，应该复用printf的代码逻辑，但输出到缓冲区
    
    for (const char *p = fmt; *p; p++) {
    800005ca:	0005c703          	lbu	a4,0(a1)
    va_start(ap, fmt);
    800005ce:	019c                	addi	a5,sp,192
    800005d0:	e43e                	sd	a5,8(sp)
{
    800005d2:	882a                	mv	a6,a0
    int count = 0;
    800005d4:	4501                	li	a0,0
    for (const char *p = fmt; *p; p++) {
    800005d6:	c725                	beqz	a4,8000063e <sprintf+0x82>
    800005d8:	87c2                	mv	a5,a6
        if (*p != '%') {
    800005da:	02500893          	li	a7,37
            continue;
        }
        
        p++;
        
        switch (*p) {
    800005de:	06400313          	li	t1,100
    800005e2:	00180e93          	addi	t4,a6,1
    800005e6:	07300e13          	li	t3,115
    800005ea:	a821                	j	80000602 <sprintf+0x46>
            buf[idx++] = *p;
    800005ec:	2505                	addiw	a0,a0,1
    800005ee:	00e78023          	sb	a4,0(a5)
            continue;
    800005f2:	86ae                	mv	a3,a1
    800005f4:	00a807b3          	add	a5,a6,a0
    for (const char *p = fmt; *p; p++) {
    800005f8:	0016c703          	lbu	a4,1(a3)
    800005fc:	00168593          	addi	a1,a3,1
    80000600:	cf15                	beqz	a4,8000063c <sprintf+0x80>
        p++;
    80000602:	00158693          	addi	a3,a1,1
        if (*p != '%') {
    80000606:	ff1713e3          	bne	a4,a7,800005ec <sprintf+0x30>
        switch (*p) {
    8000060a:	0015c703          	lbu	a4,1(a1)
    8000060e:	06670b63          	beq	a4,t1,80000684 <sprintf+0xc8>
    80000612:	05c70063          	beq	a4,t3,80000652 <sprintf+0x96>
    80000616:	03170863          	beq	a4,a7,80000646 <sprintf+0x8a>
                buf[idx++] = '%';
                count++;
                break;
                
            default:   // 未知格式符
                buf[idx++] = '%';
    8000061a:	01178023          	sb	a7,0(a5)
                buf[idx++] = *p;
    8000061e:	0015c703          	lbu	a4,1(a1)
                buf[idx++] = '%';
    80000622:	0015079b          	addiw	a5,a0,1
                buf[idx++] = *p;
    80000626:	97c2                	add	a5,a5,a6
    80000628:	2509                	addiw	a0,a0,2
    8000062a:	00e78023          	sb	a4,0(a5)
                count += 2;
                break;
    8000062e:	00a807b3          	add	a5,a6,a0
    for (const char *p = fmt; *p; p++) {
    80000632:	0016c703          	lbu	a4,1(a3)
    80000636:	00168593          	addi	a1,a3,1
    8000063a:	f761                	bnez	a4,80000602 <sprintf+0x46>
        }
    }
    
    // 添加字符串结束符
    buf[idx] = '\0';
    8000063c:	883e                	mv	a6,a5
    8000063e:	00080023          	sb	zero,0(a6)
    
    va_end(ap);
    return count;
}
    80000642:	616d                	addi	sp,sp,240
    80000644:	8082                	ret
                buf[idx++] = '%';
    80000646:	2505                	addiw	a0,a0,1
    80000648:	01178023          	sb	a7,0(a5)
                break;
    8000064c:	00a807b3          	add	a5,a6,a0
    80000650:	b765                	j	800005f8 <sprintf+0x3c>
                const char *s = va_arg(ap, const char *);
    80000652:	6722                	ld	a4,8(sp)
    80000654:	00073f03          	ld	t5,0(a4)
    80000658:	0721                	addi	a4,a4,8
    8000065a:	e43a                	sd	a4,8(sp)
                if (s == 0) {
    8000065c:	0e0f0763          	beqz	t5,8000074a <sprintf+0x18e>
                    while (*s) {
    80000660:	000f4603          	lbu	a2,0(t5)
    80000664:	85be                	mv	a1,a5
                const char *s = va_arg(ap, const char *);
    80000666:	877a                	mv	a4,t5
                    while (*s) {
    80000668:	da41                	beqz	a2,800005f8 <sprintf+0x3c>
                        buf[idx++] = *s++;
    8000066a:	00c58023          	sb	a2,0(a1)
                    while (*s) {
    8000066e:	00174603          	lbu	a2,1(a4)
                        buf[idx++] = *s++;
    80000672:	0705                	addi	a4,a4,1
                    while (*s) {
    80000674:	0585                	addi	a1,a1,1
    80000676:	fa75                	bnez	a2,8000066a <sprintf+0xae>
                        buf[idx++] = *s++;
    80000678:	41e7073b          	subw	a4,a4,t5
    8000067c:	9d39                	addw	a0,a0,a4
    8000067e:	00a807b3          	add	a5,a6,a0
    80000682:	bf9d                	j	800005f8 <sprintf+0x3c>
                int num = va_arg(ap, int);
    80000684:	6722                	ld	a4,8(sp)
    80000686:	00072f03          	lw	t5,0(a4)
    8000068a:	0721                	addi	a4,a4,8
    8000068c:	e43a                	sd	a4,8(sp)
                if (num < 0) {
    8000068e:	020f4f63          	bltz	t5,800006cc <sprintf+0x110>
                if (unum == 0) {
    80000692:	0c0f1d63          	bnez	t5,8000076c <sprintf+0x1b0>
                    temp_buf[temp_idx++] = '0';
    80000696:	03000713          	li	a4,48
    8000069a:	00e10823          	sb	a4,16(sp)
    8000069e:	4285                	li	t0,1
    800006a0:	0818                	addi	a4,sp,16
    800006a2:	fff2861b          	addiw	a2,t0,-1
    800006a6:	1602                	slli	a2,a2,0x20
    800006a8:	9201                	srli	a2,a2,0x20
    800006aa:	00ae85b3          	add	a1,t4,a0
    800006ae:	9732                	add	a4,a4,a2
    800006b0:	95b2                	add	a1,a1,a2
                    buf[idx++] = temp_buf[--temp_idx];
    800006b2:	00074603          	lbu	a2,0(a4)
                while (temp_idx > 0) {
    800006b6:	0785                	addi	a5,a5,1
    800006b8:	177d                	addi	a4,a4,-1
                    buf[idx++] = temp_buf[--temp_idx];
    800006ba:	fec78fa3          	sb	a2,-1(a5)
                while (temp_idx > 0) {
    800006be:	feb79ae3          	bne	a5,a1,800006b2 <sprintf+0xf6>
    800006c2:	0055053b          	addw	a0,a0,t0
    800006c6:	00a807b3          	add	a5,a6,a0
    800006ca:	b73d                	j	800005f8 <sprintf+0x3c>
    800006cc:	ed52                	sd	s4,152(sp)
                    unum = -num;
    800006ce:	fd22                	sd	s0,184(sp)
    800006d0:	f926                	sd	s1,176(sp)
    800006d2:	f54a                	sd	s2,168(sp)
    800006d4:	f14e                	sd	s3,160(sp)
    800006d6:	41e00f3b          	negw	t5,t5
                    negative = 1;
    800006da:	4a05                	li	s4,1
                    while (unum > 0) {
    800006dc:	0818                	addi	a4,sp,16
                        temp_buf[temp_idx++] = digits[unum % 10];
    800006de:	4485                	li	s1,1
    800006e0:	66666437          	lui	s0,0x66666
                    negative = 1;
    800006e4:	8fba                	mv	t6,a4
                        temp_buf[temp_idx++] = digits[unum % 10];
    800006e6:	9c99                	subw	s1,s1,a4
    800006e8:	66740413          	addi	s0,s0,1639 # 66666667 <_entry-0x19999999>
    800006ec:	00000997          	auipc	s3,0x0
    800006f0:	5bc98993          	addi	s3,s3,1468 # 80000ca8 <digits>
                    while (unum > 0) {
    800006f4:	4925                	li	s2,9
                        temp_buf[temp_idx++] = digits[unum % 10];
    800006f6:	028f05b3          	mul	a1,t5,s0
    800006fa:	41ff561b          	sraiw	a2,t5,0x1f
    800006fe:	83fa                	mv	t2,t5
    80000700:	01f482bb          	addw	t0,s1,t6
                    while (unum > 0) {
    80000704:	0f85                	addi	t6,t6,1
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000706:	9589                	srai	a1,a1,0x22
    80000708:	9d91                	subw	a1,a1,a2
    8000070a:	0025961b          	slliw	a2,a1,0x2
    8000070e:	9e2d                	addw	a2,a2,a1
    80000710:	0016161b          	slliw	a2,a2,0x1
    80000714:	40cf063b          	subw	a2,t5,a2
    80000718:	1602                	slli	a2,a2,0x20
    8000071a:	9201                	srli	a2,a2,0x20
    8000071c:	964e                	add	a2,a2,s3
    8000071e:	00064603          	lbu	a2,0(a2)
                        unum /= 10;
    80000722:	8f2e                	mv	t5,a1
                        temp_buf[temp_idx++] = digits[unum % 10];
    80000724:	fecf8fa3          	sb	a2,-1(t6)
                    while (unum > 0) {
    80000728:	fc7967e3          	bltu	s2,t2,800006f6 <sprintf+0x13a>
                if (negative) {
    8000072c:	000a0963          	beqz	s4,8000073e <sprintf+0x182>
            buf[idx++] = *p;
    80000730:	2505                	addiw	a0,a0,1
                    buf[idx++] = '-';
    80000732:	02d00613          	li	a2,45
    80000736:	00c78023          	sb	a2,0(a5)
                while (temp_idx > 0) {
    8000073a:	00a807b3          	add	a5,a6,a0
    8000073e:	746a                	ld	s0,184(sp)
    80000740:	74ca                	ld	s1,176(sp)
    80000742:	792a                	ld	s2,168(sp)
    80000744:	798a                	ld	s3,160(sp)
    80000746:	6a6a                	ld	s4,152(sp)
    80000748:	bfa9                	j	800006a2 <sprintf+0xe6>
    8000074a:	00000617          	auipc	a2,0x0
    8000074e:	57660613          	addi	a2,a2,1398 # 80000cc0 <null_str.0>
                    for (int i = 0; null_str[i]; i++) {
    80000752:	02800713          	li	a4,40
                        buf[idx++] = null_str[i];
    80000756:	00e78023          	sb	a4,0(a5)
                    for (int i = 0; null_str[i]; i++) {
    8000075a:	00164703          	lbu	a4,1(a2)
                        buf[idx++] = null_str[i];
    8000075e:	2505                	addiw	a0,a0,1
                    for (int i = 0; null_str[i]; i++) {
    80000760:	0785                	addi	a5,a5,1
    80000762:	0605                	addi	a2,a2,1
    80000764:	fb6d                	bnez	a4,80000756 <sprintf+0x19a>
                break;
    80000766:	00a807b3          	add	a5,a6,a0
    8000076a:	b5e1                	j	80000632 <sprintf+0x76>
    8000076c:	ed52                	sd	s4,152(sp)
    8000076e:	fd22                	sd	s0,184(sp)
    80000770:	f926                	sd	s1,176(sp)
    80000772:	f54a                	sd	s2,168(sp)
    80000774:	f14e                	sd	s3,160(sp)
                int negative = 0;
    80000776:	4a01                	li	s4,0
    80000778:	b795                	j	800006dc <sprintf+0x120>

000000008000077a <printf_color>:

// 带颜色的格式化输出
int 
printf_color(int color, const char *fmt, ...) 
{
    8000077a:	7119                	addi	sp,sp,-128
    8000077c:	fc26                	sd	s1,56(sp)
    8000077e:	84aa                	mv	s1,a0
    // 设置前景色 - ANSI转义序列
    console_puts("\033[3");
    80000780:	00000517          	auipc	a0,0x0
    80000784:	46050513          	addi	a0,a0,1120 # 80000be0 <uart_puts+0x2e0>
{
    80000788:	f4be                	sd	a5,104(sp)
    8000078a:	e486                	sd	ra,72(sp)
    8000078c:	e8b2                	sd	a2,80(sp)
    8000078e:	ecb6                	sd	a3,88(sp)
    80000790:	f0ba                	sd	a4,96(sp)
    80000792:	f8c2                	sd	a6,112(sp)
    80000794:	fcc6                	sd	a7,120(sp)
    80000796:	e0a2                	sd	s0,64(sp)
    80000798:	f84a                	sd	s2,48(sp)
    8000079a:	842e                	mv	s0,a1
    console_puts("\033[3");
    8000079c:	8cbff0ef          	jal	80000066 <console_puts>
    console_putc('0' + (color & 0x7));  // 转换为0-7
    800007a0:	0074f513          	andi	a0,s1,7
    800007a4:	03050513          	addi	a0,a0,48
    800007a8:	889ff0ef          	jal	80000030 <console_putc>
    console_puts("m");
    800007ac:	00000517          	auipc	a0,0x0
    800007b0:	43c50513          	addi	a0,a0,1084 # 80000be8 <uart_puts+0x2e8>
    800007b4:	8b3ff0ef          	jal	80000066 <console_puts>
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
    800007b8:	00044503          	lbu	a0,0(s0)
    va_start(ap, fmt);
    800007bc:	089c                	addi	a5,sp,80
    800007be:	e43e                	sd	a5,8(sp)
    for (const char *p = fmt; *p; p++) {
    800007c0:	10050163          	beqz	a0,800008c2 <printf_color+0x148>
    800007c4:	f44e                	sd	s3,40(sp)
    800007c6:	f052                	sd	s4,32(sp)
    800007c8:	ec56                	sd	s5,24(sp)
    int count = 0;
    800007ca:	4901                	li	s2,0
        if (*p != '%') {
    800007cc:	02500993          	li	s3,37
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
    800007d0:	4ad5                	li	s5,21
    800007d2:	00000a17          	auipc	s4,0x0
    800007d6:	47ea0a13          	addi	s4,s4,1150 # 80000c50 <uart_puts+0x350>
            count++;
    800007da:	2905                	addiw	s2,s2,1
        if (*p != '%') {
    800007dc:	0d351463          	bne	a0,s3,800008a4 <printf_color+0x12a>
        switch (*p) {
    800007e0:	00144783          	lbu	a5,1(s0)
        p++;
    800007e4:	00140493          	addi	s1,s0,1
        switch (*p) {
    800007e8:	0d378263          	beq	a5,s3,800008ac <printf_color+0x132>
    800007ec:	f9d7879b          	addiw	a5,a5,-99
    800007f0:	0ff7f793          	zext.b	a5,a5
    800007f4:	00fae763          	bltu	s5,a5,80000802 <printf_color+0x88>
    800007f8:	078a                	slli	a5,a5,0x2
    800007fa:	97d2                	add	a5,a5,s4
    800007fc:	439c                	lw	a5,0(a5)
    800007fe:	97d2                	add	a5,a5,s4
    80000800:	8782                	jr	a5
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
    80000802:	02500513          	li	a0,37
    80000806:	82bff0ef          	jal	80000030 <console_putc>
                console_putc(*p);
    8000080a:	00144503          	lbu	a0,1(s0)
    8000080e:	823ff0ef          	jal	80000030 <console_putc>
    for (const char *p = fmt; *p; p++) {
    80000812:	0014c503          	lbu	a0,1(s1)
    80000816:	00148413          	addi	s0,s1,1
    8000081a:	f161                	bnez	a0,800007da <printf_color+0x60>
    8000081c:	79a2                	ld	s3,40(sp)
    8000081e:	7a02                	ld	s4,32(sp)
    80000820:	6ae2                	ld	s5,24(sp)
    }
    
    va_end(ap);
    
    // 重置颜色
    console_puts("\033[0m");
    80000822:	00000517          	auipc	a0,0x0
    80000826:	3ce50513          	addi	a0,a0,974 # 80000bf0 <uart_puts+0x2f0>
    8000082a:	83dff0ef          	jal	80000066 <console_puts>
    
    return count;
}
    8000082e:	60a6                	ld	ra,72(sp)
    80000830:	6406                	ld	s0,64(sp)
    80000832:	74e2                	ld	s1,56(sp)
    80000834:	854a                	mv	a0,s2
    80000836:	7942                	ld	s2,48(sp)
    80000838:	6109                	addi	sp,sp,128
    8000083a:	8082                	ret
                print_number(va_arg(ap, unsigned int), 16, 0);
    8000083c:	67a2                	ld	a5,8(sp)
    8000083e:	4601                	li	a2,0
    80000840:	45c1                	li	a1,16
    80000842:	0007e503          	lwu	a0,0(a5)
    80000846:	07a1                	addi	a5,a5,8
    80000848:	e43e                	sd	a5,8(sp)
    8000084a:	b5dff0ef          	jal	800003a6 <print_number>
                break;
    8000084e:	b7d1                	j	80000812 <printf_color+0x98>
                print_number(va_arg(ap, unsigned int), 10, 0);
    80000850:	67a2                	ld	a5,8(sp)
    80000852:	4601                	li	a2,0
    80000854:	45a9                	li	a1,10
    80000856:	0007e503          	lwu	a0,0(a5)
    8000085a:	07a1                	addi	a5,a5,8
    8000085c:	e43e                	sd	a5,8(sp)
    8000085e:	b49ff0ef          	jal	800003a6 <print_number>
                break;
    80000862:	bf45                	j	80000812 <printf_color+0x98>
                    const char *s = va_arg(ap, const char *);
    80000864:	67a2                	ld	a5,8(sp)
    80000866:	6388                	ld	a0,0(a5)
    80000868:	07a1                	addi	a5,a5,8
    8000086a:	e43e                	sd	a5,8(sp)
                    if (s == 0) {
    8000086c:	c521                	beqz	a0,800008b4 <printf_color+0x13a>
                        console_puts(s);
    8000086e:	ff8ff0ef          	jal	80000066 <console_puts>
    80000872:	b745                	j	80000812 <printf_color+0x98>
                print_ptr(va_arg(ap, uint64));
    80000874:	67a2                	ld	a5,8(sp)
    80000876:	6388                	ld	a0,0(a5)
    80000878:	07a1                	addi	a5,a5,8
    8000087a:	e43e                	sd	a5,8(sp)
    8000087c:	bb9ff0ef          	jal	80000434 <print_ptr>
                break;
    80000880:	bf49                	j	80000812 <printf_color+0x98>
                print_number(va_arg(ap, int), 10, 1);
    80000882:	67a2                	ld	a5,8(sp)
    80000884:	4605                	li	a2,1
    80000886:	45a9                	li	a1,10
    80000888:	4388                	lw	a0,0(a5)
    8000088a:	07a1                	addi	a5,a5,8
    8000088c:	e43e                	sd	a5,8(sp)
    8000088e:	b19ff0ef          	jal	800003a6 <print_number>
                break;
    80000892:	b741                	j	80000812 <printf_color+0x98>
                console_putc(va_arg(ap, int));
    80000894:	67a2                	ld	a5,8(sp)
    80000896:	0007c503          	lbu	a0,0(a5)
    8000089a:	07a1                	addi	a5,a5,8
    8000089c:	e43e                	sd	a5,8(sp)
    8000089e:	f92ff0ef          	jal	80000030 <console_putc>
                break;
    800008a2:	bf85                	j	80000812 <printf_color+0x98>
            console_putc(*p);
    800008a4:	f8cff0ef          	jal	80000030 <console_putc>
            continue;
    800008a8:	84a2                	mv	s1,s0
    800008aa:	b7a5                	j	80000812 <printf_color+0x98>
                console_putc('%');
    800008ac:	854e                	mv	a0,s3
    800008ae:	f82ff0ef          	jal	80000030 <console_putc>
                break;
    800008b2:	b785                	j	80000812 <printf_color+0x98>
                        console_puts("(null)");
    800008b4:	00000517          	auipc	a0,0x0
    800008b8:	32450513          	addi	a0,a0,804 # 80000bd8 <uart_puts+0x2d8>
    800008bc:	faaff0ef          	jal	80000066 <console_puts>
    800008c0:	bf89                	j	80000812 <printf_color+0x98>
    int count = 0;
    800008c2:	4901                	li	s2,0
    800008c4:	bfb9                	j	80000822 <printf_color+0xa8>

00000000800008c6 <printf_init>:
// 初始化printf系统
void 
printf_init(void) 
{
    // 初始化控制台
    console_init();
    800008c6:	f66ff06f          	j	8000002c <console_init>

00000000800008ca <uart_init>:
// 向寄存器写入值
static inline void 
uart_write_reg(int reg, uint8 v)
{
    volatile uint8 *p = (uint8*)UART0;
    p[reg] = v;
    800008ca:	100007b7          	lui	a5,0x10000
    800008ce:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    800008d2:	10000737          	lui	a4,0x10000
    800008d6:	468d                	li	a3,3
    800008d8:	87ba                	mv	a5,a4
    800008da:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    800008de:	4705                	li	a4,1
    800008e0:	00e78123          	sb	a4,2(a5)
    // 设置8位数据位，1位停止位，无奇偶校验(8N1)
    uart_write_reg(LCR, 0x03);
    
    // 启用FIFO
    uart_write_reg(FCR, 0x01);
}
    800008e4:	8082                	ret

00000000800008e6 <uart_putc>:
    return p[reg];
    800008e6:	10000737          	lui	a4,0x10000
    800008ea:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800008ec:	100006b7          	lui	a3,0x10000
    800008f0:	00074783          	lbu	a5,0(a4)
// 发送单个字符
void 
uart_putc(char c)
{
    // 等待发送缓冲区空闲
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
    800008f4:	0207f793          	andi	a5,a5,32
    800008f8:	dfe5                	beqz	a5,800008f0 <uart_putc+0xa>
    p[reg] = v;
    800008fa:	00a68023          	sb	a0,0(a3) # 10000000 <_entry-0x70000000>
        ;
    
    // 发送字符
    uart_write_reg(THR, c);
}
    800008fe:	8082                	ret

0000000080000900 <uart_puts>:

// 发送字符串
void 
uart_puts(const char *s)
{
    while(*s != '\0') {
    80000900:	00054683          	lbu	a3,0(a0)
    80000904:	c28d                	beqz	a3,80000926 <uart_puts+0x26>
    return p[reg];
    80000906:	10000737          	lui	a4,0x10000
    8000090a:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000090c:	10000637          	lui	a2,0x10000
        uart_putc(*s++);
    80000910:	0505                	addi	a0,a0,1
    return p[reg];
    80000912:	00074783          	lbu	a5,0(a4)
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
    80000916:	0207f793          	andi	a5,a5,32
    8000091a:	dfe5                	beqz	a5,80000912 <uart_puts+0x12>
    p[reg] = v;
    8000091c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>
    while(*s != '\0') {
    80000920:	00054683          	lbu	a3,0(a0)
    80000924:	f6f5                	bnez	a3,80000910 <uart_puts+0x10>
    }
    80000926:	8082                	ret
