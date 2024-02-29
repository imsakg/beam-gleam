pub type Interval {
  Interval(min: Float, max: Float)
}

pub fn new(min: Float, max: Float) -> Result(Interval, Nil) {
  case min <=. max {
    True -> Ok(Interval(min, max))
    False -> Error(Nil)
  }
}

pub fn surrounds(span: Interval, value: Float) -> Bool {
  span.min <. value && value <. span.max
}

pub fn positive() -> Interval {
  Interval(0.0001, 1.0e30)
}
