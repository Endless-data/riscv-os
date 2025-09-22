#include "types.h"
#include "uart.h"

// C语言入口点，从entry.S跳转而来
void
start(void)
{
    // 初始化串口
    uart_init();
    
    // 输出欢迎信息
    uart_puts("Hello OS\n");
    
    // 进入空循环，防止程序退出
    // 在实际系统中，这里会初始化其他硬件、设置中断、启动进程等
    while(1) {
        // 空循环或低功耗等待
        // asm volatile("wfi");  // wait for interrupt，低功耗等待（可选）
    }
}