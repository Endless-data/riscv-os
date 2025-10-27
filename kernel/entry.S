# 内核入口点
# qemu -kernel 会跳转到 0x80000000

        .section .text.init
        .global _entry
_entry:
        # 设置栈指针
        # 为每个 CPU 分配一个栈
        # 栈大小为 4096 字节
        la sp, stack0
        li a0, 1024*4
        csrr a1, mhartid      # 读取 hart id (CPU ID)
        addi a1, a1, 1        # hart id 从 0 开始，栈从 stack0+4096 开始
        mul a0, a0, a1
        add sp, sp, a0
        
        # 跳转到 C 代码的 start 函数
        call start

        # 如果 start 返回，则进入死循环
spin:
        wfi                   # 等待中断
        j spin

        # 为启动栈分配空间
        .section .data
        .align 12             # 4096 字节对齐
stack0:
        .space 4096 * 8       # 为 8 个 CPU 分配栈空间