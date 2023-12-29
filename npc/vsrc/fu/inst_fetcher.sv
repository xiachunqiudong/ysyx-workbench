
import "DPI-C" function void inst_read(input int addr, output int rdata);

module inst_fetcher import liang_pkg::*;
(
	input  logic  clk_i,
	input  pc_t   pc_i,
	input  logic  if_valid_i,  
	output inst_t inst_o
);

	always_comb begin
		if (if_valid_i)
			inst_read(pc_i, inst_o);
		else
			inst_o = '0;
	end

endmodule