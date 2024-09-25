import assertions
import beam/camera
import beam/material
import beam/renderer
import beam/sampler
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

pub fn edge_antialiasing_test() {
  let objects = [
    scene.Object(
      shape.Plane(v.new(0.0, 0.0, -3.0), v.new(0.0, 0.0, 1.0)),
      material.emissive(v.new(1.0, 0.0, 0.0), 1.0),
    ),
  ]
  let assert Ok(frame) =
    renderer.sampled(camera(), objects, [], 1, 1, 2, sampler.grid(2))
  let assert Ok(pixel) = list.first(frame.pixels)
  assertions.vector_close(pixel, v.new(1.0, 0.0, 0.0))
  let edge = [
    scene.Object(
      shape.Sphere(v.new(0.0, 0.0, -3.0), 1.6),
      material.emissive(v.new(1.0, 1.0, 1.0), 1.0),
    ),
  ]
  let assert Ok(aa) =
    renderer.sampled(camera(), edge, [], 1, 1, 2, [#(0.5, 0.5), #(0.01, 0.01)])
  let assert Ok(blended) = list.first(aa.pixels)
  assertions.vector_close(blended, v.new(0.5, 0.5, 0.5))
}
