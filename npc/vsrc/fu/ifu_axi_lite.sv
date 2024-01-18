module ifu_axi_lite import liang_pkg::*;
(
  input logic clk_i,
  input logic rst_i,
  input logic flush_i,
  // REQ CHANNEL
  input pc_t   if_req_pc_i,
  input logic  if_req_valid_i,
  // RESP CHANNEL
  output inst_t if_resp_inst_o,
  output logic  if_resp_valid_o,
  input  logic  if_resp_ready_i,
  // IFU <> AXI LITE ARBITER
  output logic                  ifu_arvalid_o,
  input  logic                  ifu_arready_i,
  output logic [ADDR_WIDTH-1:0] ifu_araddr_o,
  input  logic                  ifu_rvalid_i,
  input  logic [ADDR_WIDTH-1:0] ifu_rdata_i,
  output logic                  ifu_rready_o,
  
);

  assign ifu_arvalid_o   = if_req_valid_i;
  assign ifu_araddr_o    = if_req_pc_i;
  assign ifu_rready_o    = if_resp_ready_i;
  assign if_resp_valid_o = ifu_rvalid_i;
  assign if_resp_inst_o  = ifu_rdata_o;

endmodule