import beam/bounds
import beam/interval
import beam/ray
import beam/vector as v
import gleeunit/should

pub fn slab_parallel_test() {
  let box = bounds.Bounds(v.new(-1.0, -1.0, -4.0), v.new(1.0, 1.0, -2.0))
  bounds.intersects(
    box,
    ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
    interval.positive(),
  )
  |> should.be_true
  bounds.intersects(
    box,
    ray.Ray(v.new(2.0, 0.0, 0.0), v.new(0.0, 0.0, -1.0)),
    interval.positive(),
  )
  |> should.be_false
  bounds.intersects(
    box,
    ray.Ray(v.new(1.0, 0.0, 0.0), v.new(0.0, 0.0, -1.0)),
    interval.positive(),
  )
  |> should.be_true
  bounds.intersects(
    box,
    ray.Ray(v.new(0.0, 0.0, -3.0), v.new(0.0, 1.0, 0.0)),
    interval.positive(),
  )
  |> should.be_true
}
