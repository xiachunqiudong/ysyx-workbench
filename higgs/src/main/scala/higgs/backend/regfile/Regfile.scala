package higgs.backend.regfile

import chisel3._

class RfReadPort(dataWidth: Int, addrWidth: Int) extends Bundle {
  val addr = Input(UInt(addrWidth.W))
  val data = Output(UInt(dataWidth.W))
}

class Regfile (
  numReadPort: Int,
  dataWidth: Int,
  addrWidth: Int
) extends Module {
  
  val io = IO(new Bundle {
    val read_ports = Vec(numReadPort, new RfReadPort(dataWidth, addrWidth))
    val rd_vld = Input(Bool())
    val rd_idx = Input(UInt(5.W))
    val rd_wdata = Input(UInt(64.W))
  })

  val data_array = Reg(Vec(32, UInt(64.W)))

  when(io.rd_vld) {
    data_array(io.rd_idx) := io.rd_wdata
  }

  for(rp <- io.read_ports) {
    rp.data := data_array(rp.addr)
  }

}
