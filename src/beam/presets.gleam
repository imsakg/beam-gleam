import beam/background
import beam/light.{type Light}
import beam/material
import beam/scene.{type Object}
import beam/shape
import beam/texture
import beam/vector.{type Vec}
import gleam/int
import gleam/list

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

pub fn load(name: String) -> Result(Preset, String) {
  case name {
    "primitives" | "demo" -> Ok(demo())
    "textures" -> Ok(textures())
    "mirrors" -> {
      let scene = demo()
      Ok(
        Preset(
          ..scene,
          objects: list.map(scene.objects, fn(o) {
            scene.Object(
              ..o,
              surface: material.Surface(..o.surface, reflectivity: 0.65),
            )
          }),
        ),
      )
    }
    _ -> Error("unknown scene: " <> name)
  }
}

pub fn textures() -> Preset {
  let base = demo()
  let a = vector.new(0.9, 0.1, 0.05)
  let b = vector.new(0.05, 0.3, 0.95)
  let materials = [
    texture.Checker(a, b, 3.0),
    texture.Stripe(a, b, 4.0),
    texture.Gradient(a, b, 1.0),
    texture.Image(2, 2, [a, b, vector.new(1.0, 1.0, 1.0), vector.zero()]),
  ]
  let spheres =
    list.index_map(materials, fn(t, i) {
      scene.Object(
        shape.Sphere(
          vector.new(int.to_float(i) *. 2.1 -. 3.15, 0.0, -2.0),
          0.95,
        ),
        material.shiny(t),
      )
    })
  Preset(
    ..base,
    objects: [
      scene.Object(
        shape.Plane(vector.new(0.0, -1.0, 0.0), vector.new(0.0, 1.0, 0.0)),
        material.matte(texture.Checker(
          vector.new(0.8, 0.8, 0.8),
          vector.new(0.2, 0.2, 0.2),
          1.0,
        )),
      ),
      ..spheres
    ],
    eye: vector.new(4.0, 2.0, 9.0),
    target: vector.new(0.0, 0.0, -2.0),
  )
}
