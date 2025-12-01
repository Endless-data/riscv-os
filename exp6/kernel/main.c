#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "riscv.h"
#include "param.h"
#include "proc.h"
#include "syscall.h"

// ==================== 系统调用包装函数 ====================

// getpid系统调用
static inline int sys_call_getpid(void) {
  record_syscall(SYS_getpid);
  return (int)sys_getpid();
}

// yield系统调用
static inline int sys_call_yield(void) {
  record_syscall(SYS_yield);
  return (int)sys_yield();
}

// uptime系统调用
static inline uint64 sys_call_uptime(void) {
  record_syscall(SYS_uptime);
  return sys_uptime();
}

// sleep系统调用
static inline int sys_call_sleep(int ms) {
  struct proc *p = myproc();
  if(!p || !p->trapframe) return -1;
  
  // 设置参数
  p->trapframe->a0 = ms;
  record_syscall(SYS_sleep);
  return (int)sys_sleep();
}

// fork系统调用
static inline int sys_call_fork(void) {
  record_syscall(SYS_fork);
  return (int)sys_fork();
}

// write系统调用
static inline int sys_call_write(int fd, const char *buf, int n) {
  struct proc *p = myproc();
  if(!p || !p->trapframe) return -1;
  
  // 设置参数
  p->trapframe->a0 = fd;
  p->trapframe->a1 = (uint64)buf;
  p->trapframe->a2 = n;
  record_syscall(SYS_write);
  return (int)sys_write();
}

// ==================== 测试函数 ====================

// 测试1：基础系统调用测试
void test_basic_syscalls(void)
{
  printf("测试基础系统调用...\n");
  
  // 测试getpid
  printf("  [1] 测试 getpid\n");
  int pid = sys_call_getpid();
  printf("      当前进程 PID: %d\n", pid);
  
  // 测试uptime
  printf("  [2] 测试 uptime\n");
  uint64 uptime = sys_call_uptime();
  printf("      系统运行时间: %d ticks\n", (int)uptime);
  
  // 测试yield
  printf("  [3] 测试 yield\n");
  for(int i = 0; i < 3; i++) {
    printf("      让出CPU %d/3\n", i+1);
    sys_call_yield();
  }
  
  printf("✓ 基础系统调用测试完成\n\n");
}

// 测试2：参数传递测试
void test_parameter_passing(void)
{
  printf("测试参数传递...\n");
  
  // 测试write系统调用
  printf("  [1] 测试 write 系统调用\n");
  char buffer[] = "Hello from syscall!\n";
  
  int bytes_written = sys_call_write(1, buffer, 20);
  printf("      写入 %d 字节\n", bytes_written);
  
  // 测试边界情况
  printf("  [2] 测试边界情况\n");
  
  // 无效文件描述符
  int ret = sys_call_write(-1, buffer, 10);
  printf("      无效fd返回: %d (期望 -1)\n", ret);
  
  // 空指针
  ret = sys_call_write(1, 0, 10);
  printf("      空指针返回: %d (期望 -1)\n", ret);
  
  // 负数长度
  ret = sys_call_write(1, buffer, -1);
  printf("      负数长度返回: %d (期望 -1)\n", ret);
  
  printf("✓ 参数传递测试完成\n\n");
}

// 测试3：性能测试
void test_syscall_performance(void)
{
  printf("测试系统调用性能...\n");
  
  printf("  [1] 测试 10000 次 getpid 调用\n");
  uint64 start_time = get_time();
  
  for(int i = 0; i < 10000; i++) {
    sys_call_getpid();
  }
  
  uint64 end_time = get_time();
  uint64 cycles = end_time - start_time;
  
  printf("      耗时: %d 周期\n", (int)cycles);
  printf("      平均每次调用: %d 周期\n", (int)(cycles / 10000));
  
  printf("✓ 性能测试完成\n\n");
}

// 测试4：sleep系统调用测试
void test_sleep_syscall(void)
{
  printf("测试 sleep 系统调用...\n");
  
  for(int i = 0; i < 3; i++) {
    printf("  [%d] 睡眠 100ms\n", i+1);
    uint64 before = get_time();
    sys_call_sleep(100);
    uint64 after = get_time();
    printf("      实际耗时: %d 周期\n", (int)(after - before));
  }
  
  printf("✓ sleep 测试完成\n\n");
}

// 测试5：简化的fork测试（使用辅助函数）
void fork_child_task(void)
{
  // 这是子进程要执行的代码
  set_proc_name("fork-child");
  printf("    [子进程] PID=%d, 通过fork创建！\n", sys_call_getpid());
  
  for(int i = 0; i < 3; i++) {
    printf("    [子进程 %d] 计数: %d\n", sys_call_getpid(), i+1);
    sys_call_yield();
  }
  
  printf("    [子进程 %d] 退出，返回码: 99\n", sys_call_getpid());
  exit_process(99);
}

void test_fork_syscall(void)
{
  printf("测试 fork 系统调用...\n");
  
  printf("  [1] 父进程准备 fork\n");
  printf("      父进程 PID: %d\n", sys_call_getpid());
  
  int pid = sys_call_fork();
  
  if(pid < 0) {
    printf("      ✗ fork 失败\n");
    return;
  }
  
  printf("      ✓ fork 成功，子进程 PID=%d\n", pid);
  printf("  [2] 父进程等待子进程\n");
  
  int status;
  int wpid = wait_process(&status);
  
  printf("      ✓ 子进程 %d 已退出，状态码: %d\n", wpid, status);
  printf("✓ fork 测试完成\n\n");
}

// 测试6：create_process 测试（用于对比）
void child_process(void)
{
  set_proc_name("创建子进程");
  printf("    [子进程 %d] 通过 create_process 创建\n", sys_call_getpid());
  
  for(int i = 0; i < 2; i++) {
    printf("    [子进程 %d] 工作中 %d/2\n", sys_call_getpid(), i+1);
    sys_call_yield();
  }
  
  printf("    [子进程 %d] 退出，返回码: 42\n", sys_call_getpid());
  exit_process(42);
}

void test_create_process(void)
{
  printf("测试 create_process (非fork)...\n");
  
  printf("  [1] 使用 create_process 创建子进程\n");
  int child_pid = create_process(child_process);
  
  if(child_pid < 0) {
    printf("      ✗ 创建子进程失败\n");
    return;
  }
  
  printf("      ✓ 子进程已创建 PID=%d\n", child_pid);
  
  printf("  [2] 父进程等待子进程\n");
  int status;
  int wpid = wait_process(&status);
  
  printf("      ✓ 子进程 %d 已退出，状态码: %d\n", wpid, status);
  
  printf("✓ create_process 测试完成\n\n");
}

// ==================== 主测试进程 ====================
void main_test_process(void)
{
  set_proc_name("主测试进程");
  printf("\n[主进程 %d] 开始系统调用测试\n", sys_call_getpid());
  
  // 禁用详细的系统调用调试输出（避免输出过多）
  set_syscall_debug(0);
  
  printf("\n[测试1] 基础系统调用测试\n");
  printf("=====================================\n");
  test_basic_syscalls();
  
  printf("\n[测试2] 参数传递测试\n");
  printf("=====================================\n");
  test_parameter_passing();
  
  printf("\n[测试3] 性能测试\n");
  printf("=====================================\n");
  test_syscall_performance();
  
  printf("\n[测试4] sleep系统调用测试\n");
  printf("=====================================\n");
  test_sleep_syscall();
  
  printf("\n[测试5] fork系统调用测试\n");
  printf("=====================================\n");
  test_fork_syscall();
  
  printf("\n[测试6] create_process测试\n");
  printf("=====================================\n");
  test_create_process();
  
  // 显示系统调用统计
  printf("\n");
  printf("=====================================\n");
  printf("      系统调用统计信息               \n");
  printf("=====================================\n");
  show_syscall_stats();
  
  printf("\n");
  printf("=====================================\n");
  printf("      所有测试完成！                 \n");
  printf("=====================================\n");
  
  exit_process(0);
}

// ==================== 主函数 ====================
void
main(void)
{
  // 初始化printf系统
  printf_init();
  
  // 清屏并输出欢迎信息
  clear_screen();
  printf("=====================================\n");
  printf("  实验6：系统调用测试                \n");
  printf("=====================================\n");
  printf("Hart ID: %d\n", (int)r_tp());
  printf("=====================================\n");
  
  // 初始化系统
  printf("\n[步骤1] 初始化物理内存管理\n");
  pmm_init();
  
  printf("\n[步骤2] 初始化中断系统\n");
  trapinit();
  
  printf("\n[步骤3] 初始化进程系统\n");
  procinit();
  printf("✓ 进程系统初始化完成\n");
  
  printf("\n");
  printf("=====================================\n");
  printf("      创建主测试进程                 \n");
  printf("=====================================\n");
  
  // 创建主测试进程
  int pid = create_process(main_test_process);
  if(pid < 0) {
    panic("无法创建主测试进程");
  }
  printf("✓ 主测试进程已创建 PID=%d\n", pid);
  
  printf("\n");
  printf("=====================================\n");
  printf("      启动调度器                     \n");
  printf("=====================================\n");
  
  // 使能中断
  intr_on();
  
  // 进入调度器（永不返回）
  scheduler();
  
  // 不应该到达这里
  panic("main: scheduler returned");
}