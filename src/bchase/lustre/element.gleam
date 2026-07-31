import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed
import lustre/event

pub fn keyed_div(
  key key: String,
  attrs attrs: List(attr.Attribute(msg)),
  children children: List(Element(msg)),
) -> Element(msg) {
  keyed.div(attrs, children |> list.map(pair.new(key, _)))
}

//

pub fn crossorigin_script_ensure_by_src(
  src src: String,
  integrity integrity: String,
) -> Element(msg) {
  html.script([], "(() => {
    if ( !document.querySelector(`script[src='" <> src <> "']`) ) {
      const script = document.createElement('script');
      script.src = '" <> src <> "';
      script.integrity = '" <> integrity <> "';
      script.crossOrigin = 'anonymous';
      document.head.appendChild(script);
    }
  })();")
}

//

const dom_purify_src = "https://cdn.jsdelivr.net/npm/dompurify@3.4.11/dist/purify.min.js"

const dom_purify_integrity = "sha256-26u1sgWjM+xJyMCef8ow72bfBSO7i8D6nqhDhB8RHb0="

pub fn render_purified_div(
  attrs attrs: List(attr.Attribute(msg)),
  unsafe_html unsafe_html: String,
) -> Element(msg) {
  html.div(
    [
      attr.data("unsafe_html", unsafe_html),
      attr.class("sanitize-and-render"),
      ..attrs
    ],
    [
      crossorigin_script_ensure_by_src(
        src: dom_purify_src,
        integrity: dom_purify_integrity,
      ),
      html.script(
        [],
        "(() => {
      const el = document.currentScript;

      function whenWindowDefined(key, f, poll) {
        if ( window[key] ) {
          f();
        } else {
          setTimeout(() => { whenWindowDefined(key, f, poll) }, poll);
        }
      }

      whenWindowDefined('DOMPurify', () => {
        let parent = el.parentElement;
        let unsafe_html = parent.dataset['unsafe_html'];
        let safe_html = DOMPurify.sanitize(unsafe_html);
        parent.innerHTML = safe_html;
      }, 200);
    })();",
      ),
    ],
  )
}

//

const tinymce_src = "https://cdn.jsdelivr.net/npm/tinymce@8.7.0/tinymce.min.js"

const tinymce_integrity = "sha256-G0ELV/lbW8R2d/XOer/EMDekMCkLY9HqBS62xd/VtMo="

// <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tinymce@8.7.0/skins/ui/oxide/content.min.css" integrity="sha256-skMHQK19/pG6t0zQYm0TMOgTtkOg87/AtJaxIrjPB+4=" crossorigin="anonymous">

pub type TinymceLicenseKey {
  Gpl
  TinymceLicenseKey(key: String)
}

pub fn tinymce_wysiwyg(
  value value: String,
  msg msg: fn(String) -> msg,
  license_key license_key: Option(String),
) -> Element(msg) {
  let license_key = case license_key {
    None -> "gpl"
    Some(key) -> key
  }

  html.span([], [
    html.textarea(
      [
        // attr.style("display", "none"),
      ],
      { value },
    ),
    html.input([
      attr.style("display", "none"),
      event.on_input(msg),
    ]),
    crossorigin_script_ensure_by_src(
      src: tinymce_src,
      integrity: tinymce_integrity,
    ),
    html.script([], "(() => {
      const script = document.currentScript;

      function whenWindowDefined(key, f, poll) {
        if ( window[key] ) {
          f();
        } else {
          setTimeout(() => { whenWindowDefined(key, f, poll) }, poll);
        }
      }

      whenWindowDefined('tinymce', () => {
        const parent = script.parentElement;
        const source = parent.querySelector('textarea');
        const sink = parent.querySelector('input');

        window.tinymce.init({
          license_key: '" <> license_key <> "',
          promotion: false,
          branding: false,
          target: source,
          height: 240,
        }).then((x) => {
          window.x = x;
          console.log(x);
        });

        const editor = window.tinymce.activeEditor;

        // // restrict html elements
        // const validElements = 'h1,h2,h3,h4,h5,h6,p,strong,b,em,i,u,strike,sub,sup,small,span,div,hr,br,blockquote,ul,ol,li,a,img,iframe,table,thead,tbody,tr,th,td,code,pre';
        // // editor.options.set('valid_elements', validElements);
        // // editor.schema = new tinymce.html.Schema(editor.settings);
        // // editor.setContent(editor.getContent());

        editor.on('input', (evt) => {
          // set value
          sink.value = evt.target.innerHTML;

          // manually trigger input event
          sink.dispatchEvent(new Event('input', { bubbles: false }));
        });
      }, 10);
    })();"),
  ])
}
