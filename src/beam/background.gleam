import beam/color
import beam/vector.{type Vec}
import gleam/float

pub type Background {
  Solid(color: Vec)
  Sky(bottom: Vec, top: Vec)
}

pub fn sample(background: Background, direction: Vec) -> Vec {
  case background {
    Solid(c) -> c
    Sky(bottom, top) ->
      color.mix(
        bottom,
        top,
        float.clamp(
          { vector.unit_or_zero(direction).y +. 1.0 } *. 0.5,
          0.0,
          1.0,
        ),
      )
  }
}
