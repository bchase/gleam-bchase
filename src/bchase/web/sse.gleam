import gleam/string
import bchase/json.{type Transcoder} as _

pub type SSE(t) {
  SSE(
    path_segments: List(String),
    json: Transcoder(t),
  )
}

//

pub fn path(
  endpoint endpoint: SSE(t),
) -> String {
  "/" <> { endpoint.path_segments |> string.join("/") }
}
