"""Nell's talking mouth while she's awake and smiling (Chip, 2026-11-15).

Run from art/style-test:  python ../tools/make_mouth_awake.py

Inputs: raw/FaceHappy_s2511.png (her awake face, make_eyes_open.py) and three edits of it, raw/
        MouthAwakeHalf_s2521.png, MouthAwakeOpen_s2522.png, MouthAwakeEE_s2523.png, all at
        FACE_BOX 2x like the sleeping mouth frames.
Output: final/T_Client_Nell_Mouth_Awake_Atlas8.png, 2048x256, eight 256 px cells cut at
        MOUTH_BOX with the same feather as T_Client_Nell_Mouth_Atlas8, in the same order:
        closed (the smile), half, open, ee, f/v (ee), m (closed), half, open.
M_Room_Breath samples it as MouthAwake at the same atlas UV and blends to it by EyesOpen
(add_mouth_awake_to_breath.py).
"""
from PIL import Image

from client_parts import FACE_BOX, MOUTH_BOX, feather_mask

R = Image.Resampling.LANCZOS


def cell_from(base, name):
    frame = base.copy()
    frame.paste(Image.open(name).convert("RGB").resize((512, 512), R), FACE_BOX[:2])
    return frame.crop(MOUTH_BOX)


def main():
    base = Image.open("raw/L2_s1211.png").convert("RGB")
    cells = [cell_from(base, "raw/" + n) for n in (
        "FaceHappy_s2511.png", "MouthAwakeHalf_s2521.png", "MouthAwakeOpen_s2522.png", "MouthAwakeEE_s2523.png")]
    mask = feather_mask((256, 256), 34, 14)
    atlas = Image.new("RGBA", (2048, 256), (0, 0, 0, 0))
    for i, idx in enumerate((0, 1, 2, 3, 3, 0, 1, 2)):
        cell = cells[idx].resize((256, 256), R).convert("RGBA")
        cell.putalpha(mask)
        atlas.paste(cell, (256 * i, 0))
    atlas.save("final/T_Client_Nell_Mouth_Awake_Atlas8.png")
    print("wrote final/T_Client_Nell_Mouth_Awake_Atlas8.png")


if __name__ == "__main__":
    main()
