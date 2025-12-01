#ifndef _DEFS_H_
#define _DEFS_H_

#include "types.h"

// uart.c
void uart_init(void);
void uart_putc(char c);
void uart_puts(const char *s);

// console.c
void console_init(void);
void console_putc(char c);
void console_puts(const char *s);
void clear_screen(void);
void console_goto_xy(int x, int y);

// printf.c
int printf(const char *fmt, ...);
int sprintf(char *buf, const char *fmt, ...);
int printf_color(int color, const char *fmt, ...);
void printf_init(void);

// kalloc.c - 物理内存管理
void pmm_init(void);
void* alloc_page(void);
void free_page(void* page);
void* alloc_pages(int n);
uint64 get_free_pages(void);
void print_memory_stats(void);

// vm.c - 虚拟内存管理
pagetable_t create_pagetable(void);
void destroy_pagetable(pagetable_t pt);
pte_t* walk_create(pagetable_t pt, uint64 va);
pte_t* walk_lookup(pagetable_t pt, uint64 va);
int map_page(pagetable_t pt, uint64 va, uint64 pa, int perm);
int map_range(pagetable_t pt, uint64 va, uint64 size, uint64 pa, int perm);
void dump_pagetable(pagetable_t pt, int level);
uint64 va2pa(pagetable_t pt, uint64 va);
void kvminit(void);
void kvminithart(void);

// trap.c - 中断和异常处理
void start(void);               // 机器模式启动函数
void trapinit(void);            // 初始化trap系统
void timerinit(void);           // 初始化时钟
void kerneltrap(void);          // 内核trap处理
void clockintr(void);           // 时钟中断处理
int devintr(void);              // 设备中断检查
void panic(const char *s);      // 致命错误处理
void handle_exception(uint64 scause, uint64 sepc, uint64 stval);  // 异常处理
uint64 get_time(void);          // 获取当前时间
uint64 get_ticks(void);         // 获取ticks计数
int get_interrupt_count(void);  // 获取中断计数
void show_interrupt_stats(void); // 显示中断统计
void check_sleeping_procs(void); // 检查睡眠进程

// proc.c - 进程管理
struct proc;
void procinit(void);            // 初始化进程系统
int create_process(void (*task)(void)); // 创建进程
int wait_process(int *status);  // 等待进程结束
void exit_process(int status);  // 进程退出
void yield(void);               // 让出CPU
void sched(void);               // 切换到调度器
void scheduler(void);           // 调度器
struct proc* myproc(void);      // 获取当前进程
void sleep(void *chan, int ms); // 进程睡眠
void wakeup(void *chan);        // 唤醒进程
void debug_proc_table(void);    // 调试进程表
void set_proc_name(const char *name); // 设置进程名

#endif // _DEFS_H_