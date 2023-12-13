`define XLEN 32
`define PC_WIDTH 32

// OP INFO
`define OP_WIDTH 10
`define LUI    0
`define AUIPC  2
`define JAL    3
`define JALR   4
`define BRANCH 5
`define LOAD   6
`define STORE  7
`define ALU_I  8
`define ALU_R  9
// BRANCH
`define BR_FUN_WIDTH 6
`define BEQ  0
`define BNE  1
`define BLT  2
`define BGE  3
`define BLTU 4
`define BGEU 5
// LOAD FUN
`define LD_FUN_WIDTH 5
`define LB  0
`define LH  1
`define LW  2
`define LBU 3
`define LHU 4
// STORE FUN
`define ST_FUN_WIDTH 3
`define SB 0
`define SH 1
`define SW 2
// ALU FUN
`define ALU_FUN_WIDTH 10
`define ADD  0
`define SUB  1
`define SLL  2
`define SLT  3
`define SLTU 4 
`define XOR  5
`define SRL  6
`define SRA  7
`define OR   8
`define AND  9


