#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

#define MEM_SIZE 1024

uint8_t pmem[MEM_SIZE] = {0};

void pmem_init() {
  
  char img_file[] = "/home/xia/project/chip/ysyx-workbench"
                    "/npc/test/test.bin";
  
  // rb: read binary
  FILE *fp = fopen(img_file, "rb");
  if(fp == NULL) {
    printf("can not open this file!\n");
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

void pmem_read(uint8_t *dest,uint32_t addr, int n) {
  for (int i = 0; i < n; i++) {
    *(dest + i) = pmem[addr + i];
  }
}