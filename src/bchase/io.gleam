import gleam/string
import gleam/io

pub const print = io.print
pub const print_error = io.print_error
pub const println = io.println
pub const println_error = io.println_error

pub fn log(
  lines lines: List(String),
) -> Nil {
  log_(lines, io.println)
}

pub fn log_err(
  lines lines: List(String),
) -> Nil {
  log_(lines, io.println_error)
}

fn log_(
  lines: List(String),
  io: fn(String) -> Nil,
) -> Nil {
  lines
  |> string.join("\n")
  |> io
}
