import gleam/dynamic.{type Dynamic}
import gleeunit
import gleeunit/should
import bchase/js/object.{Prop, Index}

pub fn main() -> Nil {
  gleeunit.main()
}

@external(javascript, "./js.mjs", "test_object")
fn test_object() -> Dynamic

@external(javascript, "./js.mjs", "test_object_with_array")
fn test_object_with_array() -> Dynamic

pub fn object_at_test() {
  test_object()
  |> object.at([Prop("foo"), Prop("bar")])
  |> should.equal(dynamic.int(123))

  test_object_with_array()
  |> object.at([Prop("foo"), Prop("bar"), Index(2), Prop("baz")])
  |> should.equal(dynamic.string("boo"))
}
