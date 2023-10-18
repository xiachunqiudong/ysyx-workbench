module exu(
  input [`XLEN-1:0] rs1,
  input [`XLEN-1:0] rs2,
  input [`XLEN-1:0] imm,
  input [`XLEN-1:0] pc,
  output [`XLEN-1:0] result,
  output jump
);

	wire [`XLEN-1:0] src1;
	wire [`XLEN-1:0] src2;

	assign src1 = rs1;
	assign src2 = rs2;

	wire [`XLEN-1:0] add_res;
	wire [`XLEN-1:0] and_res;
	wire [`XLEN-1:0] or_res;
	wire [`XLEN-1:0] xor_res;
	
	assign out = add_res;

endmodule