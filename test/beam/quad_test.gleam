import assertions
import beam/interval
import beam/quad
import beam/ray
import beam/vector as v
import gleeunit/should

pub fn quad_coordinates_test() {
  let o = v.new(-1.0, -1.0, -2.0)
  let u = v.new(2.0, 0.0, 0.0)
  let w = v.new(1.0, 2.0, 0.0)
  let assert Ok(h) =
    quad.intersect(
      o,
      u,
      w,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(h.u, 0.25)
  assertions.close(h.v, 0.5)
  quad.intersect(
    o,
    u,
    w,
    ray.Ray(v.new(4.0, 0.0, 0.0), v.new(0.0, 0.0, -1.0)),
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}
