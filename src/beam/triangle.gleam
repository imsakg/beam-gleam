import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/ray.{type Ray}
import beam/vector.{type Vec}
import gleam/float

pub fn intersect(
  a: Vec,
  b: Vec,
  c: Vec,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let e1 = vector.subtract(b, a)
  let e2 = vector.subtract(c, a)
  let p = vector.cross(r.direction, e2)
  let det = vector.dot(e1, p)
  let tolerance =
    1.0e-12
    *. vector.length(e1)
    *. vector.length(e2)
    *. vector.length(r.direction)
  case float.absolute_value(det) <=. tolerance {
    True -> Error(Nil)
    False -> {
      let inverse = 1.0 /. det
      let offset = vector.subtract(r.origin, a)
      let u = vector.dot(offset, p) *. inverse
      let q = vector.cross(offset, e1)
      let v = vector.dot(r.direction, q) *. inverse
      let t = vector.dot(e2, q) *. inverse
      case
        u <. 0.0 || v <. 0.0 || u +. v >. 1.0 || !interval.surrounds(span, t)
      {
        True -> Error(Nil)
        False ->
          Ok(
            hit.Hit(
              ..hit.make(
                r,
                t,
                vector.unit_or_zero(vector.cross(
                  vector.unit_or_zero(e1),
                  vector.unit_or_zero(e2),
                )),
              ),
              u: u,
              v: v,
            ),
          )
      }
    }
  }
}
