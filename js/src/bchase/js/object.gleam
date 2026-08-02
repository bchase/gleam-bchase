import gleam/list
import gleam/javascript/array.{type Array}
import gleam/dynamic.{type Dynamic}

pub type Key {
  Prop(String)
  Index(Int)
}

pub fn at(obj obj: Dynamic, path path: List(Key)) -> Dynamic {
  path
  |> list.map(fn(key) {
    case key {
      Prop(prop) -> dynamic.string(prop)
      Index(idx) -> dynamic.int(idx)
    }
  })
  |> array.from_list
  |> js_at(obj, _)
}

@external(javascript, "../js.mjs", "at")
fn js_at(obj: Dynamic, path: Array(Dynamic)) -> Dynamic
