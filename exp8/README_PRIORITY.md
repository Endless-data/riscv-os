# 实验8：优先级调度系统

## 项目概述

本实验实现了一个支持进程优先级的调度算法，在xv6简单轮转调度的基础上，添加了：
- 进程优先级机制（0-10级）
- 最高优先级优先调度
- Aging机制防止饥饿
- 动态优先级调整系统调用

## 设计目标

1. **公平性**：通过Aging机制保证低优先级进程不会被饿死
2. **响应性**：高优先级任务能够快速响应
3. **灵活性**：支持动态调整进程优先级
4. **性能**：最小化调度开销

## 核心实现

### 1. 数据结构扩展 (proc.h)

```c
struct proc {
  // ... 原有字段 ...
  
  // 优先级调度新增字段
  int priority;        // 进程优先级 (0-10, 默认5)
  int ticks;          // 已使用CPU时间片计数
  uint64 wait_time;   // 等待时长（用于aging）
};

// 优先级常量
#define DEFAULT_PRIORITY 5
#define MIN_PRIORITY 0
#define MAX_PRIORITY 10
#define AGING_THRESHOLD 10
#define AGING_BOOST 1
```

### 2. 调度算法 (proc.c)

#### 最高优先级选择
```c
static struct proc* select_highest_priority(void)
{
  选择优先级最高的RUNNABLE进程
  如果优先级相同，选择等待时间更长的（FCFS）
}
```

#### Aging机制
```c
static void aging_boost(void)
{
  遍历所有RUNNABLE进程：
    wait_time++
    如果 wait_time >= AGING_THRESHOLD:
      提升优先级（最高到MAX_PRIORITY）
      重置wait_time
}
```

#### 调度器主循环
```c
void scheduler(void)
{
  for(;;) {
    // 定期执行aging（每10ms）
    if(时间到) aging_boost();
    
    // 选择最高优先级进程
    p = select_highest_priority();
    
    if(p) {
      切换到进程p
      累加运行时间和ticks
    } else {
      WFI等待中断
    }
  }
}
```

### 3. 系统调用

#### sys_setpriority
```c
功能：设置指定进程的优先级
参数：pid, priority (0-10)
返回：成功0，失败-1
```

#### sys_getpriority
```c
功能：获取指定进程的优先级
参数：pid
返回：优先级值，失败-1
```

## 测试场景

### 测试1：优先级竞争
- 创建3个任务，优先级分别为9、5、2
- **预期**：高优先级任务先执行，低优先级任务后执行
- **验证**：观察执行顺序

### 测试2：动态优先级调整
- 创建任务后动态提升优先级
- **预期**：优先级提升后任务获得更多CPU时间
- **验证**：通过getpriority确认优先级变化

### 测试3：Aging机制验证
- 创建多个不同优先级任务
- **预期**：低优先级任务等待一段时间后优先级提升
- **验证**：所有任务最终都能执行完成

### 测试4：相同优先级公平性
- 创建3个相同优先级任务
- **预期**：表现为轮转调度（RR）
- **验证**：任务交替执行

## 性能分析

### 调度开销
- 遍历进程表：O(n)
- Aging机制：O(n)，每10ms执行一次
- 上下文切换：保持不变

### 优化建议
1. 使用优先级队列：将选择时间降至O(1)
2. 只对等待时间超过阈值的进程做aging
3. 实现多级反馈队列（MLFQ）进一步优化

## 调度统计信息

系统提供 `show_priority_stats()` 函数显示：
- 进程状态表（PID、状态、优先级、时间片、等待时间）
- 优先级分布统计（条形图）
- 调度效率分析（平均等待时间、总运行时间）

## 编译和运行

```bash
cd riscv-os/exp8
make clean
make
make qemu
```

## 关键改进点

相比简单轮转调度，优先级调度的优势：

1. ✅ **区分任务紧急程度**：实时任务可设置高优先级
2. ✅ **防止饥饿**：Aging机制保证公平性
3. ✅ **灵活可控**：支持动态调整优先级
4. ✅ **可扩展性**：可进一步扩展为MLFQ

## 扩展方向

### 多级反馈队列（MLFQ）
```
Q0 (highest priority): RR with quantum 8
Q1 (medium priority):  RR with quantum 16  
Q2 (lowest priority):  FCFS

规则：
- 新进程进入Q0
- 用完时间片降级
- 长时间未执行升级（aging）
- I/O密集任务保持高优先级
```

### 实时调度
- 添加deadline字段
- 实现EDF（Earliest Deadline First）
- 支持周期性任务

## 文件清单

- `kernel/proc.h` - 进程结构和优先级常量定义
- `kernel/proc.c` - 优先级调度器实现
- `kernel/syscall.h` - 新增系统调用编号
- `kernel/sysproc.c` - 优先级系统调用实现
- `kernel/syscall.c` - 系统调用表更新
- `kernel/main.c` - 优先级调度测试程序

## 总结

本实验成功实现了优先级调度系统，通过合理的算法设计平衡了实时性和公平性。Aging机制有效防止了低优先级进程的饥饿问题，动态优先级调整提供了灵活的资源管理能力。

该调度系统为操作系统提供了更强的任务管理能力，适用于需要区分任务重要性的应用场景，如：
- 实时控制系统
- 多媒体播放器
- 服务器负载均衡
- 桌面交互系统
