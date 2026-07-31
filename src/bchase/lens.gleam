import bchase/function

pub type Lens(parent, child) {
  Lens(
    get: fn(parent) -> child,
    set: fn(parent, child) -> parent,
  )
}

pub const combine = x

pub fn x(outer: Lens(a, b), inner: Lens(b, c)) -> Lens(a, c) {
  Lens(
    get: fn(a) {
      a
      |> outer.get
      |> inner.get
    },
    set: fn(a, c) {
      a
      |> outer.get
      |> inner.set(c)
      |> outer.set(a, _)
    },
  )
}

pub const identity = Lens(function.identity, set_identity)
fn set_identity(_, x) { x }
