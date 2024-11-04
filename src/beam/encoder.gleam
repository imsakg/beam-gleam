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

pub fn pam(frame: Frame, options: Encoding) -> BitArray {
  let header = bit_array.from_string("P7
WIDTH " <> int.to_string(frame.width) <> "
HEIGHT " <> int.to_string(frame.height) <> "
DEPTH 3
MAXVAL 255
TUPLTYPE RGB
ENDHDR
")
  <<header:bits, rgb_bytes(frame, options):bits>>
}

pub fn bmp(frame: Frame, options: Encoding) -> BitArray {
  let padding = { 4 - { frame.width * 3 } % 4 } % 4
  let image_size = { frame.width * 3 + padding } * frame.height
  let size = 54 + image_size
  let file_header = <<
    66,
    77,
    size:size(32)-little,
    0:size(32),
    54:size(32)-little,
  >>
  let info = <<
    40:size(32)-little,
    frame.width:size(32)-little,
    frame.height:size(32)-little,
    1:size(16)-little,
    24:size(16)-little,
    0:size(32),
    image_size:size(32)-little,
    2835:size(32)-little,
    2835:size(32)-little,
    0:size(32),
    0:size(32),
  >>
  let pad = list.repeat(<<0>>, padding) |> bit_array.concat
  let pixels =
    frame.pixels
    |> list.sized_chunk(frame.width)
    |> list.reverse
    |> list.map(fn(row) {
      let data =
        list.map(row, fn(p) {
          let c = rgb(p, options)
          <<c.2, c.1, c.0>>
        })
        |> bit_array.concat
      <<data:bits, pad:bits>>
    })
    |> bit_array.concat
  <<file_header:bits, info:bits, pixels:bits>>
}
