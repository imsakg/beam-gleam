pub type Vec {
  Vec(x: Float, y: Float, z: Float)
}

pub fn new(x: Float, y: Float, z: Float) -> Vec {
  Vec(x, y, z)
}

pub fn zero() -> Vec {
  Vec(0.0, 0.0, 0.0)
}
