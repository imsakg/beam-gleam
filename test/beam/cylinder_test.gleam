import assertions
import beam/cylinder
import beam/interval
import beam/ray
import beam/vector as v
import gleeunit/should

pub fn cylinder_sides_test() {
  let r = ray.Ray(v.new(0.0, 1.0, 3.0), v.new(0.0, 0.0, -1.0))
  let assert Ok(h) =
    cylinder.intersect(v.zero(), 1.0, 2.0, False, r, interval.positive())
  assertions.close(h.t, 2.0)
  assertions.vector_close(h.normal, v.new(0.0, 0.0, 1.0))
  cylinder.intersect(
    v.zero(),
    1.0,
    2.0,
    False,
    ray.Ray(v.new(0.0, 3.0, 3.0), r.direction),
    interval.positive(),
  )
  |> should.equal(Error(Nil))
}
