import bchase/pair.{flip} as _
import gleam/pair
import gleam/list

pub fn at(
  list: List(t),
  index idx: Int,
) -> Result(t, Nil) {
  list
  |> list.index_map(pair.new)
  |> list.map(flip)
  |> list.key_find(idx)
}

pub fn push(
  xs: List(t),
  x: t,
) -> List(t) {
  list.append(xs, [x])
}

pub fn reject(
  list: List(a),
  discarding predicate: fn(a) -> Bool,
) -> List(a) {
  list.filter(list, fn(x) { !predicate(x) })
}
