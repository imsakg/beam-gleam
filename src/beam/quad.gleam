import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/plane
import beam/ray.{type Ray}
import beam/vector.{type Vec}

pub fn intersect(
  origin: Vec,
  edge_u: Vec,
  edge_v: Vec,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let n = vector.cross(edge_u, edge_v)
  case plane.intersect(origin, n, r, span) {
    Error(_) -> Error(Nil)
    Ok(h) -> {
      let p = vector.subtract(h.point, origin)
      let w = vector.scale(n, 1.0 /. vector.length_squared(n))
      let u = vector.dot(w, vector.cross(p, edge_v))
      let v = vector.dot(w, vector.cross(edge_u, p))
      case u <. 0.0 || u >. 1.0 || v <. 0.0 || v >. 1.0 {
        True -> Error(Nil)
        False -> Ok(hit.Hit(..h, u: u, v: v))
      }
    }
  }
}
