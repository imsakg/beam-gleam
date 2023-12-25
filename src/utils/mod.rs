pub mod color;
pub mod vec3;

use crate::interval::*;
use rand::*;
pub const INFINITY: f64 = f64::INFINITY;
pub const PI: f64 = std::f64::consts::PI;

#[inline]
pub fn degrees_to_radians(degrees: f64) -> f64 {
    degrees * PI / 180.0
}

#[inline]
pub fn random_double() -> f64 {
    // Returns a random real in [0,1).
    let mut rng = rand::thread_rng();
    rng.gen()
}

#[inline]
pub fn random_double_range(min: f64, max: f64) -> f64 {
    // Returns a random real in [min,max).
    let mut rng = rand::thread_rng();
    rng.gen_range(min..max)
}
