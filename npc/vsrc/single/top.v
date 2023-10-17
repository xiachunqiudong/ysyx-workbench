`include "defines.v"

module top(
    input clk_i,
    input rst_i,
    output [31:0] pc_o,
    input [31:0] instr_i
);

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [`XLEN-1:0] rs1_rdata;
    wire [`XLEN-1:0] rs2_rdata;
    wire [`XLEN-1:0] imm;
    wire ebreak;

    idu 
    idu_u(.instr(instr_i),
          .rs1(rs1),
          .rs2(rs2),
          .rd(rd),
          .imm(imm),
          .ebreak(ebreak));

    regfile #(.ADDR_WIDTH(5), .DATA_WIDTH(`XLEN)) 
    regfile_u(
        .clk(clk_i),
        .rs1_raddr(rs1),
        .rs2_raddr(rs2),
        .rs1_rdata(rs1_rdata),
        .rs2_rdata(rs2_rdata),
        .waddr(rd),
        .wdata(exu_out),
        .wen(1'b1)
    );

    wire [`XLEN-1:0] exu_out;

    exu
    exu_u(
        .src1(rs1_rdata),
        .src2(rs2_rdata),
        .imm(imm),
        .out(exu_out)
    );
    
    // ebreak: stop the simulation
    import "DPI-C" function void env_ebreak();
  always @(*) begin
    if(ebreak) begin
    	env_ebreak();
		end
  end

    


    assign pc_o = pc_r;

    reg [31:0] pc_r;

    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i)
            pc_r <= 0;
        else
            pc_r <= pc_r + 4;
    end


endmodule