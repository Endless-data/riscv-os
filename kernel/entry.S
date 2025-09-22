# 启动代码，被放置在0x80000000位置
# QEMU将在此地址开始执行

.section .text.boot  # 放在代码段最开始
.global _entry       # 导出符号，使其对链接器可见

_entry:
    # 设置栈指针
    la sp, stack_top  # 加载栈顶地址到sp寄存器

    # 清零BSS段
    la a0, bss_start  # BSS段开始地址
    la a1, bss_end    # BSS段结束地址
    
    # 当BSS段开始等于结束时，说明没有BSS段，直接跳过清零
    beq a0, a1, 2f

1:  # 循环清零BSS段
    sw zero, (a0)     # 将0存储到当前地址
    addi a0, a0, 4    # 地址+4
    blt a0, a1, 1b    # 如果未到结束地址，继续循环

2:  # 清零完成，跳转到C入口函数
    call start        # 调用C函数入口点

    # 不应该从start函数返回，但如果返回了则进入死循环
3:  j 3b             # 无限循环