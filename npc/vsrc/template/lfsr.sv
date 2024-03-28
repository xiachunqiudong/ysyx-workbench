module lfsr(
  input  logic       clk_i,
  input  logic       rst_i,
  output logic [3:0] data_o
);

  logic [3:0] data_d, data_q;

  assign data_d[0] = data_q[3];
  assign data_d[1] = data_q[0] ^ data_q[3];
  assign data_d[2] = data_q[1] ^ data_q[3];
  assign data_d[3] = data_q[2];
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i)
      data_q <= 4'b1111;
    else
      data_q <= data_d;
  end

  assign data_o = {2'b00, data_q[1:0]};

endmodule