# RISC-V最小操作系统

这是一个基于RISC-V架构的最小操作系统内核，仅实现了基本的启动流程和串口输出功能，输出"Hello OS"信息。

## 项目结构

- `kernel/entry.S`: 启动汇编代码，设置栈指针、清零BSS段，跳转到C入口
- `kernel/kernel.ld`: 链接脚本，定义内存布局和符号
- `kernel/main.c`: C语言入口函数，初始化硬件并输出信息
- `kernel/uart.c`: UART驱动，实现串口输出功能
- `kernel/types.h`: 基本数据类型定义
- `kernel/uart.h`: UART函数声明

## 构建和运行

确保已安装RISC-V工具链和QEMU，然后执行：

```
make
make qemu
```

## 退出QEMU

按 Ctrl+A，然后按 X 退出QEMU。

## 调试

可以使用GDB进行调试：

```
make qemu-gdb
```

然后在另一个终端中：

```
riscv64-unknown-elf-gdb kernel/kernel
(gdb) target remote localhost:26000
(gdb) file kernel/kernel
```