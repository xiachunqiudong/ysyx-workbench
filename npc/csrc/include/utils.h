#include <stdint.h>

void init_disasm(const char *triple);
int disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

void init_log(const char *log_file);
void log(char *str);

// reg
void reg_display();