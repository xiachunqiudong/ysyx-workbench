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

extern "C" void inst_read(paddr_t addr, word_t *inst) {
  if(addr >= MEM_BASE) {
    *inst = *(word_t *)guest_to_host(addr);
     printf("addr = %08x, inst = %08x\n", addr, *inst);
  }
}

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem + paddr - MEM_BASE;
}

uint32_t inst_read(uint32_t pc) {
  return *(uint32_t *)guest_to_host(pc);
}


void pmem_read(uint8_t *dest,uint32_t addr, int n) {
  for (int i = 0; i < n; i++) {
    *(dest + i) = pmem[addr + i];
  }
}