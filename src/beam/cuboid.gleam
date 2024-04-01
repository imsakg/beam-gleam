import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/quad
import beam/ray.{type Ray}
import beam/vector.{type Vec}
import gleam/list

pub fn intersect(lo: Vec, hi: Vec, r: Ray, span: Interval) -> Result(Hit, Nil) {
  case lo.x >=. hi.x || lo.y >=. hi.y || lo.z >=. hi.z {
    True -> Error(Nil)
    False -> {
      let x = vector.new(hi.x -. lo.x, 0.0, 0.0)
      let y = vector.new(0.0, hi.y -. lo.y, 0.0)
      let z = vector.new(0.0, 0.0, hi.z -. lo.z)
      let faces = [
        #(lo, y, x),
        #(vector.new(lo.x, lo.y, hi.z), x, y),
        #(lo, z, y),
        #(vector.new(hi.x, lo.y, lo.z), y, z),
        #(lo, x, z),
        #(vector.new(lo.x, hi.y, lo.z), z, x),
      ]
      list.fold(faces, Error(Nil), fn(best: Result(Hit, Nil), face) {
        let limit = case best {
          Ok(h) -> h.t
          Error(_) -> span.max
        }
        case
          quad.intersect(
            face.0,
            face.1,
            face.2,
            r,
            interval.Interval(span.min, limit),
          )
        {
          Ok(h) -> Ok(h)
          Error(_) -> best
        }
      })
    }
  }
}
