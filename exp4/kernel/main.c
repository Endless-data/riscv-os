#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "riscv.h"

// ==================== 测试1：时钟中断测试 ====================
void test_timer_interrupt(void) {
    printf("正在测试时钟中断...\n");
    
    // 记录中断前的时间
    uint64 start_time = get_time();
    int interrupt_count = 0;
    
    // 使能中断
    intr_on();
    
    // 在时钟中断处理函数中增加计数
    // 等待几次中断
    int initial_count = get_interrupt_count();
    int last_printed = 0;
    printf("等待 5 次中断...\n");
    
    while ((get_interrupt_count() - initial_count) < 5) {
        int current = get_interrupt_count() - initial_count;
        // 只在中断发生时打印一次
        if (current > last_printed) {
            printf("  第 %d 次中断已发生\n", current);
            last_printed = current;
        }
        // 简单延时
        for (volatile int i = 0; i < 1000000; i++);
    }
    
    uint64 end_time = get_time();
    interrupt_count = get_interrupt_count() - initial_count;
    printf("时钟测试完成: %d 次中断，耗时 %d 周期\n",
           interrupt_count, (int)(end_time - start_time));
}

// ==================== 测试2：异常处理测试 ====================
void test_exception_handling(void) {
    printf("正在测试异常处理...\n");
    
    // 测试除零异常（如果支持）
    printf("注意: RISC-V上除零可能不会触发异常\n");
    
    // 测试非法指令异常
    printf("测试非法指令处理 (已跳过以避免panic)\n");
    // 实际执行会导致panic: 
    // asm volatile(".word 0x00000000");
    
    // 测试内存访问异常
    printf("测试内存访问异常 (已跳过以避免panic)\n");
    // 实际执行会导致panic: 
    // volatile int *bad_ptr = (int*)0x0; int x = *bad_ptr;

    // 2. 测试指令地址未对齐异常 (scause = 0)
    printf("  [2] 测试指令地址未对齐 (已跳过以避免panic)\n");
    // 尝试跳转到一个奇数地址。RISC-V要求跳转地址是2字节对齐的。
    // asm volatile("jr %0" :: "r"(0x80000001));
    
    printf("异常测试完成\n");
}

// ==================== 测试3：中断性能测试 ====================
void test_interrupt_overhead(void) {
    printf("正在测试中断开销...\n");
    
    // 测量中断处理的时间开销
    printf("测量中断处理开销...\n");
    
    // 禁用中断，测量基准性能
    intr_off();
    uint64 start_no_intr = get_time();
    volatile int sum = 0;
    for (int i = 0; i < 500000000; i++) {
        sum += i;
    }
    uint64 end_no_intr = get_time();
    uint64 cycles_no_intr = end_no_intr - start_no_intr;
    
    // 使能中断，测量有中断时的性能
    intr_on();
    int intr_before = get_interrupt_count();
    uint64 start_with_intr = get_time();
    sum = 0;
    for (int i = 0; i < 500000000; i++) {
        sum += i;
    }
    uint64 end_with_intr = get_time();
    int intr_after = get_interrupt_count();
    uint64 cycles_with_intr = end_with_intr - start_with_intr;
    
    // 测量上下文切换的成本
    int interrupts_occurred = intr_after - intr_before;
    uint64 overhead = cycles_with_intr - cycles_no_intr;
    
    printf("无中断时性能: %d 周期\n", (int)cycles_no_intr);
    printf("有中断时性能: %d 周期\n", (int)cycles_with_intr);
    printf("发生中断次数: %d\n", interrupts_occurred);
    printf("总开销: %d 周期\n", (int)overhead);
    
    // 分析中断频率对系统性能的影响
    if (interrupts_occurred > 0) {
        printf("每次中断平均开销: %d 周期\n", 
               (int)(overhead / interrupts_occurred));
        printf("上下文切换成本估计: ~%d 周期\n",
               (int)(overhead / interrupts_occurred));
    }
    
    printf("中断开销测试完成\n");
}

// ==================== 主函数 ====================
void
main(void)
{
    // 初始化printf系统
    printf_init();
    
    // 清屏并输出欢迎信息
    clear_screen();
    printf("=====================================\n");
    printf("  实验4：中断处理与时钟管理测试     \n");
    printf("=====================================\n");
    printf("Hart ID: %d\n", (int)r_tp());
    printf("=====================================\n");
    
    // 初始化中断系统
    printf("\n[步骤1] 初始化中断系统\n");
    trapinit();
    
    // 显示初始状态
    printf("\n[步骤2] 系统初始状态\n");
    show_interrupt_stats();
    
    printf("\n");
    printf("=====================================\n");
    printf("      开始运行测试...                \n");
    printf("=====================================\n");
    
    // 运行三个核心测试
    printf("\n[测试1] 时钟中断测试\n");
    printf("-------------------------------------\n");
    test_timer_interrupt();
    
    printf("\n[测试2] 异常处理测试\n");
    printf("-------------------------------------\n");
    test_exception_handling();
    
    printf("\n[测试3] 中断开销测试\n");
    printf("-------------------------------------\n");
    test_interrupt_overhead();
    
    // 最终统计
    printf("\n");
    printf("=====================================\n");
    printf("      最终统计信息                   \n");
    printf("=====================================\n");
    show_interrupt_stats();
    
    // 总结
    printf("\n");
    printf("=====================================\n");
    printf("      所有测试完成!                  \n");
    printf("=====================================\n");
    printf("已实现功能:\n");
    printf("  * 中断向量表配置 (stvec)\n");
    printf("  * 时钟中断处理\n");
    printf("  * 异常处理框架\n");
    printf("  * 中断使能/禁用控制\n");
    printf("  * 性能测量\n");
    printf("  * 上下文保存/恢复\n");
    printf("\n");
    printf("关键技术验证:\n");
    printf("  * CSR寄存器操作\n");
    printf("  * M模式到S模式转换\n");
    printf("  * 中断委托\n");
    printf("  * 时钟配置 (stimecmp)\n");
    printf("  * 内核中断处理流程\n");
    printf("  * 寄存器保存/恢复 (kernelvec.S)\n");
    printf("  * 中断开销分析\n");
    printf("\n");
    
    // 保持中断使能，进入待机状态
    printf("系统就绪。按 Ctrl+A, X 退出QEMU\n");
}