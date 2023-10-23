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

// MY LOG
FILE *iring_fp = NULL;
FILE *memlog_fp = NULL;

// for elf parse
char *strtab;
Elf32_Sym *symtab;
unsigned int nsymtab;

void elf_parse(const char *elf_file) {
  FILE *elf_fp = fopen(elf_file, "rb");
  if (elf_fp == NULL) {
    Log("Can not open this elf file, file name = %s", elf_file);
    assert(0);
  }
  Log("Parse elf file from %s", elf_file);
  
  // read elf header
  size_t ret;
  Elf32_Ehdr elf_hdr;
  ret = fread(&elf_hdr, sizeof(elf_hdr), 1, elf_fp);
  assert(ret != 0);
  // 根据 elf header 获取 section header table offset
  Elf32_Off sh_off = elf_hdr.e_shoff;
  uint16_t sh_num = elf_hdr.e_shnum;
  
  fseek(elf_fp, sh_off, SEEK_SET);
  // read section header table
  Elf32_Shdr shdr_tab[sh_num];
  ret = fread(&shdr_tab, sizeof(Elf32_Shdr), sh_num, elf_fp);
  assert(ret != 0);
  int i;
  Elf32_Off strtab_off = 0, symtab_off = 0;
  uint32_t strtab_size = 0, symtab_size = 0;
  // 遍历找到 str table 和 symbol table 的位置
  for (i = 0; i < sh_num; i++) {
    Elf32_Shdr shdr = shdr_tab[i];
    if (shdr.sh_type == SHT_SYMTAB) {
      symtab_off = shdr.sh_offset;
      symtab_size = shdr.sh_size;
      nsymtab = symtab_size / shdr.sh_entsize;
      break;
    }
  }
  for (i = 0; i < sh_num; i++) {
    Elf32_Shdr shdr = shdr_tab[i];
    if (shdr.sh_type == SHT_STRTAB) {
      strtab_off = shdr.sh_offset;
      strtab_size = shdr.sh_size;
      break;
    }
  }
  
  // read str table
  fseek(elf_fp, strtab_off, SEEK_SET);
  strtab = (char *)malloc(strtab_size);
  ret = fread(strtab, 1, strtab_size, elf_fp);
  assert(ret != 0);

  // read symbol table
  fseek(elf_fp, symtab_off, SEEK_SET);
  symtab = (Elf32_Sym *)malloc(symtab_size);
  ret = fread(symtab, symtab_size, 1, elf_fp);
  assert(ret != 0);

  fclose(elf_fp);
}

char *get_func_name(word_t pc) {
  int i;
  char *func_name = NULL;
  for(i = 0; i < nsymtab; i++) {
    Elf32_Sym sym = symtab[i];
    // st_info: unsigned char
    // st_info[7:4]: symbol binding
    // st_info[3:0]: symbol type
    bool is_fun = (sym.st_info & 0xf) == STT_FUNC;
    // 只要是落在这个函数区间内的指令
    if(is_fun && (pc >= sym.st_value) && (pc < sym.st_value + sym.st_size)) {
      func_name = strtab + symtab[i].st_name;
    }
  }
  return func_name;
}

void init_mytrace() {
  // iring
  char *iring_file = "/home/xiadong/project/chip/ysyx-workbench/nemu/build/nemu-iring-log.txt";
  char *mem_file   = "/home/xiadong/project/chip/ysyx-workbench/nemu/build/nemu-mem-log.txt";
  Log("iring log is written to %s", iring_file);
  iring_fp = fopen(iring_file, "w");
  memlog_fp = fopen(mem_file, "w");
  // ftrace
}

bool log_enable() {
  return MUXDEF(CONFIG_TRACE, (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END), false);
}




