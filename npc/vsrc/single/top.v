`include "defines.v"

module top(
  input clk_i,
  input rst_i,
  output [31:0] pc_o,
  input [31:0] instr_i
);

  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [`XLEN-1:0] rs1_rdata;
  wire [`XLEN-1:0] rs2_rdata;
  wire [`XLEN-1:0] imm;
	wire [`OP_WIDTH-1:0] op_info;
  wire ebreak;

  idu 
  idu_u(.instr(instr_i),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .rd_o(rd),
    .imm_o(imm),
		.op_info_o(op_info),
    .ebreak_o(ebreak)
  );

  regfile #(.ADDR_WIDTH(5), .DATA_WIDTH(`XLEN)) 
  regfile_u(
    .clk(clk_i),
    .rs1_raddr(rs1),
    .rs2_raddr(rs2),
    .rs1_rdata(rs1_rdata),
    .rs2_rdata(rs2_rdata),
    .waddr(rd),
    .wdata(exu_out),
    .wen(1'b1)
  );

  wire [`XLEN-1:0] exu_out;

  exu
  exu_u(
    .rs1_i(rs1_rdata),
    .rs2_i(rs2_rdata),
    .imm_i(imm),
    .pc_i(pc_r),
    .op_info_i(op_info),
    .result_o(exu_out),
    .jump_o()
  );
    
  // ebreak: stop the simulation
  import "DPI-C" function void env_ebreak();
  always @(*) begin
    if(ebreak) begin
    	env_ebreak();
		end
  end

  
  assign pc_o = pc_r;
  reg [`PC_WIDTH-1:0] pc_r;

	// next pc
	wire [`PC_WIDTH-1:0] pc_n;

	wire [`PC_WIDTH-1:0] npc_src1;
	wire [`PC_WIDTH-1:0] npc_src2;

	wire jal;
	wire jalr;
	assign jal  = op_info[`JAL];
	assign jalr = op_info[`JALR];

	wire jump;
	assign jump = jal || jalr;

	assign npc_src1 = jalr ? rs1_rdata : pc_r;
	assign npc_src2 = jump ? imm : 4;

	assign pc_n = npc_src1 + npc_src2;
	
  always @(posedge clk_i or posedge rst_i) begin
    if(rst_i)
      pc_r <= 32'h80000000;
    else
      pc_r <= pc_n;
  end

endmodule
