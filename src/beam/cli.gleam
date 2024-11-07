import beam/encoder
import beam/renderer
import gleam/float
import gleam/int
import gleam/result

pub type Format {
  P3
  P6
  Pam
  Bmp
}

pub type Options {
  Options(
    settings: renderer.Settings,
    encoding: encoder.Encoding,
    format: Format,
    scene: String,
    output: String,
    fov: Float,
  )
}

pub type Command {
  Help
  Render(options: Options)
}

pub fn defaults() -> Options {
  Options(renderer.defaults(), encoder.defaults(), P3, "primitives", "-", 45.0)
}

pub fn parse(arguments: List(String)) -> Result(Command, String) {
  case arguments {
    ["--help"] | ["-h"] -> Ok(Help)
    _ -> parse_loop(arguments, defaults()) |> result.map(Render)
  }
}

fn parse_loop(
  arguments: List(String),
  options: Options,
) -> Result(Options, String) {
  case arguments {
    [] -> {
      use _ <- result.try(renderer.validate(options.settings))
      case
        options.fov <=. 0.0
        || options.fov >=. 180.0
        || options.encoding.gamma <=. 0.0
        || options.encoding.gamma >. 10.0
        || float.absolute_value(options.encoding.exposure) >. 20.0
        || options.output == ""
      {
        True -> Error("invalid field of view, gamma, exposure or output path")
        False -> Ok(options)
      }
    }
    ["--tone-map", ..rest] ->
      parse_loop(
        rest,
        Options(
          ..options,
          encoding: encoder.Encoding(..options.encoding, tone_map: True),
        ),
      )
    [key, value, ..rest] -> {
      use updated <- result.try(apply(options, key, value))
      parse_loop(rest, updated)
    }
    [key] -> Error("missing value for " <> key)
  }
}

fn number(value: String, key: String) -> Result(Int, String) {
  int.parse(value) |> result.map_error(fn(_) { "invalid integer for " <> key })
}

fn decimal(value: String, key: String) -> Result(Float, String) {
  float.parse(value) |> result.map_error(fn(_) { "invalid number for " <> key })
}

fn apply(
  options: Options,
  key: String,
  value: String,
) -> Result(Options, String) {
  case key {
    "--width" ->
      number(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, width: n),
        )
      })
    "--height" ->
      number(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, height: n),
        )
      })
    "--samples" ->
      number(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, samples: n),
        )
      })
    "--depth" ->
      number(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, depth: n),
        )
      })
    "--seed" ->
      number(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, seed: n),
        )
      })
    "--gamma" ->
      decimal(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          encoding: encoder.Encoding(..options.encoding, gamma: n),
        )
      })
    "--exposure" ->
      decimal(value, key)
      |> result.map(fn(n) {
        Options(
          ..options,
          encoding: encoder.Encoding(..options.encoding, exposure: n),
        )
      })
    "--fov" ->
      decimal(value, key) |> result.map(fn(n) { Options(..options, fov: n) })
    "--scene" -> Ok(Options(..options, scene: value))
    "--output" | "-o" -> Ok(Options(..options, output: value))
    "--format" ->
      format(value) |> result.map(fn(f) { Options(..options, format: f) })
    "--sampler" ->
      sampling(value)
      |> result.map(fn(s) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, sampling: s),
        )
      })
    "--view" ->
      view(value)
      |> result.map(fn(v) {
        Options(
          ..options,
          settings: renderer.Settings(..options.settings, view: v),
        )
      })
    _ -> Error("unknown option: " <> key)
  }
}

fn format(value: String) -> Result(Format, String) {
  case value {
    "p3" -> Ok(P3)
    "p6" -> Ok(P6)
    "pam" -> Ok(Pam)
    "bmp" -> Ok(Bmp)
    _ -> Error("unknown output format: " <> value)
  }
}

fn sampling(value: String) -> Result(renderer.Sampling, String) {
  case value {
    "center" -> Ok(renderer.Center)
    "grid" -> Ok(renderer.Grid)
    "jitter" -> Ok(renderer.Jitter)
    "stratified" -> Ok(renderer.Stratified)
    _ -> Error("unknown sampler: " <> value)
  }
}

fn view(value: String) -> Result(renderer.View, String) {
  case value {
    "lit" -> Ok(renderer.Lit)
    "normals" -> Ok(renderer.Normals)
    "depth" -> Ok(renderer.Depth)
    _ -> Error("unknown view: " <> value)
  }
}

pub fn help() -> String {
  "Beam Gleam - deterministic Gleam raytracer\n\nUsage: gleam run -- [options]\n  --scene primitives|textures|mirrors\n  --width N --height N --samples N --depth N --seed N\n  --sampler center|grid|jitter|stratified\n  --view lit|normals|depth --fov DEGREES\n  --format p3|p6|pam|bmp --output PATH (default: stdout)\n  --gamma NUMBER --exposure STOPS --tone-map\n  --help\n"
}
