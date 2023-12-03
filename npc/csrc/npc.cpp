#include "npc.h"

static enum NPC_STATE npc_state = NPC_RUNNING;

void npc_set_state(NPC_STATE nState) {
  npc_state = nState;
}

NPC_STATE npc_get_state() {
  return npc_state;
}