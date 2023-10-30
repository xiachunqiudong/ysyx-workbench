#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "pmem.h"

uint8_t pmem[MEM_SIZE] = {0};

int disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
// DPI-C
extern "C" void inst_read(paddr_t addr, word_t *inst) {
  if(addr >= MEM_BASE) {
    *inst = *(word_t *)guest_to_host(addr);
    printf("-------------------\n");
    printf("pc: %08x, inst: %08x\n", addr, *inst);
    
  }
}

int addr_check(int addr) {
  int result = 0;
  if(addr >= MEM_BASE && addr < MEM_BASE + MEM_SIZE) {
    result = 1;
  } else {
    printf("MEM -> bad mem access addr, addr = %08x\n", addr);
    result = 0;
  }
  
  return result;
}

extern "C" void pmem_read(int raddr, int *rdate) {
  if (addr_check(raddr))
    *rdate = *(int *)guest_to_host(raddr & ~0x3u);
  else
    *rdate = 0;
}

extern "C" void pmem_write(int waddr, int wdata, char mask) {
  printf("MEM -> waddr: %08x, wdata: %08x, mask: %d\n", waddr, wdata, mask);
  uint8_t *base_addr = guest_to_host(waddr & ~0x3u);
  int data = wdata;
  int i;
  for (i = 0; i < 4; i++) {
    *base_addr = ((mask >> i) & 1) ? *((uint8_t *)(&data) + i) : *base_addr;
  }
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}
