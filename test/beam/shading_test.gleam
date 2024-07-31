import assertions
import beam/hit
import beam/light
import beam/material
import beam/ray
import beam/scene
import beam/shading
import beam/shape
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

pub fn hard_shadow_test() {
  let surface =
    material.Surface(
      ..material.matte(texture.Solid(v.new(1.0, 1.0, 1.0))),
      ambient: 0.0,
      diffuse: 1.0,
    )
  let h =
    hit.make(
      ray.Ray(v.new(0.0, 0.0, 1.0), v.new(0.0, 0.0, -1.0)),
      1.0,
      v.new(0.0, 0.0, 1.0),
    )
  let source =
    light.Point(v.new(0.0, 0.0, 4.0), v.new(1.0, 1.0, 1.0), 201.06192982974676)
  let blocker = scene.Object(shape.Sphere(v.new(0.0, 0.0, 2.0), 0.5), surface)
  shading.shade_visible([blocker], surface, h, v.new(0.0, 0.0, 1.0), [source])
  |> assertions.vector_close(v.zero())
  let behind = scene.Object(shape.Sphere(v.new(0.0, 0.0, 8.0), 0.5), surface)
  shading.shade_visible([behind], surface, h, v.new(0.0, 0.0, 1.0), [source])
  |> assertions.vector_close(v.new(1.0, 1.0, 1.0))
}

pub fn self_lit_test() {
  let surface = material.emissive(v.new(1.0, 0.25, 0.0), 2.0)
  let h =
    hit.make(
      ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0)),
      1.0,
      v.new(0.0, 0.0, 1.0),
    )
  shading.shade(surface, h, v.new(0.0, 0.0, 1.0), [])
  |> assertions.vector_close(v.new(2.0, 0.5, 0.0))
}
