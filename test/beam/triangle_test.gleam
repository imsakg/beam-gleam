import assertions
import beam/interval
import beam/ray
import beam/triangle
import beam/vector as v
import gleeunit/should

pub fn triangle_test() {
  let a = v.new(-1.0, -1.0, -2.0)
  let b = v.new(1.0, -1.0, -2.0)
  let c = v.new(0.0, 1.0, -2.0)
  let r = ray.Ray(v.zero(), v.new(0.0, 0.0, -1.0))
  let assert Ok(h) = triangle.intersect(a, b, c, r, interval.positive())
  assertions.close(h.t, 2.0)
  assertions.close(h.u, 0.25)
  assertions.close(h.v, 0.5)
  triangle.intersect(
    a,
    b,
    c,
    ray.Ray(v.new(3.0, 0.0, 0.0), r.direction),
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}

pub fn winding_and_edge_test() {
  let a = v.new(-1.0, -1.0, -2.0)
  let b = v.new(1.0, -1.0, -2.0)
  let c = v.new(0.0, 1.0, -2.0)
  let r = ray.Ray(v.new(0.0, -1.0, 0.0), v.new(0.0, 0.0, -1.0))
  let assert Ok(edge) = triangle.intersect(a, b, c, r, interval.positive())
  assertions.close(edge.u, 0.5)
  let assert Ok(reverse) = triangle.intersect(c, b, a, r, interval.positive())
  assertions.close(reverse.t, edge.t)
  triangle.intersect(a, a, c, r, interval.positive())
  |> should.equal(Error(Nil))
}
