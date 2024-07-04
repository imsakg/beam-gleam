import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/material.{type Surface}
import beam/ray.{type Ray}
import beam/shape.{type Shape}
import gleam/list

pub type Object {
  Object(geometry: Shape, surface: Surface)
}

pub type Collision {
  Collision(hit: Hit, surface: Surface)
}

pub fn intersect(
  objects: List(Object),
  r: Ray,
  span: Interval,
) -> Result(Collision, Nil) {
  list.fold(objects, Error(Nil), fn(best: Result(Collision, Nil), object) {
    let limit = case best {
      Ok(c) -> c.hit.t
      Error(_) -> span.max
    }
    case
      shape.intersect(object.geometry, r, interval.Interval(span.min, limit))
    {
      Ok(h) -> Ok(Collision(h, object.surface))
      Error(_) -> best
    }
  })
}

pub fn geometry(objects: List(Object)) -> List(Shape) {
  list.map(objects, fn(o) { o.geometry })
}
