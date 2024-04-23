error id: file://<WORKSPACE>/higgs/src/higgs/top/Elaborate.scala:[16..22) in Input.VirtualFile("file://<WORKSPACE>/higgs/src/higgs/top/Elaborate.scala", "package higgs.

import circt.stage._
import higgs.backend.regfile

object Elaborate extends App {
  def top = new Regfile(numReadPort: 4, dataWidth: 64, addrWidth: 5)
  val generator = Seq(chisel3.stage.ChiselGeneratorAnnotation(() => top))
  (new ChiselStage).execute(args, generator :+ CIRCTTargetAnnotation(CIRCTTarget.Verilog))
}
")
file://<WORKSPACE>/higgs/src/higgs/top/Elaborate.scala
file://<WORKSPACE>/higgs/src/higgs/top/Elaborate.scala:3: error: expected identifier; obtained import
import circt.stage._
^
#### Short summary: 

expected identifier; obtained import