import beam/camera.{type Camera}
import beam/framebuffer.{type Frame}
import beam/light.{type Light}
import beam/scene.{type Object}
import beam/tracer
import gleam/int
import gleam/list

pub fn render(
  camera: Camera,
  objects: List(Object),
  lights: List(Light),
  width: Int,
  height: Int,
  depth: Int,
) -> Result(Frame, String) {
  case width <= 0 || height <= 0 {
    True -> Error("image dimensions must be positive")
    False -> {
      let pixels =
        list.repeat(Nil, width * height)
        |> list.index_map(fn(_, i) {
          let u = { int.to_float(i % width) +. 0.5 } /. int.to_float(width)
          let v =
            1.0 -. { int.to_float(i / width) +. 0.5 } /. int.to_float(height)
          tracer.trace(objects, lights, camera.ray(camera, u, v), depth)
        })
      framebuffer.create(width, height, pixels)
    }
  }
}
