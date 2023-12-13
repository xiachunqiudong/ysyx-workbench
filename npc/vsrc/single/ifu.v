
import "DPI-C" function void inst_read(input int addr, output int rdata);

module ifu import liang_pkg::*;
(
	output pc_t   pc_i,
	output inst_t inst_o
);

	always@(*) begin
		inst_read(pc_i, inst_o);
	end


endmodule