import assertions
import beam/interval
import beam/ray
import beam/shape
import beam/vector as v
import beam/world
import gleeunit/should

pub fn nearest_surface_test() {
  let near = shape.Sphere(v.new(0.0, 0.0, -3.0), 1.0)
  let far = shape.Sphere(v.new(0.0, 0.0, -8.0), 1.0)
  let r = ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0))
  let assert Ok(a) = world.intersect([far, near], r, interval.positive())
  let assert Ok(b) = world.intersect([near, far], r, interval.positive())
  assertions.close(a.t, 2.0)
  assertions.close(a.t, b.t)
  world.intersect([], r, interval.positive()) |> should.equal(Error(Nil))
}
