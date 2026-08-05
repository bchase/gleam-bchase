import bchase/io
import gleam/string
import gleam/pair
import bchase/json.{type Transcoder} as _
import bchase/web/sse.{type SSE}
import gleam/json.{type Json}
import gleam/string_tree
import gleam/erlang/process.{type Subject, type Selector}
import gleam/otp/actor
import gleam/result
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import mist

pub fn serve_via_mist(
  sse sse: SSE(broadcast),
  listen listen:
    fn(Request(mist.Connection), ctx) -> Result(Selector(broadcast), err),
) -> #(List(String), fn(Request(mist.Connection), ctx) -> Response(mist.ResponseData)) {
  fn(request, ctx) {
    let listen =
      // NOTE: closure used to ensure `process.new_subject` is `mist` process
      fn() {
        listen(request, ctx)
        |> result.map_error(string.inspect)
      }

    mist.server_sent_events(
      request:,
      initial_response: response.new(200),
      init: init(_, listen),
      loop: fn(state, msg, conn) {
        update(state, msg, conn, sse, send_mist)
      },
    )
  }
  |> pair.new(sse.path_segments, _)
}

//

fn send_mist(
  json: Json,
  conn: mist.SSEConnection,
) -> Nil {
  json
  |> json.to_string
  |> string_tree.from_string
  |> mist.event
  |> mist.send_event(conn, _)
  |> result.unwrap(Nil)
}

//

fn init(
  self: Subject(Msg(broadcast)),
  listen: fn() -> Result(Selector(broadcast), String),
) -> Nil {
  process.send(self, Init(listen:))
}

type Msg(broadcast) {
  Init(listen: fn() -> Result(Selector(broadcast), String))
  Broadcast(msg: broadcast)
}

fn update(
  state: Nil,
  msg: Msg(broadcast),
  conn: conn,
  sse: SSE(broadcast),
  send: fn(Json, conn) -> Nil,
) -> actor.Next(Nil, Msg(broadcast)) {
  case msg {
    Init(listen:) ->
      case listen() {
        Ok(selector) ->
          state
          |> actor.continue
          |> actor.with_selector(
            selector
            |> process.map_selector(Broadcast)
          )

        Error(err) -> {
          io.println_error(
            "Failed to serve SSE `EventSource` for " <>
            string.inspect(sse.path) <> ": " <>
            err
          )

          actor.stop()
        }
      }

    Broadcast(msg:) -> {
      msg
      |> sse.json.encode
      |> send(conn)

      actor.continue(state)
    }
  }
}
