import assertions
import beam/background
import beam/ray
import beam/tracer
import beam/vector as v

pub fn sky_test() {
  let sky = background.Sky(v.new(1.0, 1.0, 1.0), v.new(0.2, 0.4, 0.8))
  background.sample(sky, v.new(0.0, 1.0, 0.0))
  |> assertions.vector_close(v.new(0.2, 0.4, 0.8))
  tracer.trace_background(
    [],
    [],
    ray.Ray(v.zero(), v.new(0.0, -1.0, 0.0)),
    1,
    sky,
  )
  |> assertions.vector_close(v.new(1.0, 1.0, 1.0))
}
