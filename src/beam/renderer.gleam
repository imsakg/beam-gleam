import beam/background
import beam/camera.{type Camera}
import beam/framebuffer.{type Frame}
import beam/interval
import beam/light.{type Light}
import beam/ray
import beam/sampler
import beam/scene.{type Object}
import beam/tracer
import beam/vector.{type Vec}
import gleam/float
import gleam/int
import gleam/list
import gleam/result

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
  use _ <- result.try(validate(
    Settings(
      ..defaults(),
      width: width,
      height: height,
      depth: depth,
      samples: list.length(offsets),
      sampling: Jitter,
    ),
  ))
  let valid_offsets =
    list.all(offsets, fn(p) {
      p.0 >=. 0.0 && p.0 <. 1.0 && p.1 >=. 0.0 && p.1 <. 1.0
    })
  use _ <- result.try(case valid_offsets {
    True -> Ok(Nil)
    False -> Error("sample offsets must lie in [0,1)")
  })
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

pub type Sampling {
  Center
  Grid
  Jitter
  Stratified
}

pub type View {
  Lit
  Normals
  Depth
}

pub type Settings {
  Settings(
    width: Int,
    height: Int,
    depth: Int,
    samples: Int,
    seed: Int,
    sampling: Sampling,
    environment: background.Background,
    view: View,
  )
}

pub fn defaults() -> Settings {
  Settings(
    320,
    180,
    5,
    4,
    42,
    Stratified,
    background.Sky(vector.new(1.0, 1.0, 1.0), vector.new(0.4, 0.65, 1.0)),
    Lit,
  )
}

pub fn render_with(
  settings: Settings,
  camera: Camera,
  objects: List(Object),
  lights: List(Light),
) -> Result(Frame, String) {
  case validate(settings) {
    Error(e) -> Error(e)
    Ok(_) -> {
      let pixels =
        list.repeat(Nil, settings.width * settings.height)
        |> list.index_map(fn(_, i) {
          let x = i % settings.width
          let y = i / settings.width
          let offsets =
            sample_offsets(
              settings,
              settings.seed + x * 73_856_093 + y * 19_349_663,
            )
          sample_pixel(
            camera,
            x,
            y,
            settings.width,
            settings.height,
            offsets,
            fn(r) { shade_ray(settings, objects, lights, r) },
          )
        })
      framebuffer.create(settings.width, settings.height, pixels)
    }
  }
}

fn sample_offsets(settings: Settings, seed: Int) -> List(#(Float, Float)) {
  let side =
    float.square_root(int.to_float(settings.samples))
    |> result.unwrap(1.0)
    |> float.truncate
  case settings.sampling {
    Center -> sampler.center()
    Grid -> sampler.grid(side)
    Jitter -> sampler.jitter(settings.samples, seed)
    Stratified -> sampler.stratified(side, seed)
  }
}

pub fn validate(settings: Settings) -> Result(Nil, String) {
  case
    settings.width > 4096
    || settings.height > 4096
    || settings.depth < 1
    || settings.depth > 32
    || settings.samples > 256
    || settings.width * settings.height * settings.samples > 8_388_608
  {
    True -> Error("render exceeds resource limits")
    False -> validate_sampling(settings)
  }
}

fn validate_sampling(settings: Settings) -> Result(Nil, String) {
  let side =
    float.square_root(int.to_float(settings.samples))
    |> result.unwrap(0.0)
    |> float.truncate
  case settings.width <= 0 || settings.height <= 0 || settings.samples <= 0 {
    True -> Error("dimensions and sample count must be positive")
    False ->
      case settings.sampling {
        Center ->
          case settings.samples == 1 {
            True -> Ok(Nil)
            False -> Error("center sampling requires one sample")
          }
        Grid | Stratified ->
          case side * side == settings.samples {
            True -> Ok(Nil)
            False -> Error("grid sampling requires a square sample count")
          }
        Jitter -> Ok(Nil)
      }
  }
}

fn shade_ray(
  settings: Settings,
  objects: List(Object),
  lights: List(Light),
  r: ray.Ray,
) -> Vec {
  case settings.view {
    Lit ->
      tracer.trace_background(
        objects,
        lights,
        r,
        settings.depth,
        settings.environment,
      )
    Normals | Depth ->
      case scene.intersect(objects, r, interval.positive()) {
        Error(_) -> vector.zero()
        Ok(c) ->
          case settings.view {
            Normals ->
              vector.scale(
                vector.add(c.hit.normal, vector.new(1.0, 1.0, 1.0)),
                0.5,
              )
            _ ->
              vector.scale(vector.new(1.0, 1.0, 1.0), 1.0 /. { 1.0 +. c.hit.t })
          }
      }
  }
}
