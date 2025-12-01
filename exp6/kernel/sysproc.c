// sysproc.c - 进程相关系统调用实现
#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "proc.h"
#include "syscall.h"

// sys_getpid - 获取当前进程ID
uint64 sys_getpid(void)
{
  struct proc *p = myproc();
  return p->pid;
}

// sys_exit - 进程退出
uint64 sys_exit(void)
{
  int status;
  argint(0, &status);
  exit_process(status);
  return 0;  // 不会到达这里
}

// sys_wait - 等待子进程
uint64 sys_wait(void)
{
  uint64 addr;
  int status = 0;
  
  argaddr(0, &addr);
  
  int pid = wait_process(&status);
  
  // 如果提供了地址，将状态写回
  if(pid > 0 && addr != 0) {
    // 简化版：直接赋值（实际应该copyout）
    *(int*)addr = status;
  }
  
  return pid;
}

// sys_fork - 创建子进程
uint64 sys_fork(void)
{
  return fork_process();
}

// sys_yield - 让出CPU
uint64 sys_yield(void)
{
  yield();
  return 0;
}

// sys_sleep - 睡眠指定毫秒
uint64 sys_sleep(void)
{
  int ms;
  argint(0, &ms);
  
  if(ms < 0) {
    return -1;
  }
  
  sleep(0, ms);
  return 0;
}

// sys_uptime - 获取系统运行时间（ticks）
uint64 sys_uptime(void)
{
  return get_ticks();
}

// sys_write - 写数据（简化版，仅支持控制台）
uint64 sys_write(void)
{
  int fd;
  uint64 buf_addr;
  int n;
  
  argint(0, &fd);
  argaddr(1, &buf_addr);
  argint(2, &n);
  
  // 参数检查
  if(n < 0) {
    printf("[错误] write: 无效的长度 %d\n", n);
    return -1;
  }
  
  if(buf_addr == 0) {
    printf("[错误] write: 空指针\n");
    return -1;
  }
  
  // 简化版：仅支持stdout (fd=1) 和 stderr (fd=2)
  if(fd != 1 && fd != 2) {
    printf("[错误] write: 无效的文件描述符 %d\n", fd);
    return -1;
  }
  
  // 直接从内核地址读取（简化版，实际应该copyin）
  char *buf = (char*)buf_addr;
  
  // 逐字符输出
  for(int i = 0; i < n; i++) {
    console_putc(buf[i]);
  }
  
  return n;
}

// sys_read - 读数据（简化版，暂不实现）
uint64 sys_read(void)
{
  int fd;
  uint64 buf_addr;
  int n;
  
  argint(0, &fd);
  argaddr(1, &buf_addr);
  argint(2, &n);
  
  printf("[警告] read系统调用暂未实现\n");
  return -1;
}
