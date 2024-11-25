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

pub fn seeded_render_test() {
  let options =
    renderer.Settings(
      ..renderer.defaults(),
      width: 4,
      height: 4,
      samples: 5,
      sampling: renderer.Jitter,
    )
  let objects = [
    scene.Object(
      shape.Sphere(v.new(0.0, 0.0, -3.0), 1.0),
      material.emissive(v.new(1.0, 0.0, 0.0), 1.0),
    ),
  ]
  renderer.render_with(options, camera(), objects, [])
  |> should.equal(renderer.render_with(options, camera(), objects, []))
  renderer.validate(
    renderer.Settings(..options, samples: 5, sampling: renderer.Grid),
  )
  |> should.equal(Error("grid sampling requires a square sample count"))
}

pub fn diagnostic_views_test() {
  let base =
    renderer.Settings(
      ..renderer.defaults(),
      width: 1,
      height: 1,
      samples: 1,
      sampling: renderer.Center,
    )
  let objects = [
    scene.Object(
      shape.Sphere(v.new(0.0, 0.0, -3.0), 1.0),
      material.emissive(v.zero(), 0.0),
    ),
  ]
  let assert Ok(normals) =
    renderer.render_with(
      renderer.Settings(..base, view: renderer.Normals),
      camera(),
      objects,
      [],
    )
  let assert Ok(n) = list.first(normals.pixels)
  assertions.vector_close(n, v.new(0.5, 0.5, 1.0))
  let assert Ok(depth) =
    renderer.render_with(
      renderer.Settings(..base, view: renderer.Depth),
      camera(),
      objects,
      [],
    )
  let assert Ok(d) = list.first(depth.pixels)
  assertions.close(d.x, 1.0 /. 3.0)
}

pub fn resource_budget_test() {
  renderer.validate(renderer.Settings(..renderer.defaults(), width: 8192))
  |> should.equal(Error("render exceeds resource limits"))
  renderer.validate(renderer.Settings(..renderer.defaults(), depth: 100))
  |> should.equal(Error("render exceeds resource limits"))
  renderer.validate(renderer.Settings(..renderer.defaults(), samples: 1024))
  |> should.equal(Error("render exceeds resource limits"))
  renderer.validate(renderer.Settings(..renderer.defaults(), depth: 0))
  |> should.equal(Error("render exceeds resource limits"))
}

pub fn public_api_budget_test() {
  renderer.render(camera(), [], [], 4097, 1, 1)
  |> should.equal(Error("render exceeds resource limits"))
  renderer.render(camera(), [], [], 1, 1, 0)
  |> should.equal(Error("render exceeds resource limits"))
  renderer.sampled(camera(), [], [], 1, 1, 2, list.repeat(#(0.5, 0.5), 257))
  |> should.equal(Error("render exceeds resource limits"))
}

pub fn invalid_offsets_test() {
  renderer.sampled(camera(), [], [], 1, 1, 1, [#(-0.1, 0.5)])
  |> should.equal(Error("sample offsets must lie in [0,1)"))
  renderer.sampled(camera(), [], [], 1, 1, 1, [#(0.5, 1.0)])
  |> should.equal(Error("sample offsets must lie in [0,1)"))
}
