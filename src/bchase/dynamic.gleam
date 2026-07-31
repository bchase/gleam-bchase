import gleam/dynamic

pub type Dynamic =
  dynamic.Dynamic

@external(erlang, "bchase", "identity")
@external(javascript, "../bchase.mjs", "identity")
pub fn from(a: a) -> Dynamic
