import assertions
import beam/interval
import beam/material
import beam/ray
import beam/scene
import beam/shape
import beam/texture
import beam/vector as v

pub fn material_selection_test() {
  let red = material.matte(texture.Solid(v.new(1.0, 0.0, 0.0)))
  let blue = material.matte(texture.Solid(v.new(0.0, 0.0, 1.0)))
  let objects = [
    scene.Object(shape.Sphere(v.new(0.0, 0.0, -5.0), 1.0), blue),
    scene.Object(shape.Sphere(v.new(0.0, 0.0, -2.0), 0.5), red),
  ]
  let assert Ok(c) =
    scene.intersect(
      objects,
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      interval.positive(),
    )
  assertions.close(c.hit.t, 1.5)
  texture.value(c.surface.texture, c.hit.point, c.hit.u, c.hit.v)
  |> assertions.vector_close(v.new(1.0, 0.0, 0.0))
}
