#include <stdint.h>
#include <stdio.h>
#include <getopt.h>

#include "common.h"
#include "monitor.h"
#include "utils.h"
#include "pmem.h"
#include "difftest.h"
#include "sdb.h"

char *img_file;
char *log_file;
char *diff_file;

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
  //  name         has arg                 val
    {"batch"    , no_argument      , NULL, 'b'},  
    {"diff"     , required_argument, NULL, 'd'},          
    {"log"      , required_argument, NULL, 'l'},
    {0          , 0                , NULL,  0 },// must all zero
  };
  int o;
  // e: e选项后面需要有参数
  while ( (o = getopt_long(argc, argv, "-bl:d:", table, NULL)) != -1) {
    switch (o) {
      case 'b': set_batch_mode(); break;
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

static long load_img() {
  char buf[128];
  long size;
  if (img_file != NULL) {
    // rb: read binary
    FILE *fp = fopen(img_file, "rb");
    
    if(fp == NULL) {
      printf("can not open this file!, file name = %s\n", img_file);
      assert(0);
    }
    
    // stream = fp, offset = 0, whence = SEEK_END
    fseek(fp, 0, SEEK_END);
    size = ftell(fp);
    sprintf(buf, "load img from %s, image size is %ld\n", img_file, size);
    npc_info(buf);
    fseek(fp, 0, SEEK_SET);
  
    if(fread(guest_to_host(MEM_BASE), size, 1, fp) != 1) {
      assert(0);
    }
  } else {
    sprintf(buf, "img file is NULL use the default img\n");
    npc_error(buf);
    assert(0);
  }
  return size;
}

void sdb_mainloop();
void cpu_rst();

void init_monitor(int argc, char *argv[]) {
  
  parse_args(argc, argv);

  init_disasm("riscv32-pc-linux-gnu");
  
  init_log(log_file);

  int img_size = load_img();

  #ifdef DIFF
  init_difftest(diff_file, img_size, 0);
  #endif

  cpu_rst();

  sdb_mainloop();

}