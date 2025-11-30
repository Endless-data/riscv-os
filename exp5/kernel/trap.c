// trap.c - 中断和异常处理
#include "types.h"
#include "riscv.h"
#include "defs.h"

// 全局时钟计数
volatile uint64 ticks = 0;

// 中断计数（用于测试）
volatile int interrupt_count = 0;

// 初始化时钟
void timerinit(void)
{
  // 使能machine-mode的timer中断
  w_mie(r_mie() | MIE_STIE);
  
  // 使能sstc扩展 (stimecmp)
  w_menvcfg(r_menvcfg() | (1L << 63)); 
  
  // 允许supervisor访问stimecmp和time
  w_mcounteren(r_mcounteren() | 2);
  
  // 请求第一次定时器中断（约0.1秒后）
  w_stimecmp(r_time() + 1000000);
}

// 机器模式启动初始化
void start(void)
{
  // 设置M Previous Privilege mode为Supervisor，用于mret
  uint64 x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
  x |= MSTATUS_MPP_S;
  w_mstatus(x);

  // 设置M Exception Program Counter为main，用于mret
  extern void main();
  w_mepc((uint64)main);

  // 暂时禁用分页
  w_satp(0);

  // 将所有中断和异常委托给supervisor mode
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  
  // 使能supervisor的外部中断和定时器中断
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);

  // 配置Physical Memory Protection，允许supervisor访问所有物理内存
  w_pmpaddr0(0x3fffffffffffffull);
  w_pmpcfg0(0xf);

  // 初始化时钟中断
  timerinit();

  // 保存hart id到tp寄存器
  int id = r_mhartid();
  w_tp(id);

  // 切换到supervisor mode并跳转到main
  asm volatile("mret");
}

// 初始化trap系统
void trapinit(void)
{
  printf("初始化中断系统...\n");
  
  // 设置supervisor trap vector
  extern void kernelvec();
  w_stvec((uint64)kernelvec);
  
  printf("✓ 中断向量表设置完成: 0x%p\n", (void*)r_stvec());
  printf("✓ 当前中断状态: %s\n", intr_get() ? "已使能" : "已禁用");
}

// 处理时钟中断
void clockintr(void)
{
  ticks++;
  interrupt_count++;
  
  // 检查睡眠进程
  check_sleeping_procs();
  
  // 请求下一次定时器中断
  w_stimecmp(r_time() + 1000000);
}

// 检查并处理设备中断
// 返回: 2=时钟中断, 1=其他设备中断, 0=未识别
int devintr(void)
{
  uint64 scause = r_scause();
  
  // 检查是否是supervisor timer interrupt
  if (scause == 0x8000000000000005L) {
    clockintr();
    return 2;
  }
  
  // 检查是否是supervisor external interrupt
  if (scause == 0x8000000000000009L) {
    // UART或其他外部中断
    return 1;
  }
  
  return 0;
}

// 内核态中断处理函数（从kernelvec.S调用）
void kerneltrap(void)
{
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  // 确保来自supervisor mode
  if ((sstatus & SSTATUS_SPP) == 0) {
    panic("kerneltrap: not from supervisor mode");
  }
  
  // 确保中断已被禁用
  if (intr_get() != 0) {
    panic("kerneltrap: interrupts enabled");
  }
  
  // 处理设备中断
  int which_dev = devintr();
  
  if (which_dev == 0) {
    // 未知的中断或异常
    printf("\n!!! 未知的中断/异常 !!!\n");
    printf("scause=0x%p\n", (void*)scause);
    printf("sepc=0x%p\n", (void*)sepc);
    printf("stval=0x%p\n", (void*)r_stval());
    panic("kerneltrap");
  }
  
  // 恢复trap寄存器，为kernelvec.S的sepc指令准备
  w_sepc(sepc);
  w_sstatus(sstatus);
}

// 异常名称查找表
const char* exception_names[] = {
  "Instruction address misaligned",
  "Instruction access fault",
  "Illegal instruction",
  "Breakpoint",
  "Load address misaligned",
  "Load access fault",
  "Store/AMO address misaligned",
  "Store/AMO access fault",
  "Environment call from U-mode",
  "Environment call from S-mode",
  "Reserved",
  "Environment call from M-mode",
  "Instruction page fault",
  "Load page fault",
  "Reserved",
  "Store/AMO page fault"
};

// 处理异常
void handle_exception(uint64 scause, uint64 sepc, uint64 stval)
{
  uint64 exception_code = scause & 0x7FFFFFFFFFFFFFFF;
  
  printf("\n=== 异常发生 ===\n");
  if (exception_code < 16) {
    printf("异常类型: %s\n", exception_names[exception_code]);
  } else {
    printf("异常类型: Unknown (code=%d)\n", (int)exception_code);
  }
  printf("异常地址 (sepc): 0x%p\n", (void*)sepc);
  printf("异常值 (stval): 0x%p\n", (void*)stval);
  printf("scause: 0x%p\n", (void*)scause);
  
  // 简单的异常处理：如果是非法指令，跳过它
  if (exception_code == 2) {
    printf("跳过非法指令...\n");
    w_sepc(sepc + 4);
    return;
  }
  
  // 其他异常则panic
  panic("Unhandled exception");
}

// panic函数 - 系统致命错误
void panic(const char *s)
{
  printf("\n!!! PANIC !!!\n");
  printf("%s\n", s);
  printf("Hart %d\n", (int)r_tp());
  printf("sepc=0x%p stval=0x%p\n", (void*)r_sepc(), (void*)r_stval());
  printf("系统已停止。\n");
  
  // 禁用中断并进入无限循环
  intr_off();
  for(;;)
    ;
}

// 获取当前时间（以ticks为单位）
uint64 get_time(void)
{
  return r_time();
}

// 获取ticks计数
uint64 get_ticks(void)
{
  return ticks;
}

// 获取中断计数
int get_interrupt_count(void)
{
  return interrupt_count;
}

// 显示中断统计信息
void show_interrupt_stats(void)
{
  printf("\n=== 中断统计信息 ===\n");
  printf("时间计数(ticks): %d\n", (int)ticks);
  printf("中断总数: %d\n", interrupt_count);
  printf("当前时间: %d cycles\n", (int)r_time());
  printf("当前状态寄存器:\n");
  printf("  sstatus: 0x%p [SIE=%d]\n", 
         (void*)r_sstatus(), intr_get());
  printf("  sie: 0x%p\n", (void*)r_sie());
  printf("  stvec: 0x%p\n", (void*)r_stvec());
}
