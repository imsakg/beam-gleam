import gleam/io

pub fn version() -> String {
  "0.2.0"
}

pub fn main() {
  io.println("Beam Gleam " <> version())
}
