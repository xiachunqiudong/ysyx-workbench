#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>

#define MEM_SIZE 1024

uint8_t pmem[MEM_SIZE] = {0};

void pmem_init();
uint32_t instr_read(uint32_t addr);