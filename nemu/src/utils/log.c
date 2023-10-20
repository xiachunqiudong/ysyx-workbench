/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>

extern uint64_t g_nr_guest_inst;
FILE *log_fp = NULL;
// MY LOG
FILE *iring_fp = NULL;
FILE *memlog_fp = NULL;

void init_log(const char *log_file) {
  // itrace
  log_fp = stdout;
  if (log_file != NULL) {
    FILE *fp = fopen(log_file, "w");
    Assert(fp, "Can not open '%s'", log_file);
    log_fp = fp;
  }
  Log("Log is written to %s", log_file ? log_file : "stdout");
}

void init_mytrace() {
  // iring
  char *iring_file = "/home/xiadong/project/chip/ysyx-workbench/nemu/build/nemu-iring-log.txt";
  char *mem_file   = "/home/xiadong/project/chip/ysyx-workbench/nemu/build/nemu-mem-log.txt";
  Log("iring log is written to %s", iring_file);
  iring_fp = fopen(iring_file, "w");
  memlog_fp = fopen(mem_file, "w");
}

bool log_enable() {
  return MUXDEF(CONFIG_TRACE, (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END), false);
}




