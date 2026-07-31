// import gleam/erlang/process.{type Subject, type Selector}
// import gleam/otp/actor
// import gleam/otp/supervision

// pub fn actor(
//   init init: fn(flags, Subject(msg)) -> #(state, Selector(msg)),
//   update update: fn(state, msg) -> actor.Next(state, msg),
//   timeout timeout: Int,
//   name name: process.Name(msg),
//   return return: fn(state) -> return,
//   flags flags: flags,
// ) -> actor.Builder(state, msg, return) {
//   actor.new_with_initialiser(timeout, fn(self) {
//     let #(state, sel) = init(flags, self)

//     state
//     |> actor.initialised
//     |> actor.selecting(sel |> process.select(self))
//     |> actor.returning(return(state))
//     |> Ok
//   })
//   |> actor.named(name)
//   |> actor.on_message(update)
// }

// fn worker(
//   actor actor: actor.Builder(state, msg, return),
// ) -> supervision.ChildSpecification(return) {
//   supervision.worker(fn() { actor.start(actor) })
// }

// fn select(
//   apply f: fn(t) -> msg
// ) -> #(Subject(t), Selector(msg)) {
//   let subj = process.new_subject()

//   process.new_selector()
//   |> process.select_map(subj, f)
//   |> pair.new(subj, _)
// }

// fn select_batch(
//   sels sels: List(Selector(msg)),
// ) -> Selector(msg) {
//   list.fold(sels, process.new_selector(), process.merge_selector)
// }

