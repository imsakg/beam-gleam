import assertions
import beam/ray
import beam/vector as v

pub fn ray_at_test() {
  let r = ray.Ray(v.new(1.0, 2.0, 3.0), v.new(0.0, 0.0, -2.0))
  ray.at(r, 2.5) |> assertions.vector_close(v.new(1.0, 2.0, -2.0))
  ray.at(r, 0.0) |> assertions.vector_close(r.origin)
}
