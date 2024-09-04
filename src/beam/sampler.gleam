import beam/random
import gleam/int
import gleam/list

pub fn center() -> List(#(Float, Float)) {
  [#(0.5, 0.5)]
}

pub fn grid(side: Int) -> List(#(Float, Float)) {
  list.repeat(Nil, side * side)
  |> list.index_map(fn(_, i) {
    #(
      { int.to_float(i % side) +. 0.5 } /. int.to_float(side),
      { int.to_float(i / side) +. 0.5 } /. int.to_float(side),
    )
  })
}

pub fn jitter(count: Int, seed: Int) -> List(#(Float, Float)) {
  jitter_loop(count, random.seed(seed), [])
}

fn jitter_loop(
  count: Int,
  generator: random.Generator,
  acc: List(#(Float, Float)),
) -> List(#(Float, Float)) {
  case count <= 0 {
    True -> list.reverse(acc)
    False -> {
      let x = random.next(generator)
      let y = random.next(x.1)
      jitter_loop(count - 1, y.1, [#(x.0, y.0), ..acc])
    }
  }
}
