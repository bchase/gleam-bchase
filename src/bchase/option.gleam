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

