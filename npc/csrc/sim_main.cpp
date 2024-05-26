#include "verilated_vcd_c.h" // for vcd wave
#include "verilated.h"
#include "VysyxSoCTop.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "config.h"
#include "monitor.h"
#include "sdb.h"
#include "utils.h"

VerilatedContext *contextp;
VerilatedVcdC *tfp;
VysyxSoCTop *top;
vluint64_t main_time = 0;
uint64_t MAX_SIM_TIME = 100000;

double sim_time_stamp() {
	return main_time;
}

void init_verilator(int argc, char **argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top = new VysyxSoCTop{contextp};
  
#ifdef WAVE
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  top->trace(tfp, 0);
  tfp->open("wave.vcd");
#endif

}

void free() {
  if (tfp != nullptr)
    delete tfp;
  if (top != nullptr)
    delete top;
  if (contextp != nullptr)
    delete contextp; 
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
  top->clock = 0;
  top->reset = 0;
  top->eval();
  
  if (tfp != nullptr) tfp->dump(main_time++);
  
  // reset
  top->clock = 1;
  top->reset = 1;
  top->eval();
  
  if (tfp != nullptr) tfp->dump(main_time++);
}

void exec_once() {

  top->clock = 0;
  top->reset = 0;
  top->eval();
  
  if (tfp != nullptr) tfp->dump(main_time++);
  
  top->clock = 1;
  top->reset = 0;
  top->eval();

  if (tfp != nullptr) tfp->dump(main_time++);

  // Reach the max simulation time.
  if (main_time > MAX_SIM_TIME) {
    char buf[128];
    sprintf(buf, "Reach the max simulation time, stop sim.\n");
    npc_info(buf);
    free();
    exit(0);
  }

}

void sim_stop() {
  printf("something bad happen, stop sim!\n");
  free();
  exit(0);
}

int main(int argc, char *argv[]) {

  init_verilator(argc, argv);

  init_monitor(argc, argv);

  free();
  
  return is_npc_exit_bad();
}