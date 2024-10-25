import beam/color
import beam/framebuffer.{type Frame}
import beam/vector.{type Vec}
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/string

pub type Encoding {
  Encoding(gamma: Float, exposure: Float, tone_map: Bool)
}

pub fn defaults() -> Encoding {
  Encoding(2.2, 0.0, False)
}

fn rgb(c: Vec, options: Encoding) -> #(Int, Int, Int) {
  let exposed = color.expose(c, options.exposure)
  let mapped = case options.tone_map {
    True -> color.reinhard(exposed)
    False -> exposed
  }
  color.to_rgb8(color.gamma(mapped, options.gamma))
}

fn dimensions(frame: Frame) -> String {
  int.to_string(frame.width) <> " " <> int.to_string(frame.height)
}

pub fn p3(frame: Frame, options: Encoding) -> BitArray {
  let rows =
    list.map(frame.pixels, fn(p) {
      let c = rgb(p, options)
      int.to_string(c.0)
      <> " "
      <> int.to_string(c.1)
      <> " "
      <> int.to_string(c.2)
      <> "
"
    })
    |> string.concat
  bit_array.from_string("P3
" <> dimensions(frame) <> "
255
" <> rows)
}

pub fn rgb_bytes(frame: Frame, options: Encoding) -> BitArray {
  list.map(frame.pixels, fn(p) {
    let c = rgb(p, options)
    <<c.0, c.1, c.2>>
  })
  |> bit_array.concat
}

pub fn p6(frame: Frame, options: Encoding) -> BitArray {
  let header = bit_array.from_string("P6
" <> dimensions(frame) <> "
255
")
  <<header:bits, rgb_bytes(frame, options):bits>>
}
