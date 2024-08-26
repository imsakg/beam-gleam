import assertions
import beam/sampler
import gleam/list
import gleeunit/should

pub fn centered_grid_test() {
  sampler.center() |> should.equal([#(0.5, 0.5)])
  sampler.grid(2)
  |> should.equal([#(0.25, 0.25), #(0.75, 0.25), #(0.25, 0.75), #(0.75, 0.75)])
  sampler.grid(0) |> should.equal([])
}
