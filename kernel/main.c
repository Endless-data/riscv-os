#include "types.h"
#include "defs.h"

// 测试printf基本功能
void test_printf_basic() {
    printf("测试整数: %d\n", 42);
    printf("测试负数: %d\n", -123);
    printf("测试零值: %d\n", 0);
    printf("测试十六进制: 0x%x\n", 0xABC);
    printf("测试字符串: %s\n", "你好，世界");
    printf("测试字符: %c\n", 'X');
    printf("测试百分号: %%\n");
}

// 测试printf边缘情况
void test_printf_edge_cases() {
    printf("INT_MAX: %d\n", 2147483647);
    printf("INT_MIN: %d\n", -2147483648);
    printf("NULL字符串: %s\n", (char*)0);
    printf("空字符串: %s\n", "");
}

// 测试颜色输出
void test_color_output() {
    printf_color(1, "红色文本\n");
    printf_color(2, "绿色文本 %d\n", 123);
    printf_color(3, "黄色文本 %s\n", "测试");
    printf_color(4, "蓝色文本\n");
}

// 测试清屏功能
void test_clear_screen() {
    printf("按任意键清屏...\n");
    // 在实际系统中，这里应该等待键盘输入
    
    clear_screen();
    console_goto_xy(10, 6);
    printf("这是清屏后在指定位置(10,6)的输出\n");
}

// C语言入口点，从entry.S跳转而来
void
start(void)
{
    // 初始化printf系统
    printf_init();
    
    // 清屏并输出欢迎信息
    clear_screen();
    printf("===================================\n");
    printf("      增强版内核 printf 测试       \n");
    printf("===================================\n\n");
    
    // 测试基本功能
    printf("--- 基本功能测试 ---\n");
    test_printf_basic();
    printf("\n");
    
    // 测试边缘情况
    printf("--- 边缘情况测试 ---\n");
    test_printf_edge_cases();
    printf("\n");
    
    // 测试颜色输出
    printf("--- 颜色输出测试 ---\n");
    test_color_output();
    printf("\n");
    
    // 测试清屏功能
    test_clear_screen();
    
    // 进入空循环，防止程序退出
    while(1) {
        // 空循环或低功耗等待
        // asm volatile("wfi");  // wait for interrupt，低功耗等待（可选）
    }
}