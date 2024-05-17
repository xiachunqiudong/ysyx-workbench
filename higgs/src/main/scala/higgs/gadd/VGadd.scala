package higgs.gadd

import chisel3._
import chisel3.util._

class unsignedAddSub(width: Int = 32) extends Module {
  val io = IO(new Bundle() {
    val addA = Input(UInt(width.W))
    val addB = Input(UInt(width.W))
    val addC = Input(UInt(1.W)) //进位或借位
    val op = Input(UInt(1.W))  //00：加法，01：减法
    val wResult = Output(UInt((width + 1).W))
  })
  val waddA = Wire(UInt(width.W + 1))
  val waddB = Wire(UInt(width.W + 1))
  val waddC = Wire(UInt(width.W + 1))
  waddA := Cat(0.U(1.W), io.addA)
  waddB := Cat(0.U(1.W), io.addB)
  waddC := Cat(0.U(width.W), io.addC)

  when (io.op === "b0".U) {
    io.wResult := waddA + waddB + io.addC
  }.otherwise{
    io.wResult := waddA - waddB - io.addC
  }
}

class vadd_vsub_m_c_m_Unit extends Module {
  //vadd、vsub、vadc、vmadc、vmadc.m、vsbc、vmsbc、vmsbc.m指令
  val io = IO(new Bundle() {
    val gaddDataA = Input(UInt(64.W))
    val gaddDataB = Input(UInt(64.W))
    val gaddDataC = Input(UInt(8.W))
    val gaddDataWdith = Input(UInt(2.W))
    val op = Input(UInt(1.W)) //0：加法，1：减法，带进位的加减包含其中
    val carryOut = Input(UInt(1.W)) //0：输出加减法结果不输出进位，1：输出进位不输出实际结果
    val gaddResult = Output(UInt(64.W))
  })
  io.gaddResult := 0.U
  when (io.gaddDataWdith === "b00".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(8))
    val signedAddUnit2 = Module(new unsignedAddSub(8))
    val signedAddUnit3 = Module(new unsignedAddSub(8))
    val signedAddUnit4 = Module(new unsignedAddSub(8))
    val signedAddUnit5 = Module(new unsignedAddSub(8))
    val signedAddUnit6 = Module(new unsignedAddSub(8))
    val signedAddUnit7 = Module(new unsignedAddSub(8))
    val signedAddUnit8 = Module(new unsignedAddSub(8))

    signedAddUnit1.io.op := io.op
    signedAddUnit2.io.op := io.op
    signedAddUnit3.io.op := io.op
    signedAddUnit4.io.op := io.op
    signedAddUnit5.io.op := io.op
    signedAddUnit6.io.op := io.op
    signedAddUnit7.io.op := io.op
    signedAddUnit8.io.op := io.op

    signedAddUnit1.io.addC := io.gaddDataC(0)
    signedAddUnit2.io.addC := io.gaddDataC(1)
    signedAddUnit3.io.addC := io.gaddDataC(2)
    signedAddUnit4.io.addC := io.gaddDataC(3)
    signedAddUnit5.io.addC := io.gaddDataC(4)
    signedAddUnit6.io.addC := io.gaddDataC(5)
    signedAddUnit7.io.addC := io.gaddDataC(6)
    signedAddUnit8.io.addC := io.gaddDataC(7)

    signedAddUnit1.io.addA := io.gaddDataA(7, 0)
    signedAddUnit1.io.addB := io.gaddDataB(7, 0)
    signedAddUnit2.io.addA := io.gaddDataA(15, 8)
    signedAddUnit2.io.addB := io.gaddDataB(15, 8)
    signedAddUnit3.io.addA := io.gaddDataA(23, 16)
    signedAddUnit3.io.addB := io.gaddDataB(23, 16)
    signedAddUnit4.io.addA := io.gaddDataA(31, 24)
    signedAddUnit4.io.addB := io.gaddDataB(31, 24)
    signedAddUnit5.io.addA := io.gaddDataA(39, 32)
    signedAddUnit5.io.addB := io.gaddDataB(39, 32)
    signedAddUnit6.io.addA := io.gaddDataA(47, 40)
    signedAddUnit6.io.addB := io.gaddDataB(47, 40)
    signedAddUnit7.io.addA := io.gaddDataA(55, 48)
    signedAddUnit7.io.addB := io.gaddDataB(55, 48)
    signedAddUnit8.io.addA := io.gaddDataA(63, 56)
    signedAddUnit8.io.addB := io.gaddDataB(63, 56)
    when(io.carryOut === "b0".U) {
      //输出实际运算结果
      io.gaddResult := Cat(signedAddUnit8.io.wResult(7, 0),signedAddUnit7.io.wResult(7, 0), signedAddUnit6.io.wResult(7, 0),
        signedAddUnit5.io.wResult(7, 0), signedAddUnit4.io.wResult(7, 0), signedAddUnit3.io.wResult(7, 0),
          signedAddUnit2.io.wResult(7, 0), signedAddUnit1.io.wResult(7, 0))
    }.otherwise {
      //输出进位信息
      io.gaddResult := Cat(0.U(56.W), signedAddUnit8.io.wResult(8), signedAddUnit7.io.wResult(8), signedAddUnit6.io.wResult(8),
        signedAddUnit5.io.wResult(8), signedAddUnit4.io.wResult(8), signedAddUnit3.io.wResult(8),
          signedAddUnit2.io.wResult(8), signedAddUnit1.io.wResult(8))
    }


  }.elsewhen(io.gaddDataWdith === "b01".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(16))
    val signedAddUnit2 = Module(new unsignedAddSub(16))
    val signedAddUnit3 = Module(new unsignedAddSub(16))
    val signedAddUnit4 = Module(new unsignedAddSub(16))
    signedAddUnit1.io.op := io.op
    signedAddUnit2.io.op := io.op
    signedAddUnit3.io.op := io.op
    signedAddUnit4.io.op := io.op

    signedAddUnit1.io.addC := io.gaddDataC(0)
    signedAddUnit2.io.addC := io.gaddDataC(1)
    signedAddUnit3.io.addC := io.gaddDataC(2)
    signedAddUnit4.io.addC := io.gaddDataC(3)

    signedAddUnit1.io.addA := io.gaddDataA(15, 0)
    signedAddUnit1.io.addB := io.gaddDataB(15, 0)
    signedAddUnit2.io.addA := io.gaddDataA(31, 16)
    signedAddUnit2.io.addB := io.gaddDataB(31, 16)
    signedAddUnit3.io.addA := io.gaddDataA(47, 32)
    signedAddUnit3.io.addB := io.gaddDataB(47, 32)
    signedAddUnit4.io.addA := io.gaddDataA(63, 48)
    signedAddUnit4.io.addB := io.gaddDataB(63, 48)
    when(io.carryOut === "b0".U) {
      //输出实际运算结果
      io.gaddResult := Cat(signedAddUnit4.io.wResult(15, 0), Cat(signedAddUnit3.io.wResult(15, 0), Cat(signedAddUnit2.io.wResult(15, 0), signedAddUnit1.io.wResult(15, 0))))
    }.otherwise {
      //输出进位信息
      io.gaddResult := Cat(0.U(60.W), Cat(signedAddUnit4.io.wResult(16), Cat(signedAddUnit3.io.wResult(16), Cat(signedAddUnit2.io.wResult(16), signedAddUnit1.io.wResult(16)))))
    }


  }.elsewhen(io.gaddDataWdith === "b10".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(32))
    val signedAddUnit2 = Module(new unsignedAddSub(32))
    signedAddUnit1.io.op := io.op
    signedAddUnit2.io.op := io.op

    signedAddUnit1.io.addC := io.gaddDataC(0)
    signedAddUnit2.io.addC := io.gaddDataC(1)

    signedAddUnit1.io.addA := io.gaddDataA(31, 0)
    signedAddUnit1.io.addB := io.gaddDataB(31, 0)
    signedAddUnit2.io.addA := io.gaddDataA(63, 32)
    signedAddUnit2.io.addB := io.gaddDataB(63, 32)
    when(io.carryOut === "b0".U) {
      //输出实际运算结果
      io.gaddResult := Cat(signedAddUnit2.io.wResult(31, 0), signedAddUnit1.io.wResult(31, 0))
    }.otherwise {
      //输出进位信息
      io.gaddResult := Cat(0.U(62.W), Cat(signedAddUnit2.io.wResult(32), signedAddUnit1.io.wResult(32)))
    }


  }.elsewhen(io.gaddDataWdith === "b11".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(64))
    signedAddUnit1.io.op := io.op

    signedAddUnit1.io.addC := io.gaddDataC(0)

    signedAddUnit1.io.addA := io.gaddDataA
    signedAddUnit1.io.addB := io.gaddDataB
    when(io.carryOut === "b0".U) {
      //输出实际运算结果
      io.gaddResult := signedAddUnit1.io.wResult(63, 0)
    }.otherwise {
      //输出进位信息
      io.gaddResult := Cat(0.U(63.W), signedAddUnit1.io.wResult(64))
    }

  }

}

class vwadd_vwsub_u_v_w_Unit extends Module {
  //符号扩展后相加，element最多为4（8扩展到16）
  val io = IO(new Bundle() {
    val gaddDataA = Input(UInt(64.W))
    val gaddDataB = Input(UInt(64.W))
    val gaddDataWdith = Input(UInt(2.W))
    val op = Input(UInt(3.W))
    //000：vwadd.v, 001：vwaddu.v, 010：vwsub.v
    //011：vwsubu.v, 100：vwadd.w, 101：vwaddu.w
    //110：vwsub.w, 111：vwsubu.w
    //8种：v或w，+或-，u或s，2*2*2
    val gaddResult = Output(UInt(64.W))
  })
  //符号扩展后的addA和addB
  val waddA_16_1 = Wire(UInt(16.W))
  val waddA_16_2 = Wire(UInt(16.W))
  val waddA_16_3 = Wire(UInt(16.W))
  val waddA_16_4 = Wire(UInt(16.W))
  val waddB_16_1 = Wire(UInt(16.W))
  val waddB_16_2 = Wire(UInt(16.W))
  val waddB_16_3 = Wire(UInt(16.W))
  val waddB_16_4 = Wire(UInt(16.W))
  val waddB_complement1_16_1 = Wire(UInt(16.W))
  val waddB_complement1_16_2 = Wire(UInt(16.W))
  val waddB_complement1_16_3 = Wire(UInt(16.W))
  val waddB_complement1_16_4 = Wire(UInt(16.W))
  val waddB_complement2_16_1 = Wire(UInt(16.W))
  val waddB_complement2_16_2 = Wire(UInt(16.W))
  val waddB_complement2_16_3 = Wire(UInt(16.W))
  val waddB_complement2_16_4 = Wire(UInt(16.W))
  val waddA_32_1 = Wire(UInt(32.W))
  val waddA_32_2 = Wire(UInt(32.W))
  val waddB_32_1 = Wire(UInt(32.W))
  val waddB_32_2 = Wire(UInt(32.W))
  val waddB_complement1_32_1 = Wire(UInt(32.W))
  val waddB_complement1_32_2 = Wire(UInt(32.W))
  val waddB_complement2_32_1 = Wire(UInt(32.W))
  val waddB_complement2_32_2 = Wire(UInt(32.W))
  val waddA_64 = Wire(UInt(64.W))
  val waddB_64 = Wire(UInt(64.W))
  val waddB_complement1_64 = Wire(UInt(64.W))
  val waddB_complement2_64 = Wire(UInt(64.W))
  val signExt = Wire(UInt(32.W))
  val signExtNeg = Wire(UInt(32.W))
  signExt := 0.U
  signExtNeg := ~signExt
  io.gaddResult := 0.U
  waddA_16_1 := 0.U
  waddA_16_2 := 0.U
  waddA_16_3 := 0.U
  waddA_16_4 := 0.U
  waddB_16_1 := 0.U
  waddB_16_2 := 0.U
  waddB_16_3 := 0.U
  waddB_16_4 := 0.U
  waddA_32_1 := 0.U
  waddA_32_2 := 0.U
  waddB_32_1 := 0.U
  waddB_32_2 := 0.U
  waddA_64 := 0.U
  waddB_64 := 0.U
  waddB_complement1_16_1 := 0.U
  waddB_complement1_16_2 := 0.U
  waddB_complement1_16_3 := 0.U
  waddB_complement1_16_4 := 0.U
  waddB_complement1_32_1 := 0.U
  waddB_complement1_32_2 := 0.U
  waddB_complement1_64 := 0.U
  waddB_complement2_16_1 := 0.U
  waddB_complement2_16_2 := 0.U
  waddB_complement2_16_3 := 0.U
  waddB_complement2_16_4 := 0.U
  waddB_complement2_32_1 := 0.U
  waddB_complement2_32_2 := 0.U
  waddB_complement2_64 := 0.U
  when (io.gaddDataWdith === "b00".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(16))
    val signedAddUnit2 = Module(new unsignedAddSub(16))
    val signedAddUnit3 = Module(new unsignedAddSub(16))
    val signedAddUnit4 = Module(new unsignedAddSub(16))
    //计算waddA 16
    when (io.op === "b100".U || io.op === "b101".U || io.op === "b110".U || io.op === "b111".U) {
      //w类指令无需扩展addA
      waddA_16_1 := io.gaddDataA(15, 0)
      waddA_16_2 := io.gaddDataA(31, 16)
      waddA_16_3 := io.gaddDataA(47, 32)
      waddA_16_4 := io.gaddDataA(63, 48)
    }.otherwise {
      //v类指令需要扩展addA
      when (io.op === "b000".U || io.op === "b010".U || io.op === "b100".U || io.op === "b110".U) {
        //有符号扩展指令需要进行符号位的扩展
        when(io.gaddDataA(7) === 0.U) {
          waddA_16_1 := Cat(signExt(7, 0), io.gaddDataA(7, 0))
        }.otherwise{
          waddA_16_1 := Cat(signExtNeg(7, 0), io.gaddDataA(7, 0))
        }
        when(io.gaddDataA(15) === 0.U) {
          waddA_16_2 := Cat(signExt(7, 0), io.gaddDataA(15, 8))
        }.otherwise{
          waddA_16_2 := Cat(signExtNeg(7, 0), io.gaddDataA(15, 8))
        }
        when(io.gaddDataA(23) === 0.U) {
          waddA_16_3 := Cat(signExt(7, 0), io.gaddDataA(23, 16))
        }.otherwise{
          waddA_16_3 := Cat(signExtNeg(7, 0), io.gaddDataA(23, 16))
        }
        when(io.gaddDataA(31) === 0.U) {
          waddA_16_4 := Cat(signExt(7, 0), io.gaddDataA(31, 24))
        }.otherwise{
          waddA_16_4 := Cat(signExtNeg(7, 0), io.gaddDataA(31, 24))
        }
      }.otherwise {
        //无符号扩展指令需要进行0扩展
        waddA_16_1 := Cat(signExt(7, 0), io.gaddDataA(7, 0))
        waddA_16_2 := Cat(signExt(7, 0), io.gaddDataA(15, 8))
        waddA_16_3 := Cat(signExt(7, 0), io.gaddDataA(23, 16))
        waddA_16_4 := Cat(signExt(7, 0), io.gaddDataA(31, 24))
      }

    }
    //扩展addB 8 1-4
    when (io.op === "b000".U || io.op === "b010".U || io.op === "b100".U || io.op === "b110".U) {
      //有符号扩展指令需要进行符号位的扩展
      when(io.gaddDataB(7) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_16_1 := Cat(signExt(7, 0), io.gaddDataB(7, 0))
        }.otherwise {
          waddB_16_1 := Cat(signExt(7, 0), io.gaddDataB(7, 0))
        }
      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_16_1 := Cat(signExtNeg(7, 0), io.gaddDataB(7, 0))
        }.otherwise {
          waddB_16_1 := Cat(signExtNeg(7, 0), io.gaddDataB(7, 0))
        }
      }
      when(io.gaddDataB(15) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_16_2 := Cat(signExt(7, 0), io.gaddDataB(15, 8))
        }.otherwise {
          waddB_16_2 := Cat(signExt(7, 0), io.gaddDataB(15, 8))
        }
      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          waddB_complement1_16_2 := Cat(signExtNeg(7, 0), io.gaddDataB(15,8))
        }.otherwise {
          waddB_16_2 := Cat(signExtNeg(7, 0), io.gaddDataB(15, 8))
        }
      }
      when(io.gaddDataB(23) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          waddB_complement1_16_3 := Cat(signExt(7, 0), io.gaddDataB(23, 16))
        }
        waddB_16_3 := Cat(signExt(7, 0), io.gaddDataB(23, 16))
      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          waddB_complement1_16_3 := Cat(signExtNeg(7, 0), io.gaddDataB(23, 16))
        }.otherwise {
          waddB_16_3 := Cat(signExtNeg(7, 0), io.gaddDataB(23, 16))
        }
      }
      when(io.gaddDataB(31) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          waddB_complement1_16_4 := Cat(signExt(7, 0), io.gaddDataB(31, 24))
        }.otherwise{
          waddB_16_4 := Cat(signExt(7, 0), io.gaddDataB(31, 24))
        }
      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          waddB_complement1_16_4 := Cat(signExtNeg(7, 0), io.gaddDataB(31, 24))
        }
        waddB_16_4 := Cat(signExtNeg(7, 0), io.gaddDataB(31, 24))
      }
    }.otherwise {
      //无符号扩展指令需要进行0扩展
      waddB_16_1 := Cat(signExt(7, 0), io.gaddDataB(7, 0))
      waddB_16_2 := Cat(signExt(7, 0), io.gaddDataB(15, 8))
      waddB_16_3 := Cat(signExt(7, 0), io.gaddDataB(23, 16))
      waddB_16_4 := Cat(signExt(7, 0), io.gaddDataB(31, 24))
    }
    when(io.op === "b010".U || io.op === "b110".U) {
      //有符号减法需要取补+1
      waddB_complement2_16_1 := ~waddB_complement1_16_1
      waddB_complement2_16_2 := ~waddB_complement1_16_2
      waddB_complement2_16_3 := ~waddB_complement1_16_3
      waddB_complement2_16_4 := ~waddB_complement1_16_4




      waddB_16_1 := waddB_complement2_16_1 + 1.U
      waddB_16_2 := waddB_complement2_16_2 + 1.U
      waddB_16_3 := waddB_complement2_16_3 + 1.U
      waddB_16_4 := waddB_complement2_16_4 + 1.U
    }

    when(io.op === "b011".U || io.op === "b111".U) {
      //无符号减
      signedAddUnit1.io.op := 1.U
      signedAddUnit2.io.op := 1.U
      signedAddUnit3.io.op := 1.U
      signedAddUnit4.io.op := 1.U
    }.otherwise {
      signedAddUnit1.io.op := 0.U
      signedAddUnit2.io.op := 0.U
      signedAddUnit3.io.op := 0.U
      signedAddUnit4.io.op := 0.U
    }


    signedAddUnit1.io.addC := 0.U
    signedAddUnit2.io.addC := 0.U
    signedAddUnit3.io.addC := 0.U
    signedAddUnit4.io.addC := 0.U

    signedAddUnit1.io.addA := waddA_16_1
    signedAddUnit1.io.addB := waddB_16_1
    signedAddUnit2.io.addA := waddA_16_2
    signedAddUnit2.io.addB := waddB_16_2
    signedAddUnit3.io.addA := waddA_16_3
    signedAddUnit3.io.addB := waddB_16_3
    signedAddUnit4.io.addA := waddA_16_4
    signedAddUnit4.io.addB := waddB_16_4
    io.gaddResult := Cat(signedAddUnit4.io.wResult(15, 0), Cat(signedAddUnit3.io.wResult(15, 0), Cat(signedAddUnit2.io.wResult(15, 0), signedAddUnit1.io.wResult(15, 0))))
  }.elsewhen(io.gaddDataWdith === "b01".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(32))
    val signedAddUnit2 = Module(new unsignedAddSub(32))
    when (io.op === "b100".U || io.op === "b101".U || io.op === "b110".U || io.op === "b111".U) {
      //w类指令无需扩展addA
      waddA_32_1 := io.gaddDataA(31, 0)
      waddA_32_2 := io.gaddDataA(63, 32)
    }.otherwise {
      //v类指令需要扩展addA
      when (io.op === "b000".U || io.op === "b010".U || io.op === "b100".U || io.op === "b110".U) {
        //有符号扩展指令需要进行符号位的扩展
        when(io.gaddDataA(15) === 0.U) {
          waddA_32_1 := Cat(signExt(15, 0), io.gaddDataA(15, 0))
        }.otherwise{
          waddA_32_1 := Cat(signExtNeg(15, 0), io.gaddDataA(15, 0))
        }
        when(io.gaddDataA(31) === 0.U) {
          waddA_32_2 := Cat(signExt(15, 0), io.gaddDataA(31, 16))
        }.otherwise{
          waddA_32_2 := Cat(signExtNeg(15, 0), io.gaddDataA(31, 16))
        }
      }.otherwise {
        //无符号扩展指令需要进行0扩展
        waddA_32_1 := Cat(signExt(15, 0), io.gaddDataA(15, 0))
        waddA_32_2 := Cat(signExt(15, 0), io.gaddDataA(31, 16))

      }
    }





    //扩展addB 16 1-2
    when (io.op === "b000".U || io.op === "b010".U || io.op === "b100".U || io.op === "b110".U) {
      //有符号扩展指令需要进行符号位的扩展
      when(io.gaddDataB(15) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_32_1 := Cat(signExt(15, 0), io.gaddDataB(15, 0))
        }.otherwise {
          waddB_32_1 := Cat(signExt(15, 0), io.gaddDataB(15, 0))
        }


      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_32_1 := Cat(signExtNeg(15, 0), io.gaddDataB(15, 0))
        }.otherwise {
          waddB_32_1 := Cat(signExtNeg(15, 0), io.gaddDataB(15, 0))
        }

      }

      when(io.gaddDataB(31) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_32_2 := Cat(signExt(15, 0), io.gaddDataB(31, 16))
        }.otherwise {
          waddB_32_2 := Cat(signExt(15, 0), io.gaddDataB(31, 16))
        }

      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_32_2 := Cat(signExtNeg(15, 0), io.gaddDataB(31, 16))
        }.otherwise {
          waddB_32_2 := Cat(signExtNeg(15, 0), io.gaddDataB(31, 16))
        }

      }



    }.otherwise {
      //无符号扩展指令需要进行0扩展
      waddB_32_1 := Cat(signExt(15, 0), io.gaddDataB(15, 0))
      waddB_32_2 := Cat(signExt(15, 0), io.gaddDataB(31, 16))
    }

    when(io.op === "b010".U || io.op === "b110".U) {
      //有符号减法需要取补+1
      waddB_complement2_32_1 := ~waddB_complement1_32_1
      waddB_complement2_32_2 := ~waddB_complement1_32_2
      waddB_32_1 := waddB_complement2_32_1 + 1.U
      waddB_32_2 := waddB_complement2_32_2 + 1.U
    }


    when(io.op === "b011".U || io.op === "b111".U) {
      signedAddUnit1.io.op := 1.U
      signedAddUnit2.io.op := 1.U

    }.otherwise {
      signedAddUnit1.io.op := 0.U
      signedAddUnit2.io.op := 0.U
    }


    signedAddUnit1.io.addC := 0.U
    signedAddUnit2.io.addC := 0.U

    signedAddUnit1.io.addA := waddA_32_1
    signedAddUnit1.io.addB := waddB_32_1
    signedAddUnit2.io.addA := waddA_32_2
    signedAddUnit2.io.addB := waddB_32_2
    io.gaddResult := Cat(signedAddUnit2.io.wResult(31, 0), signedAddUnit1.io.wResult(31, 0))
  }.elsewhen(io.gaddDataWdith === "b10".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(64))

    //扩展addA 32
    when (io.op === "b100".U || io.op === "b101".U || io.op === "b110".U || io.op === "b111".U) {
      //w类指令无需扩展addA
      waddA_64 := io.gaddDataA(63, 0)
    }.otherwise{
      //v类指令需要扩展addA
      when (io.op === "b000".U || io.op === "b010".U || io.op === "b100".U || io.op === "b110".U) {
        //有符号扩展指令需要进行符号位的扩展
        when(io.gaddDataA(31) === 0.U) {
          waddA_64 := Cat(signExt, io.gaddDataA(31, 0))
        }.otherwise{
          waddA_64 := Cat(signExtNeg, io.gaddDataA(31, 0))
        }
      }.otherwise{
        //无符号扩展指令需要进行0扩展
        waddA_64 := Cat(signExt(31, 0), io.gaddDataA(31, 0))
      }
    }


    //扩展addB 32
    when (io.op === "b000".U || io.op === "b010".U || io.op === "b100".U || io.op === "b110".U) {
      //有符号扩展指令需要进行符号位的扩展

      when(io.gaddDataB(31) === 0.U) {
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_64 := Cat(signExt, io.gaddDataB(31, 0))
        }.otherwise {
          waddB_64 := Cat(signExt, io.gaddDataB(31, 0))
        }


      }.otherwise{
        when(io.op === "b010".U || io.op === "b110".U) {
          //有符号减法指令数据暂存在临时变量中等待取补
          waddB_complement1_64 := Cat(signExtNeg, io.gaddDataB(31, 0))
        }.otherwise {
          waddB_64 := Cat(signExtNeg, io.gaddDataB(31, 0))
        }
      }

    }.otherwise {
      //无符号扩展指令需要进行0扩展
      waddB_64 := Cat(signExt(31, 0), io.gaddDataB(31, 0))

    }

    when(io.op === "b010".U || io.op === "b110".U) {
      //有符号减法需要取补+1
      waddB_complement2_64 := ~waddB_complement1_64
      waddB_64 := waddB_complement2_64 + 1.U
    }


    when(io.op === "b011".U || io.op === "b111".U) {
      signedAddUnit1.io.op := 1.U
    }.otherwise {
      signedAddUnit1.io.op := 0.U
    }


    signedAddUnit1.io.addC := 0.U

    signedAddUnit1.io.addA := waddA_64
    signedAddUnit1.io.addB := waddB_64
    io.gaddResult := signedAddUnit1.io.wResult(63, 0)
  }.elsewhen(io.gaddDataWdith === "b11".U) {
    //异常区域
    //TODO:异常处理
  }
}

class vaadd_vaasub_vsadd_vssub_u_Unit extends Module {
  //vaaddu、vaadd、vasub、vasubu指令
  //vsaddu、vsadd、vssub、vssubu指令
  val io = IO(new Bundle() {
    val gaddDataA = Input(UInt(64.W))
    val gaddDataB = Input(UInt(64.W))
    val gaddDataWdith = Input(UInt(2.W))
    val vxrm = Input(UInt(2.W)) //csr,设置舍入模式。00：rnu；01：rne；10：rdn；11：rod
    val signFlag = Input(UInt(1.W)) //0：无符号运算，1：有符号运算
    val op = Input(UInt(1.W)) //0：加法，1：减法
    val shiftOrSat = Input(UInt(1.W)) //0：移位舍入指令，1：进位饱和指令
    val gaddResult = Output(UInt(64.W))
    //val vxsat = Output(UInt(8.W))
    val vxsat = Output(UInt(8.W))
  })
  val addB_complement_8_1 = Wire(UInt(8.W))
  val addB_complement_8_2 = Wire(UInt(8.W))
  val addB_complement_8_3 = Wire(UInt(8.W))
  val addB_complement_8_4 = Wire(UInt(8.W))
  val addB_complement_8_5 = Wire(UInt(8.W))
  val addB_complement_8_6 = Wire(UInt(8.W))
  val addB_complement_8_7 = Wire(UInt(8.W))
  val addB_complement_8_8 = Wire(UInt(8.W))
  val addB_complement_16_1 = Wire(UInt(16.W))
  val addB_complement_16_2 = Wire(UInt(16.W))
  val addB_complement_16_3 = Wire(UInt(16.W))
  val addB_complement_16_4 = Wire(UInt(16.W))
  val addB_complement_32_1 = Wire(UInt(32.W))
  val addB_complement_32_2 = Wire(UInt(32.W))
  val addB_complement_64 = Wire(UInt(64.W))
  val addB_8_1 = Wire(UInt(8.W))
  val addB_8_2 = Wire(UInt(8.W))
  val addB_8_3 = Wire(UInt(8.W))
  val addB_8_4 = Wire(UInt(8.W))
  val addB_8_5 = Wire(UInt(8.W))
  val addB_8_6 = Wire(UInt(8.W))
  val addB_8_7 = Wire(UInt(8.W))
  val addB_8_8 = Wire(UInt(8.W))
  val addB_16_1 = Wire(UInt(16.W))
  val addB_16_2 = Wire(UInt(16.W))
  val addB_16_3 = Wire(UInt(16.W))
  val addB_16_4 = Wire(UInt(16.W))
  val addB_32_1 = Wire(UInt(32.W))
  val addB_32_2 = Wire(UInt(32.W))
  val addB_64 = Wire(UInt(64.W))
  /*
  val shiftResult_8_1 = Wire(UInt(9.W))
  val shiftResult_8_2 = Wire(UInt(9.W))
  val shiftResult_8_3 = Wire(UInt(9.W))
  val shiftResult_8_4 = Wire(UInt(9.W))
  val shiftResult_8_5 = Wire(UInt(9.W))
  val shiftResult_8_6 = Wire(UInt(9.W))
  val shiftResult_8_7 = Wire(UInt(9.W))
  val shiftResult_8_8 = Wire(UInt(9.W))
*/


  val tempResult_8_1 = Wire(UInt(8.W))
  val tempResult_8_2 = Wire(UInt(8.W))
  val tempResult_8_3 = Wire(UInt(8.W))
  val tempResult_8_4 = Wire(UInt(8.W))
  val tempResult_8_5 = Wire(UInt(8.W))
  val tempResult_8_6 = Wire(UInt(8.W))
  val tempResult_8_7 = Wire(UInt(8.W))
  val tempResult_8_8 = Wire(UInt(8.W))
  val tempResult_16_1 = Wire(UInt(16.W))
  val tempResult_16_2 = Wire(UInt(16.W))
  val tempResult_16_3 = Wire(UInt(16.W))
  val tempResult_16_4 = Wire(UInt(16.W))
  val tempResult_32_1 = Wire(UInt(32.W))
  val tempResult_32_2 = Wire(UInt(32.W))
  val tempVxsat1 = Wire(UInt(1.W))
  val tempVxsat2 = Wire(UInt(1.W))
  val tempVxsat3 = Wire(UInt(1.W))
  val tempVxsat4 = Wire(UInt(1.W))
  val tempVxsat5 = Wire(UInt(1.W))
  val tempVxsat6 = Wire(UInt(1.W))
  val tempVxsat7 = Wire(UInt(1.W))
  val tempVxsat8 = Wire(UInt(1.W))


  addB_complement_8_1 := 0.U
  addB_complement_8_2 := 0.U
  addB_complement_8_3 := 0.U
  addB_complement_8_4 := 0.U
  addB_complement_8_5 := 0.U
  addB_complement_8_6 := 0.U
  addB_complement_8_7 := 0.U
  addB_complement_8_8 := 0.U
  addB_complement_16_1 := 0.U
  addB_complement_16_2 := 0.U
  addB_complement_16_3 := 0.U
  addB_complement_16_4 := 0.U
  addB_complement_32_1 := 0.U
  addB_complement_32_2 := 0.U
  addB_complement_64 := 0.U
  addB_8_1 := 0.U
  addB_8_2 := 0.U
  addB_8_3 := 0.U
  addB_8_4 := 0.U
  addB_8_5 := 0.U
  addB_8_6 := 0.U
  addB_8_7 := 0.U
  addB_8_8 := 0.U
  addB_16_1 := 0.U
  addB_16_2 := 0.U
  addB_16_3 := 0.U
  addB_16_4 := 0.U
  addB_32_1 := 0.U
  addB_32_2 := 0.U
  addB_64 := 0.U

  tempResult_8_1 := 0.U
  tempResult_8_2 := 0.U
  tempResult_8_3 := 0.U
  tempResult_8_4 := 0.U
  tempResult_8_5 := 0.U
  tempResult_8_6 := 0.U
  tempResult_8_7 := 0.U
  tempResult_8_8 := 0.U
  tempResult_16_1 := 0.U
  tempResult_16_2 := 0.U
  tempResult_16_3 := 0.U
  tempResult_16_4 := 0.U
  tempResult_32_1 := 0.U
  tempResult_32_2 := 0.U

  tempVxsat1 := 0.U
  tempVxsat2 := 0.U
  tempVxsat3 := 0.U
  tempVxsat4 := 0.U
  tempVxsat5 := 0.U
  tempVxsat6 := 0.U
  tempVxsat7 := 0.U
  tempVxsat8 := 0.U

  io.vxsat := 0.U

  when (io.gaddDataWdith === "b00".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(8))
    val signedAddUnit2 = Module(new unsignedAddSub(8))
    val signedAddUnit3 = Module(new unsignedAddSub(8))
    val signedAddUnit4 = Module(new unsignedAddSub(8))
    val signedAddUnit5 = Module(new unsignedAddSub(8))
    val signedAddUnit6 = Module(new unsignedAddSub(8))
    val signedAddUnit7 = Module(new unsignedAddSub(8))
    val signedAddUnit8 = Module(new unsignedAddSub(8))


    when (io.signFlag === 1.U && io.op === 1.U) {
      //有符号减法
      addB_complement_8_1 := ~io.gaddDataB(7, 0)
      addB_complement_8_2 := ~io.gaddDataB(15, 8)
      addB_complement_8_3 := ~io.gaddDataB(23, 16)
      addB_complement_8_4 := ~io.gaddDataB(31, 24)
      addB_complement_8_5 := ~io.gaddDataB(39, 32)
      addB_complement_8_6 := ~io.gaddDataB(47, 40)
      addB_complement_8_7 := ~io.gaddDataB(55, 48)
      addB_complement_8_8 := ~io.gaddDataB(63, 56)
      when (io.gaddDataB(7, 0) === "h80".U) {
        //--128特殊情况
        addB_8_1 := addB_complement_8_1
      }.otherwise {
        addB_8_1 := addB_complement_8_1 + 1.U
      }

      when (io.gaddDataB(15, 8) === "h80".U) {
        //--128特殊情况
        addB_8_2 := addB_complement_8_2
      }.otherwise {
        addB_8_2 := addB_complement_8_2 + 1.U
      }

      when (io.gaddDataB(23, 16) === "h80".U) {
        //--128特殊情况
        addB_8_3 := addB_complement_8_3
      }.otherwise {
        addB_8_3 := addB_complement_8_3 + 1.U
      }

      when (io.gaddDataB(31, 24) === "h80".U) {
        //--128特殊情况
        addB_8_4 := addB_complement_8_4
      }.otherwise {
        addB_8_4 := addB_complement_8_4 + 1.U
      }

      when (io.gaddDataB(39, 32) === "h80".U) {
        //--128特殊情况
        addB_8_5 := addB_complement_8_5
      }.otherwise {
        addB_8_5 := addB_complement_8_5 + 1.U
      }

      when (io.gaddDataB(47, 40) === "h80".U) {
        //--128特殊情况
        addB_8_6 := addB_complement_8_6
      }.otherwise {
        addB_8_6 := addB_complement_8_6 + 1.U
      }

      when (io.gaddDataB(55, 48) === "h80".U) {
        //--128特殊情况
        addB_8_7 := addB_complement_8_7
      }.otherwise {
        addB_8_7 := addB_complement_8_7 + 1.U
      }

      when (io.gaddDataB(63, 56) === "h80".U) {
        //--128特殊情况
        addB_8_8 := addB_complement_8_8
      }.otherwise {
        addB_8_8 := addB_complement_8_8 + 1.U
      }

    }.otherwise {
      addB_8_1 := io.gaddDataB(7, 0)
      addB_8_2 := io.gaddDataB(15, 8)
      addB_8_3 := io.gaddDataB(23, 16)
      addB_8_4 := io.gaddDataB(31, 24)
      addB_8_5 := io.gaddDataB(39, 32)
      addB_8_6 := io.gaddDataB(47, 40)
      addB_8_7 := io.gaddDataB(55, 48)
      addB_8_8 := io.gaddDataB(63, 56)
    }

    when (io.signFlag === 0.U && io.op === 1.U) {
      //无符号减
      signedAddUnit1.io.op := 1.U
      signedAddUnit2.io.op := 1.U
      signedAddUnit3.io.op := 1.U
      signedAddUnit4.io.op := 1.U
      signedAddUnit5.io.op := 1.U
      signedAddUnit6.io.op := 1.U
      signedAddUnit7.io.op := 1.U
      signedAddUnit8.io.op := 1.U
    }.otherwise {

      signedAddUnit1.io.op := 0.U
      signedAddUnit2.io.op := 0.U
      signedAddUnit3.io.op := 0.U
      signedAddUnit4.io.op := 0.U
      signedAddUnit5.io.op := 0.U
      signedAddUnit6.io.op := 0.U
      signedAddUnit7.io.op := 0.U
      signedAddUnit8.io.op := 0.U

    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(7, 0) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit1.io.addC := 1.U
    }.otherwise{
      signedAddUnit1.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(15, 8) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit2.io.addC := 1.U
    }.otherwise {
      signedAddUnit2.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(23, 16) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit3.io.addC := 1.U
    }.otherwise {
      signedAddUnit3.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(31, 24) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit4.io.addC := 1.U
    }.otherwise {
      signedAddUnit4.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(39, 32) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit5.io.addC := 1.U
    }.otherwise {
      signedAddUnit5.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(47, 40) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit6.io.addC := 1.U
    }.otherwise {
      signedAddUnit6.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(55, 48) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit7.io.addC := 1.U
    }.otherwise {
      signedAddUnit7.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(63, 56) === "h80".U) {
      //有符号减-128的情况
      signedAddUnit8.io.addC := 1.U
    }.otherwise {
      signedAddUnit8.io.addC := 0.U
    }

    signedAddUnit1.io.addA := io.gaddDataA(7, 0)
    signedAddUnit1.io.addB := addB_8_1
    signedAddUnit2.io.addA := io.gaddDataA(15, 8)
    signedAddUnit2.io.addB := addB_8_2
    signedAddUnit3.io.addA := io.gaddDataA(23, 16)
    signedAddUnit3.io.addB := addB_8_3
    signedAddUnit4.io.addA := io.gaddDataA(31, 24)
    signedAddUnit4.io.addB := addB_8_4
    signedAddUnit5.io.addA := io.gaddDataA(39, 32)
    signedAddUnit5.io.addB := addB_8_5
    signedAddUnit6.io.addA := io.gaddDataA(47, 40)
    signedAddUnit6.io.addB := addB_8_6
    signedAddUnit7.io.addA := io.gaddDataA(55, 48)
    signedAddUnit7.io.addB := addB_8_7
    signedAddUnit8.io.addA := io.gaddDataA(63, 56)
    signedAddUnit8.io.addB := addB_8_8



    when (io.shiftOrSat === 0.U) {
      //移位舍入指令
      val roundModule1 = Module(new rshiftRM(8))
      val roundModule2 = Module(new rshiftRM(8))
      val roundModule3 = Module(new rshiftRM(8))
      val roundModule4 = Module(new rshiftRM(8))
      val roundModule5 = Module(new rshiftRM(8))
      val roundModule6 = Module(new rshiftRM(8))
      val roundModule7 = Module(new rshiftRM(8))
      val roundModule8 = Module(new rshiftRM(8))
      when (io.signFlag === "b1".U ) {
        //有符号加减需要符号扩展
        when (io.gaddDataA(7) === addB_8_1(7)) {
          roundModule1.io.inputInt := signedAddUnit1.io.wResult
        }.otherwise {
          //正+负需要符号扩展
          when (signedAddUnit1.io.wResult(7) === "b0".U) {
            roundModule1.io.inputInt := Cat("b0".U(1.W), signedAddUnit1.io.wResult(7, 0))
          }.otherwise {
            roundModule1.io.inputInt := Cat("b1".U(1.W), signedAddUnit1.io.wResult(7, 0))
          }
        }

        when (io.gaddDataA(15) === addB_8_2(7)) {
          roundModule2.io.inputInt := signedAddUnit2.io.wResult
        }.otherwise {
          when (signedAddUnit2.io.wResult(7) === "b0".U) {
            roundModule2.io.inputInt := Cat("b0".U(1.W), signedAddUnit2.io.wResult(7, 0))
          }.otherwise {
            roundModule2.io.inputInt := Cat("b1".U(1.W), signedAddUnit2.io.wResult(7, 0))
          }
        }

        when (io.gaddDataA(23) === addB_8_3(7)) {
          roundModule3.io.inputInt := signedAddUnit3.io.wResult
        }.otherwise {
          when (signedAddUnit3.io.wResult(7) === "b0".U) {
            roundModule3.io.inputInt := Cat("b0".U(1.W), signedAddUnit3.io.wResult(7, 0))
          }.otherwise {
            roundModule3.io.inputInt := Cat("b1".U(1.W), signedAddUnit3.io.wResult(7, 0))
          }
        }
        when (io.gaddDataA(31) === addB_8_4(7)) {
          roundModule4.io.inputInt := signedAddUnit4.io.wResult
        }.otherwise {
          when (signedAddUnit4.io.wResult(7) === "b0".U) {
            roundModule4.io.inputInt := Cat("b0".U(1.W), signedAddUnit4.io.wResult(7, 0))
          }.otherwise {
            roundModule4.io.inputInt := Cat("b1".U(1.W), signedAddUnit4.io.wResult(7, 0))
          }
        }

        when (io.gaddDataA(39) === addB_8_5(7)) {
          roundModule5.io.inputInt := signedAddUnit5.io.wResult
        }.otherwise {
          when (signedAddUnit5.io.wResult(7) === "b0".U) {
            roundModule5.io.inputInt := Cat("b0".U(1.W), signedAddUnit5.io.wResult(7, 0))
          }.otherwise {
            roundModule5.io.inputInt := Cat("b1".U(1.W), signedAddUnit5.io.wResult(7, 0))
          }
        }

        when (io.gaddDataA(47) === addB_8_6(7)) {
          roundModule6.io.inputInt := signedAddUnit6.io.wResult
        }.otherwise {
          when (signedAddUnit6.io.wResult(7) === "b0".U) {
            roundModule6.io.inputInt := Cat("b0".U(1.W), signedAddUnit6.io.wResult(7, 0))
          }.otherwise {
            roundModule6.io.inputInt := Cat("b1".U(1.W), signedAddUnit6.io.wResult(7, 0))
          }
        }

        when (io.gaddDataA(55) === addB_8_7(7)) {
          roundModule7.io.inputInt := signedAddUnit7.io.wResult
        }.otherwise {
          when (signedAddUnit7.io.wResult(7) === "b0".U) {
            roundModule7.io.inputInt := Cat("b0".U(1.W), signedAddUnit7.io.wResult(7, 0))
          }.otherwise {
            roundModule7.io.inputInt := Cat("b1".U(1.W), signedAddUnit7.io.wResult(7, 0))
          }
        }

        when (io.gaddDataA(63) === addB_8_8(7)) {
          roundModule8.io.inputInt := signedAddUnit8.io.wResult
        }.otherwise {
          when (signedAddUnit8.io.wResult(7) === "b0".U) {
            roundModule8.io.inputInt := Cat("b0".U(1.W), signedAddUnit8.io.wResult(7, 0))
          }.otherwise {
            roundModule8.io.inputInt := Cat("b1".U(1.W), signedAddUnit8.io.wResult(7, 0))
          }
        }

      }.otherwise {
        //逻辑右移
        roundModule1.io.inputInt := signedAddUnit1.io.wResult
        roundModule2.io.inputInt := signedAddUnit2.io.wResult
        roundModule3.io.inputInt := signedAddUnit3.io.wResult
        roundModule4.io.inputInt := signedAddUnit4.io.wResult
        roundModule5.io.inputInt := signedAddUnit5.io.wResult
        roundModule6.io.inputInt := signedAddUnit6.io.wResult
        roundModule7.io.inputInt := signedAddUnit7.io.wResult
        roundModule8.io.inputInt := signedAddUnit8.io.wResult

      }

      roundModule1.io.vxrm := io.vxrm
      roundModule2.io.vxrm := io.vxrm
      roundModule3.io.vxrm := io.vxrm
      roundModule4.io.vxrm := io.vxrm
      roundModule5.io.vxrm := io.vxrm
      roundModule6.io.vxrm := io.vxrm
      roundModule7.io.vxrm := io.vxrm
      roundModule8.io.vxrm := io.vxrm

      io.gaddResult := Cat(roundModule8.io.outputInt, roundModule7.io.outputInt, roundModule6.io.outputInt,
        roundModule5.io.outputInt, roundModule4.io.outputInt, roundModule3.io.outputInt, roundModule2.io.outputInt,
        roundModule1.io.outputInt)

    }.otherwise {
      //进位饱和指令
      when (io.signFlag === 0.U) {
        //无符号数的溢出位直接由结果最高位获得
        tempVxsat1 := signedAddUnit1.io.wResult(8)
        tempVxsat2 := signedAddUnit2.io.wResult(8)
        tempVxsat3 := signedAddUnit3.io.wResult(8)
        tempVxsat4 := signedAddUnit4.io.wResult(8)
        tempVxsat5 := signedAddUnit5.io.wResult(8)
        tempVxsat6 := signedAddUnit6.io.wResult(8)
        tempVxsat7 := signedAddUnit7.io.wResult(8)
        tempVxsat8 := signedAddUnit8.io.wResult(8)
        when (signedAddUnit1.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_1 := "h00".U
          }.otherwise {
            tempResult_8_1 := "hff".U
          }
        }.otherwise {
          tempResult_8_1 := signedAddUnit1.io.wResult(7, 0)
        }

        when (signedAddUnit2.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_2 := "h00".U
          }.otherwise {
            tempResult_8_2 := "hff".U
          }
        }.otherwise {
          tempResult_8_2 := signedAddUnit2.io.wResult(7, 0)
        }

        when (signedAddUnit3.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_3 := "h00".U
          }.otherwise {
            tempResult_8_3 := "hff".U
          }
        }.otherwise {
          tempResult_8_3 := signedAddUnit3.io.wResult(7, 0)
        }

        when (signedAddUnit4.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_4 := "h00".U
          }.otherwise {
            tempResult_8_4 := "hff".U
          }
        }.otherwise {
          tempResult_8_4 := signedAddUnit4.io.wResult(7, 0)
        }

        when (signedAddUnit5.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_5 := "h00".U
          }.otherwise {
            tempResult_8_5 := "hff".U
          }
        }.otherwise {
          tempResult_8_5 := signedAddUnit5.io.wResult(7, 0)
        }

        when (signedAddUnit6.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_6 := "h00".U
          }.otherwise {
            tempResult_8_6 := "hff".U
          }
        }.otherwise {
          tempResult_8_6 := signedAddUnit6.io.wResult(7, 0)
        }

        when (signedAddUnit7.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_7 := "h00".U
          }.otherwise {
            tempResult_8_7 := "hff".U
          }
        }.otherwise {
          tempResult_8_7 := signedAddUnit7.io.wResult(7, 0)
        }

        when (signedAddUnit8.io.wResult(8) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_8_8 := "h00".U
          }.otherwise {
            tempResult_8_8 := "hff".U
          }
        }.otherwise {
          tempResult_8_8 := signedAddUnit8.io.wResult(7, 0)
        }

      }.otherwise {
        //有符号数看运算前后符号位是否一致
        when (io.gaddDataA(7) === addB_8_1(7) && io.gaddDataA(7) =/= signedAddUnit1.io.wResult(7)) {
          //溢出情况
          tempVxsat1 := 1.U
          when (io.gaddDataA(7) === 0.U) {
            //整数设置最大值
            tempResult_8_1 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_1 := "b10000000".U
          }
        }.otherwise {
          tempVxsat1 := 0.U
          tempResult_8_1 := signedAddUnit1.io.wResult(7, 0)
        }

        when (io.gaddDataA(15) === addB_8_2(7) && !(io.gaddDataA(15) === signedAddUnit2.io.wResult(7))) {
          //溢出情况
          tempVxsat2 := 1.U
          when (io.gaddDataA(15) === 0.U) {
            //整数设置最大值
            tempResult_8_2 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_2 := "b10000000".U
          }
        }.otherwise {
          tempVxsat2 := 0.U
          tempResult_8_2 := signedAddUnit2.io.wResult(7, 0)
        }

        when (io.gaddDataA(23) === addB_8_3(7) && !(io.gaddDataA(23) === signedAddUnit3.io.wResult(7))) {
          //溢出情况
          tempVxsat3 := 1.U
          when (io.gaddDataA(23) === 0.U) {
            //整数设置最大值
            tempResult_8_3 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_3 := "b10000000".U
          }
        }.otherwise {
          tempVxsat3 := 0.U
          tempResult_8_3 := signedAddUnit3.io.wResult(7, 0)
        }

        when (io.gaddDataA(31) === addB_8_4(7) && !(io.gaddDataA(31) === signedAddUnit4.io.wResult(7))) {
          //溢出情况
          tempVxsat4 := 1.U
          when (io.gaddDataA(31) === 0.U) {
            //整数设置最大值
            tempResult_8_4 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_4 := "b10000000".U
          }
        }.otherwise {
          tempVxsat4 := 0.U
          tempResult_8_4 := signedAddUnit4.io.wResult(7, 0)
        }

        when (io.gaddDataA(39) === addB_8_5(7) && !(io.gaddDataA(39) === signedAddUnit5.io.wResult(7))) {
          //溢出情况
          tempVxsat5 := 1.U
          when (io.gaddDataA(39) === 0.U) {
            //整数设置最大值
            tempResult_8_5 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_5 := "b10000000".U
          }
        }.otherwise {
          tempVxsat5 := 0.U
          tempResult_8_5 := signedAddUnit5.io.wResult(7, 0)
        }

        when (io.gaddDataA(47) === addB_8_6(7) && !(io.gaddDataA(47) === signedAddUnit6.io.wResult(7))) {
          //溢出情况
          tempVxsat6 := 1.U
          when (io.gaddDataA(47) === 0.U) {
            //整数设置最大值
            tempResult_8_6 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_6 := "b10000000".U
          }
        }.otherwise {
          tempVxsat6 := 0.U
          tempResult_8_6 := signedAddUnit6.io.wResult(7, 0)
        }

        when (io.gaddDataA(55) === addB_8_7(7) && !(io.gaddDataA(55) === signedAddUnit7.io.wResult(7))) {
          //溢出情况
          tempVxsat7 := 1.U
          when (io.gaddDataA(55) === 0.U) {
            //整数设置最大值
            tempResult_8_7 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_7 := "b10000000".U
          }
        }.otherwise {
          tempVxsat7 := 0.U
          tempResult_8_7 := signedAddUnit7.io.wResult(7, 0)
        }

        when (io.gaddDataA(63) === addB_8_8(7) && !(io.gaddDataA(63) === signedAddUnit8.io.wResult(7))) {
          //溢出情况
          tempVxsat8 := 1.U
          when (io.gaddDataA(63) === 0.U) {
            //整数设置最大值
            tempResult_8_8 := "b01111111".U
          }.otherwise {
            //负数设置最大值
            tempResult_8_8 := "b10000000".U
          }
        }.otherwise {
          tempVxsat8 := 0.U
          tempResult_8_8 := signedAddUnit8.io.wResult(7, 0)
        }






      }

      io.gaddResult := Cat(tempResult_8_8, tempResult_8_7, tempResult_8_6, tempResult_8_5,
        tempResult_8_4, tempResult_8_3, tempResult_8_2, tempResult_8_1)

      io.vxsat := Cat(tempVxsat8, tempVxsat7, tempVxsat6, tempVxsat5, tempVxsat4, tempVxsat3, tempVxsat2, tempVxsat1)

    }



  }.elsewhen(io.gaddDataWdith === "b01".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(16))
    val signedAddUnit2 = Module(new unsignedAddSub(16))
    val signedAddUnit3 = Module(new unsignedAddSub(16))
    val signedAddUnit4 = Module(new unsignedAddSub(16))

    when (io.signFlag === 1.U && io.op === 1.U) {
      //有符号减法
      addB_complement_16_1 := ~io.gaddDataB(15, 0)
      addB_complement_16_2 := ~io.gaddDataB(31, 16)
      addB_complement_16_3 := ~io.gaddDataB(47, 32)
      addB_complement_16_4 := ~io.gaddDataB(63, 48)

      when (io.gaddDataB(15, 0) === "h8000".U) {
        //-最大负数特殊情况
        addB_16_1 := addB_complement_16_1
      }.otherwise {
        addB_16_1 := addB_complement_16_1 + 1.U
      }

      when (io.gaddDataB(31, 16) === "h8000".U) {
        //-最大负数特殊情况
        addB_16_2 := addB_complement_16_2
      }.otherwise {
        addB_16_2 := addB_complement_16_2 + 1.U
      }

      when (io.gaddDataB(47, 32) === "h8000".U) {
        //-最大负数特殊情况
        addB_16_3 := addB_complement_16_3
      }.otherwise {
        addB_16_3 := addB_complement_16_3 + 1.U
      }

      when (io.gaddDataB(63, 48) === "h8000".U) {
        //-最大负数特殊情况
        addB_16_4 := addB_complement_16_4
      }.otherwise {
        addB_16_4 := addB_complement_16_4 + 1.U
      }

    }.otherwise {
      addB_16_1 := io.gaddDataB(15, 0)
      addB_16_2 := io.gaddDataB(31, 16)
      addB_16_3 := io.gaddDataB(47, 32)
      addB_16_4 := io.gaddDataB(63, 48)
    }

    when (io.signFlag === 0.U && io.op === 1.U) {
      //无符号减
      signedAddUnit1.io.op := 1.U
      signedAddUnit2.io.op := 1.U
      signedAddUnit3.io.op := 1.U
      signedAddUnit4.io.op := 1.U
    }.otherwise {
      signedAddUnit1.io.op := 0.U
      signedAddUnit2.io.op := 0.U
      signedAddUnit3.io.op := 0.U
      signedAddUnit4.io.op := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(15, 0) === "h8000".U) {
      //有符号减-128的情况
      signedAddUnit1.io.addC := 1.U
    }.otherwise{
      signedAddUnit1.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(31, 16) === "h8000".U) {
      //有符号减-128的情况
      signedAddUnit2.io.addC := 1.U
    }.otherwise{
      signedAddUnit2.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(47, 32) === "h8000".U) {
      //有符号减-128的情况
      signedAddUnit3.io.addC := 1.U
    }.otherwise{
      signedAddUnit3.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(63, 48) === "h8000".U) {
      //有符号减-128的情况
      signedAddUnit4.io.addC := 1.U
    }.otherwise{
      signedAddUnit4.io.addC := 0.U
    }

    signedAddUnit1.io.addA := io.gaddDataA(15, 0)
    signedAddUnit1.io.addB := addB_16_1
    signedAddUnit2.io.addA := io.gaddDataA(31, 16)
    signedAddUnit2.io.addB := addB_16_2
    signedAddUnit3.io.addA := io.gaddDataA(47, 32)
    signedAddUnit3.io.addB := addB_16_3
    signedAddUnit4.io.addA := io.gaddDataA(63, 48)
    signedAddUnit4.io.addB := addB_16_4

    when (io.shiftOrSat === 0.U) {
      val roundModule1 = Module(new rshiftRM(16))
      val roundModule2 = Module(new rshiftRM(16))
      val roundModule3 = Module(new rshiftRM(16))
      val roundModule4 = Module(new rshiftRM(16))
      //移位舍入指令
      when (io.signFlag === "b1".U ) {
        //有符号加减需要符号扩展
        when (io.gaddDataA(15) === addB_16_1(15)) {
          roundModule1.io.inputInt := signedAddUnit1.io.wResult
        }.otherwise {
          //正+负需要符号扩展
          when (signedAddUnit1.io.wResult(15) === "b0".U) {
            roundModule1.io.inputInt := Cat("b0".U(1.W), signedAddUnit1.io.wResult(15, 0))
          }.otherwise {
            roundModule1.io.inputInt := Cat("b1".U(1.W), signedAddUnit1.io.wResult(15, 0))
          }
        }

        when (io.gaddDataA(31) === addB_16_2(15)) {
          roundModule2.io.inputInt := signedAddUnit2.io.wResult
        }.otherwise {
          when (signedAddUnit2.io.wResult(15) === "b0".U) {
            roundModule2.io.inputInt := Cat("b0".U(1.W), signedAddUnit2.io.wResult(15, 0))
          }.otherwise {
            roundModule2.io.inputInt := Cat("b1".U(1.W), signedAddUnit2.io.wResult(15, 0))
          }
        }

        when (io.gaddDataA(47) === addB_16_3(15)) {
          roundModule3.io.inputInt := signedAddUnit3.io.wResult
        }.otherwise {
          when (signedAddUnit3.io.wResult(15) === "b0".U) {
            roundModule3.io.inputInt := Cat("b0".U(1.W), signedAddUnit3.io.wResult(15, 0))
          }.otherwise {
            roundModule3.io.inputInt := Cat("b1".U(1.W), signedAddUnit3.io.wResult(15, 0))
          }
        }

        when (io.gaddDataA(63) === addB_16_4(15)) {
          roundModule4.io.inputInt := signedAddUnit4.io.wResult
        }.otherwise {
          when (signedAddUnit4.io.wResult(15) === "b0".U) {
            roundModule4.io.inputInt := Cat("b0".U(1.W), signedAddUnit4.io.wResult(15, 0))
          }.otherwise {
            roundModule4.io.inputInt := Cat("b1".U(1.W), signedAddUnit4.io.wResult(15, 0))
          }
        }

      }.otherwise {
        roundModule1.io.inputInt := signedAddUnit1.io.wResult
        roundModule2.io.inputInt := signedAddUnit2.io.wResult
        roundModule3.io.inputInt := signedAddUnit3.io.wResult
        roundModule4.io.inputInt := signedAddUnit4.io.wResult
      }









      roundModule1.io.vxrm := io.vxrm
      roundModule2.io.vxrm := io.vxrm
      roundModule3.io.vxrm := io.vxrm
      roundModule4.io.vxrm := io.vxrm
      io.gaddResult := Cat(roundModule4.io.outputInt, roundModule3.io.outputInt, roundModule2.io.outputInt,
        roundModule1.io.outputInt)


    }.otherwise {
      //进位饱和指令
      when (io.signFlag === 0.U) {
        //无符号数的溢出位直接由结果最高位获得
        tempVxsat1 := signedAddUnit1.io.wResult(16)
        tempVxsat2 := signedAddUnit2.io.wResult(16)
        tempVxsat3 := signedAddUnit3.io.wResult(16)
        tempVxsat4 := signedAddUnit4.io.wResult(16)
        when (signedAddUnit1.io.wResult(16) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_16_1 := "h0000".U
          }.otherwise {
            tempResult_16_1 := "hffff".U
          }
        }.otherwise {
          tempResult_16_1 := signedAddUnit1.io.wResult(15, 0)
        }

        when (signedAddUnit2.io.wResult(16) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_16_2 := "h0000".U
          }.otherwise {
            tempResult_16_2 := "hffff".U
          }
        }.otherwise {
          tempResult_16_2 := signedAddUnit2.io.wResult(15, 0)
        }

        when (signedAddUnit3.io.wResult(16) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_16_3 := "h0000".U
          }.otherwise {
            tempResult_16_3 := "hffff".U
          }
        }.otherwise {
          tempResult_16_3 := signedAddUnit3.io.wResult(15, 0)
        }

        when (signedAddUnit4.io.wResult(16) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_16_4 := "h0000".U
          }.otherwise {
            tempResult_16_4 := "hffff".U
          }
        }.otherwise {
          tempResult_16_4 := signedAddUnit4.io.wResult(15, 0)
        }


      }.otherwise {
        //有符号数看运算前后符号位是否一致
        when (io.gaddDataA(15) === addB_16_1(15) && !(io.gaddDataA(15) === signedAddUnit1.io.wResult(15))) {
          //溢出情况
          tempVxsat1 := 1.U
          when (io.gaddDataA(15) === 0.U) {
            //整数设置最大值
            tempResult_16_1 := "h7fff".U
          }.otherwise {
            //负数设置最大值
            tempResult_16_1 := "h8000".U
          }
        }.otherwise {
          tempVxsat1 := 0.U
          tempResult_16_1 := signedAddUnit1.io.wResult(15, 0)
        }

        when (io.gaddDataA(31) === addB_16_2(15) && !(io.gaddDataA(31) === signedAddUnit2.io.wResult(15))) {
          //溢出情况
          tempVxsat2 := 1.U
          when (io.gaddDataA(31) === 0.U) {
            //整数设置最大值
            tempResult_16_2 := "h7fff".U
          }.otherwise {
            //负数设置最大值
            tempResult_16_2 := "h8000".U
          }
        }.otherwise {
          tempVxsat2 := 0.U
          tempResult_16_2 := signedAddUnit2.io.wResult(15, 0)
        }

        when (io.gaddDataA(47) === addB_16_3(15) && !(io.gaddDataA(47) === signedAddUnit3.io.wResult(15))) {
          //溢出情况
          tempVxsat3 := 1.U
          when (io.gaddDataA(47) === 0.U) {
            //整数设置最大值
            tempResult_16_3 := "h7fff".U
          }.otherwise {
            //负数设置最大值
            tempResult_16_3 := "h8000".U
          }
        }.otherwise {
          tempVxsat3 := 0.U
          tempResult_16_3 := signedAddUnit3.io.wResult(15, 0)
        }

        when (io.gaddDataA(63) === addB_16_4(15) && !(io.gaddDataA(63) === signedAddUnit4.io.wResult(15))) {
          //溢出情况
          tempVxsat4 := 1.U
          when (io.gaddDataA(63) === 0.U) {
            //整数设置最大值
            tempResult_16_4 := "h7fff".U
          }.otherwise {
            //负数设置最大值
            tempResult_16_4 := "h8000".U
          }
        }.otherwise {
          tempVxsat4 := 0.U
          tempResult_16_4 := signedAddUnit4.io.wResult(15, 0)
        }



      }
      io.gaddResult := Cat(tempResult_16_4, tempResult_16_3, tempResult_16_2, tempResult_16_1)

      io.vxsat := Cat(tempVxsat8, tempVxsat7, tempVxsat6, tempVxsat5, tempVxsat4, tempVxsat3, tempVxsat2, tempVxsat1)
      //io.vxsat := tempVxsat8 | tempVxsat7 | tempVxsat6 | tempVxsat5| tempVxsat4| tempVxsat3 |
      //  tempVxsat2| tempVxsat1


    }


  }.elsewhen(io.gaddDataWdith === "b10".U) {
    val signedAddUnit1 = Module(new unsignedAddSub(32))
    val signedAddUnit2 = Module(new unsignedAddSub(32))

    when (io.signFlag === 1.U && io.op === 1.U) {
      //有符号减法
      addB_complement_32_1 := ~io.gaddDataB(31, 0)
      addB_complement_32_2 := ~io.gaddDataB(63, 32)

      when (io.gaddDataB(31, 0) === "h80000000".U) {
        //-最大负数特殊情况
        addB_32_1 := addB_complement_32_1
      }.otherwise {

        addB_32_1 := addB_complement_32_1 + 1.U
      }

      when (io.gaddDataB(63, 32) === "h80000000".U) {
        //-最大负数特殊情况
        addB_32_2 := addB_complement_32_2
      }.otherwise {
        addB_32_2 := addB_complement_32_2 + 1.U
      }

    }.otherwise {
      addB_32_1 := io.gaddDataB(31, 0)
      addB_32_2 := io.gaddDataB(63, 32)
    }

    when (io.signFlag === 0.U && io.op === 1.U) {
      //无符号减
      signedAddUnit1.io.op := 1.U
      signedAddUnit2.io.op := 1.U

    }.otherwise {
      signedAddUnit1.io.op := 0.U
      signedAddUnit2.io.op := 0.U
    }


    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(31, 0) === "h80000000".U) {
      //有符号减-最大负数的情况
      signedAddUnit1.io.addC := 1.U
    }.otherwise {
      signedAddUnit1.io.addC := 0.U
    }

    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(63, 32) === "h80000000".U) {
      //有符号减-最大负数的情况
      signedAddUnit2.io.addC := 1.U
    }.otherwise {
      signedAddUnit2.io.addC := 0.U
    }



    signedAddUnit1.io.addA := io.gaddDataA(31, 0)
    signedAddUnit1.io.addB := addB_32_1
    signedAddUnit2.io.addA := io.gaddDataA(63, 32)
    signedAddUnit2.io.addB := addB_32_2

    when (io.shiftOrSat === 0.U) {
      //移位舍入指令
      val roundModule1 = Module(new rshiftRM(32))
      val roundModule2 = Module(new rshiftRM(32))
      when (io.signFlag === "b1".U ) {
        //有符号加减需要符号扩展
        when (io.gaddDataA(31) === addB_32_1(31)) {
          roundModule1.io.inputInt := signedAddUnit1.io.wResult
        }.otherwise {
          when (signedAddUnit1.io.wResult(31) === "b0".U) {
            roundModule1.io.inputInt := Cat("b0".U(1.W), signedAddUnit1.io.wResult(31, 0))
          }.otherwise {
            roundModule1.io.inputInt := Cat("b1".U(1.W), signedAddUnit1.io.wResult(31, 0))
          }
        }

        when (io.gaddDataA(63) === addB_32_2(31)) {
          roundModule2.io.inputInt := signedAddUnit2.io.wResult
        }.otherwise {
          when (signedAddUnit2.io.wResult(31) === "b0".U) {
            roundModule2.io.inputInt := Cat("b0".U(1.W), signedAddUnit2.io.wResult(31, 0))
          }.otherwise {
            roundModule2.io.inputInt := Cat("b1".U(1.W), signedAddUnit2.io.wResult(31, 0))
          }
        }

      }.otherwise {
        roundModule1.io.inputInt := signedAddUnit1.io.wResult
        roundModule2.io.inputInt := signedAddUnit2.io.wResult
      }


      roundModule1.io.vxrm := io.vxrm
      roundModule2.io.vxrm := io.vxrm

      io.gaddResult := Cat(roundModule2.io.outputInt, roundModule1.io.outputInt)
    }.otherwise {
      //进位饱和指令
      when (io.signFlag === 0.U) {
        //无符号数的溢出位直接由结果最高位获得
        tempVxsat1 := signedAddUnit1.io.wResult(32)
        tempVxsat2 := signedAddUnit2.io.wResult(32)
        when (signedAddUnit1.io.wResult(32) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_32_1 := "h00000000".U
          }.otherwise {
            tempResult_32_1 := "hffffffff".U
          }
        }.otherwise {
          tempResult_32_1 := signedAddUnit1.io.wResult(31, 0)
        }

        when (signedAddUnit2.io.wResult(32) === 1.U) {
          when (io.op === "b1".U) {
            tempResult_32_2 := "h00000000".U
          }.otherwise {
            tempResult_32_2 := "hffffffff".U
          }
        }.otherwise {
          tempResult_32_2 := signedAddUnit2.io.wResult(31, 0)
        }
      }.otherwise {
        //有符号数看运算前后符号位是否一致
        when (io.gaddDataA(31) === addB_32_1(31) && !(io.gaddDataA(31) === signedAddUnit1.io.wResult(31))) {
          //溢出情况
          tempVxsat1 := 1.U
          when (io.gaddDataA(31) === 0.U) {
            //整数设置最大值
            tempResult_32_1 := "h7fffffff".U
          }.otherwise {
            //负数设置最大值
            tempResult_32_1 := "h80000000".U
          }
        }.otherwise {
          tempVxsat1 := 0.U
          tempResult_32_1 := signedAddUnit1.io.wResult(31, 0)
        }

        //有符号数看运算前后符号位是否一致
        when (io.gaddDataA(63) === addB_32_2(31) && !(io.gaddDataA(63) === signedAddUnit2.io.wResult(31))) {
          //溢出情况
          tempVxsat2 := 1.U
          when (io.gaddDataA(63) === 0.U) {
            //整数设置最大值
            tempResult_32_2 := "h7fffffff".U
          }.otherwise {
            //负数设置最大值
            tempResult_32_2 := "h80000000".U
          }
        }.otherwise {
          tempVxsat2 := 0.U
          tempResult_32_2 := signedAddUnit2.io.wResult(31, 0)
        }

      }
      io.gaddResult := Cat(tempResult_32_2, tempResult_32_1)

      io.vxsat := Cat(tempVxsat8, tempVxsat7, tempVxsat6, tempVxsat5, tempVxsat4, tempVxsat3, tempVxsat2, tempVxsat1)
      //io.vxsat := tempVxsat8 | tempVxsat7 | tempVxsat6 | tempVxsat5| tempVxsat4| tempVxsat3 |
      //  tempVxsat2| tempVxsat1

    }



  }otherwise {

    val signedAddUnit1 = Module(new unsignedAddSub(64))


    when (io.signFlag === 1.U && io.op === 1.U) {
      //有符号减法
      addB_complement_64 := ~io.gaddDataB(63, 0)

      when (io.gaddDataB(63, 0) === "h8000000000000000".U) {
        //-最大负数特殊情况
        addB_64 := addB_complement_64
      }.otherwise {
        addB_64 := addB_complement_64 + 1.U
      }


    }.otherwise {
      addB_64 := io.gaddDataB(63, 0)
    }

    when (io.signFlag === 0.U && io.op === 1.U) {
      //无符号减
      signedAddUnit1.io.op := 1.U
    }.otherwise {
      signedAddUnit1.io.op := 0.U
    }


    when (io.signFlag === 1.U && io.op === 1.U && io.gaddDataB(63, 0) === "h8000000000000000".U) {
      //有符号减-最大负数的情况
      signedAddUnit1.io.addC := 1.U
    }.otherwise {
      signedAddUnit1.io.addC := 0.U
    }


    signedAddUnit1.io.addA := io.gaddDataA(63, 0)
    signedAddUnit1.io.addB := addB_64

    when (io.shiftOrSat === 0.U) {
      //移位舍入指令
      val roundModule1 = Module(new rshiftRM(64))
      when (io.signFlag === "b1".U ) {
        //有符号加减需要符号扩展
        when (io.gaddDataA(63) === addB_64(63)) {
          roundModule1.io.inputInt := signedAddUnit1.io.wResult
        }.otherwise {
          when (signedAddUnit1.io.wResult(63) === "b0".U) {
            roundModule1.io.inputInt := Cat("b0".U(1.W), signedAddUnit1.io.wResult(63, 0))
          }.otherwise {
            roundModule1.io.inputInt := Cat("b1".U(1.W), signedAddUnit1.io.wResult(63, 0))
          }
        }
      }.otherwise {
        roundModule1.io.inputInt := signedAddUnit1.io.wResult
      }
      roundModule1.io.vxrm := io.vxrm
      io.gaddResult := roundModule1.io.outputInt
    }.otherwise {
      //进位饱和指令
      when (io.signFlag === 0.U) {
        //无符号数的溢出位直接由结果最高位获得
        tempVxsat1 := signedAddUnit1.io.wResult(64)
        when (signedAddUnit1.io.wResult(64) === 1.U) {
          when (io.op === "b1".U) {
            io.gaddResult := "h0000000000000000".U
          }.otherwise {
            io.gaddResult := "hffffffffffffffff".U
          }
        }.otherwise {
          io.gaddResult := signedAddUnit1.io.wResult(63, 0)
        }
      }.otherwise {
        //有符号数看运算前后符号位是否一致
        when (io.gaddDataA(63) === addB_64(63) && !(io.gaddDataA(63) === signedAddUnit1.io.wResult(63))) {
          //溢出情况
          tempVxsat1 := 1.U
          when (io.gaddDataA(63) === 0.U) {
            //整数设置最大值
            io.gaddResult := "h7fffffffffffffff".U
          }.otherwise {
            //负数设置最大值
            io.gaddResult := "h8000000000000000".U
          }
        }.otherwise {
          tempVxsat1 := 0.U
          io.gaddResult := signedAddUnit1.io.wResult(63, 0)
        }
      }
      io.vxsat := Cat(tempVxsat8, tempVxsat7, tempVxsat6, tempVxsat5, tempVxsat4, tempVxsat3, tempVxsat2, tempVxsat1)
      //io.vxsat := tempVxsat8 | tempVxsat7 | tempVxsat6 | tempVxsat5| tempVxsat4| tempVxsat3 |
      //  tempVxsat2| tempVxsat1
    }
  }
}

class rshiftRM(width: Int = 32) extends Module {
  //整型舍入单元
  val io = IO(new Bundle() {
    val inputInt = Input(UInt((width + 1).W))
    val vxrm = Input(UInt(2.W)) //csr,设置舍入模式。00：rnu；01：rne；10：rdn；11：rod
    val outputInt = Output(UInt(width.W))
  })
  val tempInt = Wire(UInt(width.W))
  val increBit = Wire(UInt(1.W))
  tempInt := io.inputInt(width, 1)
  when(io.vxrm === "b00".U) {
    //rnu
    increBit := io.inputInt(0)
  }.elsewhen(io.vxrm === "b01".U) {
    //rne
    when (io.inputInt(0) === 0.U) {
      increBit := 0.U
    }.otherwise {
      increBit := io.inputInt(1)
    }

  }.elsewhen(io.vxrm === "b10".U) {
    //rdn
    increBit := 0.U
  }.otherwise {
    //rod
    when (io.inputInt(0) === 0.U) {
      increBit := 0.U
    }.otherwise {
      increBit := ~io.inputInt(1)
    }

  }
  io.outputInt := tempInt + increBit
}

class VGaddModule_ori extends Module{
  val io = IO(new Bundle() {
    //指令类型
    // 00000：vadd，    00001：vsub，     00010：vwadd.v，  00011：vwaddu.v；
    // 00100：vwsub.v， 00101：vwsubu.v， 00110：vwadd.w，  00111：vwaddu.w；
    // 01000：vwsub.w， 01001：vwsubu.w， 01010：vadc，     01011：vmadc；
    // 01100：vmadc.m， 01101：vsbc，     01110：vmsbc，    01111：vmsbc.m，  10000：vaaddu；
    // 10001：vaadd，   10010：vasub，   10011：vasubu；  10100：vsaddu，   10101：vsadd；
    // 10110：vssub，   10111：vssubu
    val Gadd_insn = Input(UInt(5.W))
    val Gadd_data_a = Input(UInt(64.W))             //输入数据a，加数
    val Gadd_data_b = Input(UInt(64.W))             //输入数据b，加数
    val Gadd_data_c = Input(UInt(8.W))              //进位输入
    //数据位宽（SEW），分别对应00：8位；01：16位；10：32位；11：64位
    val Gadd_data_width = Input(UInt(2.W))
    //mask值，当element数为1时（SEW=64），最低位[0]有效；当element数为2时（SEW=32），低两位[1：0]有效，以此类推；
    val Gadd_mask = Input(UInt(8.W))
    //csr,设置舍入模式。00：rnu；01：rne；10：rdn；11：rod
    val Gadd_vxrm = Input(UInt(2.W))
    val Gadd_data_valid = Input(UInt(1.W))          //输入数据有效
    val Gadd_data_ready = Output(UInt(1.W))         //输入数据ready
    val Gadd_result = Output(UInt(64.W))            //计算结果
    val Gadd_result_valid = Output(UInt(1.W))       //计算结果valid
    val Gadd_vxsat = Output(UInt(8.W))              //csr，输出饱和位
  })
  io.Gadd_data_ready := 1.U
  io.Gadd_vxsat := 0.U
  io.Gadd_result := 0.U
  io.Gadd_result_valid := 0.U
  val Gadd_data_a_mask = Wire(UInt(64.W))
  val Gadd_data_b_mask = Wire(UInt(64.W))
  val mask_64 = Wire(UInt(64.W))
  Gadd_data_a_mask := 0.U
  Gadd_data_b_mask := 0.U
  mask_64 := 0.U
  when (io.Gadd_data_width === "b00".U) {
    mask_64 := Cat(~("hff".U(8.W) + io.Gadd_mask(7)), ~("hff".U(8.W) + io.Gadd_mask(6)), ~("hff".U(8.W) + io.Gadd_mask(5)), ~("hff".U(8.W) + io.Gadd_mask(4))
      , ~("hff".U(8.W) + io.Gadd_mask(3)), ~("hff".U(8.W) + io.Gadd_mask(2)), ~("hff".U(8.W) + io.Gadd_mask(1)), ~("hff".U(8.W) + io.Gadd_mask(0)))
  }

  when (io.Gadd_data_width === "b01".U) {
    mask_64 := Cat(~("hffff".U(16.W) + io.Gadd_mask(3)), ~("hffff".U(16.W) + io.Gadd_mask(2)), ~("hffff".U(16.W) + io.Gadd_mask(1)), ~("hffff".U(16.W) + io.Gadd_mask(0)))
  }

  when (io.Gadd_data_width === "b10".U) {
    mask_64 := Cat(~("hffffffff".U(32.W) + io.Gadd_mask(1)), ~("hffffffff".U(32.W) + io.Gadd_mask(0)))
  }

  when (io.Gadd_data_width === "b11".U) {
    mask_64 := Cat(~("hffffffffffffffff".U(64.W) + io.Gadd_mask(0)))
  }
  Gadd_data_a_mask := io.Gadd_data_a & mask_64
  Gadd_data_b_mask := io.Gadd_data_b & mask_64
  val vadd_vsub_m_c_m_Unit = Module(new vadd_vsub_m_c_m_Unit())
  val vwadd_vwsub_u_v_w_Unit = Module(new vwadd_vwsub_u_v_w_Unit())
  val vaadd_vaasub_vsadd_vssub_u_Unit = Module(new vaadd_vaasub_vsadd_vssub_u_Unit())
  vadd_vsub_m_c_m_Unit.io.gaddDataA := 0.U
  vadd_vsub_m_c_m_Unit.io.gaddDataB := 0.U
  vadd_vsub_m_c_m_Unit.io.gaddDataC := 0.U
  vadd_vsub_m_c_m_Unit.io.gaddDataWdith := 0.U
  vadd_vsub_m_c_m_Unit.io.op := 0.U
  vadd_vsub_m_c_m_Unit.io.carryOut := 0.U

  vwadd_vwsub_u_v_w_Unit.io.gaddDataA := 0.U
  vwadd_vwsub_u_v_w_Unit.io.gaddDataB := 0.U
  vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := 0.U
  vwadd_vwsub_u_v_w_Unit.io.op := 0.U

  vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := 0.U
  vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := 0.U
  vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := 0.U
  vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := 0.U
  vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 0.U
  vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 0.U
  vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 0.U

  when (io.Gadd_data_valid === "b1".U) {
    //输入数据valid
    io.Gadd_result_valid := 1.U
    when (io.Gadd_insn === "b00000".U) {
      //vadd
      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := 0.U
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 0.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 0.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult
    }.elsewhen(io.Gadd_insn === "b00001".U) {
      //vsub

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := 0.U
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 1.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 0.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b00010".U) {
      //vwadd.v

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b000".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b00011".U) {
      //vwaddu.v

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b001".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b00100".U) {
      //vwsub.v

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b010".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b00101".U) {
      //vwsubu.v

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b011".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b00110".U) {
      //vwadd.w

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b100".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b00111".U) {
      //vwaddu.w

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b101".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01000".U) {
      //vwsub.w

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b110".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01001".U) {
      //vwsubu.w

      vwadd_vwsub_u_v_w_Unit.io.gaddDataA := io.Gadd_data_a
      vwadd_vwsub_u_v_w_Unit.io.gaddDataB := io.Gadd_data_b
      vwadd_vwsub_u_v_w_Unit.io.gaddDataWdith := io.Gadd_data_width
      vwadd_vwsub_u_v_w_Unit.io.op := "b111".U
      io.Gadd_result := vwadd_vwsub_u_v_w_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01010".U) {
      //vadc

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := io.Gadd_data_c
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 0.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 0.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01011".U) {
      //vmadc

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := 0.U
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 0.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 1.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01100".U) {
      //vmadc.m

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := io.Gadd_data_c
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 0.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 1.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01101".U) {
      //vsbc

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := io.Gadd_data_c
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 1.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 0.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01110".U) {
      //vmsbc

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := 0.U
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 1.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 1.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b01111".U) {
      //vmsbc.m

      vadd_vsub_m_c_m_Unit.io.gaddDataA := io.Gadd_data_a
      vadd_vsub_m_c_m_Unit.io.gaddDataB := io.Gadd_data_b
      vadd_vsub_m_c_m_Unit.io.gaddDataC := io.Gadd_data_c
      vadd_vsub_m_c_m_Unit.io.gaddDataWdith := io.Gadd_data_width
      vadd_vsub_m_c_m_Unit.io.op := 1.U
      vadd_vsub_m_c_m_Unit.io.carryOut := 1.U
      io.Gadd_result := vadd_vsub_m_c_m_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b10000".U) {
      //vaaddu

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := io.Gadd_vxrm
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 0.U //加
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 0.U //无符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 0.U //移位舍入
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b10001".U) {
      //vaadd

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := io.Gadd_vxrm
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 0.U //加
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 1.U //有符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 0.U //移位舍入
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b10010".U) {
      //vaasub

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := io.Gadd_vxrm
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 1.U //减
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 1.U //有符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 0.U //移位舍入
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b10011".U) {
      //vaasubu

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := io.Gadd_vxrm
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 1.U //减
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 0.U //无符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 0.U //移位舍入
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult

    }.elsewhen(io.Gadd_insn === "b10100".U) {
      //vsaddu

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := 0.U
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 0.U //加
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 0.U //无符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 1.U //饱和
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult
      io.Gadd_vxsat := vaadd_vaasub_vsadd_vssub_u_Unit.io.vxsat

    }.elsewhen(io.Gadd_insn === "b10101".U) {
      //vsadd

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := 0.U
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 0.U //加
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 1.U //有符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 1.U //饱和
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult
      io.Gadd_vxsat := vaadd_vaasub_vsadd_vssub_u_Unit.io.vxsat

    }.elsewhen(io.Gadd_insn === "b10110".U) {
      //vssub

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := 0.U
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 1.U //减
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 1.U //有符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 1.U //饱和
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult
      io.Gadd_vxsat := vaadd_vaasub_vsadd_vssub_u_Unit.io.vxsat

    }.elsewhen(io.Gadd_insn === "b10111".U) {
      //vssubu

      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataA := io.Gadd_data_a
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataB := io.Gadd_data_b
      vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddDataWdith := io.Gadd_data_width
      vaadd_vaasub_vsadd_vssub_u_Unit.io.vxrm := 0.U
      vaadd_vaasub_vsadd_vssub_u_Unit.io.op := 1.U //减
      vaadd_vaasub_vsadd_vssub_u_Unit.io.signFlag := 0.U //无符号
      vaadd_vaasub_vsadd_vssub_u_Unit.io.shiftOrSat := 1.U //饱和
      io.Gadd_result := vaadd_vaasub_vsadd_vssub_u_Unit.io.gaddResult
      io.Gadd_vxsat := vaadd_vaasub_vsadd_vssub_u_Unit.io.vxsat

    }
  }




}

class VGaddModule extends Module{
  val io = IO(new Bundle() {
    //指令类型
    // 00000：vadd，    00001：vsub，     00010：vwadd.v，  00011：vwaddu.v；
    // 00100：vwsub.v， 00101：vwsubu.v， 00110：vwadd.w，  00111：vwaddu.w；
    // 01000：vwsub.w， 01001：vwsubu.w， 01010：vadc，     01011：vmadc；
    // 01100：vmadc.m， 01101：vsbc，     01110：vmsbc，    01111：vmsbc.m，  10000：vaaddu；
    // 10001：vaadd，   10010：vasub，   10011：vasubu；  10100：vsaddu，   10101：vsadd；
    // 10110：vssub，   10111：vssubu
    val Gadd_insn = Input(UInt(5.W))
    val Gadd_data_a = Input(UInt(64.W))             //输入数据a，加数
    val Gadd_data_b = Input(UInt(64.W))             //输入数据b，加数
    val Gadd_data_c = Input(UInt(8.W))              //进位输入
    //数据位宽（SEW），分别对应00：8位；01：16位；10：32位；11：64位
    val Gadd_data_width = Input(UInt(2.W))
    //mask值，当element数为1时（SEW=64），最低位[0]有效；当element数为2时（SEW=32），低两位[1：0]有效，以此类推；
    val Gadd_mask = Input(UInt(8.W))
    //csr,设置舍入模式。00：rnu；01：rne；10：rdn；11：rod
    val Gadd_vxrm = Input(UInt(2.W))
    val Gadd_data_valid = Input(UInt(1.W))          //输入数据有效
    val Gadd_data_ready = Output(UInt(1.W))         //输入数据ready
    val Gadd_result = Output(UInt(64.W))            //计算结果
    val Gadd_result_valid = Output(UInt(1.W))       //计算结果valid
    val Gadd_vxsat = Output(UInt(8.W))              //csr，输出饱和位
  })
  val vgadd_ori = Module(new VGaddModule_ori())
  vgadd_ori.io.Gadd_insn := RegNext(io.Gadd_insn)
  vgadd_ori.io.Gadd_data_a := RegNext(io.Gadd_data_a)
  vgadd_ori.io.Gadd_data_b := RegNext(io.Gadd_data_b)
  vgadd_ori.io.Gadd_data_c := RegNext(io.Gadd_data_c)
  vgadd_ori.io.Gadd_data_width := RegNext(io.Gadd_data_width)
  vgadd_ori.io.Gadd_mask := RegNext(io.Gadd_mask)
  vgadd_ori.io.Gadd_vxrm := RegNext(io.Gadd_vxrm)
  vgadd_ori.io.Gadd_data_valid := RegNext(io.Gadd_data_valid)
  io.Gadd_data_ready := 1.U
  io.Gadd_result := RegNext(vgadd_ori.io.Gadd_result)
  io.Gadd_result_valid := RegNext(vgadd_ori.io.Gadd_result_valid)
  io.Gadd_vxsat := RegNext(vgadd_ori.io.Gadd_vxsat)
}

object vgaddLauncher extends App {
  emitVerilog(new VGaddModule(),Array("--target-dir","./Verilog"))
}
