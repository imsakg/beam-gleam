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
