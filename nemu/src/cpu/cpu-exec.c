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

#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>

/* The assembly code of instructions executed is only output to the screen
 * when the number of instructions executed is less than this value.
 * This is useful when you use the `si' command.
 * You can modify this value as you want.
 */
#define MAX_INST_TO_PRINT 10

CPU_state cpu = {};
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

void device_update();

static void trace_and_difftest(Decode *_this, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
  if (ITRACE_COND) { log_write("%s\n", _this->logbuf); }
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(_this->pc, dnpc));
}

#ifdef CONFIG_ITRACE
#define IRING_SIZE 10
#define IRING_BUF_SIZE 256
char *iring[IRING_SIZE];
int iring_idx = 0;

static void iring_record(Decode *s) {
  if(iring[iring_idx] == NULL) {
    iring[iring_idx] = (char *)malloc(IRING_BUF_SIZE);
  }
  char *p = iring[iring_idx];
  char *start = p;
  iring_idx = (iring_idx + 1) % IRING_SIZE;

  // -->pc
  p += snprintf(p, IRING_BUF_SIZE, "   0x%08x: ", s->pc);
  int ilen = s->snpc - s->pc;
  uint8_t *inst = (uint8_t *)&s->isa.inst.val;
  
  // inst code
  int disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  p  += disassemble(p, start + IRING_BUF_SIZE - p,
                  MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), inst, ilen);
  *(p - 1) = '\t';
  
  // inst binary
  int i;
  for(i = ilen - 1; i >= 0; i--) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }

  // the end
  *p = '\0';

}

char *get_func_name(word_t pc);

int level = 0;
char buf[256];
static void ftrace(Decode *s) {
  word_t opcode = s->isa.opcode;
  word_t rs1 = s->isa.rs1;
  word_t rd = s->isa.rd;
  
  bool jal = opcode == 111;
  bool jalr = opcode == 103;

  bool call = (rd == 1) && (jal || jalr);
  bool ret = jalr && (rs1 == 1) && (rd == 0);

  char *p = buf;
  p += sprintf(p, "0x%08x: ", s->pc);
  
  if(call)
    level++;
  else if(ret)
    level--;

  int i;
  for (i = 0; i < level * 2; i++) {
    *p++ = ' ';
  }
  if (call) {
    char *func_name = get_func_name(s->dnpc);
    p += sprintf(p, "call [%s]@0x%08x", func_name, s->dnpc);
  }
  if (ret) {
    char *func_name = get_func_name(s->pc);
    p += sprintf(p, "ret [%s]", func_name);
  }
}
#endif

static void exec_once(Decode *s, vaddr_t pc) {
  printf("[exec onec] pc:%08x\n", pc);
  s->pc = pc;
  s->snpc = pc;
  isa_exec_once(s);
  cpu.pc = s->dnpc;

#ifdef CONFIG_ITRACE

  iring_record(s);
  ftrace(s);

  char *p = s->logbuf;
  p += snprintf(p, sizeof(s->logbuf), FMT_WORD ":", s->pc);
  int ilen = s->snpc - s->pc;
  int i;
  uint8_t *inst = (uint8_t *)&s->isa.inst.val;
  for (i = ilen - 1; i >= 0; i --) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0) space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;

#ifndef CONFIG_ISA_loongarch32r
  int disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, s->logbuf + sizeof(s->logbuf) - p,
      MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), (uint8_t *)&s->isa.inst.val, ilen);
#else
  p[0] = '\0'; // the upstream llvm does not support loongarch32r
#endif
#endif
}

static void execute(uint64_t n) {
  Decode s;
  for (;n > 0; n --) {
    exec_once(&s, cpu.pc);
    g_nr_guest_inst ++;
    trace_and_difftest(&s, cpu.pc);
    if (nemu_state.state != NEMU_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }
}

static void statistic() {
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg() {
  isa_reg_display();
  statistic();
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (nemu_state.state) {
    case NEMU_END: case NEMU_ABORT:
      printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
      return;
    default: nemu_state.state = NEMU_RUNNING;
  }

  uint64_t timer_start = get_time();

  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (nemu_state.state) {
    case NEMU_RUNNING: nemu_state.state = NEMU_STOP; break;

    case NEMU_END: case NEMU_ABORT:
      Log("nemu: %s at pc = " FMT_WORD,
          (nemu_state.state == NEMU_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (nemu_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          nemu_state.halt_pc);
      
      #ifdef CONFIG_ITRACE
      // need fix
      if (nemu_state.halt_ret == 0) {
        printf("iringbuf: bad TRAP\n");
        int idx = (iring_idx - 1 + IRING_SIZE) % IRING_SIZE;
        iring[idx][0] = '-';
        iring[idx][1] = '-';
        iring[idx][2] = '>';
        int i;
        for(i = 0; i < IRING_SIZE && iring[i] != NULL; i++) {
          IRING_LOG(iring[i]);
        }
      }
      #endif
      // fall through
    case NEMU_QUIT: statistic();
  }
}
