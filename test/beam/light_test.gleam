import assertions
import beam/light
import beam/vector as v

pub fn directional_test() {
  let source = light.Directional(v.new(0.0, -2.0, 0.0), v.new(2.0, 1.0, 0.5))
  let sample = light.sample(source, v.zero())
  assertions.vector_close(sample.towards, v.new(0.0, 1.0, 0.0))
  assertions.vector_close(sample.radiance, v.new(2.0, 1.0, 0.5))
}
