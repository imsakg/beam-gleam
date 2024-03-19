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
            True -> Ok(hit.make(r, t, n))
            False -> Error(Nil)
          }
        }
      }
    }
  }
}
