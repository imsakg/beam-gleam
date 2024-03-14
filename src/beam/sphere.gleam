import beam/hit.{type Hit}
import beam/interval.{type Interval}
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
          Ok(hit.make(
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
