"""Cut the client's mouth frames and chest piece out of the recliner drawing.

Run from art/style-test:  python ../tools/client_parts.py

Inputs:  raw/L2_s1211.png (base), raw/MouthHalf_s2301.png, raw/MouthOpen_s2302.png
         (edits of refs/client-face-crop.png, which is raw box FACE_BOX at 2x)
Outputs: final/T_Client_Mouth_Atlas.png   1024x256, four 256 px cells:
                                          closed, half, open, half
         final/T_Client_Chest.png         512x512, feathered edge

Both are overlay planes that sit just in front of the recliner plane. The script
prints where each one goes, in pixels of the 2048x2048 recliner texture.
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

from cutout import MARGIN

R = Image.Resampling.LANCZOS
FACE_BOX = (1107, 260, 1619, 772)    # raw box that was enlarged 2x for the mouth edits
MOUTH_BOX = (1270, 540, 1470, 740)   # raw box of one atlas cell (200 px square)
CHEST_BOX = (870, 530, 1510, 1170)   # raw box of the chest piece (640 px square)


def feather_mask(size, inset, blur):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).ellipse((inset, inset, size[0] - inset, size[1] - inset), fill=255)
    return mask.filter(ImageFilter.GaussianBlur(blur))


def tone_down_lipstick(cell):
    """The "oo" edit came back with glossy pink lips; pull strongly red-pink pixels most of the
    way to the grey of the same brightness, warmed to her lips' usual muted tone."""
    a = np.asarray(cell).astype(float)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    pink = np.clip((r - (g + b) / 2 - 30) / 50, 0, 1)[..., None]
    lum = (0.3 * r + 0.59 * g + 0.11 * b)[..., None]
    muted = np.concatenate([lum * 1.08, lum * 0.92, lum * 0.88], axis=2)
    out = a * (1 - 0.8 * pink) + muted * 0.8 * pink
    return Image.fromarray(np.clip(out, 0, 255).astype("uint8"))


def recliner_transform():
    """Raw -> final mapping used for T_Room_ReclinerClient_*_Key (shared trim box)."""
    boxes = []
    for name in ("cutout/L2_key.png", "cutout/L2b_key.png"):
        a = Image.open(name).split()[3].point(lambda v: 255 if v > 8 else 0)
        boxes.append(a.getbbox())
    x0 = max(min(b[0] for b in boxes) - MARGIN, 0)
    y0 = max(min(b[1] for b in boxes) - MARGIN, 0)
    x1 = min(max(b[2] for b in boxes) + MARGIN, 2048)
    y1 = min(max(b[3] for b in boxes) + MARGIN, 2048)
    scale = min(2048 / (x1 - x0), 2048 / (y1 - y0))
    cw, ch = round((x1 - x0) * scale), round((y1 - y0) * scale)
    ox, oy = (2048 - cw) // 2, 2048 - ch
    return lambda x, y: (round((x - x0) * scale + ox), round((y - y0) * scale + oy))


def to_final(box, tf):
    ax, ay = tf(box[0], box[1])
    bx, by = tf(box[2], box[3])
    return f"x={ax} y={ay} w={bx - ax} h={by - ay}"


def main():
    base = Image.open("raw/L2_s1211.png").convert("RGB")
    tf = recliner_transform()

    # Mouth: paste each edited face back at half size, then cut the same cell from each.
    cells = [base.crop(MOUTH_BOX)]
    for name in ("raw/MouthHalf_s2301.png", "raw/MouthOpen_s2302.png"):
        frame = base.copy()
        frame.paste(Image.open(name).convert("RGB").resize((512, 512), R), FACE_BOX[:2])
        cells.append(frame.crop(MOUTH_BOX))
    mask = feather_mask((256, 256), 34, 14)
    atlas = Image.new("RGBA", (1024, 256), (0, 0, 0, 0))
    for i, idx in enumerate((0, 1, 2, 1)):
        cell = cells[idx].resize((256, 256), R).convert("RGBA")
        cell.putalpha(mask)
        atlas.paste(cell, (256 * i, 0))
    atlas.save("final/T_Client_Mouth_Atlas.png")
    print("mouth cell on recliner texture:", to_final(MOUTH_BOX, tf))

    # Eight shapes (Chip, 2026-11-14: "more shapes and timings"): the three above plus ee, oo,
    # f/v and m (raw/Mouth*_s240x.png, same face crop and prompt style), and half again so
    # half-open stays the most common pick. The oo came out badly and is left out (Chip,
    # 2026-11-14), so half and open fill the last two cells. In order: closed, half, open, ee,
    # f/v, m, half, open.
    for name in ("raw/MouthEE_s2401.png", "raw/MouthOO_s2402.png", "raw/MouthFV_s2403.png", "raw/MouthMM_s2404.png"):
        frame = base.copy()
        frame.paste(Image.open(name).convert("RGB").resize((512, 512), R), FACE_BOX[:2])
        cell = frame.crop(MOUTH_BOX)
        if "OO" in name:
            cell = tone_down_lipstick(cell)
        cells.append(cell)
    atlas8 = Image.new("RGBA", (2048, 256), (0, 0, 0, 0))
    for i, idx in enumerate((0, 1, 2, 3, 5, 6, 1, 2)):
        cell = cells[idx].resize((256, 256), R).convert("RGBA")
        cell.putalpha(mask)
        atlas8.paste(cell, (256 * i, 0))
    atlas8.save("final/T_Client_Nell_Mouth_Atlas8.png")

    # Chest: one feathered piece; the engine scales it a little to breathe.
    chest = base.crop(CHEST_BOX).resize((512, 512), R).convert("RGBA")
    chest.putalpha(feather_mask((512, 512), 70, 28))
    chest.save("final/T_Client_Chest.png")
    print("chest piece on recliner texture:", to_final(CHEST_BOX, tf))


if __name__ == "__main__":
    main()
