import gleam/dict.{type Dict}
import gleam/list

pub fn keyed(
  xs: List(t),
  key: fn(t) -> key,
) -> Dict(key, t) {
  xs
  |> list.map(fn(x) { #(key(x), x) })
  |> dict.from_list
}

