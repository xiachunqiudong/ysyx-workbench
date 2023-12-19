module pipe_top import liang_pkg::*;
(
  input clk_i,
  input rst_i
);

  ifu
  ifu_u(
    .pc_i  (pc),
    .inst_o(inst)
  );

  




endmodule