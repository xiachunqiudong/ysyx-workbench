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

  wire [`XLEN-1:0] adder_cin;
  wire [`XLEN-1:0] adder_src1;
  wire [`XLEN-1:0] adder_src2;
  assign adder_cin = {{`XLEN-1{1'b0}}, alu_sub};
  assign adder_src1 = src1;
  assign adder_src2 = {`XLEN{alu_sub}} ^ src2;
      
	wire [`XLEN-1:0] add_sub_res;
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
	assign {adder_cout, add_sub_res} = adder_src1 + adder_src2 + adder_cin;
  assign sll_res = src1 << src2[4:0];
  assign slt_res  = {{`XLEN-1{1'b0}}, lt};
  assign sltu_res = {{`XLEN-1{1'b0}}, ltu};
  assign xor_res = src1 ^ src2;
  assign srl_res = src1 >> src2[4:0];
  assign sra_res = $signed(src1) >>> src2[4:0];
  assign or_res  = src1 | src2;
  assign and_res = src1 & src2;

  wire [`ALU_FUN_WIDTH-2:0] res_sel_key;
  wire add_sub_res_sel;

  assign add_sub_res_sel = alu_add | alu_sub | load | store | jal | jalr | lui | auipc;
  assign res_sel_key = {alu_fun_i[9:2], add_sub_res_sel};
  
  MuxKey #(.NR_KEY(`ALU_FUN_WIDTH-1), .KEY_LEN(`ALU_FUN_WIDTH-1), .DATA_LEN(`XLEN))
  imm_mux(
    .out(result_o),
    .key(res_sel_key),
    .lut({
      9'b0_0000_0001, add_sub_res,
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

  // BRANCH
  assign eq = ~ne;
  assign ne =  (|xor_res);
  
  // 通过分析 A - B 来比较 A 和 B 的大小，假设 A 和 B 都是有符号数
  // 如果无溢出那么结果符号为1则 A < B, 如果发生溢出那么符号为0则 A < B
  // A < B = of & ~res[XLEN-1] | ~of & res[XLEN-1]
  // A 与 B 符号不同, A负 B正
  // A 与 B 符号相同, 看加法器结果 [必定不能溢出]
  assign lt  = ( src1[`XLEN-1] & ~src2[`XLEN-1]) |
               (~(src1[`XLEN-1] ^ src2[`XLEN-1]) & add_sub_res[`XLEN-1]);
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