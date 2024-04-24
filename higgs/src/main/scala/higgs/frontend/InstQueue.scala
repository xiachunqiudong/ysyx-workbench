import chisel3._

class IQ_Entry extends bundle {
  val inst = UInt(32.W)
  val pc   = UInt(VADDR_WIDTH.W)
}