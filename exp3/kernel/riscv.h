// RISC-V CPU特定定义

#ifndef _RISCV_H_
#define _RISCV_H_

#include "types.h"

// 页表类型定义
typedef uint64 pte_t;             // 页表项类型
typedef uint64 *pagetable_t;      // 页表指针类型

// 内联汇编函数：读写satp寄存器
static inline uint64
r_satp()
{
  uint64 x;
  asm volatile("csrr %0, satp" : "=r" (x) );
  return x;
}

static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
}

// 内存屏障指令
static inline void
sfence_vma()
{
  // 刷新TLB的全部条目
  asm volatile("sfence.vma zero, zero");
}

// 等待中断指令
static inline void
wfi()
{
  asm volatile("wfi");
}

#endif // _RISCV_H_