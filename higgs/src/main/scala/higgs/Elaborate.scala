package higgs

import circt.stage._
import higgs.gadd._

object Elaborate extends App {
  println("Start Elaborate!")
  def top = new VGaddModule()
  val generator = Seq(chisel3.stage.ChiselGeneratorAnnotation(() => top))
  (new ChiselStage).execute(args, generator :+ CIRCTTargetAnnotation(CIRCTTarget.Verilog))
}
