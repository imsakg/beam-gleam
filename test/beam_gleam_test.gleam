import beam/cli
import beam_gleam
import gleam/bit_array
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn banner_test() {
  beam_gleam.version() |> should.equal("0.2.0")
}

pub fn render_entry_test() {
  let assert Ok(cli.Render(options)) =
    cli.parse([
      "--width",
      "4",
      "--height",
      "2",
      "--samples",
      "1",
      "--sampler",
      "center",
      "--format",
      "p6",
    ])
  let assert Ok(bytes) = beam_gleam.render_bytes(options)
  bit_array.slice(bytes, 0, 2) |> should.equal(Ok(<<80, 54>>))
  beam_gleam.run(["--scene", "missing"])
  |> should.equal(Error("unknown scene: missing"))
}
