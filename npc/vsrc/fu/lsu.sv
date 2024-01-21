module lsu import liang_pkg::*;
(
  input                    clk_i,
  input                    rst_i,
  // EXU <> LSU
  input                    lsu_req_valid_i,
  output                   lsu_req_ready_o,
  input load_type_e        lsu_req_load_type_i,            
  input store_type_e       lsu_req_store_type_i,            
  input                    lsu_req_type_i,
  input [ADDR_WIDTH-1:0]   lsu_req_addr_i,
  input [ADDR_WIDTH-1:0]   lsu_req_wdata_i,
  output                   lsu_resp_valid_o,
  input                    lsu_resp_ready_i,
  output [ADDR_WIDTH-1:0]  lsu_resp_rdata_o,
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

  typedef enum logic {
    LSU_IDEL, LSU_RUN
  } lsu_state_e;

  //-----------LSU SIGNALS------------//
  lsu_state_e            lsu_state_d, lsu_state_q;
  logic                  lsu_type_d, lsu_type_q; // | 0: LOAD | 1: STORE |
  logic                  lsu_is_load;
  logic                  lsu_is_store;
  logic                  lsu_valid;
  logic                  lsu_req_fire;
  logic                  lsu_resp_fire;
  logic [ADDR_WIDTH-1:0] lsu_addr;
  logic [ADDR_WIDTH-1:0] lsu_addr_d, lsu_addr_q;

  //-----------LOAD SIGNALS------------//
  load_type_e            load_type_d, load_type_q;
  logic [7:0]            lb_data;
  logic [15:0]           lh_data;
  logic [31:0]           lw_data;
  logic [DATA_WIDTH-1:0] lb_ext_data;
	logic [DATA_WIDTH-1:0] lb_sext_data;
  logic [DATA_WIDTH-1:0] lh_ext_data;
	logic [DATA_WIDTH-1:0] lh_sext_data;

  //-----------STORE SIGNALS------------//
	logic [DATA_WIDTH-1:0] lsu_wdata_d, lsu_wdata_q;
  logic [DATA_WIDTH-1:0] lsu_sb_wdata;
  logic [DATA_WIDTH-1:0] lsu_sh_wdata;
  logic [STRB_WIDTH-1:0] lsu_strb_d,  lsu_strb_q;
  logic [DATA_WIDTH-1:0] lsu_wdata;
  logic [STRB_WIDTH-1:0] lsu_sb_strb;
  logic [STRB_WIDTH-1:0] lsu_sh_strb;
  logic [STRB_WIDTH-1:0] lsu_strb;
	
  //-----------LSU------------//
  always_comb begin
    case(lsu_state_q)
      LSU_IDEL: lsu_state_d = lsu_req_fire ?  LSU_RUN : LSU_IDEL;
      LSU_RUN:  lsu_state_d = lsu_resp_fire ? LSU_IDEL : LSU_RUN;
      default:  lsu_state_d = LSU_IDEL;
    endcase
  end

  assign lsu_valid        = lsu_state_q == LSU_RUN;
  assign lsu_is_load      = lsu_type_q  == 1'b0;
  assign lsu_is_store     = lsu_type_q  == 1'b1;
  assign lsu_req_ready_o  = lsu_state_q == LSU_IDEL;
  assign lsu_req_fire     = lsu_req_valid_i  && lsu_req_ready_o;
  assign lsu_resp_valid_o = lsu_valid && (lsu_is_load && lsu_rvalid_i || lsu_is_store && lsu_bvalid_i);
  assign lsu_resp_fire    = lsu_resp_valid_o && lsu_resp_ready_i;
  // Accept new inst
  assign lsu_addr        = {lsu_req_addr_i[ADDR_WIDTH-1:2], 2'b00};
  assign lsu_type_d      = lsu_req_fire ? lsu_req_type_i : lsu_type_q;
  assign lsu_addr_d      = lsu_req_fire ? lsu_addr       : lsu_addr_q;
  assign lsu_strb_d      = lsu_req_fire ? lsu_strb       : lsu_strb_q;
  assign lsu_wdata_d     = lsu_req_fire ? lsu_wdata      : lsu_wdata_q;

  //-----------LSU x AXI LITE------------//
  assign lsu_araddr_o  = lsu_addr_q;
  assign lsu_arvalid_o = lsu_valid && lsu_is_load;
  assign lsu_araddr_o  = lsu_addr_q;
  assign lsu_rready_o  = lsu_resp_ready_i;
  
  assign lsu_awvalid_o = lsu_valid && lsu_is_store;
  assign lsu_awaddr_o  = lsu_addr_q;
  assign lsu_wvalid_o  = lsu_valid && lsu_is_store;
  assign lsu_wdata_o   = lsu_wdata_q;
  assign lsu_wstrb_o   = lsu_strb_q;
  assign lsu_bready_o  = lsu_resp_ready_i;

  //-----------LOAD------------//
  assign load_type_d  = lsu_req_fire ? lsu_req_load_type_i : load_type_q;
	assign lb_ext_data  = {{XLEN-8{1'b0}},         lb_data};
	assign lb_sext_data = {{XLEN-8{lb_data[7]}},   lb_data};
  assign lh_ext_data  = {{XLEN-16{1'b0}},        lh_data};
	assign lh_sext_data = {{XLEN-16{lh_data[15]}}, lh_data};

	MuxKey #(.NR_KEY(4), .KEY_LEN(2), .DATA_LEN(8))
  lb_mux(
      .out(lb_data),
      .key(lsu_addr_q[1:0]),
      .lut({
        2'b00, lsu_rdata_i[7:0],
        2'b01, lsu_rdata_i[15:8],
        2'b10, lsu_rdata_i[23:16],
        2'b11, lsu_rdata_i[31:24]
      })
  );
  
	MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(16))
  lh_mux(
      .out(lh_data),
      .key(lsu_addr_q[1]),
      .lut({
        1'b0, lsu_rdata_i[15:0],
        1'b1, lsu_rdata_i[31:16]
      })
  );

	MuxKey #(.NR_KEY(6), .KEY_LEN(3), .DATA_LEN(XLEN))
  rdata_mux(
      .out(lsu_resp_rdata_o),
      .key(load_type_q),
      .lut({
        LOAD_NONE, {XLEN{1'b0}},
        LOAD_LB,   lb_sext_data, // lb
        LOAD_LH,   lh_sext_data, // lh
        LOAD_LW,   lsu_rdata_i,  // lw
        LOAD_LBU,  lb_ext_data,  // lbu
        LOAD_LHU,  lh_ext_data   // lhu
      })
  );

	// STORE
	MuxKey #(.NR_KEY(4), .KEY_LEN(2), .DATA_LEN(XLEN))
  sb_mux(
    .out(lsu_sb_wdata),
    .key(lsu_addr[1:0]),
    .lut({
      2'b00, {8'b0,                 8'b0,                 8'b0,                 lsu_req_wdata_i[7:0]},
      2'b01, {8'b0,                 8'b0,                 lsu_req_wdata_i[7:0], 8'b0                },
      2'b10, {8'b0,                 lsu_req_wdata_i[7:0], 8'b0,                 8'b0                },
      2'b11, {lsu_req_wdata_i[7:0], 8'b0,                 8'b0,                 8'b0                }
    })
  );

	MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(XLEN))
  sh_mux(
    .out(lsu_sh_wdata),
    .key(lsu_addr[1]),
    .lut({
      1'b0, {16'b0,         lsu_req_wdata_i[15:0]},
      1'b1, {lsu_req_wdata_i[15:0], 16'b0}
    })
  );

	MuxKey #(.NR_KEY(4), .KEY_LEN(2), .DATA_LEN(4))
  sb_mask_mux(
    .out(lsu_sb_strb),
    .key(lsu_addr[1:0]),
    .lut({
      2'b00, 4'b0001,
      2'b01, 4'b0010,
      2'b10, 4'b0100,
      2'b11, 4'b1000
    })
  );

	MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(4))
  sh_mask_mux(
    .out(lsu_sh_strb),
    .key(lsu_addr[1]),
    .lut({
      1'b0, 4'b0011,
      1'b1, 4'b1100
    })
  );

	MuxKey #(.NR_KEY(4), .KEY_LEN(3), .DATA_LEN(DATA_WIDTH))
  wdata_mux(
    .out(lsu_wdata),
    .key(lsu_req_store_type_i),
    .lut({
      STORE_NONE, {DATA_WIDTH{1'b0}},
      STORE_SB,    lsu_sb_wdata,    // sb
      STORE_SH,    lsu_sh_wdata,    // sh
      STORE_SW,    lsu_req_wdata_i  // sw
    })
  );

	MuxKey #(.NR_KEY(4), .KEY_LEN(3), .DATA_LEN(STRB_WIDTH))
  wmask_mux(
    .out(lsu_strb),
    .key(lsu_req_store_type_i),
    .lut({
      STORE_NONE, 4'b0000,
      STORE_SB,   lsu_sb_strb, // sb
      STORE_SH,   lsu_sh_strb, // sh
      STORE_SW,   4'b1111      // sw
    })
  );

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      lsu_state_q <= LSU_IDEL;
      lsu_type_q  <= '0;
      lsu_addr_q  <= '0;
      lsu_wdata_q <= '0;
      lsu_strb_q  <= '0;
      load_type_q <= '0;
    end
    else begin
      lsu_state_q <= lsu_state_d;
      lsu_type_q  <= lsu_type_d;
      lsu_addr_q  <= lsu_addr_d;
      lsu_wdata_q <= lsu_wdata_d;
      lsu_strb_q  <= lsu_strb_d;
      load_type_q <= load_type_d;
    end
  end

  // DEBUG
  integer fp;
  initial begin
    fp = $fopen("./log/npc_lsu.log");
  end

  always_ff @(posedge clk_i) begin
    if (lsu_resp_fire && lsu_is_load) begin
      $fdisplay(fp, "[LOAD ] ADDR: %08x\t DATA: %08x\t", lsu_addr_q, lsu_rdata_i);
    end
    else if(lsu_resp_fire && lsu_is_store) begin
      $fdisplay(fp, "[STORE] ADDR: %08x\t DATA: %08x\t STRB: %4b\t", lsu_addr_q, lsu_wdata_q, lsu_strb_q);
    end
  end

endmodule