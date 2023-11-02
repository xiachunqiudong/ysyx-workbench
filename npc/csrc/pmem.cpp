#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "pmem.h"
#include "utils.h"

uint8_t pmem[MEM_SIZE] = {0};

int addr_check(int addr) {
  int result = 0;
  if(addr >= MEM_BASE && addr < MEM_BASE + MEM_SIZE) {
    result = 1;
  } else {
    // printf("MEM -> bad mem access addr, addr = %08x\n", addr);
    result = 0;
  }
  return result;
}

// DPI-C
#define BUF_SIZE 256
extern "C" void inst_read(paddr_t addr, word_t *inst) {
  char buf[BUF_SIZE];
  char *p = buf;
  if(addr >= MEM_BASE) {
    *inst = *(word_t *)guest_to_host(addr);
    log("-------------------");
    p += sprintf(p, "%08x: ", addr);
    int size = BUF_SIZE - (p - buf);
    disassemble(p, size, addr, (uint8_t *)inst, 4);
    log(buf);
  }
}

extern "C" void pmem_read(int raddr, int *rdate) {
  if (addr_check(raddr))
    *rdate = *(int *)guest_to_host(raddr & ~0x3u);
  else
    *rdate = 0;
}

extern "C" void pmem_write(int waddr, int wdata, char mask) {
  char buf[BUF_SIZE];
  char real_mask[9] = {0};
  int i;
  for (int i = 0; i < 8; i++) {
    real_mask[7 - i] = (mask >> i & 1) + '0';
  }
  sprintf(buf, "MEM -> waddr: %08x, wdata: %08x, mask: %s", waddr, wdata, real_mask);
  log(buf);
  
  uint8_t *base_addr = guest_to_host(waddr & ~0x3u);
  int real_wdata;
  uint8_t *wp = (uint8_t *)&real_wdata;
  for (i = 0; i < 4; i++) {
    *(wp + i) = ((mask >> i) & 1) ? *(((uint8_t *)(&wdata)) + i) : *(base_addr + i);
  }
  printf("MEM --> waddr: %08x, wdata: %08x, mask: %s, real_wdata: %08x\n", waddr, wdata, real_mask, real_wdata);
  *(int *)base_addr = real_wdata;
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}
