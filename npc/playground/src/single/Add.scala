package single

import chisel3._

class Add extends Module {
  val io = IO(new Bundle {
    val in  = Input(Bool())
    val out = Output(Bool())
  })

  io.out := !io.in

}
