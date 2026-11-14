"""Recolours the keyboard layer to the monitor's dark blue-grays (Chip, 2026-11-13).

A gradient map: each pixel's brightness picks a colour on a ramp sampled from
T_Room_Monitor_A (ink outlines, slate shadows, the monitor body's gray, its steel highlights),
so the linework, shading and wear stay and only the beige goes. Alpha is kept. The beige
original is in git history (and in the art session's art/style-test/cutout/Keyboard_key.png).

    python art/tools/recolor_keyboard.py [in.png] [out.png]
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'style-test/final/T_Room_Keyboard_A.png'
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else SRC

# (brightness in, colour out), from the monitor art's own range.
RAMP = [
    (0, (10, 12, 18)),
    (50, (34, 40, 52)),
    (110, (58, 67, 82)),
    (170, (80, 92, 108)),
    (215, (96, 111, 128)),
    (255, (140, 158, 170)),
]


def ramp(v):
    for (v0, c0), (v1, c1) in zip(RAMP, RAMP[1:]):
        if v <= v1:
            t = (v - v0) / (v1 - v0)
            return tuple(round(a + (b - a) * t) for a, b in zip(c0, c1))
    return RAMP[-1][1]


LUT = [ramp(v) for v in range(256)]

img = Image.open(SRC).convert('RGBA')
r, g, b, a = img.split()
lum = Image.merge('RGB', (r, g, b)).convert('L')
out = Image.merge('RGB', [lum.point([LUT[v][i] for v in range(256)]) for i in range(3)])
out.putalpha(a)
out.save(OUT)
print('wrote', OUT)
