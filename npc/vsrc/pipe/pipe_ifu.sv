module pipe_ifu import liang_pkg::*;
(
  input  logic                  clk_i,
  input  logic                  rst_i,
  input  logic                  flush_i,
  input  pc_t                   flush_pc_i,
  // IFU <> AXI LITE ARBITER
  output logic [ADDR_WIDTH-1:0] ifu_araddr_o,
  output logic                  ifu_arvalid_o,
  input  logic                  ifu_arready_i,
  input  logic                  ifu_rvalid_i,
  input  logic [DATA_WIDTH-1:0] ifu_rdata_i,
  output logic                  ifu_rready_o, 
  // IF <> ID
  output ifToId_t               ifToId_o,
  output logic                  if_valid_o,
  input  logic                  id_ready_i
);

  parameter READ_IDEL      = 2'b00;
  parameter READ_SEND_ADDR = 2'b01;
  parameter READ_WAIT_DATA = 2'b10;
  parameter READ_DONE      = 2'b11;

  logic        instBuf_allowIn;
  logic        instBuf_read;
  logic        instBuf_write;
  logic        instBuf_valid_In;
  logic        instBuf_valid_Q;
  logic [31:0] instBuf_Q;
  logic [31:0] instBuf_In;
  
  logic readAddrFire;
  logic readDataFire;

  logic [1:0] readState_In;
  logic [1:0] readState_Q;

  pc_t   pc_d, pc_q;
  logic  if_fire;
  logic  if_inst_valid;
  inst_t if_inst;
 
  assign ifToId_o.pc   = pc_q;
  assign ifToId_o.inst = if_inst;

  assign ifu_araddr_o  = pc_q;
  assign ifu_rready_o  = instBuf_allowIn;
  assign if_inst[31:0] = instBuf_Q[31:0];

  assign if_valid_o    = ~flush_i & instBuf_valid_Q & (readState_Q == READ_DONE);
  assign if_fire       = if_valid_o & id_ready_i;

  assign pc_d = flush_i ? flush_pc_i 
                        : (pc_q + 4);
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
      pc_q <= 32'h2000_0000;
    end
    else if(instBuf_write || flush_i) begin
      pc_q <= pc_d;
    end
  end

//========================================================
//                 IFU AXI Read Interface
//========================================================  
  assign readAddrFire = ifu_arvalid_o & ifu_arready_i;
  assign readDataFire = ifu_rvalid_i  & ifu_rready_o;

  always_comb begin
    readState_In = readState_Q;
    case(readState_Q) 
      READ_IDEL:      readState_In = READ_SEND_ADDR;
      READ_SEND_ADDR: readState_In = readAddrFire  ? READ_WAIT_DATA : READ_SEND_ADDR;
      READ_WAIT_DATA: readState_In = readDataFire  ? READ_DONE : READ_WAIT_DATA;
      READ_DONE:      readState_In = instBuf_write ? READ_SEND_ADDR : READ_DONE;
      default:        readState_In = READ_IDEL;
    endcase
  end
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      readState_Q <= READ_IDEL;
    end
    else begin
      readState_Q <= readState_In;
    end
  end
  
  assign instBuf_read    =  readDataFire;
  assign instBuf_write   =  instBuf_valid_Q & id_ready_i;
  assign instBuf_allowIn = ~instBuf_valid_Q | instBuf_write;

  assign ifu_arvalid_o    = readState_Q == READ_SEND_ADDR;
  assign if_inst_valid    = readState_Q == READ_DONE;
  assign instBuf_In[31:0] = ifu_rdata_i[31:0];

  assign instBuf_valid_In = flush_i       ? 1'b0
                          : instBuf_read  ? 1'b1
                          : instBuf_write ? 1'b0
                          : instBuf_valid_Q;

   always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      instBuf_valid_Q <= 1'b0;
      instBuf_Q[31:0] <= 32'b0;
    end
    else begin
      instBuf_valid_Q <= instBuf_valid_In;
      instBuf_Q[31:0] <= instBuf_In[31:0];
    end
  end 


//========================================================
//                 Performance Count
//========================================================
`ifdef DEBUG
  integer fp;
  initial begin
    fp = $fopen("/home/x/project/chip/ysyx-workbench/npc/log/npc_ifu.log");
    $fdisplay("IFU Performance Coun is on.");
  end

  logic [9:0] ifu_cnt;
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      ifu_cnt <= '0;
    end
    else if (if_fire) begin
      ifu_cnt <= '0;
    end
    else begin
      ifu_cnt <= ifu_cnt + 1;
    end
  end

  always_ff @(posedge clk_i) begin
    if (if_fire) begin
      $fdisplay(fp, "[IFU] {PC: %08x, Inst: %08x, Cycle: %0d}", pc_q, if_inst, ifu_cnt);
    end
  end
`endif


endmodule