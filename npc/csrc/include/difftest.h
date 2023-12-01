#include "common.h"
#include "pmem.h"

typedef struct {
  word_t gpr[32];
  paddr_t pc;
} npc_state;

void init_difftest(char *ref_so_file, long img_size,int port);
void difftest_step(paddr_t pc);
