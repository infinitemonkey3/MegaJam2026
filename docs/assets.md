# Third-party Assets and Licenses

List every asset not made by the team during the jam (Fab, AI generators, music, and so on).

| Asset | Source | License | Made before jam? |
|---|---|---|---|
| `art/style-test/final/T_Room_BackWall_A.png`, `T_Room_BackWallClean_A.png`, `T_Room_Floor_A.png` (2D style test: wall and floor layers) | fal, `google/nano-banana-2.1/edit`, with a style reference from `google/nano-banana-2.1` | fal model pages: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/final/T_Room_ReclinerClient_Breath0_Key.png`, `_Breath1_Key.png`, `T_Room_Monitor_A.png`, `T_Room_JunkLeft_A.png`, `T_Room_ShelfRight_A.png`, `T_Room_Desk_A.png`, `T_Room_Doorway_A.png` (2D style test: cutout layers) | fal, `google/nano-banana-2.1/edit`; alpha by our own magenta-key script (`art/tools/cutout.py`) | fal model page: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/final/T_Room_ReclinerClient_Breath0_Bria.png`, `_Breath1_Bria.png` (same cutouts, other alpha method, comparison only) | fal, `google/nano-banana-2.1/edit`; alpha by `fal-ai/bria/background/remove` | fal model pages: "Commercial use" (both) | No, generated 2026-11-12 |
| `art/style-test/final/T_Poster_Gangster.png`, `T_Poster_Romance.png`, `T_Poster_SciFi.png`, `T_Poster_Musical.png` (film posters, invented titles) | fal, `google/nano-banana-2.1/edit` | fal model page: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/final/T_Client_Mouth_Atlas.png`, `T_Client_Chest.png` (client mouth flipbook and chest overlay) | fal, `google/nano-banana-2.1/edit`; cut by our own script (`art/tools/client_parts.py`) | fal model page: "Commercial use" | No, generated 2026-11-12 |

Notes:

- The rows above are the Day 1 style test (28 fal calls, about $1.51 estimated, out of the jam's
  $30 fal credit). They live on the art branch until its PR merges. Rows for files that don't end
  up in the island get removed before submission.
- License lines are the badge shown on each fal model page on 2026-11-12; the providers' own
  terms were not read.
| `audio/narration/VO_Director_ColdOpen_01.wav` to `_04.wav`, `VO_Director_Tutorial_01.wav` (director voice-over) | fal, `google/gemini-3.8-flash-tts`, voice `Orus` | fal model page: "Commercial use" (Google's own terms not read) | No, generated 2026-11-12 (`_03` redone and `_04` added 2026-11-13) |
