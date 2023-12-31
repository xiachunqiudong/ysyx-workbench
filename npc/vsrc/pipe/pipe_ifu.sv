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
  inst_t inst;
  logic  inst_valid;
  logic  if_valid_q;
  logic  if_fire;

  assign ifToId_o.inst = inst;
  assign ifToId_o.pc   = pc_q;
  
  assign if_valid_o    = if_valid_q & ~flush_i & inst_valid;
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

  inst_fetcher
  u_inst_fetcher(
    .clk_i           (clk_i),
    .rst_i           (rst_i),
    .flush_i         (flush_i),
    .if_req_valid_i  (if_valid_q),
    .if_req_pc_i     (pc_q),
    .if_resp_valid_o (inst_valid),
    .if_resp_inst_o  (inst)
  );

endmodule