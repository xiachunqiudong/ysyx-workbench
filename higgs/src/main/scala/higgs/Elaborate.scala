package higgs

import circt.stage._
import higgs.backend.regfile._

object Elaborate extends App {
  println("Start Elaborate!")
  def top = new Regfile(4, 64, 5)
  val generator = Seq(chisel3.stage.ChiselGeneratorAnnotation(() => top))
  (new ChiselStage).execute(args, generator :+ CIRCTTargetAnnotation(CIRCTTarget.Verilog))
}
