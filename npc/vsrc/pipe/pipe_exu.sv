module pipe_exu import liang::*;
(
  input logic      clk_i,
  input logic      rst_i,
  input logic      flush_i,
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

  logic ex_fire;
  logic ex_valid_d, ex_valid_q;
  assign ex_fire = ex_valid_q && wb_ready_i;
  assign ex_ready_o = ~ex_valid_q || ex_fire;
  assign ex_valid_o = ex_valid_q;

  uop_info_t uop_info_d, uop_info_q;
  ele_t      rs1_rdate_d, rs1_rdate_q;
  ele_t      rs2_rdate_d, rs2_rdate_q;

  always_comb begin
    ex_valid_d  = ex_valid_q;
    uop_info_d  = uop_info_q;
    rs1_rdate_d = rs1_rdate_q;
    rs2_rdate_d = rs2_rdate_q;

    if(ex_ready_o) begin
      ex_valid_d  = id_valid_i;
      uop_info_d  = uop_info_i;
      rs1_rdate_d = rs1_rdate_i;
      rs2_rdate_d = rs2_rdate_i;
    end

  end

  always_ff @(posedge clk_i or posedge clk_i ) begin
    if(rst_i || flush_i) begin
      ex_valid_q <= 1'b0;
    end else if begin
      ex_valid_q  <= ex_valid_d;
      uop_info_q  <= uop_info_d;
      rs1_rdate_q <= rs1_rdate_d;
      rs2_rdate_q <= rs2_rdate_d;
    end
  end


endmodule