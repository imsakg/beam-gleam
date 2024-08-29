import gleam/int

pub opaque type Generator {
  Generator(state: Int)
}

pub fn seed(value: Int) -> Generator {
  let positive = case value < 0 {
    True -> 0 - value
    False -> value
  }
  let normalized = positive % 2_147_483_647
  Generator(case normalized == 0 {
    True -> 1
    False -> normalized
  })
}

pub fn next(generator: Generator) -> #(Float, Generator) {
  let Generator(state) = generator
  let next = { state * 16_807 } % 2_147_483_647
  #(int.to_float(next) /. 2_147_483_647.0, Generator(next))
}
