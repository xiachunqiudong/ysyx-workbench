#include <stdio.h>
#include <assert.h>

FILE *log_fp = NULL;

void init_log(const char *log_file) {
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
  printf("Log is written to %s\n", log_file ? log_file : "stdout");
}

void log(char *str) {
  fprintf(log_fp, "%s\n", str);
  fflush(log_fp);
}
