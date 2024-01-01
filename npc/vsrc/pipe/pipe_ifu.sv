module pipe_ifu import liang_pkg::*;
(
  input logic      clk_i,
  input logic      rst_i,
  input logic      flush_i,
  input pc_t       flush_pc_i,
  // to ID
  output ifToId_t  ifToId_o,
  output logic     if_valid_o,
  input  logic     id_ready_i
);

  pc_t   pc_d, pc_q;

  logic  if_req_valid;
  logic  if_req_ready;
  inst_t if_resp_inst;
  logic  if_resp_valid;
  logic  if_resp_ready;
  logic  if_req_fire;
  
  logic  if_valid_q;
  logic  if_fire;

  assign if_req_valid  = if_valid_q;
  assign ifToId_o.inst = if_resp_inst;
  assign ifToId_o.pc   = pc_q;

  assign if_valid_o    = if_valid_q & ~flush_i & if_resp_valid;
  assign if_fire       = if_valid_o & id_ready_i;

  assign pc_d = flush_i ? flush_pc_i 
                        : (pc_q + 4);
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
      pc_q       <= 32'h80000000;
      if_valid_q <= 1'b1;
    end
    else if(if_fire || flush_i) begin
      pc_q <= pc_d;
    end
  end

  // inst_fetcher
  // u_inst_fetcher(
  //   .clk_i           (clk_i),
  //   .rst_i           (rst_i),
  //   .flush_i         (flush_i),
  //   .if_req_valid_i  (if_valid_q),
  //   .if_req_pc_i     (pc_q),
  //   .if_resp_valid_o (inst_valid),
  //   .if_resp_inst_o  (inst)
  // );

  ifu_axi_lite
  u_ifu_axi_lite(
    .clk_i           (clk_i),
    .rst_i           (rst_i),
    .flush_i         (flush_i),
    .if_req_pc_i     (pc_q),
    .if_req_valid_i  (if_req_valid),
    .if_resp_inst_o  (if_resp_inst),
    .if_resp_valid_o (if_resp_valid),
    .if_resp_ready_i (id_ready_i)
  );

  integer fp;

  initial begin
    fp = $fopen("./log/npc_ifu.log");
  end

  always_ff @(posedge clk_i) begin
    if (if_fire) begin
      $fdisplay(fp, "%08x: %08x", pc_q, if_resp_inst);
    end
  end


endmodule