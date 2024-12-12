#!/usr/bin/env python3
"""Black-box CLI smoke tests and independent decoders; standard library only."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def decode(data: bytes) -> tuple[int, int, bytes]:
    if data.startswith(b"P3\n"):
        tokens = data.split()
        width, height, maximum = map(int, tokens[1:4])
        assert maximum == 255
        pixels = bytes(map(int, tokens[4:]))
    elif data.startswith(b"P6\n"):
        _, dimensions, maximum, pixels = data.split(b"\n", 3)
        width, height = map(int, dimensions.split())
        assert maximum == b"255"
    elif data.startswith(b"P7\n"):
        header, marker, pixels = data.partition(b"ENDHDR\n")
        assert marker
        fields = dict(line.split(maxsplit=1) for line in header.splitlines()[1:])
        width, height = int(fields[b"WIDTH"]), int(fields[b"HEIGHT"])
        assert fields[b"DEPTH"] == b"3"
        assert fields[b"MAXVAL"] == b"255"
        assert fields[b"TUPLTYPE"] == b"RGB"
    elif data.startswith(b"BM"):
        assert len(data) >= 54
        size, _, offset = struct.unpack_from("<III", data, 2)
        dib, width, height, planes, bits, compression = struct.unpack_from("<IiiHHI", data, 14)
        assert size == len(data) and offset == 54 and dib == 40
        assert planes == 1 and bits == 24 and compression == 0
        assert width > 0 and height > 0
        stride = (width * 3 + 3) // 4 * 4
        assert len(data) == offset + stride * height
        rgb = bytearray()
        for y in reversed(range(height)):
            row = data[offset + y * stride:offset + y * stride + width * 3]
            for x in range(0, len(row), 3):
                blue, green, red = row[x:x + 3]
                rgb.extend((red, green, blue))
        pixels = bytes(rgb)
    else:
        raise AssertionError("unknown image signature")
    assert width > 0 and height > 0
    assert len(pixels) == width * height * 3, "truncated or surplus pixel payload"
    return width, height, pixels


def main() -> None:
    gleam = os.environ.get("GLEAM") or shutil.which("gleam")
    if not gleam:
        raise SystemExit("Gleam was not found; install it or set GLEAM")
    env = dict(os.environ)
    env.setdefault("ERL_FLAGS", "+S 2:2")
    subprocess.run([gleam, "build"], cwd=ROOT, env=env, check=True)
    (ROOT / "build").mkdir(exist_ok=True)
    checks = []

    def run(arguments: list[str], success: bool = True) -> subprocess.CompletedProcess:
        result = subprocess.run([gleam, "run", "--", *arguments], cwd=ROOT, env=env,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=90)
        assert (result.returncode == 0) == success, (arguments, result.stderr.decode(errors="replace"))
        return result

    base = ["--width", "23", "--height", "15", "--samples", "4", "--seed", "17"]
    with tempfile.TemporaryDirectory(prefix="beam-smoke-", dir=ROOT / "build") as directory:
        folder = Path(directory)
        files = {}
        payloads = {}
        for kind in ["p3", "p6", "pam", "bmp"]:
            path = folder / f"render.{kind}"
            result = run([*base, "--format", kind, "--output", str(path)])
            assert result.stdout == b"", "file output contaminated stdout"
            files[kind] = path.read_bytes()
            width, height, payloads[kind] = decode(files[kind])
            assert (width, height) == (23, 15)
        assert len(set(payloads.values())) == 1, "format encoders disagree"
        assert len(set(payloads["p6"])) > 32, "render lacks scene variation"
        checks.append("P3/P6/PAM/BMP decode to identical 23x15 RGB pixels; odd-width BMP padding validated")

        stdout = run([*base, "--format", "p6", "--output", "-"]).stdout
        assert stdout == files["p6"], "binary stdout differs from file output"
        assert run([*base, "--format", "p6"]).stdout == stdout
        checks.append("binary stdout is clean and repeat renders are byte-identical")

        alternate = run([*base, "--seed", "18", "--format", "p6"]).stdout
        assert decode(alternate)[2] != payloads["p6"]
        centered = run([*base, "--samples", "1", "--sampler", "center", "--format", "p6"]).stdout
        assert decode(centered)[2] != payloads["p6"]
        checks.append("changing the seed and enabling subpixel anti-aliasing both change rendered pixels")

        for name in ["textures", "mirrors"]:
            result = run([*base, "--scene", name, "--format", "p6"])
            assert decode(result.stdout)[2] != payloads["p6"]
        for view in ["normals", "depth"]:
            result = run([*base, "--view", view, "--format", "p6"])
            assert decode(result.stdout)[2] != payloads["p6"]
        checks.append("all three scene presets and both diagnostic views produce distinct images")

        unicode_path = folder / "ışık-渲染.ppm"
        run([*base, "--format", "p6", "--output", str(unicode_path)])
        assert unicode_path.read_bytes() == stdout
        checks.append("Unicode output paths preserve image bytes")

        for arguments in [["--width", "0"], ["--width", "bad"], ["--samples", "2"],
                          ["--format", "png"], ["--fov", "180"], ["--wat", "1"]]:
            result = run(arguments, success=False)
            assert result.stdout == b"" and result.stderr
        absent = folder / "must-not-exist.ppm"
        result = run([*base, "--scene", "absent", "--output", str(absent)], success=False)
        assert not absent.exists() and result.stdout == b""
        result = run([*base, "--output", str(folder / "absent" / "image.ppm")], success=False)
        assert result.stdout == b"" and b"enoent" in result.stderr
        help_result = run(["--help"])
        assert b"Usage:" in help_result.stdout
        checks.append("invalid flags/scenes/paths fail nonzero on stderr without creating misleading output")

        print(json.dumps({"checks_passed": len(checks), "checks": checks,
                          "rgb_sha256": hashlib.sha256(payloads["p6"]).hexdigest(),
                          "format_sizes": {k: len(v) for k, v in files.items()}}, indent=2))


if __name__ == "__main__":
    main()
