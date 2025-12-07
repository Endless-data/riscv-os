// proc.c - 进程管理实现
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "proc.h"
#include "defs.h"

// 全局CPU结构
struct cpu cpu;

// 进程表
struct proc proc[NPROC];

// 下一个可用的PID
static int nextpid = 1;

// 外部函数声明
extern void swtch(struct context*, struct context*);

// 初始化进程系统
void procinit(void)
{
  struct proc *p;
  
  // 初始化CPU结构
  cpu.proc = 0;
  cpu.noff = 0;
  cpu.intena = 0;
  
  // 初始化进程表
  for(p = proc; p < &proc[NPROC]; p++) {
    p->state = UNUSED;
    p->pid = 0;
    p->kstack = 0;
    p->name[0] = 0;
    p->chan = 0;
    p->killed = 0;
    p->runtime = 0;
    p->start_time = 0;
    p->priority = DEFAULT_PRIORITY;  // 初始化优先级
    p->ticks = 0;
    p->wait_time = 0;
  }
}

// 分配一个新的PID
static int allocpid(void)
{
  return nextpid++;
}

// 查找一个未使用的进程结构
static struct proc* allocproc(void)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == UNUSED) {
      goto found;
    }
  }
  return 0;
  
found:
  p->pid = allocpid();
  p->state = USED;
  p->start_time = r_time();
  p->runtime = 0;
  p->killed = 0;
  p->chan = 0;
  p->xstate = 0;
  
  // 初始化优先级调度字段
  p->priority = DEFAULT_PRIORITY;
  p->ticks = 0;
  p->wait_time = 0;
  
  // 分配内核栈
  p->kstack = (uint64)alloc_page();
  if(p->kstack == 0) {
    p->state = UNUSED;
    return 0;
  }
  
  // 分配trapframe
  p->trapframe = (struct trapframe*)alloc_page();
  if(p->trapframe == 0) {
    free_page((void*)p->kstack);
    p->kstack = 0;
    p->state = UNUSED;
    return 0;
  }
  
  // 初始化trapframe
  p->trapframe->kernel_satp = 0;
  p->trapframe->kernel_sp = p->kstack + KSTACK_SIZE;
  p->trapframe->kernel_trap = 0;
  p->trapframe->epc = 0;
  p->trapframe->kernel_hartid = 0;
  
  return p;
}

// 释放进程资源
static void freeproc(struct proc *p)
{
  if(p->trapframe) {
    free_page((void*)p->trapframe);
  }
  if(p->kstack) {
    free_page((void*)p->kstack);
  }
  p->trapframe = 0;
  p->kstack = 0;
  p->pid = 0;
  p->state = UNUSED;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->runtime = 0;
  p->start_time = 0;
}

// fork返回函数 - 子进程从这里开始执行
void forkret(void)
{
  // exp7不使用fork，所以这个函数不会被调用
  // 如果意外调用，直接退出
  printf("警告: forkret被意外调用\n");
  exit_process(0);
}

// 创建一个新进程
// task: 进程要执行的函数
int create_process(void (*task)(void))
{
  struct proc *p;
  
  p = allocproc();
  if(p == 0) {
    return -1; // 进程表已满
  }
  
  // 设置进程上下文
  // ra设置为task函数地址，这样当调度器切换到这个进程时，会从task开始执行
  p->context.ra = (uint64)task;
  // sp设置为栈顶（栈向下增长）
  p->context.sp = p->kstack + KSTACK_SIZE;
  
  // 设置进程为可运行状态
  p->state = RUNNABLE;
  
  return p->pid;
}

// fork - 复制当前进程（简化版）
// 注意：这是简化实现，子进程执行 forkret 函数
// 返回：父进程返回子进程PID，失败返回-1
int fork_process(void)
{
  struct proc *np;  // 新进程
  struct proc *p = myproc();  // 当前进程
  
  if(!p) {
    return -1;
  }
  
  // 分配新进程
  np = allocproc();
  if(np == 0) {
    return -1;
  }
  
  // 复制trapframe（保存参数和状态）
  if(p->trapframe && np->trapframe) {
    *(np->trapframe) = *(p->trapframe);
  }
  
  // 设置子进程的上下文
  // 在简化实现中，让子进程执行 forkret 函数
  extern void forkret(void);
  np->context.ra = (uint64)forkret;
  np->context.sp = np->kstack + KSTACK_SIZE;
  
  // 复制进程名称
  int i;
  for(i = 0; i < 16 && p->name[i]; i++) {
    np->name[i] = p->name[i];
  }
  np->name[i] = 0;
  
  // 设置新进程为可运行状态
  np->state = RUNNABLE;
  
  // 父进程返回子进程PID
  return np->pid;
}

// 等待任意一个子进程结束
int wait_process(int *status)
{
  struct proc *p;
  int havekids;
  
  for(;;) {
    havekids = 0;
    
    for(p = proc; p < &proc[NPROC]; p++) {
      if(p->state == ZOMBIE) {
        // 找到一个僵尸进程
        int pid = p->pid;
        if(status) {
          *status = p->xstate;  // 返回进程的退出状态码
        }
        freeproc(p);
        return pid;
      }
      if(p->state != UNUSED) {
        havekids = 1;
      }
    }
    
    if(!havekids) {
      return -1; // 没有子进程
    }
    
    // 让出CPU，等待子进程退出
    yield();
  }
}

// 进程退出
void exit_process(int status)
{
  struct proc *p = cpu.proc;
  
  if(p == 0)
    panic("exit_process: no current process");
  
  p->xstate = status;
  p->state = ZOMBIE;
  
  // 切换到调度器
  sched();
  
  panic("exit_process: zombie returned");
}

// 让出CPU
void yield(void)
{
  struct proc *p = cpu.proc;
  
  if(p) {
    p->state = RUNNABLE;
  }
  
  sched();
}

// 切换到调度器
void sched(void)
{
  struct proc *p = cpu.proc;
  
  if(p == 0)
    return;
  
  // 切换到调度器上下文
  swtch(&p->context, &cpu.scheduler);
}

// 选择最高优先级的可运行进程
static struct proc* select_highest_priority(void)
{
  struct proc *p, *best = 0;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state != RUNNABLE)
      continue;
      
    if(best == 0 || p->priority > best->priority) {
      best = p;
    }
    // 如果优先级相同，选择等待时间更长的（FCFS）
    else if(p->priority == best->priority && p->wait_time > best->wait_time) {
      best = p;
    }
  }
  
  return best;
}

// Aging机制：提升长时间等待进程的优先级
static void aging_boost(void)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == RUNNABLE) {
      p->wait_time++;
      
      // 如果等待时间超过阈值，提升优先级
      if(p->wait_time >= AGING_THRESHOLD && p->priority < MAX_PRIORITY) {
        p->priority += AGING_BOOST;
        p->wait_time = 0;  // 重置等待时间
        
        if(p->priority > MAX_PRIORITY)
          p->priority = MAX_PRIORITY;
      }
    }
  }
}

// 调度器 - 优先级调度算法
void scheduler(void)
{
  struct proc *p;
  uint64 last_aging_time = r_time();
  
  for(;;) {
    // 定期执行aging（每100个时钟周期）
    uint64 now = r_time();
    if(now - last_aging_time > 100000) {  // 约10ms
      aging_boost();
      last_aging_time = now;
    }
    
    // 选择最高优先级的进程
    p = select_highest_priority();
    
    if(p) {
      // 切换到该进程
      p->state = RUNNING;
      p->wait_time = 0;  // 重置等待时间
      cpu.proc = p;
      
      uint64 start = r_time();
      swtch(&cpu.scheduler, &p->context);
      uint64 end = r_time();
      
      // 累加运行时间和时间片计数
      p->runtime += (end - start);
      p->ticks++;
      
      // 进程已经切换回来
      cpu.proc = 0;
      
      // 如果进程是ZOMBIE，清理它
      if(p->state == ZOMBIE) {
        // 在实际系统中，父进程会wait来清理
        // 这里简单处理
      }
    } else {
      // 没有可运行的进程，使能中断并等待
      intr_on();
      asm volatile("wfi"); // 等待中断
      intr_off();
    }
  }
}

// 获取当前进程
struct proc* myproc(void)
{
  return cpu.proc;
}

// 进程睡眠
void sleep(void *chan, int ms)
{
  struct proc *p = cpu.proc;
  
  if(p == 0)
    return;
  
  p->chan = chan;
  p->wakeup_time = r_time() + ms * 10000; // 简单的时间转换
  p->state = SLEEPING;
  
  sched();
  
  p->chan = 0;
}

// 唤醒睡眠在chan上的进程
void wakeup(void *chan)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == SLEEPING && p->chan == chan) {
      p->state = RUNNABLE;
    }
  }
}

// 定期检查并唤醒超时的进程（从时钟中断调用）
void check_sleeping_procs(void)
{
  struct proc *p;
  uint64 now = r_time();
  
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == SLEEPING && p->wakeup_time <= now) {
      p->state = RUNNABLE;
    }
  }
}

// 进程信息调试函数
void debug_proc_table(void)
{
  struct proc *p;
  const char* state_names[] = {
    "UNUSED", "USED", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE"
  };
  
  printf("\n=== 进程表 ===\n");
  printf("PID\t状态\t\t名称\t\t运行时间\n");
  printf("---\t----\t\t----\t\t--------\n");
  
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state != UNUSED) {
      printf("%d\t%s\t%s\t\t%d\n", 
             p->pid, 
             state_names[p->state],
             p->name[0] ? p->name : "(无名)",
             (int)p->runtime);
    }
  }
  
  // 统计信息
  int count[6] = {0};
  for(p = proc; p < &proc[NPROC]; p++) {
    count[p->state]++;
  }
  
  printf("\n进程统计:\n");
  printf("  未使用: %d\n", count[UNUSED]);
  printf("  已分配: %d\n", count[USED]);
  printf("  睡眠中: %d\n", count[SLEEPING]);
  printf("  可运行: %d\n", count[RUNNABLE]);
  printf("  运行中: %d\n", count[RUNNING]);
  printf("  僵尸态: %d\n", count[ZOMBIE]);
  printf("  总计: %d/%d\n", NPROC - count[UNUSED], NPROC);
}

// 设置进程名称
void set_proc_name(const char *name)
{
  struct proc *p = cpu.proc;
  if(p) {
    int i;
    for(i = 0; i < 15 && name[i]; i++) {
      p->name[i] = name[i];
    }
    p->name[i] = 0;
  }
}
