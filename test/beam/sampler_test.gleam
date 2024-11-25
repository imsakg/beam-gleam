import assertions
import beam/sampler
import gleam/float
import gleam/int
import gleam/list
import gleeunit/should

pub fn centered_grid_test() {
  sampler.center() |> should.equal([#(0.5, 0.5)])
  sampler.grid(2)
  |> should.equal([#(0.25, 0.25), #(0.75, 0.25), #(0.25, 0.75), #(0.75, 0.75)])
  sampler.grid(0) |> should.equal([])
}

pub fn seeded_jitter_test() {
  let samples = sampler.jitter(8, 123)
  samples |> should.equal(sampler.jitter(8, 123))
  list.length(samples) |> should.equal(8)
  list.each(samples, fn(p) {
    should.be_true(p.0 >=. 0.0 && p.0 <. 1.0 && p.1 >=. 0.0 && p.1 <. 1.0)
  })
  sampler.jitter(0, 123) |> should.equal([])
  should.not_equal(samples, sampler.jitter(8, 124))
}

pub fn stratified_cells_test() {
  let points = sampler.stratified(3, 42)
  list.length(points) |> should.equal(9)
  list.index_map(points, fn(p, i) {
    assertions.close(float.floor(p.0 *. 3.0), int.to_float(i % 3))
    assertions.close(float.floor(p.1 *. 3.0), int.to_float(i / 3))
  })
  sampler.stratified(1, 42) |> should.equal(sampler.jitter(1, 42))
}

pub fn negative_side_test() {
  sampler.grid(-2) |> should.equal([])
  sampler.stratified(-2, 42) |> should.equal([])
}
