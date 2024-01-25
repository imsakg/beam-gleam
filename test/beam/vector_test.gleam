import beam/vector
import gleeunit/should

pub fn construction_test() {
  vector.new(1.0, 2.0, 3.0).z |> should.equal(3.0)
  vector.zero() |> should.equal(vector.new(0.0, 0.0, 0.0))
}

pub fn addition_test() {
  vector.add(vector.new(1.0, -2.0, 3.0), vector.new(4.0, 2.0, -1.0))
  |> should.equal(vector.new(5.0, 0.0, 2.0))
}

pub fn displacement_test() {
  vector.subtract(vector.new(3.0, 1.0, 2.0), vector.new(1.0, 2.0, 3.0))
  |> should.equal(vector.new(2.0, -1.0, -1.0))
  vector.negate(vector.new(1.0, -2.0, 0.0))
  |> should.equal(vector.new(-1.0, 2.0, 0.0))
}

pub fn scaling_test() {
  let v = vector.new(2.0, -4.0, 1.0)
  vector.scale(v, 0.5) |> should.equal(vector.new(1.0, -2.0, 0.5))
  vector.multiply(v, vector.new(0.5, 0.0, 3.0))
  |> should.equal(vector.new(1.0, -0.0, 3.0))
}

pub fn dot_product_test() {
  vector.dot(vector.new(1.0, 2.0, 3.0), vector.new(-2.0, 1.0, 4.0))
  |> should.equal(12.0)
  vector.dot(vector.new(1.0, 0.0, 0.0), vector.new(0.0, 1.0, 0.0))
  |> should.equal(0.0)
}
