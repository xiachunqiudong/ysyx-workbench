#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "npc.h"
#include "pmem.h"
#include "utils.h"
#include "time.h"

extern "C" void flash_read(uint32_t addr, uint32_t *data) {

}

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
    #ifdef LOG
    sprintf(buf, "%08d  [PMEM READ] addr: 0x%08x, data: 0x%08x\n", (int)sim_time_stamp(), raddr, *rdata);
    #endif
  } else if(IN_RTC(raddr)) {
    time(&cur_time);
    *rdata = (uint32_t)cur_time;
    #ifdef LOG
    sprintf(buf, "[MMIO: RTC] [%d] addr: 0x%08x, data: 0x%08x\n", (int)sim_time_stamp(), raddr, *rdata);
    mem_log(buf);
    #endif
  } else {
    #ifdef LOG
    sprintf(buf, "[PMEM READ] [%d] bad memory read address: 0x%08x\n", (int)sim_time_stamp(), raddr);
    #endif    
    sim_stop();
  }
  #ifdef LOG
  mem_log(buf);
  #endif
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
    #ifdef LOG
    sprintf(buf, "%08d  [MEM WRITE] waddr: %08x, wdata: %08x, mask: %s, real_wdata: %08x", 
      (int)sim_time_stamp(), waddr, wdata, real_mask, real_wdata);
    mem_log(buf);
    #endif
    return;
  }
    
  // 2. Write to Serial
  if (IN_SRIAL(waddr)) {
    putchar((int)wdata);
    #ifdef LOG
    sprintf(buf, "%08d  [MEM WRITE] waddr: %08x, wdata: %08x, mask: %s", 
      (int)sim_time_stamp(), waddr, wdata, real_mask);
    mem_log(buf);
    #endif
    return;
  }
  
  // Bad Address
  #ifdef LOG
  sprintf(buf, "[PMEM WRITE] bad memory write address: %08x\n", waddr);
  mem_log(buf);
  #endif
  sim_stop();
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}
