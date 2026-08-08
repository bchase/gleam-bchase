import gleam/option.{type Option, Some, None}

pub fn guard(
  option option: Option(a),
  fail fail: b,
  cont cont: fn(a) -> b,
) -> b {
  case option {
    Some(x) -> cont(x)
    None -> fail
  }
}

pub fn pair(
  x: Option(a),
  y: Option(b),
) -> Option(#(a, b)) {
  case x, y {
    Some(x), Some(y) -> Some(#(x, y))
    _, _ -> None
  }
}
