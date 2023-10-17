#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  size_t i = 0;
  while(s[i] != '\0') i++;
  return i;
}

char *strcpy(char *dst, const char *src) {
  if(dst == NULL || src == NULL)
    return NULL;
  size_t i = 0;
  while(src[i] != '\0') {
    dst[i] = src[i];
    i++;
  }
  dst[i] = '\0';
  return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {

  if(dst == NULL || src == NULL)
    return NULL;

  size_t i;
  
  for(i = 0; i < n && *src != '\0'; i++)
    dst[i] = src[i];
  for( ; i < n; i++)
    dst[i] = '\0';
    
  return dst;
}

char *strcat(char *dst, const char *src) {
  size_t dst_len = strlen(dst);
  size_t i = 0;
  while(src[i] != '\0') {
    dst[dst_len + i] = src[i];
    i++;
  }
  dst[dst_len + i] = '\0';
  return dst;
}

int strcmp(const char *s1, const char *s2) {
  size_t i = 0;
  while (s1[i] == s2[i] && s1[i] != '\0' && s2[i] != '\0') {
    i++;
  }
  return s1[i] - s2[i];
}

int strncmp(const char *s1, const char *s2, size_t n) {
  size_t i = 0;
  while (s1[i] == s2[i] && s1[i] != '\0' && s2[i] != '\0' && i < n) {
    i++;
  }
  return s1[i] - s2[i];
}

void *memset(void *s, int c, size_t n) {
  size_t i;
  char *sp = (char*)s;
  for(i = 0; i < n; i++) {
    sp[i] = c;
  }
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  size_t i;
  char *srcp, *dstp;
  srcp = (char *)src;
  dstp = (char *)dst;
  char temp[n];
  for(i = 0; i < n; i++) {
    temp[i] = srcp[i];
  }
  for(i = 0; i < n; i++) {
    dstp[i] = temp[i];
  }
  return dst;
}

// can not solve overlap
void *memcpy(void *out, const void *in, size_t n) {
  size_t i;
  char *inp, *outp;
  inp = (char *)in;
  outp = (char *)out;
  for(i = 0; i < n; i++) {
    outp[i] = inp[i];
  }
  return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  if(n == 0)
    return 0;
  
  const unsigned char *s1p, *s2p;
  s1p = (const unsigned char *)s1;
  s2p = (const unsigned char *)s2;
  int i;
  for(i = 0; i < n; i++) {
    if(s1p[i] != s2p[i])
      return s1p[i] - s2p[i];
  }
  return 0;
}

#endif
