module inst_fetcher import liang_pkg::*;
(
	input  logic  clk_i,
	input  logic  rst_i,
	input  logic  flush_i,
	
	input  logic  if_req_valid_i, 
	input  pc_t   if_req_pc_i,
	
	output inst_t if_resp_inst_o,
	output logic  if_resp_valid_o
);

	// IFU FSM
	typedef enum logic [1:0] {
		IFU_IDEL, IFU_RUN, IFU_DONE
	} ifu_state_e;

	ifu_state_e state_d, state_q;
	logic       ren;

	assign if_resp_valid_o = (state_q == IFU_DONE);
	assign ren             = (state_q == IFU_RUN);

	always_comb begin
		state_d = state_q;
		case(state_q)
			IFU_IDEL: begin
				state_d = if_req_valid_i ? IFU_RUN : IFU_IDEL;
			end
			IFU_RUN: begin
				state_d = flush_i ? IFU_RUN : IFU_DONE;
			end
			IFU_DONE: begin
				state_d = IFU_RUN;
			end
			default: state_d = IFU_IDEL;
		endcase
	end

	always_ff @(posedge clk_i or posedge rst_i) begin
		if (rst_i) begin
			state_q <= IFU_IDEL;
		end
		else begin
			state_q <= state_d;
		end
	end

	ifu_sram
	u_ifu_sram(
		.clk_i   (clk_i),
		.ren_i   (ren),
		.raddr_i (if_req_pc_i),
		.rdata_o (if_resp_inst_o)
	);

endmodule