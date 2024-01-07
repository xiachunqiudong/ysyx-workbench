#include "npc.h"

static enum NPC_STATE npc_state = NPC_RUNNING;

static commit_info_t commit_info;

void npc_set_state(NPC_STATE nState) {
  npc_state = nState;
}

NPC_STATE npc_get_state() {
  return npc_state;
}

void npc_commit(bool valid, uint32_t pc, uint32_t inst, uint32_t dnpc) {
  commit_info.commit_valid = valid;
  commit_info.commit_pc    = pc;
  commit_info.commit_dnpc  = inst;
  commit_info.commit_inst  = dnpc;
}

commit_info_t npc_commit_info() {
  return commit_info;
}