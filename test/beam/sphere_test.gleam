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

pub fn inside_and_clipped_test() {
  let center = v.zero()
  let r = ray.Ray(center, v.new(1.0, 0.0, 0.0))
  let assert Ok(h) = sphere.intersect(center, 2.0, r, interval.positive())
  assertions.close(h.t, 2.0)
  h.front_face |> should.be_false
  let assert Ok(far) =
    sphere.intersect(
      v.new(0.0, 0.0, -3.0),
      1.0,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.Interval(2.5, 5.0),
    )
  assertions.close(far.t, 4.0)
}
