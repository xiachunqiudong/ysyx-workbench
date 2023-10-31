`include "defines.v"

module wb(
  input  [`OP_WIDTH-1:0] op_info_i,
  input  [`XLEN-1:0] mem_rdata,
  input  [`XLEN-1:0] exu_out,
  output [`XLEN-1:0] rf_wdata
);

  wire load;

  assign rf_wdata = load ? mem_rdata : exu_out;
  

endmodule