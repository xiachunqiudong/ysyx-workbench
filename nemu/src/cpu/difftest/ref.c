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
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>

// addr: Ref guest memory 
// buf:  Dut host memory 
__EXPORT void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) {
  // DIFFTEST_TO_DUT 0
  // DIFFTEST_TO_REF 1
  uint8_t *ref_host_addr = guest_to_host(addr);
  int i;
  for (i = 0; i < n; i++) {
    if(direction)
      *ref_host_addr = *((uint8_t *)buf);
    else
      *((uint8_t *)buf) = *ref_host_addr;
  }
}

__EXPORT void difftest_regcpy(void *dut, bool direction) {
  RISCV_GPR_TYPE * dut_ptr = (RISCV_GPR_TYPE *)dut;
  int i;
  for (i = 0; i < RISCV_GPR_NUM; i++) {
    if (direction)
      cpu.gpr[i] = dut_ptr[i];
    else
      dut_ptr[i] = cpu.gpr[i];
  }
  if (direction)
    cpu.pc = dut_ptr[RISCV_GPR_NUM];
  else
    dut_ptr[RISCV_GPR_NUM] = cpu.pc;
}

__EXPORT void difftest_exec(uint64_t n) {
  assert(0);
}

__EXPORT void difftest_raise_intr(word_t NO) {
  assert(0);
}

__EXPORT void difftest_init(int port) {
  void init_mem();
  init_mem();
  /* Perform ISA dependent initialization. */
  init_isa();
}
