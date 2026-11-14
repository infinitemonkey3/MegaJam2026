"""Builds the title card (Content/TitleCard/T_TitleCard) from its two layers (Chip, 2026-11-14).

- Background (T_Title_Background_A): the recliner's cable is painted out (it went nowhere), and
  the lanterns that crowded the WONDERWELL title are taken out of the sky around it, with the
  big top-right one moved into the corner.
- The recliner is taken out (Chip, 2026-11-14): this script writes the cleaned background to
  STAGE, an AI edit of it removes the chair (fal google/nano-banana-2.1/edit, saved as
  NO_CHAIR), and only the chair's region of that edit is blended in. Without NO_CHAIR, a rough
  local fill (remove_chair) is used instead.
- A brick wall drawn faintly into the dark wall behind the recliner, fading up into the ink
  strokes (Chip, 2026-11-14).
- Wordmark (T_Title_Wordmark_A): composited where mockup-title.jpg had it, with a dark outer
  stroke, a drop shadow and a soft dark halo so it stands out from the pale sky.

Edits are OpenCV inpainting (Telea) inside hand-placed masks, in 1920 x 1080 coordinates.

    python art/tools/make_title_card.py [out.png]
"""
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
BG = ROOT / 'style-test/final/T_Title_Background_A.png'
WORDMARK = ROOT / 'style-test/final/T_Title_Wordmark_A.png'
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'style-test/final/T_TitleCard_B.png'
W, H = 1920, 1080
STAGE = ROOT / 'style-test/raw/TitleBg_clean_with_chair.png'     # input for the AI edit
NO_CHAIR = ROOT / 'style-test/raw/TitleBg_no_chair.png'          # its result, used when present
STAGE_STREET = ROOT / 'style-test/raw/TitleBg_street.png'       # input for the dreamer edit
DREAMER = ROOT / 'style-test/raw/TitleBg_dreamer.png'            # its result, used when present
DREAMER_BOX = (700, 640, 1220, 1075)

# The cable, from the plug end in the sky down to where it tucks behind the chair's base, in two
# runs, each clone-stamped from the texture beside it (offset dx, dy): the rising run from its
# right, the run along the floor from below.
CABLE_RUNS = [
    ([(1266, 566), (1250, 575), (1230, 595), (1215, 620), (1207, 645), (1204, 670), (1202, 700),
      (1204, 740), (1205, 770), (1204, 800), (1200, 830), (1192, 860), (1182, 885), (1172, 910),
      (1167, 930), (1169, 950), (1175, 968)], (40, 0)),
    ([(1175, 965), (1176, 980), (1160, 992), (1130, 999), (1100, 999), (1075, 996), (1062, 990)], (0, 26)),
    ([(1168, 926), (1180, 942), (1185, 958), (1180, 972)], (44, 0)),     # the loop's bulge
]
CABLE_WIDTH = 28

# Lanterns in the title's band (x 318-1600, y 185-375), as boxes x0, y0, x1, y1.
LANTERNS_OUT = [(452, 188, 493, 255), (1375, 192, 1418, 255), (1219, 245, 1246, 285),
                (1294, 252, 1358, 338)]
BIG_LANTERN = (1480, 26, 1578, 194)           # moved up into the corner, smaller
BIG_TO = (1752, 18)                           # its new top-left
BIG_SCALE = 0.72
GLOW = 14                                     # px of glow around each lantern to clear too

# The brick wall: the dark wall area above the floor line (y 926), not the chair.
FLOOR_Y = 924
CHAIR_BOX = (790, 700, 1140, 1048)
CHAIR_SKY_Y = 790
CHAIR_FILL = (770, 690, 1170, 1060)   # the region taken from the AI edit (NO_CHAIR)        # above this, the chair's top was against the sky and ink, not the wall
BRICK_W, BRICK_H = 84, 30
MORTAR = 0.55            # mortar lines multiply the wall by this
FADE_TOP, FADE_RANGE = 560, 170   # bricks fade in below the ink strokes


def remove_chair(rgb):
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV)
    v = hsv[..., 2]
    x0, y0, x1, y1 = CHAIR_BOX
    box = np.zeros(v.shape, bool)
    box[y0:y1, x0:x1] = True
    ink = v < 40
    count, labels = cv2.connectedComponents((~ink).astype(np.uint8), connectivity=4)
    reaches_out = np.zeros(count, bool)
    reaches_out[np.unique(labels[~box & ~ink])] = True
    inner = ~ink & ~reaches_out[labels] & box          # chair pieces, sealed by the outline
    chair = cv2.dilate(inner.astype(np.uint8), np.ones((9, 9), np.uint8)) > 0
    chair = cv2.morphologyEx(chair.astype(np.uint8), cv2.MORPH_CLOSE, np.ones((15, 15), np.uint8)) > 0
    chair &= box
    out = rgb.astype(np.float32)
    for y in range(y0, y1):
        row = chair[y]
        if not row.any():
            continue
        xs = np.nonzero(row)[0]
        a, b = max(xs.min() - 1, 0), min(xs.max() + 1, rgb.shape[1] - 1)
        t = np.linspace(0, 1, b - a + 1)[:, None]
        out[y, a:b + 1] = out[y, a] * (1 - t) + out[y, b] * t
    out = out.astype(np.uint8)
    # Where the chair's top met the sky and ink strokes, row filling streaks: smooth that part.
    top = chair.copy()
    top[CHAIR_SKY_Y:] = False
    return cv2.inpaint(out, cv2.dilate(top.astype(np.uint8) * 255, np.ones((7, 7), np.uint8)), 12, cv2.INPAINT_TELEA)


def brick_wall(rgb):
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV)
    v, sat = hsv[..., 2].astype(np.int32), hsv[..., 1].astype(np.int32)
    wall = ((v < 80) & (sat < 80) & (v > 18)).astype(np.uint8)
    wall[FLOOR_Y:] = 0
    # The chair's black ink outline cuts its insides off from the wall: keep only the parts that
    # reach outside the chair's box (the wall), not the dark folds inside it.
    count, labels = cv2.connectedComponents(wall, connectivity=4)
    x0, y0, x1, y1 = CHAIR_BOX
    outside = np.ones_like(wall, bool)
    outside[y0:y1, x0:x1] = False
    keep = np.zeros(count, bool)
    keep[np.unique(labels[outside & (wall > 0)])] = True
    keep[0] = False
    wall = keep[labels].astype(np.uint8)
    wall = cv2.morphologyEx(wall, cv2.MORPH_OPEN, np.ones((3, 3), np.uint8))

    rng = np.random.default_rng(7)
    shade = np.ones(rgb.shape[:2], np.float32)          # multiplier on the wall
    lines = np.zeros(rgb.shape[:2], np.uint8)
    rows = range(FADE_TOP - BRICK_H, FLOOR_Y, BRICK_H)
    for r, y in enumerate(rows):
        xs = np.arange(-BRICK_W, W + BRICK_W, BRICK_W) + (BRICK_W // 2 if r % 2 else 0)
        for bx in xs:
            jx = int(rng.integers(-4, 5))
            # each brick a touch lighter or darker
            shade[max(y, 0):y + BRICK_H, max(bx + jx, 0):max(bx + jx + BRICK_W, 0)] *= 1.0 + rng.uniform(-0.07, 0.10)
            cv2.line(lines, (bx + jx, y), (bx + jx + int(rng.integers(-2, 3)), y + BRICK_H), 255, 2)
        # a slightly wobbly bed joint
        pts = np.array([(x, y + int(1.5 * np.sin(x / 57.0 + r))) for x in range(0, W + 40, 40)], np.int32)
        cv2.polylines(lines, [pts], False, 255, 2)
    lines = cv2.GaussianBlur(lines.astype(np.float32) / 255.0, (0, 0), 0.7)
    shade = shade * (1 - lines * (1 - MORTAR))

    fade = np.clip((np.arange(rgb.shape[0]) - FADE_TOP) / FADE_RANGE, 0, 1)[:, None]
    weight = cv2.GaussianBlur(wall.astype(np.float32), (0, 0), 2) * fade
    out = rgb.astype(np.float32) * (1 + (shade[..., None] - 1) * weight[..., None])
    return np.clip(out, 0, 255).astype(np.uint8)


# Where the wordmark goes (matches mockup-title.jpg) and its scale.
WM_X, WM_Y, WM_SCALE = 314, 64, 0.627


def inpaint(rgb, mask, radius=9):
    return cv2.inpaint(rgb, mask, radius, cv2.INPAINT_TELEA)


bg = np.array(Image.open(BG).convert('RGB').resize((W, H), Image.Resampling.LANCZOS))

# The big lantern, cut out before it's cleared (with its own glow, on a soft-edged mask).
x0, y0, x1, y1 = BIG_LANTERN
big = Image.fromarray(bg[y0:y1, x0:x1].copy())

# Cable: clone-stamp each run from beside it, feathered (inpainting smeared the halftone dots).
for run, (dx, dy) in CABLE_RUNS:
    m = np.zeros((H, W), np.uint8)
    cv2.polylines(m, [np.array(run, np.int32)], False, 255, CABLE_WIDTH)
    soft = cv2.GaussianBlur(m.astype(np.float32) / 255.0, (0, 0), 3)[..., None]
    src = np.roll(bg, (-dy, -dx), axis=(0, 1))
    bg = (bg * (1 - soft) + src * soft).astype(np.uint8)

mask = np.zeros((H, W), np.uint8)
for (a, b, c, d) in LANTERNS_OUT + [BIG_LANTERN]:
    cv2.ellipse(mask, ((a + c) // 2, (b + d) // 2), ((c - a) // 2 + GLOW, (d - b) // 2 + GLOW), 0, 0, 360, 255, -1)
bg = inpaint(bg, mask)

# The chair: an AI edit of the cleaned background removes it (NO_CHAIR, from the STAGE file this
# script writes); without it, the local fill (remove_chair) is a rough fallback.
Image.fromarray(bg).save(STAGE)
if NO_CHAIR.exists():
    # Only the chair's region comes from the edit (elsewhere it drifted: softer detail, and it
    # dropped the moved lantern), feathered into the cleaned background.
    ai = np.array(Image.open(NO_CHAIR).convert('RGB').resize((W, H), Image.Resampling.LANCZOS))
    region = np.zeros((H, W), np.float32)
    x0, y0, x1, y1 = CHAIR_FILL
    region[y0:y1, x0:x1] = 1.0
    region = cv2.GaussianBlur(region, (0, 0), 18)[..., None]
    bg = (bg * (1 - region) + ai * region).astype(np.uint8)
else:
    bg = remove_chair(bg)
bg = brick_wall(bg)
# The dreamer: a figure sat on the street where the chair was, head in hands, the dream rising
# from their head. Another AI edit, of the background as it is here (STAGE_STREET), blended in
# only around the figure (DREAMER_BOX), when DREAMER exists.
Image.fromarray(bg).save(STAGE_STREET)
if DREAMER.exists():
    fig = np.array(Image.open(DREAMER).convert('RGB').resize((W, H), Image.Resampling.LANCZOS))
    region = np.zeros((H, W), np.float32)
    x0, y0, x1, y1 = DREAMER_BOX
    region[y0:y1, x0:x1] = 1.0
    region = cv2.GaussianBlur(region, (0, 0), 16)[..., None]
    bg = (bg * (1 - region) + fig * region).astype(np.uint8)
out = Image.fromarray(bg).convert('RGBA')

# The big lantern in its new place: feathered so its glow blends.
big = big.resize((int(big.width * BIG_SCALE), int(big.height * BIG_SCALE)), Image.Resampling.LANCZOS)
feather = Image.new('L', big.size, 0)
fm = np.zeros((big.height, big.width), np.uint8)
cv2.ellipse(fm, (big.width // 2, big.height // 2), (big.width // 2 - 2, big.height // 2 - 2), 0, 0, 360, 255, -1)
feather = Image.fromarray(fm).filter(ImageFilter.GaussianBlur(4))
out.paste(big, BIG_TO, feather)

# Wordmark, with a dark stroke, drop shadow and halo under it.
wm = Image.open(WORDMARK).convert('RGBA')
wm = wm.resize((int(wm.width * WM_SCALE), int(wm.height * WM_SCALE)), Image.Resampling.LANCZOS)
alpha = np.array(wm)[..., 3]
alpha = np.where(alpha > 40, alpha, 0).astype(np.uint8)   # the PNG has faint alpha across its whole box
wm.putalpha(Image.fromarray(alpha))
# Padded, so the halo and shadow aren't clipped at the image edge (the letters touch it).
PAD = 60
padded = Image.new('RGBA', (wm.width + 2 * PAD, wm.height + 2 * PAD), (0, 0, 0, 0))
padded.paste(wm, (PAD, PAD))
wm = padded
alpha = np.array(wm)[..., 3]
NAVY = (22, 26, 48)

def layer(a, color, opacity):
    img = Image.new('RGBA', wm.size, color + (0,))
    img.putalpha(Image.fromarray((a * opacity).clip(0, 255).astype(np.uint8)))
    return img

halo = cv2.GaussianBlur(cv2.dilate(alpha, np.ones((9, 9), np.uint8)).astype(np.float32), (0, 0), 22)
shadow = cv2.GaussianBlur(alpha.astype(np.float32), (0, 0), 6)
stroke = cv2.dilate(alpha, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))).astype(np.float32)

canvas = Image.new('RGBA', (W, H), (0, 0, 0, 0))
canvas.alpha_composite(layer(halo, NAVY, 0.45), (WM_X - PAD, WM_Y - PAD))
canvas.alpha_composite(layer(shadow, NAVY, 0.75), (WM_X - PAD, WM_Y - PAD + 9))
canvas.alpha_composite(layer(stroke, NAVY, 1.0), (WM_X - PAD, WM_Y - PAD))
canvas.alpha_composite(wm, (WM_X - PAD, WM_Y - PAD))
out.alpha_composite(canvas)

out.convert('RGB').save(OUT)
print('wrote', OUT)
