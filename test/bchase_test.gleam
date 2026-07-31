import bchase/dynamic as dyn
import bchase/unsafe
import gleam/dynamic/decode
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn dynamic_from_test() {
  123
  |> dyn.from
  |> decode.run(decode.int)
  |> should.be_ok
  |> should.equal(123)

  "asdf"
  |> dyn.from
  |> decode.run(decode.string)
  |> should.be_ok
  |> should.equal("asdf")
}

pub fn unsafe_cast_test() {
  123
  |> dyn.from
  |> unsafe.cast
  |> should.equal(123)
}

pub fn unsafe_apply_test() {
  unsafe.apply(["gleam", "bool"], "negate", [False])
  |> should.be_ok
  |> should.equal(True)
}
