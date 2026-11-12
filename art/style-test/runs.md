# Style test: run log

Run 2026-11-12 after Chip approved the spend (cap $1.00). 14 paid calls, no reruns, no backup
model. Prompts are in `plan.md`, unchanged.

**Cost: about $0.74 estimated** (3 x $0.059 + 8 x $0.063 + 3 x $0.018). The Nano Banana figures
are fal's per-image examples; the amount fal actually billed was not readable from the tools, so
check the fal dashboard for the exact number.

| ID | Date | Endpoint | Seed | Size | Reference images | Output file | Cost (USD, est.) | Kept? |
|---|---|---|---|---|---|---|---|---|
| R-A1 | 2026-11-12 | google/nano-banana-2.1 | 1101 | 2K 16:9 (2752x1536) | none | raw/R-A1_s1101.png | 0.059 | no |
| R-A2 | 2026-11-12 | google/nano-banana-2.1 | 1102 | 2K 16:9 (2752x1536) | none | raw/R-A2_s1102.png | 0.059 | **yes**, refs/style-ref.png |
| R-B1 | 2026-11-12 | google/nano-banana-2.1 | 1103 | 2K 16:9 (2752x1536) | none | raw/R-B1_s1103.png | 0.059 | comparison only |
| L1 | 2026-11-12 | google/nano-banana-2.1/edit | 1201 | 2K 16:9 (2752x1536) | style-ref | raw/L1_s1201.png | 0.063 | **yes** |
| L1 | 2026-11-12 | google/nano-banana-2.1/edit | 1202 | 2K 16:9 (2752x1536) | style-ref | raw/L1_s1202.png | 0.063 | no |
| L2 | 2026-11-12 | google/nano-banana-2.1/edit | 1211 | 2K 1:1 (2048x2048) | style-ref | raw/L2_s1211.png | 0.063 | **yes** |
| L2 | 2026-11-12 | google/nano-banana-2.1/edit | 1212 | 2K 1:1 (2048x2048) | style-ref | raw/L2_s1212.png | 0.063 | no |
| L2 | 2026-11-12 | google/nano-banana-2.1/edit | 1213 | 2K 1:1 (2048x2048) | style-ref | raw/L2_s1213.png | 0.063 | no |
| L3 | 2026-11-12 | google/nano-banana-2.1/edit | 1221 | 2K 16:9 (2752x1536) | style-ref | raw/L3_s1221.png | 0.063 | **yes** |
| L3 | 2026-11-12 | google/nano-banana-2.1/edit | 1222 | 2K 16:9 (2752x1536) | style-ref | raw/L3_s1222.png | 0.063 | no |
| L2b | 2026-11-12 | google/nano-banana-2.1/edit | 1301 | 2K 1:1 (2048x2048) | L2_s1211, style-ref | raw/L2b_s1301.png | 0.063 | **yes** |
| L2 alpha | 2026-11-12 | fal-ai/bria/background/remove | - | 2048x2048 | - | cutout/L2_bria.png | 0.018 | yes |
| L2b alpha | 2026-11-12 | fal-ai/bria/background/remove | - | 2048x2048 | - | cutout/L2b_bria.png | 0.018 | yes |
| L3 alpha | 2026-11-12 | fal-ai/bria/background/remove | - | 2752x1536 | - | cutout/L3_bria.png | 0.018 | yes |

The `_key` cutouts were made locally with `art/tools/cutout.py key` at no cost.

## Picks

- **Style reference: R-A2.** Three posters as asked (R-A1 drew extra posters and a second
  window), both titles spelled right, flat tones, closed outlines.
- **L1: seed 1201.** Both variations had correct lettering; lowest seed wins.
- **L2: seed 1211.** The only variation with the whole chair, footrest and cable inside the
  frame. 1212 and 1213 crop the bottom of the chair.
- **L3: seed 1221.** Clear "PRICE, E." label; 1222's label is faint.

## Finals and plane sizing

| Final | Size | Content box (x, y, w, h) |
|---|---|---|
| final/T_Room_BackWall_A.png | 2048x1024 RGB | full; source was 16:9, so use a 16:9 plane (800 x 450 cm) |
| final/T_Room_ReclinerClient_Breath0_Bria.png, `_Key.png` | 2048x2048 RGBA | 0, 295, 2048, 1753 |
| final/T_Room_ReclinerClient_Breath1_Bria.png, `_Key.png` | 2048x2048 RGBA | 0, 295, 2048, 1753 (shared with Breath0) |
| final/T_Room_DeskClutter_A_Bria.png, `_Key.png` | 2048x1024 RGBA | 0, 141, 2048, 883 |

Cutouts are bottom-aligned in the texture, so the bottom of the plane is the floor (recliner) or
the desk top (clutter). Planes for the cutouts match the texture's proportions (1:1 and 2:1).

## What I saw (quick look only; the editor checklist is the real test)

- **Style holds.** The wall, recliner and clutter look like one hand: same line, same halftone,
  same palette. Lettering is correct on all kept images.
- **The key beats Bria on these images.** Bria leaves magenta in enclosed gaps (under the
  footrest, between the circuit board and the cable coil, a speck by the folders). The local
  magenta key clears them. Try the `_Key` finals first.
- **Breathing frame: same woman, but a redraw.** L2b keeps her face, hair, clothes, chair and
  cable, but the whole drawing shifts slightly, not just the chest. Swapping the two frames may
  read as a jitter rather than a breath (checklist question 5). If so, production should breathe
  by moving or scaling a chest piece in the engine instead of generating frames.
- **Sizes confirmed.** 2K is 2048x2048 at 1:1 and 2752x1536 at 16:9.
- **Ink wash (R-B1)** is moody but, as expected, soft-edged and lower contrast; nothing was made
  from it.
