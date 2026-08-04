import bchase/dynamic.{type Dynamic}
import bchase/function
import bchase/io
import bchase/unsafe
import bchase/js/object
import bchase/web/endpoint.{type Endpoint}
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import plinth/browser/event as browser
import plinth/browser/eventsource.{type EventSource}
import plinth/browser/message_event as msg

pub type Overrides(t) {
  Overrides(
    on_open: Option(fn(String, browser.Event(Nil), fn(t) -> Nil) -> Nil),
    on_close: Option(fn(String, browser.Event(Nil), fn(t) -> Nil) -> Nil),
    before_message_dispatch: Option(fn(browser.Event(msg.T)) -> Nil),
    on_parse_err: Option(fn(Dynamic, List(decode.DecodeError), fn(t) -> Nil) -> Nil),
  )
}

pub fn no_overrides() -> Overrides(t) {
  Overrides(None, None, None, None)
}

pub fn log_open_close_err() -> Overrides(t) {
  Overrides(
    before_message_dispatch: None,
    on_open: Some(fn(path, _dispatch, _evt) {
      io.println("Connected to `EventSource`: " <> path)
    }),
    on_close: Some(fn(path, _dispatch, _evt) {
      io.println("Disconnected from `EventSource`: " <> path)
    }),
    on_parse_err: Some(fn(data, errs, _dispatch) {
      io.println_error(
        "`Endpoint` parse error: " <> string.inspect(errs) <> "\n" <>
        "MSG: " <> string.inspect(data)
      )
    }),
  )
}

pub fn connect(
  endpoint sse: Endpoint(Nil, t),
  on_message f: fn(t) -> Nil,
  overrides overrides: Overrides(t),
) -> Result(EventSource, Nil) {
  use connect <- result.try(eventsource.constructor())

  let on_open = overrides.on_open |> option.unwrap(function.always3(Nil))
  let on_close = overrides.on_close |> option.unwrap(function.always3(Nil))
  let on_parse_err =
    overrides.on_parse_err
    |> option.unwrap(fn(data, errs, _dispatch) {
      io.println_error({
        "`EventSource` msg parse error: " <> string.inspect(errs) <> "\n" <>
        "MSG: " <> string.inspect(data)
      })
    })

  let path = endpoint.path(endpoint: sse)
  let event_source = connect(path, False)

  eventsource.on_open(event_source, on_open(path, _, f))
  eventsource.on_close(event_source, on_close(path, _, f))
  eventsource.on_message(event_source, fn(evt) {
    case parse_msg_data(evt:, decoder: endpoint.output(sse).decoder()) {
      Ok(x) -> f(x)
      Error(#(data, errs)) -> on_parse_err(data, errs, f)
    }
  })

  Ok(event_source)
}

fn parse_msg_data(
  evt evt: browser.Event(raw),
  decoder decoder: Decoder(t),
) -> Result(t, #(Dynamic, List(decode.DecodeError))) {
  let data =
    evt
    |> dynamic.from
    |> object.at(["data"] |> list.map(object.Prop))

  data
  |> decode.run({
    decode.string
    |> decode.then(fn(str) {
      case json.parse(str, decoder) {
        Error(_err) -> unsafe.decoder_fail_("sse")
        Ok(str) -> decode.success(str)
      }
    })
  })
  |> result.map_error(fn(errs) {
    #(data, errs)
  })
}
