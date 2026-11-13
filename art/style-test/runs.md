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

---

# Round 2: monitor, mouth, chest, posters, depth layers

Run 2026-11-12 after Chip's feedback on round 1 and his approval ("Yes go for it", cap $2.00).
14 paid calls, all on `google/nano-banana-2.1/edit`, one of them a redraw of the monitor.
**About $0.77 estimated** (8 x $0.063 at 2K + 6 x $0.044 at 1K). Both rounds together: about
$1.51. As before, the exact billed amount is only on the fal dashboard.

Every call used system prompt A from `plan.md` and `refs/style-ref.png` as the reference,
except the two mouth edits, which used `refs/client-face-crop.png` (the client's face from
`raw/L2_s1211.png`, enlarged 2x) and a one-line style note. Alpha is the local magenta key only.

| ID | Seed | Size | Output file | Cost (est.) | Kept? |
|---|---|---|---|---|---|
| Monitor | 2101 | 2K 1:1 | raw/Monitor_s2101.png | 0.063 | no, drawn at an angle |
| Monitor (redraw, "flat head-on front elevation") | 2111 | 2K 1:1 | raw/Monitor_s2111.png | 0.063 | **yes** |
| Back wall without posters | 2102 | 2K 16:9 | raw/WallClean_s2102.png | 0.063 | **yes** |
| Junk pile, left | 2103 | 2K 1:1 | raw/JunkLeft_s2103.png | 0.063 | **yes** |
| Film shelf, right | 2104 | 2K 1:1 | raw/ShelfRight_s2104.png | 0.063 | **yes** |
| Desk top with lamp | 2105 | 2K 16:9 | raw/Desk_s2105.png | 0.063 | **yes** |
| Doorway frame | 2106 | 2K 16:9 | raw/Doorway_s2106.png | 0.063 | **yes** |
| Floor, top-down | 2107 | 2K 16:9 | raw/Floor_s2107.png | 0.063 | **yes** |
| Poster, gangster: THE QUIET PARTNER | 2201 | 1K 2:3 | raw/PosterGangster_s2201.png | 0.044 | **yes** |
| Poster, wartime romance: THE LAST PLANE OUT | 2202 | 1K 2:3 | raw/PosterRomance_s2202.png | 0.044 | **yes** |
| Poster, dystopian sci-fi: TOMORROW IS RATIONED | 2203 | 1K 2:3 | raw/PosterSciFi_s2203.png | 0.044 | **yes** |
| Poster, pastoral musical: SING, MEADOW, SING | 2204 | 1K 2:3 | raw/PosterMusical_s2204.png | 0.044 | **yes** |
| Mouth, lips parted | 2301 | 1K 1:1 | raw/MouthHalf_s2301.png | 0.044 | **yes** |
| Mouth, open | 2302 | 1K 1:1 | raw/MouthOpen_s2302.png | 0.044 | **yes** |

The prompts for these are not in `plan.md`; fal keeps them with each request, and the poster
scenes are described in the table. No prompt names a real film, actor or studio.

## Depth stack (back to front)

Distances are from the seated eye point, as in `plan.md` section 5. Sizes are starting values.

| # | Layer | Final file | Texture | Plane (W x H cm) | Distance (cm) |
|---|---|---|---|---|---|
| 0 | Floor (horizontal) | T_Room_Floor_A.png | 2048x1024 RGB | 800 x 450, lying flat | under everything |
| 1 | Back wall, no posters | T_Room_BackWallClean_A.png | 2048x1024 RGB | 800 x 450 | 420 |
| 2 | Posters x4 | T_Poster_Gangster / Romance / SciFi / Musical.png | 512x1024 RGB | 60 x 90 each | 417, just off the wall |
| 3 | Junk pile, left | T_Room_JunkLeft_A.png | 2048x2048 RGBA | 250 x 250 | 340 |
| 4 | Film shelf, right | T_Room_ShelfRight_A.png | 2048x2048 RGBA | 250 x 250 | 330 |
| 5 | Recliner and client | T_Room_ReclinerClient_Breath0_Key.png (round 1) | 2048x2048 RGBA | 230 x 230 | 260 |
| 5a | Chest overlay | T_Client_Chest.png | 512x512 RGBA | 74 x 74 | 259.5 |
| 5b | Mouth overlay | T_Client_Mouth_Atlas.png | 1024x256 RGBA, 4 cells | 23 x 23 | 259 |
| 6 | Desk top with lamp | T_Room_Desk_A.png | 2048x1024 RGBA | 260 x 130 | 100 |
| 7 | Monitor | T_Room_Monitor_A.png | 2048x2048 RGBA | 60 x 60, or larger | 85, free to move |
| 8 | Desk clutter | T_Room_DeskClutter_A_Key.png (round 1) | 2048x1024 RGBA | 110 x 55 | 70 |
| 9 | Doorway frame | T_Room_Doorway_A.png | 2048x1024 RGBA | 385 x 215 (16:9; the opening is about 100 x 200) | behind the seat; the entry camera starts outside it and passes through |

Opaque 16:9 and 2:3 sources were resized straight to power-of-two, so the plane's proportions
restore the picture. `mockup-round2.jpg` is a flat paste-up of the layers to show them together;
it is not a game asset and its layout is only a guess.

## Placing the moving parts

- **Monitor screen.** On `T_Room_Monitor_A.png` the dark screen area is x=260, y=294, w=1527,
  h=1172 (of 2048). On a 60 cm plane that is 44.7 x 34.3 cm, starting 7.6 cm from the left edge
  and 8.6 cm from the top. Put the UMG screen there, just in front of the plane.
- **Chest.** `T_Client_Chest.png` covers x=829, y=602, w=662, h=663 of the recliner texture: a
  74 cm square whose centre is 130 cm from the plane's left edge and 105 cm from its top. It has
  a soft edge, so scaling it about 2% up and down on a 4 second cycle should read as breathing
  without a visible seam.
- **Mouth.** Each 256 px cell of `T_Client_Mouth_Atlas.png` covers x=1243, y=613, w=207, h=207
  of the recliner texture: a 23 cm square whose centre is 151 cm from the left and 80 cm from the
  top. Cells left to right: closed, half, open, half. Play them as a flipbook while she talks and
  hold cell 1 (or hide the plane) when she is silent.

Both overlays come from `art/tools/client_parts.py`.

## What I saw

- The new layers match round 1's style, and all four poster titles are spelled right.
- The mouth edits changed the mouth and left the rest of the face in place, so the frames line
  up.
- The sci-fi and musical posters have small made-up credit lines at the bottom that are partly
  readable (invented names, and "Lorem ipsum" on the musical). They are tiny at wall distance;
  crop or repaint the bottom strip if it shows in a close-up.
- The shelf was asked for with solid black gaps but came out see-through, which the key turned
  into real holes. That helps the parallax.
- The first monitor was drawn at a slight angle; the redraw is square-on.
- Not tested: anything in UEFN. The chest and mouth overlays have not been seen moving.

---

# Round 3: cold-open poster, flyer and street wall

Run 2026-11-12 from Chip's brief for the cold open, approved at about $0.40 (cap $0.75).
4 paid calls on `google/nano-banana-2.1/edit`, no reruns. **About $0.40 estimated**
(2 x $0.138 at 4K + 2 x $0.063 at 2K). All three rounds: about $1.91.

The company is **Wonderwell** (Chip's pick). Its poster uses colours found nowhere else in the
game: cream white `#F4EEDC`, sky blue `#8EC5E8`, soft gold `#E9C46A`. The poster's system prompt
swapped the house palette for these on clean areas; the flyer and wall used system prompt A.

| ID | Seed | Size | Output file | Cost (est.) | Kept? |
|---|---|---|---|---|---|
| Wonderwell poster | 3101 | 4K 2:3 (3392x5056) | raw/Wonderwell_s3101.png | 0.138 | yes, as option B |
| Wonderwell poster | 3102 | 4K 2:3 (3392x5056) | raw/Wonderwell_s3102.png | 0.138 | **yes, option A (my pick)** |
| Flyer for the back room | 3201 | 2K 3:4 (1792x2400) | raw/Flyer_s3201.png | 0.063 | **yes** |
| Street wall | 3301 | 2K 16:9 | raw/StreetWall_s3301.png | 0.063 | **yes** |

Lettering, all spelled right on both posters and the flyer:

- Poster: "MAKE DREAMS HAPPEN", "Accepting applications from exceptional candidates",
  "WONDERWELL".
- Flyer: "LOVED ONE LOOPING?", "DON'T WAIT FOR THE MANUFACTURER.", "CALL 555-0147", "DISCREET.
  CASH ONLY.", and 555-0147 on each tear-off tab. 555-01xx numbers are reserved for fiction.

## Finals

| Final file | Texture | Plane |
|---|---|---|
| T_ColdOpen_Wonderwell_A_Top.png, `_A_Bottom.png` | 2048x2048 RGB each | Two planes stacked with no gap, each 4:3 (for a 120 x 180 cm poster, two planes of 120 x 90). Together they give 2048x4096 for the push-in and pan. |
| T_ColdOpen_Wonderwell_B_Top.png, `_B_Bottom.png` | same | The other variation, cut the same way. Use A or B, not both. |
| T_ColdOpen_Flyer_A.png | 2048x2048 RGBA, content box x=239 y=0 w=1570 h=2048 | About 45 x 45 cm plane (the flyer itself is about 34 x 45), just in front of the poster, tilted a few degrees, over the poster's lower left so WONDERWELL stays readable. |
| T_ColdOpen_StreetWall_A.png | 2048x1024 RGB | 16:9 plane behind the poster, for example 640 x 360 cm. |

The tall poster was resized from 2:3 to 1:2 before the split, so each half is stretched on its
texture and the 4:3 planes restore it. `mockup-coldopen.jpg` is a flat paste-up, not a game
asset.

## What I saw

- Option A has the lettering in dark ink on cream and the cleaner wizard pose; option B has
  cream and gold lettering on a blue sky and stronger light rays. Both decay to slate and black
  at the bottom as asked.
- The flyer has six tabs with two torn gaps, not the eight and three I asked for. It reads the
  same.
- The street wall is only 2K, so it will soften if the camera pushes far into it. The poster is
  the piece built for the close-up.
- Not tested: anything in UEFN.

---

# Dream transition masks (no generation, no cost)

The take start is a nod to movie night, not a literal projector: house lights down, a projector
click (audio), a light flickering up on the client, and a colour wash that tracks the take.
Since the room is 2D, "light" is a blended overlay, not a UEFN light. Made locally by
`art/tools/fx_masks.py`; import both with **sRGB off**.

| Final | Texture | Use |
|---|---|---|
| T_FX_Spot_Recliner.png | 1024x1024 greyscale | Soft glow in the recliner's shape, brightest on her face and chest. Put it on a plane the same size and position as the recliner plane, just in front, as the mask of an **additive** (or modulate) material tinted by the take's colour. Fade it up for "light on the patient"; flicker its intensity for the projector start. |
| T_FX_Vignette.png | 1024x512 greyscale | White centre falling to black edges, for a 16:9 plane close to the camera with a **modulate** (multiply) material. Fade it in for "house lights down". |

`mockup-fx.jpg` shows the mask, then a warm and a cold wash composited in Python (a stand-in for
the material, not a render).

To check in the editor: whether UEFN materials allow the Additive and Modulate blend modes on a
plane, and how to change the tint at runtime. The research notes found Verse material parameters
unreliable, so the safe fallback is one overlay plane (or material) per colour, shown and hidden
with `creative_prop.Show`/`Hide`, or swapped with `SetMaterial`.

---

# Round 4: poster corner fix and Help Wanted note

Run 2026-11-12 from Chip's notes on the cold open, approved at about $0.20 (cap $0.50). 2 paid
calls on `google/nano-banana-2.1/edit`, no reruns. **About $0.20 estimated** (1 x $0.138 at 4K +
1 x $0.063 at 2K). All rounds: about $2.11.

The pan now tells the story top to bottom: the Wonderwell dream, the back room's flyer for the
people it fails, then a hand-made "HELP WANTED" sign at the end, which is where the player comes
in. The camera can end on it and push in.

| ID | Seed | Size | Input | Output file | Cost (est.) | Kept? |
|---|---|---|---|---|---|---|
| Poster A, corner fixed | 4101 | 4K 2:3 | raw/Wonderwell_s3102.png | raw/Wonderwell_A_fixed_s4101.png | 0.138 | **yes** |
| Help Wanted sign | 4201 | 2K 4:3 (2400x1792) | style ref | raw/HelpWanted_s4201.png | 0.063 | **yes** |

- **Poster A:** the turned-up bottom-left corner is gone and WONDERWELL is whole. About 5.6% of
  pixels changed (mostly the corner and fine grime); the figures and lettering held.
  `T_ColdOpen_Wonderwell_A_Top.png` and `_A_Bottom.png` were rebuilt from it. Option B still has
  the broken corner.
- **Help Wanted sign:** torn cardboard, one strip of tape, "HELP WANTED" in shaky marker and
  nothing else. `T_ColdOpen_HelpWanted_A.png`, 2048x2048 RGBA, content box x=0 y=462 w=2048
  h=1586. A plane of about 40 x 40 cm (the sign itself about 40 x 30), below the flyer at the end
  of the pan. At 2048 across 40 cm it holds up for a close push-in.
- The flyer is unchanged.
- `mockup-coldopen.jpg` now shows the three pieces in pan order on the wall; the layout is a guess.

---

# Round 5: street wall at poster scale, and a cable cutout

Run 2026-11-12 after Chip noted that the first street wall was drawn too wide a view (the
posters would use only a small, soft slice of it) and that its cables ran behind the poster.
Approved "Go" at about $0.20 (cap $0.50). 2 calls on `google/nano-banana-2.1/edit`, no reruns.
**About $0.20 estimated** (1 x $0.138 at 4K + 1 x $0.063 at 2K). All rounds: about $2.31.

| ID | Seed | Size | Output file | Cost (est.) | Kept? |
|---|---|---|---|---|---|
| Street wall, about 4 m wide, clear middle | 5101 | 4K 16:9 (5504x3072) | raw/StreetWallScaled_s5101.png | 0.138 | **yes** |
| Cable bundle | 5201 | 2K 4:1 (4128x1024) | raw/Cables_s5201.png | 0.063 | **yes** |

| Final | Texture | Plane |
|---|---|---|
| T_ColdOpen_StreetWallScaled_Left.png, `_Right.png` | 2048x2048 RGB each (left and right halves) | Two planes side by side, each 200 x 225 cm, making a 400 x 225 cm wall. About 5 texels per cm. |
| T_ColdOpen_Cables_A.png | 2048x512 RGBA | About 400 x 100 cm, a few cm in front of the poster, with its sag above the poster's top edge. |

At this scale a 120 x 180 cm poster covers about 30% of the wall's width, and the middle 60% of
the wall is plain for the poster, flyer and sign. The cables hang in front, so nothing is cut
off, and they slide past the poster in the pan. The first wall (`T_ColdOpen_StreetWall_A`) is
kept for a wider street shot.

`mockup-coldopen.jpg` is now at real scale (3.2 px per cm): wall 400 x 225, poster 120 x 180,
flyer about 45, sign about 40. The layout is a guess.

## Revised cold-open sizes (Chip, no new images)

Smaller poster, bigger flyer and sign. These replace the plane sizes given in rounds 3 to 5:

| Piece | Plane | Texture detail |
|---|---|---|
| Wonderwell poster (two stacked planes) | 90 x 135 cm in total, each half 90 x 67.5 | about 30 texels per cm |
| Flyer | about 70 x 70 cm plane (the flyer itself about 54 x 70), overlapping the poster's lower right corner | about 29 texels per cm |
| Help Wanted sign | about 60 x 60 cm plane (the sign itself about 60 x 46), below the poster at the end of the pan | about 34 texels per cm |
| Wall | unchanged, 400 x 225 cm | about 5 texels per cm |

All three still have far more detail than the wall behind them, so the push-in onto the sign
stays sharp. `mockup-coldopen.jpg` is rebuilt at these sizes; the layout is still a guess.

## Cold-open layout: a row, read left to right (Chip)

The camera now travels sideways: the poster, then the flyer to its right at the bottom, then the
Help Wanted sign to the right of the flyer. Positions on the 400 x 225 cm wall, measured from the
wall's left edge and up from its bottom edge (the pavement), plane centres:

| Piece | Plane | Centre (across, up) | Notes |
|---|---|---|---|
| Wonderwell poster | 90 x 135 cm | 125, 139 cm | spans 80 to 170 across, 71 to 206 up |
| Flyer | about 70 x 70 cm | 209, 105 cm | tilted about 3 degrees clockwise; its bottom lines up with the poster's bottom |
| Help Wanted sign | about 60 x 60 cm | 273, 94 cm | tilted about 5 degrees anticlockwise; a little lower than the flyer, the end of the move |
| Cables | 400 x 100 cm | 200, 210 cm | in front of everything, sag above the poster |

`mockup-coldopen.jpg` shows this layout.

## Cold-open camera path (Chip)

Fade in from black on a tight crop of "MAKE DREAMS HAPPEN", drift down until WONDERWELL is in
frame, then on the narration's "That's not me" track right past the flyer to the Help Wanted
sign. Framing targets on the wall, using the layout above (frame width is what the screen shows,
16:9):

| Beat | Frame centre (across, up) | Frame width | What's in shot |
|---|---|---|---|
| 1. Fade in | 125, 186 cm | about 85 cm | the title only |
| 2. Drift down (end) | 125, 95 cm | about 100 cm | the two figures' lower half, "Accepting applications...", WONDERWELL |
| 3. "That's not me", track right | through 209, 105 cm | about 100 cm | the flyer |
| 4. Help Wanted | 273, 94 cm | about 80 cm | the Help Wanted sign; the track slows but doesn't stop |
| 5. The door | 362, 115 cm | about 110 cm, pushing in to about 50 on the wired glass | the shop's street door; fade to black during the push |
| 6. Office | (inside) | | fade up inside the office, on the room's existing entry move through `T_Room_Doorway_A` |

Beats 5 and 6 are Chip's (2026-11-12): keep panning right to a door, push in and fade to black,
then come back in the office.

### Round 6: street door

Run 2026-11-12, approved "Yes, make it" at about $0.06 (cap $0.20). 1 call on
`google/nano-banana-2.1/edit`, no reruns. **About $0.06 estimated.** All rounds: about $2.37.

| ID | Seed | Size | Reference images | Output file | Cost (est.) | Kept? |
|---|---|---|---|---|---|---|
| Street door, head-on, on magenta | 6101 | 2K 9:16 (1536x2752) | style ref, `T_Room_Doorway_A` (on magenta, 1024x512 JPG) | raw/Door_s6101.png | 0.063 | **yes**, after a local fix |

Prompt: system prompt A, then "A single shabby street-level shop door seen flat and head-on ...
wired-glass panel, dark inside with only a faint warm amber glow ... a small hand-lettered
bone-paper card taped inside the glass, lettering too small to read ... should read as the
outside of the doorway in the second image." The model wrote "Hand-Letted" on the card, so the
heading was painted over locally with one of the card's own scribble lines
(`raw/Door_fixed_s6101.png`, free). The card can carry the shop's name later if it gets one.

| Final | Texture | Plane | Centre (across, up) |
|---|---|---|---|
| T_ColdOpen_Door_A.png | 1024x2048 RGBA, content box x=0 y=283 w=1024 h=1765 | 122 x 244 cm (the door, frame and step are 122 x 210; the top 34 cm is empty) | 362, 122 cm; spans 301 to 423 across, plane bottom on the pavement |

**The wall needs to be wider.** The door with its frame is about 122 cm wide, so it can't fit
between the Help Wanted sign (right edge at 303) and the wall's end at 400. Scale the whole wall
uniformly to 432 x 243 cm (two halves of 216 x 243, cables 432 x 108). Nothing
else moves: positions are measured from the wall's left edge and the pavement. The door then
ends 9 cm short of the wall's right edge.

Resolution: in beat 1 the title is about 72 cm wide on the top poster texture (2048 texels for
90 cm), so it gets about 0.85 texels per screen pixel at 1080p, very slightly soft. Grain or a
slow fade hides that. If it shows, a free fix is a third texture cropped from the 4K source
around the title only, laid over the top half.

This replaces the hard cut on "That's not me" in `docs/design.md` (cold open, step 2) with a
track; the design doc is the orchestrator's to update.

---

# Final art pass list

Held for a texture-upgrade pass at the end of the jam (Chip, 2026-11-12). Add to it as things
come up.

| Item | Why | Fix | Cost |
|---|---|---|---|
| Title crop for the cold-open fade-in | "MAKE DREAMS HAPPEN" gets about 0.85 texels per screen pixel at 1080p in the opening crop, so it is very slightly soft | Crop the title from `raw/Wonderwell_A_fixed_s4101.png` (4K) into its own 2048-wide texture, laid over the poster's top half | Free, local |
| Wonderwell poster option B | Still has the turned-up corner with the W drawn over it | Same edit as option A (round 4); only needed if B is used | About $0.14 |
| Credit lines on two posters | `T_Poster_SciFi` and `T_Poster_Musical` have tiny, partly readable made-up credits (invented names, and "Lorem ipsum" on the musical) | Crop or paint over the bottom strip locally; only needed if a close-up shows them | Free, local |
