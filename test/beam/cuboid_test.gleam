import assertions
import beam/cuboid
import beam/interval
import beam/ray
import beam/vector as v

pub fn box_front_and_inside_test() {
  let lo = v.new(-1.0, -1.0, -4.0)
  let hi = v.new(1.0, 1.0, -2.0)
  let assert Ok(h) =
    cuboid.intersect(
      lo,
      hi,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(h.t, 2.0)
  assertions.vector_close(h.normal, v.new(0.0, 0.0, 1.0))
  let assert Ok(inside) =
    cuboid.intersect(
      lo,
      hi,
      ray.Ray(v.new(0.0, 0.0, -3.0), v.new(1.0, 0.0, 0.0)),
      interval.positive(),
    )
  assertions.close(inside.t, 1.0)
}
