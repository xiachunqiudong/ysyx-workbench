`include "defines.v"

module idu(
    input [31:0] instr,
    // op number
    output [4:0] rs1_o,
    output [4:0] rs2_o,
    output [4:0] rd_o,
    output [`XLEN-1:0] imm_o,
    // op info
		output [`OP_WIDTH-1:0] op_info_o,
    output [`BR_FUN_WIDTH-1:0] br_fun_o,
    output [`LD_FUN_WIDTH-1:0] ld_fun_o,
    output [`ST_FUN_WIDTH-1:0] st_fun_o,
    output ebreak_o // exception
);
	
  // get op number
  assign rs1_o = instr[19:15];
  assign rs2_o = instr[24:20];
  assign rd_o  = instr[11:7];

  wire [6:0] fun7;
  wire [2:0] fun3;
  wire [6:0] opcode;

  assign fun7   = instr[31:25];
  assign fun3   = instr[14:12];
  assign opcode = instr[6:0];

  wire lui;
  wire auipc;
  wire jal;
  wire jalr;
  wire branch;
  wire load;
  wire store;
  wire alu_i;
  wire alu_r;

	// get op info
  assign lui    = opcode == 7'b01101_11;
  assign auipc  = opcode == 7'b00101_11;
  assign jal    = opcode == 7'b11011_11;
  assign jalr   = opcode == 7'b11001_11;
  assign branch = opcode == 7'b11000_11;
  assign load   = opcode == 7'b00000_11;
  assign store  = opcode == 7'b01000_11;
  assign alu_i  = opcode == 7'b00100_11;
  assign alu_r  = opcode == 7'b01100_11;

  assign ebreak_o = instr[31:20] == 12'b1 && instr[19:7] == 13'b0 && opcode == 7'b11100_11;

	assign op_info_o[`LUI]    = lui;
	assign op_info_o[`AUIPC]  = auipc;
	assign op_info_o[`JAL] 	  = jal;
	assign op_info_o[`JALR]   = jalr;
	assign op_info_o[`BRANCH] = branch;
	assign op_info_o[`LOAD]   = load;
	assign op_info_o[`STORE]  = store;
	assign op_info_o[`ALU_I]  = alu_i;
	assign op_info_o[`ALU_R]  = alu_r;

  // branch
  assign br_fun_o[`BEQ]  = branch && fun3 == 3'b000;
  assign br_fun_o[`BNE]  = branch && fun3 == 3'b001;
  assign br_fun_o[`BLT]  = branch && fun3 == 3'b100;
  assign br_fun_o[`BGE]  = branch && fun3 == 3'b101;
  assign br_fun_o[`BLTU] = branch && fun3 == 3'b110;
  assign br_fun_o[`BGEU] = branch && fun3 == 3'b111;
  
	// load
  assign ld_fun_o[`LB]  = load && fun3 == 3'b000;
  assign ld_fun_o[`LH]  = load && fun3 == 3'b001;
  assign ld_fun_o[`LW]  = load && fun3 == 3'b010;
  assign ld_fun_o[`LBU] = load && fun3 == 3'b100;
  assign ld_fun_o[`LHU] = load && fun3 == 3'b101;

  // store
  assign st_fun_o[`SB] = store && fun3 == 3'b000; 
  assign st_fun_o[`SH] = store && fun3 == 3'b001; 
  assign st_fun_o[`SW] = store && fun3 == 3'b010; 


  //*************************//
  //       Get Imm           //
  //*************************//
  wire [4:0] imm_type;
	assign imm_type[`TYPE_I] = alu_i || jalr || load;
	assign imm_type[`TYPE_S] = store;
	assign imm_type[`TYPE_B] = branch;
	assign imm_type[`TYPE_U] = lui || auipc;
	assign imm_type[`TYPE_J] = jal;
	
	wire [`XLEN-1:0] imm_I;
  wire [`XLEN-1:0] imm_S;
  wire [`XLEN-1:0] imm_B;
  wire [`XLEN-1:0] imm_U;
  wire [`XLEN-1:0] imm_J;
  
	// 所有立即数都是符号扩展
  assign imm_I = {{`XLEN-12{instr[31]}}, instr[31:20]};
  assign imm_S = {{`XLEN-12{instr[31]}}, instr[31:25], instr[11:7]};
  assign imm_B = {{`XLEN-13{instr[31]}}, instr[31],    instr[7],     instr[30:25], instr[11:8], 1'b0};
	assign imm_U = {{`XLEN-32{instr[31]}}, instr[31:12], 12'b0 };
  assign imm_J = {{`XLEN-21{instr[31]}}, instr[31],    instr[19:12], instr[20],    instr[30:21], 1'b0};

  // imm MUX
	// NR_KEY: 键值对的数量 KEY_LEN: 键值的位宽
  MuxKey #(.NR_KEY(5), .KEY_LEN(5), .DATA_LEN(`XLEN))
  imm_mux(
      .out(imm_o),
      .key(imm_type),
      .lut({
        5'b00001, imm_I,
        5'b00010, imm_S,
        5'b00100, imm_B,
        5'b01000, imm_U,
        5'b10000, imm_J
      })
  );

endmodule