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

pub fn primitive_bounds_test() {
  let assert Ok(box) =
    shape.bounding_box(shape.Sphere(v.new(1.0, 2.0, 3.0), 2.0))
  assertions.vector_close(box.min, v.new(-1.0, 0.0, 1.0))
  assertions.vector_close(box.max, v.new(3.0, 4.0, 5.0))
}

pub fn translated_hit_test() {
  let primitive =
    shape.Translated(shape.Sphere(v.zero(), 1.0), v.new(0.0, 0.0, -3.0))
  let assert Ok(h) =
    shape.intersect(
      primitive,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(h.t, 2.0)
  assertions.vector_close(h.point, v.new(0.0, 0.0, -2.0))
}
