/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/difftest.h>
#include "../local-include/reg.h"

void reg_display(CPU_state *cpu);

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
  word_t *reg_gpr = ref_r->gpr;
  int i;
  // comapre pc
  if(ref_r->pc != cpu.pc) {
    printf("difftest: pc different ref->pc: 0x%08x, dut->pc: 0x%08x\n", ref_r->pc, cpu.pc);
    printf("ref: \n");
    reg_display(ref_r);
    return false;
  }
  // compare regfile
  for (i = 0; i < 32; i++) {
    if (reg_gpr[i] != cpu.gpr[i]) {
      printf("ref: \n");
      reg_display(ref_r);
      return false;
    }
  }
  return true;
}

void isa_difftest_attach() {
}
