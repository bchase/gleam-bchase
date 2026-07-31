import gleam/dynamic/decode.{type Decoder}
import gleam/float
import gleam/int
import gleam/result

pub type Number {
  Int(int: Int)
  Float(float: Float)
}

// CONV

pub fn to_int(num num: Number) -> Int {
  num |> to_int_(conv: float.truncate)
}

pub fn to_int_(num num: Number, conv f: fn(Float) -> Int) -> Int {
  case num {
    Int(int:) -> int
    Float(float:) -> f(float)
  }
}

pub fn to_float(num num: Number) -> Float {
  num |> to_float_(conv: int.to_float)
}

pub fn to_float_(num num: Number, conv f: fn(Int) -> Float) -> Float {
  case num {
    Int(int:) -> f(int)
    Float(float:) -> float
  }
}

// OPERATIONS

pub fn add(
  num1 num1: Number,
  num2 num2: Number,
) -> Number {
  case num1, num2 {
    Int(int: i1), Int(int: i2) -> Int(int.add(i1, i2))

    Float(float: f1), Float(float: f2) -> Float(float.add(f1, f2))

    Int(int:), Float(float:) |
    Float(float:), Int(int:) ->
      Float(float.add(float, int.to_float(int)))
  }
}

pub fn add_(
  num1 num1: Number,
  num2 num2: Number,
  add add: fn(Int, Float) -> Number,
) -> Number {
  case num1, num2 {
    Int(int: i1), Int(int: i2) -> Int(int.add(i1, i2))

    Float(float: f1), Float(float: f2) -> Float(float.add(f1, f2))

    Int(int:), Float(float:) | Float(float:), Int(int:) -> add(int, float)
  }
}

// PARSE

pub fn parse(str str: String) -> Result(Number, Nil) {
  parse_int(str)
  |> result.lazy_or(fn() { parse_float(str) })
}

fn parse_float(str str: String) -> Result(Number, Nil) {
  str
  |> float.parse
  |> result.map(Float)
}

fn parse_int(str str: String) -> Result(Number, Nil) {
  str
  |> int.parse
  |> result.map(Int)
}

// DISPLAY

pub fn to_string(num num: Number) -> String {
  case num {
    Int(int:) -> int.to_string(int)
    Float(float:) -> float.to_string(float)
  }
}

// DECODERS

pub fn decoder_number_str_or_int_or_float() -> Decoder(Number) {
  decode.one_of(decoder_number_str(), [
    decoder_number_int_or_float(),
  ])
}

pub fn decoder_number_int_or_float_or_str() -> Decoder(Number) {
  decode.one_of(decoder_number_int_or_float(), [
    decoder_number_str(),
  ])
}

pub fn decoder_number_int_or_float() -> Decoder(Number) {
  decode.one_of(decoder_int(), [
    decoder_float(),
  ])
}

fn decoder_number_str() -> Decoder(Number) {
  decode.string
  |> decode.then(fn(str) {
    case parse(str) {
      Ok(num) -> decode.success(num)
      Error(_) -> decode.failure(zero, "Number")
    }
  })
}

const zero = Int(0)

fn decoder_int() -> Decoder(Number) {
  decode.int |> decode.map(Int)
}

fn decoder_float() -> Decoder(Number) {
  decode.float |> decode.map(Float)
}
