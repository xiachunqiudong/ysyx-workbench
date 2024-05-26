#include <stdint.h>
#include <assert.h>
#include <stdio.h>

#define ROM_BASE 0x20000000
#define ROM_SIZE 0x20000fff

uint8_t rom[ROM_SIZE];

void mrom_init() {
  for (int i =0; i < ROM_SIZE; i++) {
    rom[i] = i;
  }
  *(uint32_t *)rom = 0x00100073;
}

extern "C" void mrom_read(uint32_t addr, uint32_t *data) {
  if (addr >= ROM_BASE && addr < ROM_BASE + ROM_SIZE) {
    *data = *(uint32_t *)(rom + addr - ROM_BASE);
  } else {
    assert(0);
  }
}

