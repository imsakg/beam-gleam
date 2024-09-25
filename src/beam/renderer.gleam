import beam/camera.{type Camera}
import beam/framebuffer.{type Frame}
import beam/light.{type Light}
import beam/ray
import beam/sampler
import beam/scene.{type Object}
import beam/tracer
import beam/vector.{type Vec}
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
  sampled(camera, objects, lights, width, height, depth, sampler.center())
}

pub fn sampled(
  camera: Camera,
  objects: List(Object),
  lights: List(Light),
  width: Int,
  height: Int,
  depth: Int,
  offsets: List(#(Float, Float)),
) -> Result(Frame, String) {
  case width <= 0 || height <= 0 || list.is_empty(offsets) {
    True -> Error("dimensions and sample count must be positive")
    False -> {
      let pixels =
        list.repeat(Nil, width * height)
        |> list.index_map(fn(_, i) {
          sample_pixel(
            camera,
            i % width,
            i / width,
            width,
            height,
            offsets,
            fn(r) { tracer.trace(objects, lights, r, depth) },
          )
        })
      framebuffer.create(width, height, pixels)
    }
  }
}

fn sample_pixel(
  camera: Camera,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
  offsets: List(#(Float, Float)),
  shade: fn(ray.Ray) -> Vec,
) -> Vec {
  let sum =
    list.fold(offsets, vector.zero(), fn(acc, p) {
      let u = { int.to_float(x) +. p.0 } /. int.to_float(width)
      let v = 1.0 -. { int.to_float(y) +. p.1 } /. int.to_float(height)
      vector.add(acc, shade(camera.ray(camera, u, v)))
    })
  vector.scale(sum, 1.0 /. int.to_float(list.length(offsets)))
}
