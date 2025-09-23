# RISC-V最小操作系统

这是一个基于RISC-V架构的最小操作系统内核，基于实验分步骤实现。

## 实验内容

### 实验1：RISC-V引导与裸机启动
- 参考xv6的启动机制，理解并实现最小操作系统的引导过程
- 实现基本的UART驱动和简单输出
- 输出"Hello OS"信息

### 实验2：内核printf与清屏功能实现
- 实现格式化输出系统（printf）
- 支持多种格式：%d、%x、%s、%c、%p等
- 实现ANSI控制序列，支持清屏和光标控制
- 支持彩色输出

## 项目结构

- **启动与引导**
  - `kernel/entry.S`: 启动汇编代码，设置栈指针、清零BSS段，跳转到C入口
  - `kernel/kernel.ld`: 链接脚本，定义内存布局和符号

- **驱动层**
  - `kernel/uart.c`/`uart.h`: UART硬件驱动，实现基本输入输出

- **控制台与格式化输出**
  - `kernel/console.c`/`console.h`: 控制台抽象层，处理特殊字符和ANSI序列
  - `kernel/printf.c`/`printf.h`: 格式化输出系统，实现printf功能

- **基础支持**
  - `kernel/main.c`: C语言入口函数，包含测试代码
  - `kernel/types.h`: 基本数据类型定义

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