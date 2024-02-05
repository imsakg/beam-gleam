import beam/vector.{type Vec}
import gleam/float
import gleeunit/should

pub fn close(actual: Float, expected: Float) {
  should.be_true(float.absolute_value(actual -. expected) <. 0.000001)
}

pub fn vector_close(a: Vec, b: Vec) {
  close(a.x, b.x)
  close(a.y, b.y)
  close(a.z, b.z)
}
