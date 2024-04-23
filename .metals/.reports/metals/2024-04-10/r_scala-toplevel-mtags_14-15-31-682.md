error id: file://<WORKSPACE>/higgs/src/main/scala/higgs/Elaborate.scala:[74..81) in Input.VirtualFile("file://<WORKSPACE>/higgs/src/main/scala/higgs/Elaborate.scala", "package higgs

import circt.stage._
import higgs.backend.regfile

object  extends App {
  println("Start Elaborate!")
  //def top = new Regfile(numReadPort: 4, dataWidth: 64, addrWidth: 5)
  //val generator = Seq(chisel3.stage.ChiselGeneratorAnnotation(() => top))
  //(new ChiselStage).execute(args, generator :+ CIRCTTargetAnnotation(CIRCTTarget.Verilog))
}
")
file://<WORKSPACE>/higgs/src/main/scala/higgs/Elaborate.scala
file://<WORKSPACE>/higgs/src/main/scala/higgs/Elaborate.scala:6: error: expected identifier; obtained extends
object  extends App {
        ^
#### Short summary: 

expected identifier; obtained extends