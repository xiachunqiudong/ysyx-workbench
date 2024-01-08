module ifu_sram(
  input         clk_i,
  input         ren_i,
  input  [31:0] raddr_i,
  output [31:0] rdata_o
);

  logic [31:0] rdata_d, rdata_q;

  assign rdata_o = rdata_q;

  always_ff @(posedge clk_i) begin
    rdata_q <= rdata_d;
  end

  always_comb begin
    if (ren_i) begin
      pmem_read(raddr_i, rdata_d);
    end
    else begin
      rdata_d = '0;
    end
  end
  
endmodule