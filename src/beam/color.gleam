import beam/vector.{type Vec}
import gleam/float
import gleam/result

pub type Color =
  Vec

pub fn black() -> Color {
  vector.zero()
}

pub fn white() -> Color {
  vector.new(1.0, 1.0, 1.0)
}

pub fn mix(a: Color, b: Color, t: Float) -> Color {
  vector.add(vector.scale(a, 1.0 -. t), vector.scale(b, t))
}

pub fn to_rgb8(c: Color) -> #(Int, Int, Int) {
  #(channel(c.x), channel(c.y), channel(c.z))
}

fn channel(value: Float) -> Int {
  float.truncate(float.clamp(value, 0.0, 0.999999) *. 256.0)
}

/// Nonpositive gamma requests linear output; negative radiance is clipped.
pub fn gamma(c: Color, gamma: Float) -> Color {
  let exponent = case gamma >. 0.0 {
    True -> 1.0 /. gamma
    False -> 1.0
  }
  vector.new(
    transfer(c.x, exponent),
    transfer(c.y, exponent),
    transfer(c.z, exponent),
  )
}

fn transfer(value: Float, exponent: Float) -> Float {
  float.power(float.max(0.0, value), exponent) |> result.unwrap(0.0)
}
