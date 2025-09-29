#include <stdarg.h>
#include "types.h"
#include "defs.h"

// 定义数字字符集（10进制和16进制）
static const char digits[] = "0123456789abcdef";

// 控制台颜色代码
#define COLOR_BLACK      0
#define COLOR_RED        1
#define COLOR_GREEN      2
#define COLOR_YELLOW     3
#define COLOR_BLUE       4
#define COLOR_MAGENTA    5
#define COLOR_CYAN       6
#define COLOR_WHITE      7

// 数字转换函数 - 将数字转换为指定进制的字符串
static void 
print_number(long long num, int base, int is_signed) 
{
    char buf[32];  // 足够存储64位整数
    int idx = 0;
    unsigned long long unum;
    
    // 处理符号问题
    int negative = 0;
    if (is_signed && num < 0) {
        negative = 1;
        unum = (unsigned long long)(-num);  // 转为正数处理
    } else {
        unum = (unsigned long long)num;
    }
    
    // 处理特殊情况: 0
    if (unum == 0) {
        buf[idx++] = '0';
    } else {
        // 将数字转换为字符，从低位到高位
        while (unum != 0) {
            buf[idx++] = digits[unum % base];
            unum /= base;
        }
    }
    
    // 添加负号（如果需要）
    if (negative) {
        buf[idx++] = '-';
    }
    
    // 反向输出字符
    while (idx > 0) {
        console_putc(buf[--idx]);
    }
}

// 打印指针地址
static void 
print_ptr(uint64 ptr) 
{
    console_puts("0x");
    
    // 对于64位指针，我们需要输出16个十六进制数字
    int i;
    int leading_zeros = 1;  // 是否跳过前导零
    
    // 从高位到低位，每4位一组转换为一个十六进制数字
    for (i = 60; i >= 0; i -= 4) {
        int digit = (ptr >> i) & 0xf;
        
        // 跳过前导零，但至少输出一个0
        if (digit == 0 && leading_zeros && i != 0) {
            continue;
        }
        
        leading_zeros = 0;
        console_putc(digits[digit]);
    }
}

// 格式化输出到控制台
int 
printf(const char *fmt, ...) 
{
    va_list ap;
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
        if (*p != '%') {
            // 普通字符直接输出
            console_putc(*p);
            count++;
            continue;
        }
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
            case 'd':  // 十进制有符号整数
                print_number(va_arg(ap, int), 10, 1);
                break;
                
            case 'u':  // 十进制无符号整数
                print_number(va_arg(ap, unsigned int), 10, 0);
                break;
                
            case 'x':  // 十六进制整数
                print_number(va_arg(ap, unsigned int), 16, 0);
                break;
                
            case 'p':  // 指针
                print_ptr(va_arg(ap, uint64));
                break;
                
            case 'c':  // 字符
                console_putc(va_arg(ap, int));
                break;
                
            case 's':  // 字符串
                {
                    const char *s = va_arg(ap, const char *);
                    if (s == 0) {
                        console_puts("(null)");
                    } else {
                        console_puts(s);
                    }
                }
                break;
                
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
                console_putc(*p);
                break;
        }
        count++;
    }
    
    va_end(ap);
    return count;
}

// 格式化输出到缓冲区
int 
sprintf(char *buf, const char *fmt, ...) 
{
    va_list ap;
    int count = 0;
    char temp_buf[128]; // 临时缓冲区
    int idx = 0;
    
    va_start(ap, fmt);
    
    // 这是一个简化的实现，仅支持基本功能
    // 在实际项目中，应该复用printf的代码逻辑，但输出到缓冲区
    
    for (const char *p = fmt; *p; p++) {
        if (*p != '%') {
            buf[idx++] = *p;
            count++;
            continue;
        }
        
        p++;
        
        switch (*p) {
            case 'd': {  // 整数
                int num = va_arg(ap, int);
                int temp_idx = 0;
                int negative = 0;
                unsigned int unum;
                
                // 处理负数
                if (num < 0) {
                    negative = 1;
                    unum = -num;
                } else {
                    unum = num;
                }
                
                // 处理0的情况
                if (unum == 0) {
                    temp_buf[temp_idx++] = '0';
                } else {
                    // 转换数字
                    while (unum > 0) {
                        temp_buf[temp_idx++] = digits[unum % 10];
                        unum /= 10;
                    }
                }
                
                // 添加符号
                if (negative) {
                    buf[idx++] = '-';
                    count++;
                }
                
                // 反向拷贝数字
                while (temp_idx > 0) {
                    buf[idx++] = temp_buf[--temp_idx];
                    count++;
                }
                break;
            }
            
            case 's': {  // 字符串
                const char *s = va_arg(ap, const char *);
                if (s == 0) {
                    static const char null_str[] = "(null)";
                    for (int i = 0; null_str[i]; i++) {
                        buf[idx++] = null_str[i];
                        count++;
                    }
                } else {
                    while (*s) {
                        buf[idx++] = *s++;
                        count++;
                    }
                }
                break;
            }
            
            case '%':  // 百分号
                buf[idx++] = '%';
                count++;
                break;
                
            default:   // 未知格式符
                buf[idx++] = '%';
                buf[idx++] = *p;
                count += 2;
                break;
        }
    }
    
    // 添加字符串结束符
    buf[idx] = '\0';
    
    va_end(ap);
    return count;
}

// 带颜色的格式化输出
int 
printf_color(int color, const char *fmt, ...) 
{
    // 设置前景色 - ANSI转义序列
    console_puts("\033[3");
    console_putc('0' + (color & 0x7));  // 转换为0-7
    console_puts("m");
    
    va_list ap;
    int count = 0;
    
    va_start(ap, fmt);
    
    // 简单的状态机解析格式字符串
    for (const char *p = fmt; *p; p++) {
        if (*p != '%') {
            // 普通字符直接输出
            console_putc(*p);
            count++;
            continue;
        }
        
        // 跳过%
        p++;
        
        // 处理格式符
        switch (*p) {
            case 'd':  // 十进制有符号整数
                print_number(va_arg(ap, int), 10, 1);
                break;
                
            case 'u':  // 十进制无符号整数
                print_number(va_arg(ap, unsigned int), 10, 0);
                break;
                
            case 'x':  // 十六进制整数
                print_number(va_arg(ap, unsigned int), 16, 0);
                break;
                
            case 'p':  // 指针
                print_ptr(va_arg(ap, uint64));
                break;
                
            case 'c':  // 字符
                console_putc(va_arg(ap, int));
                break;
                
            case 's':  // 字符串
                {
                    const char *s = va_arg(ap, const char *);
                    if (s == 0) {
                        console_puts("(null)");
                    } else {
                        console_puts(s);
                    }
                }
                break;
                
            case '%':  // 百分号
                console_putc('%');
                break;
                
            default:   // 未知格式符
                console_putc('%');
                console_putc(*p);
                break;
        }
        count++;
    }
    
    va_end(ap);
    
    // 重置颜色
    console_puts("\033[0m");
    
    return count;
}

// 初始化printf系统
void 
printf_init(void) 
{
    // 初始化控制台
    console_init();
}