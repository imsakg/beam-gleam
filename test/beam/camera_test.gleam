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

pub fn field_of_view_test() {
  let assert Ok(c) =
    camera.look_at(
      v.zero(),
      v.new(0.0, 0.0, -1.0),
      v.new(0.0, 1.0, 0.0),
      90.0,
      2.0,
    )
  assertions.close(v.length(c.horizontal), 4.0)
  assertions.close(v.length(c.vertical), 2.0)
  assertions.vector_close(c.lower_left, v.new(-2.0, -1.0, -1.0))
}

pub fn primary_ray_test() {
  let assert Ok(c) =
    camera.look_at(
      v.zero(),
      v.new(0.0, 0.0, -1.0),
      v.new(0.0, 1.0, 0.0),
      90.0,
      1.0,
    )
  assertions.vector_close(
    camera.ray(c, 0.5, 0.5).direction,
    v.new(0.0, 0.0, -1.0),
  )
  assertions.close(v.length(camera.ray(c, 0.0, 1.0).direction), 1.0)
}
