// Notebook solutions and testbenches

package notebook

import chisel3._
import chisel3.util._
import chisel3.iotesters.{Driver, PeekPokeTester, ChiselFlatSpec}

class CombLogicTester(c: CombLogic) extends PeekPokeTester(c) {
  val cycles = 100
  import scala.util.Random
  for (i <- 0 until cycles) {
    val in_a = Random.nextInt(16)
    val in_b = Random.nextInt(16)
    val in_c = Random.nextInt(16)
    poke(c.io.in_a, in_a)
    poke(c.io.in_b, in_b)
    poke(c.io.in_c, in_c)
    expect(c.io.out, in_a * in_b + in_c)
  }
}

class NotebookUnitTester extends ChiselFlatSpec {
  "CombLogic" should "properly return the right results" in {
    iotesters.Driver.execute(
      Array(
        // "--backend-name",
        // "verilator",
        "--generate-vcd-output",
        "on",
        "--target-dir",
        "DebugWave",
        "--top-name",
        "CombLogicSimple"
      ),
      () => new CombLogic
    ) { c =>
      new CombLogicTester(c)
    } should be(true)
  }
}
