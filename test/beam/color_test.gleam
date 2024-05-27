import assertions
import beam/color
import beam/vector as v
import gleeunit/should

pub fn linear_color_test() {
  color.to_rgb8(v.new(-0.4, 0.5, 2.0)) |> should.equal(#(0, 128, 255))
  color.mix(color.black(), color.white(), 0.25)
  |> assertions.vector_close(v.new(0.25, 0.25, 0.25))
}
