import beam/color
import beam/vector.{type Vec}
import gleam/float

pub type Texture {
  Stripe(first: Vec, second: Vec, scale: Float)
  Gradient(first: Vec, second: Vec, scale: Float)
  Checker(even: Vec, odd: Vec, scale: Float)
  Solid(color: Vec)
}

pub fn value(texture: Texture, point: Vec, u: Float, v: Float) -> Vec {
  let _ = point
  let _ = u
  let _ = v
  case texture {
    Stripe(a, b, scale) ->
      case cell(point.x *. scale) % 2 == 0 {
        True -> a
        False -> b
      }
    Gradient(a, b, scale) -> {
      let x = point.x *. scale
      color.mix(a, b, x -. float.floor(x))
    }
    Checker(even, odd, scale) -> {
      let sum =
        cell(point.x *. scale) + cell(point.y *. scale) + cell(point.z *. scale)
      case sum % 2 == 0 {
        True -> even
        False -> odd
      }
    }
    Solid(color) -> color
  }
}

fn cell(n: Float) -> Int {
  float.floor(n) |> float.truncate
}
