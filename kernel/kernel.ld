/* filepath: /Users/tongzhen/code/os-expr/riscv-os/kernel/kernel.ld */
OUTPUT_ARCH( "riscv" )
ENTRY( _entry )

SECTIONS
{
  /*
   * 确保 entry.S / _entry 位于 0x80000000,
   * 这是 qemu 的 -kernel 参数跳转的地址
   */
  . = 0x80000000;

  .text : {
    *(.text.init)      /* 入口代码段 */
    *(.text .text.*)   /* 所有代码段 */
    . = ALIGN(0x1000); /* 页面对齐 */
    PROVIDE(etext = .); /* 代码段结束标记 */
  }

  .rodata : {
    . = ALIGN(16);
    *(.srodata .srodata.*) /* 小的只读数据 */
    . = ALIGN(16);
    *(.rodata .rodata.*)   /* 只读数据段 */
  }

  .data : {
    . = ALIGN(16);
    *(.sdata .sdata.*)     /* 小的数据段 */
    . = ALIGN(16);
    *(.data .data.*)       /* 数据段 */
  }

  .bss : {
    . = ALIGN(16);
    *(.sbss .sbss.*)       /* 小的BSS段 */
    . = ALIGN(16);
    *(.bss .bss.*)         /* BSS段 */
    . = ALIGN(0x1000);     /* 页面对齐，为物理内存分配做准备 */
  }

  /* 内核结束标记 - 物理内存分配从这里开始 */
  PROVIDE(end = .);
  
  /* 丢弃不需要的段 */
  /DISCARD/ : {
    *(.eh_frame .note.GNU-stack)
  }
}