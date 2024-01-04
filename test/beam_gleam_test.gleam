import beam_gleam
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn banner_test() {
  beam_gleam.version() |> should.equal("0.2.0")
}
