use crate::interval::Interval;

use super::vec3;

pub use vec3::Vec3 as Color;

#[inline]
fn linear_to_gamma(linear_component: f64) -> f64 {
    linear_component.sqrt()
}

pub fn write_color(pixel_color: &Color, samples_per_pixel: i32) -> String {
    let mut r = pixel_color.x();
    let mut g = pixel_color.y();
    let mut b = pixel_color.z();

    // Apply the linear to gamma transform
    r = linear_to_gamma(r);
    g = linear_to_gamma(g);
    b = linear_to_gamma(b);

    // Divide the color by the number of samples and gamma-correct for gamma=2.0.
    let scale = 1.0 / samples_per_pixel as f64;
    r *= scale;
    g *= scale;
    b *= scale;

    // Write the translated [0,255] value of each color component.
    let intensity = Interval::new(Some(Interval {
        min: 0.000,
        max: 0.999,
    }));

    format!(
        "{} {} {}",
        (256.0 * intensity.clamp(r).sqrt()) as i32,
        (256.0 * intensity.clamp(g).sqrt()) as i32,
        (256.0 * intensity.clamp(b).sqrt()) as i32
    )
}
