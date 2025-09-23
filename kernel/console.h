#ifndef _CONSOLE_H_
#define _CONSOLE_H_

#include "types.h"

// 初始化控制台
void console_init(void);

// 输出单个字符到控制台
void console_putc(char c);

// 输出字符串到控制台
void console_puts(const char *s);

// 清除屏幕
void clear_screen(void);

// 定位光标
void console_goto_xy(int x, int y);

#endif // _CONSOLE_H_