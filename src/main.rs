use std::{
    fs,
    io::{BufWriter, Write},
};

// modules
mod utils;

use utils::color::Color;
use utils::vec3::Vec3;

use crate::utils::color;

fn main() -> std::io::Result<()> {
    // Image
    let (image_width, image_height) = (256, 256);
    let file_path = "image.ppm";
    // Render

    let f = fs::File::create(file_path)?;
    let mut f_handle = BufWriter::new(f);

    let header = format!("P3\n{} {}\n255\n", image_width, image_height);
    f_handle.write_all(header.as_bytes())?;

    for j in 0..image_height {
        // Print progress
        for i in 0..image_width {
            let pixel = Color::new(
                i as f64 / (image_width - 1) as f64,
                j as f64 / (image_height - 1) as f64,
                0.25,
            );
            f_handle.write_all(color::write_color(&pixel).as_bytes())?;
        }
        eprint!("\rScanlines remaining: {} ", image_height - j - 1);
    }
    eprintln!("\nDone.");

    Ok(())
}
