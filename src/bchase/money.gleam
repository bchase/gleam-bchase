import gleam/dynamic/decode.{type Decoder}
import gleam/float
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/string

pub type Money {
  Money(currency: Currency, amount: Int)
}

pub type Currency {
  Usd
}

pub fn usd(amount: Int) -> Money {
  Money(Usd, amount)
}

pub fn usd_(amount: Float) -> Money {
  amount
  |> float.multiply(100 |> int.to_float)
  |> float.truncate
  |> usd
}

pub fn plus(money1 money1: Money, money2 money2: Money) -> Money {
  case money1, money2 {
    Money(currency: Usd, amount: amount1), Money(currency: Usd, amount: amount2)
    -> Money(currency: Usd, amount: amount1 + amount2)
  }
}

pub fn zero() -> Money {
  let _totality = fn(curr) {
    case curr {
      Usd -> Nil
    }
  }

  Money(currency: Usd, amount: 0)
}

pub fn to_string(money money: Money) -> String {
  case money {
    Money(currency: Usd, amount: cents) -> usd_to_string(cents:)
  }
}

fn usd_to_string(cents cents: Int) -> String {
  let assert #(Ok(dollars), Ok(cents)) = #(
    int.divide(cents, 100),
    int.remainder(cents, 100),
  )

  let dollars =
    dollars
    |> int.to_string
    |> string.to_graphemes
    |> list.reverse
    |> list.sized_chunk(3)
    |> list.map(string.join(_, ""))
    |> string.join(",")
    |> string.reverse

  let cents =
    cents
    |> int.to_string
    |> string.pad_start(to: 2, with: "0")

  dollars <> "." <> cents
}

pub fn encode_money(value: Money) -> Json {
  case value {
    Money(..) as value ->
      json.object([
        #("amount", json.int(value.amount)),
        #("currency", encode_currency(value.currency)),
      ])
  }
}

pub fn decoder_money() -> Decoder(Money) {
  decode.one_of(decoder_money_money(), [])
}

pub fn decoder_money_money() -> Decoder(Money) {
  use currency <- decode.field("currency", decoder_currency())
  use amount <- decode.field("amount", decode.int)
  decode.success(Money(currency:, amount:))
}

pub fn encode_currency(value: Currency) -> Json {
  case value {
    Usd -> json.object([])
  }
}

pub fn decoder_currency() -> Decoder(Currency) {
  decode.one_of(decoder_currency_usd(), [])
}

pub fn decoder_currency_usd() -> Decoder(Currency) {
  decode.success(Usd)
}
