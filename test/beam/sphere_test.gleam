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

pub fn tangent_and_zero_direction_test() {
  let assert Ok(tangent) =
    sphere.intersect(
      v.new(1.0, 0.0, -3.0),
      1.0,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(tangent.t, 3.0)
  sphere.intersect(
    v.zero(),
    1.0,
    ray.Ray(v.zero(), v.zero()),
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}

pub fn spherical_uv_test() {
  let equator = sphere.uv(v.new(1.0, 0.0, 0.0))
  assertions.close(equator.0, 0.5)
  assertions.close(equator.1, 0.5)
  assertions.close(sphere.uv(v.new(0.0, 1.0, 0.0)).1, 1.0)
  let assert Ok(h) =
    sphere.intersect(
      v.new(0.0, 0.0, -3.0),
      1.0,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(h.v, 0.5)
  assertions.close(h.u, 0.25)
}

pub fn distant_sphere_precision_test() {
  let r = ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0))
  let assert Ok(h) =
    sphere.intersect(
      v.new(0.0, 0.0, -100_000_000.0),
      1.0,
      r,
      interval.positive(),
    )
  assertions.close(h.t, 99_999_999.0)
  assertions.vector_close(h.normal, v.new(0.0, 0.0, 1.0))
  let assert Ok(slow) =
    sphere.intersect(
      v.new(0.0, 0.0, -3.0),
      1.0,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -0.0000000000001)),
      interval.positive(),
    )
  assertions.vector_close(slow.point, v.new(0.0, 0.0, -2.0))
}
