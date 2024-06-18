import assertions
import beam/texture
import beam/vector as v
import gleeunit/should

pub fn solid_test() {
  let red = v.new(1.0, 0.0, 0.0)
  texture.value(texture.Solid(red), v.new(3.0, 2.0, 1.0), 0.2, 0.8)
  |> assertions.vector_close(red)
}

pub fn checker_test() {
  let white = v.new(1.0, 1.0, 1.0)
  let black = v.zero()
  let checker = texture.Checker(white, black, 1.0)
  texture.value(checker, v.new(0.1, 0.1, 0.1), 0.0, 0.0)
  |> assertions.vector_close(white)
  texture.value(checker, v.new(-0.1, 0.1, 0.1), 0.0, 0.0)
  |> assertions.vector_close(black)
  texture.value(checker, v.new(-1.1, 0.1, 0.1), 0.0, 0.0)
  |> assertions.vector_close(white)
}

pub fn stripe_and_gradient_test() {
  let red = v.new(1.0, 0.0, 0.0)
  let blue = v.new(0.0, 0.0, 1.0)
  texture.value(texture.Stripe(red, blue, 2.0), v.new(0.75, 8.0, 2.0), 0.0, 0.0)
  |> assertions.vector_close(blue)
  texture.value(
    texture.Gradient(red, blue, 1.0),
    v.new(-0.25, 0.0, 0.0),
    0.0,
    0.0,
  )
  |> assertions.vector_close(v.new(0.25, 0.0, 0.75))
}
