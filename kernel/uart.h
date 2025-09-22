#ifndef _UART_H_
#define _UART_H_

// UART初始化函数
void uart_init(void);

// 输出单个字符
void uart_putc(char c);

// 输出字符串
void uart_puts(const char *s);

#endif // _UART_H_