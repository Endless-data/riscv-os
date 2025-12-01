// 物理内存管理器实现
// 基于xv6的设计思路，添加统计和扩展功能

#include "types.h"
#include "memlayout.h"
#include "kalloc.h"
#include "defs.h"

// 空闲页面链表节点（利用空闲页面本身存储）
struct run {
    struct run *next;
};

// 内存管理器状态
struct {
    struct run *freelist;    // 空闲页面链表头
    uint64 total_pages;      // 总页面数
    uint64 free_pages;       // 空闲页面数  
    uint64 used_pages;       // 已使用页面数
} pmm;

// 外部符号：内核结束地址（由链接脚本定义）
extern char end[];

// 简单的内存设置函数（类似memset）
void* memset_simple(void *dst, int c, uint n) {
    char *d = (char*)dst;
    int i;
    for (i = 0; i < n; i++) {
        d[i] = c;
    }
    return dst;
}

// 释放一段内存范围到空闲链表
void freerange(void *pa_start, void *pa_end) {
    char *p;
    p = (char*)PGROUNDUP((uint64)pa_start);
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
        free_page(p);
    }
}

// 初始化物理内存管理器
void pmm_init(void) {
    printf("初始化物理内存管理器...\n");
    
    // 计算可用内存范围
    char *start = (char*)PGROUNDUP((uint64)end);
    char *stop = (char*)PHYSTOP;
    
    printf("内存范围: 0x%p - 0x%p\n", start, stop);
    printf("内核结束地址: 0x%p\n", end);
    
    // 计算总页面数
    pmm.total_pages = ((uint64)stop - (uint64)start) / PGSIZE;
    printf("总页面数: %d\n", (int)pmm.total_pages);
    
    // 释放所有可用内存到空闲链表
    freerange(end, (void*)PHYSTOP);
    
    printf("物理内存管理器初始化完成\n");
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
}

// 分配一个物理页面
void* alloc_page(void) {
    struct run *r;
    
    // 检查是否有空闲页面
    if (pmm.freelist == 0) {
        return 0;  // 内存耗尽
    }
    
    // 取出链表头部页面
    r = pmm.freelist;
    pmm.freelist = r->next;
    
    // 更新统计信息
    pmm.free_pages--;
    pmm.used_pages++;
    
    // 清零页面内容（安全考虑）
    memset_simple((char*)r, 5, PGSIZE);
    
    return (void*)r;
}

// 释放一个物理页面
void free_page(void* pa) {
    struct run *r;
    
    // 地址有效性检查
    if (((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP) {
        printf("free_page: 无效地址 0x%p\n", pa);
        return;
    }
    
    // 填充垃圾数据（帮助检测悬空引用）
    memset_simple(pa, 1, PGSIZE);
    
    // 将页面添加到空闲链表头部
    r = (struct run*)pa;
    r->next = pmm.freelist;
    pmm.freelist = r;
    
    // 更新统计信息
    pmm.free_pages++;
    if (pmm.used_pages > 0) {
        pmm.used_pages--;
    }
}

// 分配连续的n个页面（简单实现）
void* alloc_pages(int n) {
    if (n <= 0) return 0;
    if (n == 1) return alloc_page();
    
    // 简单实现：仅支持单页分配
    // 实际的伙伴系统实现会更复杂
    printf("alloc_pages: 暂不支持多页分配 (n=%d)\n", n);
    return 0;
}

// 获取空闲页面数量
uint64 get_free_pages(void) {
    return pmm.free_pages;
}

// 打印内存使用统计
void print_memory_stats(void) {
    printf("=== 内存使用统计 ===\n");
    printf("总页面数:   %d\n", (int)pmm.total_pages);
    printf("空闲页面数: %d\n", (int)pmm.free_pages);
    printf("已用页面数: %d\n", (int)pmm.used_pages);
    printf("总内存:     %d KB\n", (int)(pmm.total_pages * PGSIZE / 1024));
    printf("空闲内存:   %d KB\n", (int)(pmm.free_pages * PGSIZE / 1024));
    printf("已用内存:   %d KB\n", (int)(pmm.used_pages * PGSIZE / 1024));
    
    if (pmm.total_pages > 0) {
        int usage = (int)((pmm.used_pages * 100) / pmm.total_pages);
        printf("内存使用率: %d%%\n", usage);
    }
    printf("==================\n");
}