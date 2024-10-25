import beam/encoder
import beam/framebuffer
import beam/vector as v
import gleam/bit_array
import gleeunit/should

fn image() {
  let assert Ok(frame) =
    framebuffer.create(2, 1, [v.new(1.0, 0.0, 0.0), v.new(0.0, 1.0, 0.0)])
  frame
}

pub fn ascii_ppm_test() {
  encoder.p3(image(), encoder.Encoding(1.0, 0.0, False))
  |> bit_array.to_string
  |> should.equal(Ok(
    "P3
2 1
255
255 0 0
0 255 0
",
  ))
}

pub fn binary_ppm_test() {
  encoder.p6(image(), encoder.Encoding(1.0, 0.0, False))
  |> should.equal(<<
    "P6
2 1
255
":utf8,
    255,
    0,
    0,
    0,
    255,
    0,
  >>)
}
