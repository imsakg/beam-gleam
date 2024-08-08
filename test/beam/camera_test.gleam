import assertions
import beam/camera
import beam/vector as v
import gleeunit/should

pub fn camera_basis_test() {
  let assert Ok(frame) =
    camera.basis(v.new(0.0, 0.0, 3.0), v.zero(), v.new(0.0, 1.0, 0.0))
  assertions.vector_close(frame.right, v.new(1.0, 0.0, 0.0))
  assertions.vector_close(frame.up, v.new(0.0, 1.0, 0.0))
  assertions.vector_close(frame.backward, v.new(0.0, 0.0, 1.0))
  camera.basis(v.zero(), v.zero(), v.new(0.0, 1.0, 0.0))
  |> should.equal(Error("camera origin equals target"))
}
