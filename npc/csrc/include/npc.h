#ifndef __NPC__
#define __NPC__

// NPC state
enum NPC_STATE {
  NPC_RUNNING = 0,
  NPC_STOP,
  NPC_ERROR_DIFF
};

void npc_set_state(NPC_STATE nState);
NPC_STATE npc_get_state();



#endif