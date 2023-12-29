#ifndef __PMEM__
#define __PMEM__

#include "common.h"

#define LEGAL_MEM_ADDR(addr) (addr >= MEM_BASE && addr < (MEM_BASE + MEM_SIZE))

uint32_t inst_read(uint32_t addr);
uint8_t *guest_to_host(paddr_t paddr);


#endif