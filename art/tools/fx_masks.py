"""Make the greyscale masks for 2D "lighting" (no generation, no cost).

Run from art/style-test:  python ../tools/fx_masks.py

Outputs (final/):
  T_FX_Spot_Recliner.png  1024x1024 L. A soft glow in the shape of the recliner and client,
                          aligned 1:1 with the recliner plane (same size and position). Use it
                          as the mask of an additive overlay tinted by the take's colour.
  T_FX_Vignette.png       1024x512 L. White centre falling to black edges, for a 16:9 plane
                          in front of the room; multiply with it to bring the house lights down.

Both are linear masks: import them with sRGB off.
"""
import numpy as np
from PIL import Image, ImageFilter

R = Image.Resampling.LANCZOS


def spot():
    a = Image.open("final/T_Room_ReclinerClient_Breath0_Key.png").split()[3].resize((1024, 1024), R)
    shape = np.asarray(a.filter(ImageFilter.MaxFilter(31)).filter(ImageFilter.GaussianBlur(60)),
                       dtype=np.float32) / 255.0
    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)
    # Brightest on her face and chest (about x=0.62, y=0.45 of the recliner texture).
    falloff = np.exp(-(((xx - 635) / 420) ** 2 + ((yy - 460) / 470) ** 2))
    out = np.clip(shape * (0.35 + 0.65 * falloff) * 1.15, 0, 1)
    Image.fromarray((out * 255).round().astype(np.uint8), "L").save("final/T_FX_Spot_Recliner.png")


def vignette():
    yy, xx = np.mgrid[0:512, 0:1024].astype(np.float32)
    d = np.sqrt(((xx - 512) / 512) ** 2 + ((yy - 256) / 256) ** 2)
    out = np.clip(1.15 - 0.85 * d ** 1.6, 0, 1)
    Image.fromarray((out * 255).round().astype(np.uint8), "L").save("final/T_FX_Vignette.png")


if __name__ == "__main__":
    spot()
    vignette()
