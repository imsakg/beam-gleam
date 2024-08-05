import assertions
import beam/material
import beam/ray
import beam/scene
import beam/shape
import beam/texture
import beam/tracer
import beam/vector as v

pub fn reflected_emitter_test() {
  let mirror =
    material.Surface(
      ..material.matte(texture.Solid(v.zero())),
      reflectivity: 1.0,
    )
  let glow = material.emissive(v.new(1.0, 0.25, 0.0), 1.0)
  let objects = [
    scene.Object(
      shape.Plane(v.new(0.0, 0.0, -1.0), v.new(0.0, 0.0, 1.0)),
      mirror,
    ),
    scene.Object(shape.Sphere(v.new(0.0, 0.0, 2.0), 0.5), glow),
  ]
  let r = ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0))
  tracer.trace(objects, [], r, 3)
  |> assertions.vector_close(v.new(1.0, 0.25, 0.0))
  tracer.trace(objects, [], r, 0) |> assertions.vector_close(v.zero())
}
