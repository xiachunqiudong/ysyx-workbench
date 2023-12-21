module pipe_exu import liang::*;
(
  input logic      clk_i,
  input logic      rst_i,
  input logic      flush_i,
  // id <> ex
  input  idToEx_t   idToEx_i,
  input  logic      id_valid_i,
  output logic      ex_ready_o,
  // ex <> wb
  output exToWb_t   exToWb_o,
  output logic      ex_valid_o,
  input  logic      wb_ready_i
);

  logic ex_fire;
  logic ex_valid_d, ex_valid_q;
  
  assign ex_fire    = ex_valid_q && wb_ready_i;
  assign ex_ready_o = ~ex_valid_q || ex_fire;
  assign ex_valid_o = ex_valid_q;

  idToEx_t idToEx_d, idToEx_q;

  always_comb begin
    ex_valid_d  = ex_valid_q;
    idToEx_d    = idToEx_q;
    
    if(ex_ready_o) begin
      ex_valid_d  = id_valid_i;
      idToEx_d = idToEx_i;
    end

  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i || flush_i) begin
      ex_valid_q  <= 1'b0;
    end else if begin
      ex_valid_q  <= ex_valid_d;
      idToEx_q    <= idToEx_d;
    end
  end

  logic jump;

  alu
  alu_u(
    .rs1_i      (idToEx_q.rs1_rdata),
    .rs2_i      (idToEx_q.rs2_rdata),
    .uop_info_i (idToEx_q.uop_info),
    .alu_res_o  (exToWb_o.alu_res),
    .jump_o     (jump)
  );

  // addr gen
  paddr_t lsu_addr;

  assign lsu_addr = idToEx_q.rs1_rdata + idToEx_q.uop_info.imm; 

  lsu
  lsu_u(
    .uop_info_i (idToEx_q.uop_info_q),
    .addr_i     (lsu_addr),
    .wdata_i    (idToEx_q.rs2_rdata_q),
    .rdata_o    (exToWb_o.lsu_res)
  );

  assign exToWb_o.uop_info = uop_info_q;

  
endmodule