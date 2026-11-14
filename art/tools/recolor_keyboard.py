"""Recolours the keyboard layer to the monitor's dark blue-grays, with brighter keycaps
(Chip, 2026-11-13).

A gradient map: each pixel's brightness picks a colour on a ramp sampled from
T_Room_Monitor_A (ink outlines, slate shadows, the monitor body's gray, its steel highlights),
so the linework, shading and wear stay and only the beige goes. The case and the key faces are
nearly the same brightness in the art (about 199 and 206-225), so they're told apart by shape:
the light areas are labelled between the black outlines, the big one is the case and the small
ones are keycaps, and the keycaps get a brighter ramp. Alpha is kept.

Run it on the beige keyboard (remove_keyboard_cable.py's output), not on its own output.

    python art/tools/recolor_keyboard.py in.png [out.png]
"""
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(sys.argv[1])
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / 'style-test/final/T_Room_Keyboard_A.png'

# (brightness in, colour out). The case: the monitor's own range.
CASE_RAMP = [
    (0, (10, 12, 18)),
    (50, (34, 40, 52)),
    (110, (58, 67, 82)),
    (170, (80, 92, 108)),
    (215, (96, 111, 128)),
    (255, (140, 158, 170)),
]
# Keycaps: the same darks, lifted faces.
KEY_RAMP = [
    (0, (10, 12, 18)),
    (50, (34, 40, 52)),
    (110, (72, 82, 98)),
    (170, (124, 136, 152)),
    (215, (168, 180, 194)),
    (255, (214, 222, 230)),
]

LIGHT = 110            # brighter than this is a face (case or key), darker is outline or shade
SEAL = 2               # px the outlines are thickened by so each key is its own region
KEY_MIN, KEY_MAX = 300, 150000  # px area of one keycap face (the spacebar is the biggest), at 4096 x 1024


def lut(ramp):
    out = np.zeros((256, 3), np.float32)
    for v in range(256):
        for (v0, c0), (v1, c1) in zip(ramp, ramp[1:]):
            if v <= v1:
                t = (v - v0) / (v1 - v0)
                out[v] = [a + (b - a) * t for a, b in zip(c0, c1)]
                break
    return out


img = np.array(Image.open(SRC).convert('RGBA'))
rgb, alpha = img[..., :3], img[..., 3]
lum = cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY)

# Light areas, with the outlines thickened a little so keys don't leak into the case.
light = ((lum > LIGHT) & (alpha > 128)).astype(np.uint8)
sealed = cv2.erode(light, np.ones((2 * SEAL + 1, 2 * SEAL + 1), np.uint8))
count, labels, stats, _ = cv2.connectedComponentsWithStats(sealed, connectivity=4)
keys = np.zeros_like(sealed)
for i in range(1, count):
    if KEY_MIN <= stats[i, cv2.CC_STAT_AREA] <= KEY_MAX:
        keys[labels == i] = 1
# Grow the keys back over the sealed margin (only onto light pixels), then soften the edge.
keys = cv2.dilate(keys, np.ones((2 * SEAL + 3, 2 * SEAL + 3), np.uint8)) & light
soft = cv2.GaussianBlur(keys.astype(np.float32), (0, 0), 1.5)[..., None]

case_rgb = lut(CASE_RAMP)[lum]
key_rgb = lut(KEY_RAMP)[lum]
out = case_rgb * (1 - soft) + key_rgb * soft
result = np.dstack([np.clip(out, 0, 255).astype(np.uint8), alpha])
Image.fromarray(result, 'RGBA').save(OUT)
print('wrote', OUT, 'keycaps found:', int(sum(1 for i in range(1, count) if KEY_MIN <= stats[i, cv2.CC_STAT_AREA] <= KEY_MAX)))
