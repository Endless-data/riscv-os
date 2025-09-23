#ifndef _PRINTF_H_
#define _PRINTF_H_

// 格式化输出到控制台
int printf(const char *fmt, ...);

// 格式化输出到缓冲区
int sprintf(char *buf, const char *fmt, ...);

// 带颜色的格式化输出
int printf_color(int color, const char *fmt, ...);

// 初始化printf系统
void printf_init(void);

#endif // _PRINTF_H_