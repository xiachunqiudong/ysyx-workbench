module fake_sram
#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 10
)
(
  input                       CLK ,
  input      [ADDR_WIDTH-1:0] A   ,
  input      [DATA_WIDTH-1:0] D   ,  
  input      [DATA_WIDTH-1:0] WEN ,  
  output reg [DATA_WIDTH-1:0] Q 
);

  reg [DATA_WIDTH-1:0] data_array [ADDR_WIDTH-1:0];

  always @(posedge CLK) begin
    Q <= data_array[A];
  end 

  always @(posedge CLK) begin
    if (WEN) begin
      data_arrayata[A] <= D;
    end
  end  

endmodule