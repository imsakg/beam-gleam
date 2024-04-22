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
  case radius <=. 0.0 || height <=. 0.0 {
    True -> Error(Nil)
    False -> valid_intersect(center, radius, height, closed, r, span)
  }
}

fn valid_intersect(
  center: Vec,
  radius: Float,
  height: Float,
  closed: Bool,
  r: Ray,
  span: Interval,
) -> Result(Hit, Nil) {
  let side_hit = side(center, radius, height, r, span)
  case closed {
    False -> side_hit
    True ->
      nearest(
        side_hit,
        nearest(
          cap(center, radius, r, span, -1.0),
          cap(
            vector.add(center, vector.new(0.0, height, 0.0)),
            radius,
            r,
            span,
            1.0,
          ),
        ),
      )
  }
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

fn nearest(a: Result(Hit, Nil), b: Result(Hit, Nil)) -> Result(Hit, Nil) {
  case a, b {
    Ok(x), Ok(y) ->
      case x.t <. y.t {
        True -> a
        False -> b
      }
    Ok(_), _ -> a
    _, _ -> b
  }
}

fn cap(
  center: Vec,
  radius: Float,
  r: Ray,
  span: Interval,
  sign: Float,
) -> Result(Hit, Nil) {
  case float.absolute_value(r.direction.y) <. 1.0e-10 {
    True -> Error(Nil)
    False -> {
      let t = { center.y -. r.origin.y } /. r.direction.y
      let p = vector.subtract(ray.at(r, t), center)
      case
        interval.surrounds(span, t)
        && p.x *. p.x +. p.z *. p.z <=. radius *. radius
      {
        True -> Ok(hit.make(r, t, vector.new(0.0, sign, 0.0)))
        False -> Error(Nil)
      }
    }
  }
}
