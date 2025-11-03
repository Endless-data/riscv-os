OUTPUT_ARCH( "riscv" )
ENTRY( _entry )

SECTIONS
{
  /* 确保入口点位于 QEMU 启动的地址 */
  . = 0x80000000;

  /* 代码段 */
  .text : {
    *(.text.boot)     /* 确保启动代码在最开始 */
    *(.text .text.*)
    PROVIDE(etext = .);  /* 代码段结束标记 */
  }

  /* 只读数据段 */
  .rodata : {
    . = ALIGN(16);
    *(.rodata .rodata.*)
  }

  /* 数据段 - 已初始化的全局变量 */
  .data : {
    . = ALIGN(16);
    *(.data .data.*)
    PROVIDE(edata = .);  /* 数据段结束标记 */
  }

  /* BSS段 - 未初始化的全局变量 */
  .bss : {
    . = ALIGN(16);
    PROVIDE(bss_start = .);  /* BSS段开始标记 */
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(16);
    PROVIDE(bss_end = .);    /* BSS段结束标记 */
  }

  /* 设置系统结束标记 */
  PROVIDE(end = .);

  /* 栈空间 - 4KB */
  . = ALIGN(4096);
  . = . + 4096;
  PROVIDE(stack_top = .);
}