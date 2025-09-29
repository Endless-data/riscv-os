#ifndef _DEFS_H_
#define _DEFS_H_

#include "types.h"

// uart.c
void uart_init(void);
void uart_putc(char c);
void uart_puts(const char *s);

// console.c
void console_init(void);
void console_putc(char c);
void console_puts(const char *s);
void clear_screen(void);
void console_goto_xy(int x, int y);

// printf.c
int printf(const char *fmt, ...);
int sprintf(char *buf, const char *fmt, ...);
int printf_color(int color, const char *fmt, ...);
void printf_init(void);

#endif // _DEFS_H_