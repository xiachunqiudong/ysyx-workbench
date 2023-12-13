package liang_pkg;

  localparam int unsigned XLEN = 32;
  
  typedef logic [31:0] pc_t;
  typedef logic [31:0] inst_t;
  
  typedef enum logic[2:0] {
    IMM_NONE,
    IMM_I,
    IMM_S,
    IMM_B,
    IMM_U,
    IMM_J
  } imm_type_e;

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

  typedef enum logic [2:0] {
    LOAD_NONE,
    LOAD_LB,
    LOAD_LH,
    LOAD_LW,
    LOAD_LD,
    LOAD_LBU,
    LOAD_LHU,
    LOAD_LWU
  } load_type_e;

  typedef enum logic [2:0] {
    STORE_NONE,
    STORE_SB,
    STORE_SH,
    STORE_SW,
    STORE_SD
  } store_type_e;

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

  typedef struct packed {
    pc_t             pc;
    logic [4:0]      rs1;
    logic [4:0]      rs2;
    logic [4:0]      rd;
    logic            rd_wen;
    logic [XLEN-1:0] imm;
    fu_e             fu;
    fu_op_e          fu_op;
    fu_func_e        fu_func;
    load_type_e      load_type;
    store_type_e     store_type;
  } uop_info_t;

endpackage