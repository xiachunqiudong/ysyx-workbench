module exu(
  input [`XLEN-1:0] src1,
  input [`XLEN-1:0] src2,
	input [`XLEN-1:0] imm,
	output [`XLEN-1:0] out
);

	assign out = src1 + imm;

endmodule