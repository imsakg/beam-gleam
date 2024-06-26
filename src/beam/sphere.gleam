import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/math
import beam/ray.{type Ray}
import beam/vector
import gleam/float
import gleam/result

pub fn intersect(
  center: vector.Vec,
  radius: Float,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let oc = vector.subtract(r.origin, center)
  let a = vector.length_squared(r.direction)
  let half_b = vector.dot(oc, r.direction)
  let c = vector.length_squared(oc) -. radius *. radius
  let discriminant = half_b *. half_b -. a *. c
  case discriminant <. 0.0 || radius <=. 0.0 || a <. 1.0e-24 {
    True -> Error(Nil)
    False -> {
      let sqrt_d = float.square_root(discriminant) |> result.unwrap(0.0)
      let near = { 0.0 -. half_b -. sqrt_d } /. a
      let root = case interval.surrounds(span, near) {
        True -> near
        False -> { 0.0 -. half_b +. sqrt_d } /. a
      }
      case interval.surrounds(span, root) {
        False -> Error(Nil)
        True ->
          Ok(surface_hit(
            r,
            root,
            vector.scale(
              vector.subtract(ray.at(r, root), center),
              1.0 /. radius,
            ),
          ))
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
