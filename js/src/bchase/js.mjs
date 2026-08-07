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

export function set_item(key, val) {
  return globalThis.localStorage.setItem(key, val);
}

export function get_item(key) {
  const val = globalThis.localStorage.getItem(key);
  return val ? val : undefined;
}

export function remove_item(key) {
  return globalThis.localStorage.removeItem(key);
}
