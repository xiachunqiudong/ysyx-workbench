#ifndef __RISCV_CSR_H__
#define __RISCV_CSR_H__

#include <common.h>

#define MSTATUS 0
#define MTVEC   1
#define MEPC    2
#define MCAUSE  3


word_t csrrw(word_t pc, word_t csr_id, word_t csr_wdata, bool csr_wen);
word_t csrrs(word_t csr_id, word_t csr_wdata, bool csr_wen);
word_t csrrc(word_t csr_id, word_t csr_wdata, bool csr_wen);
word_t csr_ecall(word_t pc);
word_t csr_mret(word_t pc);

#endif