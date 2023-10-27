#include "verilated_vcd_c.h" // for vcd wave
#include "verilated.h"
#include "Vtop.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "pmem.h"
#include "monitor.h"

VerilatedContext *contextp;
VerilatedVcdC *tfp;
Vtop *top;
vluint64_t main_time = 0;

double sc_time_stamp() {
	return main_time;
}

void init_verilator(int argc, char **argv) {
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

bool sim_flag = true;
extern "C" void env_ebreak() {
  printf("ebreak!\n");
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

void cpu_rst() {
  top->clk_i = 0;
  top->rst_i = 0;
  top->eval();
  tfp->dump(main_time++);
  
  // reset
  top->clk_i = 1;
  top->rst_i = 1;
  top->eval();
  tfp->dump(main_time++);
}

void exec_once() {
  top->clk_i = 0;
  top->rst_i = 0;
  top->eval();
  tfp->dump(main_time++);


  top->clk_i = 1;
  top->rst_i = 0;
  top->eval();
  tfp->dump(main_time++);
}


int main(int argc, char *argv[]) {

  init_monitor(argc, argv);

  init_verilator(argc, argv);
  
  cpu_rst();
  
  while (sim_flag && main_time < 50 && !contextp->gotFinish()) {
    exec_once();  
  }

  free();
  
  return 0;
}