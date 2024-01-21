module pipe_exu import liang_pkg::*;
(
  input logic              clk_i,
  input logic              rst_i,
  input logic              flush_i,
  // id <> ex
  input  idToEx_t          idToEx_i,
  input  logic             id_valid_i,
  output logic             ex_ready_o,
  // ex <> wb
  output exToWb_t          exToWb_o,
  output logic             ex_valid_o,
  input  logic             wb_ready_i,
  // forward from wb stage
  input logic              wb_fwd_valid_i,  
  input logic [4:0]        wb_fwd_rd_i,  
  input ele_t              wb_fwd_data_i,
  output logic             flush_o,
  output pc_t              flush_pc_o,
  // LSU <> ARBITER
  output  [ADDR_WIDTH-1:0] lsu_araddr_o,
  output                   lsu_arvalid_o,
  input                    lsu_arready_i,
  input [DATA_WIDTH-1:0]   lsu_rdata_i,
  input                    lsu_rvalid_i,
  output                   lsu_rready_o, 
  output  [ADDR_WIDTH-1:0] lsu_awaddr_o,
  output                   lsu_awvalid_o,
  input                    lsu_awready_i,
  output  [ADDR_WIDTH-1:0] lsu_wdata_o,
  output  [STRB_WIDTH-1:0] lsu_wstrb_o,
  output                   lsu_wvalid_o,
  input                    lsu_wready_i,
  input [1:0]              lsu_bresp_i,
  input                    lsu_bvalid_i,
  output                   lsu_bready_o
);

  //-----------EXU SIGNALS------------//
  logic                  ex_valid_d, ex_valid_q;
  logic                  ex_fire;
  logic                  ex_done;
  idToEx_t               idToEx_d, idToEx_q;
  uop_info_t             uop_info;
  pc_t                   ex_pc;
  logic [4:0]            rs1;
  logic [4:0]            rs2;
  ele_t                  rs1_data;
  ele_t                  rs2_data;
  // EX <> ALU
  ele_t                  alu_res;
  //-----------EXU x LSU------------//
  logic                  ex_is_load;
  logic                  ex_is_store;
  logic                  ex_use_lsu;
  logic                  lsu_req_valid;
  logic                  lsu_req_ready;
  load_type_e            lsu_req_load_type;            
  store_type_e           lsu_req_store_type;            
  logic                  lsu_req_type;
  logic [ADDR_WIDTH-1:0] lsu_req_addr;
  logic [ADDR_WIDTH-1:0] lsu_req_wdata;
  logic                  lsu_resp_valid;
  logic                  lsu_resp_ready;
  logic [ADDR_WIDTH-1:0] lsu_resp_rdata;
  //-----------BRANCH------------//
  logic                  jump;

  // output
  assign exToWb_o.alu_res  = alu_res;
  assign exToWb_o.lsu_res  = lsu_resp_rdata;
  assign exToWb_o.uop_info = idToEx_q.uop_info;
  // exu
  assign uop_info         = idToEx_q.uop_info;
  assign ex_pc            = uop_info.pc;
  assign rs1              = idToEx_q.uop_info.rs1;
  assign rs2              = idToEx_q.uop_info.rs2;
  assign ex_done          = !ex_use_lsu || (ex_use_lsu && lsu_resp_valid);
  assign ex_fire          = ex_valid_o && wb_ready_i;
  assign ex_ready_o       = !ex_valid_q || ex_fire;
  assign ex_valid_o       = ex_valid_q && ex_done;
  assign ex_valid_d       = ex_ready_o ? id_valid_i : ex_valid_q;
  assign idToEx_d         = ex_ready_o ? idToEx_i   : idToEx_q;

  assign rs1_data         = (wb_fwd_valid_i && wb_fwd_rd_i == rs1) ? wb_fwd_data_i 
                                                                   : idToEx_q.rs1_rdata;
  
  assign rs2_data         = (wb_fwd_valid_i && wb_fwd_rd_i == rs2) ? wb_fwd_data_i 
                                                                   : idToEx_q.rs2_rdata;
  //-----------LSU------------//
  assign ex_is_load         = uop_info.fu_op == LOAD;
  assign ex_is_store        = uop_info.fu_op == STORE;
  assign ex_use_lsu         = ex_is_load || ex_is_store;
  assign lsu_req_valid      = ex_valid_q && ex_use_lsu;
  assign lsu_req_load_type  = uop_info.load_type;
  assign lsu_req_store_type = uop_info.store_type;
  assign lsu_req_type       = ex_is_store;
  assign lsu_req_addr       = rs1_data + idToEx_q.uop_info.imm;
  assign lsu_req_wdata      = rs2_data;
  assign lsu_resp_ready     = wb_ready_i;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
      ex_valid_q  <= '0;
      idToEx_q    <= '0;
    end 
    else begin
      ex_valid_q  <= ex_valid_d;
      idToEx_q    <= idToEx_d;
    end
  end                                                     

  alu
  alu_u(
    .rs1_i      (rs1_data),
    .rs2_i      (rs2_data),
    .uop_info_i (uop_info),
    .alu_res_o  (alu_res),
    .jump_o     (jump)
  );

  lsu
  lsu_u(
    .clk_i                (clk_i),
    .rst_i                (rst_i),
  // EXU <> LSU,
    .lsu_req_valid_i      (lsu_req_valid),
    .lsu_req_ready_o      (lsu_req_ready),
    .lsu_req_load_type_i  (lsu_req_load_type),           
    .lsu_req_store_type_i (lsu_req_store_type),            
    .lsu_req_type_i       (lsu_req_type),
    .lsu_req_addr_i       (lsu_req_addr),
    .lsu_req_wdata_i      (lsu_req_wdata),
    .lsu_resp_valid_o     (lsu_resp_valid),
    .lsu_resp_ready_i     (lsu_resp_ready),
    .lsu_resp_rdata_o     (lsu_resp_rdata),
  // LSU <> ARBITE(),
    .lsu_araddr_o         (lsu_araddr_o),
    .lsu_arvalid_o        (lsu_arvalid_o),
    .lsu_arready_i        (lsu_arready_i),
    .lsu_rdata_i          (lsu_rdata_i),
    .lsu_rvalid_i         (lsu_rvalid_i),
    .lsu_rready_o         (lsu_rready_o),
    .lsu_awaddr_o         (lsu_awaddr_o),
    .lsu_awvalid_o        (lsu_awvalid_o),
    .lsu_awready_i        (lsu_awready_i),
    .lsu_wstrb_o          (lsu_wstrb_o),
    .lsu_wdata_o          (lsu_wdata_o),
    .lsu_wvalid_o         (lsu_wvalid_o),
    .lsu_wready_i         (lsu_wready_i),
    .lsu_bresp_i          (lsu_bresp_i),
    .lsu_bvalid_i         (lsu_bvalid_i),
    .lsu_bready_o         (lsu_bready_o)
  );

  

  // flush
  assign flush_o    = ex_valid_o && (uop_info.fu_op inside {JAL, JALR} || (uop_info.fu_op == BRANCH && jump));
  assign flush_pc_o = (uop_info.fu_op == JALR ? rs1_data : ex_pc) + uop_info.imm;

 // for difftest
  assign exToWb_o.uop_info.dnpc = flush_o ? flush_pc_o : ex_pc + 4;

endmodule