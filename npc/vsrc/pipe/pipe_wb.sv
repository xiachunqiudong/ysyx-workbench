module pipe_wb import liang_pkg::*;
(
  input logic clk_i,
  input logic rst_i,
  // ex <> wb
  input exToWb_t exToWb_i,
  input logic    ex_valid_i,
  output logic   wb_ready_o,
  // wb > regfile
  output wb_req_t wb_req_o,
  // forward
  output logic       wb_fwd_valid_o,
  output logic [4:0] wb_fwd_rd_o,  
  output ele_t       wb_fwd_data_o
);
  
  pc_t     commit_pc;
  pc_t     dnpc;
  logic    wb_valid_d, wb_valid_q;
  exToWb_t exToWb_d,   exToWb_q;
  wire        commit_valid;
  logic       rd_wen;
  logic [4:0] rd;
  ele_t       rd_wdata;

  // commit every cycle
  assign commit_valid = wb_valid_q;
  assign wb_ready_o   = 1'b1;
  assign commit_pc    = exToWb_q.uop_info.pc;
  assign dnpc         = exToWb_q.dnpc;

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
      exToWb_q   <= '0;
    end begin
      wb_valid_q <= wb_valid_d;
      exToWb_q   <= exToWb_d;
    end
  end

  assign rd_wen   = commit_valid && exToWb_q.uop_info.rd_wen;
  assign rd       = exToWb_q.uop_info.rd;
  assign rd_wdata = exToWb_q.uop_info.fu_op == LOAD ? exToWb_q.lsu_res 
                                                    : exToWb_q.alu_res;
  assign wb_req_o = '{
    rd_wen:   rd_wen,
    rd:       rd,
    rd_wdata: rd_wdata
  };

  assign wb_fwd_valid_o = rd_wen;
  assign wb_fwd_rd_o    = rd;
  assign wb_fwd_data_o  = rd_wdata;

  // ebreak: stop the simulation
  // return pc
  import "DPI-C" function void env_ebreak(input int pc);

  // is this cycle has inst commit ?
  import "DPI-C" function void commit(input logic valid, input int pc, input int inst, input int dnpc);
  
  always_comb begin
    if(commit_valid && exToWb_q.uop_info.ebreak) begin
    	env_ebreak(commit_pc);
		end 
    else begin

    end
    
  end

  integer fp;
  initial begin
    fp = $fopen("./log/npc_wb.log");
  end

  always_comb begin
    commit(commit_valid, commit_pc, exToWb_q.uop_info.inst, dnpc);
    if (commit_valid) begin
      $fdisplay(fp, "PC: %08x commit, dnpc: %08x", commit_pc, dnpc);
    end
  end

endmodule