import gleam/string
import bchase/json.{type Transcoder} as bchase_json

pub type SSE(t) = Endpoint(Nil, t)
pub type WebSocket(input, output) = Endpoint(input, output)

pub opaque type Type {
  WebSocket
  SSE
}

pub opaque type Endpoint(input, output) {
  Endpoint(
    type_: Type,
    path: List(String),
    input: Transcoder(input),
    output: Transcoder(output),
  )
}

//

pub fn websocket(
  path path: List(String),
  input input: Transcoder(input),
  output output: Transcoder(output),
) -> WebSocket(input, output) {
  Endpoint(type_: WebSocket, path:, input:, output:)
}

pub fn sse(
  path path: List(String),
  json json: Transcoder(t),
) -> SSE(t) {
  Endpoint(type_: SSE, path:, input: bchase_json.nil(), output: json)
}

//

pub fn path(
  endpoint endpoint: Endpoint(a, b)
) -> String {
  path_(endpoint.path)
}

pub fn path_(
  path path: List(String),
) -> String {
  "/" <> { path |> string.join("/") }
}

pub fn input(
  endpoint endpoint: Endpoint(input, input)
) -> Transcoder(input) {
  endpoint.input
}

pub fn output(
  endpoint endpoint: Endpoint(input, output)
) -> Transcoder(output) {
  endpoint.output
}
