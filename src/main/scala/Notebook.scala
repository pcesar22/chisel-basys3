// See README.md for license details.

package notebook

import chisel3._
import chisel3.util._
import chisel3.iotesters.{Driver, PeekPokeTester, ChiselFlatSpec}

object Utils {
  def getVerilog(dut: => chisel3.core.UserModule, path: String): String = {
    import firrtl._
    return chisel3.Driver.execute(Array[String]("--target-dir", s"$path"), {
      () => dut
    }) match {
      case s: chisel3.ChiselExecutionSuccess =>
        s.firrtlResultOption match {
          case Some(f: FirrtlExecutionSuccess) => f.emitted
        }
    }
  }
}

class CombLogicTop extends RawModule  {
  val clk = IO(Input(Clock()))
  val btnC = IO(Input(Bool()))
  val sw = IO(Input(UInt(12.W)))
  val led = IO(Output(UInt(8.W)))

  val module = withClockAndReset(clk, btnC) {
    Module(new CombLogic)
  }

  module.io.in_a := sw(3,0)
  module.io.in_b := sw(7,4)
  module.io.in_c := sw(11,8)
  led := module.io.out
}

class CombLogic extends Module {
  val io = IO(new Bundle {
    val in_a = Input(UInt(4.W))
    val in_b = Input(UInt(4.W))
    val in_c = Input(UInt(4.W))
    val out = Output(UInt(8.W))
  })

  // Exercise
  val prod = io.in_a * io.in_b
  io.out := prod + Cat(0.U(4.W), io.in_c)
}

object CombLogicMain extends App {
  println(Utils.getVerilog(new CombLogicTop, "basys3/comb_logic"))
}
