"""Removes the coiled cable from the keyboard layer (Chip, 2026-11-13).

Everything above the keyboard's top outline, between x 1950 and 2850, is cleared to
transparent (the cable's coil and frayed end), and the outline under the cable's strain relief
is patched with a clean stretch of the same edge from 150 px to the left. The taped corner on
the right is outside the cleared span.

    python art/tools/remove_keyboard_cable.py [in.png] [out.png]
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'style-test/final/T_Room_Keyboard_A.png'
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else SRC

CLEAR_X0, CLEAR_X1 = 1950, 2850      # the cable's span above the top edge
PATCH_X0, PATCH_X1 = 2060, 2170      # under the strain relief
PATCH_SHIFT = 150                    # clean edge to copy from, to the left
PATCH_ROWS = 22                      # rows from just above the edge down into the bezel


def edge_top(x):
    """First row of the keyboard's top outline (131 at x 2000, sloping to 129 at x 3000)."""
    return int(round(131 - (x - 2000) * 0.002))


img = Image.open(SRC).convert('RGBA')
px = img.load()

# Patch first, from the untouched edge, then clear above it.
for x in range(PATCH_X0, PATCH_X1):
    top = edge_top(x) - 4
    for dy in range(PATCH_ROWS):
        px[x, top + dy] = px[x - PATCH_SHIFT, top + dy]

for x in range(CLEAR_X0, CLEAR_X1):
    for y in range(0, edge_top(x) - 2):
        px[x, y] = (0, 0, 0, 0)

img.save(OUT)
print('wrote', OUT)
