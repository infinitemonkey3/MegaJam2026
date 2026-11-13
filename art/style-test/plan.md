# 2D art style test: plan

Written 2026-11-12 (jam Day 1) by the art stream. This is the plan for the "2D layers in the 3D
room" half of the art path test in `docs/design.md` (technical risk 6). **Nothing has been
generated.** Every paid call below waits for Chip's approval of the model and cost.

The question the test answers: **does one illustrated style hold across several generated
images, and does it read from the desk** next to the 3D blockout, under the room lighting and
the haze?

All endpoint IDs, schemas and prices were looked up on fal on 2026-11-12. Anything I could not
confirm is marked **unconfirmed**.

## Approval request

| | |
|---|---|
| Models | `google/nano-banana-2.1` (generate), `google/nano-banana-2.1/edit` (edit with reference), `fal-ai/bria/background/remove` (alpha) |
| Calls | 11 image calls + 3 background-removal calls = 14 |
| Estimated cost | **$0.74** |
| Cap I'm asking for | **$1.00**, which covers up to 4 reruns of a failed image |
| Left of the $30 after the test | about $29 |

## 1. The look

One fixed style for every image: **"two-ink print"**. It should look like a page from a cheaply
printed crime comic.

- Bold black brush-ink outlines of uneven weight, and large solid black shadow shapes.
- Flat colour fills, three or four tones per object. No gradients, no airbrush, no photo or 3D
  render look.
- Dry-brush and coarse halftone texture inside shapes only, never on the outline.
- Every object has a crisp, closed silhouette.
- Light is low and motivated: teal neon from the street, striped by the blinds, and one amber
  desk lamp.

Palette (ours, used in every prompt):

| Name | Hex | Used for |
|---|---|---|
| Ink black | `#0B0D12` | Line, shadow shapes |
| Slate blue | `#2A3442` | Walls, deep midtones |
| Dusty steel | `#5B6B7A` | Metal, plastic, cloth midtones |
| Bone paper | `#D9D2C0` | Paper, skin lights, tape |
| Signal teal | `#19C6B5` | Neon, screen glow |
| Sodium amber | `#F2A53A` | Lamp, warm rim light |
| Warning red | `#D83A2E` | Stickers and stamps, tiny areas only |

No magenta, pink or purple anywhere in the art. That keeps magenta free as the cutout key colour
(section 6).

**Candidates:**

| | A. Two-ink print (recommended) | B. Ink wash |
|---|---|---|
| Look | Hard ink line, flat tones, halftone | Wet grey washes, soft bleeding edges, paper grain |
| Cutout edges | Hard and closed, so alpha is clean | Soft edges leave fringes and holes on a plane |
| Consistency | Few tones and a hard line are easy to repeat | Wash density and bleed differ on every image |
| Under haze and dimming | Black shapes survive desaturation and blur | Already low-contrast, turns to mud |
| Lettering on posters and flyers | Stays readable | Blurs |
| Breathing frames | A small shape change, easy to match | Wash texture boils between frames |

**Recommendation: A.** B is moodier in a single image, but this game needs cutouts on planes,
many matching images and readable lettering, and A is better at all three. The test still makes
one B reference image so the two can be compared side by side ($0.06).

**Our own signage and brands.** No real brands, no film or artist named in any prompt. The test
uses placeholder poster titles (`THE LONG INTERMISSION`, `SALT STATIC`) and the case-folder label
`PRICE, E.`. They are placeholders: the writing stream owns the real names, and each should be
searched before it ships. The neon outside the window is light only, with no readable sign.

## 2. Model choice

### Generation and editing: Nano Banana 2.1

| | Generate | Edit |
|---|---|---|
| Endpoint ID | `google/nano-banana-2.1` | `google/nano-banana-2.1/edit` |
| Used for | The style reference only | Every layer (the reference image goes in on every call) and every change to the client |
| Reference images | No | Yes, `image_urls`, up to 14 |
| Style lock | `system_prompt` field | `system_prompt` field |
| Size control | `resolution` 1K / 2K / 4K and `aspect_ratio` (no 2:1; 16:9 and 1:1 are available) | Same |
| Negative prompt | None | None |
| Seed | `seed` field | `seed` field |
| Transparent background | No | No |
| Price | Billed by tokens. fal's page gives about **$0.040 at 1K, $0.059 at 2K** per image | About **$0.044 at 1K, $0.063 at 2K** with two input images |
| License line on the fal page | "Commercial use" | "Commercial use" |

Why this one: it is fal's published default for both text-to-image and editing, its notes call
out consistent people across images, and the `system_prompt` field lets the style text sit apart
from the scene text so it is identical on every call. fal's notes also warn that character
continuity can drift and small text at 1K can blur, which is what the test checks.

Price notes: `get_pricing` returns only "1 unit" for these endpoints, so the per-image numbers
come from the pricing table on the model page. They are fal's examples for a short prompt, not a
quote. The edit figure excludes thinking tokens ($8.82 per million), so a real edit may cost a
cent or so more. Exact pixel size at 2K is **unconfirmed** (the page says "about 4 megapixels");
the pipeline resizes to exact power-of-two sizes anyway.

### Background removal: Bria RMBG 2.0

| | |
|---|---|
| Endpoint ID | `fal-ai/bria/background/remove` |
| Price | **$0.018 per image** without a prompt (`get_pricing`, and the same on the page) |
| License line on the fal page | "Commercial use"; the page adds that it is trained only on licensed data |

Needed because the image model has no transparent output. `fal-ai/birefnet/v2` is cheaper on
paper ($0.000575 per compute second) but its per-image cost is **unconfirmed**, so I picked the
fixed price. The test also runs a free local magenta key on the same images for comparison
(section 6).

### Backup: Seedream 5.0 Flash

| | Generate | Edit |
|---|---|---|
| Endpoint ID | `bytedance/seedream/v5/flash/text-to-image` | `bytedance/seedream/v5/flash/edit` |
| Price | **$0.027 per image** (`get_pricing`) | **$0.027 per image** (`get_pricing`) |
| Reference images | No | Yes, up to 10 |
| Size | Exact width and height, so 2048x2048 and 2048x1024 directly | Same |
| Negative prompt, seed, system prompt | None of the three | None of the three |
| Transparent background | No | Only keeps the alpha of an input that already has one |
| License line on the fal page | "Commercial use" | "Commercial use" |

Use it if the Nano Banana style reference fails the pick rules in section 3 twice. With no
system prompt field, the style block is pasted at the top of each prompt. It is cheaper, so if it
holds the style just as well it becomes the production model.

Also looked at, not picked: `fal-ai/flux-2-pro` and `/edit` (confirmed $0.03 for the first
megapixel plus $0.015 per extra input or output megapixel, so $0.075 or more per 2K image) and
`openai/gpt-image-2.6/flare/text-to-image`, the only one with native transparent output (price
is token-based and **unconfirmed**).

The license lines above are the badge on each fal model page. I did not read Google's, Bria's
or ByteDance's own terms.

## 3. The test set

Eleven images in four steps. Each variation is its own call with `num_images: 1` and a fixed
seed, so any image can be asked for again.

Common settings for every image call: `output_format: "png"`, `thinking_level: "medium"`,
`limit_generations: true`, `enable_web_search: false`, `safety_tolerance` left at default, and
the `system_prompt` below. None of the chosen models takes a negative prompt, so exclusions are
written into the system prompt.

**Seed policy.** Seeds are fixed and logged (`1101`, `1102`, ... as listed). The seed is for
re-running a call, not for consistency: consistency comes from the system prompt and the
reference image. Whether the same seed reproduces the same image on this model is
**unconfirmed**.

### System prompt A (every call, word for word)

```
House style "two-ink print" for every image: a hand-inked illustration that looks like a page
from a cheaply printed crime comic. Bold black brush-ink outlines of uneven weight and large
solid black shadow shapes. Flat colour fills only, three or four tones per object. No gradients,
no soft airbrush, no photorealism, no 3D render look. Dry-brush and coarse halftone dot texture
inside shapes only, never on the outlines. Palette limited to: ink black #0B0D12, slate blue
#2A3442, dusty steel #5B6B7A, bone paper #D9D2C0, signal teal #19C6B5, sodium amber #F2A53A,
and tiny touches of warning red #D83A2E. No magenta, pink or purple on any object. Light is low
and motivated: teal neon from outside striped by window blinds, and one warm amber lamp. Every
object has a crisp, closed silhouette. No signatures, watermarks, borders, panel frames, speech
balloons or captions. The only lettering is what the prompt spells out.
```

### System prompt B (image R-B1 only)

```
House style "ink wash" for every image: a hand-painted ink-wash illustration on rough paper, in
the manner of a noir graphic novel. Loose black brush line, wet grey washes that bleed at the
edges, visible paper grain, large areas of deep black. Colour is sparse: slate blue #2A3442
washes, signal teal #19C6B5 for neon light, sodium amber #F2A53A for lamp light, bone paper
#D9D2C0 for highlights. No magenta, pink or purple. No photorealism, no 3D render look. No
signatures, watermarks, borders, panel frames, speech balloons or captions. The only lettering
is what the prompt spells out.
```

### The client (pasted into every prompt that shows her)

```
Nell: a 71-year-old woman, broad and sturdy, with strong forearms, short wavy white hair pushed
back from a lined, square face, and deep-set eyes that are closed. She wears a faded steel-blue
cardigan over a bone-coloured blouse, and a thin grey blanket covers her to the waist. Her hands
are folded on her stomach. Behind her right ear is a small implant port; a thin black cable runs
from it, held to her temple by two strips of bone-coloured tape, and trails over the arm of the
chair.
```

### Step 1: style reference (3 calls)

Endpoint `google/nano-banana-2.1`, `resolution: "2K"`, `aspect_ratio: "16:9"`.

| ID | System prompt | Seed |
|---|---|---|
| R-A1 | A | 1101 |
| R-A2 | A | 1102 |
| R-B1 | B | 1103 |

Prompt (same for all three):

```
Wide interior view of a cramped back room at night, seen from a chair at a desk, at seated eye
level. Along the bottom of the frame: the near edge of a scarred wooden desk with a stack of
paper case folders, a chipped saucer of loose screws, a coil of black cable, and a
bulky old monitor with its screen off. Middle distance, right of centre: an old reclining
armchair patched with tape, and asleep in it an elderly woman with short white hair, a steel-blue
cardigan and a grey blanket, a thin black cable taped at her temple and trailing to the floor.
Left: a waist-high heap of gutted monitors, loose circuit boards and tangled cable. Back wall:
stained plaster, three old film posters pinned up, and a window with half-closed venetian
blinds; teal neon light from the street cuts through the blinds in stripes, and rain runs down
the glass. One amber desk lamp. No other people. Two posters carry hand-lettered titles in
capitals, "THE LONG INTERMISSION" and "SALT STATIC"; the third is torn and unreadable.
```

**Pick rule (no decision needed):** the reference is the A image that passes more of these:
hard closed outlines on every object; no gradients; only palette colours; the woman, the junk
pile and the wall are each readable as a thumbnail at 480 px wide; both poster titles spelled
right. Tie goes to R-A1. If both fail three or more, rerun once with seeds `1111` and `1112`,
then switch to the backup model. R-B1 is only for the side-by-side with A; no layers are made
from it. Save the pick as `refs/style-ref.png`.

### Step 2: layers (7 calls)

Endpoint `google/nano-banana-2.1/edit`, `resolution: "2K"`, `image_urls: [style-ref]`. The
reference has to be uploaded to fal first to get a URL.

Every layer prompt starts with the same line:

```
Use the attached image only as the style, line and palette reference. Do not copy its layout.
Draw a new image in exactly that style:
```

**L1 back wall.** `aspect_ratio: "16:9"`, 2 variations (seeds `1201`, `1202`). Opaque, no alpha.
Final texture 2048x1024.

```
A flat, straight-on elevation of one interior wall, filling the whole frame from edge to edge.
No floor, no ceiling, no furniture, no people, no perspective. Stained, cracked plaster in slate
blue. In the left third, a window with half-closed venetian blinds; teal neon light from outside
comes through the slats, rain runs down the glass, and the striped light falls across the wall
to the right. In the centre and right, three old film posters pinned up at slightly different
heights: one titled "THE LONG INTERMISSION" and one titled "SALT STATIC" in hand-lettered
capitals, the third torn and unreadable. A dead wall clock, a run of surface cable conduit, a
row of bare nails. The wall is darkest in the top corners and along the bottom.
```

**L2 recliner with the client.** `aspect_ratio: "1:1"`, 3 variations (seeds `1211`, `1212`,
`1213`). Cutout. Final texture 2048x2048.

```
One isolated subject on a perfectly flat, uniform, pure magenta (#FF00FF) background. The
background has no shadow, no floor, no gradient and no texture, and magenta appears nowhere on
the subject. The subject: an old reclining armchair, leaned back, patched with tape, seen
three-quarter from the front and slightly from above, as from a seated person a few metres
away. Lying in it is [the client block]. The whole chair, the figure and the trailing cable fit
inside the frame with a clear magenta margin on every side; nothing is cropped. Teal light
falls on her from the upper left and a warm amber rim from the lower right.
```

Pick rule for L2: the variation where she best matches the client block (hair, cardigan,
closed eyes, taped cable), nothing is cropped, and the magenta is flat. Tie goes to the lowest
seed.

**L3 foreground desk clutter.** (2026-11-13: the images in `raw/`, `cutout/` and `refs/` were made when this prompt and the style-reference prompt asked for a stubbed-out cigarette in the saucer; that was swapped for screws to meet the jam's content guidelines, and the clutter layer was removed from the game.) `aspect_ratio: "16:9"`, 2 variations (seeds `1221`, `1222`).
Cutout. Final texture 2048x1024.

```
One isolated group of objects on a perfectly flat, uniform, pure magenta (#FF00FF) background.
The background has no shadow, no surface, no gradient and no texture, and magenta appears
nowhere on the objects. The objects sit in a low, wide row as if on the near edge of a desk,
seen from just above, with their bottom edge flat and level: a stack of three paper case folders
tied with string, the top one labelled "PRICE, E." in capitals; a chipped saucer of loose
screws; a coffee-ringed mug; a small screwdriver; a loose circuit board;
a coil of black cable. The whole group fits inside the frame with a clear magenta margin at the
top and sides. Warm amber lamp light from the right, a teal edge light from the left.
```

### Step 3: same person, second frame (1 call)

**L2b breathing frame.** Endpoint `google/nano-banana-2.1/edit`, `resolution: "2K"`,
`aspect_ratio: "1:1"`, seed `1301`, `image_urls: [picked L2 raw image, style-ref]`. This is the
test of "the client stays the same person" and of breathing frames at once.

```
Edit the first image. Keep everything identical: the same woman, face, hair, clothes, blanket,
chair, cable, pose, framing, line work, colours and the flat magenta background. Change only
this: she is at the top of a slow breath in. Her chest and the blanket over it are slightly
raised, her shoulders are a touch higher, and her folded hands have risen with her chest. Do not
move the chair, her head or the framing. The second image is the style reference only.
```

### Step 4: alpha (3 calls)

`fal-ai/bria/background/remove` with `image_url` only (no prompt, which would raise the price to
$0.03) on the picked L2, on L2b and on the picked L3. The local magenta key in section 6 runs on
the same three images for free.

### Summary

| Step | Images | Calls |
|---|---|---|
| 1. Style reference | R-A1, R-A2, R-B1 | 3 |
| 2. Layers | L1 x2, L2 x3, L3 x2 | 7 |
| 3. Same person | L2b | 1 |
| 4. Alpha | L2, L2b, L3 | 3 |

## 4. Cost

### The test

| Call | Endpoint | Count | Each | Total |
|---|---|---|---|---|
| Style reference, 2K | `google/nano-banana-2.1` | 3 | $0.059 | $0.177 |
| Layers and breathing frame, 2K, 1-2 reference images | `google/nano-banana-2.1/edit` | 8 | $0.063 | $0.504 |
| Background removal | `fal-ai/bria/background/remove` | 3 | $0.018 | $0.054 |
| **Total** | | **14** | | **$0.735** |

The Nano Banana rows are estimates from fal's pricing table (token billing); the Bria row is a
fixed price. Requested cap: **$1.00**.

### Full production (rough)

Assumes the test passes with the same models, three attempts per finished image, 2K for room
layers and 1K ($0.044) for small items. Counts are my guess at the slice's needs.

| Group | Finished images | Calls | Each | Total |
|---|---|---|---|---|
| Room layers: back wall, 2 junk piles, recliner, desk, 2 foreground clutter | 7 | 21 | $0.063 | $1.32 |
| Client: 2 more breathing frames, half-awake, distressed, empty recliner | 5 | 15 | $0.063 | $0.95 |
| Posters and wall dressing | 6 | 12 | $0.044 | $0.53 |
| Cold open: 3 flyers, warning sticker, 3 street wall layers, doorway figure | 8 | 24 | $0.063 | $1.51 |
| Desk items and case-file pictures | 6 | 12 | $0.044 | $0.53 |
| Background removal on cutouts | 25 | 25 | $0.018 | $0.45 |
| **Total** | **32** | **109** | | **about $5.30** |

Doubling that for restarts and a style change midway gives about **$11**. So the 2D path should
fit in roughly a third of the $30, leaving the rest for audio (director voice, if generated) and
anything the 3D path needs from fal. On the backup model the same list is about $3.

## 5. How it gets judged

The orchestrator imports the finals and looks from the desk, next to the 3D blockout, in the
same lighting.

### Layer depth order

Distances are from the seated eye point (about 115 cm above the floor), straight ahead. Planes
are vertical and face the eye point.

| Order (back to front) | Layer | Distance | Plane size (W x H) | Bottom edge above floor | Texture | In the test? |
|---|---|---|---|---|---|---|
| 1 | Back wall | 420 cm | 800 x 450 cm | 0 cm | 2048x1024, opaque | Yes, L1 |
| 2 | Junk pile | 330 cm, left | 280 x 200 cm | 0 cm | 2048x2048, alpha | No, use a blockout box |
| 3 | Recliner with client | 260 cm, right of centre | 230 x 230 cm | 0 cm | 2048x2048, alpha | Yes, L2 and L2b |
| 4 | Desk | 95 cm | 240 x 120 cm | 0 cm | 2048x1024, alpha | No, use the blockout desk |
| 5 | Foreground clutter | 70 cm | 110 x 62 cm | 75 cm (on the desk top) | 2048x1024, alpha | Yes, L3 |

At 1080p with a FOV near 80 degrees these sizes give about one texel per screen pixel on the
wall and the clutter, and two on the recliner. If the recliner looks the same at 1024x1024,
production uses that.

### Editor setup

- Texture import: sRGB on, mipmaps on ("No Mipmaps" fails validation), default compression.
- Material: Surface, **Lit**, roughness 1, specular 0, so the room lamp, dimming and fog affect
  the planes. Try **Masked** first (clean sorting, fog works), then **Translucent** on the same
  texture if the edge looks too hard.
- L2 and L2b on the same plane, swapped on a timer of about 2 seconds, to see the breathing.

### Checklist

Answer each yes or no from the desk view, then once more with the top haze level on.

**Style consistency**
1. Do L1, L2 and L3 look drawn by the same hand (line weight, number of tones, texture)?
2. Are all colours from the palette, with no stray hue on any layer?
3. Do the lighting directions agree (teal from the window side, amber from the lamp side)?
4. Is the client in L2b plainly the same woman as in L2 (face, hair, clothes, cable)?
5. Does swapping L2 and L2b read as breathing, without the chair or outline jumping?

**Readability at desk distance**
6. Is the client readable as a person lying in a chair at a glance?
7. Are the poster titles and the folder label legible, and spelled right?
8. Does the screen area stay the focus, with the layers not fighting it?
9. With the lamp dimmed and each haze level on, is the client still readable?

**Alpha edges**
10. No magenta or pale fringe on any cutout edge, close up and at distance?
11. No holes inside the cutouts, and no leftover background between cables or chair legs?
12. Do the edges hold under mipmapping (no shimmer or halo when the view moves)?
13. Which is cleaner on the same image, the Bria cutout or the local magenta key?
14. Do the planes take the room light and fog like the blockout next to them, with no sorting
    errors between layers?

**Parallax**
15. When the player leans or stands, do the layers shift against each other enough to feel
    like depth?
16. At what head movement does a plane read as flat cardboard? Is that inside what the seated
    view allows?

**Against the 3D blockout**
17. Which view would you rather watch for ten minutes?

Pass: yes on 1, 2, 4, 6, 10 and 14, and no more than three no answers in total. Results go in
`docs/spikes.md` under the art path, by the orchestrator.

## 6. Cutout pipeline

From a generated image to a plane texture. All of it runs locally with Python and Pillow (Pillow
9.2 is installed on this machine) apart from the Bria call.

1. **Save the raw output** untouched in `raw/`, named `<ID>_s<seed>.png`, for example
   `L2_s1212.png`. Add a line to `runs.md` (format in `art/README.md`).
2. **Alpha.** Two methods, both kept for the test:
   - *Bria:* `fal-ai/bria/background/remove`, saved to `cutout/<ID>_bria.png`.
   - *Magenta key (free):* alpha 0 where a pixel is close to `#FF00FF`, a short ramp at the
     edge, then remove the magenta cast from edge pixels by pulling red and blue down to the
     green-based grey. Saved to `cutout/<ID>_key.png`.
   Production keeps whichever wins question 13.
3. **Bleed the edge colour.** Copy the nearest opaque colour outward into the transparent
   pixels (about 8 px) without changing alpha. This stops dark or magenta halos when the
   texture is mipmapped.
4. **Trim** to the alpha bounding box plus a 16 px margin. For L3, keep the bottom edge where it
   is, so the objects sit on the desk line.
5. **Fit to a power of two.** Scale the trimmed image to fit inside the target size (2048x2048,
   2048x1024 or 1024x1024, never above 2K) and pad with transparent pixels, centred
   horizontally and bottom-aligned. Opaque layers such as L1 are simply resized to 2048x1024;
   the plane's own proportions restore the picture. Record the padded content box in `runs.md`
   so the plane can be sized to match.
6. **Save the final** as 8-bit RGBA PNG (RGB for opaque layers) in `final/`, named for import.

**Naming.** `T_<Set>_<Layer>_<Variant>.png`:

| Test ID | Final file |
|---|---|
| L1 | `T_Room_BackWall_A.png` |
| L2 | `T_Room_ReclinerClient_Breath0.png` |
| L2b | `T_Room_ReclinerClient_Breath1.png` |
| L3 | `T_Room_DeskClutter_A.png` |

For the test, the two alpha methods get a `_Bria` or `_Key` suffix.

**Folders.** See `art/README.md`. The test uses `art/style-test/refs/`, `raw/`, `cutout/`
and `final/`. PNGs are stored in Git LFS by the repo's `.gitattributes`.

**Asset log.** Every final that could ship gets a row in `docs/assets.md`, in the format in
`art/README.md`. The art stream does not edit `docs/assets.md`; it puts the rows in the PR
description and the orchestrator adds them.

## Run order once approved

1. Step 1, three calls together. Apply the pick rule, save `refs/style-ref.png`, upload it.
2. Step 2, seven calls together. Apply the L2 pick rule; for L1 and L3 take the variation with
   correct lettering, lowest seed on a tie.
3. Step 3, one call.
4. Step 4, three calls, and the local key on the same three images.
5. Pipeline steps 3 to 6, commit raws, cutouts and finals, open a PR with the asset rows and the
   actual cost. The orchestrator imports and runs the checklist.

Stop and report instead of spending past the cap.
