import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/ray.{type Ray}
import beam/vector.{type Vec}
import gleam/float

pub fn intersect(
  point: Vec,
  normal: Vec,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  case vector.unit(normal) {
    Error(_) -> Error(Nil)
    Ok(n) -> {
      let denominator = vector.dot(n, r.direction)
      case float.absolute_value(denominator) <. 1.0e-10 {
        True -> Error(Nil)
        False -> {
          let t = vector.dot(vector.subtract(point, r.origin), n) /. denominator
          case interval.surrounds(span, t) {
            True -> Ok(surface_hit(r, t, n, point))
            False -> Error(Nil)
          }
        }
      }
    }
  }
}

fn surface_hit(r: Ray, t: Float, normal: Vec, anchor: Vec) -> Hit {
  let reference = case float.absolute_value(normal.y) <. 0.9 {
    True -> vector.new(0.0, 1.0, 0.0)
    False -> vector.new(0.0, 0.0, 1.0)
  }
  let tangent = vector.unit_or_zero(vector.cross(reference, normal))
  let bitangent = vector.cross(normal, tangent)
  let h = hit.make(r, t, normal)
  let p = vector.subtract(h.point, anchor)
  hit.Hit(..h, u: vector.dot(p, tangent), v: vector.dot(p, bitangent))
}
