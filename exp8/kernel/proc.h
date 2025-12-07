// proc.h - 进程管理数据结构
#ifndef _PROC_H_
#define _PROC_H_

#include "types.h"

// Trapframe - 保存用户进程寄存器（用于系统调用和中断）
struct trapframe {
  /*   0 */ uint64 kernel_satp;   // 内核页表
  /*   8 */ uint64 kernel_sp;     // 内核栈顶
  /*  16 */ uint64 kernel_trap;   // trap处理函数
  /*  24 */ uint64 epc;           // 用户程序计数器
  /*  32 */ uint64 kernel_hartid; // hartid
  /*  40 */ uint64 ra;
  /*  48 */ uint64 sp;
  /*  56 */ uint64 gp;
  /*  64 */ uint64 tp;
  /*  72 */ uint64 t0;
  /*  80 */ uint64 t1;
  /*  88 */ uint64 t2;
  /*  96 */ uint64 s0;
  /* 104 */ uint64 s1;
  /* 112 */ uint64 a0;
  /* 120 */ uint64 a1;
  /* 128 */ uint64 a2;
  /* 136 */ uint64 a3;
  /* 144 */ uint64 a4;
  /* 152 */ uint64 a5;
  /* 160 */ uint64 a6;
  /* 168 */ uint64 a7;
  /* 176 */ uint64 s2;
  /* 184 */ uint64 s3;
  /* 192 */ uint64 s4;
  /* 200 */ uint64 s5;
  /* 208 */ uint64 s6;
  /* 216 */ uint64 s7;
  /* 224 */ uint64 s8;
  /* 232 */ uint64 s9;
  /* 240 */ uint64 s10;
  /* 248 */ uint64 s11;
  /* 256 */ uint64 t3;
  /* 264 */ uint64 t4;
  /* 272 */ uint64 t5;
  /* 280 */ uint64 t6;
};

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
  struct trapframe *trapframe; // 用于系统调用的寄存器保存区
  char name[16];               // 进程名（用于调试）
  void *chan;                  // 睡眠通道
  int killed;                  // 是否被杀死
  int xstate;                  // 退出状态
  uint64 wakeup_time;          // 唤醒时间（用于sleep）
  uint64 runtime;              // 累计运行时间
  uint64 start_time;           // 进程创建时间
  
  // 优先级调度相关字段
  int priority;                // 进程优先级 (0-10, 默认5, 值越大优先级越高)
  int ticks;                   // 已使用CPU时间片计数
  uint64 wait_time;            // 等待时长（用于aging机制）
};

// 优先级调度常量
#define DEFAULT_PRIORITY 5      // 默认优先级
#define MIN_PRIORITY 0          // 最低优先级
#define MAX_PRIORITY 10         // 最高优先级
#define AGING_THRESHOLD 10      // aging触发阈值（ticks）
#define AGING_BOOST 1           // aging时优先级提升量

#endif // _PROC_H_
