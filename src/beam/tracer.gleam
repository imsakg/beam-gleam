import beam/background.{type Background}
import beam/color
import beam/interval
import beam/light.{type Light}
import beam/ray.{type Ray}
import beam/scene.{type Object}
import beam/shading
import beam/vector.{type Vec}
import gleam/float

pub fn trace(
  objects: List(Object),
  lights: List(Light),
  r: Ray,
  depth: Int,
) -> Vec {
  trace_background(objects, lights, r, depth, background.Solid(color.black()))
}

pub fn trace_background(
  objects: List(Object),
  lights: List(Light),
  r: Ray,
  depth: Int,
  environment: Background,
) -> Vec {
  case depth <= 0 {
    True -> color.black()
    False ->
      case scene.intersect(objects, r, interval.positive()) {
        Error(_) -> background.sample(environment, r.direction)
        Ok(c) -> {
          let base =
            shading.shade_visible(
              objects,
              c.surface,
              c.hit,
              vector.negate(r.direction),
              lights,
            )
          let amount = float.clamp(c.surface.reflectivity, 0.0, 1.0)
          case amount <=. 0.0 {
            True -> base
            False -> {
              let direction =
                vector.reflect(vector.unit_or_zero(r.direction), c.hit.normal)
              let reflected =
                ray.Ray(shading.offset_origin(c.hit, direction), direction)
              color.mix(
                base,
                trace_background(
                  objects,
                  lights,
                  reflected,
                  depth - 1,
                  environment,
                ),
                amount,
              )
            }
          }
        }
      }
  }
}
