module pipe_wb import liang_pkg::*;
(
  input logic clk_i,
  input logic rst_i,
  // ex <> wb
  input exToWb_t exToWb_i,
  input logic    ex_valid_i,
  output logic   wb_ready_o,
  // wb > regfile
  output wb_req_t wb_req_o
);
  
  logic wb_valid_d, wb_valid_q;
  exToWb_t exToWb_d, exToWb_q;

  // commit every cycle
  assign wb_ready_o = 1'b1;

  always_comb begin
    wb_valid_d = wb_valid_q;
    exToWb_d   = exToWb_q;
    if(wb_ready_o) begin
      wb_valid_d = ex_valid_i;
      exToWb_d   = exToWb_i;
    end
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i || rst_i) begin
      wb_valid_q <= 1'b0;
    end begin
      wb_valid_q <= wb_valid_d;
      exToWb_q   <= exToWb_d;
    end
  end

  assign wb_req_o.rd_wen = exToWb_q.uop_info.rd_wen;
  assign wb_req_o.rd     = exToWb_q.uop_info.rd;

  assign wb_req_o.rd_wdata = exToWb_q.uop_info.fu_op == LOAD ? exToWb_q.lsu_res 
                                                             : exToWb_q.alu_res;



  // ebreak: stop the simulation
  // return pc and a0
  import "DPI-C" function void env_ebreak(input int pc);
  always_ff @(posedge clk_i) begin
    if(exToWb_q.uop_info.ebreak) begin
    	env_ebreak(exToWb_q.uop_info.pc);
		end
  end

endmodule