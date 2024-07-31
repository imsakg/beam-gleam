import beam/texture.{type Texture}
import beam/vector.{type Vec}
import gleam/float

pub type Surface {
  Surface(
    texture: Texture,
    ambient: Float,
    diffuse: Float,
    specular: Float,
    shininess: Float,
    reflectivity: Float,
    emission: Vec,
  )
}

pub fn matte(texture: Texture) -> Surface {
  Surface(texture, 0.08, 0.9, 0.0, 32.0, 0.0, vector.zero())
}

pub fn shiny(texture: Texture) -> Surface {
  Surface(..matte(texture), specular: 0.6, shininess: 80.0)
}

pub fn emissive(color: Vec, strength: Float) -> Surface {
  Surface(
    ..matte(texture.Solid(vector.zero())),
    ambient: 0.0,
    diffuse: 0.0,
    emission: vector.scale(color, float.max(0.0, strength)),
  )
}
