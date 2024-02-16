import assertions
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

pub fn cross_product_test() {
  let x = vector.new(1.0, 0.0, 0.0)
  let y = vector.new(0.0, 1.0, 0.0)
  vector.cross(x, y) |> should.equal(vector.new(0.0, 0.0, 1.0))
  vector.cross(y, x) |> should.equal(vector.new(0.0, 0.0, -1.0))
  vector.cross(x, x) |> should.equal(vector.zero())
}

pub fn length_test() {
  vector.length_squared(vector.new(2.0, 3.0, 6.0)) |> should.equal(49.0)
  vector.length(vector.new(2.0, 3.0, 6.0)) |> should.equal(7.0)
  vector.length(vector.zero()) |> should.equal(0.0)
}

pub fn normalization_test() {
  vector.unit(vector.zero()) |> should.equal(Error(Nil))
  let assert Ok(v) = vector.unit(vector.new(0.0, 3.0, 4.0))
  assertions.close(vector.length(v), 1.0)
  assertions.close(v.y, 0.6)
}

pub fn reflection_test() {
  let incident = vector.new(1.0, -1.0, 0.0)
  vector.reflect(incident, vector.new(0.0, 1.0, 0.0))
  |> assertions.vector_close(vector.new(1.0, 1.0, 0.0))
}

pub fn refraction_test() {
  let normal = vector.new(0.0, 1.0, 0.0)
  let assert Ok(refracted) =
    vector.refract(vector.new(0.0, -1.0, 0.0), normal, 1.0 /. 1.5)
  assertions.vector_close(refracted, vector.new(0.0, -1.0, 0.0))
  vector.refract(vector.new(0.9, -0.435889894, 0.0), normal, 1.5)
  |> should.equal(Error(Nil))
  vector.refract(vector.new(0.0, -1.0, 0.0), normal, -1.0)
  |> should.equal(Error(Nil))
}
