module pipe_idu import liang_pkg::*;
(
    input  logic      clk_i,
    input  logic      rst_i,
		input  logic      flush_i,
		// if-id
    input  ifToId_t   ifToId_i,
		input  logic      if_valid_i,
		output logic      id_ready_o,
		// id-ex
		output logic      id_valid_o,
		input  logic      ex_ready_i,
		output uop_info_t uop_info_o
);

	pc_t id_pc;
	assign id_pc = ifToId_q.pc;

	ifToId_t ifToId_d,   ifToId_q;
	logic    id_valid_d, id_valid_q;
	logic fire;

	// handshack success
	assign fire = id_valid_q && ex_ready_i;
	assign id_ready_o = fire || ~id_valid_q;
	assign id_valid_o = id_valid_q && ~flush_i;

	always_comb begin
		id_valid_d   = id_valid_q;
		ifToId_d     = ifToId_q;
		if (id_ready_o) begin
			id_valid_d = if_valid_i;
			ifToId_d   = ifToId_i;
		end 
	end

	always_ff @(posedge clk_i or posedge rst_i) begin
		if (rst_i) begin
			id_valid_q <= 1'b0;
			ifToId_q   <= '0;
		end
		else begin
			id_valid_q <= id_valid_d;
			ifToId_q   <= ifToId_d;
		end
	end

	decoder 
  u_decoder(
    .pc_i       (ifToId_q.pc),
    .inst_i     (ifToId_q.inst),
    .uop_info_o (uop_info_o)
  );


endmodule