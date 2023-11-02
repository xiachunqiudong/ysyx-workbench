`include "defines.v"

module top(
  input clk_i,
  input rst_i // reset signal
);

  // record the last pc and instruction
  import "DPI-C" function void get_pc_inst (input int pc, input int inst);
  
  reg [`XLEN-1:0] pc_last;
  reg [31:0] inst_last;

  always @(posedge clk_i) begin
    pc_last <= pc_r;
    inst_last <= inst;
  end

  always @(*) begin
    get_pc_inst(pc_last, inst_last);
  end

  wire [31:0] inst;

  // data path
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [`XLEN-1:0] rs1_rdata;
  wire [`XLEN-1:0] rs2_rdata;
  wire [`XLEN-1:0] imm;
  // control path
  wire rd_wen;  
  wire [`OP_WIDTH-1:0]      op_info;
  wire [`BR_FUN_WIDTH-1:0]  br_fun;
  wire [`LD_FUN_WIDTH-1:0]  ld_fun;
  wire [`ST_FUN_WIDTH-1:0]  st_fun;
  wire [`ALU_FUN_WIDTH-1:0] alu_fun;
  wire ebreak;

  wire [`XLEN-1:0] exu_out;
  wire [`XLEN-1:0] mem_rdata;
  wire [`XLEN-1:0] rd_wdata;

 

  ifu
  ifu_u(
    .pc_i(pc_r),
    .inst_o(inst)
  );

  idu 
  idu_u(
    .instr(inst),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .rd_o(rd),
    .imm_o(imm),
    .rd_wen_o(rd_wen),
		.op_info_o(op_info),
    .br_fun_o(br_fun),
    .ld_fun_o(ld_fun),
    .st_fun_o(st_fun),
    .alu_fun_o(alu_fun),
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
    .wdata(rd_wdata),
    .wen(rd_wen)
  );

  exu
  exu_u(
    .rs1_i(rs1_rdata),
    .rs2_i(rs2_rdata),
    .imm_i(imm),
    .pc_i(pc_r),
    .op_info_i(op_info),
    .br_fun_i(br_fun),
    .alu_fun_i(alu_fun),
    .result_o(exu_out),
    .jump_o()
  );
    
  mem
  mem_u(
    .ld_i(op_info[`LOAD]),
    .st_i(op_info[`STORE]),
    .ld_fun_i(ld_fun),
    .st_fun_i(st_fun),
    .addr_i(exu_out),
    .wdata_i(rs2_rdata),
    .rdata_o(mem_rdata)
  );

  wb
  wb_u(
    .op_info_i  (op_info),
    .mem_rdata_i(mem_rdata),
    .exu_out_i  (exu_out),
    .rd_wdata_o (rd_wdata)
  );

  // ebreak: stop the simulation
  import "DPI-C" function void env_ebreak();
  always @(*) begin
    if(ebreak) begin
    	env_ebreak();
		end
  end

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
