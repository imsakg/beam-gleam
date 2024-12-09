import assertions
import beam/interval
import beam/plane
import beam/ray
import beam/vector as v
import gleeunit/should

pub fn plane_test() {
  let p = v.new(0.0, -1.0, 0.0)
  let n = v.new(0.0, 2.0, 0.0)
  let assert Ok(h) =
    plane.intersect(
      p,
      n,
      ray.Ray(v.zero(), v.new(0.0, -1.0, 0.0)),
      interval.positive(),
    )
  assertions.close(h.t, 1.0)
  assertions.close(v.length(h.normal), 1.0)
  plane.intersect(
    p,
    n,
    ray.Ray(v.zero(), v.new(1.0, 0.0, 0.0)),
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}

pub fn degenerate_and_behind_test() {
  let r = ray.Ray(v.zero(), v.new(0.0, -1.0, 0.0))
  plane.intersect(v.zero(), v.zero(), r, interval.positive())
  |> should.equal(Error(Nil))
  plane.intersect(
    v.new(0.0, 1.0, 0.0),
    v.new(0.0, 1.0, 0.0),
    r,
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}

pub fn planar_uv_test() {
  let assert Ok(h) =
    plane.intersect(
      v.new(0.0, -1.0, 0.0),
      v.new(0.0, 1.0, 0.0),
      ray.Ray(v.zero(), v.new(0.5, -1.0, 0.5)),
      interval.positive(),
    )
  assertions.close(h.u, -0.5)
  assertions.close(h.v, 0.5)
}
