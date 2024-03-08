import assertions
import beam/interval
import beam/ray
import beam/sphere
import beam/vector as v
import gleeunit/should

pub fn sphere_hit_test() {
  let r = ray.Ray(v.zero(), v.new(0.0, 0.0, -2.0))
  let assert Ok(h) =
    sphere.intersect(v.new(0.0, 0.0, -3.0), 1.0, r, interval.positive())
  assertions.close(h.t, 1.0)
  assertions.vector_close(h.normal, v.new(0.0, 0.0, 1.0))
  sphere.intersect(v.new(0.0, 4.0, -3.0), 1.0, r, interval.positive())
  |> should.equal(Error(Nil))
}
