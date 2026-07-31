import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}

@external(erlang, "bchase", "identity")
@external(javascript, "../bchase.mjs", "identity")
pub fn cast(dynamic: Dynamic) -> a

@external(erlang, "unsafe_ffi", "undefined")
@external(javascript, "../unsafe_ffi.mjs", "undefined")
pub fn undefined() -> t

pub fn decoder_fail() -> Decoder(t) {
  decoder_fail_("`unsafe.undefined()`")
}

pub fn decoder_fail_(msg msg: String) -> Decoder(t) {
  decode.failure(undefined(), msg)
}

@external(erlang, "unsafe_ffi", "apply")
pub fn apply(
  module module: List(String),
  func func: String,
  args args: List(arg),
) -> Result(return, Nil)
