import beam/interval
import gleeunit/should

pub fn interval_test() {
  let span = interval.Interval(0.001, 10.0)
  interval.surrounds(span, 1.0) |> should.be_true
  interval.surrounds(span, 0.001) |> should.be_false
  interval.surrounds(span, 10.0) |> should.be_false
  interval.new(2.0, 1.0) |> should.equal(Error(Nil))
}
