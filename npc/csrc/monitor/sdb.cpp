#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <utils.h>

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

void exec_once();

static int cmd_c(char *arg) {
  return 0;
}

static int cmd_q(char *arg) {
  return -1;
}

static int cmd_si(char *arg) {
  exec_once();
  return 0;
}

static int cmd_info(char *arg) {
  reg_display();
  return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  //{ "help", "Display information about all supported commands", cmd_help },
  { "c",    "Continue the execution of the program",            cmd_c },
  { "q",    "Exit NEMU",                                        cmd_q },
  { "si",   "Execute single instruction",                       cmd_si},
  { "info", "Get the program status",                           cmd_info},
  //{ "x",    "Get memory",                                       cmd_x},
  //{ "p",    "Get the Expr Value",                               cmd_p},
};

#define NR_CMD sizeof(cmd_table)

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
