import beam/hit.{type Hit}
import beam/light.{type Light}
import beam/material.{type Surface}
import beam/texture
import beam/vector.{type Vec}
import gleam/float
import gleam/list

pub fn shade(surface: Surface, h: Hit, view: Vec, lights: List(Light)) -> Vec {
  let _ = view
  let base = texture.value(surface.texture, h.point, h.u, h.v)
  list.fold(lights, vector.scale(base, surface.ambient), fn(acc, source) {
    let sample = light.sample(source, h.point)
    let cosine = float.max(0.0, vector.dot(h.normal, sample.towards))
    let diffuse =
      vector.scale(
        vector.multiply(base, sample.radiance),
        surface.diffuse *. cosine,
      )
    vector.add(acc, diffuse)
  })
}
