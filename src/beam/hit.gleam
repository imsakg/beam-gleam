import beam/ray.{type Ray}
import beam/vector.{type Vec}

pub type Hit {
  Hit(t: Float, point: Vec, normal: Vec, front_face: Bool, u: Float, v: Float)
}

pub fn make(r: Ray, t: Float, outward: Vec) -> Hit {
  let front = vector.dot(r.direction, outward) <. 0.0
  Hit(
    t,
    ray.at(r, t),
    case front {
      True -> outward
      False -> vector.negate(outward)
    },
    front,
    0.0,
    0.0,
  )
}
