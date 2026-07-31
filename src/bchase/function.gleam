import gleam/function

pub const always = always1

pub fn always0(x: t) -> fn() -> t {
  fn() { x }
}

pub fn always1(x: t) -> fn(a) -> t {
  fn(_) { x }
}

pub fn always2(x: t) -> fn(a, b) -> t {
  fn(_, _) { x }
}

pub fn always3(x: t) -> fn(a, b, c) -> t {
  fn(_, _,_) { x }
}

pub fn always4(x: t) -> fn(a, b, c, e) -> t {
  fn(_, _, _,_) { x }
}

pub fn always5(x: t) -> fn(a, b, c, e, f) -> t {
  fn(_, _, _, _,_) { x }
}

pub fn always6(x: t) -> fn(a, b, c, e, f, g) -> t {
  fn(_, _,__, _, _, _) { x }
}

pub const identity = function.identity

pub fn flip(
  f: fn(a, b) -> c,
) -> fn(b, a) -> c {
  fn(b, a) { f(a, b) }
}

pub fn x(f: fn(b) -> c, g: fn(a) -> b) -> fn(a) -> c {
  fn(x) { f(g(x)) }
}

pub fn xx(f: fn(c) -> d, g: fn(b) -> c, h: fn(a) -> b) -> fn(a) -> d {
  fn(x) { f(g(h(x))) }
}

pub fn xxx(
  f: fn(d) -> e,
  g: fn(c) -> d,
  h: fn(b) -> c,
  i: fn(a) -> b,
) -> fn(a) -> e {
  fn(x) { f(g(h(i(x)))) }
}
