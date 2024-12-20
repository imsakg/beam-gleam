import beam/camera
import beam/cli
import beam/encoder
import beam/material
import beam/renderer
import beam/scene
import beam/shape
import beam/vector as v
import beam_gleam
import gleam/bit_array
import gleam/list
import gleeunit/should

pub fn preset_pipeline_test() {
  list.each(["primitives", "textures", "mirrors"], fn(name) {
    let assert Ok(cli.Render(options)) =
      cli.parse([
        "--scene",
        name,
        "--width",
        "9",
        "--height",
        "5",
        "--format",
        "p6",
      ])
    let assert Ok(bytes) = beam_gleam.render_bytes(options)
    let header = bit_array.from_string("P6\n9 5\n255\n")
    bit_array.byte_size(bytes)
    |> should.equal(bit_array.byte_size(header) + 9 * 5 * 3)
  })
}

pub fn seeded_pipeline_test() {
  let assert Ok(cli.Render(options)) =
    cli.parse([
      "--width",
      "16",
      "--height",
      "9",
      "--format",
      "p6",
      "--seed",
      "123",
    ])
  let first = beam_gleam.render_bytes(options)
  first |> should.equal(beam_gleam.render_bytes(options))
  let changed =
    cli.Options(
      ..options,
      settings: renderer.Settings(..options.settings, seed: 124),
    )
  should.not_equal(first, beam_gleam.render_bytes(changed))
}

pub fn gamma_after_antialiasing_test() {
  let assert Ok(camera) =
    camera.look_at(
      v.zero(),
      v.new(0.0, 0.0, -1.0),
      v.new(0.0, 1.0, 0.0),
      90.0,
      1.0,
    )
  let objects = [
    scene.Object(
      shape.Sphere(v.new(0.0, 0.0, -3.0), 1.6),
      material.emissive(v.new(1.0, 1.0, 1.0), 1.0),
    ),
  ]
  let assert Ok(frame) =
    renderer.sampled(camera, objects, [], 1, 1, 2, [#(0.5, 0.5), #(0.01, 0.01)])
  let bytes = encoder.p6(frame, encoder.Encoding(2.0, 0.0, False))
  bit_array.slice(bytes, bit_array.byte_size(bytes) - 3, 3)
  |> should.equal(Ok(<<181, 181, 181>>))
}
