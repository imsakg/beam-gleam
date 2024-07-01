import assertions
import beam/material
import beam/texture
import beam/vector as v
import gleeunit/should

pub fn material_defaults_test() {
  let matte = material.matte(texture.Solid(v.new(0.8, 0.2, 0.1)))
  assertions.close(matte.diffuse, 0.9)
  assertions.close(matte.reflectivity, 0.0)
  let glossy = material.shiny(matte.texture)
  should.be_true(glossy.specular >. matte.specular)
}
