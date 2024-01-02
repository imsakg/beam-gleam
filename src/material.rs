use crate::utils;
use crate::{Color, HitRecord, Ray};

struct Material {}

trait Material_t {
    fn new() -> Material;
    fn scatter(r_in: &Ray, hit_record: &HitRecord, scattered: &Ray) -> bool;
}
