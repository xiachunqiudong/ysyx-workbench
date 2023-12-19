module idu import liang_pkg::*;
(
    input  pc_t           pc_i,
    input  inst_t         inst_i,
    output uop_info_t     uop_info_o
);

  fu_e         fu;
  fu_op_e      fu_op;
  fu_func_e    fu_func;
  load_type_e  load_type;
  store_type_e store_type;
  logic        ebreak;
  logic        ecall;
  logic        rd_wen;
  
  assign uop_info_o = '{
                        pc:      pc_i,
                        rs1:     rs1,
                        rs2:     rs2,
                        rd:      rd, 
                        imm:     imm, 
                        rd_wen:  rd_wen,
                        fu:      fu,
                        fu_op:   fu_op, 
                        fu_func: fu_func,
                        load_type:  load_type,
                        store_type: store_type,
                        ebreak:     ebreak,
                        ecall:      ecall
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

  logic [6:0] fun7;
  logic [2:0] fun3;
  logic [6:0] opcode;

  assign rs1    = inst_i[19:15];
  assign rs2    = inst_i[24:20];
  assign rd     = inst_i[11:7];
  assign fun7   = inst_i[31:25];
  assign fun3   = inst_i[14:12];
  assign opcode = inst_i[6:0];

	assign rd_wen = !(fu_op inside {BRANCH, STORE}) && (rd != 5'b0);
  assign ebreak = inst_i[31:20] == 12'b1 && inst_i[19:7] == 13'b0 && opcode == 7'b11100_11;

  always_comb begin
    fu_op   = OP_NONE;
    fu_func = FUNC_NONE;
    load_type  = LOAD_NONE;
    store_type = STORE_NONE;
    case(opcode)
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
          3'b000: load_type = LOAD_LB;
          3'b001: load_type = LOAD_LH;
          3'b010: load_type = LOAD_LW;
          3'b100: load_type = LOAD_LBU;
          3'b101: load_type = LOAD_LHU;
          default:load_type = LOAD_NONE;
        endcase
      end
      // STORE
      7'b01000_11: begin
        fu_op = STORE;
        case(fun3)
          3'b000: store_type = STORE_SB;
          3'b001: store_type = STORE_SH;
          3'b010: store_type = STORE_SW;
          default:store_type = STORE_NONE;
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
        fu_op      = OP_NONE;
        fu_func    = FUNC_NONE;
        load_type  = LOAD_NONE;
        store_type = STORE_NONE;
      end
    endcase
  end


  //*************************//
  //       Get Imm           //
  //*************************//
  // logic [4:0]      imm_type;
  
	// assign imm_type[`TYPE_I] = alu_i || jalr || load;
	// assign imm_type[`TYPE_S] = store;
	// assign imm_type[`TYPE_B] = branch;
	// assign imm_type[`TYPE_U] = lui || auipc;
	// assign imm_type[`TYPE_J] = jal;
	
  imm_type_e imm_type;
  logic [XLEN-1:0] imm;

  always_comb begin
    imm_type   = IMM_NONE;
    if (fu_op inside {ALI, ALR, LOAD})
      imm_type = IMM_I;
    else if(fu_op == STORE)
     imm_type  = IMM_S;
    else if(fu_op == BRANCH)
      imm_type = IMM_B;
    else if(fu_op inside {LUI, AUIPC})
      imm_type = IMM_U;
    else if(fu_op == JAL)
      imm_type = IMM_J;
  end
  
	logic [XLEN-1:0] imm_I;
  logic [XLEN-1:0] imm_S;
  logic [XLEN-1:0] imm_B;
  logic [XLEN-1:0] imm_U;
  logic [XLEN-1:0] imm_J;
  
	// 所有立即数都是符号扩展
  assign imm_I = {{XLEN-12{inst_i[31]}}, inst_i[31:20]};
  assign imm_S = {{XLEN-12{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
  assign imm_B = {{XLEN-13{inst_i[31]}}, inst_i[31],    inst_i[7],     inst_i[30:25], inst_i[11:8], 1'b0};
	assign imm_U = {{XLEN-32{inst_i[31]}}, inst_i[31:12], 12'b0 };
  assign imm_J = {{XLEN-21{inst_i[31]}}, inst_i[31],    inst_i[19:12], inst_i[20],    inst_i[30:21], 1'b0};

  // imm MUX
	// NR_KEY: 键值对的数量 KEY_LEN: 键值的位宽
  MuxKey #(.NR_KEY(6), .KEY_LEN(3), .DATA_LEN(XLEN))
  imm_mux(
    .out(imm),
    .key(imm_type),
    .lut({
      IMM_NONE, {XLEN{1'b0}},
      IMM_I,     imm_I,
      IMM_S,     imm_S,
      IMM_B,     imm_B,
      IMM_U,     imm_U,
      IMM_J,     imm_J
    })
  );

endmodule