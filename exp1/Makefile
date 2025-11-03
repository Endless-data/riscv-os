# RISC-V编译工具链前缀
CROSS_COMPILE = riscv64-elf-

# 工具链命令
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

# 编译选项
CFLAGS = -Wall -Werror -O2 -ffreestanding -nostdlib -nostdinc -mcmodel=medany
ASFLAGS = -march=rv64g

# QEMU命令
QEMU = qemu-system-riscv64
QEMUOPTS = -machine virt -bios none -kernel kernel/kernel -m 128M -nographic

# 所有源文件
C_SOURCES = $(wildcard kernel/*.c)
ASM_SOURCES = $(wildcard kernel/*.S)
OBJ = $(C_SOURCES:.c=.o) $(ASM_SOURCES:.S=.o)

# 默认目标
all: kernel/kernel

# 编译C文件
kernel/%.o: kernel/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# 编译汇编文件
kernel/%.o: kernel/%.S
	$(CC) $(CFLAGS) -c $< -o $@

# 链接生成内核
kernel/kernel: $(OBJ)
	$(LD) -T kernel/kernel.ld -o $@ $^
	$(OBJDUMP) -S $@ > kernel/kernel.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel/kernel.sym

# 在QEMU中启动
qemu: all
	$(QEMU) $(QEMUOPTS)

# 在QEMU调试模式下启动
qemu-gdb: all
	$(QEMU) $(QEMUOPTS) -S -gdb tcp::26000

# 清理生成文件
clean:
	rm -f kernel/*.o kernel/kernel kernel/*.asm kernel/*.sym

.PHONY: all clean qemu qemu-gdb
