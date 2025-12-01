// fs.h - 文件系统数据结构定义
#ifndef _FS_H_
#define _FS_H_

#include "types.h"

// 磁盘布局:
// [ boot block | super block | log | inode blocks | free bit map | data blocks ]

#define ROOTINO  1   // 根inode编号
#define BSIZE 512    // 块大小

// 磁盘上的超级块
struct superblock {
  uint32 magic;        // 魔数，必须是 FSMAGIC
  uint32 size;         // 文件系统大小（块数）
  uint32 nblocks;      // 数据块数量
  uint32 ninodes;      // inode数量
  uint32 nlog;         // 日志块数量
  uint32 logstart;     // 日志区起始块号
  uint32 inodestart;   // inode区起始块号
  uint32 bmapstart;    // 位图区起始块号
};

#define FSMAGIC 0x10203040

#define NDIRECT 12
#define NINDIRECT (BSIZE / sizeof(uint32))
#define MAXFILE (NDIRECT + NINDIRECT)

// 磁盘上的inode结构
struct dinode {
  int16 type;           // 文件类型
  int16 major;          // 主设备号(T_DEVICE only)
  int16 minor;          // 次设备号(T_DEVICE only)
  int16 nlink;          // 指向此inode的链接数
  uint32 size;          // 文件大小（字节）
  uint32 addrs[NDIRECT+1]; // 数据块地址
};

// inode 类型
#define T_DIR     1   // 目录
#define T_FILE    2   // 文件
#define T_DEVICE  3   // 设备

// 内存中的inode
struct inode {
  uint32 dev;           // 设备号
  uint32 inum;          // inode号
  int ref;              // 引用计数
  int valid;            // inode是否已从磁盘读取
  
  int16 type;           // 从磁盘复制
  int16 major;
  int16 minor;
  int16 nlink;
  uint32 size;
  uint32 addrs[NDIRECT+1];
};

// 每个inode块包含的inode数量
#define IPB           (BSIZE / sizeof(struct dinode))

// 块号转换为包含它的块号
#define IBLOCK(i, sb)     ((i) / IPB + sb.inodestart)

// 每个块的位图位数
#define BPB           (BSIZE*8)

// 块号转换为位图块号
#define BBLOCK(b, sb) ((b)/BPB + sb.bmapstart)

// 目录是包含一系列dirent结构的文件
#define DIRSIZ 14

struct dirent {
  uint16 inum;
  char name[DIRSIZ];
};

#endif // _FS_H_
