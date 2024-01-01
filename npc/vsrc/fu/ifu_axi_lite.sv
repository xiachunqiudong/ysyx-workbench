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
  input  logic  if_resp_ready_i
);

  typedef enum logic [1:0] {
    READ_IDEL, SEND_ADDR, WAIT_DATA, READ_DONE
  } state_e;

  logic arvalid;
  logic arready;

  inst_t rdata;
  logic  rvalid;
  logic  rready;

  logic addr_fire;
  logic data_fire;

  logic if_resp_fire;

  state_e state_d, state_q;
  inst_t  inst_d,  inst_q;

  assign if_resp_inst_o  = inst_q;
  assign if_resp_valid_o = state_q == READ_DONE;
  assign if_resp_fire    = if_resp_valid_o && if_resp_ready_i;

  assign arvalid = state_q == SEND_ADDR;
  assign rready  = 1'b1;

  assign addr_fire = arvalid && arready;
  assign data_fire = rvalid  && rready;

  assign inst_d = data_fire ? rdata : inst_q;
  
  always_comb begin
    case(state_q)
      READ_IDEL: state_d = if_req_valid_i ? SEND_ADDR : READ_IDEL;
      SEND_ADDR: state_d = flush_i ? SEND_ADDR : (addr_fire ? WAIT_DATA : SEND_ADDR);
      WAIT_DATA: state_d = flush_i ? SEND_ADDR : (data_fire ? READ_DONE : WAIT_DATA);
      READ_DONE: state_d = (flush_i || if_resp_fire) ? SEND_ADDR : READ_DONE;
      default: state_d = READ_IDEL;
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_i) begin
    if (rst_i) begin
      state_q <= READ_IDEL;
      inst_q  <= '0;
    end else begin
      state_q <= state_d;
      inst_q  <= inst_d;
    end
  end

  dram_axi_lite
  u_dram_axi_lite(
    .clk_i     (clk_i),
    .rst_i     (rst_i),
    .araddr_i  (if_req_pc_i),
    .arvalid_i (arvalid),
    .arready_o (arready),
    .rdata_o   (rdata),
    .rvalid_o  (rvalid),
    .rready_i  (rready),
    .awaddr_i  (),
    .awvalid_i (),
    .awready_o (),
    .wdata_i   (),
    .wstrb_i   (),
    .wvalid_i  (),
    .wready_o  (),
    .bresp_o   (),
    .bvalid_o  (),
    .bready_i  ()
  );



endmodule