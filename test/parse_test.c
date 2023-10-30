#include <stdio.h>
#include <getopt.h>

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
  //  name         has arg                 val            
    {"log"      , required_argument, NULL, 'l'},
    {0          , 0                , NULL,  0 },// must all zero
  };
  int o;
  // e: e选项后面需要有参数
  while ( (o = getopt_long(argc, argv, "-bhl:d:e:p:i:m:", table, NULL)) != -1) {
    switch (o) {
      case 'l': printf("log file name: %s\n", optarg); break;
      case 1: printf("img file name: %s\n", optarg); return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-e,--elf=ELF_FILE       get elf_file from ELF_FILE\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-i,--iring=FILE         output iring to FILE\n");
        printf("\t-m,--memlog=FILE        output memlog to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
    }
  }
  return 0;
}

int main(int argc, char *argv[]) {
	parse_args(argc, argv);
	return 0;
}


