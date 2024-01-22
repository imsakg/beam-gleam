pub type Vec {
  Vec(x: Float, y: Float, z: Float)
}

pub fn new(x: Float, y: Float, z: Float) -> Vec {
  Vec(x, y, z)
}

pub fn zero() -> Vec {
  Vec(0.0, 0.0, 0.0)
}

pub fn add(a: Vec, b: Vec) -> Vec {
  Vec(a.x +. b.x, a.y +. b.y, a.z +. b.z)
}

pub fn subtract(a: Vec, b: Vec) -> Vec {
  Vec(a.x -. b.x, a.y -. b.y, a.z -. b.z)
}

pub fn negate(a: Vec) -> Vec {
  subtract(zero(), a)
}

pub fn scale(a: Vec, amount: Float) -> Vec {
  Vec(a.x *. amount, a.y *. amount, a.z *. amount)
}

pub fn multiply(a: Vec, b: Vec) -> Vec {
  Vec(a.x *. b.x, a.y *. b.y, a.z *. b.z)
}
