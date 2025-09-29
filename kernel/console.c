#include "types.h"
#include "defs.h"

// 初始化控制台
void 
console_init(void) 
{
    // 初始化UART
    uart_init();
}

// 输出单个字符到控制台
void 
console_putc(char c) 
{
    // 处理特殊字符
    if (c == '\n') {
        // 换行符需要CR+LF
        uart_putc('\r');
        uart_putc('\n');
    } else if (c == '\b') {
        // 退格键，输出退格+空格+退格序列
        uart_putc('\b');
        uart_putc(' ');
        uart_putc('\b');
    } else {
        // 普通字符直接输出
        uart_putc(c);
    }
}

// 输出字符串到控制台
void 
console_puts(const char *s) 
{
    while (*s != '\0') {
        console_putc(*s++);
    }
}

// 清除屏幕 - ANSI转义序列
void 
clear_screen(void) 
{
    // ESC [ 2 J - 清除整个屏幕
    // ESC [ H - 光标移动到左上角 (1,1)
    console_puts("\033[2J");
    console_puts("\033[H");
}

// 定位光标
void 
console_goto_xy(int x, int y) 
{
    // 缓冲区用于构造ANSI序列
    char buf[16];
    char *p = buf;
    
    // ESC [ row ; col H
    *p++ = '\033';
    *p++ = '[';
    
    // 转换y坐标（行）
    int temp = y;
    char y_digits[10];
    int y_idx = 0;
    
    do {
        y_digits[y_idx++] = (temp % 10) + '0';
        temp /= 10;
    } while (temp > 0);
    
    // 反向输出
    while (y_idx > 0) {
        *p++ = y_digits[--y_idx];
    }
    
    *p++ = ';';
    
    // 转换x坐标（列）
    temp = x;
    char x_digits[10];
    int x_idx = 0;
    
    do {
        x_digits[x_idx++] = (temp % 10) + '0';
        temp /= 10;
    } while (temp > 0);
    
    // 反向输出
    while (x_idx > 0) {
        *p++ = x_digits[--x_idx];
    }
    
    *p++ = 'H';
    *p = '\0';
    
    // 发送序列
    console_puts(buf);
}