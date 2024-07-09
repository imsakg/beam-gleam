import beam/vector.{type Vec}

pub type Light {
  Directional(direction: Vec, radiance: Vec)
}

pub type Sample {
  Sample(towards: Vec, radiance: Vec, distance: Float)
}

pub fn sample(light: Light, point: Vec) -> Sample {
  let _ = point
  case light {
    Directional(direction, radiance) ->
      Sample(vector.unit_or_zero(vector.negate(direction)), radiance, 1.0e30)
  }
}
