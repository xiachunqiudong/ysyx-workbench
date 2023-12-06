#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>
#include <stdlib.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

// return the number of characters printed 
// (excluding the null byte used to end output to strings)
int sprintf(char *out, const char *fmt, ...) {
  
  va_list vl;
  va_start(vl, fmt);
  int i = 0;
  int cnt = 0;
  
  int d;
  char *s;

  while (fmt[i] != '\0') {
    // char
    if (fmt[i] != '%'){
      out[cnt++] = fmt[i++];
      continue;
    }
    // %
	  i++; // pass the %
    switch (fmt[i++]) {
      case 'd':
        d = va_arg(vl, int);
        char temp[32];
        int j = 0;
        do {
          temp[j++] = (d % 10) + '0';
          d = d / 10;
        } while(d != 0);
        // reverse
        while(j > 0) {
          out[cnt++] = temp[--j];
        }
        break;
      case 's':
        s = va_arg(vl, char *);
        while(*s != '\0') {
          out[cnt++] = *s++;
        }
        break;
    } 
  }

  out[cnt] = '\0';
  return cnt;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
