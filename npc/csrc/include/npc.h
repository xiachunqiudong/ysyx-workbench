#ifndef __NPC__
#define __NPC__

#include <stdint.h>

#define RESET_VEC 0x80000000

// npc data type
typedef uint32_t word_t;
typedef uint32_t paddr_t;

// #define DIFF
#define LOG

// NPC state
enum NPC_STATE {
  NPC_RUNNING = 0,
  NPC_STOP,
  NPC_ERROR_DIFF
};

typedef struct {
  bool     commit_valid;
  uint32_t commit_pc;
  uint32_t commit_dnpc;
  uint32_t commit_inst;
} commit_info_t;

// NPC STATE
void npc_set_state(NPC_STATE nState);
NPC_STATE npc_get_state();
void npc_commit(bool valid, uint32_t pc, uint32_t inst, uint32_t dnpc);
commit_info_t npc_commit_info();

// NPC REGS
typedef struct {
  word_t gpr[32];
  paddr_t pc;
} cpu_state;

void show_cpu_state(cpu_state cpu);
const char *get_gpr_name(int i);
void reg_display();
word_t gpr_val(int idx);

#endif