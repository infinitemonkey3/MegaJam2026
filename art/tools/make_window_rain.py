"""Rain on the room's window (Chip, 2026-11-14). No rain particle systems ship with UEFN, so the
rain is two layers of streaks panning down in the back wall's material, clipped to the window's
glass. This writes:
  - art/style-test/final/T_Room_RainStreaks.png: a 256 x 512 tile of thin falling streaks (white,
    alpha only matters), tiling top to bottom;
  - art/style-test/final/T_Room_WindowGlassMask.png: 1024 x 512, white where the back wall
    (T_Room_BackWallClean_A, 4096 x 2048) shows glass: the lower pane, and the strip of the upper
    pane below the blinds. Feathered a little.
build_window_rain.py builds the material.

Run: python art/tools/make_window_rain.py
"""
import os
import random
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FINAL = os.path.join(ROOT, "art", "style-test", "final")

# Streaks: like the painted ones, near vertical, thin, of mixed length and strength.
random.seed(7)
W, H = 256, 512
tile = Image.new("RGBA", (W, H), (255, 255, 255, 0))
d = ImageDraw.Draw(tile)
for _ in range(46):
    x = random.uniform(0, W)
    y = random.uniform(0, H)
    length = random.uniform(18, 70)
    alpha = random.randint(70, 220)
    width = random.choice((1, 1, 2, 2, 3))
    for dy in (0, -H, H):                       # wrap so the tile repeats seamlessly
        d.line((x, y + dy, x - length * 0.04, y + length + dy), fill=(255, 255, 255, alpha), width=width)
tile = tile.filter(ImageFilter.GaussianBlur(0.6))
tile.save(os.path.join(FINAL, "T_Room_RainStreaks.png"))

# The glass, in 4096 x 2048 wall pixels, drawn into a quarter-size mask.
S = 0.25
mask = Image.new("L", (int(4096 * S), int(2048 * S)), 0)
md = ImageDraw.Draw(mask)
md.rectangle((529 * S, 952 * S, 1265 * S, 1409 * S), fill=255)              # lower pane
# Upper pane below the blinds: the bottom slat hangs at a slant, lower on the right.
md.polygon([(529 * S, 798 * S), (1258 * S, 848 * S), (1258 * S, 900 * S), (529 * S, 900 * S)], fill=255)
mask = mask.filter(ImageFilter.GaussianBlur(2))
mask.save(os.path.join(FINAL, "T_Room_WindowGlassMask.png"))
print("wrote rain streaks and glass mask")
