import beam/framebuffer
import beam/vector as v
import gleeunit/should

pub fn framebuffer_validation_test() {
  let assert Ok(frame) =
    framebuffer.create(2, 1, [v.zero(), v.new(1.0, 1.0, 1.0)])
  frame.width |> should.equal(2)
  framebuffer.create(2, 2, [v.zero()])
  |> should.equal(Error("pixel count does not match dimensions"))
  framebuffer.create(0, 1, [])
  |> should.equal(Error("image dimensions must be positive"))
}
