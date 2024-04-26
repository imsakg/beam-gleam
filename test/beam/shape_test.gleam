import assertions
import beam/interval
import beam/ray
import beam/shape
import beam/vector as v

pub fn dispatch_test() {
  let primitive = shape.Sphere(v.new(0.0, 0.0, -3.0), 1.0)
  let assert Ok(h) =
    shape.intersect(
      primitive,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(h.t, 2.0)
}
