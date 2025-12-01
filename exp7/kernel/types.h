#ifndef _TYPES_H_
#define _TYPES_H_

// 基本类型定义
typedef int                uint;
typedef unsigned char      uint8;
typedef unsigned short     uint16;
typedef unsigned int       uint32;
typedef unsigned long      uint64;
typedef uint64             pde_t;

// 页表相关类型
typedef uint64 pte_t;      // 页表项类型
typedef uint64 *pagetable_t; // 页表指针类型

#endif // _TYPES_H_