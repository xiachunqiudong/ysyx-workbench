#include <elf.h>
#include <stdio.h>
#include <stdlib.h>

char *strtab;
Elf32_Sym *symtab;


int main() {
  char *elf_path = "/home/xiadong/project/chip/"
                   "ysyx-workbench/am-kernels/tests/cpu-tests/build/"
                   "add-riscv32-nemu.elf";
  
  FILE *elf_fp = fopen(elf_path, "rb");
  
  // read elf header
  Elf32_Ehdr elf_hdr;
  fread(&elf_hdr, sizeof(elf_hdr), 1, elf_fp);
  // 根据 elf header 获取 section header table offset
  Elf32_Off sh_off = elf_hdr.e_shoff;
  uint16_t sh_num = elf_hdr.e_shnum;
  
  fseek(elf_fp, sh_off, SEEK_SET);
  // read section header table
  Elf32_Shdr shdr_tab[sh_num];
  fread(&shdr_tab, sizeof(Elf32_Shdr), sh_num, elf_fp);

  int i;
  Elf32_Off strtab_off, symtab_off;
  uint32_t strtab_size, symtab_size;
  // 遍历找到 str table 和 symbol table 的位置
  for (i = 0; i < sh_num; i++) {
    Elf32_Shdr shdr = shdr_tab[i];
    if (shdr.sh_type == SHT_SYMTAB) {
      symtab_off = shdr.sh_offset;
      symtab_size = shdr.sh_size;
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
  fread(strtab, 1, strtab_size, elf_fp);

  // read symbol table
  fseek(elf_fp, symtab_off, SEEK_SET);
  symtab = (Elf32_Sym *)malloc(symtab_size);
  fread(symtab, symtab_size, 1, elf_fp);
  int sym_size = symtab_size/sizeof(Elf32_Sym);
  for(i = 0; i < sym_size; i++) {
    Elf32_Sym sym = symtab[i];
    // st_info: unsigned char
    // st_info[7:4]: symbol binding
    // st_info[3:0]: symbol type
    if((sym.st_info & 0xf) == STT_FUNC) {
      printf("%s\n", strtab + symtab[i].st_name);
    }
  }
  
}