import gleam/list
import gleam/option.{type Option, None, Some}

pub type RemoteData(t, err) {
  NotAsked
  Loading
  Failure(err: err)
  Success(data: t)
}

//

pub fn unwrap(
  data data: RemoteData(t, err),
  default default: t,
) -> t {
  case data {
    Success(data:) -> data
    _ -> default
  }
}

pub fn unwrap_lazy(
  data data: RemoteData(t, err),
  err f: fn(Option(err)) -> t,
) -> t {
  case data {
    Success(data:) -> data
    NotAsked -> f(None)
    Loading -> f(None)
    Failure(err:) -> f(Some(err))
  }
}

//

pub fn is_not_asked(
  data data: RemoteData(t, err),
) -> Bool {
  data == NotAsked
}

pub fn is_loading(
  data data: RemoteData(t, err),
) -> Bool {
  data == Loading
}

pub fn is_failure(
  data data: RemoteData(t, err),
) -> Bool {
  case data {
    Failure(..) -> True
    _ -> False
  }
}

pub fn is_success(
  data data: RemoteData(t, err),
) -> Bool {
  case data {
    Success(..) -> True
    _ -> False
  }
}

//

pub fn try(
  data data: RemoteData(a, err),
  cont cont: fn(a) -> RemoteData(b, err),
) -> RemoteData(b, err) {
  bind(data, cont)
}

pub fn bind(
  data data: RemoteData(a, err),
  cont cont: fn(a) -> RemoteData(b, err),
) -> RemoteData(b, err) {
  case data {
    NotAsked -> NotAsked
    Loading -> Loading
    Failure(err:) -> Failure(err:)
    Success(data:) -> cont(data)
  }
}

//

pub fn map(
  data data: RemoteData(a, err),
  apply f: fn(a) -> b,
) -> RemoteData(b, err) {
  use x <- bind(data)
  Success(f(x))
}

pub fn map2(
  data1 data1: RemoteData(a, err),
  data2 data2: RemoteData(b, err),
  apply f: fn(a, b) -> c,
) -> RemoteData(c, err) {
  use x <- bind(data1)
  use y <- bind(data2)
  Success(f(x, y))
}

pub fn map3(
  data1 data1: RemoteData(a, err),
  data2 data2: RemoteData(b, err),
  data3 data3: RemoteData(c, err),
  apply f: fn(a, b, c) -> d,
) -> RemoteData(d, err) {
  use x <- bind(data1)
  use y <- bind(data2)
  use z <- bind(data3)
  Success(f(x, y, z))
}

pub fn map_error(
  data data: RemoteData(t, e1),
  apply f: fn(e1) -> e2,
) -> RemoteData(t, e2) {
  case data {
    NotAsked -> NotAsked
    Loading -> Loading
    Failure(err:) -> Failure(err: f(err))
    Success(data:) -> Success(data:)
  }
}

//

pub fn from_result(
  result result: Result(t, err),
) -> RemoteData(t, err) {
  case result {
    Ok(x) -> Success(x)
    Error(err) -> Failure(err)
  }
}

pub fn to_result(
  data data: RemoteData(t, err),
  loading loading: err,
  not_asked not_asked: err,
) -> Result(t, err) {
  case data {
    NotAsked -> Error(not_asked)
    Loading -> Error(loading)
    Failure(err:) -> Error(err)
    Success(data:) -> Ok(data)
  }
}

//

pub fn from_option(
  option option: Option(t),
  err err: err,
) -> RemoteData(t, err) {
  case option {
    Some(x) -> Success(x)
    None -> Failure(err)
  }
}

pub fn to_option(
  data data: RemoteData(t, err),
) -> Option(t) {
  case data {
    NotAsked |
    Loading |
    Failure(..) -> None
    Success(data:) -> Some(data)
  }
}

//

pub fn from_list(
  list list: List(RemoteData(t, err)),
) -> RemoteData(List(t), err) {
  list.fold_until(list, NotAsked, fn(acc, data) {
    case acc, data {
      Success(data: xs), Success(data: x) ->
        list.Continue(Success(data: [x, ..xs]))

      acc, _ ->
        list.Stop(acc)
    }
  })
  |> map(list.reverse)
}
