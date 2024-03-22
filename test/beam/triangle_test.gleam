import assertions
import beam/interval
import beam/ray
import beam/triangle
import beam/vector as v
import gleeunit/should

pub fn triangle_test() {
  let a = v.new(-1.0, -1.0, -2.0)
  let b = v.new(1.0, -1.0, -2.0)
  let c = v.new(0.0, 1.0, -2.0)
  let r = ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0))
  let assert Ok(h) = triangle.intersect(a, b, c, r, interval.positive())
  assertions.close(h.t, 2.0)
  assertions.close(h.u, 0.25)
  assertions.close(h.v, 0.5)
  triangle.intersect(
    a,
    b,
    c,
    ray.Ray(v.new(3.0, 0.0, 0.0), r.direction),
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}
