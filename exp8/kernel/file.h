// file.h - 文件描述符定义
#ifndef _FILE_H_
#define _FILE_H_

#include "types.h"
#include "fs.h"

struct file {
  enum { FD_NONE, FD_PIPE, FD_INODE, FD_DEVICE } type;
  int ref; // 引用计数
  char readable;
  char writable;
  struct inode *ip;  // FD_INODE 和 FD_DEVICE
  uint32 off;        // FD_INODE
};

#define major(dev)  ((dev) >> 16 & 0xFFFF)
#define minor(dev)  ((dev) & 0xFFFF)
#define mkdev(m,n)  ((uint32)((m)<<16| (n)))

// 内存中的inode表
struct {
  struct inode inode[50];  // 简化：最多50个打开的inode
} icache;

// 内存中的文件表
struct {
  struct file file[100];   // 简化：最多100个打开的文件
} ftable;

#endif // _FILE_H_
