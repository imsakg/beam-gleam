import gleam/float
import gleam/result

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

pub fn dot(a: Vec, b: Vec) -> Float {
  a.x *. b.x +. a.y *. b.y +. a.z *. b.z
}

pub fn cross(a: Vec, b: Vec) -> Vec {
  Vec(
    a.y *. b.z -. a.z *. b.y,
    a.z *. b.x -. a.x *. b.z,
    a.x *. b.y -. a.y *. b.x,
  )
}

pub fn length_squared(a: Vec) -> Float {
  dot(a, a)
}

pub fn length(a: Vec) -> Float {
  float.square_root(length_squared(a)) |> result.unwrap(0.0)
}

pub fn unit(a: Vec) -> Result(Vec, Nil) {
  let len = length(a)
  case len <. 0.000000000001 {
    True -> Error(Nil)
    False -> Ok(scale(a, 1.0 /. len))
  }
}

pub fn unit_or_zero(a: Vec) -> Vec {
  unit(a) |> result.unwrap(zero())
}

/// The supplied normal must be a unit vector.
pub fn reflect(direction: Vec, normal: Vec) -> Vec {
  subtract(direction, scale(normal, 2.0 *. dot(direction, normal)))
}

/// Direction and normal must be unit vectors; eta is n_incident / n_transmitted.
pub fn refract(direction: Vec, normal: Vec, eta: Float) -> Result(Vec, Nil) {
  let cosine = float.min(dot(negate(direction), normal), 1.0)
  let perpendicular = scale(add(direction, scale(normal, cosine)), eta)
  let parallel_squared = 1.0 -. length_squared(perpendicular)
  case parallel_squared <. 0.0 || eta <=. 0.0 {
    True -> Error(Nil)
    False ->
      Ok(subtract(
        perpendicular,
        scale(normal, float.square_root(parallel_squared) |> result.unwrap(0.0)),
      ))
  }
}
