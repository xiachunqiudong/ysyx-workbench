#include <stdint.h>
#include <stdio.h>
#include <getopt.h>
#include "verilated_dpi.h"
#include "pmem.h"
#include "monitor.h"
#include "log.h"

typedef uint32_t word_t;

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
    
    if((i + 1) % 8 == 0) {
      printf("\n");
    }
  
  }
}

char *img_file;
char *log_file;

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
  //  name         has arg                 val            
    {"log"      , required_argument, NULL, 'l'},
    {0          , 0                , NULL,  0 },// must all zero
  };
  int o;
  // e: e选项后面需要有参数
  while ( (o = getopt_long(argc, argv, "-l:", table, NULL)) != -1) {
    switch (o) {
      case 'l': log_file = optarg; break;
      case 1:   img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-e,--elf=FILE           get elf_file from FILE\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-i,--iring=FILE         output iring to FILE\n");
        printf("\t-m,--memlog=FILE        output memlog to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        return 1;
    }
  }
  return 0;
}

static void load_img() {
  if (img_file != NULL) {
    printf("load img file from %s\n", img_file);
    // rb: read binary
    FILE *fp = fopen(img_file, "rb");
    
    if(fp == NULL) {
      printf("can not open this file!, file name = %s\n", img_file);
      assert(0);
    }
    
    // stream = fp, offset = 0, whence = SEEK_END
    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);
    printf("This image size is %ld\n", size);
    fseek(fp, 0, SEEK_SET);
    
    int ret = fread(guest_to_host(MEM_BASE), size, 1, fp);
    if(ret != 1) {
      printf("ret = %d\n", ret);
      assert(0);
    }
  } else {
    printf("img file is NULL use the default img\n");
    assert(0);
  }
}

void init_disasm(const char *triple);


void init_monitor(int argc, char *argv[]) {
  
  parse_args(argc, argv);

  init_disasm("riscv32-pc-linux-gnu");
  
  init_log(log_file);

  load_img();
}