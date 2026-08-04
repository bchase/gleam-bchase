import gleam/string
import bchase/json.{type Transcoder} as _

pub type SSE(t) = Endpoint(Nil, t)
pub type WebSocket(input, output) = Endpoint(input, output)

pub type Endpoint(input, output) {
  WebSocket(
    path_segments: List(String),
    input: Transcoder(input),
    output: Transcoder(output),
  )
  SSE(
    path_segments: List(String),
    output: Transcoder(output),
  )
}

//

pub fn path(
  endpoint endpoint: Endpoint(a, b)
) -> String {
  "/" <> { endpoint.path_segments |> string.join("/") }
}
