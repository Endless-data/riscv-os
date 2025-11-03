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

#endif // _DEFS_H_