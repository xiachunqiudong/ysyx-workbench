package liang_pkg;

  localparam int unsigned XLEN = 32;

  typedef enum logic [3:0] {
    OP_NONE,
    ALR, 
    ALI,
    BRANCH,
    LOAD, 
    STORE, 
    JAL, 
    JALR,
    AUIPC, 
    LUI
  } fu_op_e;

  typedef enum logic [7:0] {
    FUNC_NONE,
    // Arithmetic and logic instrucions
    ADD,  SUB, SLL,  SLT,  SLTU,  XOR,  SRL,  SRA,  OR,  AND,
    ADDI,      SLLI, SLTI, SLTUI, XORI, SRLI, SRAI, ORI, ANDI,
    // Branch
    BEQ, BNE, BLT, BGE, BLTU, BGEU,
    // Load
    LB, LH, LW, LBU, LHU,
    // Store
    SB, SH, SW
  } fu_func_e;

  typedef enum logic [1:0] {
    FU_NONE,
    FU_ALU,
    FU_LSU,
    FU_MFPU
  } fu_e;

  typedef logic [31:0] pc_t;
  typedef logic [31:0] inst_t;

  typedef struct packed {
    logic [4:0]      rs1;
    logic [4:0]      rs2;
    logic [4:0]      rd;
    logic            rd_wen;
    logic [XLEN-1:0] imm;
    fu_e             fu;
    fu_op_e          fu_op;
    fu_func_e        fu_func;
  } id_info_t;


endpackage