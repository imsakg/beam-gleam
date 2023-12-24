use std::{
    fs,
    io::{BufWriter, Write},
};

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
            let r = i as f64 / (image_width - 1) as f64;
            let g = j as f64 / (image_height - 1) as f64;
            let b = 0.25;

            let ir = (255.999 * r) as u32;
            let ig = (255.999 * g) as u32;
            let ib = (255.999 * b) as u32;

            let pixel = format!("{} {} {}\n", ir, ig, ib);
            f_handle.write_all(pixel.as_bytes())?;
        }
        eprint!("\rScanlines remaining: {} ", image_height - j - 1);
    }
    eprintln!("\nDone.");

    Ok(())
}
