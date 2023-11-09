#include "utils.h"

static bool is_single_digit(const char c, char type) {
  switch (type) {
  case 'd': return c >= '0' && c <= '9';
  case 'h': return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f');
  default: return c >= '0' && c <= '9';
  }
}

bool is_digit(const char *str, char type) {
  if (str == nullptr)
    return false;
  
  while (*str != '\0') {
    if(is_single_digit(*str, type)) {
      str++;
    } else {
      return false;
    }
  }
  
  return true;
}
