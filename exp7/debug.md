测试与调试策略
文件系统完整性测试
1 void test_filesystem_integrity(void) {
2 printf("Testing filesystem integrity…\n");
3 // 创建测试文件
4 int fd = open("testfile", O_CREATE | O_RDWR);
5 assert(fd >= 0);
6
7 // 写入数据
8 char buffer[] = "Hello, filesystem!";
9 int bytes = write(fd, buffer, strlen(buffer));
10 assert(bytes == strlen(buffer));
11 close(fd);
12
13 // 重新打开并验证
14 fd = open("testfile", O_RDONLY);
15 assert(fd >= 0);
16
17 char read_buffer[64];
18 bytes = read(fd, read_buffer, sizeof(read_buffer));
19 read_buffer[bytes] = '\0';
20
21 assert(strcmp(buffer, read_buffer) == 0);
22 close(fd);
23
24 // 删除文件
25 assert(unlink("testfile") == 0);
26
27 printf("Filesystem integrity test passed\n");
28 }
并发访问测试
1 void test_concurrent_access(void) {
2 printf("Testing concurrent file access…
3 ");
4 // 创建多个进程同时访问文件系统
5 for (int i = 0; i < 4; i++) {
6 if (fork() == 0) {
7 // 子进程：创建和删除文件
8 char filename[32];
9 snprintf(filename, sizeof(filename), "test_%d", i);
10
11 for (int j = 0; j < 100; j++) {
12 int fd = open(filename, O_CREATE | O_RDWR);
13 if (fd >= 0) {
14 write(fd, &j, sizeof(j));
15 close(fd);
16 unlink(filename);
17 }
18 }
19 exit(0);
20 }
21 }
22
23 // 等待所有子进程完成
24 for (int i = 0; i < 4; i++) {
25 wait(NULL);
26 }
27
28 printf("Concurrent access test completed
崩溃恢复测试
1 void test_crash_recovery(void) {
2 printf("Testing crash recovery…
3 ");
4 // 模拟崩溃场景：
5 // 1. 开始大量文件操作
6 // 2. 在中途"崩溃"（重启系统）
7 // 3. 检查文件系统一致性
8
9 // 注意：这个测试需要特殊的测试框架
10 // 可以通过修改内核代码来模拟崩溃
性能测试
1 void test_filesystem_performance(void) {
2 printf("Testing filesystem performance…\n");
3 uint64 start_time = get_time();
4
5 // 大量小文件测试
6 for (int i = 0; i < 1000; i++) {
7 char filename[32];
8 snprintf(filename, sizeof(filename), "small_%d", i);
9
10 int fd = open(filename, O_CREATE | O_RDWR);
11 write(fd, "test", 4);
12 close(fd);
13 }
14
15 uint64 small_files_time = get_time() - start_time;
16
17 // 大文件测试
18 start_time = get_time();
19 int fd = open("large_file", O_CREATE | O_RDWR);
20 char large_buffer[4096];
21 for (int i = 0; i < 1024; i++) { // 4MB文件
22 write(fd, large_buffer, sizeof(large_buffer));
23 }
24 close(fd);
25
26 uint64 large_file_time = get_time() - start_time;
27
28 printf("Small files (1000x4B): %lu cycles\n", small_files_time);
29 printf("Large file (1x4MB): %lu cycles\n", large_file_time);
30
31 // 清理测试文件
32 for (int i = 0; i < 1000; i++) {
33 char filename[32];
34 snprintf(filename, sizeof(filename), "small_%d", i);
35 unlink(filename);
36 }
37 unlink("large_file");
38 }
调试建议
文件系统状态检查
1 void debug_filesystem_state(void) {
2 printf("=== Filesystem Debug Info ===
3 ");
4 // 显示超级块信息
5 struct superblock sb;
6 read_superblock(&sb);
7 printf("Total blocks: %d
8 ", sb.size);
9 printf("Free blocks: %d
10 ", count_free_blocks());
11 printf("Free inodes: %d
12 ", count_free_inodes());
13
14 // 显示块缓存状态
15 printf("Buffer cache hits: %d
16 ", buffer_cache_hits);
17 printf("Buffer cache misses: %d
inode追踪
1 void debug_inode_usage(void) {
2 printf("=== Inode Usage ===\n");
3 for (int i = 0; i < NINODE; i++) {
4 struct inode *ip = &icache.inode[i];
5 if (ip->ref > 0) {
6 printf("Inode %d: ref=%d, type=%d, size=%d\n",
7 ip->inum, ip->ref, ip->type, ip->size);
8 }
9 }
10 }
磁盘I/O统计
1 void debug_disk_io(void) {
2 printf("=== Disk I/O Statistics ===
3 ");
4 printf("Disk reads: %d
5 ", disk_read_count);
6 printf("Disk writes: %d
7 ", disk_write_count);