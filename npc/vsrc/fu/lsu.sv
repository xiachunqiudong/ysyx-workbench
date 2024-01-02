module lsu import liang_pkg::*;
(
  input  logic     clk_i,
	// control signal
  input logic      valid_i,
  input uop_info_t uop_info_i,
	// data signal
	input  [XLEN-1:0] addr_i,
	input  [XLEN-1:0] wdata_i,
	output [XLEN-1:0] rdata_o
);

  logic is_load;
  logic is_store;
	logic [XLEN-1:0] ram_addr;
  assign is_load  = uop_info_i.fu_op == LOAD  && valid_i;
  assign is_store = uop_info_i.fu_op == STORE && valid_i;
	assign ram_addr = {addr_i[XLEN-1:2], 2'b0};
	
	// LOAD
	logic [XLEN-1:0] ram_rdata;
	always_comb begin
    if (is_load) begin
		  pmem_read(ram_addr, ram_rdata);
    end else
      ram_rdata = '0;
	end
	
	// LOAD BYTE
	wire [7:0] lb_data;
	MuxKey #(.NR_KEY(4), .KEY_LEN(2), .DATA_LEN(8))
  lb_mux(
      .out(lb_data),
      .key(addr_i[1:0]),
      .lut({
        2'b00, ram_rdata[7:0],
        2'b01, ram_rdata[15:8],
        2'b10, ram_rdata[23:16],
        2'b11, ram_rdata[31:24]
      })
  );

	wire [XLEN-1:0] lb_ext_data;
	wire [XLEN-1:0] lb_sext_data;
	assign lb_ext_data  = {{XLEN-8{1'b0}}, lb_data};
	assign lb_sext_data = {{XLEN-8{lb_data[7]}}, lb_data};

	// LOAD HALF
	wire [15:0] lh_data;
	MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(16))
  lh_mux(
      .out(lh_data),
      .key(addr_i[1]),
      .lut({
        1'b0, ram_rdata[15:0],
        1'b1, ram_rdata[31:16]
      })
  );

	wire [XLEN-1:0] lh_ext_data;
	wire [XLEN-1:0] lh_sext_data;
	assign lh_ext_data  = {{XLEN-16{1'b0}}, lh_data};
	assign lh_sext_data = {{XLEN-16{lh_data[15]}}, lh_data};
  
	MuxKey #(.NR_KEY(6), .KEY_LEN(3), .DATA_LEN(XLEN))
  rdata_mux(
      .out(rdata_o),
      .key(uop_info_i.load_type),
      .lut({
        LOAD_NONE, {XLEN{1'b0}},
        LOAD_LB,   lb_sext_data, // lb
        LOAD_LH,   lh_sext_data, // lh
        LOAD_LW,   ram_rdata,    // lw
        LOAD_LBU,  lb_ext_data,  // lbu
        LOAD_LHU,  lh_ext_data   // lhu
      })
  );

	// STORE
	wire [XLEN-1:0] ram_wdata;
	wire [3:0] ram_mask;
	always @(*) begin
		if(is_store) begin
			pmem_write(ram_addr, ram_wdata, {4'b0, ram_mask});
		end
	end

	// STORE BYTE
	wire [XLEN-1:0] sb_data;
	MuxKey #(.NR_KEY(4), .KEY_LEN(2), .DATA_LEN(XLEN))
  sb_mux(
    .out(sb_data),
    .key(addr_i[1:0]),
    .lut({
      2'b00, {8'b0,         8'b0,         8'b0,         wdata_i[7:0]},
      2'b01, {8'b0,         8'b0,         wdata_i[7:0], 8'b0},
      2'b10, {8'b0,         wdata_i[7:0], 8'b0,         8'b0},
      2'b11, {wdata_i[7:0], 8'b0,         8'b0,         8'b0}
    })
  );

	wire [3:0] sb_mask;
	MuxKey #(.NR_KEY(4), .KEY_LEN(2), .DATA_LEN(4))
  sb_mask_mux(
    .out(sb_mask),
    .key(addr_i[1:0]),
    .lut({
      2'b00, 4'b0001,
      2'b01, 4'b0010,
      2'b10, 4'b0100,
      2'b11, 4'b1000
    })
  );

	// STORE HALF
	wire [XLEN-1:0] sh_data;
	MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(XLEN))
  sh_mux(
    .out(sh_data),
    .key(addr_i[1]),
    .lut({
      1'b0, {16'b0,         wdata_i[15:0]},
      1'b1, {wdata_i[15:0], 16'b0}
    })
  );

	wire [3:0] sh_mask;
	MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(4))
  sh_mask_mux(
    .out(sh_mask),
    .key(addr_i[1]),
    .lut({
      1'b0, 4'b0011,
      1'b1, 4'b1100
    })
  );

	MuxKey #(.NR_KEY(4), .KEY_LEN(3), .DATA_LEN(XLEN))
  wdata_mux(
    .out(ram_wdata),
    .key(uop_info_i.store_type),
    .lut({
      STORE_NONE, {XLEN{1'b0}},
      STORE_SB,    sb_data, // sb
      STORE_SH,    sh_data, // sh
      STORE_SW,    wdata_i  // sw
    })
  );

	MuxKey #(.NR_KEY(4), .KEY_LEN(3), .DATA_LEN(4))
  wmask_mux(
    .out(ram_mask),
    .key(uop_info_i.store_type),
    .lut({
      STORE_NONE, 4'b0000,
      STORE_SB,   sb_mask, // sb
      STORE_SH,   sh_mask, // sh
      STORE_SW,   4'b1111  // sw
    })
  );

  // DEBUG
  integer fp;
  initial begin
    fp = $fopen("./log/npc_lsu.log");
  end

  always_ff @(posedge clk_i) begin
    if (uop_info_i.fu_op == LOAD) begin
      $fdisplay(fp, "[LOAD ] PC: %08x\t ADDR: %08x\t Data: %08x\t", uop_info_i.pc, addr_i, rdata_o);
    end
    else if(uop_info_i.fu_op == STORE) begin
      $fdisplay(fp, "[STORE] PC: %08x\t ADDR: %08x\t Data: %08x\t", uop_info_i.pc, addr_i, wdata_i);
    end
  end


endmodule