# Architecture and numerical contracts

## Pipeline

1. `beam/cli` parses arguments into explicit render and encoder settings; invalid values return descriptive errors.
2. `beam/presets` provides immutable objects, materials, lights, camera placement and environment.
3. `beam/camera` constructs an orthonormal look-at frame and maps bottom-up normalized viewport coordinates to unit primary rays.
4. `beam/renderer` visits the framebuffer in **top-down row-major order**, chooses deterministic subpixel offsets and averages linear radiance.
5. `beam/tracer` selects the nearest `beam/scene` collision, evaluates visible direct light and follows reflective rays up to the depth budget. Misses sample `beam/background`.
6. `beam/encoder` applies exposure, optional tone mapping, gamma and 8-bit clamping, then encodes P3/P6/PAM/BMP.
7. `beam/system` and `beam_io.erl` alone read arguments or perform I/O. Stdout is configured for binary-safe Latin-1 transport; rendering and encoding remain pure.

## Geometry

A ray retains its parameterization: `origin + t * direction`. Primitive intersections accept non-unit directions; camera and lighting rays are normalized. `Interval` is open at both ends to reject self-intersections and hits beyond a light. `Hit.normal` opposes the incoming ray; `front_face` records whether the original outward normal faced it. Normals are unit vectors for valid nondegenerate primitives.

The shape union dispatches all primitives. Nearest-hit folds narrow the upper interval as they find candidates. Sphere/box/cylinder bounds are an early rejection filter, not a BVH. Translated/rotated wrappers inverse-transform rays and transform hit positions/normals back; they deliberately fall back to uncullled intersection rather than using incorrect transformed bounds.

Sphere intersection uses closest-approach geometry to avoid cancellation of large nearly equal squared terms. Triangle parallelism tolerance scales with edge/ray magnitudes; normals are computed from normalized edges. Plane/cylinder near-parallel cutoffs and the 0.0001 world-space secondary-ray offset remain practical educational tolerances, not a proof of arbitrary-scale numerical robustness. Huge coordinates, subnormal values and primitives far below ordinary scene scales are not guaranteed.

Triangle UVs are barycentric; quad UVs use its two edge vectors. Sphere/cylinder U follows azimuth and V follows polar angle/height. Cylinder cap coordinates map the disk into a unit square. Infinite planes use a stable local orthonormal frame, with unbounded U/V. In-memory image textures clamp to edge texels (V=1 is the top row); procedural patterns use world-space positions. Object transforms preserve generated UVs but procedural world-space patterns intentionally remain anchored in the world.

## Shading

Materials carry a texture, ambient/diffuse/specular coefficients, shininess, reflectivity and emission. Point-light power is scaled by `1 / (4πr²)`; directional light has no attenuation. Lambert and Phong are zero for light behind the oriented surface normal. Hard shadows offset their origin and stop before the sampled point light, so geometry behind the light does not occlude it.

Direct light is mixed with the recursively reflected result by clamped reflectivity; emissive surfaces return light even with no external lights. Emission does **not** illuminate neighbors through global illumination. The vector library provides refraction and total-internal-reflection tests, but no transparent material/integrator has been added.

## Sampling and limits

The PRNG is a functional Park–Miller generator with explicit state; no process-global randomness participates in a render. Pixel coordinates derive independent seeds. Grid and stratified modes use square sample counts; jitter supports arbitrary positive counts. Public rasterization paths share validation before allocation, and custom sample offsets must lie in `[0,1)` on both axes.

The built-in limits bound primary rays, not all secondary work: recursion and light/shadow counts still multiply cost. Framebuffer and texture record constructors are public low-level building blocks; use their validating `create`/`image` helpers rather than constructing inconsistent records. Encoders assume valid frames. Output is held in memory; this is not a streaming or production renderer.

## Test strategy

- Gleeunit tests cover vector identities, zero normalization, oriented hits, all primitives, clipping, degenerate/parallel/tangent cases, transformed shapes, nearest surfaces, UVs, material selection, lighting/shadows, reflection termination, camera validation and deterministic sampling.
- Independent review produced regressions for bypassed public render guards, negative sample grids, tiny triangles, distant spheres and missing plane/cylinder UVs. These were reproduced, fixed and tested.
- `scripts/smoke_render.py` runs the actual CLI and decodes its files independently, rather than comparing encoder output to itself.
- CI definition is provided, but no remote CI or push is part of this work. Local tool output is the execution evidence.

## Preserved prototype

The original Rust files and user-local profiler/render artifacts were not refactored, removed or staged. Gleam and Rust share `src/` by file extension, with their respective build outputs ignored. The dirty Cargo.lock was preserved, not adopted into the Gleam history.
