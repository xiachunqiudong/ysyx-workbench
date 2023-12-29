#ifndef __COMMON__
#define __COMMON__

#include <stdio.h>
#include <assert.h>
#include <stdint.h>

// memory config
#define MEM_SIZE  0x8000000
#define MEM_BASE  0x80000000
#define RESET_VEC 0x80000000

// npc data type
typedef uint32_t word_t;
typedef uint32_t paddr_t;

// CPU state
typedef struct {
  word_t gpr[32];
  paddr_t pc;
} cpu_state;

void show_cpu_state(cpu_state cpu);
const char *get_gpr_name(int i);

#define DIFF
#define LOG

#endif