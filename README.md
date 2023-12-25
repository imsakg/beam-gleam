# Beam Gleam
<!-- Logo -->
![Logo](resources/logo.jpg)

## Description

Beam Gleam is a ray tracing engine written in Rust. It is a work in progress and is not yet usable.

## Usage

The engine using [PPM](https://en.wikipedia.org/wiki/Netpbm) format to encode image and pushing image buffer to standard output to print the image. Since it using standard output, you need to pipe the output to a file to save the image.

To save the image to a file, use the following command:

```bash
cargo run --release > image.ppm
```

