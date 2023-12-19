
import "DPI-C" function void inst_read(input int addr, output int rdata);

module inst_fetcher import liang_pkg::*;
(
	input  pc_t   pc_i,
	output inst_t inst_o
);

	always@(*) begin
		inst_read(pc_i, inst_o);
	end

endmodule