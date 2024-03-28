#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "npc.h"
#include "pmem.h"
#include "utils.h"
#include "time.h"

time_t cur_time;

void sim_stop();
double sim_time_stamp();

#define BUF_SIZE 256
char buf[BUF_SIZE];

uint8_t pmem[MEM_SIZE] = {0};

void init_pmem() {
  sprintf(buf, "PMEM at [0x%08x, 0x%08x]\n", MEM_BASE, MEM_BASE + MEM_SIZE - 1);
  npc_info(buf);
  sprintf(buf, "MMIO: Serial at [0x%08x, 0x%08x]\n", SRIAL_BASE, SRIAL_BASE + SRIAL_SIZE - 1);
  npc_info(buf);
  sprintf(buf, "MMIO: RTC at [0x%08x, 0x%08x]\n", RTC_BASE, RTC_BASE + RTC_SIZE - 1);
  npc_info(buf);
}

static void addr_check(paddr_t addr) {
  if(!IN_MEM(addr)) {
    sprintf(buf, "Bad memory address: %08x at %f, stop simulation!\n", addr, sim_time_stamp());
    npc_error(buf);
    sim_stop();
  }
}

// DPI-C
extern "C" void pmem_read(paddr_t raddr, uint32_t *rdata) {
  if (IN_MEM(raddr)) {
    *rdata = *(uint32_t *)guest_to_host(raddr & ~0x3u);
    sprintf(buf, "%08d  [PMEM READ] addr: 0x%08x, data: 0x%08x\n", (int)sim_time_stamp(), raddr, *rdata);
  } else if(IN_RTC(raddr)) {
    time(&cur_time);
    *rdata = (uint32_t)cur_time;
    sprintf(buf, "[MMIO: RTC] [%d] addr: 0x%08x, data: 0x%08x\n", (int)sim_time_stamp(), raddr, *rdata);
    mem_log(buf);
  } else {
    sprintf(buf, "[PMEM READ] [%d] bad memory read address: 0x%08x\n", (int)sim_time_stamp(), raddr);
    sim_stop();
  }
  mem_log(buf);
}

extern "C" void pmem_write(uint32_t waddr, uint32_t wdata, char mask) {
  char real_mask[9] = {0};
  for (int i = 0; i < 8; i++) real_mask[7 - i] = (mask >> i & 1) + '0';
  
  // 1. Write to Physical Memory
  if (IN_MEM(waddr)) { 
    uint8_t *base_addr = guest_to_host(waddr & ~0x3u);
    uint32_t real_wdata;
    uint8_t *wp = (uint8_t *)&real_wdata;
    for (int i = 0; i < 4; i++) {
      *(wp + i) = ((mask >> i) & 1) ? *(((uint8_t *)(&wdata)) + i) : *(base_addr + i);
    }
    *(uint32_t *)base_addr = real_wdata;
    sprintf(buf, "%08d  [MEM WRITE] waddr: %08x, wdata: %08x, mask: %s, real_wdata: %08x", 
      (int)sim_time_stamp(), waddr, wdata, real_mask, real_wdata);
    mem_log(buf);
    return;
  }
    
  // 2. Write to Serial
  if (IN_SRIAL(waddr)) {
    putchar((int)wdata);
    sprintf(buf, "%08d  [MEM WRITE] waddr: %08x, wdata: %08x, mask: %s", 
      (int)sim_time_stamp(), waddr, wdata, real_mask);
    mem_log(buf);
    return;
  }
  
  // Bad Address
  sprintf(buf, "[PMEM WRITE] bad memory write address: %08x\n", waddr);
  mem_log(buf);
  sim_stop();
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}
