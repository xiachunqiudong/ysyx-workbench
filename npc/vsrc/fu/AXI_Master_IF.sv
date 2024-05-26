module AXI_Master_IF
#(
  parameter int unsigned DATA_WIDTH  = 64,
  parameter int unsigned ADDR_WIDTH  = 32,
  parameter int unsigned STRB_WIDTH  = DATA_WIDTH/8
)
(
  input wire clk_i,
  input wire rst_i,
  // IFU <> AXI Master IF
  input  wire [ADDR_WIDTH-1:0] ifu_araddr_i,
  input  wire                  ifu_arvalid_i,
  output wire                  ifu_arready_o,
  output wire [DATA_WIDTH-1:0] ifu_rdata_o,
  output wire                  ifu_rvalid_o,
  input  wire                  ifu_rready_i,
  // LSU <> AXI Master IF
  input  wire [ADDR_WIDTH-1:0] lsu_araddr_i,
  input  wire                  lsu_arvalid_i,
  output wire                  lsu_arready_o,
  output wire [DATA_WIDTH-1:0] lsu_rdata_o,
  output wire                  lsu_rvalid_o,
  input  wire                  lsu_rready_i, 
  input  wire [ADDR_WIDTH-1:0] lsu_awaddr_i,
  input  wire                  lsu_awvalid_i,
  output wire                  lsu_awready_o,
  input  wire [ADDR_WIDTH-1:0] lsu_wdata_i,
  input  wire [STRB_WIDTH-1:0] lsu_wstrb_i,
  input  wire                  lsu_wvalid_i,
  output wire                  lsu_wready_o,
  output wire [1:0]            lsu_bresp_o,
  output wire                  lsu_bvalid_o,
  input  wire                  lsu_bready_i,
  // AXI Master IF <> AXI Bus
  output wire                  arvalid_o,
  input  wire                  arready_i,
  output wire [3:0]            arid_o,
  output wire [ADDR_WIDTH-1:0] araddr_o,
  output wire [7:0]            arlen_o,
  output wire [2:0]            arsize_o,
  output wire [1:0]            arburst_o,
  input  wire                  rvalid_i,
  output wire                  rready_o, 
  input  wire [3:0]            rid_i,
  input  wire [DATA_WIDTH-1:0] rdata_i,
  input  wire [1:0]            rresp_i,
  input  wire                  rlast_i,
  output wire                  awvalid_o,
  input  wire                  awready_i,
  output wire [3:0]            awid_o,
  output wire [ADDR_WIDTH-1:0] awaddr_o,
  output wire [7:0]            awlen_o,
  output wire [2:0]            awsize_o,
  output wire [1:0]            awburst_o,
  output wire                  wvalid_o,
  input  wire                  wready_i,
  output wire [ADDR_WIDTH-1:0] wdata_o,
  output wire [STRB_WIDTH-1:0] wstrb_o,
  output wire                  wlast_o,
  input  wire                  bvalid_i,
  output wire                  bready_o,
  input  wire [3:0]            bid_i,
  input  wire [1:0]            bresp_i
);

//========================================================
//                  AXI 协议简介
//========================================================
// 突发传输类型:
//  1. fixed: 固定地址, 适合访问 FIFO
//  2. incr:  地址递增, 适合访问 Memory
//  3. wrap:  回环递增, 适合访问 Cache
//


  parameter IDEL = 2'b00, IFU_RUN = 2'b01, LSU_RUN = 2'b10;
  logic [1:0] state_d, state_q;

  logic sel_ifu;
  logic sel_lsu;
  logic ifu_req_valid;
  logic lsu_req_valid;
  logic ifu_done;
  logic lsu_done;
  logic read_done;
  logic write_done;

  // FSM state
  always_comb begin
    state_d = state_q;
    case(state_q)
      IDEL: 
      begin
        state_d = lsu_req_valid ? LSU_RUN :
                  ifu_req_valid ? IFU_RUN : 
                  IDEL;
      end
      IFU_RUN: state_d = ifu_done ? IDEL : IFU_RUN;
      LSU_RUN: state_d = lsu_done ? IDEL : LSU_RUN;
      default: state_d = state_q;
    endcase
  end

  assign ifu_req_valid = ifu_arvalid_i;
  assign lsu_req_valid = lsu_arvalid_i || lsu_awvalid_i || lsu_wvalid_i;
  assign read_done     = rready_o && rvalid_i;
  assign write_done    = bready_o && bvalid_i;
  assign ifu_done      = sel_ifu  && read_done && rlast_i;
  assign lsu_done      = sel_lsu  && (read_done || write_done);

  assign sel_ifu = state_q == IFU_RUN;
  assign sel_lsu = state_q == LSU_RUN;
  
  assign ifu_arready_o = sel_ifu               & arready_i;
  assign ifu_rvalid_o  = sel_ifu               & rvalid_i;
  assign ifu_rdata_o   = {DATA_WIDTH{sel_ifu}} & rdata_i;

  assign lsu_arready_o = sel_lsu               & arready_i;
  assign lsu_rvalid_o  = sel_lsu               & rvalid_i;
  assign lsu_rdata_o   = {DATA_WIDTH{sel_lsu}} & rdata_i;

  assign lsu_awready_o = sel_lsu               & awready_i;
  assign lsu_bvalid_o  = sel_lsu               & bvalid_i;
  assign lsu_bresp_o   = {2{sel_lsu}}          & bresp_i;

  assign araddr_o  = {ADDR_WIDTH{sel_ifu}} & ifu_araddr_i
                   | {ADDR_WIDTH{sel_lsu}} & lsu_araddr_i;

  assign arvalid_o = sel_ifu               & ifu_arvalid_i
                   | sel_lsu               & lsu_arvalid_i;

  assign rready_o  = sel_ifu               & ifu_rready_i
                   | sel_lsu               & lsu_rready_i;

  assign awaddr_o  = {ADDR_WIDTH{sel_lsu}} & lsu_awaddr_i;
  assign awvalid_o = sel_lsu               & lsu_awvalid_i;            
  assign wdata_o   = {DATA_WIDTH{sel_lsu}} & lsu_wdata_i;
  assign wstrb_o   = {STRB_WIDTH{sel_lsu}} & lsu_wstrb_i;
  assign wvalid_o  = sel_lsu               & lsu_wvalid_i;
  assign bready_o  = sel_lsu               & lsu_bready_i; 

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state_q <= IDEL;
    end 
    else begin
      state_q <= state_d;
    end
  end

//========================================================
//                 AR Channel
//========================================================
  assign arid_o[3:0]    = 4'd2;
  assign arburst_o[1:0] = 2'b01;
  assign arsize_o[2:0]  = 3'b000;
  assign arlen_o[7:0]   = 3'b0001;

endmodule