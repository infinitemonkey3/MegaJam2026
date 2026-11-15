"""Nell awake: eyes open and a content smile, as an overlay for the recliner texture (Chip, 2026-11-15).

Run from art/style-test:  python ../tools/make_eyes_open.py

Input:  raw/FaceHappy_s2511.png, a nano-banana-2.1/edit of refs/client-face-crop.png ("open her
        eyes, relax her brow, a gentle closed-lip smile, change nothing else"; the first take,
        raw/EyesOpen_s2501.png, kept her sleeping frown: Chip wanted her relaxed and happy). It is
        raw/L2_s1211.png's FACE_BOX at 2x.
Output: final/T_Client_Nell_EyesOpen.png, 2048x2048 RGBA in the same space as
        T_Room_Recliner_Nell (frame 0, T_Room_ReclinerClient_Breath0_Key): transparent except
        her face, feathered. M_Room_Breath lerps to it by the scalar EyesOpen
        (add_eyes_to_breath.py), which game_director sets for her waking lines.

The edit is pasted back at half size like the mouth frames (client_parts.py). The mask is where
the edit differs from the drawing, kept to the face (brow to chin) so drift elsewhere doesn't
show.
"""
import numpy as np
from PIL import Image, ImageFilter

from client_parts import FACE_BOX, recliner_transform

R = Image.Resampling.LANCZOS
EYE_BAND = (1200, 380, 1560, 720)   # raw box the mask is kept to: her face, brow to chin


def main():
    base = Image.open("raw/L2_s1211.png").convert("RGB")
    edit = base.copy()
    edit.paste(Image.open("raw/FaceHappy_s2511.png").convert("RGB").resize((512, 512), R), FACE_BOX[:2])

    diff = np.abs(np.asarray(edit).astype(int) - np.asarray(base).astype(int)).sum(axis=2)
    mask = np.zeros(diff.shape, dtype=np.uint8)
    x0, y0, x1, y1 = EYE_BAND
    band = diff[y0:y1, x0:x1]
    mask[y0:y1, x0:x1] = np.where(band > 40, 255, 0)
    # Close the holes (the edit drifts slightly in skin tone, so a patchy mask would show).
    m = Image.fromarray(mask).filter(ImageFilter.MaxFilter(41)).filter(ImageFilter.MinFilter(25))
    m = m.filter(ImageFilter.GaussianBlur(8))
    # Fade out at the band's edges so nothing ends in a hard line.
    edge = Image.new("L", base.size, 0)
    edge.paste(255, (x0 + 8, y0 + 8, x1 - 8, y1 - 8))
    edge = edge.filter(ImageFilter.GaussianBlur(8))
    m = Image.fromarray((np.asarray(m).astype(int) * np.asarray(edge) // 255).astype(np.uint8))

    overlay = edit.convert("RGBA")
    overlay.putalpha(m)

    # Raw -> final, the same trim box and scale as the recliner texture.
    tf = recliner_transform()
    ax, ay = tf(0, 0)
    bx, by = tf(base.width, base.height)
    scaled = overlay.resize((bx - ax, by - ay), R)
    out = Image.new("RGBA", (2048, 2048), (0, 0, 0, 0))
    out.paste(scaled, (ax, ay))   # no mask: a straight copy, clipped to the canvas
    out.save("final/T_Client_Nell_EyesOpen.png")
    print("wrote final/T_Client_Nell_EyesOpen.png; eye band in final px:", tf(x0, y0), tf(x1, y1))


if __name__ == "__main__":
    main()
