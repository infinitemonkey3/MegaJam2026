"""Draws the dream debugger's title bar: a thin application-window title bar with a cloud that
dissolves into binary digits, the WONDERWELL wordmark, the app name and window buttons.

UEFN can't import fonts, so the brand lettering comes in as this image. Rendered at 2x and
downsampled for clean edges.

    python art/tools/make_debugger_titlebar.py [out.png]
"""
import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
WORDMARK = ROOT / 'style-test/final/T_Title_Wordmark_A.png'
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'style-test/final/T_Debugger_TitleBar.png'
MONO = 'C:/Windows/Fonts/consolab.ttf'

W, H = 2048, 88          # final size: the debugger page's 1300-wide top row, about 56 tall (23.3 : 1)
S = 2                    # supersampling
w, h = W * S, H * S

INK = (16, 20, 34, 255)
BAR_TOP = (36, 50, 76, 255)
BAR_BOTTOM = (20, 28, 44, 255)
CREAM = (243, 230, 196, 255)
GOLD = (217, 165, 74, 255)
TEAL = (110, 214, 205, 255)

random.seed(7)
img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# Bar: rounded top corners, vertical gradient, thin gold rule along the bottom.
bar = Image.new('RGBA', (w, h), (0, 0, 0, 0))
for y in range(h):
    t = y / (h - 1)
    c = tuple(int(BAR_TOP[i] + (BAR_BOTTOM[i] - BAR_TOP[i]) * t) for i in range(3)) + (255,)
    ImageDraw.Draw(bar).line([(0, y), (w, y)], fill=c)
mask = Image.new('L', (w, h), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h + 40 * S], radius=14 * S, fill=255)
img.paste(bar, (0, 0), mask)
d.rectangle([0, h - 3 * S, w, h], fill=GOLD)

# Cloud: a cluster of circles, cream with a gold rim (comic style), at the bar's left.
cx, cy = 76 * S, h // 2 + 3 * S
blobs = [(-26, 8, 17), (-8, -6, 21), (14, -12, 22), (34, -2, 18), (48, 8, 14), (6, 10, 20), (28, 12, 16)]
cloud = Image.new('L', (w, h), 0)
cd = ImageDraw.Draw(cloud)
for bx, by, r in blobs:
    cd.ellipse([cx + (bx - r) * S, cy + (by - r) * S, cx + (bx + r) * S, cy + (by + r) * S], fill=255)
cd.rectangle([0, cy + 22 * S, w, h], fill=0)          # flat comic-cloud bottom
rim = cloud.filter(ImageFilter.MaxFilter(2 * 3 + 1))

# Where the cloud turns digital: solid to the left of SPLIT, pixels and digits to the right.
SPLIT = cx + 4 * S
left = Image.new('L', (w, h), 0)
ImageDraw.Draw(left).rectangle([0, 0, SPLIT, h], fill=255)
from PIL import ImageChops
solid = ImageChops.multiply(cloud, left)
img.paste(Image.new('RGBA', (w, h), GOLD), (0, 0), ImageChops.multiply(rim, left))
img.paste(Image.new('RGBA', (w, h), CREAM), (0, 0), solid)

# Pixel blocks: the cloud's right half breaks into squares, thinning out to the right.
px = 7 * S
PIX_END = cx + 66 * S
for gx in range(SPLIT, PIX_END, px):
    t = (gx - SPLIT) / (PIX_END - SPLIT)
    for gy in range(0, h, px):
        if cloud.getpixel((min(gx + px // 2, w - 1), min(gy + px // 2, h - 1))) > 128 and random.random() > t ** 1.3:
            shade = CREAM if random.random() > 0.3 else GOLD
            d.rectangle([gx + S, gy + S, gx + px - S, gy + px - S], fill=shade)

# Binary: digits along the cloud's band, from where the pixels thin out to just before the
# wordmark, fading from cream to gold to teal and thinning as they go.
digit_font = ImageFont.truetype(MONO, 13 * S)
band_top, band_bottom = cy - 30 * S, cy + 22 * S
step_x, step_y = 10 * S, 13 * S
x0, x1 = cx + 54 * S, 288 * S
for gx in range(x0, x1, step_x):
    t = (gx - x0) / (x1 - x0)
    half = (band_bottom - band_top) / 2 * (1 - 0.7 * t)
    mid = (band_top + band_bottom) / 2 + 3 * S * t
    for gy in range(band_top, band_bottom, step_y):
        if abs(gy + step_y / 2 - mid) > half:
            continue
        if random.random() < 0.85 - 0.6 * t:
            col = CREAM if t < 0.3 else (GOLD if t < 0.65 else TEAL)
            alpha = int(255 * (1 - 0.65 * t))
            d.text((gx, gy), random.choice('01'), font=digit_font, fill=col[:3] + (alpha,))

# Wordmark, cropped to its letters and scaled to the bar.
wm = Image.open(WORDMARK).convert('RGBA')
wm = wm.crop(wm.getbbox())
wm_h = int(h * 0.62)
wm = wm.resize((int(wm.width * wm_h / wm.height), wm_h), Image.Resampling.LANCZOS)
wm_x = 300 * S
img.alpha_composite(wm, (wm_x, (h - wm_h) // 2 - 1 * S))

# App name after the wordmark, in small mono caps.
name_font = ImageFont.truetype(MONO, 22 * S)
name = 'DREAM DEBUGGER  v4.1.7'
nx = wm_x + wm.width + 26 * S
ny = h // 2 - 12 * S
d.text((nx, ny), name, font=name_font, fill=GOLD)
tag_font = ImageFont.truetype(MONO, 15 * S)
tag = '[UNREGISTERED]'
tx = nx + d.textlength(name, font=name_font) + 18 * S
d.text((tx, ny + 5 * S), tag, font=tag_font, fill=(222, 96, 84, 255))

# Window buttons on the right: minimise, maximise, close.
bw, bh, gap = 34 * S, 26 * S, 8 * S
by = (h - bh) // 2
right = w - 18 * S
for i, kind in enumerate(('close', 'max', 'min')):
    x1b = right - i * (bw + gap)
    x0b = x1b - bw
    d.rounded_rectangle([x0b, by, x1b, by + bh], radius=5 * S, outline=CREAM, width=2 * S,
                        fill=(150, 50, 46, 255) if kind == 'close' else None)
    mx, my = (x0b + x1b) // 2, by + bh // 2
    if kind == 'min':
        d.line([(mx - 8 * S, my + 6 * S), (mx + 8 * S, my + 6 * S)], fill=CREAM, width=3 * S)
    elif kind == 'max':
        d.rectangle([mx - 7 * S, my - 6 * S, mx + 7 * S, my + 6 * S], outline=CREAM, width=2 * S)
    else:
        d.line([(mx - 6 * S, my - 6 * S), (mx + 6 * S, my + 6 * S)], fill=CREAM, width=3 * S)
        d.line([(mx - 6 * S, my + 6 * S), (mx + 6 * S, my - 6 * S)], fill=CREAM, width=3 * S)

img = img.resize((W, H), Image.Resampling.LANCZOS)
img.save(OUT)
print('wrote', OUT, img.size)
