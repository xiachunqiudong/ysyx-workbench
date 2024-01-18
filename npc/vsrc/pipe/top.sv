module top import liang_pkg::*;
(
  input clk_i,
  input rst_i
);

  logic flush;
  pc_t  flush_pc;

  ifToId_t ifToId;
  logic    if_valid;
  logic    id_ready;

  logic      id_valid;
  logic      ex_ready;
  uop_info_t uop_info;
  idToEx_t   idToEx;

  ele_t rs1_rdata;
  ele_t rs2_rdata;

  exToWb_t exToWb;
  logic    ex_valid;
  logic    wb_ready;
  wb_req_t wb_req;

  // forward
  logic       wb_fwd_valid;
  logic [4:0] wb_fwd_rd;
  ele_t       wb_fwd_data;

  // IFU <> AXI LITE ARBITER
  logic ifu_araddr;
  logic ifu_arvalid;
  logic ifu_arready;
  logic ifu_rdata;
  logic ifu_rvalid;
  logic ifu_rready;
  
  // LSU <> AXI LITE ARBITER
  logic lsu_araddr;
  logic lsu_arvalid;
  logic lsu_arready;
  logic lsu_awaddr;
  logic lsu_awvalid;
  logic lsu_awready;
  logic lsu_wdata;
  logic lsu_wstrb;
  logic lsu_wvalid;
  logic lsu_wready;
  logic lsu_bresp;
  logic lsu_bresp;
  logic lsu_bready;

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
    .flush_i    (flush),
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
    .waddr     (wb_req.rd),
    .wdata     (wb_req.rd_wdata),
    .wen       (wb_req.rd_wen)
  );
  
  assign idToEx.uop_info  = uop_info;
  assign idToEx.rs1_rdata = rs1_rdata;
  assign idToEx.rs2_rdata = rs2_rdata;

  pipe_exu
  u_pipe_exu(
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .flush_i        (flush),
    .idToEx_i       (idToEx),
    .id_valid_i     (id_valid),
    .ex_ready_o     (ex_ready),
    .exToWb_o       (exToWb),
    .ex_valid_o     (ex_valid),
    .wb_ready_i     (wb_ready),
    // fwd from wb
    .wb_fwd_valid_i (wb_fwd_valid),
    .wb_fwd_rd_i    (wb_fwd_rd),
    .wb_fwd_data_i  (wb_fwd_data),
    .flush_o        (flush),
    .flush_pc_o     (flush_pc)
  );

  pipe_wb
  u_pipe_wb(
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .exToWb_i       (exToWb),
    .ex_valid_i     (ex_valid),
    .wb_ready_o     (wb_ready),
    .wb_req_o       (wb_req),
    .wb_fwd_valid_o (wb_fwd_valid),
    .wb_fwd_rd_o    (wb_fwd_rd),
    .wb_fwd_data_o  (wb_fwd_data)
  );

  axi_lite_arbiter
  u_axi_lite_arbiter(
    .clk_i         (clk_i),
    .rst_i         (rst_i),
    .ifu_araddr_i  (ifu_araddr),
    .ifu_arvalid_i (ifu_arvalid),
    .ifu_arready_o (ifu_arready),
    .ifu_rdata_o   (ifu_rdata),
    .ifu_rvalid_o  (ifu_rvalid),
    .ifu_rready_i  (ifu_rready),
    .lsu_araddr_i  (),
    .lsu_arvalid_i (),
    .lsu_arready_o (),
    .lsu_awaddr_i  (),
    .lsu_awvalid_i (),
    .lsu_awready_o (),
    .lsu_wdata_i   (),
    .lsu_wstrb_i   (),
    .lsu_wvalid_i  (),
    .lsu_wready_o  (),
    .lsu_bresp_o   (),
    .lsu_bresp_o   (),
    .lsu_bready_i  ()
  );


endmodule