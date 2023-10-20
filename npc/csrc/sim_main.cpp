#include "verilated_vcd_c.h" // for vcd wave
#include "verilated.h"
#include "Vtop.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void pmem_init();
uint32_t inst_read(uint32_t pc);
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

void show_inst(uint8_t *instr, uint32_t pc) {
  printf("pc: %0x\t", pc);
  printf("inst: ");
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
  uint32_t pc, inst;
  while (sim_flag && main_time < 10 && !contextp->gotFinish()) {
    top->clk_i = clk;
    top->rst_i = rst;
    
    pc = top->pc_o;
    inst = inst_read(pc);
    show_inst((uint8_t *)&inst, pc);
    top->instr_i = inst;
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