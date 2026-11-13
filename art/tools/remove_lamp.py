"""Paint the desk lamp out of T_Room_Desk_A.png (Chip, 2026-11-13).

Usage: python remove_lamp.py <in.png> <out.png>

Coordinates are for the 4096x2048 desk texture made from raw/Desk4K_s2125.png:
1. The lamp above the desk goes transparent.
2. The base, its shadow, the cord and the foot of the arm are covered with the desk top's plain
   bone colour.
3. The far edge under the arm is copied from further left, and the right end edge where the
   cord crossed it is copied from higher up along its own slope.
4. The lamp's amber light pool is replaced with the desk top's plain bone colour.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cutout import bleed  # noqa: E402

FAR_EDGE_TOP = 1036                    # top of the far edge ink line
END_SLOPE = 0.77                       # right end edge: px right per px down
END_X0, END_Y0 = 3545, 1046            # where the end edge meets the far edge
BONE = np.array([219, 207, 190], np.float32)  # the desk top's plain colour


def end_edge_x(y):
    return END_X0 + END_SLOPE * (y - END_Y0)


def main(src, dst):
    arr = np.asarray(Image.open(src).convert("RGBA")).astype(np.float32)
    h, w = arr.shape[:2]
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float32)

    # 1. The lamp above the desk.
    arr[:FAR_EDGE_TOP, 2850:3700, 3] = 0

    # 2. Patch on the desk top, kept clear of the end edge.
    m = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(m)
    d.ellipse((3100, 1120, 3745, 1410), fill=255)
    d.polygon([(3355, FAR_EDGE_TOP + 16), (3530, FAR_EDGE_TOP + 16), (3480, 1200), (3335, 1200)], fill=255)
    d.rectangle((3540, 1195, 3760, 1295), fill=255)
    m = np.asarray(m.filter(ImageFilter.MaxFilter(11))).astype(np.float32) / 255.0
    m[xs > end_edge_x(ys) - 16] = 0
    m[ys < FAR_EDGE_TOP + 16] = 0
    m = np.asarray(Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(10))).astype(np.float32)[..., None] / 255.0

    grain = np.random.default_rng(7).normal(0.0, 2.5, (h, w, 1)).astype(np.float32)
    fill = BONE + grain
    arr[..., :3] = arr[..., :3] * (1 - m) + fill * m
    arr[..., 3] = np.maximum(arr[..., 3], m[..., 0] * 255)

    # 3a. Far edge line under the arm, from 220 px to the left.
    arr[FAR_EDGE_TOP - 4:FAR_EDGE_TOP + 50, 3330:3550] = arr[FAR_EDGE_TOP - 4:FAR_EDGE_TOP + 50, 3110:3330]
    # 3b. End edge where the cord crossed it: fit the edge's outer side on clean rows, then copy
    #     a clean row's edge onto each damaged row, lined up on the fit.
    def outer(y):
        opaque = np.where(arr[y, 3400:, 3] > 128)[0]
        return 3400 + opaque.max() if len(opaque) else None
    clean = [y for y in list(range(1090, 1180, 4)) + list(range(1320, 1420, 4)) if outer(y)]
    fit = np.polyfit(clean, [outer(y) for y in clean], 1)
    ref_y = 1170
    ref = arr[ref_y].copy()
    ref_x = np.polyval(fit, ref_y)
    for y in range(1180, 1315):
        shift = int(round(np.polyval(fit, y) - ref_x))
        x0 = int(np.polyval(fit, y)) - 45
        x1 = min(x0 + 140, w)
        arr[y, x0:x1] = ref[x0 - shift:x1 - shift]
    print("end edge fit: x = %.3f * y + %.1f" % tuple(fit))
    # Anything left of the cord past the end edge.
    beyond = (xs > np.polyval(fit, ys) + 2) & (ys > END_Y0) & (ys < 1400)
    arr[beyond, 3] = 0

    # 4. The lamp's light pool: every amber pixel becomes plain bone paper, by how amber it is,
    #    so the ink scratches and coffee rings stay. (Copied wood repeated the left end's
    #    rings and patches.) A little grain stops it looking flat.
    r, b = arr[..., 0], arr[..., 2]
    amber = np.clip((r - b - 31.0) / 30.0, 0.0, 1.0)[..., None]
    amber[: FAR_EDGE_TOP] = 0
    arr[..., :3] = arr[..., :3] * (1 - amber) + (BONE + grain) * amber

    bleed(Image.fromarray(arr.round().clip(0, 255).astype(np.uint8), "RGBA")).save(dst)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
