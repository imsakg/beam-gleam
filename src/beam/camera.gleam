import beam/math
import beam/ray
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

pub type Camera {
  Camera(origin: Vec, lower_left: Vec, horizontal: Vec, vertical: Vec)
}

pub fn look_at(
  origin: Vec,
  target: Vec,
  up: Vec,
  vfov: Float,
  aspect: Float,
) -> Result(Camera, String) {
  case vfov <=. 0.0 || vfov >=. 180.0 {
    True -> Error("field of view must be between 0 and 180 degrees")
    False ->
      case aspect <=. 0.0 {
        True -> Error("aspect ratio must be positive")
        False -> valid_look_at(origin, target, up, vfov, aspect)
      }
  }
}

fn valid_look_at(
  origin: Vec,
  target: Vec,
  up: Vec,
  vfov: Float,
  aspect: Float,
) -> Result(Camera, String) {
  case basis(origin, target, up) {
    Error(e) -> Error(e)
    Ok(frame) -> {
      let height = 2.0 *. math.tangent(vfov *. 0.008726646259971648)
      let horizontal = vector.scale(frame.right, height *. aspect)
      let vertical = vector.scale(frame.up, height)
      let lower =
        vector.subtract(
          vector.subtract(
            vector.subtract(origin, vector.scale(horizontal, 0.5)),
            vector.scale(vertical, 0.5),
          ),
          frame.backward,
        )
      Ok(Camera(origin, lower, horizontal, vertical))
    }
  }
}

/// u increases left to right; v increases bottom to top.
pub fn ray(camera: Camera, u: Float, v: Float) -> ray.Ray {
  let point =
    vector.add(
      camera.lower_left,
      vector.add(
        vector.scale(camera.horizontal, u),
        vector.scale(camera.vertical, v),
      ),
    )
  ray.Ray(
    camera.origin,
    vector.unit_or_zero(vector.subtract(point, camera.origin)),
  )
}
