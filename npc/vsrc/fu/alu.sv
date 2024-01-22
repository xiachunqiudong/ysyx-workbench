module alu import liang_pkg::*;(
  input [XLEN-1:0]   rs1_i,
  input [XLEN-1:0]   rs2_i,
  input uop_info_t   uop_info_i,
  output [XLEN-1:0]  alu_res_o,
  output             jump_o
);

  //-----------ALU SIGNALS------------//
	logic [XLEN-1:0] src1;
	logic [XLEN-1:0] src2;
	logic [XLEN-1:0] imm;
  fu_op_e          fu_op;
  //-----------ADDER SIGNALS------------//
  logic            adder_sub;
  logic [XLEN-1:0] adder_src1;
  logic [XLEN-1:0] adder_src2;      
	logic [XLEN-1:0] adder_res;
  logic            adder_cout;
	
  logic [XLEN-1:0] sll_res;
	logic [XLEN-1:0] slt_res;
	logic [XLEN-1:0] sltu_res;
	logic [XLEN-1:0] xor_res;
	logic [XLEN-1:0] srl_res;
	logic [XLEN-1:0] sra_res;
	logic [XLEN-1:0] or_res;
	logic [XLEN-1:0] and_res;

  assign fu_op = uop_info_i.fu_op;
  assign imm   = uop_info_i.imm;
  
  assign src1 = (fu_op inside {AUIPC, JAL, JALR}) ? uop_info_i.pc :
                (uop_info_i.fu_op inside {LUI})   ? '0 :
                                                    rs1_i;

  assign src2 = (uop_info_i.fu_op inside {ALR, BRANCH}) ? rs2_i :
                (uop_info_i.fu_op inside {JAL, JALR})   ? 4 :
                                                          imm;



//------------adder------------
  assign adder_sub               = (uop_info_i.fu_func inside {SUB, SLT, SLTI, SLTU, SLTUI}) 
                                || (uop_info_i.fu_op == BRANCH);
  
  assign adder_src1              = src1;
  assign adder_src2              = {XLEN{adder_sub}} ^ src2;
	assign {adder_cout, adder_res} = adder_src1 + adder_src2 + {{XLEN-1{1'b0}}, adder_sub};
  
  assign sll_res  = src1 << src2[4:0];
  assign slt_res  = {{XLEN-1{1'b0}}, lt};
  assign sltu_res = {{XLEN-1{1'b0}}, ltu};
  assign xor_res  = src1 ^ src2;
  assign srl_res  = src1 >> src2[4:0];
  assign sra_res  = $signed(src1) >>> src2[4:0];
  assign or_res   = src1 | src2;
  assign and_res  = src1 & src2;

  always_comb begin
    alu_res_o = '0;
    if (uop_info_i.fu_op inside {[LOAD:LUI]} || uop_info_i.fu_func inside {ADD, ADDI, SUB}) begin
      alu_res_o = adder_res;
    end else if (uop_info_i.fu_func inside {SLL, SLLI}) begin
      alu_res_o = sll_res;
    end 
    else if (uop_info_i.fu_func inside {SLL, SLLI}) begin
      alu_res_o = sll_res;
    end
    else if (uop_info_i.fu_func inside {SLT, SLTI}) begin
      alu_res_o = slt_res;
    end
    else if (uop_info_i.fu_func inside {SLTU, SLTUI}) begin
      alu_res_o = sltu_res;
    end
    else if (uop_info_i.fu_func inside {XOR, XORI}) begin
      alu_res_o = xor_res;
    end
    else if (uop_info_i.fu_func inside {SRL, SRLI}) begin
      alu_res_o = srl_res;
    end
    else if (uop_info_i.fu_func inside {SRA, SRAI}) begin
      alu_res_o = sra_res;
    end
    else if (uop_info_i.fu_func inside {OR, ORI}) begin
      alu_res_o = or_res;
    end
    else if (uop_info_i.fu_func inside {AND, ANDI}) begin
      alu_res_o = and_res;
    end
  end

//---------------branch--------------------
  logic ne, eq, lt, ge, ltu, geu;
  
  assign ne  =  (|xor_res);
  assign eq  = ~ne;
  assign lt  = (src1[XLEN-1] & ~src2[XLEN-1]) | (~(src1[XLEN-1] ^ src2[XLEN-1]) & adder_res[XLEN-1]);
  assign ge  = ~lt | eq;
  assign ltu = ~adder_cout;
  assign geu = adder_cout | eq;

  always_comb begin
    jump_o = '0;  
    case(uop_info_i.fu_func)
      BEQ:     jump_o = eq;
      BNE:     jump_o = ne;
      BLT:     jump_o = lt;
      BGE:     jump_o = ge;
      BLTU:    jump_o = ltu;
      BGEU:    jump_o = geu;
      default: jump_o = '0;
    endcase
  end
  

endmodule