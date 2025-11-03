/*
 * xv6页表管理深度分析
 * ==================
 * 
 * 1. walk()函数分析
 * ================
 * 
 * 函数原型：
 * pte_t *walk(pagetable_t pagetable, uint64 va, int alloc)
 * 
 * 功能：根据虚拟地址找到对应的页表项指针
 * 参数：
 * - pagetable: 根页表指针
 * - va: 虚拟地址
 * - alloc: 是否在页表项不存在时自动分配
 * 
 * 核心算法分析：
 * 
 * 1. 地址范围检查：
 *    if(va >= MAXVA) panic("walk");
 *    防止访问超出39位地址空间的地址
 * 
 * 2. 三级页表递归遍历：
 *    for(int level = 2; level > 0; level--)
 *    从根页表(level 2)开始，逐级向下查找
 * 
 * 3. 页表项查找与创建：
 *    pte_t *pte = &pagetable[PX(level, va)];
 *    PX(level, va)提取当前级别的页表索引
 * 
 * 4. 有效性检查与下级页表获取：
 *    if(*pte & PTE_V) {
 *        pagetable = (pagetable_t)PTE2PA(*pte);
 *    }
 *    如果当前PTE有效，提取物理地址作为下级页表
 * 
 * 5. 按需分配机制：
 *    if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
 *        return 0;
 *    memset(pagetable, 0, PGSIZE);
 *    *pte = PA2PTE(pagetable) | PTE_V;
 *    
 * 关键思考：
 * - 为什么level从2开始到1结束？
 *   因为level 0是叶子级，直接返回其地址
 * - 如何避免无限递归？
 *   通过固定的3级深度和明确的终止条件
 * - 内存分配失败如何处理？
 *   返回0，上层调用者需要检查并处理错误
 * 
 * 2. mappages()函数分析
 * ====================
 * 
 * 函数原型：
 * int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
 * 
 * 功能：为一段虚拟地址范围创建到物理地址的映射
 * 
 * 核心步骤：
 * 
 * 1. 地址对齐检查：
 *    if((va % PGSIZE) != 0) panic("mappages: va not aligned");
 *    if((size % PGSIZE) != 0) panic("mappages: size not aligned");
 *    确保虚拟地址和大小都按页对齐
 * 
 * 2. 逐页映射循环：
 *    for(a = va; a <= last; a += PGSIZE, pa += PGSIZE) {
 *        pte = walk(pagetable, a, 1);
 *        *pte = PA2PTE(pa) | perm | PTE_V;
 *    }
 * 
 * 3. 重映射检查：
 *    if(*pte & PTE_V) panic("mappages: remap");
 *    防止重复映射同一虚拟地址
 * 
 * 4. PTE设置：
 *    *pte = PA2PTE(pa) | perm | PTE_V;
 *    设置物理页号、权限位和有效位
 * 
 * 错误恢复机制：
 * - walk()失败时返回-1，但已经建立的映射不会自动清理
 * - 这是一个设计缺陷，实际系统应该支持部分失败时的回滚
 * 
 * 3. 关键宏定义分析
 * ================
 * 
 * PX(level, va)：提取页表索引
 * #define PX(level, va) ((((uint64) (va)) >> PXSHIFT(level)) & PXMASK)
 * 
 * 计算过程：
 * - PXSHIFT(2) = 12 + 9*2 = 30，提取位[38:30]
 * - PXSHIFT(1) = 12 + 9*1 = 21，提取位[29:21]  
 * - PXSHIFT(0) = 12 + 9*0 = 12，提取位[20:12]
 * 
 * PA2PTE(pa)：物理地址转PTE
 * #define PA2PTE(pa) ((((uint64)pa) >> 12) << 10)
 * 将物理地址右移12位得到PPN，再左移10位到PTE的正确位置
 * 
 * PTE2PA(pte)：PTE转物理地址
 * #define PTE2PA(pte) (((pte) >> 10) << 12)
 * 提取PPN并左移12位得到物理地址
 * 
 * 4. 页表一致性保证
 * ================
 * 
 * 内存屏障：
 * - walk()中分配新页表后会memset清零
 * - mappages()设置PTE前会检查重映射
 * - kvminithart()中使用sfence_vma()刷新TLB
 * 
 * 原子性考虑：
 * - 单个PTE的设置是原子的（64位写入）
 * - 多页映射不是原子的，可能需要额外的锁保护
 * 
 * 5. 性能优化思路
 * ==============
 * 
 * TLB缓存优化：
 * - 减少不必要的sfence_vma()调用
 * - 批量映射时延迟TLB刷新
 * 
 * 内存预分配：
 * - 预先分配常用的页表页面
 * - 减少临时分配的开销
 * 
 * 大页支持：
 * - 在适当的情况下使用2MB/1GB大页
 * - 减少页表层级和TLB压力
 */

#ifndef _VM_ANALYSIS_H_
#define _VM_ANALYSIS_H_

// 页表遍历调试辅助
void debug_walk(pagetable_t pt, uint64 va);
void validate_pagetable_consistency(pagetable_t pt);
int count_mapped_pages(pagetable_t pt);

#endif // _VM_ANALYSIS_H_