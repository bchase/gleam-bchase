import gleam/result

pub fn guard(
  result result: Result(a, err),
  fail fail: fn(err) -> b,
  cont cont: fn(a) -> b,
) -> b {
  case result {
    Ok(x) -> cont(x)
    Error(err) -> fail(err)
  }
}

pub fn try_fail(
  result result: Result(a, err1),
  err err: err2,
  cont cont: fn(a) -> Result(b, err1),
) -> Result(b, err2) {
  result
  |> result.try(cont)
  |> result.replace_error(err)
}

pub fn try_fail_(
  result result: Result(a, err1),
  err fail: fn(err1) -> Result(b, err2),
  cont cont: fn(a) -> Result(b, err2),
) -> Result(b, err2) {
  case result {
    Error(err) -> fail(err)
    Ok(x) -> cont(x)
  }
}

pub fn try_err(
  result result: Result(a, err1),
  err wrap: fn(err1) -> err2,
  cont cont: fn(a) -> Result(b, err2),
) -> Result(b, err2) {
  result
  |> result.map_error(wrap)
  |> result.try(cont)
}

pub fn try_unwrap(
  result result: Result(a, err),
  default default: b,
  cont cont: fn(a) -> b,
) -> b {
  {
    use x <- result.try(result)
    Ok(cont(x))
  }
  |> result.unwrap(default)
}

pub fn try_unwrap_(
  result result: Result(a, err),
  default default: fn() -> b,
  cont cont: fn(a) -> b,
) -> b {
  {
    use x <- result.try(result)
    Ok(cont(x))
  }
  |> result.lazy_unwrap(default)
}
