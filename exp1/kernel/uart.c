#include "types.h"
#include "uart.h"

// UART寄存器基址
#define UART0 0x10000000L

// 寄存器偏移量
#define RHR 0       // 接收保持寄存器(读)
#define THR 0       // 发送保持寄存器(写)
#define IER 1       // 中断使能寄存器
#define FCR 2       // FIFO控制寄存器
#define LCR 3       // 线路控制寄存器
#define LSR 5       // 线路状态寄存器

// LSR位定义
#define LSR_TX_IDLE  0x20  // 发送保持寄存器为空
#define LSR_RX_READY 0x01  // 接收数据就绪

// 向寄存器写入值
static inline void 
uart_write_reg(int reg, uint8 v)
{
    volatile uint8 *p = (uint8*)UART0;
    p[reg] = v;
}

// 从寄存器读取值
static inline uint8 
uart_read_reg(int reg)
{
    volatile uint8 *p = (uint8*)UART0;
    return p[reg];
}

// 初始化UART
void 
uart_init(void)
{
    // 禁用中断
    uart_write_reg(IER, 0x00);
    
    // 设置波特率(此处省略，QEMU不需要)
    
    // 设置8位数据位，1位停止位，无奇偶校验(8N1)
    uart_write_reg(LCR, 0x03);
    
    // 启用FIFO
    uart_write_reg(FCR, 0x01);
}

// 发送单个字符
void 
uart_putc(char c)
{
    // 等待发送缓冲区空闲
    while((uart_read_reg(LSR) & LSR_TX_IDLE) == 0)
        ;
    
    // 发送字符
    uart_write_reg(THR, c);
}

// 发送字符串
void 
uart_puts(const char *s)
{
    while(*s != '\0') {
        uart_putc(*s++);
    }
}