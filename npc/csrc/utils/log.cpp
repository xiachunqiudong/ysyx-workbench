#include "stdio.h"
#include "assert.h"
#include "utils.h"

FILE *log_fp = NULL;
FILE *mem_log_fp = NULL;

void init_log(const char *log_file) {
  char buf[256];
  // itrace
  log_fp = stdout;
  if (log_file != NULL) {
    FILE *fp = fopen(log_file, "w");
    if (fp == NULL) {
      sprintf(buf, "Can not open log file, file name is %s\n", log_file);
      npc_error(buf);
      assert(0);
    }
    log_fp = fp;
  }
  sprintf(buf, "Log is written to %s\n", log_file ? log_file : "stdout");
  npc_info(buf);
}

void init_mem_log(const char *mem_log_file) {
  char buf[256];
  
  if (mem_log_file == NULL) {
    sprintf(buf, "Pmem log file path is NULL, exit simulation!");
    npc_error(buf);
    assert(0);
  }

  mem_log_fp = fopen(mem_log_file, "w");

  if (mem_log_fp == NULL) {
    sprintf(buf, "Can not open pmem log file, file name is %s\n", mem_log_file);
    npc_error(buf);
    assert(0);
  }
  
  sprintf(buf, "Pmem log is written to %s\n", mem_log_file);
  npc_info(buf);

}


void log(char *str) {
  fprintf(log_fp, "%s\n", str);
  fflush(log_fp);
}

void mem_log(char *str) {
  fprintf(mem_log_fp, "%s\n", str);
  fflush(mem_log_fp);
}

void npc_info(char *str) {
  printf(ANSI_FG_CYAN "[NPC info] %s" ANSI_NONE, str);
}

void npc_error(char *str) {
  printf(ANSI_FG_RED "[NPC error] %s" ANSI_NONE, str);
}

