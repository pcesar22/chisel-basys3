// See README.md for license details.

package notebook

import chisel3._
import chisel3.util._
import chisel3.iotesters.{Driver, PeekPokeTester, ChiselFlatSpec}

object Utils {
  def getVerilog(dut: => chisel3.core.UserModule): String = {
    import firrtl._
    return chisel3.Driver.execute(Array[String](), { () => dut }) match {
      case s: chisel3.ChiselExecutionSuccess =>
        s.firrtlResultOption match {
          case Some(f: FirrtlExecutionSuccess) => f.emitted
        }
    }
  }
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
  println(Utils.getVerilog(new CombLogic))
}
