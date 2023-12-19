module wb import liang_pkg::*;
(
  input  uop_info_t     uop_info_i,
  input  [XLEN-1:0]     mem_rdata_i,
  input  [XLEN-1:0]     alu_out_i,
  output [XLEN-1:0]     rd_wdata_o
);

  assign rd_wdata_o = uop_info_i.fu_op == LOAD ? mem_rdata_i 
                                               : alu_out_i;

endmodule