`include "defines.v"

module exu(
  // op number
  input [`XLEN-1:0] rs1_i,
  input [`XLEN-1:0] rs2_i,
  input [`XLEN-1:0] imm_i,
  input [`XLEN-1:0] pc_i,
  // op info
  input [`OP_WIDTH-1:0]      op_info_i,
  input [`BR_FUN_WIDTH-1:0]  br_fun_i,
  input [`ALU_FUN_WIDTH-1:0] alu_fun_i,
  output [`XLEN-1:0] result_o,
  // get the branch result
  output jump_o
);

  // op info
  wire lui;
  wire auipc;
  wire jal;
  wire jalr;
  wire branch;
  wire load;
  wire store;
  wire alu_i;
  wire alu_r;
  // branch fun
  wire beq;
  wire bne;
  wire blt;
  wire bge;
  wire bltu;
  wire bgeu;
  // alu fun
  wire alu_add;
  wire alu_sub;
  wire alu_sll;
  wire alu_slt;
  wire alu_sltu;
  wire alu_xor;
  wire alu_srl;
  wire alu_sra;
  wire alu_or;
  wire alu_and;

  assign lui    = op_info_i[`LUI];
  assign auipc  = op_info_i[`AUIPC];
  assign jal    = op_info_i[`JAL];
  assign jalr   = op_info_i[`JALR];
  assign branch = op_info_i[`BRANCH];
  assign load   = op_info_i[`LOAD];
  assign store  = op_info_i[`STORE];
  assign alu_i  = op_info_i[`ALU_I];
  assign alu_r  = op_info_i[`ALU_R];

  assign beq  = br_fun_i[`BEQ];
  assign bne  = br_fun_i[`BNE];
  assign blt  = br_fun_i[`BLT];
  assign bge  = br_fun_i[`BGE];
  assign bltu = br_fun_i[`BLTU];
  assign bgeu = br_fun_i[`BGEU];

  assign alu_add  = alu_fun_i[`ADD];
  assign alu_sub  = alu_fun_i[`SUB];
  assign alu_sll  = alu_fun_i[`SLL];
  assign alu_slt  = alu_fun_i[`SLT];
  assign alu_sltu = alu_fun_i[`SLTU];
  assign alu_xor  = alu_fun_i[`XOR];
  assign alu_srl  = alu_fun_i[`SRL];
  assign alu_sra  = alu_fun_i[`SRA];
  assign alu_or   = alu_fun_i[`OR];
  assign alu_and  = alu_fun_i[`AND];


	wire [`XLEN-1:0] src1;
	wire [`XLEN-1:0] src2;

	assign src1 = (auipc || jal || jalr) ? pc_i 
              : lui ? 0
              : rs1_i;
	
	assign src2 = (alu_r || branch) ? rs2_i
              : (jal || jalr) ? 4
              : imm_i;

  wire adder_sub;
  wire [`XLEN-1:0] adder_src1;
  wire [`XLEN-1:0] adder_src2;      
	wire [`XLEN-1:0] adder_res;
  wire             adder_cout;
	wire [`XLEN-1:0] sll_res;
	wire [`XLEN-1:0] slt_res;
	wire [`XLEN-1:0] sltu_res;
	wire [`XLEN-1:0] xor_res;
	wire [`XLEN-1:0] srl_res;
	wire [`XLEN-1:0] sra_res;
	wire [`XLEN-1:0] or_res;
	wire [`XLEN-1:0] and_res;

  wire eq;
  wire ne;
  wire lt;  
  wire ge;
  wire ltu;
  wire geu;

//------------adder------------
  assign adder_sub  = alu_sub | alu_slt | alu_sltu | branch;
  assign adder_src1 = src1;
  assign adder_src2 = {`XLEN{adder_sub}} ^ src2;
	assign {adder_cout, adder_res} = adder_src1 + adder_src2 + { {`XLEN-1{1'b0}}, adder_sub };
  assign sll_res = src1 << src2[4:0];
  assign slt_res  = {{`XLEN-1{1'b0}}, lt};
  assign sltu_res = {{`XLEN-1{1'b0}}, ltu};
  assign xor_res = src1 ^ src2;
  assign srl_res = src1 >> src2[4:0];
  assign sra_res = $signed(src1) >>> src2[4:0];
  assign or_res  = src1 | src2;
  assign and_res = src1 & src2;

//----------------res sel-----------------
  wire [`ALU_FUN_WIDTH-2:0] res_sel_key;
  wire adder_res_sel;
  assign adder_res_sel = alu_add | alu_sub | load | store | jal | jalr | lui | auipc;
  assign res_sel_key = {alu_fun_i[9:2], adder_res_sel};
  
  MuxKey #(.NR_KEY(`ALU_FUN_WIDTH-1), .KEY_LEN(`ALU_FUN_WIDTH-1), .DATA_LEN(`XLEN))
  imm_mux(
    .out(result_o),
    .key(res_sel_key),
    .lut({
      9'b0_0000_0001, adder_res,
      9'b0_0000_0010, sll_res,
      9'b0_0000_0100, slt_res,
      9'b0_0000_1000, sltu_res,
      9'b0_0001_0000, xor_res,
      9'b0_0010_0000, srl_res,
      9'b0_0100_0000, sra_res,
      9'b0_1000_0000, or_res,
      9'b1_0000_0000, and_res
    })
  );

//---------------branch--------------------
  assign ne  =  (|xor_res);
  assign eq  = ~ne;
  assign lt  = (src1[`XLEN-1] & ~src2[`XLEN-1]) | (~(src1[`XLEN-1] ^ src2[`XLEN-1]) & adder_res[`XLEN-1]);
  assign ge  = ~lt | eq;
  assign ltu = ~adder_cout;
  assign geu = adder_cout | eq;

  assign jump_o = (beq  & eq)  |
                  (bne  & ne)  |
                  (blt  & lt)  |
                  (bge  & ge)  |
                  (bltu & ltu) |
                  (bgeu & geu);

endmodule