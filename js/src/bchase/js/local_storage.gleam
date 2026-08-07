pub type LocalStorage

@external(javascript, "../js.mjs", "local_storage")
pub fn local_storage() -> Result(LocalStorage, Nil)

@external(javascript, "../js.mjs", "set_item")
pub fn set_item(
  local_storage local_storage: LocalStorage,
  key key: String,
  val val: String,
) -> Nil

@external(javascript, "../js.mjs", "get_item")
pub fn get_item(
  local_storage local_storage: LocalStorage,
  key key: String,
) -> Result(String, Nil)

@external(javascript, "../js.mjs", "remove_item")
pub fn remove_item(
  local_storage local_storage: LocalStorage,
  key key: String,
) -> Nil
