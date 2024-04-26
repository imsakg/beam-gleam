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
  Sphere(center: Vec, radius: Float)
  Plane(point: Vec, normal: Vec)
  Triangle(a: Vec, b: Vec, c: Vec)
  Quad(origin: Vec, u: Vec, v: Vec)
  Box(min: Vec, max: Vec)
  Cylinder(center: Vec, radius: Float, height: Float, closed: Bool)
}

pub fn intersect(shape: Shape, r: Ray, span: Interval) -> Result(Hit, Nil) {
  case shape {
    Sphere(c, radius) -> sphere.intersect(c, radius, r, span)
    Plane(p, n) -> plane.intersect(p, n, r, span)
    Triangle(a, b, c) -> triangle.intersect(a, b, c, r, span)
    Quad(o, u, v) -> quad.intersect(o, u, v, r, span)
    Box(lo, hi) -> cuboid.intersect(lo, hi, r, span)
    Cylinder(c, radius, height, closed) ->
      cylinder.intersect(c, radius, height, closed, r, span)
  }
}
