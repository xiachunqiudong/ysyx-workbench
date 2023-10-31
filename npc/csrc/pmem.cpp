#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "pmem.h"
#include "utils.h"

uint8_t pmem[MEM_SIZE] = {0};

static int addr_check(int addr) {
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
    printf("%s\n", buf);
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
  sprintf(buf, "MEM -> waddr: %08x, wdata: %08x, mask: %d", waddr, wdata, mask);
  log(buf);
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
