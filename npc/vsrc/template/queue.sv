
module queue 
import liang_pkg::*;
#(
	parameter int unsigned DEPTH     = 8,
	parameter int unsigned PTR_WIDTH = $clog2(DEPTH)
)
(
	input logic clk_i,
	input logic rst_i,
	input logic push,
	input logic pop,
	input logic [3:0] data_in,
	output logic [3:0] data_out
);

	typedef struct packed {
		logic                 flag;
		logic [PTR_WIDTH-1:0] value; 
	} ptr_t;

	logic empty, full;
	ptr_t head_ptr_d, head_ptr_q;
	ptr_t tail_ptr_d, tail_ptr_d;

	logic [3:0] [DEPTH-1:0] data_queue_d, data_queue_q;

	assign data_out = data_queue_q[tail_ptr_q.value];
	
	assign empty    = head_ptr_q == tail_ptr_q;
	
	assign full     = (head_ptr_q.flag  ^  tail_ptr_q.flag) 
	                & (head_ptr_q.value == tail_ptr_q.value);
	
	//-------- update ptr ----------//
	always_comb begin
		head_ptr_d = head_ptr_q;
		tail_ptr_d = tail_ptr_q;
		
		if (push && ~full) begin
			data_queue_d[head_ptr_q] = data_in;
			head_ptr_d = head_ptr_q + 1;
		end

		if (pop && ~empty) begin
			tail_ptr_d = tail_ptr_q + 1;
		end

	end

	always_ff @(posedge clk_i or posedge rst_i) begin
		if (rst_i) begin
			head_ptr_q   <= '0;
			tail_ptr_q   <= '0;
			data_queue_q <= '0;
		end else begin
			head_ptr_q   <= head_ptr_d;
			tail_ptr_q   <= tail_ptr_q;
			data_queue_q <= data_queue_d;
		end
	end

endmodule