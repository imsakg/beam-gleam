import beam/vector.{type Vec}
import gleam/float

pub type Light {
  Point(position: Vec, color: Vec, power: Float)
  Directional(direction: Vec, radiance: Vec)
}

pub type Sample {
  Sample(towards: Vec, radiance: Vec, distance: Float)
}

pub fn sample(light: Light, point: Vec) -> Sample {
  let _ = point
  case light {
    Point(position, color, power) -> {
      let delta = vector.subtract(position, point)
      let distance = vector.length(delta)
      let attenuation = case distance >. 1.0e-10 {
        True ->
          float.max(0.0, power)
          /. { 12.566370614359172 *. distance *. distance }
        False -> 0.0
      }
      Sample(
        vector.unit_or_zero(delta),
        vector.scale(color, attenuation),
        distance,
      )
    }
    Directional(direction, radiance) ->
      Sample(vector.unit_or_zero(vector.negate(direction)), radiance, 1.0e30)
  }
}
