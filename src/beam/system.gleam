/// Minimal OTP-only I/O boundary. Rendering modules remain pure.
@external(erlang, "beam_io", "arguments")
pub fn arguments() -> List(String)

@external(erlang, "beam_io", "write_file")
pub fn write_file(path: String, data: BitArray) -> Result(Nil, String)

@external(erlang, "beam_io", "read_file")
pub fn read_file(path: String) -> Result(BitArray, String)

@external(erlang, "beam_io", "remove_file")
pub fn remove_file(path: String) -> Result(Nil, String)

@external(erlang, "beam_io", "stdout")
pub fn stdout(data: BitArray) -> Result(Nil, String)

@external(erlang, "beam_io", "error")
pub fn error(message: String) -> Nil

@external(erlang, "beam_io", "exit")
pub fn exit(code: Int) -> Nil
