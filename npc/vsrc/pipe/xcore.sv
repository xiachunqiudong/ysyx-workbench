module xcore import liang_pkg::*;
(
  input  wire        clock,
  input  wire        reset,
  input  wire        io_interrupt,
  // CPU as master
  // AW channel
  input  wire        io_master_awready,
  output wire        io_master_awvalid,
  output wire [3:0]  io_master_awid,
  output wire [31:0] io_master_awaddr,
  output wire [7:0]  io_master_awlen,
  output wire [2:0]  io_master_awsize,
  output wire [1:0]  io_master_awburst,
  // W channel
  input  wire        io_master_wready,
  output wire        io_master_wvalid,
  output wire [63:0] io_master_wdata,
  output wire [63:0] io_master_wstrb,
  output wire        io_master_wlast,
  // B channel
  output wire        io_master_bready,
  input  wire        io_master_bvalid,
  input  wire [3:0]  io_master_bid,
  input  wire [1:0]  io_master_bresp,
  // AR channel
  input  wire        io_master_arready,
  output wire        io_master_arvalid,
  output wire [3:0]  io_master_arid,
  output wire [31:0] io_master_araddr,
  output wire [7:0]  io_master_arlen,
  output wire [2:0]  io_master_arsize,
  output wire [1:0]  io_master_arburst,
  // R Channel
  output wire        io_master_rready,
  input  wire        io_master_rvalid,
  input  wire [3:0]  io_master_rid,
  input  wire [63:0] io_master_rdata,
  input  wire [1:0]  io_master_rresp,
  input  wire        io_master_rlast,
  // CPU as slave, do not use for now.
  // AW channel
  output wire        io_slave_awready,
  input  wire        io_slave_awvalid,
  input  wire [3:0]  io_slave_awid,
  input  wire [31:0] io_slave_awaddr,
  input  wire [7:0]  io_slave_awlen,
  input  wire [2:0]  io_slave_awsize,
  input  wire [1:0]  io_slave_awburst,
  // W channel
  output wire        io_slave_wready,
  input  wire        io_slave_wvalid,
  input  wire [63:0] io_slave_wdata,
  input  wire [63:0] io_slave_wstrb,
  input  wire        io_slave_wlast,
  // B channel
  input  wire        io_slave_bready,
  output wire        io_slave_bvalid,
  output wire [3:0]  io_slave_bid,
  output wire [1:0]  io_slave_bresp,
  // AR channel
  output wire        io_slave_arready,
  input  wire        io_slave_arvalid,
  input  wire [3:0]  io_slave_arid,
  input  wire [31:0] io_slave_araddr,
  input  wire [7:0]  io_slave_arlen,
  input  wire [2:0]  io_slave_arsize,
  input  wire [1:0]  io_slave_arburst,
  // R Channel
  input  wire        io_slave_rready,
  output wire        io_slave_rvalid,
  output wire [3:0]  io_slave_rid,
  output wire [63:0] io_slave_rdata,
  output wire [1:0]  io_slave_rresp,
  output wire        io_slave_rlast
);

  logic       flush;
  pc_t        flush_pc;

  ifToId_t    ifToId;
  logic       if_valid;
  logic       id_ready;

  logic       id_valid;
  logic       ex_ready;
  uop_info_t  uop_info;
  idToEx_t    idToEx;
  wire        idu_csr_wen;
  wire [11:0] idu_csr_id;
  wire        idu_ecall;
  wire        idu_ebreak;
  wire        idu_mret;

  ele_t       rs1_rdata;
  ele_t       rs2_rdata;

  exToWb_t    exToWb;
  logic       ex_valid;
  logic       wb_ready;
  wb_req_t    wb_req;

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
  logic                  lsu_rvalid;
  logic                  lsu_rready;
  logic [ADDR_WIDTH-1:0] lsu_awaddr;
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
    .clk_i         (clock),
    .rst_i         (reset),
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
    .clk_i        (clock),
    .rst_i        (reset),
    .flush_i      (flush),
    .ifToId_i     (ifToId),
    .if_valid_i   (if_valid),
    .id_ready_o   (id_ready),
    .id_valid_o   (id_valid),
    .ex_ready_i   (ex_ready),
    .uop_info_o   (uop_info),
		.idu_csr_id_o (idu_csr_id),
		.idu_csr_wen_o(idu_csr_wen),
		.idu_ecall_o  (idu_ecall),
		.idu_ebreak_o (idu_ebreak),
		.idu_mret_o   (idu_mret)
  );

	regfile #(.ADDR_WIDTH(5), .DATA_WIDTH(XLEN)) 
  regfile_u(
    .clk       (clock),
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
    .clk_i          (clock),
    .rst_i          (reset),
    .flush_i        (flush),
    .idToEx_i       (idToEx),
		.idu_csr_id_i   (idu_csr_id),
		.idu_csr_wen_i  (idu_csr_wen),
		.idu_ecall_i    (idu_ecall),
		.idu_ebreak_i   (idu_ebreak),
		.idu_mret_i     (idu_mret),
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
    .flush_pc_o     (flush_pc),
    // LSU <> AXI LITE ARBITER
    .lsu_araddr_o   (lsu_araddr),
    .lsu_arvalid_o  (lsu_arvalid),
    .lsu_arready_i  (lsu_arready),
    .lsu_rdata_i    (lsu_rdata),
    .lsu_rvalid_i   (lsu_rvalid),
    .lsu_rready_o   (lsu_rready),
    .lsu_awaddr_o   (lsu_awaddr),
    .lsu_awvalid_o  (lsu_awvalid),
    .lsu_awready_i  (lsu_awready),
    .lsu_wdata_o    (lsu_wdata),
    .lsu_wstrb_o    (lsu_wstrb),
    .lsu_wvalid_o   (lsu_wvalid),
    .lsu_wready_i   (lsu_wready),
    .lsu_bresp_i    (lsu_bresp),
    .lsu_bvalid_i   (lsu_bvalid),
    .lsu_bready_o   (lsu_bready)
  );

  pipe_wb
  u_pipe_wb(
    .clk_i          (clock),
    .rst_i          (reset),
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
    .clk_i         (clock),
    .rst_i         (reset),
    .ifu_araddr_i  (ifu_araddr),
    .ifu_arvalid_i (ifu_arvalid),
    .ifu_arready_o (ifu_arready),
    .ifu_rdata_o   (ifu_rdata),
    .ifu_rvalid_o  (ifu_rvalid),
    .ifu_rready_i  (ifu_rready),
    .lsu_araddr_i  (lsu_araddr),
    .lsu_arvalid_i (lsu_arvalid),
    .lsu_arready_o (lsu_arready),
    .lsu_rdata_o   (lsu_rdata),
    .lsu_rvalid_o  (lsu_rvalid),
    .lsu_rready_i  (lsu_rready),
    .lsu_awaddr_i  (lsu_awaddr),
    .lsu_awvalid_i (lsu_awvalid),
    .lsu_awready_o (lsu_awready),
    .lsu_wdata_i   (lsu_wdata),
    .lsu_wstrb_i   (lsu_wstrb),
    .lsu_wvalid_i  (lsu_wvalid),
    .lsu_wready_o  (lsu_wready),
    .lsu_bresp_o   (lsu_bresp),
    .lsu_bvalid_o  (lsu_bvalid),
    .lsu_bready_i  (lsu_bready),
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
    .clk_i     (clock),
    .rst_i     (reset),
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

  csr
  u_csr(
  .clk_i                  (),
  .rst_i                  (),
  // For CSRRW/CSRRC/CSRRS
  .csr_id                 (),
  .csr_wen                (),
  .csr_wdata              (),
  .csr_rdata              (),
  // For Riscv Trap
  .trap_handler_mepc_wdata(),
  .trap_handler_mepc_wen  (),
  .csr_mtvec_rdata        (),
  .csr_mepc_rdata         ()
  );

endmodule
