// fs.c - 简化的文件系统实现
#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "file.h"

// 简化的内存"磁盘" - 用于模拟
#define FSSIZE 1000  // 文件系统大小（块数）
static char disk[FSSIZE][BSIZE];  // 模拟磁盘

// 超级块（在内存中缓存）
struct superblock sb;

// 统计信息
static uint64 disk_read_count = 0;
static uint64 disk_write_count = 0;
static uint64 buffer_cache_hits = 0;
static uint64 buffer_cache_misses = 0;

// 简化的块缓存
#define NBUF 30
struct buf {
  int valid;
  int dirty;
  uint32 blockno;
  char data[BSIZE];
} bcache[NBUF];

// 读取磁盘块
static void bread(uint32 blockno, char *data)
{
  if(blockno >= FSSIZE) {
    panic("bread: 无效的块号");
  }
  
  // 检查缓存
  for(int i = 0; i < NBUF; i++) {
    if(bcache[i].valid && bcache[i].blockno == blockno) {
      memcpy(data, bcache[i].data, BSIZE);
      buffer_cache_hits++;
      return;
    }
  }
  
  // 缓存未命中，从"磁盘"读取
  memcpy(data, disk[blockno], BSIZE);
  disk_read_count++;
  buffer_cache_misses++;
  
  // 加入缓存（简单的替换策略：找空闲或覆盖第一个）
  for(int i = 0; i < NBUF; i++) {
    if(!bcache[i].valid) {
      bcache[i].valid = 1;
      bcache[i].dirty = 0;
      bcache[i].blockno = blockno;
      memcpy(bcache[i].data, data, BSIZE);
      return;
    }
  }
  
  // 缓存满了，覆盖第一个
  if(bcache[0].dirty) {
    memcpy(disk[bcache[0].blockno], bcache[0].data, BSIZE);
    disk_write_count++;
  }
  bcache[0].valid = 1;
  bcache[0].dirty = 0;
  bcache[0].blockno = blockno;
  memcpy(bcache[0].data, data, BSIZE);
}

// 写入磁盘块
static void bwrite(uint32 blockno, char *data)
{
  if(blockno >= FSSIZE) {
    panic("bwrite: 无效的块号");
  }
  
  // 更新缓存
  for(int i = 0; i < NBUF; i++) {
    if(bcache[i].valid && bcache[i].blockno == blockno) {
      memcpy(bcache[i].data, data, BSIZE);
      bcache[i].dirty = 1;
      // 简化：立即写回
      memcpy(disk[blockno], data, BSIZE);
      disk_write_count++;
      bcache[i].dirty = 0;
      return;
    }
  }
  
  // 不在缓存中，直接写入
  memcpy(disk[blockno], data, BSIZE);
  disk_write_count++;
}

// 简化的位图操作
static char bitmap[FSSIZE];

static void bzero(uint32 blockno)
{
  char buf[BSIZE];
  memset(buf, 0, BSIZE);
  bwrite(blockno, buf);
}

// 分配一个数据块
static uint32 balloc(void)
{
  for(uint32 b = 0; b < sb.size; b++) {
    if(bitmap[b] == 0) {
      bitmap[b] = 1;
      bzero(b);
      return b;
    }
  }
  panic("balloc: 磁盘空间不足");
  return 0;
}

// 释放一个数据块
static void bfree(uint32 b)
{
  if(b < sb.bmapstart || b >= sb.size) {
    panic("bfree: 无效的块号");
  }
  bitmap[b] = 0;
  bzero(b);
}

// inode 缓存
static void iinit(void)
{
  for(int i = 0; i < 50; i++) {
    icache.inode[i].ref = 0;
    icache.inode[i].valid = 0;
  }
}

// 分配一个inode
static struct inode* ialloc(uint16 type)
{
  // 在磁盘上查找空闲inode
  for(uint32 inum = 1; inum < sb.ninodes; inum++) {
    char buf[BSIZE];
    uint32 blockno = IBLOCK(inum, sb);
    bread(blockno, buf);
    
    struct dinode *dip = (struct dinode*)buf + inum % IPB;
    if(dip->type == 0) {  // 空闲inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      bwrite(blockno, buf);
      
      // 分配内存inode
      for(int i = 0; i < 50; i++) {
        if(icache.inode[i].ref == 0) {
          icache.inode[i].dev = 0;
          icache.inode[i].inum = inum;
          icache.inode[i].ref = 1;
          icache.inode[i].valid = 1;
          icache.inode[i].type = type;
          icache.inode[i].size = 0;
          memset(icache.inode[i].addrs, 0, sizeof(icache.inode[i].addrs));
          return &icache.inode[i];
        }
      }
      panic("ialloc: inode 缓存已满");
    }
  }
  panic("ialloc: 没有可用的 inode");
  return 0;
}

// 根据inum获取inode
static struct inode* iget(uint32 inum)
{
  // 先查找缓存
  for(int i = 0; i < 50; i++) {
    if(icache.inode[i].valid && icache.inode[i].inum == inum) {
      icache.inode[i].ref++;
      return &icache.inode[i];
    }
  }
  
  // 从磁盘读取
  for(int i = 0; i < 50; i++) {
    if(icache.inode[i].ref == 0) {
      char buf[BSIZE];
      uint32 blockno = IBLOCK(inum, sb);
      bread(blockno, buf);
      
      struct dinode *dip = (struct dinode*)buf + inum % IPB;
      
      icache.inode[i].dev = 0;
      icache.inode[i].inum = inum;
      icache.inode[i].ref = 1;
      icache.inode[i].valid = 1;
      icache.inode[i].type = dip->type;
      icache.inode[i].major = dip->major;
      icache.inode[i].minor = dip->minor;
      icache.inode[i].nlink = dip->nlink;
      icache.inode[i].size = dip->size;
      memcpy(icache.inode[i].addrs, dip->addrs, sizeof(dip->addrs));
      
      return &icache.inode[i];
    }
  }
  
  panic("iget: inode 缓存已满");
  return 0;
}

// 释放inode引用
static void iput(struct inode *ip)
{
  if(ip->ref < 1)
    panic("iput");
  
  ip->ref--;
  
  if(ip->ref == 0) {
    // 写回磁盘
    char buf[BSIZE];
    uint32 blockno = IBLOCK(ip->inum, sb);
    bread(blockno, buf);
    
    struct dinode *dip = (struct dinode*)buf + ip->inum % IPB;
    dip->type = ip->type;
    dip->major = ip->major;
    dip->minor = ip->minor;
    dip->nlink = ip->nlink;
    dip->size = ip->size;
    memcpy(dip->addrs, ip->addrs, sizeof(dip->addrs));
    
    bwrite(blockno, buf);
    ip->valid = 0;
  }
}

// 获取inode的第n个数据块号
static uint32 bmap(struct inode *ip, uint32 bn)
{
  if(bn < NDIRECT) {
    if(ip->addrs[bn] == 0)
      ip->addrs[bn] = balloc();
    return ip->addrs[bn];
  }
  
  bn -= NDIRECT;
  if(bn < NINDIRECT) {
    // 间接块
    if(ip->addrs[NDIRECT] == 0)
      ip->addrs[NDIRECT] = balloc();
    
    char buf[BSIZE];
    bread(ip->addrs[NDIRECT], buf);
    uint32 *a = (uint32*)buf;
    if(a[bn] == 0) {
      a[bn] = balloc();
      bwrite(ip->addrs[NDIRECT], buf);
    }
    return a[bn];
  }
  
  panic("bmap: 超出文件大小");
  return 0;
}

// 从inode读取数据
static int readi(struct inode *ip, char *dst, uint32 off, uint32 n)
{
  if(off > ip->size || off + n < off)
    return 0;
  if(off + n > ip->size)
    n = ip->size - off;
  
  uint32 tot = 0;
  while(tot < n) {
    uint32 blockno = bmap(ip, off / BSIZE);
    char buf[BSIZE];
    bread(blockno, buf);
    
    uint32 m = BSIZE - off % BSIZE;
    if(m > n - tot)
      m = n - tot;
    
    memcpy(dst, buf + off % BSIZE, m);
    tot += m;
    off += m;
    dst += m;
  }
  return tot;
}

// 向inode写入数据
static int writei(struct inode *ip, char *src, uint32 off, uint32 n)
{
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE * BSIZE)
    return -1;
  
  uint32 tot = 0;
  while(tot < n) {
    uint32 blockno = bmap(ip, off / BSIZE);
    char buf[BSIZE];
    bread(blockno, buf);
    
    uint32 m = BSIZE - off % BSIZE;
    if(m > n - tot)
      m = n - tot;
    
    memcpy(buf + off % BSIZE, src, m);
    bwrite(blockno, buf);
    
    tot += m;
    off += m;
    src += m;
  }
  
  if(off > ip->size)
    ip->size = off;
  
  return tot;
}

// 目录查找
static struct inode* dirlookup(struct inode *dp, char *name, uint32 *poff)
{
  if(dp->type != T_DIR)
    panic("dirlookup: 不是目录");
  
  struct dirent de;
  for(uint32 off = 0; off < dp->size; off += sizeof(de)) {
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup: 读取失败");
    
    if(de.inum == 0)
      continue;
    
    if(strncmp(name, de.name, DIRSIZ) == 0) {
      if(poff)
        *poff = off;
      return iget(de.inum);
    }
  }
  return 0;
}

// 向目录添加条目
static int dirlink(struct inode *dp, char *name, uint32 inum)
{
  // 检查名字是否已存在
  struct inode *ip = dirlookup(dp, name, 0);
  if(ip) {
    iput(ip);
    return -1;
  }
  
  // 查找空闲条目
  struct dirent de;
  uint32 off;
  for(off = 0; off < dp->size; off += sizeof(de)) {
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink: 读取失败");
    if(de.inum == 0)
      break;
  }
  
  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink: 写入失败");
  
  return 0;
}

// 初始化文件系统
void fsinit(void)
{
  printf("初始化文件系统...\n");
  
  // 初始化超级块
  sb.magic = FSMAGIC;
  sb.size = FSSIZE;
  sb.nblocks = FSSIZE - 100;  // 预留100个块给元数据
  sb.ninodes = 200;
  sb.nlog = 30;
  sb.logstart = 2;
  sb.inodestart = 32;
  sb.bmapstart = 32 + (sb.ninodes / IPB) + 1;
  
  // 初始化位图
  for(uint32 i = 0; i < sb.bmapstart; i++)
    bitmap[i] = 1;  // 元数据块标记为已用
  for(uint32 i = sb.bmapstart; i < FSSIZE; i++)
    bitmap[i] = 0;
  
  // 初始化inode缓存
  iinit();
  
  // 创建根目录
  struct inode *root = ialloc(T_DIR);
  root->nlink = 1;
  root->size = 2 * sizeof(struct dirent);
  
  // 添加 . 和 ..
  struct dirent de;
  de.inum = ROOTINO;
  strncpy(de.name, ".", DIRSIZ);
  writei(root, (char*)&de, 0, sizeof(de));
  strncpy(de.name, "..", DIRSIZ);
  writei(root, (char*)&de, sizeof(de), sizeof(de));
  
  iput(root);
  
  printf("✓ 文件系统初始化完成\n");
  printf("  总块数: %d\n", sb.size);
  printf("  数据块数: %d\n", sb.nblocks);
  printf("  Inode数: %d\n", sb.ninodes);
}

// 创建文件
struct inode* fs_create(char *path, int16 type)
{
  struct inode *dp = iget(ROOTINO);
  
  // 简化：只支持根目录下的文件
  struct inode *ip = dirlookup(dp, path, 0);
  if(ip) {
    iput(dp);
    return ip;
  }
  
  // 创建新文件
  ip = ialloc(type);
  ip->nlink = 1;
  ip->size = 0;
  
  dirlink(dp, path, ip->inum);
  iput(dp);
  
  return ip;
}

// 打开文件
struct inode* fs_open(char *path)
{
  struct inode *dp = iget(ROOTINO);
  struct inode *ip = dirlookup(dp, path, 0);
  iput(dp);
  return ip;
}

// 删除文件
int fs_unlink(char *path)
{
  struct inode *dp = iget(ROOTINO);
  uint32 off;
  struct inode *ip = dirlookup(dp, path, &off);
  
  if(!ip) {
    iput(dp);
    return -1;
  }
  
  // 删除目录项
  struct dirent de;
  memset(&de, 0, sizeof(de));
  writei(dp, (char*)&de, off, sizeof(de));
  
  // 减少链接数
  ip->nlink--;
  if(ip->nlink == 0) {
    // 释放数据块
    for(uint32 i = 0; i < NDIRECT; i++) {
      if(ip->addrs[i])
        bfree(ip->addrs[i]);
    }
    ip->type = 0;  // 标记为空闲
  }
  
  iput(ip);
  iput(dp);
  return 0;
}

// 读取文件
int fs_read(struct inode *ip, char *dst, uint32 off, uint32 n)
{
  return readi(ip, dst, off, n);
}

// 写入文件
int fs_write(struct inode *ip, char *src, uint32 off, uint32 n)
{
  return writei(ip, src, off, n);
}

// 关闭文件
void fs_close(struct inode *ip)
{
  iput(ip);
}

// 获取磁盘I/O统计
void debug_disk_io(void)
{
  printf("=== 磁盘 I/O 统计 ===\n");
  printf("磁盘读取次数: %d\n", (int)disk_read_count);
  printf("磁盘写入次数: %d\n", (int)disk_write_count);
  printf("缓存命中次数: %d\n", (int)buffer_cache_hits);
  printf("缓存未命中次数: %d\n", (int)buffer_cache_misses);
  if(buffer_cache_hits + buffer_cache_misses > 0) {
    int hit_rate = (buffer_cache_hits * 100) / (buffer_cache_hits + buffer_cache_misses);
    printf("缓存命中率: %d%%\n", hit_rate);
  }
}

// 获取空闲块数
uint32 count_free_blocks(void)
{
  uint32 free = 0;
  for(uint32 i = sb.bmapstart; i < FSSIZE; i++) {
    if(bitmap[i] == 0)
      free++;
  }
  return free;
}

// 获取空闲inode数
uint32 count_free_inodes(void)
{
  uint32 free = 0;
  for(int i = 0; i < 50; i++) {
    if(icache.inode[i].ref == 0)
      free++;
  }
  return free;
}

// 显示文件系统状态
void debug_filesystem_state(void)
{
  printf("=== 文件系统调试信息 ===\n");
  printf("总块数: %d\n", sb.size);
  printf("空闲块数: %d\n", (int)count_free_blocks());
  printf("空闲 inode 数: %d\n", (int)count_free_inodes());
  
  debug_disk_io();
}

// 显示inode使用情况
void debug_inode_usage(void)
{
  printf("=== Inode 使用情况 ===\n");
  for(int i = 0; i < 50; i++) {
    struct inode *ip = &icache.inode[i];
    if(ip->ref > 0) {
      const char *type_str = "UNKNOWN";
      if(ip->type == T_DIR) type_str = "DIR";
      else if(ip->type == T_FILE) type_str = "FILE";
      else if(ip->type == T_DEVICE) type_str = "DEVICE";
      
      printf("Inode %d: ref=%d, type=%s, size=%d\n",
             ip->inum, ip->ref, type_str, ip->size);
    }
  }
}
