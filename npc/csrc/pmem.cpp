#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "pmem.h"
#include "utils.h"

void sim_stop();
double sim_time_stamp();

uint8_t pmem[MEM_SIZE] = {0};

static void addr_check(int addr) {
  if(!LEGAL_MEM_ADDR(addr)) {
    printf("Bad memory address: %08x at %f, stop simulation!\n", addr, sim_time_stamp());
    sim_stop();
  }
}

// DPI-C
#define BUF_SIZE 512
extern "C" void inst_read(paddr_t addr, word_t *inst) {
  if (!LEGAL_MEM_ADDR(addr)) {
    printf("[Inst Fetch] bad inst fetch address: %08x\n", addr);
    sim_stop();
  }
  char buf[BUF_SIZE];
  *inst = *(word_t *)guest_to_host(addr);
}

extern "C" void pmem_read(int raddr, int *rdata) {
  if (!LEGAL_MEM_ADDR(raddr)) {
    printf("[PMEM READ] [%d] bad memory read address: %08x\n", (int)sim_time_stamp(), raddr);
    return;
    //sim_stop();
  }
  char buf[BUF_SIZE];
  *rdata = *(int *)guest_to_host(raddr & ~0x3u);
}

extern "C" void pmem_write(int waddr, int wdata, char mask) {
  if (!LEGAL_MEM_ADDR(waddr)) {
    printf("[PMEM WRITE] bad memory write address: %08x\n", waddr);
    sim_stop();
  }
  
  char buf[BUF_SIZE];
  char real_mask[9] = {0};
  
  int i;
  for (i = 0; i < 8; i++) {
    real_mask[7 - i] = (mask >> i & 1) + '0';
  }
  
  uint8_t *base_addr = guest_to_host(waddr & ~0x3u);
  int real_wdata;
  uint8_t *wp = (uint8_t *)&real_wdata;
  for (i = 0; i < 4; i++) {
    *(wp + i) = ((mask >> i) & 1) ? *(((uint8_t *)(&wdata)) + i) : *(base_addr + i);
  }

  // sprintf(buf, "[MEM WRITE] waddr: %08x, wdata: %08x, mask: %s, real_wdata: %08x\n", 
  //         waddr, wdata, real_mask, real_wdata);
  // log(buf);
  
  *(int *)base_addr = real_wdata;
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}
