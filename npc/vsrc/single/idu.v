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

  wire type_R;
  wire type_I;
  wire type_S;
  wire type_B;
  wire type_U;
  wire type_J;

  assign type_I = opcode == 7'b00100_11;

  // get op info
  assign ebreak = instr[31:20] == 12'b1 && instr[19:7] == 13'b0 && opcode == 7'b11100_11;

  wire lui;
  wire auipc;
  wire jal;
  wire jalr;
  wire branch;
  wire load;
  wire store;
  wire alu_i;
  wire alu_r;

  // branch
  wire beq; 
  wire bne;
  wire blt; 
  wire bge; 
  wire bltu;
  wire bgeu;

  assign lui    = opcode == 7'b01101_11;
  assign auipc  = opcode == 7'b00101_11;
  assign jal    = opcode == 7'b00101_11;
  assign jalr   = opcode == 7'b00101_11;
  assign branch = opcode == 7'b11000_11;
  assign load   = opcode == 7'b11000_11;
  assign store  = opcode == 7'b11000_11;
  assign alu_i  = opcode == 7'b00000_11;
  assign alu_r  = opcode == 7'b00000_11;

  // branch
  assign beq  = branch && fun3 == 3'b000;
  assign bne  = branch && fun3 == 3'b001;
  assign blt  = branch && fun3 == 3'b100;
  assign bge  = branch && fun3 == 3'b101;
  assign bltu = branch && fun3 == 3'b110;
  assign bgeu = branch && fun3 == 3'b111;
  // load



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