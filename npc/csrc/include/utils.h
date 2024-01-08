#ifndef __UTILS__
#define __UTILS__

#include <stdint.h>

void init_disasm(const char *triple);
int disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

void init_log(const char *log_file);
void init_mem_log(const char *mem_log_file);

// bit helper
bool is_digit(const char *str, char type);

//--------------log----------------
void log(char *str);
void mem_log(char *str);
void npc_info(char *str);
void npc_error(char *str);

#define ANSI_FG_BLACK   "\33[1;30m"
#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_YELLOW  "\33[1;33m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_FG_MAGENTA "\33[1;35m"
#define ANSI_FG_CYAN    "\33[1;36m"
#define ANSI_FG_WHITE   "\33[1;37m"
#define ANSI_BG_BLACK   "\33[1;40m"
#define ANSI_BG_RED     "\33[1;41m"
#define ANSI_BG_GREEN   "\33[1;42m"
#define ANSI_BG_YELLOW  "\33[1;43m"
#define ANSI_BG_BLUE    "\33[1;44m"
#define ANSI_BG_MAGENTA "\33[1;35m"
#define ANSI_BG_CYAN    "\33[1;46m"
#define ANSI_BG_WHITE   "\33[1;47m"
#define ANSI_NONE       "\33[0m"

#endif