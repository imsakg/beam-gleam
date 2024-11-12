import beam/system
import gleeunit/should

pub fn binary_file_roundtrip_test() {
  let path = "build/beam-io-test.bin"
  let bytes = <<0, 255, 128, 10, 13, 42>>
  system.write_file(path, bytes) |> should.equal(Ok(Nil))
  system.read_file(path) |> should.equal(Ok(bytes))
  system.remove_file(path) |> should.equal(Ok(Nil))
  system.read_file(path) |> should.equal(Error("enoent"))
}
