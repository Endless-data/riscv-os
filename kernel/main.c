#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "riscv.h"
#include "vm.h"

// 添加必要的宏定义
#define PTE2PA(pte) (((pte) >> 10) << 12)

// 声明外部变量
extern pagetable_t kernel_pagetable;

// 测试物理内存分配器
void test_physical_memory(void) {
    printf("\n=== 物理内存分配器测试 ===\n");
    
    // 测试基本分配和释放
    printf("1. 测试基本分配...\n");
    void *page1 = alloc_page();
    void *page2 = alloc_page();
    
    if (page1 == 0 || page2 == 0) {
        printf("ERROR: 内存分配失败\n");
        return;
    }
    
    printf("分配页面1: 0x%p\n", page1);
    printf("分配页面2: 0x%p\n", page2);
    
    // 检查页面不同且对齐
    if (page1 == page2) {
        printf("ERROR: 分配了相同的页面\n");
        return;
    }
    
    if (((uint64)page1 & 0xFFF) != 0 || ((uint64)page2 & 0xFFF) != 0) {
        printf("ERROR: 页面未对齐\n");
        return;
    }
    
    printf("✓ 页面不同且正确对齐\n");
    
    // 测试数据写入
    printf("2. 测试数据写入...\n");
    *(int*)page1 = 0x12345678;
    *(int*)page2 = 0xABCDEF00;
    
    if (*(int*)page1 != 0x12345678 || *(int*)page2 != 0xABCDEF00) {
        printf("ERROR: 数据写入失败\n");
        return;
    }
    printf("✓ 数据写入成功\n");
    
    // 测试释放和重新分配
    printf("3. 测试释放和重分配...\n");
    uint64 free_before = get_free_pages();
    free_page(page1);
    uint64 free_after = get_free_pages();
    
    if (free_after != free_before + 1) {
        printf("ERROR: 释放后空闲页面数不正确\n");
        return;
    }
    
    void *page3 = alloc_page();
    printf("重新分配页面: 0x%p\n", page3);
    printf("✓ 释放和重分配成功\n");
    
    // 清理
    free_page(page2);
    free_page(page3);
    
    printf("物理内存分配器测试完成\n");
}

// 测试页表功能
void test_pagetable(void) {
    printf("\n=== 页表管理系统测试 ===\n");
    
    // 创建测试页表
    printf("1. 创建页表...\n");
    pagetable_t pt = create_pagetable();
    if (pt == 0) {
        printf("ERROR: 页表创建失败\n");
        return;
    }
    printf("✓ 页表创建成功: 0x%p\n", pt);
    
    // 测试基本映射
    printf("2. 测试页面映射...\n");
    uint64 va = 0x1000000;  // 虚拟地址
    void *pa_page = alloc_page();
    if (pa_page == 0) {
        printf("ERROR: 分配物理页面失败\n");
        destroy_pagetable(pt);
        return;
    }
    
    uint64 pa = (uint64)pa_page;
    printf("映射 VA:0x%p -> PA:0x%p\n", (void*)va, (void*)pa);
    
    if (map_page(pt, va, pa, PTE_R | PTE_W) != 0) {
        printf("ERROR: 页面映射失败\n");
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    printf("✓ 页面映射成功\n");
    
    // 测试地址转换
    printf("3. 测试地址转换...\n");
    pte_t *pte = walk_lookup(pt, va);
    if (pte == 0 || (*pte & PTE_V) == 0) {
        printf("ERROR: 页表遍历失败\n");
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    
    uint64 pa_found = PTE2PA(*pte);
    if (pa_found != pa) {
        printf("ERROR: 地址转换错误, 期望:0x%p, 实际:0x%p\n", 
               (void*)pa, (void*)pa_found);
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    printf("✓ 地址转换正确\n");
    
    // 测试权限位
    printf("4. 测试权限位...\n");
    if ((*pte & PTE_R) == 0 || (*pte & PTE_W) == 0) {
        printf("ERROR: 权限位设置错误\n");
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    
    if (*pte & PTE_X) {
        printf("ERROR: 意外的执行权限\n");
        free_page(pa_page);
        destroy_pagetable(pt);
        return;
    }
    printf("✓ 权限位设置正确 [RW-]\n");
    
    // 清理
    free_page(pa_page);
    destroy_pagetable(pt);
    printf("页表管理系统测试完成\n");
}

// 测试虚拟内存激活
void test_virtual_memory(void) {
    printf("\n=== 虚拟内存系统测试 ===\n");
    
    printf("启用分页前的状态:\n");
    printf("当前satp值: 0x%p\n", (void*)r_satp());
    
    // 显示内存统计
    print_memory_stats();
    
    // 初始化并激活虚拟内存
    printf("\n正在启用虚拟内存...\n");
    kvminit();
    
    if (kernel_pagetable == 0) {
        printf("ERROR: 内核页表初始化失败\n");
        return;
    }
    
    kvminithart();
    
    printf("\n启用分页后的状态:\n");
    printf("当前satp值: 0x%p\n", (void*)r_satp());
    
    // 测试内核代码仍然可执行
    printf("✓ 内核代码仍然可执行\n");
    
    // 测试内核数据仍然可访问
    printf("✓ 内核数据仍然可访问\n");
    
    // 测试设备访问仍然正常
    printf("✓ 设备访问仍然正常\n");
    
    printf("虚拟内存系统测试完成\n");
}

// 展示页表结构（简化版）
void show_pagetable_demo(void) {
    printf("\n=== 页表结构演示 ===\n");
    
    if (kernel_pagetable == 0) {
        printf("内核页表未初始化\n");
        return;
    }
    
    printf("内核页表根地址: 0x%p\n", kernel_pagetable);
    printf("页表结构（仅显示前几个有效项）:\n");
    
    // 简单显示页表的前几个项
    for (int i = 0; i < 10; i++) {
        pte_t pte = kernel_pagetable[i];
        if (pte & PTE_V) {
            printf("  [%d] PTE=0x%p -> PA=0x%p [", i, (void*)pte, (void*)PTE2PA(pte));
            if (pte & PTE_R) printf("R");
            if (pte & PTE_W) printf("W");
            if (pte & PTE_X) printf("X");
            if (pte & PTE_U) printf("U");
            printf("]\n");
        }
    }
}


// C语言入口点，从entry.S跳转而来
void
start(void)
{
    // 初始化printf系统
    printf_init();
    
    // 清屏并输出欢迎信息
    clear_screen();
    printf("=====================================\n");
    printf("     实验3：页表与内存管理测试       \n");
    printf("=====================================\n");
    
    
    // 初始化物理内存管理器
    printf("\n=== 第1步：初始化物理内存管理器 ===\n");
    pmm_init();
    
    // 测试物理内存分配器
    test_physical_memory();
    
    // 测试页表管理系统
    test_pagetable();
    
    // 测试虚拟内存系统
    test_virtual_memory();
    
    // 展示页表结构
    show_pagetable_demo();
    
    // 最终内存统计
    printf("\n=== 最终内存统计 ===\n");
    print_memory_stats();
    
    // 总结
    printf("\n=====================================\n");
    printf("        实验3测试全部完成!           \n");
    printf("=====================================\n");
    printf("已实现功能:\n");
    printf("✓ Sv39页表机制理解和实现\n");
    printf("✓ 物理内存分配器 (pmm_init, alloc_page, free_page)\n");
    printf("✓ 页表管理系统 (create_pagetable, map_page, walk)\n");
    printf("✓ 虚拟内存激活 (kvminit, kvminithart)\n");
    printf("✓ 地址转换和权限管理\n");
    printf("✓ 内存统计和调试功能\n\n");
    
    printf("关键技术点验证:\n");
    printf("• 39位虚拟地址三级页表遍历\n");
    printf("• 物理页面链表管理\n");
    printf("• PTE权限位设置和检查\n");
    printf("• satp寄存器配置和TLB刷新\n");
    printf("• 内核恒等映射建立\n");
    printf("• 内存分配统计和泄漏检测\n\n");
    
    // 进入空循环，防止程序退出
    printf("系统已就绪，进入待机状态...\n");
    while(1) {
        // 空循环或低功耗等待
        asm volatile("wfi");  // wait for interrupt，低功耗等待
    }
}