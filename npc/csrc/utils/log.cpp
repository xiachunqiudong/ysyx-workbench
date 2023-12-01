#include "utils.h"

FILE *log_fp = NULL;

void init_log(const char *log_file) {
  char buf[128];
  // itrace
  log_fp = stdout;
  if (log_file != NULL) {
    FILE *fp = fopen(log_file, "w");
    if (fp == NULL) {
      printf("Can not open log file, file name is %s\n", log_file);
      assert(0);
    }
    log_fp = fp;
  }
  sprintf(buf, "Log is written to %s\n", log_file ? log_file : "stdout");
  npc_info(buf);
}

void log(char *str) {
  fprintf(log_fp, "%s\n", str);
  fflush(log_fp);
}

void npc_info(char *str) {
  printf(ANSI_FG_CYAN "[NPC info] %s" ANSI_NONE, str);
}

void npc_error(char *str) {
  printf(ANSI_FG_RED "[NPC error] %s" ANSI_NONE, str);
}

