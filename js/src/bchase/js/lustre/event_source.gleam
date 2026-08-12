import bchase/io
import bchase/js/event_source
import bchase/web/sse
import gleam/option.{type Option, None, Some}
import gleam/result
import lustre/effect.{type Effect}

pub type SSE(t) = event_source.SSE(t)
pub type EventSource = event_source.EventSource

pub fn connect(
  sse sse: SSE(broadcast),
  msg wrap: fn(broadcast) -> msg,
  connected connected: Option(fn(EventSource) -> msg)
) -> Effect(msg) {
  effect.from(fn(dispatch) {
    event_source.connect(
      endpoint: sse,
      on_message: fn(msg) { dispatch(wrap(msg)) },
      overrides: event_source.log_open_close_err(),
    )
    |> result.map(fn(event_source) {
      case connected {
        Some(connected) -> dispatch(connected(event_source))
        None -> Nil
      }
    })
    |> result.map_error(fn(_) {
      io.println_error(
        "SSE failed to connect: " <> sse.path(sse)
      )
    })
    |> result.unwrap(Nil)
  })
}
