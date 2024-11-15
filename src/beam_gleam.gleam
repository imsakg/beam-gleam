import beam/camera
import beam/cli
import beam/encoder
import beam/presets
import beam/renderer
import beam/system
import beam/vector
import gleam/bit_array
import gleam/int
import gleam/result

pub fn version() -> String {
  "0.2.0"
}

pub fn main() {
  case run(system.arguments()) {
    Ok(_) -> Nil
    Error(message) -> {
      system.error(message)
      system.exit(1)
    }
  }
}

pub fn run(arguments: List(String)) -> Result(Nil, String) {
  use command <- result.try(cli.parse(arguments))
  case command {
    cli.Help -> system.stdout(bit_array.from_string(cli.help()))
    cli.Render(options) -> {
      use bytes <- result.try(render_bytes(options))
      case options.output {
        "-" -> system.stdout(bytes)
        path -> system.write_file(path, bytes)
      }
    }
  }
}

pub fn render_bytes(options: cli.Options) -> Result(BitArray, String) {
  use _ <- result.try(renderer.validate(options.settings))
  use preset <- result.try(presets.load(options.scene))
  let aspect =
    int.to_float(options.settings.width)
    /. int.to_float(options.settings.height)
  use camera <- result.try(camera.look_at(
    preset.eye,
    preset.target,
    vector.new(0.0, 1.0, 0.0),
    options.fov,
    aspect,
  ))
  let settings =
    renderer.Settings(..options.settings, environment: preset.environment)
  use frame <- result.try(renderer.render_with(
    settings,
    camera,
    preset.objects,
    preset.lights,
  ))
  Ok(case options.format {
    cli.P3 -> encoder.p3(frame, options.encoding)
    cli.P6 -> encoder.p6(frame, options.encoding)
    cli.Pam -> encoder.pam(frame, options.encoding)
    cli.Bmp -> encoder.bmp(frame, options.encoding)
  })
}
