import assertions
import beam/hit
import beam/light
import beam/material
import beam/ray
import beam/shading
import beam/texture
import beam/vector as v

pub fn lambert_test() {
  let red = v.new(1.0, 0.0, 0.0)
  let surface =
    material.Surface(
      ..material.matte(texture.Solid(red)),
      ambient: 0.0,
      diffuse: 1.0,
    )
  let h =
    hit.make(
      ray.Ray(v.new(0.0, 0.0, 1.0), v.new(0.0, 0.0, -1.0)),
      1.0,
      v.new(0.0, 0.0, 1.0),
    )
  let source = light.Directional(v.new(0.0, 0.0, -1.0), v.new(1.0, 1.0, 1.0))
  shading.shade(surface, h, v.new(0.0, 0.0, 1.0), [source])
  |> assertions.vector_close(red)
  shading.shade(surface, h, v.new(0.0, 0.0, 1.0), [
    light.Directional(v.new(0.0, 0.0, 1.0), v.new(1.0, 1.0, 1.0)),
  ])
  |> assertions.vector_close(v.zero())
}

pub fn phong_test() {
  let surface =
    material.Surface(
      ..material.shiny(texture.Solid(v.zero())),
      ambient: 0.0,
      diffuse: 0.0,
      specular: 0.5,
    )
  let h =
    hit.make(
      ray.Ray(v.new(0.0, 0.0, 1.0), v.new(0.0, 0.0, -1.0)),
      1.0,
      v.new(0.0, 0.0, 1.0),
    )
  let source = light.Directional(v.new(0.0, 0.0, -1.0), v.new(1.0, 1.0, 1.0))
  shading.shade(surface, h, v.new(0.0, 0.0, 1.0), [source])
  |> assertions.vector_close(v.new(0.5, 0.5, 0.5))
  shading.shade(surface, h, v.new(1.0, 0.0, 0.0), [source])
  |> assertions.vector_close(v.zero())
}
