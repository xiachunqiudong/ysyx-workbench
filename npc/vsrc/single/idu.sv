`include "defines.v"

module idu import liang_pkg::*;
(
    input  inst_t         inst_i,
    output id_info_t      id_info_o,
    // op info
		output [`OP_WIDTH-1:0]      op_info_o,
    output [`BR_FUN_WIDTH-1:0]  br_fun_o,
    output [`LD_FUN_WIDTH-1:0]  ld_fun_o,
    output [`ST_FUN_WIDTH-1:0]  st_fun_o,
    output [`ALU_FUN_WIDTH-1:0] alu_fun_o,
    output ebreak_o // exception
);
  fu_e      fu;
  fu_op_e   fu_op;
  fu_func_e fu_func;
  
  assign id_info_o = '{rs1:     rs1,
                       rs2:     rs2,
                       rd:      rd, 
                       imm:     imm, 
                       rd_wen:  rd_wen,
                       fu:      fu,
                       fu_op:   fu_op, 
                       fu_func: fu_func
                       };

  always_comb begin
    fu = FU_NONE;
    if(fu_op inside {LOAD, STORE})
      fu = FU_LSU;
    else if(fu_op inside {ALI, ALR})
      fu = FU_ALU;
  end

  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [4:0] rd;
  logic       rd_wen;
  logic [6:0] fun7;
  logic [2:0] fun3;
  logic [6:0] opcode;

  assign rs1    = inst_i[19:15];
  assign rs2    = inst_i[24:20];
  assign rd     = inst_i[11:7];
  assign fun7   = inst_i[31:25];
  assign fun3   = inst_i[14:12];
  assign opcode = inst_i[6:0];

  logic lui;
  logic auipc;
  logic jal;
  logic jalr;
  logic branch;
  logic load;
  logic store;
  logic alu_i;
  logic alu_r;

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

	assign rd_wen = !branch && !store && (rd != 5'b0);

  assign ebreak_o = inst_i[31:20] == 12'b1 && inst_i[19:7] == 13'b0 && opcode == 7'b11100_11;

	assign op_info_o[`LUI]    = lui;
	assign op_info_o[`AUIPC]  = auipc;
	assign op_info_o[`JAL] 	  = jal;
	assign op_info_o[`JALR]   = jalr;
	assign op_info_o[`BRANCH] = branch;
	assign op_info_o[`LOAD]   = load;
	assign op_info_o[`STORE]  = store;
	assign op_info_o[`ALU_I]  = alu_i;
	assign op_info_o[`ALU_R]  = alu_r;

  // branch function
  assign br_fun_o[`BEQ]  = branch && fun3 == 3'b000;
  assign br_fun_o[`BNE]  = branch && fun3 == 3'b001;
  assign br_fun_o[`BLT]  = branch && fun3 == 3'b100;
  assign br_fun_o[`BGE]  = branch && fun3 == 3'b101;
  assign br_fun_o[`BLTU] = branch && fun3 == 3'b110;
  assign br_fun_o[`BGEU] = branch && fun3 == 3'b111;
	// load function
  assign ld_fun_o[`LB]  = load && fun3 == 3'b000;
  assign ld_fun_o[`LH]  = load && fun3 == 3'b001;
  assign ld_fun_o[`LW]  = load && fun3 == 3'b010;
  assign ld_fun_o[`LBU] = load && fun3 == 3'b100;
  assign ld_fun_o[`LHU] = load && fun3 == 3'b101;
  // store function
  assign st_fun_o[`SB] = store && fun3 == 3'b000; 
  assign st_fun_o[`SH] = store && fun3 == 3'b001; 
  assign st_fun_o[`SW] = store && fun3 == 3'b010; 
  // alu function
  assign alu_fun_o[`ADD]  = fun3 == 3'b000 && (alu_i || (alu_r && fun7 == 7'b000_0000));
  assign alu_fun_o[`SUB]  = fun3 == 3'b000 && (alu_r && fun7 == 7'b010_0000);
  assign alu_fun_o[`SLL]  = fun3 == 3'b001 && fun7 == 7'b000_0000 && (alu_i || alu_r);
  assign alu_fun_o[`SLT]  = fun3 == 3'b010 && (alu_i || (alu_r && fun7 == 7'b000_0000));
  assign alu_fun_o[`SLTU] = fun3 == 3'b011 && (alu_i || (alu_r && fun7 == 7'b000_0000));
  assign alu_fun_o[`XOR]  = fun3 == 3'b100 && (alu_i || (alu_r && fun7 == 7'b000_0000));
  assign alu_fun_o[`SRL]  = fun3 == 3'b101 && fun7 == 7'b000_0000 && (alu_i || alu_r);
  assign alu_fun_o[`SRA]  = fun3 == 3'b101 && fun7 == 7'b010_0000 && (alu_i || alu_r);
  assign alu_fun_o[`OR]   = fun3 == 3'b110 && (alu_i || (alu_r && fun7 == 7'b000_0000));
  assign alu_fun_o[`AND]  = fun3 == 3'b111 && (alu_i || (alu_r && fun7 == 7'b000_0000));

  assign lui    = opcode == 7'b01101_11;
  assign auipc  = opcode == 7'b00101_11;
  assign jal    = opcode == 7'b11011_11;
  assign jalr   = opcode == 7'b11001_11;
  assign branch = opcode == 7'b11000_11;
  assign load   = opcode == 7'b00000_11;
  assign store  = opcode == 7'b01000_11;
  assign alu_i  = opcode == 7'b00100_11;
  assign alu_r  = opcode == 7'b01100_11;


  always_comb begin
    fu_func = FUNC_NONE;
    fu_op   = OP_NONE;
    case(fun7)
      7'b01101_11: fu_op = LUI;
      7'b00101_11: fu_op = AUIPC;
      7'b11011_11: fu_op = JAL;
      7'b11001_11: fu_op = JALR;
      // BRANCH
      7'b11000_11: begin
        fu_op = BRANCH;
        case(fun3)
          3'b000: fu_func = BEQ;
          3'b001: fu_func = BNE;
          3'b100: fu_func = BLT;
          3'b101: fu_func = BGE;
          3'b110: fu_func = BLTU;
          3'b111: fu_func = BGEU;
          default: fu_func = FUNC_NONE;
        endcase
      end
      // LOAD
      7'b00000_11: begin
        fu_op = LOAD;
        case(fun3)
          3'b000: fu_func = LB;
          3'b001: fu_func = LH;
          3'b010: fu_func = LW;
          3'b100: fu_func = LBU;
          3'b101: fu_func = LHU;
          default: fu_func = FUNC_NONE;
        endcase
      end
      // STORE
      7'b01000_11: begin
        fu_op = STORE;
        case(fun3)
          3'b000: fu_func = SB;
          3'b001: fu_func = SH;
          3'b010: fu_func = SW;
          default: fu_func = FUNC_NONE;
        endcase
      end
      // ALU-I
      7'b00100_11: begin
        fu_op = ALI;
        case(fun3)
          3'b000: fu_func = ADDI;
          3'b001: fu_func = SLLI;
          3'b010: fu_func = SLTI;
          3'b011: fu_func = SLTUI;
          3'b100: fu_func = XORI;
          // SRL or SRA
          3'b101: begin
            if (fun7 == 7'b000_0000) begin
              fu_func = SRLI;
            end
            else if (fun7 == 7'b010_0000) begin
              fu_func = SRAI;
            end
          end
          3'b110: fu_func = ORI;
          3'b111: fu_func = ANDI;
          default: fu_func = FUNC_NONE;
        endcase
      end
      // ALU-R
      7'b01100_11: begin
        fu_op = ALR;
        case(fun3)
          3'b000: begin
            if (fun7 == 7'b000_0000) begin
              fu_func = ADD;
            end
            else if (fun7 == 7'b010_0000) begin
              fu_func = SUB;
            end
          end
          3'b001: fu_func = SLL;
          3'b010: fu_func = SLT;
          3'b011: fu_func = SLTU;
          3'b100: fu_func = XOR;
          // SRL or SRA
          3'b101: begin
            if (fun7 == 7'b000_0000) begin
              fu_func = SRL;
            end
            else if (fun7 == 7'b010_0000) begin
              fu_func = SRA;
            end
          end
          3'b110: fu_func = OR;
          3'b111: fu_func = AND;
          default: fu_func = FUNC_NONE;
        endcase
      end
      default: begin 
        fu_op   = OP_NONE;
        fu_func = FUNC_NONE;
      end
    endcase
  end


  //*************************//
  //       Get Imm           //
  //*************************//
  logic [4:0]      imm_type;
  logic [XLEN-1:0] imm;
	assign imm_type[`TYPE_I] = alu_i || jalr || load;
	assign imm_type[`TYPE_S] = store;
	assign imm_type[`TYPE_B] = branch;
	assign imm_type[`TYPE_U] = lui || auipc;
	assign imm_type[`TYPE_J] = jal;
	
	logic [`XLEN-1:0] imm_I;
  logic [`XLEN-1:0] imm_S;
  logic [`XLEN-1:0] imm_B;
  logic [`XLEN-1:0] imm_U;
  logic [`XLEN-1:0] imm_J;
  
	// 所有立即数都是符号扩展
  assign imm_I = {{`XLEN-12{inst_i[31]}}, inst_i[31:20]};
  assign imm_S = {{`XLEN-12{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
  assign imm_B = {{`XLEN-13{inst_i[31]}}, inst_i[31],    inst_i[7],     inst_i[30:25], inst_i[11:8], 1'b0};
	assign imm_U = {{`XLEN-32{inst_i[31]}}, inst_i[31:12], 12'b0 };
  assign imm_J = {{`XLEN-21{inst_i[31]}}, inst_i[31],    inst_i[19:12], inst_i[20],    inst_i[30:21], 1'b0};

  // imm MUX
	// NR_KEY: 键值对的数量 KEY_LEN: 键值的位宽
  MuxKey #(.NR_KEY(5), .KEY_LEN(5), .DATA_LEN(`XLEN))
  imm_mux(
    .out(imm),
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