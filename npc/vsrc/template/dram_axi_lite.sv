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

  typedef enum logic [1:0] {
    READ_IDEL, READ_WAIT, READ_RUN, READ_DONE
  } read_state_e;

  typedef enum logic [1:0] {
    WRITE_IDEL, WRITE_WAIT, WRITE_RUN, WRITE_DONE
  } write_state_e;

  //-----------LSFR SIGNALS------------//
  logic [3:0] lat;
  logic [3:0] lsfr_cnt_d, lsfr_cnt_q;
  logic       lsfr_done;
  logic       lsfr_cnt_init;
  logic       lsfr_cnt_run;

  //-----------READ SIGNALS------------//
  read_state_e           read_state_d, read_state_q;
  logic [DATA_WIDTH-1:0] rdata_d,  rdata_q;
  logic [ADDR_WIDTH-1:0] araddr_d, araddr_q;
  logic                  raddr_valid_d, raddr_valid_q;
  logic                  raddr_fire;
  logic                  rdata_fire;
  
  //-----------WRITE SIGNALS------------//
  write_state_e          write_state_d, write_state_q;
  logic                  waddr_fire;
  logic                  wdata_fire;
  logic                  write_both_ok;
  logic                  bresp_fire;
  logic                  waddr_valid_d, waddr_valid_q;
  logic                  wdata_valid_d, wdata_valid_q;
  logic [ADDR_WIDTH-1:0] waddr_d, waddr_q;
  logic [DATA_WIDTH-1:0] wdata_d, wdata_q;
  logic [STRB_WIDTH-1:0] wstrb_d, wstrb_q;

  //-----------READ------------//
  assign rdata_o       = rdata_q;
  assign raddr_fire    = arvalid_i && arready_o;
  assign rdata_fire    = rvalid_o  && rready_i;
  
  assign raddr_valid_d = raddr_fire ? 1'b1 :
                         rdata_fire ? 1'b0 :
                         raddr_valid_q;

  assign araddr_d      = raddr_fire ? araddr_i : araddr_q;
  assign arready_o     = read_state_q == READ_IDEL;
  assign rvalid_o      = read_state_q == READ_DONE;

  // READ NEXT STATE
  always_comb begin
    read_state_d = read_state_q;
    case(read_state_q)
      READ_IDEL: read_state_d = arvalid_i     ? READ_WAIT : READ_IDEL;
      READ_WAIT: read_state_d = raddr_valid_q ? READ_RUN  : READ_WAIT;
      READ_RUN:  read_state_d = lsfr_done     ? READ_DONE : READ_RUN;
      READ_DONE: read_state_d = rdata_fire    ? READ_IDEL : READ_DONE;
      default:   read_state_d = READ_IDEL;
    endcase
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      read_state_q  <= READ_IDEL;
      rdata_q       <= '0;
      araddr_q      <= '0;
      raddr_valid_q <= '0;
      lsfr_cnt_q    <= '0;
    end
    else begin
      read_state_q  <= read_state_d;
      rdata_q       <= rdata_d;
      araddr_q      <= araddr_d;
      raddr_valid_q <= raddr_valid_d;
      lsfr_cnt_q    <= lsfr_cnt_d;
    end
  end
    
  //-----------WRITE------------//
  assign awready_o  = !waddr_valid_q;
  assign wready_o   = !wdata_valid_q;
  assign bvalid_o   = write_state_q == WRITE_DONE;
  assign waddr_fire = awvalid_i && awready_o;
  assign wdata_fire = wvalid_i  && wready_o;
  assign bresp_fire = bvalid_o  && bready_i;

  assign waddr_valid_d = waddr_fire ? 1 :
                         bresp_fire ? 0 :
                                      waddr_valid_q;
  
  assign wdata_valid_d = wdata_fire ? 1 :
                         bresp_fire ? 0 :
                                      wdata_valid_q;
                              
  assign waddr_d       = waddr_fire ? awaddr_i : waddr_q;
  assign wdata_d       = wdata_fire ? wdata_i  : wdata_q;
  assign wstrb_d       = wdata_fire ? wstrb_i  : wstrb_q;
  assign write_both_ok = waddr_valid_q && wdata_valid_q;

  always_comb begin
    case(write_state_q)
      WRITE_IDEL: write_state_d = (awvalid_i || wvalid_i) ? WRITE_WAIT : WRITE_IDEL;
      WRITE_WAIT: write_state_d = write_both_ok           ? WRITE_RUN  : WRITE_WAIT;
      WRITE_RUN:  write_state_d = lsfr_done               ? WRITE_DONE : WRITE_RUN;
      WRITE_DONE: write_state_d = bresp_fire              ? WRITE_IDEL : WRITE_DONE;
      default:    write_state_d = WRITE_IDEL;
    endcase
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      waddr_valid_q <= '0;
      wdata_valid_q <= '0;
      waddr_q       <= '0;
      wdata_q       <= '0;
      wstrb_q       <= '0;
      write_state_q <= WRITE_IDEL;
    end
    else begin
      waddr_valid_q <= waddr_valid_d;
      wdata_valid_q <= wdata_valid_d;
      waddr_q       <= waddr_d;
      wdata_q       <= wdata_d; 
      wstrb_q       <= wstrb_d;
      write_state_q <= write_state_d;   
    end
  end

  //-----------LSFR------------//
  lfsr
  u_lfsr(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .data_o (lat)
  );
  assign lsfr_cnt_init = raddr_fire || (write_state_q == WRITE_WAIT && write_state_d == WRITE_RUN);
  assign lsfr_cnt_run  = read_state_q == READ_RUN || write_state_q == WRITE_RUN;
 
  assign lsfr_cnt_d    = lsfr_cnt_init ? lat :
                         lsfr_cnt_run  ? lsfr_cnt_q - 1 :
                                         lsfr_cnt_q;

  assign lsfr_done     = lsfr_cnt_run && (lsfr_cnt_q == 0);

  //-----------DPIC------------//
  always_comb begin
    if (read_state_q == READ_RUN && lsfr_done) begin
      pmem_read(araddr_q, rdata_d);
    end else begin
      rdata_d = rdata_q;
    end
  end

  always_ff @(posedge clk_i) begin
    if(write_state_q == WRITE_RUN && lsfr_done) begin
      pmem_write(waddr_q, wdata_q, {4'b0, wstrb_q});
    end
  end

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