import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/ray.{type Ray}
import beam/vector.{type Vec}
import gleam/float
import gleam/result

pub fn intersect(
  center: Vec,
  radius: Float,
  height: Float,
  closed: Bool,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let _ = closed
  side(center, radius, height, r, span)
}

fn side(
  center: Vec,
  radius: Float,
  height: Float,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let o = vector.subtract(r.origin, center)
  let d = r.direction
  let a = d.x *. d.x +. d.z *. d.z
  let b = o.x *. d.x +. o.z *. d.z
  let c = o.x *. o.x +. o.z *. o.z -. radius *. radius
  let disc = b *. b -. a *. c
  case a <. 1.0e-20 || disc <. 0.0 {
    True -> Error(Nil)
    False -> {
      let root = float.square_root(disc) |> result.unwrap(0.0)
      case
        side_root({ 0.0 -. b -. root } /. a, center, radius, height, r, span)
      {
        Ok(h) -> Ok(h)
        Error(_) ->
          side_root({ 0.0 -. b +. root } /. a, center, radius, height, r, span)
      }
    }
  }
}

fn side_root(
  t: Float,
  center: Vec,
  radius: Float,
  height: Float,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let p = vector.subtract(ray.at(r, t), center)
  case !interval.surrounds(span, t) || p.y <. 0.0 || p.y >. height {
    True -> Error(Nil)
    False -> Ok(hit.make(r, t, vector.new(p.x /. radius, 0.0, p.z /. radius)))
  }
}
