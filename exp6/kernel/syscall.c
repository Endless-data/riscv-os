// syscall.c - 系统调用框架实现
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"

// 调试开关
static int debug_syscalls = 1;

// 系统调用名称（用于调试）
static const char* syscall_names[10] = {
  [0]           = 0,
  [SYS_getpid]  = "getpid",
  [SYS_exit]    = "exit",
  [SYS_wait]    = "wait",
  [SYS_fork]    = "fork",
  [SYS_yield]   = "yield",
  [SYS_sleep]   = "sleep",
  [SYS_uptime]  = "uptime",
  [SYS_write]   = "write",
  [SYS_read]    = "read",
};

// 从trapframe获取第n个参数（原始值）
static uint64 argraw(int n)
{
  struct proc *p = myproc();
  struct trapframe *tf = p->trapframe;
  
  switch (n) {
  case 0:
    return tf->a0;
  case 1:
    return tf->a1;
  case 2:
    return tf->a2;
  case 3:
    return tf->a3;
  case 4:
    return tf->a4;
  case 5:
    return tf->a5;
  }
  
  panic("argraw: invalid argument number");
  return -1;
}

// 获取整型参数
void argint(int n, int *ip)
{
  *ip = argraw(n);
}

// 获取地址参数
void argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
}

// 系统调用函数声明
extern uint64 sys_getpid(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_fork(void);
extern uint64 sys_yield(void);
extern uint64 sys_sleep(void);
extern uint64 sys_uptime(void);
extern uint64 sys_write(void);
extern uint64 sys_read(void);

// 系统调用表
static uint64 (*syscalls[])(void) = {
  [SYS_getpid]  sys_getpid,
  [SYS_exit]    sys_exit,
  [SYS_wait]    sys_wait,
  [SYS_fork]    sys_fork,
  [SYS_yield]   sys_yield,
  [SYS_sleep]   sys_sleep,
  [SYS_uptime]  sys_uptime,
  [SYS_write]   sys_write,
  [SYS_read]    sys_read,
};

// 系统调用统计
static uint64 syscall_counts[10] = {0};
static uint64 syscall_total = 0;

// 手动记录系统调用（用于直接调用时）
void record_syscall(int num)
{
  if(num > 0 && num < 10) {
    syscall_counts[num]++;
    syscall_total++;
  }
}

// 系统调用分发器
void syscall(void)
{
  int num;
  struct proc *p = myproc();
  
  if(!p || !p->trapframe) {
    panic("syscall: no process or trapframe");
  }
  
  // 系统调用号在a7寄存器
  num = p->trapframe->a7;
  
  // 调试输出
  if(debug_syscalls && num > 0 && num < 10) {
    printf("[系统调用] PID=%d 调用 %s (编号=%d)\n",
           p->pid, syscall_names[num], num);
  }
  
  // 检查系统调用号是否有效
  if(num > 0 && num < 10 && syscalls[num]) {
    // 调用对应的系统调用处理函数
    uint64 ret = syscalls[num]();
    
    // 返回值放在a0寄存器
    p->trapframe->a0 = ret;
    
    // 统计
    syscall_counts[num]++;
    syscall_total++;
    
    // 调试输出
    if(debug_syscalls) {
      printf("[系统调用] %s 返回值=%d\n", syscall_names[num], (int)ret);
    }
  } else {
    printf("[错误] PID=%d: 未知系统调用 %d\n", p->pid, num);
    p->trapframe->a0 = -1;
  }
}

// 显示系统调用统计信息
void show_syscall_stats(void)
{
  printf("\n=== 系统调用统计 ===\n");
  printf("总调用次数: %d\n", (int)syscall_total);
  printf("\n各系统调用次数:\n");
  
  for(int i = 1; i < 10; i++) {
    if(syscall_counts[i] > 0 && syscall_names[i]) {
      printf("  %s: %d 次\n", syscall_names[i], (int)syscall_counts[i]);
    }
  }
  printf("====================\n");
}

// 设置调试开关
void set_syscall_debug(int enable)
{
  debug_syscalls = enable;
}
