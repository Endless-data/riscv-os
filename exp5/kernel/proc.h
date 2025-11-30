// proc.h - 进程管理数据结构
#ifndef _PROC_H_
#define _PROC_H_

#include "types.h"

// 保存的寄存器上下文用于内核上下文切换
struct context {
  uint64 ra;      // 返回地址
  uint64 sp;      // 栈指针
  
  // 被调用者保存的寄存器
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

// CPU状态
struct cpu {
  struct proc *proc;          // 当前运行的进程，null表示空闲
  struct context scheduler;   // 调度器上下文
  int noff;                   // push_off()嵌套深度
  int intena;                 // push_off()之前的中断状态
};

// 进程状态
enum procstate { 
  UNUSED,     // 未使用
  USED,       // 已分配但未就绪
  SLEEPING,   // 睡眠中
  RUNNABLE,   // 可运行
  RUNNING,    // 正在运行
  ZOMBIE      // 僵尸状态
};

// 进程控制块
struct proc {
  enum procstate state;        // 进程状态
  int pid;                     // 进程ID
  uint64 kstack;               // 内核栈虚拟地址
  struct context context;      // 进程上下文
  char name[16];               // 进程名（用于调试）
  void *chan;                  // 睡眠通道
  int killed;                  // 是否被杀死
  uint64 wakeup_time;          // 唤醒时间（用于sleep）
  uint64 runtime;              // 累计运行时间
  uint64 start_time;           // 进程创建时间
};

#endif // _PROC_H_
