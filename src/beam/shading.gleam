import beam/hit.{type Hit}
import beam/light.{type Light}
import beam/material.{type Surface}
import beam/ray
import beam/scene
import beam/texture
import beam/vector.{type Vec}
import beam/world
import gleam/float
import gleam/list
import gleam/result

pub fn shade(surface: Surface, h: Hit, view: Vec, lights: List(Light)) -> Vec {
  shade_visible([], surface, h, view, lights)
}

pub fn shade_visible(
  objects: List(scene.Object),
  surface: Surface,
  h: Hit,
  view: Vec,
  lights: List(Light),
) -> Vec {
  let _ = view
  let base = texture.value(surface.texture, h.point, h.u, h.v)
  list.fold(lights, vector.scale(base, surface.ambient), fn(acc, source) {
    let raw_sample = light.sample(source, h.point)
    let blocked =
      world.occluded(
        scene.geometry(objects),
        ray.Ray(offset_origin(h, raw_sample.towards), raw_sample.towards),
        raw_sample.distance -. 0.0002,
      )
    let sample = case blocked {
      True -> light.Sample(..raw_sample, radiance: vector.zero())
      False -> raw_sample
    }
    let cosine = float.max(0.0, vector.dot(h.normal, sample.towards))
    let diffuse =
      vector.scale(
        vector.multiply(base, sample.radiance),
        surface.diffuse *. cosine,
      )
    let reflected = vector.reflect(vector.negate(sample.towards), h.normal)
    let alignment =
      float.max(0.0, vector.dot(vector.unit_or_zero(view), reflected))
    let power =
      float.power(alignment, float.max(1.0, surface.shininess))
      |> result.unwrap(0.0)
    let specular = case cosine >. 0.0 {
      True -> vector.scale(sample.radiance, surface.specular *. power)
      False -> vector.zero()
    }
    vector.add(acc, vector.add(diffuse, specular))
  })
}

pub fn offset_origin(h: Hit, direction: Vec) -> Vec {
  let sign = case vector.dot(direction, h.normal) >=. 0.0 {
    True -> 1.0
    False -> -1.0
  }
  vector.add(h.point, vector.scale(h.normal, sign *. 0.0001))
}
