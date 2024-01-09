import beam/vector
import gleeunit/should

pub fn construction_test() {
  vector.new(1.0, 2.0, 3.0).z |> should.equal(3.0)
  vector.zero() |> should.equal(vector.new(0.0, 0.0, 0.0))
}
