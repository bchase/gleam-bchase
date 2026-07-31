import bchase/json.{type Transcoder}
import bchase/lens.{type Lens}

pub type Field(record, field, t) {
  Field(property: String, field: field, lens: Lens(record, t))
}

pub type FieldJson(record, field, t) {
  FieldJson(field: Field(record, field, t), json: Transcoder(t))
}
