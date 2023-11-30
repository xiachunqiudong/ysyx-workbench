#include <stdint.h>
#include <stdio.h>
#include <getopt.h>

#include "common.h"
#include "monitor.h"
#include "utils.h"
#include "pmem.h"
#include "difftest.h"

char *img_file;
char *log_file;
char *diff_file;

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
  //  name         has arg                 val  
    {"diff"     , required_argument, NULL, 'd'},          
    {"log"      , required_argument, NULL, 'l'},
    {0          , 0                , NULL,  0 },// must all zero
  };
  int o;
  // e: e选项后面需要有参数
  while ( (o = getopt_long(argc, argv, "-l:d:", table, NULL)) != -1) {
    switch (o) {
      case 'd': diff_file = optarg; break;
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

void sdb_mainloop();
void cpu_rst();

void init_monitor(int argc, char *argv[]) {
  
  parse_args(argc, argv);

  init_disasm("riscv32-pc-linux-gnu");
  
  init_log(log_file);

  load_img();

  init_difftest(diff_file, img_file);

  cpu_rst();

  ref_init();

  sdb_mainloop();

}