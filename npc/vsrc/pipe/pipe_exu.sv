module pipe_exu import liang::*;
(
  input logic      clk_i,
  input logic      rst_i,
  // id <> ex
  input uop_info_t uop_info_i,
  input ele_t      rs1_rdate_i,
  input ele_t      rs2_rdate_i,
  input logic      id_valid_i,
  output logic      ex_ready_o,
  // ex <> wb
  output uop_info_t uop_info_o,
  output ele_t      exu_output_o,
  output logic      ex_valid_o,
  input logic       wb_ready_i
);

endmodule