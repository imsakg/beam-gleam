# Beam Gleam

![Logo](resources/logo.jpg)

An educational **Gleam raytracer on Erlang/OTP**, with a deterministic CLI and independently checked image encoders. The original Rust prototype remains alongside it, unchanged.

## Run

Validated locally with Gleam 1.19.2 and Erlang/OTP 29. Install Gleam, Erlang and rebar3, then:

```sh
gleam deps download
gleam test
mkdir -p renders
gleam run -- --scene primitives --width 320 --height 180 --samples 16 \
  --format p6 --output renders/primitives.ppm
```

Use a path under `renders/` rather than overwriting the prototype's existing `image.ppm`. Output directories must already exist.

To stream an image, omit `--output` or pass `--output -`. Only image bytes go to stdout; build messages and errors go to stderr:

```sh
gleam run -- --scene textures --format bmp > renders/textures.bmp
gleam run -- --scene mirrors --format pam --tone-map --exposure 1.0 > renders/mirrors.pam
gleam run -- --view normals --samples 1 --sampler center > renders/normals.ppm
gleam run -- --help
```

## Features

- Spheres, two-sided planes, triangles, parallelogram quads, boxes and capped/open finite cylinders.
- Translation, Y rotation, per-primitive bounding-box culling and nearest-surface selection.
- Solid, world-space checker/stripe/gradient and in-memory RGB image textures; sphere, planar, triangle/quad and cylinder UVs.
- Ambient + Lambert diffuse + Phong highlights; directional and inverse-square point lights; finite hard-shadow rays.
- Emissive surfaces, bounded recursive mirror reflection and solid/gradient sky environments.
- Look-at camera, vertical field of view, aspect ratio and top-down image scanlines.
- Center, regular-grid, seeded jitter and stratified-jitter sampling. Samples are averaged **before** exposure, optional Reinhard tone mapping and gamma.
- P3 ASCII PPM, P6 binary PPM, RGB PAM and padded 24-bit BMP.
- `primitives`, `textures`, `mirrors` scene presets; `lit`, `normals`, `depth` views.

## CLI options

- `--width N --height N`: default 320 × 180.
- `--samples N`: default 4; `--sampler center|grid|jitter|stratified` (default stratified).
- Grid/stratified counts must be perfect squares; center requires one sample; jitter accepts arbitrary positive counts.
- `--seed N`: default 42. The same options produce identical bytes on the same runtime; changing the seed affects jitter, not regular grids.
- `--depth N`: default 5; `--fov DEGREES`: default 45.
- `--scene primitives|textures|mirrors`; `--view lit|normals|depth`.
- `--format p3|p6|pam|bmp`: default p3. File extensions do not choose the format.
- `--output PATH` / `-o PATH`: default stdout (`-`). Existing target files are overwritten; no parent directories are created.
- `--gamma NUMBER`: default 2.2; `--exposure STOPS`: default 0; `--tone-map`: enable Reinhard mapping.
- `--help` / `-h`: usage text. Invalid options fail nonzero without image bytes on stdout.

Render guards: positive dimensions up to 4096 per axis, 1–256 samples, depth 1–32, and at most 8,388,608 primary sample rays. Gamma must be positive and at most 10; exposure is limited to ±20 stops. The educational implementation is single-process and may be slow well below these maximums.

## Verify

```sh
gleam format --check src test
gleam test
python3 -m unittest discover -s scripts -p 'test_*.py'
python3 scripts/smoke_render.py
```

The black-box smoke test uses only Python's standard library. It independently decodes every output format, checks their RGB payloads agree, tests odd-width BMP padding and binary stdout, repeats seeded renders, compares anti-aliasing/scene/view changes, exercises Unicode paths and checks failure behavior. CI runs the same gates; the workflow itself has not been run remotely as part of this local-only development.

## Layout and limits

See [architecture and numerical contracts](docs/architecture.md). `src/beam/*.gleam` is the active Gleam implementation; `src/beam_io.erl` is its small OTP-only I/O adapter. `src/*.rs`, `src/utils/*.rs`, Cargo manifests and the Rust usage below are the preserved original prototype:

```sh
cargo run --release > renders/rust-prototype.ppm
```

The Gleam test suite does not validate Rust. This is a Whitted-style direct-light renderer, **not** an unbiased global-illumination path tracer. It has no BVH, multicore scheduler, transparent materials, area lights, mesh/image-file loader or PNG encoder. Image textures can be constructed programmatically from linear RGB pixel lists; image-file loading is not implied.

## History provenance

The starting repository had 17 **Rust** commits from December 2023–January 2024. The added Gleam implementation was built and tested during agent-assisted development in October 2026. At the user's request, added commit author/committer dates were reconstructed as weekday evenings spanning September 2023–December 2024. They are **not original development timestamps**. Original commits were not rewritten, and nothing was pushed. See [the implementation plan](docs/plans/gleam-raytracer.md#history-provenance) and `History-Reconstruction` trailers for details.
