
module regfile import liang_pkg::*;
#(ADDR_WIDTH = 1, DATA_WIDTH = 1)
(
    input clk,
    // read
    input [ADDR_WIDTH-1:0]  rs1_raddr,
    input [ADDR_WIDTH-1:0]  rs2_raddr,
    output [DATA_WIDTH-1:0] rs1_rdata,
    output [DATA_WIDTH-1:0] rs2_rdata,
    // write
    input [DATA_WIDTH-1:0] wdata,
    input [ADDR_WIDTH-1:0] waddr,
    input                  wen,
    output [DATA_WIDTH-1:0] a0
);
    
    reg [DATA_WIDTH-1:0] rf [1:31];
    
    always @(posedge clk) begin
        if (wen) rf[waddr] <= wdata;
    end

    assign rs1_rdata = rs1_raddr == 5'b0 ? 0 : rf[rs1_raddr];
    assign rs2_rdata = rs2_raddr == 5'b0 ? 0 : rf[rs2_raddr];

    import "DPI-C" function void set_gpr_ptr(input logic [DATA_WIDTH-1:0] a[]);

    initial begin 
        set_gpr_ptr(rf);
    end

    assign a0 = rf[10];


endmodule