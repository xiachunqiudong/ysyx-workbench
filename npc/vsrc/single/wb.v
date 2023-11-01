`include "defines.v"

module wb(
  input  [`OP_WIDTH-1:0] op_info_i,
  input  [`XLEN-1:0] mem_rdata_i,
  input  [`XLEN-1:0] exu_out_i,
  output [`XLEN-1:0] rd_wdata_o
);

  wire load;

  assign load = op_info_i[`LOAD];

  assign rd_wdata_o = load ? mem_rdata_i : exu_out_i;

endmodule