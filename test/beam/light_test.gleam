import assertions
import beam/light
import beam/vector as v

pub fn directional_test() {
  let source = light.Directional(v.new(0.0, -2.0, 0.0), v.new(2.0, 1.0, 0.5))
  let sample = light.sample(source, v.zero())
  assertions.vector_close(sample.towards, v.new(0.0, 1.0, 0.0))
  assertions.vector_close(sample.radiance, v.new(2.0, 1.0, 0.5))
}

pub fn point_attenuation_test() {
  let source = light.Point(v.zero(), v.new(1.0, 1.0, 1.0), 12.566370614359172)
  let near = light.sample(source, v.new(0.0, 0.0, 1.0))
  let far = light.sample(source, v.new(0.0, 0.0, 2.0))
  assertions.close(near.radiance.x, 1.0)
  assertions.close(far.radiance.x, 0.25)
  assertions.close(far.distance, 2.0)
  assertions.vector_close(light.sample(source, v.zero()).radiance, v.zero())
}
