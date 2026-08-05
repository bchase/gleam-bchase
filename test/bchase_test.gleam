import gleam/bool
import bchase/io
import gleam/result
import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import bchase/dynamic as dyn
import bchase/unsafe
import gleam/dynamic/decode
import gleeunit
import gleeunit/should
import bchase/json.{type Transcoder} as _

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

// //

// pub type Endpoint(input, output) {
//   Endpoint(
//     path_segments: List(String),
//     input: Transcoder(input),
//     output: Transcoder(output),
//   )
// }

// pub fn router(
//   lookup lookup: List(#(List(String), fn(req, ctx) -> resp)),
//   custom custom: fn(List(String), req, ctx) -> Result(resp, Nil),
//   fallback fallback: resp,
//   zero zero: #(req, ctx),
// ) -> fn(List(String), req, ctx) -> resp {
//   let #(lookup, shadowed) = build_lookup_and_shadowed(lookup:, custom:, zero:)

//   {
//     io.println_error(
//       "[WARNING] The following paths are shadowed in your router:\n" <> {
//         shadowed
//         |> list.map(string.inspect)
//         |> list.map(string.append("  ", suffix: _))
//         |> string.join("\n")
//       }
//     )
//   }

//   fn(path_segments, req, ctx) {
//     case dict.get(lookup, path_segments) {
//       Ok(handle) ->
//         handle(req, ctx)

//       Error(Nil) ->
//         custom(path_segments, req, ctx)
//         |> result.unwrap(fallback)
//     }
//   }
// }

// fn build_lookup_and_shadowed(
//   lookup orig: List(#(List(String), fn(req, ctx) -> resp)),
//   custom custom: fn(List(String), req, ctx) -> Result(resp, Nil),
//   zero zero: #(req, ctx),
// ) -> #(Dict(List(String), fn(req, ctx) -> resp), List(List(String))) {
//   let lookup = orig |> dict.from_list

//   let shadowed_lookup =
//     orig
//     |> list.group(fn(t) { t.0 })
//     |> dict.to_list
//     |> list.filter_map(fn(t) {
//       case t.1 {
//         [_, _, ..] ->
//           Ok(t.0)

//         [] | [_] ->
//           Error(Nil)
//       }
//     })

//   let shadowed_custom =
//     lookup
//     |> dict.keys
//     |> list.filter(fn(path) {
//       custom(path, zero.0, zero.1)
//       |> result.is_ok
//     })

//   #(lookup, list.append(shadowed_lookup, shadowed_custom))
// }

// fn connect_path(
//   endpoint endpoint: Endpoint(input, output),
// ) -> String {
//   "/" <> { endpoint.path_segments |> string.join("/") }
// }

// pub fn unify_test() {
// }
