
import "DPI-C" function void inst_read(input int addr, output int rdata);

module ifu(
	output [31:0] pc_i,
	output [31:0] inst_o
);

	always@(*) begin
		inst_read(pc_i, inst_o);
	end


endmodule