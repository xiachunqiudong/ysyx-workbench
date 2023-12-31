module ifu_axi_lite(
  input logic clk_i,
  input logic rst_i,
  // REQ CHANNEL
  input pc_t   if_req_pc_i,
  input logic  if_req_valid_i,
  output logic if_req_ready_o,
  // RESP CHANNEL
  output inst_t if_resp_inst_o,
  output logic  if_resp_valid_o,
  input  logic  if_resp_ready_i
);

  typedef enum logic [1:0] {
    READ_IDEL, SEND_ADDR, WAIT_DATA, READ_DONE
  } state_e;

  logic if_req_fire;
  logic if_resp_fire;

  logic arvalid;
  logic arready;

  inst_t rdata;
  logic  rvalid;
  logic  rready;

  logic addr_fire;
  logic rdata_fire;

  state_e state_d, state_q;
  pc_t    pc_d, pc_q;
  inst_t  inst_d, inst_q;

  assign if_req_ready_o  = state_q == IDEL;
  assign if_resp_valid_o = state_q == READ_DONE;
  
  assign if_req_fire  = if_req_valid_i  && if_req_ready_o;
  assign if_resp_fire = if_resp_valid_o && if_resp_ready_i;

  assign arvalid = state_q == SEND_ADDR;
  assign rready  = state_q == WAIT_DATA;

  assign addr_fire = arvalid && arready;
  assign data_fire = rvalid  && rready;

  assign pc_d   = if_req_fire ? if_req_pc_i : pc_q;
  assign inst_d = data_fire ? rdata : inst_q;
  
  always_comb begin
    case(state_q) begin
      READ_IDEL: state_d = if_req_fire  ? SEND_ADDR : IDEL;
      SEND_ADDR: state_d = addr_fire    ? WAIT_DATA : SEND_ADDR;
      WAIT_DATA: state_d = data_fire    ? READ_DONE : WAIT_DATA;
      READ_DONE: state_d = if_resp_fire ? READ_IDEL : READ_DONE;
      default: state_d = READ_IDEL;
    end
  end

  dram_axi_lite
  u_dram_axi_lite(
    .clk_i     (clk_i),
    .rst_i     (rst_i),
    .araddr_i  (pc_q),
    .arvalid_i (arvalid),
    .arready_o (arready),
    .rdata_o   (rdata),
    .rvalid_o  (rvalid),
    .rready_i  (rready),
    .awaddr_i  (),
    .awvalid_i (),
    .awready_o (),
    .wdata_i   (),
    .wvalid_i  (),
    .wready_o  (),
    .bresp_o   (),
    .bvalid_o  (),
    .bready_i  ()
  );



endmodule