// platform.h - 平台相关定义
#ifndef _PLATFORM_H_
#define _PLATFORM_H_

// UART 基地址（QEMU virt 机器）
#define UART0 0x10000000L

// 内存布局
#define KERNBASE 0x80000000L
#define PHYSTOP  (KERNBASE + 128*1024*1024)  // 128MB

// 页面大小
#define PGSIZE 4096

#endif // _PLATFORM_H_
