#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "riscv.h"
#include "param.h"
#include "proc.h"

// ==================== 测试任务函数 ====================

// 简单任务 - 打印信息后退出
void simple_task(void)
{
  set_proc_name("简单任务");
  printf("[进程 %d] 简单任务开始执行\n", myproc()->pid);
  
  // 执行一些工作
  for(int i = 0; i < 3; i++) {
    printf("[进程 %d] 工作中... %d/3\n", myproc()->pid, i+1);
    yield(); // 让出CPU
  }
  
  printf("[进程 %d] 简单任务完成\n", myproc()->pid);
  exit_process(0);
}

// CPU密集型任务
void cpu_intensive_task(void)
{
  static int task_id = 0;
  int my_id = ++task_id;
  char name[16];
  sprintf(name, "CPU任务%d", my_id);
  set_proc_name(name);
  
  printf("[进程 %d] CPU密集任务 %d 开始\n", myproc()->pid, my_id);
  
  volatile uint64 sum = 0;
  for(int i = 0; i < 5; i++) {
    // 执行一些计算
    for(volatile int j = 0; j < 100000; j++) {
      sum += j;
    }
    printf("[进程 %d] CPU任务 %d 进度: %d/5\n", myproc()->pid, my_id, i+1);
    yield();
  }
  
  printf("[进程 %d] CPU任务 %d 完成, sum=%d\n", myproc()->pid, my_id, (int)sum);
  exit_process(0);
}

// 共享缓冲区（用于测试同步）
#define BUFFER_SIZE 5
static int buffer[BUFFER_SIZE];
static int buf_in = 0;
static int buf_out = 0;
static int buf_count = 0;

void shared_buffer_init(void)
{
  buf_in = 0;
  buf_out = 0;
  buf_count = 0;
}

// 生产者任务
void producer_task(void)
{
  set_proc_name("生产者");
  printf("[进程 %d] 生产者启动\n", myproc()->pid);
  
  for(int i = 0; i < 10; i++) {
    // 等待缓冲区有空间
    while(buf_count >= BUFFER_SIZE) {
      yield();
    }
    
    // 生产数据
    buffer[buf_in] = i;
    buf_in = (buf_in + 1) % BUFFER_SIZE;
    buf_count++;
    
    printf("[进程 %d] 生产: %d (缓冲区: %d/%d)\n", 
           myproc()->pid, i, buf_count, BUFFER_SIZE);
    yield();
  }
  
  printf("[进程 %d] 生产者完成\n", myproc()->pid);
  exit_process(0);
}

// 消费者任务
void consumer_task(void)
{
  set_proc_name("消费者");
  printf("[进程 %d] 消费者启动\n", myproc()->pid);
  
  for(int i = 0; i < 10; i++) {
    // 等待缓冲区有数据
    while(buf_count <= 0) {
      yield();
    }
    
    // 消费数据
    int data = buffer[buf_out];
    buf_out = (buf_out + 1) % BUFFER_SIZE;
    buf_count--;
    
    printf("[进程 %d] 消费: %d (缓冲区: %d/%d)\n", 
           myproc()->pid, data, buf_count, BUFFER_SIZE);
    yield();
  }
  
  printf("[进程 %d] 消费者完成\n", myproc()->pid);
  exit_process(0);
}

// ==================== 测试函数 ====================

// 测试1：进程创建测试
void test_process_creation(void)
{
  printf("正在测试进程创建...\n");
  
  // 测试基本的进程创建
  printf("  [1] 创建单个进程\n");
  int pid = create_process(simple_task);
  if(pid > 0) {
    printf("      ✓ 成功创建进程 PID=%d\n", pid);
  } else {
    printf("      ✗ 进程创建失败\n");
    return;
  }
  
  // 显示进程表 - 应该看到2个进程（主进程 + 新进程）
  printf("      --- 当前进程表 ---\n");
  debug_proc_table();
  
  // 等待第一个进程完成
  printf("      等待进程完成...\n");
  int exit_status;
  int wpid = wait_process(&exit_status);
  if(wpid > 0) {
    printf("      ✓ 进程 %d 已退出，退出码: %d\n", wpid, exit_status);
  }
  
  // 测试进程表限制
  printf("  [2] 测试进程表限制\n");
  int pids[NPROC];
  int count = 0;
  
  // 创建多个进程
  for(int i = 0; i < NPROC + 2; i++) {
    int p = create_process(simple_task);
    if(p > 0) {
      pids[count++] = p;
    } else {
      printf("      达到进程表限制，无法创建更多进程\n");
      break;
    }
  }
  printf("      已创建 %d 个进程\n", count);
  
  // 显示满载的进程表
  printf("      --- 进程表（满载状态）---\n");
  debug_proc_table();
  
  // 清理测试进程
  printf("      清理测试进程...\n");
  for(int i = 0; i < count; i++) {
    int wpid = wait_process(&exit_status);
    printf("      进程 %d 已清理 (退出码: %d)\n", wpid, exit_status);
  }
  
  // 显示清理后的进程表
  printf("      --- 清理后的进程表 ---\n");
  debug_proc_table();
  
  printf("✓ 进程创建测试完成\n\n");
}

// 测试2：调度器测试
void test_scheduler(void)
{
  printf("正在测试调度器...\n");
  
  // 创建多个CPU密集型进程
  printf("  [1] 创建3个CPU密集型进程\n");
  int cpu_pids[3];
  for(int i = 0; i < 3; i++) {
    cpu_pids[i] = create_process(cpu_intensive_task);
    printf("      创建进程 PID=%d\n", cpu_pids[i]);
  }
  
  // 显示创建后的进程表
  printf("  --- 创建后的进程表 ---\n");
  debug_proc_table();
  
  // 观察调度行为
  printf("  [2] 观察调度行为\n");
  uint64 start_time = get_time();
  
  // 让调度器运行，等待所有CPU任务完成
  printf("      等待CPU任务完成...\n");
  for(int i = 0; i < 3; i++) {
    int exit_status;
    int wpid = wait_process(&exit_status);
    printf("      CPU任务进程 %d 完成 (退出码: %d)\n", wpid, exit_status);
  }
  
  uint64 end_time = get_time();
  uint64 cycles = end_time - start_time;
  
  printf("      调度测试耗时: %llu 周期\n", cycles);
  printf("✓ 调度器测试完成\n\n");
}

// 测试3：同步机制测试
void test_synchronization(void)
{
  printf("正在测试同步机制...\n");
  
  // 测试生产者-消费者场景
  printf("  [1] 初始化共享缓冲区\n");
  shared_buffer_init();
  
  printf("  [2] 创建生产者和消费者\n");
  int pid1 = create_process(producer_task);
  int pid2 = create_process(consumer_task);
  printf("      生产者 PID=%d\n", pid1);
  printf("      消费者 PID=%d\n", pid2);
  
  // 显示进程表 - 应该看到3个进程
  printf("  --- 当前进程表 ---\n");
  debug_proc_table();
  
  // 等待两个进程完成
  printf("  [3] 等待生产者和消费者完成\n");
  for(int i = 0; i < 2; i++) {
    int exit_status;
    int wpid = wait_process(&exit_status);
    printf("      进程 %d 完成 (退出码: %d)\n", wpid, exit_status);
  }
  
  printf("✓ 同步机制测试完成\n\n");
}

// ==================== 主进程任务 ====================
// 主进程将运行所有测试
void main_process_task(void)
{
  set_proc_name("主测试进程");
  printf("\n[主进程 %d] 开始运行测试\n", myproc()->pid);
  
  // 运行三个核心测试
  printf("\n[测试1] 进程创建测试\n");
  printf("=====================================\n");
  test_process_creation();
  
  // 显示当前进程表
  debug_proc_table();
  
  printf("\n[测试2] 调度器测试\n");
  printf("=====================================\n");
  test_scheduler();
  
  printf("\n[测试3] 同步机制测试\n");
  printf("=====================================\n");
  test_synchronization();
  
  // 显示最终进程表
  printf("\n");
  printf("=====================================\n");
  printf("      最终进程表状态                 \n");
  printf("=====================================\n");
  debug_proc_table();
  
  printf("\n");
  printf("=====================================\n");
  printf("      所有测试完成！                 \n");
  printf("=====================================\n");
  
  // 主测试进程退出
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
  printf("  实验5：进程管理与调度测试          \n");
  printf("=====================================\n");
  printf("Hart ID: %d\n", (int)r_tp());
  printf("=====================================\n");
  
  // 初始化系统
  printf("\n[步骤1] 初始化物理内存管理\n");
  pmm_init();
  print_memory_stats();
  
  printf("\n[步骤2] 初始化中断系统\n");
  trapinit();
  
  printf("\n[步骤3] 初始化进程系统\n");
  procinit();
  printf("✓ 进程系统初始化完成\n");
  printf("  最大进程数: %d\n", NPROC);
  
  // 显示初始进程表
  debug_proc_table();
  
  printf("\n");
  printf("=====================================\n");
  printf("      创建主测试进程                 \n");
  printf("=====================================\n");
  
  // 创建主测试进程
  int pid = create_process(main_process_task);
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