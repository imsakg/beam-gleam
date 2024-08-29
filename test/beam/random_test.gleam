import assertions
import beam/random
import gleeunit/should

pub fn deterministic_random_test() {
  let seed = random.seed(42)
  let first = random.next(seed)
  first |> should.equal(random.next(random.seed(42)))
  should.be_true(first.0 >=. 0.0 && first.0 <. 1.0)
  should.not_equal(first.0, random.next(first.1).0)
  random.next(random.seed(-42)).0 |> assertions.close(first.0)
}
