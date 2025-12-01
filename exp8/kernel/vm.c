// 页表管理系统实现
// 基于xv6的设计，实现Sv39三级页表

#include "types.h"
#include "memlayout.h" 
#include "riscv.h"
#include "vm.h"
#include "kalloc.h"
#include "defs.h"

// 内核页表
pagetable_t kernel_pagetable = 0;

// 地址转换宏
#define PA2PTE(pa) ((((uint64)pa) >> 12) << 10)
#define PTE2PA(pte) (((pte) >> 10) << 12)

// 创建新的页表
pagetable_t create_pagetable(void) {
    pagetable_t pt;
    
    // 分配一个页面作为页表
    pt = (pagetable_t)alloc_page();
    if (pt == 0) {
        return 0;  // 内存分配失败
    }
    
    // 清零页表内容
    for (int i = 0; i < 512; i++) {
        pt[i] = 0;
    }
    
    return pt;
}

// 递归释放页表及其子页表
void destroy_pagetable(pagetable_t pt) {
    if (pt == 0) return;
    
    // 遍历所有页表项
    for (int i = 0; i < 512; i++) {
        pte_t pte = pt[i];
        
        // 如果是有效的中间级页表项
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
            // 递归释放子页表
            uint64 child_pa = PTE2PA(pte);
            destroy_pagetable((pagetable_t)child_pa);
        }
    }
    
    // 释放当前页表页面
    free_page((void*)pt);
}

// 页表遍历 - 查找模式（不创建新页表）
pte_t* walk_lookup(pagetable_t pt, uint64 va) {
    if (va >= MAXVA) {
        return 0;  // 地址超出范围
    }
    
    // 从根页表开始，逐级向下查找
    for (int level = 2; level > 0; level--) {
        // 计算当前级别的页表索引
        int index = PX(level, va);
        pte_t *pte = &pt[index];
        
        // 检查页表项是否有效
        if ((*pte & PTE_V) == 0) {
            return 0;  // 页表项无效，路径不存在
        }
        
        // 检查是否为中间级页表项（R/W/X都为0）
        if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
            return 0;  // 这是叶子页面，不应该在中间级出现
        }
        
        // 获取下一级页表的物理地址
        pt = (pagetable_t)PTE2PA(*pte);
    }
    
    // 返回叶子级页表项的地址
    return &pt[PX(0, va)];
}

// 页表遍历 - 创建模式（必要时创建新页表）
pte_t* walk_create(pagetable_t pt, uint64 va) {
    if (va >= MAXVA) {
        printf("walk_create: 地址超出范围 0x%p\n", (void*)va);
        return 0;
    }
    
    // 从根页表开始，逐级向下查找或创建
    for (int level = 2; level > 0; level--) {
        int index = PX(level, va);
        pte_t *pte = &pt[index];
        
        if (*pte & PTE_V) {
            // 页表项已存在，检查是否为中间级页表项
            if ((*pte & (PTE_R | PTE_W | PTE_X)) != 0) {
                printf("walk_create: 遇到叶子页面在级别 %d\n", level);
                return 0;
            }
            // 获取下一级页表
            pt = (pagetable_t)PTE2PA(*pte);
        } else {
            // 页表项不存在，创建新的页表
            pagetable_t new_pt = create_pagetable();
            if (new_pt == 0) {
                printf("walk_create: 分配页表失败在级别 %d\n", level);
                return 0;
            }
            
            // 设置页表项指向新创建的页表
            *pte = PA2PTE((uint64)new_pt) | PTE_V;
            pt = new_pt;
        }
    }
    
    // 返回叶子级页表项的地址
    return &pt[PX(0, va)];
}

// 建立单页映射
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm) {
    pte_t *pte;
    
    // 检查地址对齐
    if ((va % PGSIZE) != 0) {
        printf("map_page: 虚拟地址未对齐 0x%p\n", (void*)va);
        return -1;
    }
    
    if ((pa % PGSIZE) != 0) {
        printf("map_page: 物理地址未对齐 0x%p\n", (void*)pa);
        return -1;
    }
    
    // 获取页表项地址（必要时创建中间级页表）
    pte = walk_create(pt, va);
    if (pte == 0) {
        printf("map_page: walk_create失败\n");
        return -1;
    }
    
    // 检查是否已经映射
    if (*pte & PTE_V) {
        printf("map_page: 地址已映射 0x%p -> 0x%p\n", 
               (void*)va, (void*)PTE2PA(*pte));
        return -1;
    }
    
    // 设置页表项
    *pte = PA2PTE(pa) | perm | PTE_V;
    
    return 0;
}

// 建立连续页面映射
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm) {
    uint64 a, last;
    
    // 检查对齐
    if ((va % PGSIZE) != 0 || (size % PGSIZE) != 0) {
        printf("map_range: 地址或大小未对齐\n");
        return -1;
    }
    
    if (size == 0) {
        return 0;
    }
    
    a = va;
    last = va + size - PGSIZE;
    
    // 逐页建立映射
    for (; ; a += PGSIZE, pa += PGSIZE) {
        if (map_page(pt, a, pa, perm) != 0) {
            printf("map_range: 映射失败在地址 0x%p\n", (void*)a);
            // TODO: 这里应该清理已经建立的映射
            return -1;
        }
        
        if (a == last) {
            break;
        }
    }
    
    return 0;
}

// 打印页表内容（调试用）
void dump_pagetable(pagetable_t pt, int level) {
    // 缩进显示层级
    for (int indent = 0; indent < (3 - level); indent++) {
        printf("  ");
    }
    
    printf("页表级别 %d (物理地址: 0x%p)\n", level, pt);
    
    // 遍历页表项
    for (int i = 0; i < 512; i++) {
        pte_t pte = pt[i];
        
        if (pte & PTE_V) {
            // 显示缩进
            for (int indent = 0; indent < (3 - level); indent++) {
                printf("  ");
            }
            
            printf("  [%d] PTE=0x%p", i, (void*)pte);
            
            if (level > 0 && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
                // 中间级页表项
                printf(" -> 页表 0x%p\n", (void*)PTE2PA(pte));
                if (level > 0) {
                    dump_pagetable((pagetable_t)PTE2PA(pte), level - 1);
                }
            } else {
                // 叶子页表项
                printf(" -> 页面 0x%p [", (void*)PTE2PA(pte));
                if (pte & PTE_R) printf("R");
                if (pte & PTE_W) printf("W");  
                if (pte & PTE_X) printf("X");
                if (pte & PTE_U) printf("U");
                printf("]\n");
            }
        }
    }
}

// 地址转换：虚拟地址转物理地址
uint64 va2pa(pagetable_t pt, uint64 va) {
    pte_t *pte;
    uint64 pa;
    
    if (va >= MAXVA) {
        return 0;
    }
    
    pte = walk_lookup(pt, va);
    if (pte == 0) {
        return 0;  // 未映射
    }
    
    if ((*pte & PTE_V) == 0) {
        return 0;  // 无效映射
    }
    
    pa = PTE2PA(*pte);
    return pa + (va & (PGSIZE - 1));  // 加上页内偏移
}

// 外部符号声明（由链接脚本定义）
extern char etext[];  // 内核代码段结束

// 添加PTE2PA和PX宏的定义（如果在其他地方未定义）
#ifndef PTE2PA
#define PTE2PA(pte) (((pte) >> 10) << 12)
#endif

#ifndef PX
#define PX(level, va) ((((uint64) (va)) >> (PGSHIFT + (9 * (level)))) & 0x1FF)
#endif

// 创建内核页表
pagetable_t kvmmake(void) {
    pagetable_t kpgtbl;
    
    printf("创建内核页表...\n");
    
    // 分配根页表
    kpgtbl = create_pagetable();
    if (kpgtbl == 0) {
        printf("kvmmake: 创建页表失败\n");
        return 0;
    }
    
    printf("映射UART设备...\n");
    // 映射UART设备（恒等映射）
    if (map_page(kpgtbl, UART0, UART0, PTE_R | PTE_W) != 0) {
        printf("kvmmake: UART映射失败\n");
        goto fail;
    }
    
    printf("映射内核代码段...\n");
    // 映射内核代码段（只读+可执行）
    uint64 code_size = PGROUNDUP((uint64)etext - KERNBASE);
    if (map_range(kpgtbl, KERNBASE, code_size, KERNBASE, PTE_R | PTE_X) != 0) {
        printf("kvmmake: 内核代码段映射失败\n");
        goto fail;
    }
    
    printf("映射内核数据段...\n");
    // 映射内核数据段（读写）
    uint64 data_size = PGROUNDUP(PHYSTOP - (uint64)etext);
    if (map_range(kpgtbl, (uint64)etext, data_size, (uint64)etext, PTE_R | PTE_W) != 0) {
        printf("kvmmake: 内核数据段映射失败\n");
        goto fail;
    }
    
    printf("内核页表创建成功\n");
    return kpgtbl;
    
fail:
    destroy_pagetable(kpgtbl);
    return 0;
}

// 初始化内核虚拟内存
void kvminit(void) {
    printf("=== 初始化内核虚拟内存 ===\n");
    
    // 创建内核页表
    kernel_pagetable = kvmmake();
    if (kernel_pagetable == 0) {
        printf("kvminit: 内核页表创建失败!\n");
        return;
    }
    
    printf("内核页表地址: 0x%p\n", kernel_pagetable);
    printf("内核虚拟内存初始化完成\n");
}

// 激活内核页表（启用虚拟内存）
void kvminithart(void) {
    printf("=== 激活虚拟内存系统 ===\n");
    
    if (kernel_pagetable == 0) {
        printf("kvminithart: 内核页表未初始化!\n");
        return;
    }
    
    printf("当前satp寄存器值: 0x%p\n", (void*)r_satp());
    
    // 刷新TLB
    sfence_vma();
    
    // 设置satp寄存器，启用Sv39分页模式
    uint64 satp_val = MAKE_SATP(kernel_pagetable);
    printf("设置satp寄存器: 0x%p\n", (void*)satp_val);
    w_satp(satp_val);
    
    // 再次刷新TLB
    sfence_vma();
    
    printf("新的satp寄存器值: 0x%p\n", (void*)r_satp());
    printf("虚拟内存系统已激活!\n");
}