import beam/vector.{type Vec}

pub type Basis {
  Basis(right: Vec, up: Vec, backward: Vec)
}

pub fn basis(origin: Vec, target: Vec, up: Vec) -> Result(Basis, String) {
  case vector.unit(vector.subtract(origin, target)) {
    Error(_) -> Error("camera origin equals target")
    Ok(w) ->
      case vector.unit(vector.cross(up, w)) {
        Error(_) -> Error("camera up is parallel to view")
        Ok(u) -> Ok(Basis(u, vector.cross(w, u), w))
      }
  }
}
