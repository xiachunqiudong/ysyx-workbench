#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "difftest.h"
#include "pmem.h"
#include "npc.h"
#include "sdb.h"
#include "utils.h"

// DPI-C
static uint32_t this_pc_d1, this_inst_d1, this_pc, this_inst;

extern "C" void get_pc_inst(uint32_t pc_d1, uint32_t inst_d1, uint32_t pc, uint32_t inst) {
  this_pc_d1 = pc_d1;
  this_inst_d1 = inst_d1;
  this_pc = pc;
  this_inst = inst;
}

// EBREAK
int ret_value = 0;
extern "C" void env_ebreak(uint32_t pc, uint32_t a0) {
  char buf[128];
  sprintf(buf, "The npc sim env has call the ebreak, end the simulation.\n" "ebreak at pc: %08x, code = %u\n", pc, a0);
  npc_info(buf);
  ret_value = a0;
  npc_set_state(NPC_STOP);
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

void exec_once();

bool is_batch_mode = false;
void set_batch_mode() {
  is_batch_mode = true;
}

void exec(uint32_t n) {
  int size = 64;
  char disasm[size], buf[128];
  for (uint32_t i = 0; i < n; i++) {
    if (npc_get_state() == NPC_STOP) {
      disassemble(disasm, size, this_pc_d1, (uint8_t *)&this_inst_d1, 4);
      sprintf(buf, "npc sim stop caused by ebreak, at %08x: %s\n", this_pc, disasm);
      npc_info(buf);
      break;
    } else if (npc_get_state() == NPC_ERROR_DIFF) {
      disassemble(disasm, size, this_pc_d1, (uint8_t *)&this_inst_d1, 4);
      sprintf(buf, "npc sim error caused by difftest fail, at %08x: %s\n", this_pc_d1, disasm);
      npc_error(buf);
      break;
    } else {
      exec_once();
      #ifdef DIFF
      if(!difftest_step(this_pc)) {// diff fail
        npc_set_state(NPC_ERROR_DIFF);
        ret_value = 1;
      }
      #endif
      if (is_batch_mode == false) {
        disassemble(disasm, size, this_pc_d1, (uint8_t *)&this_inst_d1, 4);
        printf("%08x: %s\n", this_pc_d1, disasm);
      }
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

  if (is_batch_mode) {
    char buf[128];
    sprintf(buf, "batch mode on, if you wanna close this mode please remove the -b in abstract-machine/scripts/platform/npc.mk\n");
    npc_info(buf);
    cmd_c(nullptr);
    return;
  }

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

