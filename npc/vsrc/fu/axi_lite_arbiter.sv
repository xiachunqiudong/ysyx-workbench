module axi_lite_arbiter
#(
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned ADDR_WIDTH  = 32,
  parameter int unsigned STRB_WIDTH = DATA_WIDTH/8
)
(
  input wire clk_i,

  input wire rst_i,
  // IFU <> ARBITER
  input  wire [ADDR_WIDTH-1:0] ifu_araddr_i,
  input  wire                  ifu_arvalid_i,
  output wire                  ifu_arready_o,
  output wire [DATA_WIDTH-1:0] ifu_rdata_o,
  output wire                  ifu_rvalid_o,
  input  wire                  ifu_rready_i,
  // LSU <> ARBITER
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
  // ARBITER <> AXI_LITE_RAM
  output wire [ADDR_WIDTH-1:0] araddr_o,
  output wire                  arvalid_o,
  input  wire                  arready_i,
  input  wire [DATA_WIDTH-1:0] rdata_i,
  input  wire                  rvalid_i,
  output wire                  rready_o, 
  output wire [ADDR_WIDTH-1:0] awaddr_o,
  output wire                  awvalid_o,
  input  wire                  awready_i,
  output wire [ADDR_WIDTH-1:0] wdata_o,
  output wire [STRB_WIDTH-1:0] wstrb_o,
  output wire                  wvalid_o,
  input  wire                  wready_i,
  input  wire [1:0]            bresp_i,
  input  wire                  bvalid_i,
  output wire                  bready_o
);

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
      IDEL: begin
        state_d = lsu_req_valid ? LSU_RUN :
                  ifu_req_valid ? IFU_RUN : 
                  IDEL;
      end;
      IFU_RUN: state_d = ifu_done ? IDEL : IFU_RUN;
      LSU_RUN: state_d = lsu_done ? IDEL : LSU_RUN;
      default: state_d = state_q;
    endcase
  end

  assign ifu_req_valid = ifu_arvalid_i;
  assign lsu_req_valid = lsu_arvalid_i || lsu_awvalid_i || lsu_wvalid_i;
  assign read_done     = rready_o && rvalid_i;
  assign write_done    = bready_o && bvalid_i;
  assign ifu_done      = sel_ifu  && read_done;
  assign lsu_done      = sel_lsu  && (read_done || write_done);

  assign sel_ifu = state_q == IFU_RUN;
  assign sel_lsu = state_q == LSU_RUN;
  
  assign ifu_arready_o = arready_i & sel_ifu;
  assign ifu_rvalid_o  = rvalid_i  & sel_ifu;
  assign ifu_rdata_o   = {DATA_WIDTH{sel_ifu}} & rdata_i;
  
  assign lsu_arready_o = sel_lsu               & arready_i;
  assign lsu_rvalid_o  = sel_lsu               & rvalid_i;
  assign lsu_rdata_o   = {DATA_WIDTH{sel_lsu}} & rdata_i;
  assign lsu_awready_o = sel_lsu               & awready_i;
  assign lsu_bvalid_o  = sel_lsu               & bvalid_i;
  assign lsu_bresp_o   = {2{sel_lsu}}          & bresp_i;

  assign arvalid_o = sel_ifu & ifu_arvalid_i
                   | sel_lsu & lsu_arvalid_i;
  assign araddr_o  = sel_ifu & ifu_araddr_i
                   | sel_lsu & lsu_araddr_i;

  assign awaddr_o = {ADDR_WIDTH{sel_lsu}} & lsu_awaddr_i;            
  assign wvalid_o = sel_lsu               & lsu_wvalid_i;
  assign wdata_o  = {DATA_WIDTH{sel_lsu}} & lsu_wdata_i;
  assign wstrb_o  = {STRB_WIDTH{sel_ifu}} & lsu_wstrb_i;
  assign bready_o = sel_lsu               & lsu_bready_i;
         
  
endmodule