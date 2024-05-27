import beam/vector.{type Vec}
import gleam/float

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
