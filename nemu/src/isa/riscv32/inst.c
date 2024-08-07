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

#include "local-include/reg.h"
#include "local-include/csr.h"
#include <cpu/cpu.h>
#include <cpu/ifetch.h>
#include <cpu/decode.h>

#define R(i) gpr(i)
#define Mr vaddr_read
#define Mw vaddr_write

enum {
  TYPE_RR,
  TYPE_I, 
  TYPE_S,
  TYPE_B,
  TYPE_U,  
  TYPE_J,
  TYPE_N,// none
};

#define src1R() do { *src1 = R(rs1); } while (0)
#define src2R() do { *src2 = R(rs2); } while (0)
#define immI()  do { *imm = SEXT(BITS(i, 31, 20), 12); } while(0)
#define immS()  do { *imm = (SEXT(BITS(i, 31, 25), 7) << 5) | BITS(i, 11, 7); } while(0)
#define immB()  do { *imm = (SEXT(BITS(i, 31, 31), 1) << 12) \
                                | BITS(i, 7, 7) << 11 \
                                | BITS(i, 30, 25) << 5 \
                                | BITS(i, 11, 8) << 1; } while(0)
#define immU()  do { *imm = SEXT(BITS(i, 31, 12), 20) << 12; } while(0)
#define immJ()  do { *imm = (SEXT(BITS(i, 31, 31), 1) << 20) \
                                | BITS(i, 19, 12) << 12 \
                                | BITS(i, 20, 20) << 11 \
                                | BITS(i, 30, 21) << 1; } while(0)

static void decode_operand(Decode *s, int *rd, word_t *src1, word_t *src2, word_t *imm, int type) {
  uint32_t i = s->isa.inst.val;
  int rs1 = BITS(i, 19, 15);
  int rs2 = BITS(i, 24, 20);
  *rd     = BITS(i, 11, 7);
  s->isa.rs1 = rs1;
  s->isa.rd = *rd;
  s->isa.opcode = BITS(i, 6, 0);
  switch (type) {
    case TYPE_RR: src1R(); src2R();         break;
    case TYPE_I:  src1R();          immI(); break;
    case TYPE_U:                    immU(); break;
    case TYPE_B:  src1R(); src2R(); immB(); break;
    case TYPE_S:  src1R(); src2R(); immS(); break;
    case TYPE_J:                    immJ(); break;
  }
}

static int decode_exec(Decode *s) {
  int rd = 0;
  word_t src1 = 0, src2 = 0;
  word_t imm = 0;
  s->dnpc = s->snpc;

#define INSTPAT_INST(s) ((s)->isa.inst.val)
#define INSTPAT_MATCH(s, name, type, ... /* execute body */ ) { \
  decode_operand(s, &rd, &src1, &src2, &imm, concat(TYPE_, type)); \
  __VA_ARGS__ ; \
}
  /*
  * note:
  *  1. reg 的数据类型为 word_t, rv32: uint32_t, rv64: uint64_t
  */

  INSTPAT_START();
  
  /*
  * RV32I
  */

  // U
  INSTPAT("??????? ????? ????? ??? ????? 01101 11", lui    , U, R(rd) = imm);
  INSTPAT("??????? ????? ????? ??? ????? 00101 11", auipc  , U, R(rd) = s->pc + imm);
  
  // B
  INSTPAT("??????? ????? ????? 000 ????? 11000 11", beq    , B, s->dnpc = (src1 == src2) ? (s->pc + imm) : s->snpc);
  INSTPAT("??????? ????? ????? 001 ????? 11000 11", bne    , B, s->dnpc = (src1 != src2) ? (s->pc + imm) : s->snpc);
  INSTPAT("??????? ????? ????? 100 ????? 11000 11", blt    , B, s->dnpc = ((sword_t)src1 <  (sword_t)src2) ? (s->pc + imm) : s->snpc);
  INSTPAT("??????? ????? ????? 101 ????? 11000 11", bge    , B, s->dnpc = ((sword_t)src1 >= (sword_t)src2) ? (s->pc + imm) : s->snpc);
  INSTPAT("??????? ????? ????? 110 ????? 11000 11", bltu   , B, s->dnpc = (src1 <  src2) ? (s->pc + imm) : s->snpc);
  INSTPAT("??????? ????? ????? 111 ????? 11000 11", bgeu   , B, s->dnpc = (src1 >= src2) ? (s->pc + imm) : s->snpc);

  // R Type
  INSTPAT("0000000 ????? ????? 000 ????? 01100 11", add    , RR, R(rd) = src1 + src2);
  INSTPAT("0100000 ????? ????? 000 ????? 01100 11", sub    , RR, R(rd) = src1 - src2);
  INSTPAT("0000000 ????? ????? 001 ????? 01100 11", sll    , RR, R(rd) = src1 << (src2 & 0x1F));
  INSTPAT("0000000 ????? ????? 010 ????? 01100 11", slt    , RR, R(rd) = (sword_t)src1 < (sword_t)src2);
  INSTPAT("0000000 ????? ????? 011 ????? 01100 11", sltu   , RR, R(rd) = src1 < src2);
  INSTPAT("0000000 ????? ????? 100 ????? 01100 11", xor    , RR, R(rd) = src1 ^ src2);
  INSTPAT("0000000 ????? ????? 101 ????? 01100 11", srl    , RR, R(rd) = src1 >> (src2 & 0x1F));
  INSTPAT("0100000 ????? ????? 101 ????? 01100 11", sra    , RR, R(rd) = (sword_t)src1 >> (src2 & 0x1F));
  INSTPAT("0000000 ????? ????? 110 ????? 01100 11", or     , RR, R(rd) = src1 | src2);
  INSTPAT("0000000 ????? ????? 111 ????? 01100 11", and    , RR, R(rd) = src1 & src2);

  // I Type
  // algorithm
  INSTPAT("??????? ????? ????? 000 ????? 00100 11", addi   , I, R(rd) = src1 + imm);
  INSTPAT("??????? ????? ????? 010 ????? 00100 11", slti   , I, R(rd) = (sword_t)src1 < (sword_t)imm);
  INSTPAT("??????? ????? ????? 011 ????? 00100 11", sltiu  , I, R(rd) = src1 < imm);
  INSTPAT("??????? ????? ????? 100 ????? 00100 11", xori   , I, R(rd) = src1 ^ imm);
  INSTPAT("??????? ????? ????? 110 ????? 00100 11", ori    , I, R(rd) = src1 | imm);
  INSTPAT("??????? ????? ????? 111 ????? 00100 11", andi   , I, R(rd) = src1 & imm);
  INSTPAT("0000000 ????? ????? 001 ????? 00100 11", slli   , I, R(rd) = src1 << (imm & 0x1F));
  INSTPAT("0000000 ????? ????? 101 ????? 00100 11", srli   , I, R(rd) = src1 >> (imm & 0x1F));
  INSTPAT("0100000 ????? ????? 101 ????? 00100 11", srla   , I, R(rd) = (sword_t)src1 >> (imm & 0x1F));

  // I Type
  // load
  // 在c中， 有符号数在进行类型转换时，会进行符号扩展
  INSTPAT("??????? ????? ????? 000 ????? 00000 11", lb     , I, R(rd) = (int8_t)Mr(src1 + imm, 1));
  INSTPAT("??????? ????? ????? 001 ????? 00000 11", lh     , I, R(rd) = (int16_t)Mr(src1 + imm, 2));
  INSTPAT("??????? ????? ????? 010 ????? 00000 11", lw     , I, R(rd) = Mr(src1 + imm, 4));
  INSTPAT("??????? ????? ????? 100 ????? 00000 11", lbu    , I, R(rd) = Mr(src1 + imm, 1));
  INSTPAT("??????? ????? ????? 101 ????? 00000 11", lhu    , I, R(rd) = Mr(src1 + imm, 2));

  // S Type
  INSTPAT("??????? ????? ????? 000 ????? 01000 11", sb     , S, Mw(src1 + imm, 1, src2));
  INSTPAT("??????? ????? ????? 001 ????? 01000 11", sh     , S, Mw(src1 + imm, 2, src2));
  INSTPAT("??????? ????? ????? 010 ????? 01000 11", sw     , S, Mw(src1 + imm, 4, src2));


  // J Type
  INSTPAT("??????? ????? ????? ??? ????? 11011 11", jal    , J, R(rd) = s->pc + 4; s->dnpc = s->pc + imm;);
  INSTPAT("??????? ????? ????? 000 ????? 11001 11", jalr   , I, R(rd) = s->pc + 4; s->dnpc = src1 + imm);

  /*
  * RV32M
  */
  INSTPAT("0000001 ????? ????? 000 ????? 01100 11", mul    , RR, R(rd) = (sword_t)src1 * (sword_t)src2);
  INSTPAT("0000001 ????? ????? 001 ????? 01100 11", mulh   , RR, R(rd) = (word_t)(((int64_t)(sword_t)src1  * (int64_t)(sword_t)src2) >> 32));
  INSTPAT("0000001 ????? ????? 010 ????? 01100 11", mulhsu , RR, R(rd) = (word_t)(((int64_t)(sword_t)src1  * (uint64_t)src2) >> 32));
  INSTPAT("0000001 ????? ????? 011 ????? 01100 11", mulhu  , RR, R(rd) = (word_t)(((uint64_t)src1 * (uint64_t)src2) >> 32));
  INSTPAT("0000001 ????? ????? 100 ????? 01100 11", div    , RR, R(rd) = (sword_t)src1 / (sword_t)src2);
  INSTPAT("0000001 ????? ????? 101 ????? 01100 11", divu   , RR, R(rd) = src1 / src2);
  INSTPAT("0000001 ????? ????? 110 ????? 01100 11", rem    , RR, R(rd) = (sword_t)src1 % (sword_t)src2);
  INSTPAT("0000001 ????? ????? 111 ????? 01100 11", remu   , RR, R(rd) = src1 % src2);

  //---------- System Instruction ----------//
  //INSTPAT("0000000 00000 00000 000 00000 11100 11", mret   , N, INV(s->pc)); 
  INSTPAT("??????? ????? ????? 001 ????? 11100 11", csrrw  , I, R(rd) = csrrw(s->pc, imm, src1, s->isa.rs1 != 0));
  INSTPAT("??????? ????? ????? 010 ????? 11100 11", csrrs  , I, R(rd) = csrrs(imm, src1, s->isa.rs1 != 0));
  INSTPAT("??????? ????? ????? 011 ????? 11100 11", csrrc  , I, R(rd) = csrrc(imm, src1, s->isa.rs1 != 0));
  INSTPAT("0000000 00000 00000 000 00000 11100 11", ecall  , N, s->dnpc = csr_ecall(s->pc));
  INSTPAT("0011000 00010 00000 000 00000 11100 11", mret   , N, s->dnpc = csr_mret(s->pc));
  INSTPAT("0000000 00001 00000 000 00000 11100 11", ebreak , N, NEMUTRAP(s->pc, R(10)));
  INSTPAT("??????? ????? ????? ??? ????? ????? ??", inv    , N, INV(s->pc));

  INSTPAT_END();

  R(0) = 0; // reset $zero to 0

  return 0;
}

int isa_exec_once(Decode *s) {
  // instrcution fetch
  // update the snpc
  s->isa.inst.val = inst_fetch(&s->snpc, 4);
  return decode_exec(s);
}
