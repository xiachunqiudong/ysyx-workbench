#include "local-include/csr.h"

static word_t csr_vec[10];
char syslog_buf[256];

static word_t getCsrVecId(word_t csr_id) {
  if      (csr_id == 0x300) {return MSTATUS;}
  else if (csr_id == 0x305) {return MTVEC;}
  else if (csr_id == 0x341) {return MEPC;}
  else if (csr_id == 0x342) {return MCAUSE;}
  else                      {printf("Bad Csr Address: %x\n", csr_id); assert(0);}
  return 0;
}

word_t csrrw(word_t pc, word_t csr_id, word_t csr_wdata, bool csr_wen) {
  word_t csr_vec_id = getCsrVecId(csr_id);
  word_t csrr_rdata = csr_vec[csr_vec_id];
  if (csr_wen) csr_vec[csr_vec_id] = csr_wdata;
#ifdef CONFIG_ITRACE
  sprintf(syslog_buf, "[System CSRRW] PC: %08x    MEPC: %08x\n", pc, csr_wdata);
  SYS_LOG(syslog_buf);
#endif
  return csrr_rdata;
};

word_t csrrs(word_t csr_id, word_t csr_wdata, bool csr_wen) {
  word_t csr_vec_id = getCsrVecId(csr_id);
  word_t csrr_rdata = csr_vec[csr_vec_id];
  if (csr_wen) csr_vec[csr_vec_id] = csr_wdata | csrr_rdata;
  return csrr_rdata;
};

word_t csrrc(word_t csr_id, word_t csr_wdata, bool csr_wen) {
  word_t csr_vec_id = getCsrVecId(csr_id);
  word_t csrr_rdata = csr_vec[csr_vec_id];
  if (csr_wen) csr_vec[csr_vec_id] = csr_wdata & (~csrr_rdata);
  return csrr_rdata;
};


word_t csr_ecall(word_t pc) {
  csr_vec[MEPC] = pc;
  csr_vec[MCAUSE] = 11;
  // printf("Ecall: %08x\n", csr_vec[MTVEC]);
  return csr_vec[MTVEC];
}

word_t csr_mret(word_t pc) {
  // printf("Mret: %08x\n", csr_vec[MEPC]);
#ifdef CONFIG_ITRACE
  sprintf(syslog_buf, "[System Mret] PC: %08x    MEPC: %08x\n", pc, csr_vec[MEPC]);
  SYS_LOG(syslog_buf);
#endif
  
  return csr_vec[MEPC];
}

