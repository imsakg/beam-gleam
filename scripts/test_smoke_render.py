"""Test the independent smoke decoders, including transport-sensitive bytes."""
import struct
import unittest
import smoke_render


class DecoderTests(unittest.TestCase):
    def test_ascii_ppm(self):
        self.assertEqual(smoke_render.decode(b"P3\n2 1\n255\n255 0 0\n0 255 0\n"),
                         (2, 1, bytes([255, 0, 0, 0, 255, 0])))

    def test_binary_payload_whitespace_is_not_stripped(self):
        pixels = bytes([10, 13, 32, 255, 0, 128])
        self.assertEqual(smoke_render.decode(b"P6\n2 1\n255\n" + pixels), (2, 1, pixels))

    def test_pam_metadata(self):
        prefix = b"P7\nWIDTH 1\nHEIGHT 1\nDEPTH 3\nMAXVAL 255\nTUPLTYPE RGB\nENDHDR\n"
        self.assertEqual(smoke_render.decode(prefix + bytes([0, 128, 255])),
                         (1, 1, bytes([0, 128, 255])))
        with self.assertRaises(AssertionError):
            smoke_render.decode(prefix.replace(b"DEPTH 3", b"DEPTH 4") + bytes([0, 128, 255]))

    def test_bmp_bottom_up_bgr_and_padding(self):
        header = struct.pack("<2sIHHI", b"BM", 62, 0, 0, 54)
        info = struct.pack("<IiiHHIIiiII", 40, 1, 2, 1, 24, 0, 8, 2835, 2835, 0, 0)
        # Stored bottom blue row first, then the red top row, each padded to 4 bytes.
        body = bytes([255, 0, 0, 0, 0, 0, 255, 0])
        self.assertEqual(smoke_render.decode(header + info + body),
                         (1, 2, bytes([255, 0, 0, 0, 0, 255])))

    def test_truncated_and_surplus_payloads_rejected(self):
        for pixels in [b"", b"xx", b"xxxx"]:
            with self.subTest(payload=pixels), self.assertRaises(AssertionError):
                smoke_render.decode(b"P6\n1 1\n255\n" + pixels)

    def test_unknown_format_rejected(self):
        with self.assertRaises(AssertionError):
            smoke_render.decode(b"not an image")


if __name__ == "__main__":
    unittest.main()
