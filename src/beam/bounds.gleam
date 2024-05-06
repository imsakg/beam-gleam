import beam/interval.{type Interval}
import beam/ray.{type Ray}
import beam/vector.{type Vec}
import gleam/float
import gleam/list
import gleam/result

pub type Bounds {
  Bounds(min: Vec, max: Vec)
}

pub fn intersects(box: Bounds, r: Ray, span: Interval) -> Bool {
  let axes = [
    #(box.min.x, box.max.x, r.origin.x, r.direction.x),
    #(box.min.y, box.max.y, r.origin.y, r.direction.y),
    #(box.min.z, box.max.z, r.origin.z, r.direction.z),
  ]
  list.fold(axes, Ok(span), fn(current, axis) {
    result.try(current, fn(s) { clip(axis.0, axis.1, axis.2, axis.3, s) })
  })
  |> result.is_ok
}

fn clip(
  lo: Float,
  hi: Float,
  origin: Float,
  direction: Float,
  span: Interval,
) -> Result(Interval, Nil) {
  case direction >=. 0.0 && direction <=. 0.0 {
    True ->
      case origin <. lo || origin >. hi {
        True -> Error(Nil)
        False -> Ok(span)
      }
    False -> {
      let a = { lo -. origin } /. direction
      let b = { hi -. origin } /. direction
      let low = float.max(span.min, float.min(a, b))
      let high = float.min(span.max, float.max(a, b))
      case high <. low {
        True -> Error(Nil)
        False -> Ok(interval.Interval(low, high))
      }
    }
  }
}
