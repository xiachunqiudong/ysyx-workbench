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

#include <isa.h>
#include <cpu/cpu.h>
#include <memory/paddr.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");
  // add history
  if (line_read && *line_read) {
    add_history(line_read);
  }
  if(!line_read) {
    // printf("line_read is NULL\n");
  }
  // printf("line_read: %s\n", line_read);
  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) {
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args) {
  if(args == NULL) {
    cpu_exec(1);
  } else {
    // TODO: 输入合法性检测
    int step = atoi(args);
    cpu_exec(step);
  }
  return 0;
}

static int cmd_info(char *args) {
  if(args == NULL) {
    printf("info need 1 arg!\n");
  } else if(strcmp("r", args) == 0) {
    isa_reg_display();
  } else if(strcmp("w", args) == 0) {
    printf("info watch point\n");
  } else {
    printf("unknow info arg!\n");
  }
  return 0;
}

static int cmd_x(char *args) {
  char *arg1, *arg2;
  arg1 = strtok(NULL, " ");
  arg2 = strtok(NULL, " ");
  if(arg1 == NULL || arg2 == NULL) {
    printf("cmd x need 2 args\n");
  } else {
    // printf("arg1 = %s, arg2 = %s\n", arg1, arg2);
    int n = atoi(arg1);
    int addr;
    sscanf(arg2, "0x%x", &addr);
    printf("0x%x: ", addr);
    for(int i = n - 1; i >= 0; i--) {
      printf("0x%x ", paddr_read(addr + i, 1));
    }
    printf("\n");
  }
  return 0;
}

static int cmd_p(char *args) {
  if(args != NULL) {
    bool success;
    expr(args, &success);
  } else {
    printf("cmd_p need 1 arg!\n");
  }
  return 0;
}


static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c",    "Continue the execution of the program",            cmd_c },
  { "q",    "Exit NEMU",                                        cmd_q },
  { "si",   "Execute single instruction",                       cmd_si},
  { "info", "Get the program status",                           cmd_info},
  { "x",    "Get memory",                                       cmd_x},
  { "p",    "Get the Expr Value",                               cmd_p},

  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  // printf("arg = %s\n", arg);
  // printf("args = %s\n", args);
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  // readline can not be NULL, so this is endless loop
  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    // strtok("hello world", " ")
    // hello[\0]world

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        // return value < 0 => return
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
