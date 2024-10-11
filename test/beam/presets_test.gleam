import beam/camera
import beam/presets
import beam/renderer
import beam/vector
import gleam/list
import gleeunit/should

pub fn demo_render_test() {
  let scene = presets.demo()
  list.length(scene.objects) |> should.equal(8)
  let assert Ok(camera) =
    camera.look_at(
      scene.eye,
      scene.target,
      vector.new(0.0, 1.0, 0.0),
      scene.fov,
      2.0,
    )
  let options =
    renderer.Settings(
      ..renderer.defaults(),
      width: 12,
      height: 6,
      samples: 1,
      sampling: renderer.Center,
      environment: scene.environment,
    )
  let assert Ok(frame) =
    renderer.render_with(options, camera, scene.objects, scene.lights)
  list.length(frame.pixels) |> should.equal(72)
}
