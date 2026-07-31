import bchase/json.{type Transcoder} as _
import bchase/lens.{type Lens}
import bchase/meta
import bchase/unsafe
import gleam/dynamic/decode.{type Decoder}
import gleam/function
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre.{type App}
import lustre/attribute as attr
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/event

pub type WebComponent(config, model, int_msg, out_msg, ext_msg) {
  WebComponent(
    tag: String,
    component: App(Nil, model, int_msg),
    props: List(Prop(config, int_msg, ext_msg)),
    event: Option(Event(int_msg, out_msg, ext_msg)),
  )
}

pub opaque type Prop(model, int_msg, ext_msg) {
  Prop(
    key: String,
    option: component.Option(int_msg),
    attr: fn(model) -> attr.Attribute(ext_msg),
  )
}

pub opaque type Event(int_msg, out_msg, ext_msg) {
  Event(
    on: fn(String, Notifier(out_msg, ext_msg)) -> attr.Attribute(ext_msg),
    emit: fn(String, out_msg) -> Effect(int_msg),
  )
}

pub type Notifier(out_msg, ext_msg) {
  Msg(msg: fn(out_msg) -> ext_msg)
  Dispatch(dispatch: fn(out_msg) -> Nil)
}

type Emit(out_msg, int_msg) =
  fn(out_msg) -> Effect(int_msg)

pub fn web_component(
  tag tag: String,
  init init: fn(Nil) -> #(model, Effect(int_msg)),
  update update: fn(model, int_msg, Emit(out_msg, int_msg)) ->
    #(model, Effect(int_msg)),
  view view: fn(model) -> Element(int_msg),
  options options: List(component.Option(int_msg)),
  props props: List(Prop(config, int_msg, ext_msg)),
  event event: Option(Event(int_msg, out_msg, ext_msg)),
) -> WebComponent(config, model, int_msg, out_msg, ext_msg) {
  WebComponent(tag:, props:, event:, component: {
    component(init:, view:, options:, props:, update: fn(model, msg) {
      update(model, msg, emit(tag:, event:))
    })
  })
}

pub fn component(
  init init: fn(arguments) -> #(model, Effect(int_msg)),
  update update: fn(model, int_msg) -> #(model, Effect(int_msg)),
  view view: fn(model) -> Element(int_msg),
  options options: List(component.Option(int_msg)),
  props props: List(Prop(config, int_msg, ext_msg)),
) -> App(arguments, model, int_msg) {
  lustre.component(
    init:,
    update:,
    view:,
    options: list.flatten([
      options,
      props
        |> list.map(fn(prop: Prop(config, int_msg, ext_msg)) { prop.option }),
    ]),
  )
}

pub fn register(
  component component: WebComponent(config, model, int_msg, out_msg, ext_msg),
) -> Nil {
  case lustre.register(component.component, component.tag) {
    Ok(_) -> Nil

    Error(err) -> {
      io.println_error({
        "Failed to `register` component tag `"
        <> component.tag
        <> "`\n"
        <> string.inspect(component.component)
        <> "\n"
        <> string.inspect(err)
      })
    }
  }
}

pub fn element(
  web_component wc: WebComponent(config, model, int_msg, out_msg, ext_msg),
  config config: config,
  attrs attrs: List(attr.Attribute(ext_msg)),
  children children: List(Element(ext_msg)),
  notifier notifier: Notifier(out_msg, ext_msg),
) -> Element(ext_msg) {
  let attrs =
    list.flatten([
      attrs,
      wc.props |> list.map(fn(prop) { prop.attr(config) }),
      list.wrap(case wc.event {
        None -> attr.none()
        Some(event) -> event.on(event_name(tag: wc.tag), notifier)
      }),
    ])

  element.element(wc.tag, attrs, children)
}

pub fn prop_(
  msg msg: fn(String, fn(config) -> config) -> int_msg,
  meta meta: meta.FieldJson(config, field, t),
) -> Prop(config, int_msg, ext_msg) {
  let key = meta.field.property

  Prop(
    key:,
    option: {
      component.on_attribute_change(key, fn(json) {
        json
        |> json.parse({
          meta.json.decoder()
          |> decode.then(fn(value) {
            decode.success(msg(key, meta.field.lens.set(_, value)))
          })
        })
        |> result.map_error(fn(err) {
          io.println_error(
            "Failed to parse component property `"
            <> key
            <> "`: "
            <> err |> string.inspect,
          )
        })
        |> result.replace_error(Nil)
      })
    },
    attr: fn(cfg: config) {
      attr.attribute(
        key,
        meta.field.lens.get(cfg) |> meta.json.encode |> json.to_string,
      )
    },
  )
}

pub fn prop(
  key key: String,
  lens lens: Lens(config, t),
  transcoder transcoder: Transcoder(t),
  msg msg: fn(String, fn(config) -> config) -> int_msg,
) -> Prop(config, int_msg, ext_msg) {
  Prop(
    key:,
    option: {
      component.on_attribute_change(key, fn(json) {
        json
        |> json.parse({
          transcoder.decoder()
          |> decode.then(fn(value) {
            decode.success(msg(key, lens.set(_, value)))
          })
        })
        |> result.map_error(fn(err) {
          io.println_error(
            "Failed to parse component property `"
            <> key
            <> "`: "
            <> err |> string.inspect,
          )
        })
        |> result.or(Ok(msg(key, function.identity)))
      })
    },
    attr: fn(cfg: config) {
      attr.attribute(key, lens.get(cfg) |> transcoder.encode |> json.to_string)
    },
  )
}

pub fn event(msg json: Transcoder(out_msg)) -> Event(int_msg, out_msg, ext_msg) {
  Event(
    on: fn(name, notifier) { on(name:, json:, notifier:) },
    emit: fn(name, msg) { event.emit(name, json.encode(msg)) },
  )
}

//

const event_name_prefix: String = "bchase:lustre:component:"

fn event_name(tag tag: String) -> String {
  event_name_prefix <> tag <> ":msg-event"
}

fn emit(
  tag tag: String,
  event event: Option(Event(int_msg, out_msg, ext_msg)),
) -> fn(out_msg) -> Effect(int_msg) {
  case event {
    Some(event) -> event.emit(event_name(tag:), _)

    None -> fn(_msg) {
      io.println_error(
        "`bchase/lustre/component` <"
        <> tag
        <> "> attempted to emit an event, but no handler was registered",
      )
      effect.none()
    }
  }
}

fn on(
  name name: String,
  json json: Transcoder(int_msg),
  notifier notifier: Notifier(int_msg, ext_msg),
) -> attr.Attribute(ext_msg) {
  event.on(name, {
    use msg <- decode.then(decode.at(["detail"], json.decoder()))

    case notifier {
      Msg(msg: wrap) -> decode.success(wrap(msg))

      Dispatch(dispatch:) -> {
        dispatch(msg)
        unsafe.decoder_fail()
      }
    }
  })
}
