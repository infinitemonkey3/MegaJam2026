# art/

Source images and models for *Dead Air*, owned by the art stream (stream 3 in
`docs/workstreams.md`). Import into UEFN is done by the orchestrator session, not from here.

## Rule: no generation without approval

Every paid fal or Meshy call is approved by Chip first, **by model and by cost**. Until a plan's
approval request has a yes:

- do not call anything that creates or runs a job (fal `run_model`, `submit_job`, `submit_jobs`;
  any Meshy create tool)
- free lookups are fine: model search, schemas, pricing, account status, reading model pages

An approval covers the models, the number of calls and the cost cap named in the request, and
nothing else. Stop and report before going past the cap. Only use models whose fal page allows
commercial use.

## Layout

```
art/
  README.md
  style-test/          Day 1 test of the 2D-layers path
    plan.md            the look, models, prompts, cost, judging, pipeline
    runs.md            one line per paid call (created on the first run)
    refs/              the chosen style reference image
    raw/               model output, untouched: <ID>_s<seed>.png
    cutout/            after alpha: <ID>_bria.png, <ID>_key.png
    final/             trimmed, power-of-two, ready to import: T_<Set>_<Layer>_<Variant>.png
  tools/
    cutout.py          magenta key, edge bleed, trim and fit to power-of-two (needs Pillow, numpy)
    client_parts.py    cuts the client's mouth flipbook and chest overlay from the recliner drawing
    fx_masks.py        makes the greyscale spotlight and vignette masks for 2D "lighting"
  room/                production room layers (same refs/raw/cutout/final split), after the test
  client/              production client frames
  posters/             posters and wall dressing
  coldopen/            flyers and street layers
  models/              3D sources, if the 3D path is chosen
```

Only `style-test/` and `tools/` exist so far; the others are created when production starts. Images and
models are stored in Git LFS (see the repo's `.gitattributes`).

Textures are power-of-two, 2K or smaller, 8-bit PNG, RGBA for cutouts and RGB for opaque
layers.

## Run log format (`runs.md`)

One table row per paid call, added when the call returns:

```
| ID | Date | Endpoint | Seed | Size | Reference images | Output file | Cost (USD) | Kept? |
| L2 | 2026-11-12 | google/nano-banana-2.1/edit | 1212 | 2K 1:1 | refs/style-ref.png | raw/L2_s1212.png | 0.063 | yes |
```

The full prompt for each ID lives in the plan; if a prompt is changed for a rerun, the changed
text goes under the table with the ID.

## Asset log format (`docs/assets.md`)

Every image that could ship gets a row in `docs/assets.md`, matching that file's columns. The
art stream writes the rows in its PR description; the orchestrator adds them to the file.

```
| Asset | Source | License | Made before jam? |
| art/style-test/final/T_Room_BackWall_A.png (back wall layer) | fal, google/nano-banana-2.1/edit | fal model page: "Commercial use" | No, made during the jam (2026-11-12) |
| art/style-test/final/T_Room_ReclinerClient_Breath0.png (recliner with client) | fal, google/nano-banana-2.1/edit; alpha by fal-ai/bria/background/remove | fal model pages: "Commercial use" (both) | No, made during the jam (2026-11-12) |
```

- **Asset:** the final file's path and what it is.
- **Source:** the tool (fal or Meshy), the exact endpoint ID, and any second model used on it.
- **License:** the license line as shown on the model's page on the day it was made.
- **Made before jam?:** "No, made during the jam" and the date.
