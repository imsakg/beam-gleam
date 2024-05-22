import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/ray.{type Ray}
import beam/shape.{type Shape}
import gleam/list

pub fn intersect(
  objects: List(Shape),
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  list.fold(objects, Error(Nil), fn(best: Result(Hit, Nil), object) {
    let limit = case best {
      Ok(h) -> h.t
      Error(_) -> span.max
    }
    case shape.intersect(object, r, interval.Interval(span.min, limit)) {
      Ok(h) -> Ok(h)
      Error(_) -> best
    }
  })
}

/// Ray direction must be unit length when max_distance is a world-space distance.
pub fn occluded(objects: List(Shape), r: Ray, max_distance: Float) -> Bool {
  list.any(objects, fn(object) {
    case shape.intersect(object, r, interval.Interval(0.0001, max_distance)) {
      Ok(_) -> True
      Error(_) -> False
    }
  })
}
