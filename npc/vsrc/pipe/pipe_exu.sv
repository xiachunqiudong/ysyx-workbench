module pipe_exu import liang_pkg::*;
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
  input  logic      wb_ready_i,
  // forward from wb stage
  input logic       wb_fwd_valid_i,  
  input logic [4:0] wb_fwd_rd_i,  
  input ele_t       wb_fwd_data_i,
  output logic      flush_o,
  output pc_t       flush_pc_o

);

  uop_info_t uop_info;
  pc_t       ex_pc;

  ele_t      alu_res;
  ele_t      lsu_res;
  
  assign uop_info = idToEx_q.uop_info;
  assign ex_pc    = uop_info.pc;
  
  assign exToWb_o.alu_res = alu_res;
  assign exToWb_o.lsu_res = lsu_res;

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
      idToEx_d    = idToEx_i;
    end

  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
      ex_valid_q  <= 1'b0;
    end 
    else begin
      ex_valid_q  <= ex_valid_d;
      idToEx_q    <= idToEx_d;
    end
  end

  logic jump;
  
  logic [4:0] rs1;
  logic [4:0] rs2;
  
  ele_t rs1_data;
  ele_t rs2_data;

  assign rs1      = idToEx_q.uop_info.rs1;
  assign rs2      = idToEx_q.uop_info.rs2;
  
  assign rs1_data = (wb_fwd_valid_i && wb_fwd_rd_i == rs1) ? wb_fwd_data_i 
                                                           : idToEx_q.rs1_rdata;
  
  assign rs2_data = (wb_fwd_valid_i && wb_fwd_rd_i == rs2) ? wb_fwd_data_i 
                                                           : idToEx_q.rs2_rdata;                                                      

  alu
  alu_u(
    .rs1_i      (rs1_data),
    .rs2_i      (rs2_data),
    .uop_info_i (uop_info),
    .alu_res_o  (alu_res),
    .jump_o     (jump)
  );

  // addr gen
  paddr_t lsu_addr;

  assign lsu_addr = rs1_data + idToEx_q.uop_info.imm;

  lsu
  lsu_u(
    .clk_i      (clk_i),
    .valid_i    (ex_valid_o),
    .uop_info_i (uop_info),
    .addr_i     (lsu_addr),
    .wdata_i    (rs2_data),
    .rdata_o    (lsu_res)
  );

  assign exToWb_o.uop_info = idToEx_q.uop_info;

  // flush
  assign flush_o    = ex_valid_o && (uop_info.fu_op inside {JAL, JALR} || (uop_info.fu_op == BRANCH && jump));
  assign flush_pc_o = (uop_info.fu_op == JALR ? rs1_data : ex_pc) + uop_info.imm;

 // for difftest
  assign exToWb_o.uop_info.dnpc = flush_o ? flush_pc_o : ex_pc + 4;

endmodule