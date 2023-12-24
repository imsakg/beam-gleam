use std::{
    fs,
    io::{BufWriter, Write},
};

// modules
mod ray;
mod utils;

use ray::Ray;
use utils::color::Color;
use utils::vec3::Point3;
use utils::vec3::Vec3;

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

fn ray_color(r: &Ray) -> Color {
    let t = hit_sphere(&Point3::new(0.0, 0.0, -1.0), 0.5, r);
    if t > 0.0 {
        let n = Vec3::unit_vector(r.at(t) - Vec3::new(0.0, 0.0, -1.0));
        return 0.5 * Color::new(n.x() + 1.0, n.y() + 1.0, n.z() + 1.0);
    }
    let unit_direction = Vec3::unit_vector(r.direction());
    let a = 0.5 * (unit_direction.y() + 1.0);
    (1.0 - a) * Color::new(1.0, 1.0, 1.0) + a * Color::new(0.5, 0.7, 1.0)
}

fn main() -> std::io::Result<()> {
    // Image
    let aspect_ratio = 16.0 / 9.0;
    // Calculate the image height, and ensure that it is at least 1.
    let image_width = 400;
    let image_height = (image_width as f64 / aspect_ratio) as i32;
    if image_height < 1 {
        panic!("Image height must be at least 1.");
    }

    // Camera
    let focal_length = 1.0;
    let viewport_height = 2.0;
    let viewport_width = aspect_ratio * viewport_height;
    let camera_center = Vec3::new(0.0, 0.0, 0.0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    let viewport_u = Vec3::new(viewport_width, 0.0, 0.0);
    let viewport_v = Vec3::new(0.0, -viewport_height, 0.0);

    // Calculate the hoizontal and vertical delta vectors from pixel to pixel.
    let pixel_delta_u = viewport_u / (image_width - 1) as f64;
    let pixel_delta_v = viewport_v / (image_height - 1) as f64;

    // Calculate the bottom left corner of the viewport.
    let viewport_upper_left =
        camera_center - Vec3::new(0_f64, 0_f64, focal_length) - viewport_u / 2.0 - viewport_v / 2.0;
    let pixel100_loc = viewport_upper_left + 0.5 * pixel_delta_u + 0.5 * pixel_delta_v;

    let file_path = "image.ppm";
    // Render

    let f = fs::File::create(file_path)?;
    let mut f_handle = BufWriter::new(f);

    let header = format!("P3\n{} {}\n255\n", image_width, image_height);
    f_handle.write_all(header.as_bytes())?;

    for j in 0..image_height {
        for i in 0..image_width {
            let pixel_center =
                pixel100_loc + (i as f64 * pixel_delta_u) + (j as f64 * pixel_delta_v);
            let ray_direction = pixel_center - camera_center;
            let r = Ray::new(camera_center, ray_direction);

            let pixel_color = ray_color(&r);

            f_handle.write_all(color::write_color(&pixel_color).as_bytes())?;
        }
        eprint!("\rScanlines remaining: {} ", image_height - j - 1);
    }
    eprintln!("\nDone.");

    Ok(())
}
