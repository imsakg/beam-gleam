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
