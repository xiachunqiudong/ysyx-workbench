#ifndef __PMEM__
#define __PMEM__

#include "common.h"

bool addr_check(int addr);
uint32_t inst_read(uint32_t addr);
uint8_t *guest_to_host(paddr_t paddr);

#endif