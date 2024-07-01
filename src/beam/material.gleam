import beam/texture.{type Texture}
import beam/vector.{type Vec}

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
