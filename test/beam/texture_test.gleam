import assertions
import beam/texture
import beam/vector as v
import gleeunit/should

pub fn solid_test() {
  let red = v.new(1.0, 0.0, 0.0)
  texture.value(texture.Solid(red), v.new(3.0, 2.0, 1.0), 0.2, 0.8)
  |> assertions.vector_close(red)
}
