module pipe_ifu import liang_pkg::*;
(
  input  logic                  clk_i,
  input  logic                  rst_i,
  input  logic                  flush_i,
  input  pc_t                   flush_pc_i,
  // IFU <> AXI LITE ARBITER
  output logic [ADDR_WIDTH-1:0] ifu_araddr_o,
  output logic                  ifu_arvalid_o,
  input  logic                  ifu_arready_i,
  input  logic                  ifu_rvalid_i,
  input  logic [DATA_WIDTH-1:0] ifu_rdata_i,
  output logic                  ifu_rready_o, 
  // IF <> ID
  output ifToId_t               ifToId_o,
  output logic                  if_valid_o,
  input  logic                  id_ready_i
);

  pc_t   pc_d, pc_q;
  logic  has_flush_d, has_flush_q; 
  logic  if_valid_q;
  logic  if_fire;
  logic  if_inst_valid;
  inst_t if_inst;

  assign ifToId_o.pc   = pc_q;
  assign ifToId_o.inst = if_inst;

  assign ifu_araddr_o  = pc_q;
  assign ifu_arvalid_o = if_valid_q;
  assign ifu_rready_o  = id_ready_i;
  assign if_inst       = ifu_rdata_i;
  assign if_inst_valid = ifu_rvalid_i;

  assign has_flush_d   = ifu_rvalid_i ? 1'b0 :
                         flush_i      ? 1'b1 :
                                        has_flush_q;

  assign if_valid_o    = if_valid_q & !flush_i & has_flush_q & if_inst_valid;
  assign if_fire       = if_valid_o & id_ready_i;

  assign pc_d = flush_i ? flush_pc_i 
                        : (pc_q + 4);
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
      pc_q        <= 32'h80000000;
      if_valid_q  <= 1'b1;
      has_flush_q <= '0;
    end
    else if(if_fire || flush_i) begin
      pc_q        <= pc_d;
      has_flush_q <= has_flush_d;
    end
  end

  integer fp;
  initial begin
    fp = $fopen("./log/npc_ifu.log");
  end

  always_ff @(posedge clk_i) begin
    if (if_fire) begin
      $fdisplay(fp, "%08x: %08x", pc_q, if_inst);
    end
  end

endmodule