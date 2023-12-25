use std::{
    fs,
    io::{BufWriter, Write},
    rc::Rc,
};

// modules
mod camera;
mod hittable;
mod hittable_list;
mod interval;
mod ray;
mod sphere;
mod utils;

use camera::Camera;
use hittable::{HitRecord, Hittable};
use hittable_list::HittableList;
use interval::Interval;
use ray::Ray;
use utils::vec3::Point3;
use utils::vec3::Vec3;
use utils::{color::Color, INFINITY};

use crate::utils::color;

fn hit_sphere(center: &Point3, radius: f64, r: &Ray) -> f64 {
    let oc = r.origin() - *center;
    let a = r.direction().length_squared();
    let half_b = Vec3::dot(&oc, &r.direction());
    let c = oc.length_squared() - radius * radius;
    let discriminant = half_b * half_b - a * c;
    if discriminant < 0.0 {
        -1.0
    } else {
        (-half_b - discriminant.sqrt()) / a
    }
}

// fn ray_color(r: &Ray, world: &HittableList) -> Color {
//     let mut rec = HitRecord {
//         p: Point3::new(0.0, 0.0, 0.0),
//         normal: Vec3::new(0.0, 0.0, 0.0),
//         t: 0.0,
//         front_face: false,
//     };

//     let temp = Interval::new(Some(Interval {
//         min: 0.0,
//         max: INFINITY,
//     }));
//     if world.hit(r, temp, &mut rec) {
//         return 0.5
//             * Color::new(
//                 rec.normal.x() + 1.0,
//                 rec.normal.y() + 1.0,
//                 rec.normal.z() + 1.0,
//             );
//     }

//     let t = hit_sphere(&Point3::new(0.0, 0.0, -1.0), 0.5, r);
//     if t > 0.0 {
//         let n = Vec3::unit_vector(r.at(t) - Vec3::new(0.0, 0.0, -1.0));
//         return 0.5 * Color::new(n.x() + 1.0, n.y() + 1.0, n.z() + 1.0);
//     }
//     let unit_direction = Vec3::unit_vector(r.direction());
//     let a = 0.5 * (unit_direction.y() + 1.0);
//     (1.0 - a) * Color::new(1.0, 1.0, 1.0) + a * Color::new(0.5, 0.7, 1.0)
// }

fn main() -> std::io::Result<()> {
    let mut world = HittableList::new();
    world.add(Rc::new(sphere::Sphere::new(
        Point3::new(0.0, 0.0, -1.0),
        0.5,
    )));
    world.add(Rc::new(sphere::Sphere::new(
        Point3::new(0.0, -100.5, -1.0),
        100.0,
    )));

    let cam = Camera::new(16_f64 / 9_f64, 400, 100);
    cam.render(&world);
    Ok(())
}
