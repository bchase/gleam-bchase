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
  listen listen:
    fn(Request(mist.Connection), ctx) -> Result(Selector(broadcast), err),
  sse sse: SSE(broadcast),
  err from_err: fn(err, Request(mist.Connection), ctx) -> Response(mist.ResponseData),
) -> #(List(String), fn(Request(mist.Connection), ctx) -> Response(mist.ResponseData)) {
  fn(req, ctx) {
    case listen(req, ctx) {
      Error(err) ->
        from_err(err, req, ctx)

      Ok(selector) ->
        mist.server_sent_events(
          request: req,
          initial_response: response.new(200),
          init: init(_, selector),
          loop: fn(state, msg, conn) {
            update(state, msg, conn, sse.json, send_mist)
          },
        )
    }
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
  selector: Selector(broadcast),
) -> State(broadcast, conn) {
  process.send(self, Init(selector:))

  State
}

type State(broadcast, conn) {
  State
}

type Msg(broadcast) {
  Init(selector: Selector(broadcast))
  Broadcast(msg: broadcast)
}

fn update(
  state: State(broadcast, conn),
  msg: Msg(broadcast),
  conn: conn,
  json: Transcoder(broadcast),
  send: fn(Json, conn) -> Nil,
) -> actor.Next(State(broadcast, conn), Msg(broadcast)) {
  case msg {
    Init(selector: ) ->
      selector
      |> process.map_selector(Broadcast)
      |> process.select(process.new_subject())
      |> actor.with_selector(actor.continue(state), _)

    Broadcast(msg:) -> {
      msg
      |> json.encode
      |> send(conn)

      actor.continue(state)
    }
  }
}
