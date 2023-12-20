module pipe_top import liang_pkg::*;
(
  input clk_i,
  input rst_i
);

  logic flush;
  pc_t  flush_pc;

  ifToId_t ifToId;
  loigc    if_valid;
  loigc    id_ready;

  logic      id_valid;
  logic      ex_ready;
  uop_info_t uop_info;
  idToEx_t   idToEx;

  ele_t rs1_rdata;
  ele_t rs2_rdata;

  pipe_ifu
  u_pipe_ifu(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .flush_i    (flush),
    .flush_pc_i (flush_pc),
    .ifToId_o   (ifToId),
    .if_valid_o (if_valid),
    .id_ready_i (id_ready)
  );

  pipe_idu
  u_pipe_idu(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .ifToId_i   (ifToId),
    .if_valid_i (if_valid),
    .id_ready_o (id_ready),
    .id_valid_o (id_valid),
    .ex_ready_i (ex_ready),
    .uop_info_o (uop_info)
  );

	regfile #(.ADDR_WIDTH(5), .DATA_WIDTH(XLEN)) 
  regfile_u(
    .clk       (clk_i),
    // read
    .rs1_raddr (uop_info.rs1),
    .rs2_raddr (uop_info.rs2),
    .rs1_rdata (rs1_rdata),
    .rs2_rdata (rs2_rdata),
    // write
    .waddr     (),
    .wdata     (),
    .wen       (),
    .a0        ()
  );
  
  assign idToEx.uop_info  = uop_info;
  assign idToEx.rs1_raddr = rs1_rdata;
  assign idToEx.rs2_raddr = rs2_rdata;







endmodule