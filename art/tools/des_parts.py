"""Split Des out of his recliner drawing and cut his mouth frames and chest piece.

Run from art/style-test:  python ../tools/des_parts.py

Inputs:  cutout/ReclinerEmpty_key.png, cutout/DesSeat_key.png (magenta-keyed with cutout.py)
         raw/ReclinerEmpty_s7101.png, raw/DesSeat_s7202.png (the same two drawings, unkeyed)
         raw/DesMouthHalf_s7501.png, raw/DesMouthOpen_s7502.png (edits of refs/des-face-crop.png,
         which is raw box FACE_BOX at 2x)
Outputs: final/T_Room_Recliner_Empty.png   2048x2048, the empty seat
         final/T_Client_Des_Overlay.png    2048x2048, Des alone, aligned 1:1 with the empty seat
         final/T_Client_Des_Mouth_Atlas.png 1024x256, cells closed, half, open, half
         final/T_Client_Des_Chest.png      512x512, feathered edge

The overlay is where the Des drawing differs from the empty-seat drawing, so the two planes
share one size and position. Both seat textures use one shared trim box.
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

from client_parts import feather_mask
from cutout import MARGIN, bleed

R = Image.Resampling.LANCZOS
FACE_BOX = (1150, 280, 1662, 792)    # raw box enlarged 2x for the mouth edits
MOUTH_BOX = (1285, 555, 1485, 755)   # raw box of one atlas cell (200 px square)
CHEST_BOX = (980, 580, 1620, 1220)  # raw box of the chest piece (640 px square)
SEED = (1300, 900)                   # a raw point on his chest, inside the figure
DIFF_MIN = 60                       # summed RGB difference that counts as "Des"


def des_mask():
    empty = np.asarray(Image.open("raw/ReclinerEmpty_s7101.png").convert("RGB")).astype(int)
    des = np.asarray(Image.open("raw/DesSeat_s7202.png").convert("RGB")).astype(int)
    hit = Image.fromarray(((np.abs(empty - des).sum(-1) > DIFF_MIN) * 255).astype(np.uint8), "L")
    hit = hit.filter(ImageFilter.MaxFilter(15)).filter(ImageFilter.MinFilter(15))  # close gaps
    hit = hit.filter(ImageFilter.MinFilter(9)).filter(ImageFilter.MaxFilter(9))    # drop thin drift lines
    # Keep only the piece connected to his chest, which drops specks of chair drift.
    hit = hit.point(lambda v: 255 if v > 127 else 0)
    ImageDraw.floodfill(hit, SEED, 200)
    hit = hit.point(lambda v: 255 if v == 200 else 0)
    # Fill holes: flood the outside, anything not reached is inside the figure.
    flood = hit.copy()
    ImageDraw.floodfill(flood, (0, 0), 128)
    filled = np.where(np.asarray(flood) == 128, 0, 255).astype(np.uint8)
    soft = Image.fromarray(filled, "L").filter(ImageFilter.GaussianBlur(1.5))
    keyed = np.asarray(Image.open("cutout/DesSeat_key.png").split()[3]).astype(np.float32)
    return Image.fromarray((np.asarray(soft) / 255.0 * keyed).astype(np.uint8), "L")


def transform(boxes):
    x0 = max(min(b[0] for b in boxes) - MARGIN, 0)
    y0 = max(min(b[1] for b in boxes) - MARGIN, 0)
    x1 = min(max(b[2] for b in boxes) + MARGIN, 2048)
    y1 = min(max(b[3] for b in boxes) + MARGIN, 2048)
    scale = min(2048 / (x1 - x0), 2048 / (y1 - y0))
    cw, ch = round((x1 - x0) * scale), round((y1 - y0) * scale)
    ox, oy = (2048 - cw) // 2, 2048 - ch
    return (x0, y0, x1, y1), (cw, ch), (ox, oy), lambda x, y: (round((x - x0) * scale + ox),
                                                               round((y - y0) * scale + oy))


def place(img, crop, size, offset, name):
    canvas = Image.new("RGBA", (2048, 2048), (0, 0, 0, 0))
    canvas.paste(bleed(img).crop(crop).resize(size, R), offset)
    canvas.save(f"final/{name}")


def to_final(box, tf):
    ax, ay = tf(box[0], box[1])
    bx, by = tf(box[2], box[3])
    return f"x={ax} y={ay} w={bx - ax} h={by - ay}"


def main():
    empty = Image.open("cutout/ReclinerEmpty_key.png").convert("RGBA")
    des = Image.open("cutout/DesSeat_key.png").convert("RGBA")
    des.putalpha(des_mask())
    boxes = [im.split()[3].point(lambda v: 255 if v > 8 else 0).getbbox() for im in (empty, des)]
    crop, size, offset, tf = transform(boxes)
    place(empty, crop, size, offset, "T_Room_Recliner_Empty.png")
    place(des, crop, size, offset, "T_Client_Des_Overlay.png")
    print(f"seat and overlay: 2048x2048, content box x={offset[0]} y={offset[1]} w={size[0]} h={size[1]}")

    base = Image.open("raw/DesSeat_s7202.png").convert("RGB")
    cells = [base.crop(MOUTH_BOX)]
    for name in ("raw/DesMouthHalf_s7501.png", "raw/DesMouthOpen_s7502.png"):
        frame = base.copy()
        frame.paste(Image.open(name).convert("RGB").resize((512, 512), R), FACE_BOX[:2])
        cells.append(frame.crop(MOUTH_BOX))
    mask = feather_mask((256, 256), 34, 14)
    atlas = Image.new("RGBA", (1024, 256), (0, 0, 0, 0))
    for i, idx in enumerate((0, 1, 2, 1)):
        cell = cells[idx].resize((256, 256), R).convert("RGBA")
        cell.putalpha(mask)
        atlas.paste(cell, (256 * i, 0))
    atlas.save("final/T_Client_Des_Mouth_Atlas.png")
    print("mouth cell on seat texture:", to_final(MOUTH_BOX, tf))

    chest = base.crop(CHEST_BOX).resize((512, 512), R).convert("RGBA")
    chest.putalpha(feather_mask((512, 512), 70, 28))
    chest.save("final/T_Client_Des_Chest.png")
    print("chest piece on seat texture:", to_final(CHEST_BOX, tf))


if __name__ == "__main__":
    main()
