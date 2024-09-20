import assertions
import beam/camera
import beam/material
import beam/renderer
import beam/scene
import beam/shape
import beam/vector as v
import gleam/list
import gleeunit/should

fn camera() {
  let assert Ok(c) =
    camera.look_at(
      v.zero(),
      v.new(0.0, 0.0, -1.0),
      v.new(0.0, 1.0, 0.0),
      90.0,
      1.0,
    )
  c
}

pub fn single_pixel_test() {
  let objects = [
    scene.Object(
      shape.Sphere(v.new(0.0, 0.0, -3.0), 1.0),
      material.emissive(v.new(1.0, 0.0, 0.0), 1.0),
    ),
  ]
  let assert Ok(frame) = renderer.render(camera(), objects, [], 1, 1, 2)
  let assert Ok(pixel) = list.first(frame.pixels)
  assertions.vector_close(pixel, v.new(1.0, 0.0, 0.0))
  frame.height |> should.equal(1)
}
