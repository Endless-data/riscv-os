// string.c - 基本字符串和内存操作函数
#include "types.h"

// 内存复制
void* memcpy(void *dst, const void *src, uint64 n)
{
  char *d = (char*)dst;
  const char *s = (const char*)src;
  while(n-- > 0)
    *d++ = *s++;
  return dst;
}

// 内存设置
void* memset(void *dst, int c, uint64 n)
{
  char *d = (char*)dst;
  while(n-- > 0)
    *d++ = (char)c;
  return dst;
}

// 内存比较
int memcmp(const void *s1, const void *s2, uint64 n)
{
  const unsigned char *p1 = (const unsigned char*)s1;
  const unsigned char *p2 = (const unsigned char*)s2;
  while(n-- > 0) {
    if(*p1 != *p2)
      return *p1 - *p2;
    p1++;
    p2++;
  }
  return 0;
}

// 字符串长度
uint64 strlen(const char *s)
{
  uint64 n;
  for(n = 0; s[n]; n++)
    ;
  return n;
}

// 字符串比较
int strcmp(const char *s1, const char *s2)
{
  while(*s1 && *s1 == *s2) {
    s1++;
    s2++;
  }
  return (unsigned char)*s1 - (unsigned char)*s2;
}

// 字符串比较（限定长度）
int strncmp(const char *s1, const char *s2, uint64 n)
{
  while(n > 0 && *s1 && *s1 == *s2) {
    n--;
    s1++;
    s2++;
  }
  if(n == 0)
    return 0;
  return (unsigned char)*s1 - (unsigned char)*s2;
}

// 字符串复制
char* strcpy(char *dst, const char *src)
{
  char *d = dst;
  while((*d++ = *src++) != 0)
    ;
  return dst;
}

// 字符串复制（限定长度）
char* strncpy(char *dst, const char *src, uint64 n)
{
  char *d = dst;
  while(n > 0 && *src) {
    *d++ = *src++;
    n--;
  }
  while(n > 0) {
    *d++ = 0;
    n--;
  }
  return dst;
}

// 字符串连接
char* strcat(char *dst, const char *src)
{
  char *d = dst;
  while(*d)
    d++;
  while((*d++ = *src++) != 0)
    ;
  return dst;
}

// 查找字符
char* strchr(const char *s, int c)
{
  while(*s) {
    if(*s == c)
      return (char*)s;
    s++;
  }
  if(c == 0)
    return (char*)s;
  return 0;
}
