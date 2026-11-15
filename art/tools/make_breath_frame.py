"""Nell's breathing (Chip, 2026-11-14): the second frame for the recliner's crossfade.

The two style-test frames (T_Room_ReclinerClient_Breath0_Key / Breath1_Key, 2026-11-12) differ
mostly in her chest and arms, but the regenerated frame also nudges ink lines everywhere, which
a crossfade turns into shimmer. So the second frame is frame 0 with frame 1 let in only around
the torso, through a soft mask. The game's recliner texture (T_Room_Recliner_Nell) is frame 0;
M_Room_Breath crossfades it with this.

Run: python art/tools/make_breath_frame.py
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FINAL = os.path.join(ROOT, "art", "style-test", "final")
a = Image.open(os.path.join(FINAL, "T_Room_ReclinerClient_Breath0_Key.png")).convert("RGBA")
b = Image.open(os.path.join(FINAL, "T_Room_ReclinerClient_Breath1_Key.png")).convert("RGBA")

# The torso: shoulders to folded hands (2048 px frame), as a soft ellipse.
mask = Image.new("L", a.size, 0)
ImageDraw.Draw(mask).ellipse((760, 660, 1560, 1300), fill=255)
mask = mask.filter(ImageFilter.GaussianBlur(70))

out = Image.composite(b, a, mask)
out.save(os.path.join(FINAL, "T_Room_Recliner_Nell_Breath.png"))

# How much changed outside the torso now (should be none).
d = np.abs(np.asarray(out).astype(int) - np.asarray(a).astype(int)).max(axis=2)
outside = np.asarray(mask) < 8
print("changed px inside", int((d[~outside] > 40).sum()), "outside", int((d[outside] > 40).sum()))
