import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option}
import gleam/time/timestamp.{type Timestamp}

pub type Transcoder(t) {
  Transcoder(
    encode: fn(t) -> Json,
    decoder: fn() -> Decoder(t),
  )
}

pub const string = Transcoder(json.string, decode_string)

pub const int = Transcoder(json.int, decode_int)

pub const float = Transcoder(json.float, decode_float)

pub const bool = Transcoder(json.bool, decode_bool)

pub const nil = Transcoder(encode_nil, decoder_nil)

pub fn encode_nil(_nil: Nil) {
  json.null()
}

pub fn decoder_nil() -> Decoder(Nil) {
  decode.success(Nil)
}

pub fn result(
  ok ok: Transcoder(t),
  err err: Transcoder(err)
) -> Transcoder(Result(t, err)) {
  Transcoder(
    encode: encode_result(_, ok.encode, err.encode),
    decoder: fn() { decoder_result(ok.decoder(), err.decoder()) },
  )
}

pub fn option(transcoder transcoder: Transcoder(t)) -> Transcoder(Option(t)) {
  Transcoder(json.nullable(_, transcoder.encode), fn() {
    decode.optional(transcoder.decoder())
  })
}

pub fn list(transcoder transcoder: Transcoder(t)) -> Transcoder(List(t)) {
  Transcoder(json.array(_, transcoder.encode), fn() {
    decode.list(transcoder.decoder())
  })
}

pub fn dict(transcoder transcoder: Transcoder(t)) -> Transcoder(Dict(String, t)) {
  Transcoder(
    encode: json.dict(_, fn(str) { str }, transcoder.encode),
    decoder: fn() { decode.dict(decode.string, transcoder.decoder()) },
  )
}

fn decode_string() {
  decode.string
}

fn decode_int() {
  decode.int
}

fn decode_float() {
  decode.float
}

fn decode_bool() {
  decode.bool
}

//

pub fn encode_result(
  result result: Result(t, err),
  ok encode_ok: fn(t) -> Json,
  err encode_error: fn(err) -> Json,
) -> Json {
  case result {
    Ok(x) -> json.object([#("ok", encode_ok(x))])
    Error(err) -> json.object([#("error", encode_error(err))])
  }
}

pub fn decoder_result(
  ok ok: Decoder(t),
  err err: Decoder(err),
) -> Decoder(Result(t, err)) {
  decode.one_of(
    decoder_result_ok(ok:),
    [decoder_result_err(err:)],
  )
}

pub fn decoder_result_ok(
  ok decoder_ok: Decoder(t),
) -> Decoder(Result(t, err)) {
  use x <- decode.field("ok", decoder_ok)
  decode.success(Ok(x))
}

pub fn decoder_result_err(
  err decoder_error: Decoder(err),
) -> Decoder(Result(t, err)) {
  use err <- decode.field("error", decoder_error)
  decode.success(Error(err))
}

//

pub const timestamp = Transcoder(encode_timestamp, decoder_timestamp)

pub fn encode_timestamp(
  timestamp timestamp: Timestamp,
) -> Json {
  let #(seconds, nanoseconds) =
    timestamp.to_unix_seconds_and_nanoseconds(timestamp)

  json.object([
    #("s", json.int(seconds)),
    #("ns", json.int(nanoseconds)),
  ])
}

pub fn decoder_timestamp() -> Decoder(Timestamp) {
  use s <- decode.field("s", decode.int)
  use ns <- decode.field("ns", decode.int)

  decode.success(timestamp.from_unix_seconds_and_nanoseconds(s, ns))
}
