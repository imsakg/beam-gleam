import beam/color
import beam/vector.{type Vec}
import gleam/float
import gleam/int
import gleam/list
import gleam/result

pub type Texture {
  Image(width: Int, height: Int, pixels: List(Vec))
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
    Image(width, height, pixels) -> {
      let x =
        float.truncate(float.clamp(u, 0.0, 0.999999) *. int.to_float(width))
      let y =
        float.truncate(
          float.clamp(1.0 -. v, 0.0, 0.999999) *. int.to_float(height),
        )
      list.drop(pixels, y * width + x)
      |> list.first
      |> result.unwrap(vector.zero())
    }
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

pub fn image(
  width: Int,
  height: Int,
  pixels: List(Vec),
) -> Result(Texture, Nil) {
  case width > 0 && height > 0 && list.length(pixels) == width * height {
    True -> Ok(Image(width, height, pixels))
    False -> Error(Nil)
  }
}
