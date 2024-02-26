import beam/vector.{type Vec}

pub type Ray {
  Ray(origin: Vec, direction: Vec)
}

pub fn at(ray: Ray, t: Float) -> Vec {
  vector.add(ray.origin, vector.scale(ray.direction, t))
}
