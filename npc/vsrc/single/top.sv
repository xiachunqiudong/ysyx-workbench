`include "defines.v"

module top import liang_pkg::*;
(
  input clk_i,
  input rst_i // reset signal
);

  // record the last pc and instruction
  import "DPI-C" function void get_pc_inst (input int pc_d1, input int inst_d1, input int pc, input int inst);
  
  reg [`XLEN-1:0] pc_last;
  reg [31:0] inst_last;

  always @(posedge clk_i) begin
    pc_last <= pc_r;
    inst_last <= inst;
  end

  always @(*) begin
    get_pc_inst(pc_last, inst_last, pc_r, inst);
  end

  inst_t inst;
  pc_t   pc;
  // Instrucion Decode
  uop_info_t uop_info;
  // Execution
  logic [XLEN-1:0] rs1_rdata;
  logic [XLEN-1:0] rs2_rdata;

  assign pc = pc_r;
  
  wire ebreak;
  wire jump;
  wire [`XLEN-1:0] exu_out;
  wire [`XLEN-1:0] mem_rdata;
  wire [`XLEN-1:0] rd_wdata;

  ifu
  ifu_u(
    .pc_i  (pc),
    .inst_o(inst)
  );

  idu 
  idu_u(
    .pc_i       (pc_r),
    .inst_i     (inst),
    .uop_info_o (uop_info),
    .ebreak_o   (ebreak)
  );

  wire [`XLEN-1:0] rf_a0;

  regfile #(.ADDR_WIDTH(5), .DATA_WIDTH(XLEN)) 
  regfile_u(
    .clk       (clk_i),
    .rs1_raddr (uop_info.rs1),
    .rs2_raddr (uop_info.rs2),
    .rs1_rdata (rs1_rdata),
    .rs2_rdata (rs2_rdata),
    .waddr     (uop_info.rd),
    .wdata     (rd_wdata),
    .wen       (uop_info.rd_wen),
    .a0        (rf_a0)
  );

  alu
  alu_u(
    .rs1_i      (rs1_rdata),
    .rs2_i      (rs2_rdata),
    .uop_info_i (uop_info),
    .alu_res_o  (exu_out),
    .jump_o     (jump)
  );
    
  mem
  mem_u(
    .uop_info_i (uop_info),
    .addr_i     (exu_out),
    .wdata_i    (rs2_rdata),
    .rdata_o    (mem_rdata)
  );

  wb
  wb_u(
    .uop_info_i (uop_info),
    .mem_rdata_i(mem_rdata),
    .exu_out_i  (exu_out),
    .rd_wdata_o (rd_wdata)
  );

  // ebreak: stop the simulation
  import "DPI-C" function void env_ebreak(input int pc, input int a0);
  always @(*) begin
    if(ebreak) begin
    	env_ebreak(pc_r, rf_a0);
		end
  end

  reg [`PC_WIDTH-1:0] pc_r;
	
  // next pc
	wire [`PC_WIDTH-1:0] pc_n;

	wire [`PC_WIDTH-1:0] npc_src1;
	wire [`PC_WIDTH-1:0] npc_src2;

	wire jal;
	wire jalr;
	assign jal  = uop_info.fu_op == JAL;
	assign jalr = uop_info.fu_op == JALR;

  wire taken;
	assign taken = jal || jalr || jump;

	assign npc_src1 = jalr ?  rs1_rdata   : pc_r;
	assign npc_src2 = taken ? uop_info.imm : 4;

	assign pc_n = npc_src1 + npc_src2;
	
  always @(posedge clk_i or posedge rst_i) begin
    if(rst_i)
      pc_r <= 32'h80000000;
    else
      pc_r <= pc_n;
  end

endmodule
