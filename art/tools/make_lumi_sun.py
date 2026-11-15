"""Lumi's avatar: a gentle sun with a talking mouth (Chip, 2026-11-15).

Run from art/style-test:  python ../tools/make_lumi_sun.py

Input:  raw/LumiSun_s2601a.png (google/nano-banana-2.1, on magenta; _s2601b the other take).
Output: final/T_Lumi_Sun_0.png (the smile, as drawn), _1.png (half open), _2.png (open),
        512x512 RGBA, magenta keyed out. The open mouths are painted here over the smile, so the
        frames line up exactly. take_flow flips between them while Lumi speaks
        (debug_screen.SetAssistantAvatar).
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

NAVY = (24, 26, 58)
INSIDE = (92, 30, 52)
TONGUE = (238, 132, 150)


def key_magenta(im):
    a = np.asarray(im.convert("RGB")).astype(int)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    # Magenta: red and blue high, green low. Soft edge over a small range.
    m = np.clip(((r + b) / 2 - g - 120) / 60, 0, 1)
    alpha = (255 * (1 - m)).astype(np.uint8)
    out = im.convert("RGBA")
    out.putalpha(Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(0.6)))
    # Pull the magenta fringe out of the edge pixels.
    px = np.asarray(out).copy()
    edge = (px[..., 3] < 250) & (px[..., 3] > 0)
    px[..., 0][edge] = np.minimum(px[..., 0][edge], px[..., 1][edge] + 40)
    px[..., 2][edge] = np.minimum(px[..., 2][edge], px[..., 1][edge] + 40)
    return Image.fromarray(px)


def main():
    src = Image.open("raw/LumiSun_s2601a.png").convert("RGB")
    a = np.asarray(src).astype(int)
    # The smile: dark navy pixels below the eyes, between the cheeks.
    dark = (a.sum(axis=2) < 200)
    ys, xs = np.nonzero(dark[532:600, 440:590])   # rows 532+: below the eyes (they end at 524)
    x0, x1 = xs.min() + 440, xs.max() + 440
    y0, y1 = ys.min() + 532, ys.max() + 532
    cx, cy, w = (x0 + x1) / 2, (y0 + y1) / 2, x1 - x0
    print("smile box", x0, y0, x1, y1)
    cream = tuple(int(v) for v in a[int(y0) - 14, int(cx)])   # face colour just above the smile

    frames = [src.copy()]
    for open_h in (0.3, 0.55):
        f = src.copy()
        d = ImageDraw.Draw(f)
        d.rectangle((x0 - 6, y0 - 8, x1 + 6, y1 + 8), fill=cream)     # paint the smile out
        # An open smile: the lower half of an ellipse centred on the top edge, so the chord's
        # flat side is the top of the mouth.
        top = y0 + 2
        half_w, depth = w * 0.58, w * open_h
        box = (cx - half_w, top - depth, cx + half_w, top + depth)
        d.chord(box, 0, 180, fill=INSIDE, outline=NAVY, width=7)
        d.ellipse((cx - half_w * 0.45, top + depth * 0.4, cx + half_w * 0.45, top + depth - 6), fill=TONGUE)
        d.chord(box, 0, 180, outline=NAVY, width=7)                    # outline back over the tongue's edge
        frames.append(f)

    for i, f in enumerate(frames):
        out = key_magenta(f)
        bbox = out.split()[3].point(lambda v: 255 if v > 8 else 0).getbbox()
        side = max(bbox[2] - bbox[0], bbox[3] - bbox[1]) + 24
        sq = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        sq.paste(out.crop(bbox), ((side - (bbox[2] - bbox[0])) // 2, (side - (bbox[3] - bbox[1])) // 2))
        sq.resize((512, 512), Image.Resampling.LANCZOS).save(f"final/T_Lumi_Sun_{i}.png")
        if i == 0:
            frame_box = bbox
        print("wrote", f"final/T_Lumi_Sun_{i}.png")


if __name__ == "__main__":
    main()
