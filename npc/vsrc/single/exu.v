`include "defines.v"

module exu(
  // op number
  input [`XLEN-1:0] rs1_i,
  input [`XLEN-1:0] rs2_i,
  input [`XLEN-1:0] imm_i,
  input [`XLEN-1:0] pc_i,
  // op info
  input [`OP_WIDTH-1:0] op_info_i,
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

  assign lui    = op_info_i[`LUI];
  assign auipc  = op_info_i[`AUIPC];
  assign jal    = op_info_i[`JAL];
  assign jalr   = op_info_i[`JALR];
  assign branch = op_info_i[`BRANCH];
  assign load   = op_info_i[`LOAD];
  assign store  = op_info_i[`STORE];
  assign alu_i  = op_info_i[`ALU_I];
  assign alu_r  = op_info_i[`ALU_R];

	wire [`XLEN-1:0] src1;
	wire [`XLEN-1:0] src2;

	assign src1 = (auipc || jal || jalr) ? pc_i 
              : lui ? 0
              : rs1_i;
	
	assign src2 = (alu_r || branch) ? rs2_i
              : (jal || jalr) ? 4
              : imm_i;

	wire [`XLEN-1:0] add_res;
	wire [`XLEN-1:0] sub_res;
	wire [`XLEN-1:0] and_res;
	wire [`XLEN-1:0] or_res;
	wire [`XLEN-1:0] xor_res;

	assign add_res = src1 + src2;
	assign sub_res = src1 - src2;


	assign result_o = add_res;

endmodule