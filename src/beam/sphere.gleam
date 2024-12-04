import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/math
import beam/ray.{type Ray}
import beam/vector
import gleam/float
import gleam/result

/// Closest-approach geometry avoids subtracting almost equal large squares.
pub fn intersect(
  center: vector.Vec,
  radius: Float,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let offset = vector.subtract(r.origin, center)
  let a = vector.length_squared(r.direction)
  case radius <=. 0.0 || a <=. 0.0 {
    True -> Error(Nil)
    False -> {
      let middle = { 0.0 -. vector.dot(offset, r.direction) } /. a
      let closest = vector.add(offset, vector.scale(r.direction, middle))
      let remaining = radius *. radius -. vector.length_squared(closest)
      case remaining <. 0.0 {
        True -> Error(Nil)
        False -> {
          let delta = float.square_root(remaining /. a) |> result.unwrap(0.0)
          let near = middle -. delta
          let root = case interval.surrounds(span, near) {
            True -> near
            False -> middle +. delta
          }
          case interval.surrounds(span, root) {
            False -> Error(Nil)
            True ->
              Ok(surface_hit(
                r,
                root,
                vector.unit_or_zero(vector.subtract(ray.at(r, root), center)),
              ))
          }
        }
      }
    }
  }
}

pub fn uv(normal: vector.Vec) -> #(Float, Float) {
  let theta = math.arccos(float.clamp(0.0 -. normal.y, -1.0, 1.0))
  let phi = math.atan2(0.0 -. normal.z, normal.x) +. 3.141592653589793
  #(phi /. 6.283185307179586, theta /. 3.141592653589793)
}

fn surface_hit(r: Ray, t: Float, outward: vector.Vec) -> Hit {
  let coords = uv(outward)
  hit.Hit(..hit.make(r, t, outward), u: coords.0, v: coords.1)
}
