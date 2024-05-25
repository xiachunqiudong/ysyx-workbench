module csr #(
  parameter XLEN = 32
)
(
  input  logic            clk_i,
  input  logic            rst_i,
  // For CSRRW/CSRRC/CSRRS
  input  logic [11:0]     csr_id,
  input  logic            csr_wen,
  input  logic [XLEN-1:0] csr_wdata,
  output logic [XLEN-1:0] csr_rdata,
  // For Riscv Trap
  input  logic [XLEN-1:0] trap_handler_mepc_wdata,
  input  logic            trap_handler_mepc_wen,
  output logic [XLEN-1:0] csr_mtvec_rdata,
  output logic [XLEN-1:0] csr_mepc_rdata
);

  logic mtvec_update;
  logic mepc_update;
  
  logic [XLEN-1:0] mtvec_d, mtvec_q;
  logic [XLEN-1:0] mepc_d,  mepc_q;

  assign mtvec_update = trap_handler_mepc_wen;
  assign mepc_update  = csr_wen && csr_id == 12'h305;

  assign mepc_d  = mepc_update  ? trap_handler_mepc_wdata : mepc_q;
  assign mtvec_d = mtvec_update ? csr_wdata : mtvec_q;
  
  assign csr_mepc_rdata  = mepc_q;
  assign csr_mtvec_rdata = mtvec_q;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      mtvec_q <= '0;
      mepc_q  <= '0;
    end
    else begin
      mtvec_q <= mtvec_d;
      mepc_q  <= mepc_d;
    end
  end

endmodule
