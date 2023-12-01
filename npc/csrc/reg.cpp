#include "verilated_dpi.h"
#include "common.h"

word_t *cpu_gpr = nullptr;

// get the rtl regfile value by reference pass
extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
  cpu_gpr = (word_t *)(((VerilatedDpiOpenVar*)r)->datap());
}

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void reg_display() {
  for(int i = 0; i < 32; i++) {
    
    if (i == 0)
      printf("%s = 0x%08x\t",regs[i], 0);
    else
      printf("%s = 0x%08x\t", regs[i], cpu_gpr[i-1]);
    
    if((i + 1) % 8 == 0)
      printf("\n");
  
  }
}

word_t gpr_val(int idx) {
  return cpu_gpr[idx];
} 