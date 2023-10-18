#include "verilated_vcd_c.h" // for vcd wave
#include "verilated.h"
#include "Vtop.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void pmem_init();
void pmem_read(uint8_t *dest,uint32_t addr, int n);
void rf_states();

VerilatedContext *contextp;
VerilatedVcdC *tfp;
Vtop *top;
vluint64_t main_time = 0;

double sc_time_stamp() {
	return main_time;
}

void init(int argc, char **argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  
  top = new Vtop{contextp};
  
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  top->trace(tfp, 0);
  tfp->open("wave.vcd");
}

void free() {
  if (tfp != nullptr)
    delete tfp;
  if (top != nullptr)
    delete top;
  if (contextp != nullptr)
    delete contextp; 
}

bool sim_flag;
extern "C" void env_ebreak() {
  printf("ebreak at 0x%x\n", top->pc_o);
  sim_flag = false;
}

void show_instr(uint8_t *instr, uint32_t pc) {
  printf("pc: %0x\t", pc);
  printf("instr: ");
  for(int i = 3; i >= 0; i--) {
    printf("%02x ", instr[i]);
  }
  printf("\n");
}

int main(int argc, char **argv) {

  init(argc, argv);
  sim_flag = true;
  pmem_init();

  int clk = 0;
  int rst = 1;
  uint32_t pc;
  uint8_t instr[4];
  while (sim_flag && main_time < 10 && !contextp->gotFinish()) {
    top->clk_i = clk;
    top->rst_i = rst;
    pc = top->pc_o;
    pmem_read(instr, pc, 4);

    top->instr_i = *(uint32_t *)&instr;
    top->eval();
    tfp->dump(main_time);
    rf_states();
    main_time++;
    if(main_time == 3) {
      rst = 0;
    }
    clk = 1 - clk;
  }

  free();
  
  return 0;
}