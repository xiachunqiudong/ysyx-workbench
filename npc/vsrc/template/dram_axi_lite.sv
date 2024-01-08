// DPI-C
import "DPI-C" function void pmem_read(input int raddr, output int rdate);
import "DPI-C" function void pmem_write(input int waddr, input int wdate, input byte wmask);

// AXI-LITE SLAVE
module dram_axi_lite
#(
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned ADDR_WIDTH  = 32,
  parameter int unsigned STRB_WIDTH = DATA_WIDTH/8
)
(
  input  logic clk_i,
  input  logic rst_i,
  // READ ARRD CHANNEL
  input  logic [ADDR_WIDTH-1:0] araddr_i,
  input  logic                  arvalid_i,
  output logic                  arready_o,
  // READ DATA CHANNEL
  output logic [DATA_WIDTH-1:0] rdata_o,
  output logic                  rvalid_o,
  input  logic                  rready_i,
  // WRITE ARRD CHANNEL
  input  logic [ADDR_WIDTH-1:0] awaddr_i,
  input  logic                  awvalid_i,
  output logic                  awready_o,
  // WRITE DATA CHANNEL
  input  logic [DATA_WIDTH-1:0] wdata_i,
  input  logic [STRB_WIDTH-1:0] wstrb_i,
  input  logic                  wvalid_i,
  output logic                  wready_o,
  // WRITE RESP CHANNEL
  output logic [1:0]            bresp_o,
  output logic                  bvalid_o,
  input  logic                  bready_i
);

  logic [3:0] read_cnt_d, read_cnt_q;
  logic can_read;

  //-----------READ------------//
  logic [DATA_WIDTH-1:0] rdata_d,  rdata_q;
  logic [ADDR_WIDTH-1:0] araddr_d, araddr_q;
  logic raddr_fire;
  logic rdata_fire;

  assign rdata_o = rdata_q;
  assign raddr_fire = arvalid_i && arready_o;
  assign rdata_fire = rvalid_o  && rready_i;

  assign araddr_d = raddr_fire ? araddr_i : araddr_q;

  assign read_cnt_d = raddr_fire || can_read   ? 0 :
                      read_state_q == READ_RUN ? read_cnt_q + 1 :
                                                 read_cnt_q;

  assign can_read = read_cnt_q == 10;

  typedef enum logic [1:0] {
    READ_IDEL, READ_RUN, READ_DONE
  } read_state_e;

  read_state_e read_state_d, read_state_q;

  assign arready_o = read_state_q == READ_IDEL;
  assign rvalid_o  = read_state_q == READ_DONE;

  // READ NEXT STATE
  always_comb begin
    read_state_d = read_state_q;
    case(read_state_q)
      READ_IDEL: read_state_d = raddr_fire ? READ_RUN : READ_IDEL;
      READ_RUN:  read_state_d = can_read   ? READ_DONE : READ_RUN;
      READ_DONE: read_state_d = rdata_fire ? READ_IDEL : READ_DONE;
      default:   read_state_d = READ_IDEL;
    endcase
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      read_state_q  <= READ_IDEL;
      rdata_q       <= '0;
      araddr_q      <= '0;
      read_cnt_q    <= '0;
    end
    else begin
      read_state_q  <= read_state_d;
      rdata_q       <= rdata_d;
      araddr_q      <= araddr_d;
      read_cnt_q    <= read_cnt_d;
    end
  end
  
  always_comb begin
    if (read_state_q == READ_RUN && can_read) begin
      pmem_read(araddr_q, rdata_d);
    end else begin
      rdata_d = rdata_q;
    end
  end
  
  //-----------WRITE------------//
  logic waddr_fire;
  logic wdata_fire;
  logic bresp_fire;
  logic waddr_valid_d, waddr_valid_q;
  logic wdata_valid_d, wdata_valid_q;
  logic [ADDR_WIDTH-1:0] waddr_d, waddr_q;
  logic [DATA_WIDTH-1:0] wdata_d, wdata_q;

  assign waddr_fire = awvalid_i && awready_o;
  assign wdata_fire = wvalid_i  && wready_o;
  assign bresp_fire = bvalid_o  && bready_i;

  assign waddr_valid_d = waddr_fire ? 1 :
                         bresp_fire ? 0 :
                                      waddr_valid_q;
  
  assign wdata_valid_d = wdata_fire ? 1 :
                         bresp_fire ? 0 :
                                      waddr_valid_q;
  
  assign waddr_d = waddr_fire ? awaddr_i : awaddr_q;
  assign wdata_d = wdata_fire ? wdata_i  : wdata_q;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      waddr_valid_q <= '0;
      wdata_valid_q <= '0;
      waddr_q       <= '0;
      wdata_q       <= '0;
    end
    else begin
      waddr_valid_q <= waddr_valid_d;
      wdata_valid_q <= wdata_valid_d;
      waddr_q       <= waddr_d;
      wdata_q       <= wdata_d;    
    end
  end

  //-----------LSFR------------//
  logic [3:0] lat;
  lfsr
  u_lfsr(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .data_o (lat)
  );

  //-----------DEBUG------------//
  integer fp;
  initial begin
    fp = $fopen("./log/npc_axi_lite.log");
  end
  always_ff @(posedge clk_i) begin
    $fdisplay(fp, "lat: %d", lat);
    if (read_state_q == READ_RUN) begin
      $fdisplay(fp, "read addr: %08x", araddr_q);
    end
  end

endmodule