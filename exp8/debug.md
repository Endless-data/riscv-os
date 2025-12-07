项目1：优先级调度系统
Ø 理解操作系统调度器（Scheduler）的作用
Ø 掌握进程调度算法的分类及应用场景
Ø 分析 xv6 默认轮转调度算法的局限性
Ø 设计并实现支持进程优先级的调度算法
Ø 学会性能分析与公平性评估
09 内容结构
Ø 1. 操作系统调度概述
Ø 2. xv6 调度框架分析
Ø 3. 性能瓶颈与改进方向
Ø 4. 优先级调度设计与实现
Ø 5. 进一步扩展：多级反馈队列
09 内容结构
Ø 1. 操作系统调度概述
Ø 2. xv6 调度框架分析
Ø 3. 性能瓶颈与改进方向
Ø 4. 优先级调度设计与实现
Ø 5. 进一步扩展：多级反馈队列
09 为什么学习调度？
Ø 操作系统的核心功能之一：管理 CPU 资源。
p 在多任务系统中，同时运行多个进程
p 调度算法决定谁先运行、谁等待
p 不同调度策略 → 不同性能表现
09 为什么学习调度？
Ø 操作系统的核心功能之一：管理 CPU 资源。
p 在多任务系统中，同时运行多个进程
p 调度算法决定谁先运行、谁等待
p 不同调度策略 → 不同性能表现
09 典型场景对比
场景 所需调度特性
视频播放 低延迟、实时性
批处理任务 吞吐量
桌面系统 交互响应快
嵌入式控制 确定性、可预测性
09 调度的目标
Ø 公平性（Fairness）： 每个进程都有机会获得 CPU
Ø 高效性（Efficiency）： 尽可能让 CPU 不空闲
Ø 响应性（Responsiveness）：快速响应用户交互
Ø 吞吐量（Throughput）： 单位时间内完成的任务数
09 调度层次
Ø 短程调度（CPU 调度）：决定哪个进程获得 CPU
Ø 中程调度：处理挂起与恢复
Ø 长程调度：控制系统中活跃任务数量
09 常见调度算法
算法 说明 优缺点
FCFS 先来先服务 实现简单，交互性差
SJF 短任务优先 吞吐高，长任务饥饿
RR 时间片轮转 公平，但无优先级
Priority 优先级调度 灵活，但需防饥饿
MLFQ 多级反馈队列 综合性强，实现复杂
09 xv6 调度概述
Ø 采用 Round-Robin (RR) 调度
Ø 每个进程获得相同 CPU 时间片
Ø 时间片耗尽 → 调度器选择下一个 “RUNNABLE” 进程
Ø 调度函数在 `proc.c` 中实现
09 关键结构：struct proc
struct proc {
uint sz; // 进程内存大小
pde_t* pgdir; // 页表
char *kstack; // 内核栈
enum procstate state; // 进程状态
int pid; // PID
struct proc *parent;
char name[16]; // 进程名
... };
09 调度循环简要
void scheduler(void) {
for(;;) {
acquire(&ptable.lock);
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
if(p->state != RUNNABLE)
continue;
proc = p;
switchuvm(p);
p->state = RUNNING;
swtch(&cpu->scheduler, proc->context);
switchkvm();
}
release(&ptable.lock);
}
}
09 当前算法特性
Ø 公平性： 所有进程轮流执行
Ø 实时性： 无优先机制，交互延迟较高
Ø 适用场景： 小型教学实验、轻负载系统
Ø 性能瓶颈： 缺乏区分任务紧急程度的能力
09 性能瓶颈分析
Ø 问题 1：响应性不佳
p 交互任务（如 shell）与 CPU 密集任务竞争时，响应延迟显著增大
p 所有任务等待同等时间片 → 用户体验下降
Ø 问题 2：无优先级概念
p 系统不能区分重要任务与后台任务
p 实时行为难以保证 —— 可能导致关键任务延迟
Ø 问题 3：缺乏动态调整机制
p 不支持 “老化 (aging)” 机制
p 一旦排在后面，进程可能长期等待
09 优先级调度设计
Ø 设计目标
p 在 xv6 基础上添加优先级字段
p 选择最高优先级可运行进程执行
p 引入aging，防止低优先级进程饥饿
p 保持代码结构简洁、易维护
09 优先级属性设计
Ø 默认优先级为 5。
Ø 值越大 → 优先级越高。
struct proc {
... int priority; // 进程优先级 (0~10)
int ticks; // 已用 CPU 时间
int wait_time; // 等待时长（用于aging）
};
09 新增系统调用接口
Ø 可在用户态手动调整进程优先级，利于测试算法正确性。
int setpriority(int pid, int value); // 设置进程优先级
int getpriority(int pid); // 查询进程优先级
09 核心调度逻辑修改
Ø 在 scheduler() 循环内调用该函数替代原始遍历。
struct proc* select_highest_priority(void) {
struct proc *p,
*best = 0;
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
if(p->state == RUNNABLE && (!best || p->priority > best->priority))
best = p;
return best;
}
09 Aging 机制设计
Ø 防止低优先级进程 “永远得不到 CPU”
。
Ø AGING_THRESHOLD：经验值，例如 10 ticks
Ø 优先级增幅可控制上限 MAX_PRIORITY
for(p in all processes)
if(p->state == RUNNABLE)
p->wait_time++;
if(p->wait_time > AGING_THRESHOLD)
p->priority++;
09 调度切换逻辑
Ø 调度器唤醒 → 扫描可运行进程
Ø 若存在更高优先级的进程 → 抢占
Ø 切换到目标进程 → 执行时间片
Ø 更新运行统计信息（ticks / wait_time）
09 实现细节与测试
Ø 添加系统调用步骤
p 用户态声明接口（user.h）
p 添加系统调用号（syscall.h）
p 在内核侧定义函数（sysproc.c）
p 在系统调用表中注册（syscall.c）
09 实现细节与测试
Ø 编写 nice.c（简易命令工具）
#include "types.h"
#include "user.h"
int main(int argc, char *argv[]) {
if(argc != 3){
printf(2,
"Usage: nice pid priority\n");
exit();
}
setpriority(atoi(argv[1]), atoi(argv[2]));
exit();
}
09 测试场景设计
测试编号 场景描述 预期结果
T1 两个任务，优先级差距大 高优先级任务先执行完
T2 相同优先级 行为等价RR
T3 高低混合 + aging 所有任务最终执行完
09 定性测试：均衡性观察
$ nice 5 8 # 提高 PID 5 的优先级
$ nice 6 2 # 降低 PID 6 的优先级
$ ps
PID PRIORITY STATE TICKS
5 8 RUNNING 50
6 2 SLEEPING 10