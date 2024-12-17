# Gleam raytracer implementation plan

> **For Hermes:** Use test-driven-development for each behavior slice and independently review the final result.

**Goal:** Add a working, tested Gleam raytracer alongside the original Rust prototype, building 83 substantive local commits for 100 total.

**Architecture:** Pure immutable vector, ray, geometry, texture and shading modules; deterministic sampling; camera and rendering pipeline; small Erlang adapters only for command-line arguments and file/stdout I/O. Keep the Rust implementation and pre-existing local artifacts untouched.

**Tech stack:** Gleam on Erlang/OTP, gleam_stdlib, gleeunit, Python smoke validators.

## History provenance

The starting checkout contains **17 Rust commits**, dated 2023-12-24 through 2024-01-02; its name does not mean it contains Gleam. New code is an actual Gleam implementation, not a relabeling of Rust. The requested September 2023–December 2024 weekday/evening dates are **reconstructed metadata applied during agent-assisted development in October 2026**, not evidence of historical activity. Original commits are preserved unchanged. The initial planning commit is dated September 2023, earlier than its parent in wall-clock time; ancestry remains intact. Subsequent implementation commits are distributed across weekday evenings in 2024. Every added commit carries a History-Reconstruction trailer. No pushes are authorized.

## Verification loop

For each behavior: add a focused failing gleeunit test; run `gleam test` to observe the missing behavior; implement the smallest coherent change; run `gleam format src test`, `gleam test` and `git diff --check`; stage only the slice; sign and commit. Documentation/config-only slices use appropriate parsing or smoke checks. No empty commits or fabricated test results. Preserve dirty Cargo.lock, profiler data, firedbg directory and the existing image.

## Ordered increments

1. Record scope, provenance, architecture and acceptance gates (this document).
2. Bootstrap Gleam and the test harness without moving Rust sources.
3–13. Vector construction/arithmetic, dot/cross products, normalization, reflection, refraction and rotation; zero and numerical edge cases.
14–18. Ray evaluation, intervals, oriented hit records and bounded sphere intersections.
19–27. Plane, triangle, quadrilateral, box and finite cylinder intersections; cap, parallel and tangent regressions.
28–34. Scene nearest-hit dispatch, bounds, translation, Y rotation and visibility queries.
35–42. Linear colors, channel clamping, gamma/exposure/tone mapping, solid/checker/stripe/gradient/image textures and sphere UVs.
43–51. Surface materials; directional/point lights, Lambert/Phong response, shadows, attenuation, emissive and recursive reflective shading.
52–59. Camera basis, field of view, aspect validation, deterministic subpixel sampling, stratification, seeded jitter and supersampling.
60–68. Framebuffer renderer, backgrounds, normal/depth views, recursion limits, texture integration and scene presets.
69–75. P3/P6 PPM and PAM encoders, RGB byte packing, CLI parsing, file output and stdout discipline.
76–83. End-to-end smoke and deterministic regressions, CI, documentation, integration fixes and final independently reviewed acceptance.

## Acceptance

- About 100 total commits, each nonempty and accurately described; new commit dates in the requested window, weekday evenings, signatures verified.
- `gleam test` and `gleam format --check src test` pass.
- CLI produces valid P3, P6 and PAM images; dimensions/channel counts independently parsed; repeated seeded renders identical; AA changes an actual edge image.
- Multiple primitives, textures, lit shadows, reflective surfaces and camera options are used by runnable presets.
- Read-only original-history comparison and dirty-file hashes match the baseline. No remote writes.

## Implemented outcome

The Gleam core, six primitive families, textures/UVs, lighting/shadows, reflection, camera/sampling, three presets, diagnostic views, four encoders and CLI are implemented. Independent review findings have regression tests and fixes. Local Gleeunit and CLI smoke checks pass. Final integration regressions and the exact signed-history audit close the work; remote CI and pushing remain out of scope.

See [README](../../README.md) for runnable commands and [architecture](../architecture.md) for implemented contracts and limitations. Original Rust sources and pre-existing dirty files remain untouched.
