error id: file://<WORKSPACE>/higgs/cpu/src/Regfile.scala:[27..32) in Input.VirtualFile("file://<WORKSPACE>/higgs/cpu/src/Regfile.scala", "import chisel3._

class 


class Regfile extends Module {
  val io = IO(new Bundle {
    val rs1_idx = Input(UInt(5.W))
    val rs1_rdata = Output(UInt(64.W))
    val rs2_idx = Input(UInt(5.W))
    val rs2_rdata = Output(UInt(64.W))
    val rd_vld = Input(Bool())
    val rd_idx = Input(UInt(5.W))
    val rd_wdata = Input(UInt(64.W))
  })

  val data_array = Reg(Vec(32, UInt(64.W)))

  when(io.rd_vld) {
    data_array(io.rd_idx) := io.rd_wdata
  }

  io.rs1_rdata := data_array(io.rs1_idx)
  io.rs2_rdata := data_array(io.rs2_idx)

}
")
file://<WORKSPACE>/higgs/cpu/src/Regfile.scala
file://<WORKSPACE>/higgs/cpu/src/Regfile.scala:6: error: expected identifier; obtained class
class Regfile extends Module {
^
#### Short summary: 

expected identifier; obtained class