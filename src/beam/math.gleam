/// Trigonometric operations provided by OTP, with radians as the unit.
@external(erlang, "math", "sin")
pub fn sine(radians: Float) -> Float

@external(erlang, "math", "cos")
pub fn cosine(radians: Float) -> Float

@external(erlang, "math", "tan")
pub fn tangent(radians: Float) -> Float

@external(erlang, "math", "atan2")
pub fn atan2(y: Float, x: Float) -> Float

@external(erlang, "math", "acos")
pub fn arccos(x: Float) -> Float
