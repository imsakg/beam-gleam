import beam/vector.{type Vec}
import gleam/float

pub type Texture {
  Checker(even: Vec, odd: Vec, scale: Float)
  Solid(color: Vec)
}

pub fn value(texture: Texture, point: Vec, u: Float, v: Float) -> Vec {
  let _ = point
  let _ = u
  let _ = v
  case texture {
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
