"""Viewfinder corners for clickable room objects (room-lines.md, Chip 2026-11-15): four thin
brackets on a transparent square, white so Verse can tint them (faint, bright on hover, dim once
seen). Stretched over each object's projected rectangle, so the brackets scale with it.

Run: python art/tools/make_target_corners.py
"""
import os
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
S, L, T = 256, 56, 7          # size, bracket length, thickness
im = Image.new("RGBA", (S, S), (255, 255, 255, 0))
d = ImageDraw.Draw(im)
# Each corner: a horizontal and a vertical bar of length L and thickness T.
for left, top in ((True, True), (False, True), (True, False), (False, False)):
    x0 = 0 if left else S - L
    y0 = 0 if top else S - T
    d.rectangle((x0, y0, x0 + L - 1, y0 + T - 1), fill=(255, 255, 255, 255))      # horizontal
    x0 = 0 if left else S - T
    y0 = 0 if top else S - L
    d.rectangle((x0, y0, x0 + T - 1, y0 + L - 1), fill=(255, 255, 255, 255))      # vertical
im.save(os.path.join(ROOT, "art", "style-test", "final", "T_RoomTargetCorners.png"))
print("wrote T_RoomTargetCorners.png")
