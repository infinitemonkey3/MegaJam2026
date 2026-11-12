"""Cutout pipeline for 2D layer art (see art/style-test/plan.md, section 6).

Usage:
  python cutout.py key   <raw.png> <out.png>            magenta key -> RGBA
  python cutout.py fit   <W> <H> <out_dir> <in.png>=<out_name> [...]
                                                        bleed, trim, fit to W x H
  python cutout.py opaque <W> <H> <in.png> <out.png>    resize an opaque layer

`fit` uses one shared trim box for all inputs given in the same call, so frames of
the same subject stay aligned. It prints the content box for the run log.
"""
import sys

import numpy as np
from PIL import Image, ImageFilter

MARGIN = 16      # px kept around the trimmed subject
BLEED_PASSES = 4 # each pass spreads edge colour about 4 px into transparency


def key_magenta(src, dst):
    rgb = np.asarray(Image.open(src).convert("RGB")).astype(np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    excess = np.minimum(r, b) - g              # high only on magenta
    alpha = 1.0 - np.clip((excess - 60.0) / 100.0, 0.0, 1.0)
    spill = np.clip(excess, 0.0, None)         # pull red and blue down to green
    rgb[..., 0] = r - spill
    rgb[..., 2] = b - spill
    out = np.dstack([rgb, alpha * 255.0]).round().astype(np.uint8)
    Image.fromarray(out, "RGBA").save(dst)


def bleed(img):
    """Spread opaque edge colour into transparent pixels; alpha is unchanged."""
    arr = np.asarray(img).astype(np.float32)
    rgb, a = arr[..., :3], arr[..., 3:4] / 255.0
    solid = (a > 0.5).astype(np.float32)
    for _ in range(BLEED_PASSES):
        pre = Image.fromarray((rgb * solid).round().astype(np.uint8), "RGB")
        cov = Image.fromarray((solid[..., 0] * 255).astype(np.uint8), "L")
        pre_b = np.asarray(pre.filter(ImageFilter.GaussianBlur(2))).astype(np.float32)
        cov_b = np.asarray(cov.filter(ImageFilter.GaussianBlur(2))).astype(np.float32)[..., None] / 255.0
        grown = cov_b > 0.02
        fill = np.where(grown, pre_b / np.maximum(cov_b, 1e-3), 0.0)
        new = (solid < 0.5) & grown
        rgb = np.where(new, np.clip(fill, 0, 255), rgb)
        solid = np.maximum(solid, new.astype(np.float32))
    out = np.dstack([rgb, arr[..., 3:4]]).round().astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def fit(w, h, out_dir, pairs):
    imgs = [(Image.open(src).convert("RGBA"), name) for src, name in pairs]
    boxes = [im.split()[3].point(lambda v: 255 if v > 8 else 0).getbbox() for im, _ in imgs]
    iw, ih = imgs[0][0].size
    x0 = max(min(b[0] for b in boxes) - MARGIN, 0)
    y0 = max(min(b[1] for b in boxes) - MARGIN, 0)
    x1 = min(max(b[2] for b in boxes) + MARGIN, iw)
    y1 = min(max(b[3] for b in boxes) + MARGIN, ih)
    scale = min(w / (x1 - x0), h / (y1 - y0))
    cw, ch = round((x1 - x0) * scale), round((y1 - y0) * scale)
    ox, oy = (w - cw) // 2, h - ch            # centred, bottom-aligned
    for im, name in imgs:
        part = bleed(im).crop((x0, y0, x1, y1)).resize((cw, ch), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        canvas.paste(part, (ox, oy))
        canvas.save(f"{out_dir}/{name}")
        print(f"{name}: {w}x{h}, content box x={ox} y={oy} w={cw} h={ch}")


def main(argv):
    cmd = argv[1]
    if cmd == "key":
        key_magenta(argv[2], argv[3])
    elif cmd == "fit":
        fit(int(argv[2]), int(argv[3]), argv[4], [a.split("=", 1) for a in argv[5:]])
    elif cmd == "stretch":   # stretch <W> <H> <in.png> <out.png>: RGBA, no trim
        bleed(Image.open(argv[4]).convert("RGBA")).resize(
            (int(argv[2]), int(argv[3])), Image.Resampling.LANCZOS).save(argv[5])
    elif cmd == "opaque":
        Image.open(argv[4]).convert("RGB").resize((int(argv[2]), int(argv[3])), Image.Resampling.LANCZOS).save(argv[5])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv)
