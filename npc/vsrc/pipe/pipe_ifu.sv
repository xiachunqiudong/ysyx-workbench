module pipe_ifu import liang_pkg::*;
(
  input logic      clk_i,
  input logic      rst_i,
  input logic      flush_i,
  input logic      flush_pc_i,
  // to ID
  output ifToId_t  ifToId_o,
  output logic     if_valid_o,
  input  logic     id_ready_i
);

  assign ifToId_o.inst = inst;
  assign ifToId_o.pc   = pc_q;

  pc_t pc_q, pc_d;
  inst_t inst;
	
  assign pc_d = flush_i ? flush_pc_i 
                        : (pc_q + 4);
  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)
      pc_q <= 32'h80000000;
    else
      pc_q <= pc_d;
  end

  inst_fetcher
  u_inst_fetcher(
    .pc_i   (pc_q),
    .inst_o (inst)
  );

  assign if_valid = 1'b1;

endmodule