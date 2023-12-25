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

    let cam = Camera::new(16_f64 / 9_f64, 720, 100);
    cam.render(&world);
    Ok(())
}
