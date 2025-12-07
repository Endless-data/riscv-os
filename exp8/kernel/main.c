#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "riscv.h"
#include "param.h"
#include "proc.h"
#include "syscall.h"

// ==================== 系统调用包装函数 ====================

static inline int sys_call_getpid(void) {
  record_syscall(SYS_getpid);
  return (int)sys_getpid();
}

static inline int sys_call_yield(void) {
  record_syscall(SYS_yield);
  return (int)sys_yield();
}

static inline uint64 sys_call_uptime(void) {
  record_syscall(SYS_uptime);
  return sys_uptime();
}

static inline int sys_call_setpriority(int pid, int priority) {
  struct proc *p = myproc();
  if(!p || !p->trapframe) return -1;
  
  p->trapframe->a0 = pid;
  p->trapframe->a1 = priority;
  record_syscall(SYS_setpriority);
  return (int)sys_setpriority();
}

static inline int sys_call_getpriority(int pid) {
  struct proc *p = myproc();
  if(!p || !p->trapframe) return -1;
  
  p->trapframe->a0 = pid;
  record_syscall(SYS_getpriority);
  return (int)sys_getpriority();
}

// ==================== 测试任务 ====================

// 高优先级任务
void high_priority_task(void)
{
  set_proc_name("高优先级");
  int pid = sys_call_getpid();
  
  printf("[高优先级] PID=%d 启动\n", pid);
  sys_call_setpriority(pid, 9);
  
  for(int i = 0; i < 5; i++) {
    printf("[高优先级 PID=%d] 执行 %d/5\n", pid, i+1);
    volatile int sum = 0;
    for(int j = 0; j < 10000; j++) sum += j;
    sys_call_yield();
  }
  
  printf("[高优先级 PID=%d] 完成\n", pid);
  exit_process(0);
}

// 中等优先级任务
void medium_priority_task(void)
{
  set_proc_name("中等优先级");
  int pid = sys_call_getpid();
  
  printf("[中等优先级] PID=%d 启动\n", pid);
  
  for(int i = 0; i < 5; i++) {
    printf("[中等优先级 PID=%d] 执行 %d/5\n", pid, i+1);
    volatile int sum = 0;
    for(int j = 0; j < 5000; j++) sum += j;
    sys_call_yield();
  }
  
  printf("[中等优先级 PID=%d] 完成\n", pid);
  exit_process(0);
}

// 低优先级任务
void low_priority_task(void)
{
  set_proc_name("低优先级");
  int pid = sys_call_getpid();
  
  printf("[低优先级] PID=%d 启动\n", pid);
  sys_call_setpriority(pid, 2);
  
  for(int i = 0; i < 8; i++) {
    printf("[低优先级 PID=%d] 执行 %d/8\n", pid, i+1);
    volatile int sum = 0;
    for(int j = 0; j < 3000; j++) sum += j;
    sys_call_yield();
  }
  
  printf("[低优先级 PID=%d] 完成\n", pid);
  exit_process(0);
}

// 长时间运行的高优先级任务
void long_high_priority_task(void)
{
  set_proc_name("高优先级");
  int pid = sys_call_getpid();
  
  printf("[高优先级] PID=%d 启动\n", pid);
  sys_call_setpriority(pid, 9);
  
  // 执行20次，让低优先级有时间等待
  for(int i = 0; i < 20; i++) {
    int current_priority = sys_call_getpriority(pid);
    printf("[高优先级 PID=%d 优先级=%d] 执行 %d/20\n", 
           pid, current_priority, i+1);
    
    volatile int sum = 0;
    for(int j = 0; j < 50000; j++) sum += j;  // 增加计算量
    sys_call_yield();
  }
  
  printf("[高优先级 PID=%d] 完成\n", pid);
  exit_process(0);
}

// 会被Aging提升的低优先级任务
void aging_low_priority_task(void)
{
  set_proc_name("低优先级");
  int pid = sys_call_getpid();
  
  printf("[低优先级] PID=%d 启动，初始优先级=2\n", pid);
  sys_call_setpriority(pid, 2);
  
  for(int i = 0; i < 15; i++) {
    int current_priority = sys_call_getpriority(pid);
    printf("[低优先级 PID=%d 优先级=%d] 执行 %d/15", 
           pid, current_priority, i+1);
    
    // 显示优先级变化
    if(i > 0) {
      static int last_priority = 2;
      if(current_priority != last_priority) {
        printf(" ← Aging提升！(%d→%d)", last_priority, current_priority);
        last_priority = current_priority;
      }
    }
    printf("\n");
    
    volatile int sum = 0;
    for(int j = 0; j < 30000; j++) sum += j;
    sys_call_yield();
  }
  
  printf("[低优先级 PID=%d] 完成\n", pid);
  exit_process(0);
}


// ==================== 测试场景 ====================

// 测试1：优先级竞争
void test_priority_competition(void)
{
  printf("\n╔══════════════════════════════════════╗\n");
  printf("║   测试1：优先级竞争                 ║\n");
  printf("╚══════════════════════════════════════╝\n\n");
  
  int pid_low = create_process(low_priority_task);
  int pid_medium = create_process(medium_priority_task);
  int pid_high = create_process(high_priority_task);
  
  printf("创建任务: 高(%d) 中(%d) 低(%d)\n\n", pid_high, pid_medium, pid_low);
  
  for(int i = 0; i < 3; i++) {
    int status;
    int wpid = wait_process(&status);
    printf("✓ 进程 %d 完成\n", wpid);
  }
  
  printf("\n✓ 测试1完成\n");
}

// 测试2：动态优先级调整
void test_dynamic_priority(void)
{
  printf("\n╔══════════════════════════════════════╗\n");
  printf("║   测试2：动态优先级调整             ║\n");
  printf("╚══════════════════════════════════════╝\n\n");
  
  int pid = create_process(medium_priority_task);
  printf("创建任务 PID=%d\n", pid);
  
  for(int i = 0; i < 100000; i++);
  
  printf("提升 PID=%d 优先级到 8\n", pid);
  sys_call_setpriority(pid, 8);
  
  int priority = sys_call_getpriority(pid);
  printf("当前优先级=%d\n\n", priority);
  
  int status;
  wait_process(&status);
  
  printf("\n✓ 测试2完成\n");
}

// 测试3：Aging机制验证
void test_aging_mechanism(void)
{
  printf("\n╔══════════════════════════════════════╗\n");
  printf("║   测试3：Aging机制验证              ║\n");
  printf("╚══════════════════════════════════════╝\n\n");
  
  printf("说明: 低优先级进程长时间等待后，Aging机制会提升其优先级\n");
  printf("期望: 看到低优先级从2逐渐提升到更高值\n\n");
  
  // 先创建低优先级，让它开始等待
  int pid_low = create_process(aging_low_priority_task);
  
  // 短暂延迟
  for(volatile int i = 0; i < 100000; i++);
  
  // 再创建高优先级，抢占CPU
  int pid_high = create_process(long_high_priority_task);
  
  printf("创建顺序: 低(%d,优先级=2) → 高(%d,优先级=9)\n\n", pid_low, pid_high);
  printf("预期: 低优先级进程会等待，然后被Aging提升优先级\n\n");
  
  // 等待两个进程完成
  for(int i = 0; i < 2; i++) {
    int status;
    int wpid = wait_process(&status);
    printf("✓ 进程 %d 完成\n", wpid);
  }
  
  printf("\n✓ 测试3完成\n");
  printf("观察: 低优先级进程的优先级是否随时间增长而提升\n");
}

// 测试4：相同优先级公平性
void test_same_priority_fairness(void)
{
  printf("\n╔══════════════════════════════════════╗\n");
  printf("║   测试4：相同优先级公平性           ║\n");
  printf("╚══════════════════════════════════════╝\n\n");
  
  int pid1 = create_process(medium_priority_task);
  int pid2 = create_process(medium_priority_task);
  int pid3 = create_process(medium_priority_task);
  
  printf("创建3个相同优先级任务\n");
  printf("  PID=%d\n  PID=%d\n  PID=%d\n\n", pid1, pid2, pid3);
  
  for(int i = 0; i < 3; i++) {
    int status;
    wait_process(&status);
  }
  
  printf("\n✓ 测试4完成\n");
}

// ==================== 主测试进程 ====================
void main_test_process(void)
{
  set_proc_name("主测试");
  printf("\n[主进程] 开始优先级调度测试\n");
  
  set_syscall_debug(0);
  
  test_priority_competition();
  
  test_dynamic_priority();
  
  test_aging_mechanism();
  
  test_same_priority_fairness();
  
  show_syscall_stats();
  
  printf("\n╔══════════════════════════════════════╗\n");
  printf("║      所有测试完成！                 ║\n");
  printf("╚══════════════════════════════════════╝\n");
  
  exit_process(0);
}

// ==================== 主函数 ====================
void
main(void)
{
  printf_init();
  clear_screen();
  
  printf("╔══════════════════════════════════════╗\n");
  printf("║   实验8：优先级调度系统             ║\n");
  printf("╚══════════════════════════════════════╝\n");
  printf("Hart ID: %d\n", (int)r_tp());
  
  printf("\n[初始化] 物理内存管理\n");
  pmm_init();
  
  printf("\n[初始化] 中断系统\n");
  trapinit();
  
  printf("\n[初始化] 优先级调度系统\n");
  procinit();
  printf("  默认优先级: %d\n", DEFAULT_PRIORITY);
  printf("  范围: [%d, %d]\n", MIN_PRIORITY, MAX_PRIORITY);
  printf("  Aging阈值: %d\n", AGING_THRESHOLD);
  
  printf("\n[创建] 主测试进程\n");
  int pid = create_process(main_test_process);
  if(pid < 0) {
    panic("创建失败");
  }
  printf("  PID=%d\n", pid);
  
  printf("\n[启动] 优先级调度器\n");
  
  intr_on();
  scheduler();
  
  panic("scheduler returned");
}
