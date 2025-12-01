#include "types.h"
#include "platform.h"
#include "defs.h"
#include "fs.h"

// 测试 1: 文件系统完整性
void test_filesystem_integrity(void)
{
    printf("\n【测试1】文件系统完整性测试\n");
    printf("---------------------------------\n");
    
    // 创建测试文件
    printf("1. 创建文件 test1.txt...\n");
    struct inode *ip = fs_create("test1.txt", T_FILE);
    if(!ip) {
        printf("✗ 文件创建失败\n");
        return;
    }
    printf("✓ 文件创建成功 (inode=%d)\n", ip->inum);
    
    // 写入数据
    printf("2. 写入数据到文件...\n");
    char *write_data = "Hello, FileSystem!";
    int n = fs_write(ip, write_data, 0, strlen(write_data));
    printf("✓ 写入 %d 字节\n", n);
    fs_close(ip);
    
    // 重新打开并读取
    printf("3. 重新打开文件并读取...\n");
    ip = fs_open("test1.txt");
    if(!ip) {
        printf("✗ 文件打开失败\n");
        return;
    }
    
    char read_data[100];
    memset(read_data, 0, sizeof(read_data));
    n = fs_read(ip, read_data, 0, 50);
    printf("✓ 读取 %d 字节: \"%s\"\n", n, read_data);
    
    // 验证数据
    if(strcmp(read_data, write_data) == 0) {
        printf("✓ 数据验证成功\n");
    } else {
        printf("✗ 数据验证失败\n");
    }
    fs_close(ip);
    
    printf("✓ 测试1完成\n");
}

// 测试 2: 并发访问（简化版）
void test_concurrent_access(void)
{
    printf("\n【测试2】并发访问测试\n");
    printf("---------------------------------\n");
    
    // 创建文件
    printf("1. 创建文件 test2.txt...\n");
    struct inode *ip1 = fs_create("test2.txt", T_FILE);
    if(!ip1) {
        printf("✗ 文件创建失败\n");
        return;
    }
    printf("✓ 文件创建成功\n");
    
    // 同时打开两次（模拟并发）
    printf("2. 多次打开同一文件...\n");
    struct inode *ip2 = fs_open("test2.txt");
    if(!ip2) {
        printf("✗ 第二次打开失败\n");
        fs_close(ip1);
        return;
    }
    printf("✓ 文件可以被多次打开\n");
    printf("  第一次: inode=%d, ref=%d\n", ip1->inum, ip1->ref);
    printf("  第二次: inode=%d, ref=%d\n", ip2->inum, ip2->ref);
    
    // 交替写入
    printf("3. 交替写入数据...\n");
    char *data1 = "AAA";
    char *data2 = "BBB";
    fs_write(ip1, data1, 0, 3);
    fs_write(ip2, data2, 3, 3);
    printf("✓ 数据写入完成\n");
    
    // 读取验证
    char buf[10];
    memset(buf, 0, sizeof(buf));
    fs_read(ip1, buf, 0, 6);
    printf("  读取结果: \"%s\"\n", buf);
    
    fs_close(ip1);
    fs_close(ip2);
    printf("✓ 测试2完成\n");
}

// 测试 3: 崩溃恢复（简化版）
void test_crash_recovery(void)
{
    printf("\n【测试3】崩溃恢复测试\n");
    printf("---------------------------------\n");
    
    // 创建文件并写入
    printf("1. 创建并写入文件 test3.txt...\n");
    struct inode *ip = fs_create("test3.txt", T_FILE);
    if(!ip) {
        printf("✗ 文件创建失败\n");
        return;
    }
    
    char *data = "Crash Recovery Test Data";
    int n = fs_write(ip, data, 0, strlen(data));
    printf("✓ 写入 %d 字节\n", n);
    fs_close(ip);
    
    // 模拟"崩溃"后重新打开
    printf("2. 模拟崩溃后重新打开文件...\n");
    ip = fs_open("test3.txt");
    if(!ip) {
        printf("✗ 文件打开失败\n");
        return;
    }
    
    // 验证数据完整性
    char buf[100];
    memset(buf, 0, sizeof(buf));
    n = fs_read(ip, buf, 0, 100);
    printf("✓ 读取 %d 字节: \"%s\"\n", n, buf);
    
    if(strcmp(buf, data) == 0) {
        printf("✓ 数据在模拟崩溃后保持完整\n");
    } else {
        printf("✗ 数据损坏\n");
    }
    
    fs_close(ip);
    printf("✓ 测试3完成\n");
}

// 测试 4: 性能测试
void test_filesystem_performance(void)
{
    printf("\n【测试4】文件系统性能测试\n");
    printf("---------------------------------\n");
    
    // 重置统计信息
    debug_disk_io();
    
    // 创建多个文件
    printf("1. 创建10个文件...\n");
    for(int i = 0; i < 10; i++) {
        char name[20];
        name[0] = 'f';
        name[1] = 'i';
        name[2] = 'l';
        name[3] = 'e';
        name[4] = '0' + i;
        name[5] = '.';
        name[6] = 't';
        name[7] = 'x';
        name[8] = 't';
        name[9] = '\0';
        
        struct inode *ip = fs_create(name, T_FILE);
        if(!ip) {
            printf("✗ 文件 %s 创建失败\n", name);
            continue;
        }
        
        // 写入一些数据
        char data[100];
        for(int j = 0; j < 100; j++) {
            data[j] = 'A' + (i % 26);
        }
        fs_write(ip, data, 0, 100);
        fs_close(ip);
    }
    printf("✓ 10个文件创建完成\n");
    
    // 随机读取
    printf("2. 随机读取文件...\n");
    for(int i = 0; i < 5; i++) {
        char name[20];
        int idx = (i * 3) % 10;
        name[0] = 'f';
        name[1] = 'i';
        name[2] = 'l';
        name[3] = 'e';
        name[4] = '0' + idx;
        name[5] = '.';
        name[6] = 't';
        name[7] = 'x';
        name[8] = 't';
        name[9] = '\0';
        
        struct inode *ip = fs_open(name);
        if(ip) {
            char buf[100];
            fs_read(ip, buf, 0, 100);
            fs_close(ip);
        }
    }
    printf("✓ 随机读取完成\n");
    
    // 显示统计
    printf("3. 性能统计:\n");
    debug_disk_io();
    
    printf("✓ 测试4完成\n");
}

// 综合测试
void test_all(void)
{
    printf("\n╔══════════════════════════════════╗\n");
    printf("║   实验7：文件系统综合测试       ║\n");
    printf("╚══════════════════════════════════╝\n");
    
    test_filesystem_integrity();
    test_concurrent_access();
    test_crash_recovery();
    test_filesystem_performance();
    
    printf("\n╔══════════════════════════════════╗\n");
    printf("║      文件系统最终状态报告        ║\n");
    printf("╚══════════════════════════════════╝\n");
    debug_filesystem_state();
    debug_inode_usage();
    
    printf("\n✓ 所有测试完成！\n");
}

void os_start()
{
    printf("启动操作系统...\n");
    
    // 初始化各个子系统
    uart_init();
    pmm_init();
    
    // 初始化文件系统
    fsinit();
    
    // 运行文件系统测试
    test_all();
    
    while(1) {
        // 空闲循环
    }
}