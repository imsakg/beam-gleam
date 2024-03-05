import assertions
import beam/hit
import beam/ray
import beam/vector as v
import gleeunit/should

pub fn oriented_hit_test() {
  let normal = v.new(0.0, 0.0, 1.0)
  let outside = hit.make(ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)), 1.0, normal)
  outside.front_face |> should.be_true
  assertions.vector_close(outside.normal, normal)
  let inside = hit.make(ray.Ray(v.zero(), normal), 1.0, normal)
  inside.front_face |> should.be_false
  assertions.vector_close(inside.normal, v.negate(normal))
}
