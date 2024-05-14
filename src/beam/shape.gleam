import beam/bounds
import beam/cuboid
import beam/cylinder
import beam/hit.{type Hit}
import beam/interval.{type Interval}
import beam/plane
import beam/quad
import beam/ray.{type Ray}
import beam/sphere
import beam/triangle
import beam/vector.{type Vec}

pub type Shape {
  Translated(shape: Shape, offset: Vec)
  Sphere(center: Vec, radius: Float)
  Plane(point: Vec, normal: Vec)
  Triangle(a: Vec, b: Vec, c: Vec)
  Quad(origin: Vec, u: Vec, v: Vec)
  Box(min: Vec, max: Vec)
  Cylinder(center: Vec, radius: Float, height: Float, closed: Bool)
}

pub fn intersect(shape: Shape, r: Ray, span: Interval) -> Result(Hit, Nil) {
  case bounding_box(shape) {
    Ok(box) ->
      case bounds.intersects(box, r, span) {
        True -> intersect_raw(shape, r, span)
        False -> Error(Nil)
      }
    Error(_) -> intersect_raw(shape, r, span)
  }
}

fn intersect_raw(shape: Shape, r: Ray, span: Interval) -> Result(Hit, Nil) {
  case shape {
    Translated(child, offset) -> {
      let local = ray.Ray(vector.subtract(r.origin, offset), r.direction)
      case intersect(child, local, span) {
        Ok(h) -> Ok(hit.Hit(..h, point: vector.add(h.point, offset)))
        Error(_) -> Error(Nil)
      }
    }
    Sphere(c, radius) -> sphere.intersect(c, radius, r, span)
    Plane(p, n) -> plane.intersect(p, n, r, span)
    Triangle(a, b, c) -> triangle.intersect(a, b, c, r, span)
    Quad(o, u, v) -> quad.intersect(o, u, v, r, span)
    Box(lo, hi) -> cuboid.intersect(lo, hi, r, span)
    Cylinder(c, radius, height, closed) ->
      cylinder.intersect(c, radius, height, closed, r, span)
  }
}

pub fn bounding_box(shape: Shape) -> Result(bounds.Bounds, Nil) {
  case shape {
    Sphere(c, r) -> {
      let extent = vector.new(r, r, r)
      Ok(bounds.Bounds(vector.subtract(c, extent), vector.add(c, extent)))
    }
    Box(lo, hi) -> Ok(bounds.Bounds(lo, hi))
    Cylinder(c, r, h, _) ->
      Ok(bounds.Bounds(
        vector.add(c, vector.new(0.0 -. r, 0.0, 0.0 -. r)),
        vector.add(c, vector.new(r, h, r)),
      ))
    _ -> Error(Nil)
  }
}
