import beam/background
import beam/light.{type Light}
import beam/material
import beam/scene.{type Object}
import beam/shape
import beam/texture
import beam/vector.{type Vec}

pub type Preset {
  Preset(
    objects: List(Object),
    lights: List(Light),
    eye: Vec,
    target: Vec,
    fov: Float,
    environment: background.Background,
  )
}

pub fn demo() -> Preset {
  let floor =
    material.matte(texture.Checker(
      vector.new(0.8, 0.8, 0.75),
      vector.new(0.12, 0.14, 0.18),
      1.0,
    ))
  let red =
    material.shiny(texture.Gradient(
      vector.new(0.9, 0.08, 0.04),
      vector.new(0.95, 0.7, 0.08),
      0.4,
    ))
  let blue = material.shiny(texture.Solid(vector.new(0.08, 0.25, 0.7)))
  let mirror =
    material.Surface(
      ..material.shiny(texture.Solid(vector.new(0.8, 0.8, 0.8))),
      reflectivity: 0.75,
    )
  let objects = [
    scene.Object(
      shape.Plane(vector.new(0.0, -1.0, 0.0), vector.new(0.0, 1.0, 0.0)),
      floor,
    ),
    scene.Object(shape.Sphere(vector.new(-1.6, 0.0, -2.0), 1.0), red),
    scene.Object(
      shape.RotatedY(
        shape.Box(vector.new(0.0, -1.0, -3.0), vector.new(1.4, 0.5, -1.6)),
        0.3,
      ),
      blue,
    ),
    scene.Object(
      shape.Cylinder(vector.new(2.6, -1.0, -3.7), 0.65, 2.1, True),
      red,
    ),
    scene.Object(
      shape.Triangle(
        vector.new(-4.0, -1.0, -4.0),
        vector.new(-2.0, -1.0, -4.0),
        vector.new(-3.0, 1.2, -4.0),
      ),
      blue,
    ),
    scene.Object(
      shape.Quad(
        vector.new(-5.0, -1.0, -6.0),
        vector.new(10.0, 0.0, 0.0),
        vector.new(0.0, 4.0, 0.0),
      ),
      material.matte(texture.Solid(vector.new(0.4, 0.45, 0.5))),
    ),
    scene.Object(shape.Sphere(vector.new(0.7, -0.35, 0.5), 0.65), mirror),
    scene.Object(
      shape.Sphere(vector.new(-0.5, 2.0, -5.0), 0.3),
      material.emissive(vector.new(1.0, 0.6, 0.2), 2.0),
    ),
  ]
  Preset(
    objects,
    [
      light.Point(vector.new(-3.0, 6.0, 4.0), vector.new(1.0, 0.9, 0.75), 900.0),
      light.Directional(vector.new(0.6, -1.0, -0.5), vector.new(0.25, 0.3, 0.4)),
    ],
    vector.new(6.0, 3.0, 7.0),
    vector.new(0.0, 0.1, -2.0),
    45.0,
    background.Sky(vector.new(0.9, 0.95, 1.0), vector.new(0.25, 0.5, 0.9)),
  )
}
