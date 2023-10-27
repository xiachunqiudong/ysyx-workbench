#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "pmem.h"


uint8_t pmem[MEM_SIZE] = {0};

void pmem_init() {
  
  char img_file[] = "/home/xiadong/project/chip/ysyx-workbench"
                    "/npc/test/test.bin";
  
  // rb: read binary
  FILE *fp = fopen(img_file, "rb");
  
  if(fp == NULL) {
    printf("can not open this file!, file name = %s\n", img_file);
    assert(0);
  }
  
  // stream = fp, offset = 0, whence = SEEK_END
  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);
  printf("The image is %s, size = %ld\n", img_file, size);
  fseek(fp, 0, SEEK_SET);
  
  int ret = fread(pmem, size, 1, fp);
  if(ret != 1) {
    printf("ret = %d\n", ret);
    assert(0);
  }

}

// DPI-C
extern "C" void inst_read(paddr_t addr, word_t *inst) {
  if(addr >= MEM_BASE) {
    *inst = *(word_t *)guest_to_host(addr);
     printf("addr = %08x, inst = %08x\n", addr, *inst);
  }
}

extern "C" void pmem_read(int raddr, int *rdate) {
  *rdate = *(int *)guest_to_host(raddr & ~0x3u);
}

extern "C" void pmem_write(int waddr, int wdata, char mask) {
  uint8_t *base_addr = guest_to_host(waddr & ~0x3u);
  int wdata = wdata;
  int i;
  for (i = 0; i < 4; i++) {
    *base_addr = ((mask >> i) & 1) ? *((uint8_t *)(&wdata) + i) : *base_addr;
  }
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}
