import beam/vector.{type Vec}

pub type Texture {
  Solid(color: Vec)
}

pub fn value(texture: Texture, point: Vec, u: Float, v: Float) -> Vec {
  let _ = point
  let _ = u
  let _ = v
  case texture {
    Solid(color) -> color
  }
}
