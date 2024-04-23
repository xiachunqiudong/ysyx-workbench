file://<WORKSPACE>/higgs/cpu/src/Regfile.scala
### java.lang.IndexOutOfBoundsException: 0

occurred in the presentation compiler.

presentation compiler configuration:
Scala version: 3.3.1
Classpath:
<HOME>/.cache/coursier/v1/https/repo1.maven.org/maven2/org/scala-lang/scala3-library_3/3.3.1/scala3-library_3-3.3.1.jar [exists ], <HOME>/.cache/coursier/v1/https/repo1.maven.org/maven2/org/scala-lang/scala-library/2.13.10/scala-library-2.13.10.jar [exists ]
Options:



action parameters:
offset: 410
uri: file://<WORKSPACE>/higgs/cpu/src/Regfile.scala
text:
```scala
import chisel3._

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

  when(rd_vld) {
    data_array()@@
  }


}

```



#### Error stacktrace:

```
scala.collection.LinearSeqOps.apply(LinearSeq.scala:131)
	scala.collection.LinearSeqOps.apply$(LinearSeq.scala:128)
	scala.collection.immutable.List.apply(List.scala:79)
	dotty.tools.dotc.util.Signatures$.countParams(Signatures.scala:501)
	dotty.tools.dotc.util.Signatures$.applyCallInfo(Signatures.scala:186)
	dotty.tools.dotc.util.Signatures$.computeSignatureHelp(Signatures.scala:94)
	dotty.tools.dotc.util.Signatures$.signatureHelp(Signatures.scala:63)
	scala.meta.internal.pc.MetalsSignatures$.signatures(MetalsSignatures.scala:17)
	scala.meta.internal.pc.SignatureHelpProvider$.signatureHelp(SignatureHelpProvider.scala:51)
	scala.meta.internal.pc.ScalaPresentationCompiler.signatureHelp$$anonfun$1(ScalaPresentationCompiler.scala:398)
```
#### Short summary: 

java.lang.IndexOutOfBoundsException: 0