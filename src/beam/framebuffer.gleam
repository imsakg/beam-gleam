import beam/vector.{type Vec}
import gleam/list

pub type Frame {
  Frame(width: Int, height: Int, pixels: List(Vec))
}

pub fn create(
  width: Int,
  height: Int,
  pixels: List(Vec),
) -> Result(Frame, String) {
  case width <= 0 || height <= 0 {
    True -> Error("image dimensions must be positive")
    False ->
      case list.length(pixels) == width * height {
        True -> Ok(Frame(width, height, pixels))
        False -> Error("pixel count does not match dimensions")
      }
  }
}
