module pipe_ifu import liang_pkg::*;
(
  input clk_i,
  input rst_i,
  output ifToId,
  output if_valid,
  input  id_ready
);

  pc_t pc_r;
	
  // next pc
	pc_t npc_src1;
	pc_t npc_src2;

	wire jal;
	wire jalr;
	assign jal  = uop_info.fu_op == JAL;
	assign jalr = uop_info.fu_op == JALR;

  logic taken;
	assign taken = jal || jalr || jump;

	assign npc_src1 = jalr  ? rs1_rdata    : pc_r;
	assign npc_src2 = taken ? uop_info.imm : 4;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)
      pc_r <= 32'h80000000;
    else
      pc_r <= npc_src1 + npc_src2;
  end

endmodule