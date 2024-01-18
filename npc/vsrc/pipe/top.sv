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
  logic [ADDR_WIDTH-1:0] ifu_araddr;
  logic                  ifu_arvalid;
  logic                  ifu_arready;
  logic [DATA_WIDTH-1:0] ifu_rdata;
  logic                  ifu_rvalid;
  logic                  ifu_rready;
  // LSU <> AXI LITE ARBITER
  logic [ADDR_WIDTH-1:0] lsu_araddr;
  logic                  lsu_arvalid;
  logic                  lsu_arready;
  logic [DATA_WIDTH-1:0] lsu_rdata;
  logic                  lsu_awaddr;
  logic                  lsu_awvalid;
  logic                  lsu_awready;
  logic [DATA_WIDTH-1:0] lsu_wdata;
  logic [STRB_WIDTH-1:0] lsu_wstrb;
  logic                  lsu_wvalid;
  logic                  lsu_wready;
  logic [1:0]            lsu_bresp;
  logic                  lsu_bvalid;
  logic                  lsu_bready;
  // AXI LITE ARBITER <> AXI
  logic [ADDR_WIDTH-1:0] araddr;
  logic                  arvalid;
  logic                  arready;
  logic [DATA_WIDTH-1:0] rdata;
  logic                  rvalid;
  logic                  rready;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic                  awvalid;
  logic                  awready;
  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wvalid;
  logic                  wready;
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;


  pipe_ifu
  u_pipe_ifu(
    .clk_i         (clk_i),
    .rst_i         (rst_i),
    .flush_i       (flush),
    .flush_pc_i    (flush_pc),
    .ifu_araddr_o  (ifu_araddr),
    .ifu_arvalid_o (ifu_arvalid),
    .ifu_arready_i (ifu_arready),
    .ifu_rdata_i   (ifu_rdata),
    .ifu_rvalid_i  (ifu_rvalid),
    .ifu_rready_o  (ifu_rready),
    .ifToId_o      (ifToId),
    .if_valid_o    (if_valid),
    .id_ready_i    (id_ready)
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
    .lsu_rdata_o   (),
    .lsu_rvalid_o  (),
    .lsu_rready_i  (),
    .lsu_awaddr_i  (),
    .lsu_awvalid_i (),
    .lsu_awready_o (),
    .lsu_wdata_i   (),
    .lsu_wstrb_i   (),
    .lsu_wvalid_i  (),
    .lsu_wready_o  (),
    .lsu_bresp_o   (),
    .lsu_bvalid_o  (),
    .lsu_bready_i  (),
    .araddr_o      (araddr),
    .arvalid_o     (arvalid),
    .arready_i     (arready),
    .rdata_i       (rdata),
    .rvalid_i      (rvalid),
    .rready_o      (rready),
    .awaddr_o      (awaddr),
    .awvalid_o     (awvalid),
    .awready_i     (awready),
    .wdata_o       (wdata),
    .wstrb_o       (wstrb),
    .wvalid_o      (wvalid),
    .wready_i      (wready),
    .bresp_i       (bresp),
    .bvalid_i      (bvalid),
    .bready_o      (bready)
  );

  dram_axi_lite
  u_dram_axi_lite(
    .clk_i     (clk_i),
    .rst_i     (rst_i),
    .araddr_i  (araddr),
    .arvalid_i (arvalid),
    .arready_o (arready),
    .rdata_o   (rdata),
    .rvalid_o  (rvalid),
    .rready_i  (rready),
    .awaddr_i  (awaddr),
    .awvalid_i (awvalid),
    .awready_o (awready),
    .wdata_i   (wdata),
    .wstrb_i   (wstrb),
    .wvalid_i  (wvalid),
    .wready_o  (wready),
    .bresp_o   (bresp),
    .bvalid_o  (bvalid),
    .bready_i  (bready)
  );

endmodule