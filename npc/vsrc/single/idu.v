`include "defines.v"

module idu(
    input [31:0] instr,
    // op number
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [`XLEN-1:0] imm,
    // op info
    output ebreak
);
	

    // get op number
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];
    
    wire [6:0] fun7;
    wire [2:0] fun3;
    wire [6:0] opcode;

    assign fun7   = instr[31:25];
    assign fun3   = instr[14:12];
    assign opcode = instr[6:0];

    wire type_I;
    assign type_I = opcode == 7'b00100_11;

    // get op info
    assign ebreak = instr[31:20] == 12'b1 && instr[19:7] == 13'b0 && opcode == 7'b11100_11;

    // ALU-I
    // ALU-R
    // LOAD
    // STORE
    // BRANCH
    // JAL



    // get imm
    wire [`XLEN-1:0] imm_I;
    wire [`XLEN-1:0] imm_S;

    assign imm_I = {{`XLEN-12{instr[31]}}, instr[31:20]};
    assign imm_S = `XLEN'b0;

    // imm MUX
    MuxKey #(.NR_KEY(2), .KEY_LEN(1), .DATA_LEN(`XLEN))
    imm_mux(
        .out(imm),
        .key(type_I),
        .lut({
            1'b1, imm_I,
            1'b0, imm_S
        })
    );


endmodule