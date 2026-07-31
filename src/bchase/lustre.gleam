import bchase/unsafe
import gleam/dynamic/decode
import gleam/io
import lustre/attribute as attr
import lustre/effect.{type Effect}
import lustre/event

pub type Msg(in, out, ext) {
  In(msg: in)
  Out(msg: out)
  Ext(msg: ext)
}

pub fn pure(model model: model) -> #(model, Effect(msg)) {
  #(model, effect.none())
}

pub fn pure_log_err(
  model model: model,
  err err: String,
) -> #(model, Effect(msg)) {
  io.println_error(err)
  #(model, effect.none())
}

pub fn do(
  t t: #(model, Effect(msg)),
  cont cont: fn(model) -> #(model, Effect(msg)),
) -> #(model, Effect(msg)) {
  do_(t, fn(msg) { msg }, cont)
}

pub fn do_(
  t t: #(inner_model, Effect(inner_msg)),
  msg msg: fn(inner_msg) -> outer_msg,
  cont cont: fn(inner_model) -> #(outer_model, Effect(outer_msg)),
) -> #(outer_model, Effect(outer_msg)) {
  let #(model, inner_eff) = t
  let #(model, outer_eff) = cont(model)
  #(model, effect.batch([inner_eff |> effect.map(msg), outer_eff]))
}

//

pub fn effs(
  model model: model,
  effs effs: List(Effect(msg)),
) -> #(model, Effect(msg)) {
  #(model, effect.batch(effs))
}

pub fn add_effs(
  t: #(model, Effect(msg)),
  effs effs: List(Effect(msg)),
) -> #(model, Effect(msg)) {
  #(t.0, effect.batch([t.1, ..effs]))
}

pub fn to_eff(msg msg: msg) -> Effect(msg) {
  effect.from(fn(dispatch) { dispatch(msg) })
}

//

pub fn event_on_click_dispatch(
  msg msg: msg,
  dispatch dispatch: fn(msg) -> Nil,
) -> attr.Attribute(a) {
  event.on("click", {
    use _ <- decode.then(decode.dynamic)
    dispatch(msg)
    unsafe.decoder_fail()
  })
}
// //

// pub fn map(
//   t t: #(inner_model, Effect(inner_msg)),
//   set set: fn(inner_model) -> model,
//   msg msg: fn(inner_msg) -> msg,
// ) -> #(model, Effect(msg)) {
//   #(set(t.0), effect.map(t.1, msg))
// }

// pub fn inner(
//   model model: model,
//   update update: fn(inner, inner_msg) -> #(inner, Effect(inner_msg)),
//   msg msg: inner_msg,
//   wrap wrap: fn(inner_msg) -> msg,
//   inner inner: Lens(model, inner),
// ) -> #(model, Effect(msg)) {
//   let #(x, x_eff) = update(inner.get(model), msg)

//   model
//   |> inner.set(x)
//   |> effs([
//     x_eff |> effect.map(wrap),
//   ])
// }

// pub fn map_inner(
//   outer outer: outer,
//   inner inner: Lens(outer, inner),
//   apply f: fn(inner) -> inner,
// ) -> outer {
//   outer
//   |> inner.get
//   |> f
//   |> inner.set(outer, _)
// }

// pub fn inner_(
//   t: #(inner, Effect(inner_msg)),
//   set set: fn(inner) -> model,
//   wrap wrap: fn(inner_msg) -> msg,
// ) -> #(model, Effect(msg)) {
//   t
//   |> pair.map_first(set)
//   |> pair.map_second(effect.map(_, wrap))
// }
