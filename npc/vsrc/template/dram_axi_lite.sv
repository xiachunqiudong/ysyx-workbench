// DPI-C
import "DPI-C" function void pmem_read(input int raddr, output int rdate);
import "DPI-C" function void pmem_write(input int waddr, input int wdate, input byte wmask);

// AXI-LITE SLAVE
module dram_axi_lite
#(
  parameter int unsigned DATA_WIDTH = 32,
  parameter int unsigned ADDR_WIDTH = 32
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
  input  logic [3:0]            wstrb_i,
  input  logic [3:0]            wvalid_i,
  output logic                  wready_o,
  // WRITE RESP CHANNEL
  output logic                  bresp_o,
  output logic                  bvalid_o,
  input  logic                  bready_i
);

  
  //-----------READ------------//
  logic [DATA_WIDTH-1:0] rdata_d,  rdata_q;
  logic [ADDR_WIDTH-1:0] araddr_d, araddr_q;
  logic raddr_fire;
  logic read_fire;

  assign rdata_o = rdata_q;
  assign raddr_fire = arvalid_i && arready_o;
  assign rdata_fire = rvalid_o  && rready_i;

  assign araddr_d = raddr_fire ? araddr_i : araddr_q;

  typedef enum logic [2:0] {
    READ_IDEL, READ_RUN, READ_DONE
  } read_state_e;

  read_state_e read_state_d, read_state_q;

  assign arready_o = state_q == IDEL;
  assign rvalid_o  = state_q == READ_DONE;

  // READ NEXT STATE
  always_comb begin
    read_state_d = read_state_q;
    case(read_state_q)
      READ_IDEL: read_state_d = raddr_fire ? READ : IDEL;
      READ_RUN:  read_state_d = READ_DONE;
      READ_DONE: read_state_d = rdata_fire ? IDEL : READ_DONE;
      default:   read_state_d = IDEL;
    endcase
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state_q  <= IDEL;
      rdata_q  <= '0;
      araddr_q <= '0;
    end
    else begin
      state_q  <= state_d;
      rdata_q  <= rdata_d;
      araddr_q <= araddr_d;
    end
  end
  
  always_comb begin
    if (state_q == READ) begin
      pmem_read(araddr_q, rdata_d);
    end else begin
      rdata_d = rdata_q;
    end
  end
  
  //-----------WRITE------------//

  



endmodule