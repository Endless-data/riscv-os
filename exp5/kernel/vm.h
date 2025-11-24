/*
 * Sv39页表机制深度解析
 * ===================
 * 
 * 1. 39位虚拟地址分解
 * -----------------
 * RISC-V Sv39采用39位虚拟地址空间，地址分解如下：
 * 
 * 位域分布：
 * 38 30 29 21 20 12 11  0
 * |VPN[2]|VPN[1]|VPN[0]|offset|
 *   9位   9位    9位   12位
 * 
 * - VPN[2] (38:30): 一级页表索引，9位，范围0-511
 * - VPN[1] (29:21): 二级页表索引，9位，范围0-511  
 * - VPN[0] (20:12): 三级页表索引，9位，范围0-511
 * - offset (11:0):  页内偏移，12位，范围0-4095
 * 
 * Q: 为什么是9位而不是其他位数？
 * A: 每个页表页面大小为4KB(4096字节)，每个PTE为8字节，
 *    因此每页可容纳 4096/8 = 512 个PTE，需要9位索引(2^9=512)
 * 
 * 2. 页表项(PTE)格式
 * ----------------
 * 64位PTE的位域分布：
 * 63    54 53  28 27  19 18  10 9   8 7 6 5 4 3 2 1 0
 * |Reserved|PPN[2]|PPN[1]|PPN[0]|RSW|D|A|G|U|X|W|R|V|
 * 
 * 关键位含义：
 * - V (0): Valid位，标识PTE是否有效
 * - R (1): Readable，页面可读权限
 * - W (2): Writable，页面可写权限  
 * - X (3): Executable，页面可执行权限
 * - U (4): User，用户态可访问权限
 * - G (5): Global，全局页面标记
 * - A (6): Accessed，访问位(硬件设置)
 * - D (7): Dirty，脏位(硬件设置)
 * - RSW (9:8): 保留给软件使用
 * - PPN (53:10): 物理页号，44位
 * 
 * 3. 三级页表设计的优势
 * ==================
 * 
 * Q: 为什么选择三级页表而不是二级或四级？
 * A: 
 * - 二级页表：地址空间太小，无法满足64位系统需求
 * - 四级页表：内存开销更大，地址转换延迟更高
 * - 三级页表：平衡了地址空间大小(512GB)与性能开销
 * 
 * 地址空间计算：
 * - 每级索引9位，共3级：9+9+9+12 = 39位
 * - 虚拟地址空间：2^39 = 512GB
 * - 每个进程可使用512GB虚拟内存，对大多数应用足够
 * 
 * 4. 中间级页表项的权限设置
 * ========================
 * 中间级页表项(非叶子节点)的R/W/X位应该设置为0，因为：
 * - 中间级PTE只是指向下一级页表的指针
 * - 只有叶子级PTE才描述实际的内存页面权限
 * - 如果中间级PTE的R/W/X不全为0，硬件会将其解释为大页面
 * 
 * 5. 页表存储机制
 * ==============
 * "页表也存储在物理内存中"的含义：
 * - 页表本身就是内存中的数据结构
 * - 每个页表占用一个物理页面(4KB)
 * - 页表页面通过物理内存分配器分配
 * - satp寄存器存储根页表的物理地址
 */

#ifndef _VM_H_
#define _VM_H_

#include "types.h"
#include "riscv.h"
#include "memlayout.h"

// 虚拟地址解析辅助函数

// 从虚拟地址提取各级页表索引
#define VPN_0(va) (((va) >> 12) & 0x1FF)  // 第0级索引(叶子级)
#define VPN_1(va) (((va) >> 21) & 0x1FF)  // 第1级索引  
#define VPN_2(va) (((va) >> 30) & 0x1FF)  // 第2级索引(根级)

// 页表遍历级别定义
#define PT_LEVEL_ROOT   2  // 根页表级别
#define PT_LEVEL_MIDDLE 1  // 中间页表级别  
#define PT_LEVEL_LEAF   0  // 叶子页表级别

// 页表项权限组合
#define PTE_KERN_RO  (PTE_R | PTE_V)                // 内核只读
#define PTE_KERN_RW  (PTE_R | PTE_W | PTE_V)        // 内核读写
#define PTE_KERN_RX  (PTE_R | PTE_X | PTE_V)        // 内核读执行
#define PTE_USER_RO  (PTE_R | PTE_U | PTE_V)        // 用户只读
#define PTE_USER_RW  (PTE_R | PTE_W | PTE_U | PTE_V) // 用户读写
#define PTE_USER_RX  (PTE_R | PTE_X | PTE_U | PTE_V) // 用户读执行

// 页表操作函数声明
pagetable_t create_pagetable(void);
void destroy_pagetable(pagetable_t pt);
pte_t* walk_create(pagetable_t pt, uint64 va);
pte_t* walk_lookup(pagetable_t pt, uint64 va);
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm);
void dump_pagetable(pagetable_t pt, int level);

#endif // _VM_H_