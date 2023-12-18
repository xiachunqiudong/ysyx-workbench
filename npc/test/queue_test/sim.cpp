#include "verilated_vcd_c.h" // for vcd wave
#include "verilated.h"
#include "Vqueue.h"
#include "stdlib.h"
#include "time.h"
#include "stdio.h"

VerilatedContext *contextp;
VerilatedVcdC *tfp;
Vqueue *dut;
vluint64_t main_time = 0;

void init_verilator(int argc, char **argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  
  dut = new Vqueue{contextp};
  
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  dut->trace(tfp, 0);
  tfp->open("queue.vcd");
}

void free() {
  if (tfp != nullptr)
    delete tfp;
  if (dut != nullptr)
    delete dut;
  if (contextp != nullptr)
    delete contextp; 
}

void reset() {
  dut->clk_i = 0;
  dut->rst_i = 0;
  dut->eval();
  tfp->dump(main_time++);
  
  dut->clk_i = 1;
  dut->rst_i = 1;
  dut->eval();
  tfp->dump(main_time++);
}

int clk = 0, rst = 0;

int main(int argc, char *argv[]) {
  srand((unsigned int)time(NULL));
  init_verilator(argc, argv);
  reset();
  dut->rst_i = 0;
  int data = 1;
  for (int i = 0; i < 1000; i++) {
    dut->clk_i = 0;
    dut->eval();
    tfp->dump(main_time++);
    
    if (rand() % 2) {
      dut->push    = 1;
      dut->data_in = data;
      data ++;
    }
    
    if (rand() % 2) {
      dut->pop    = 1;
      printf("data_out = %d\n", dut->data_out);
    }

    dut->clk_i = 1;
    dut->eval();
    tfp->dump(main_time++);
  }

  free();
  
  return 0;
}