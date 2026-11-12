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

    # Chest: one feathered piece; the engine scales it a little to breathe.
    chest = base.crop(CHEST_BOX).resize((512, 512), R).convert("RGBA")
    chest.putalpha(feather_mask((512, 512), 70, 28))
    chest.save("final/T_Client_Chest.png")
    print("chest piece on recliner texture:", to_final(CHEST_BOX, tf))


if __name__ == "__main__":
    main()
