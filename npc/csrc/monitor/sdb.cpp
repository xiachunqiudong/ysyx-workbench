#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "pmem.h"
#include "sdb.h"
#include "utils.h"

// DPI-C
static uint32_t pc_last, inst_last;

extern "C" void get_pc_inst(uint32_t pc, uint32_t inst) {
  pc_last = pc;
  inst_last = inst;
}

// EBREAK
bool sim_flag = true;
int ret_value = 0;
extern "C" void env_ebreak(uint32_t pc, uint32_t a0) {
  printf("ebreak at pc: %08x, code = %u\n", pc, a0);
  sim_flag = false;
  ret_value = a0;
}


static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc) ");
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

// CPU state
enum CPU_STATE {
  RUNNING = 0, 
  STOP,
};

enum CPU_STATE cpu_state = RUNNING;

void exec_once();

void exec(uint32_t n) {
  int size = 64;
  char disasm[size];
  uint32_t i;
  for (i = 0; i < n; i++) {
    if (cpu_state == STOP) {
      disassemble(disasm, size, pc_last, (uint8_t *)&inst_last, 4);
      printf("The sim env has call the ebreak, end the simulation.\n");
      //printf("0x%08x: %s\n", pc_last, disasm);
      break;
    }
    exec_once();
    disassemble(disasm, size, pc_last, (uint8_t *)&inst_last, 4);
    printf("0x%08x: %s\n", pc_last, disasm);
    if (sim_flag == false) {
      cpu_state = STOP;
    }
  }
}

static int cmd_c(char *arg) {
  exec(-1);
  return 0;
}

static int cmd_q(char *arg) {
  return -1;
}

static int cmd_si(char *arg) {
  if (arg == NULL) {
    exec(1);
  } else if (!is_digit(arg, 'd')) {
    printf("cmd si argument must be a number!\n");
  } else {
    int step = atoi(arg);
    exec(step);
  }
  return 0;
}

static int cmd_info(char *arg) {
  reg_display();
  return 0;
}

static int cmd_x(char *args) {
  char *arg1, *arg2;
  arg1 = strtok(NULL, " ");
  arg2 = strtok(NULL, " ");
  if(arg1 == NULL || arg2 == NULL) {
    printf("cmd x need 2 args\n");
  } else if (!is_digit(arg1, 'd')) {
    printf("arg1 must be a number!\n");
  } else {
    int n = atoi(arg1);
    paddr_t addr;
    sscanf(arg2, "0x%x", &addr);
    if(addr_check(addr)) {
      uint8_t *host_addr = guest_to_host(addr);
      printf("0x%x: ", addr);
      for(int i = n - 1; i >= 0; i--) {
        printf("0x02%x ", host_addr[i]);
      }
      printf("\n");
    } else {
      printf("bad mem access address!\n");
    }
  }
  return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  //{ "help", "Display information about all supported commands", cmd_help },
  { "c",    "Continue the execution of the program",            cmd_c },
  { "q",    "Exit NPC",                                         cmd_q },
  { "si",   "Execute single instruction",                       cmd_si},
  { "info", "Get the program status",                           cmd_info},
  { "x",    "Get memory",                                       cmd_x},
  //{ "p",    "Get the Expr Value",                               cmd_p},
};

#define NR_CMD sizeof(cmd_table)/sizeof(cmd_table[0])

void sdb_mainloop() {
  // readline can not be NULL, so this is endless loop
  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

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

    // 将命令名称和命令表中的所有命令作匹配
    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        // if handler return value < 0 then return
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

int is_npc_exit_bad() {
  return ret_value;
}

