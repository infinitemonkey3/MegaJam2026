"""Cut the glass out of the monitor texture so the in-world screen can sit behind the bezel.

Usage: python cut_screen.py <in.png> <out.png> [--glass]

Flood-fills the screen glass from the centre (colour within TOLERANCE of the centre pixel),
makes it transparent with a slightly eased edge, and prints the hole's bounding box so the
screen widget can be sized to it. With --glass it does the opposite: keeps only the glass
(grown a little further, so it reaches under the bezel), for a layer behind the frame.
"""
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

TOLERANCE = 40      # per channel, in 0-255
GROW = 3            # px the hole grows under the black bezel line, so no glass shows at the edge


def main(src, dst, glass=False):
    img = Image.open(src).convert("RGBA")
    w, h = img.size
    rgb = img.convert("RGB")
    seed = (w // 2, int(h * 0.43))
    mark = (255, 0, 255)
    probe = rgb.copy()
    ImageDraw.floodfill(probe, seed, mark, thresh=TOLERANCE)
    hole = np.all(np.asarray(probe) == mark, axis=-1) & ~np.all(np.asarray(rgb) == mark, axis=-1)
    m = Image.fromarray((hole * 255).astype(np.uint8))
    grow = GROW * 4 if glass else GROW
    m = m.filter(ImageFilter.MaxFilter(grow * 2 + 1)).filter(ImageFilter.GaussianBlur(1))
    a = np.asarray(img).copy()
    keep = np.asarray(m).astype(np.float32) / 255
    if not glass:
        keep = 1 - keep
    a[..., 3] = (a[..., 3].astype(np.float32) * keep).astype(np.uint8)
    Image.fromarray(a, "RGBA").save(dst)
    ys, xs = np.where(hole)
    print("hole box x=%d y=%d w=%d h=%d of %dx%d" % (xs.min(), ys.min(), xs.max() - xs.min() + 1, ys.max() - ys.min() + 1, w, h))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], "--glass" in sys.argv[3:])
