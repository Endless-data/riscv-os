// stat.h - 文件状态结构
#ifndef _STAT_H_
#define _STAT_H_

#include "types.h"

#define T_DIR     1   // 目录
#define T_FILE    2   // 文件
#define T_DEVICE  3   // 设备

struct stat {
  int dev;     // 文件系统的磁盘设备
  uint32 ino;  // Inode号
  int16 type;  // 文件类型
  int16 nlink; // 到文件的链接数
  uint64 size; // 文件大小（字节）
};

#endif // _STAT_H_
