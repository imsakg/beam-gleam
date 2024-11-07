import assertions
import beam/cli
import beam/renderer
import gleeunit/should

pub fn cli_options_test() {
  let assert Ok(cli.Render(options)) =
    cli.parse([
      "--width",
      "16",
      "--height",
      "8",
      "--samples",
      "9",
      "--seed",
      "7",
      "--format",
      "bmp",
      "--scene",
      "textures",
      "--output",
      "render.bmp",
      "--fov",
      "60.0",
      "--gamma",
      "2.0",
      "--exposure",
      "1.0",
      "--tone-map",
      "--sampler",
      "grid",
      "--view",
      "normals",
    ])
  options.settings.width |> should.equal(16)
  options.settings.samples |> should.equal(9)
  options.settings.view |> should.equal(renderer.Normals)
  options.format |> should.equal(cli.Bmp)
  options.encoding.tone_map |> should.be_true
  assertions.close(options.fov, 60.0)
}

pub fn cli_errors_test() {
  cli.parse(["--width", "no"])
  |> should.equal(Error("invalid integer for --width"))
  cli.parse(["--width"]) |> should.equal(Error("missing value for --width"))
  cli.parse(["--wat", "1"]) |> should.equal(Error("unknown option: --wat"))
  cli.parse(["--help"]) |> should.equal(Ok(cli.Help))
  cli.parse(["--samples", "2"])
  |> should.equal(Error("grid sampling requires a square sample count"))
}
