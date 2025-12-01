// Memory layout definitions for RISC-V

#ifndef _MEMLAYOUT_H_
#define _MEMLAYOUT_H_

// 物理内存布局
#define KERNBASE 0x80000000L       // 内核起始地址
#define PHYSTOP  (KERNBASE + 128*1024*1024) // 物理内存结束位置（128MB）

// UART设备地址
#define UART0 0x10000000L

// 页大小和相关宏定义
#define PGSIZE 4096               // 4KB页面大小
#define PGSHIFT 12                // 页偏移位数

// 页面对齐宏
#define PGROUNDUP(sz)  (((sz)+PGSIZE-1) & ~(PGSIZE-1))
#define PGROUNDDOWN(a) (((a)) & ~(PGSIZE-1))

// Sv39虚拟内存系统常量
#define SATP_SV39 (8L << 60)      // Sv39模式标识
#define MAKE_SATP(pagetable) (SATP_SV39 | (((uint64)pagetable) >> 12))

// 最大虚拟地址（39位地址空间）
#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))

// 内核虚拟地址空间布局
#define TRAMPOLINE (MAXVA - PGSIZE)        // 蹦床页面

// 页表相关常量
#define PTE_V (1L << 0)           // 有效位
#define PTE_R (1L << 1)           // 可读位
#define PTE_W (1L << 2)           // 可写位
#define PTE_X (1L << 3)           // 可执行位
#define PTE_U (1L << 4)           // 用户态可访问位

// 从页表项提取物理页号
#define PTE_PA(pte) (((pte) >> 10) << 12)

// 从虚拟地址提取页表索引的宏（Sv39三级页表）
#define PXMASK          0x1FF     // 9位掩码
#define PXSHIFT(level)  (PGSHIFT+(9*(level)))
#define PX(level, va)   ((((uint64) (va)) >> PXSHIFT(level)) & PXMASK)

#endif // _MEMLAYOUT_H_