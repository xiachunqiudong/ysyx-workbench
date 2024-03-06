//
//
//

module ifu_icache_tag_array 
#(
  parameter INDEX_WIDTH = ,
  parameter TAG_WIDTH   = 59
)
(
  input                    clk_i,
  input                    rst_i,
  input  [INDEX_WIDTH-1:0] icache_index_i,
  input                    icache_tag_wen_i,
  input  [TAG_WIDTH-1:0]   icache_tag_wdata_i,
  output [TAG_WIDTH-1:0]   icache_tag_rdata_o
);

  fake_sram
  tag_array (
    .CLK (clk_i             ),
    .A   (icache_index_i    ),
    .D   (icache_tag_wdata_i),
    .WEN (icache_tag_wen_i  ),
    .Q   (icache_tag_rdata_o)
  );

endmodule