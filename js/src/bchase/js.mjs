import { Result$Ok, Result$Error } from "../gleam.mjs";

// OBJECTS

export function at(obj, path) {
  return path.reduce((acc, key) => acc?.[key], obj);
}

// `localStorage`

export function local_storage() {
  return globalThis['localStorage']
    ? Result$Ok(globalThis.localStorage)
    : Result$Error(undefined);
}

export function set_item(ls, key, val) {
  return ls.setItem(key, val);
}

export function get_item(ls, key) {
  const val = ls.getItem(key);
  return val
    ? Result$Ok(val)
    : Result$Error(undefined);
}

export function remove_item(ls, key) {
  return ls.removeItem(key);
}
