# Third-party Assets and Licenses

List every asset not made by the team during the jam (Fab, AI generators, music, and so on).

| Asset | Source | License | Made before jam? |
|---|---|---|---|
| `art/style-test/final/T_Room_BackWall_A.png`, `T_Room_BackWallClean_A.png`, `T_Room_Floor_A.png` (2D style test: wall and floor layers) | fal, `google/nano-banana-2.1/edit`, with a style reference from `google/nano-banana-2.1` | fal model pages: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/raw/WallClean4K_s2121.png`, `_s2122.png`, `Desk4K_s2125.png`, `_s2126.png` (4K back wall and whole desk; the kept ones replace `T_Room_BackWallClean_A.png` and `T_Room_Desk_A.png`) | fal, `google/nano-banana-2.1/edit`, style reference `refs/style-ref.png`; desk alpha by `art/tools/cutout.py` | fal model page: "Commercial use" | No, generated 2026-11-13 |
| `art/style-test/final/T_Room_ReclinerClient_Breath0_Key.png`, `_Breath1_Key.png`, `T_Room_Monitor_A.png`, `T_Room_JunkLeft_A.png`, `T_Room_ShelfRight_A.png`, `T_Room_Desk_A.png`, `T_Room_Doorway_A.png` (2D style test: cutout layers) | fal, `google/nano-banana-2.1/edit`; alpha by our own magenta-key script (`art/tools/cutout.py`) | fal model page: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/final/T_Room_Recliner_Nell_Breath.png` (Nell's second breathing frame: `_Breath0_Key` with `_Breath1_Key` let in around the torso only, by `art/tools/make_breath_frame.py`) | Derived from the fal frames above; no new generation | as above | No, made 2026-11-14 |
| `art/style-test/final/T_Room_ReclinerClient_Breath0_Bria.png`, `_Breath1_Bria.png` (same cutouts, other alpha method, comparison only) | fal, `google/nano-banana-2.1/edit`; alpha by `fal-ai/bria/background/remove` | fal model pages: "Commercial use" (both) | No, generated 2026-11-12 |
| `art/style-test/final/T_Poster_Gangster.png`, `T_Poster_Romance.png`, `T_Poster_SciFi.png` (film posters, invented titles) | fal, `google/nano-banana-2.1/edit` | fal model page: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/final/T_Poster_Musical.png` (SING, MEADOW, SING, redone darker: a lone woman by a wind-bent tree at dusk; from `raw/PosterMusical_s2501.png`; `_s2502.png` was the other option) | fal, `google/nano-banana-2.1/edit`, house style prompt A and `refs/style-ref.png`, seeds 2501-2502 | fal model page: "Commercial use" | No, generated 2026-11-15 |
| `audio/narration/VO_Director_room_poster_musical.wav` (+ `takes/..._A.wav`, `_B.wav`; the director on the poster) | fal, `google/gemini-3.8-flash-tts`, voice Orus | fal model page: "Commercial use" | No, generated 2026-11-15 |
| `art/style-test/final/T_TitleCard_B.png` (title card, `Content/TitleCard/T_TitleCard`): `raw/TitleBg_no_chair.png` (recliner removed) and `raw/TitleBg_dreamer_a.png` (the figure on the street, chosen; `_b` the other take) | fal, `google/nano-banana-2.1/edit`, on our own title background; composited by `art/tools/make_title_card.py` | fal model page: "Commercial use" | No, generated 2026-11-14 |
| `art/style-test/final/T_Client_Mouth_Atlas.png`, `T_Client_Chest.png` (client mouth flipbook and chest overlay) | fal, `google/nano-banana-2.1/edit`; cut by our own script (`art/tools/client_parts.py`) | fal model page: "Commercial use" | No, generated 2026-11-12 |
| `art/style-test/raw/MouthEE_s2401.png`, `MouthOO_s2402.png`, `MouthFV_s2403.png`, `MouthMM_s2404.png` and `final/T_Client_Nell_Mouth_Atlas8.png` (four more mouth shapes for Nell, ee, oo, f/v, m; the atlas adds them to the first three; the oo lips toned down locally) | fal, `google/nano-banana-2.1/edit` on `refs/client-face-crop.png`, seeds 2401-2404; cut by `art/tools/client_parts.py` | fal model page: "Commercial use" | No, generated 2026-11-14 |

Notes:

- The rows above are the Day 1 style test (28 fal calls, about $1.51 estimated, out of the jam's
  $30 fal credit). They live on the art branch until its PR merges. Rows for files that don't end
  up in the island get removed before submission.
- License lines are the badge shown on each fal model page on 2026-11-12; the providers' own
  terms were not read.
| `audio/narration/VO_Director_ColdOpen_01.wav` to `_04.wav`, `VO_Director_Tutorial_01.wav` (director voice-over) | fal, `google/gemini-3.8-flash-tts`, voice `Orus` | fal model page: "Commercial use" (Google's own terms not read) | No, generated 2026-11-12 (`_03` redone and `_04` added 2026-11-13) |
| `audio/narration/VO_Director_Tutorial_02.wav`, `VO_Director_nell_d1_intro.wav` to `VO_Director_nell_d3_sendin.wav` (director voice-over, debugger flow) | fal, `google/gemini-3.8-flash-tts`, voice `Orus` | fal model page: "Commercial use" (Google's own terms not read) | No, generated 2026-11-14 |
| `audio/narration/VO_Director_finale_*.wav` (director, the finale: praise, reboot, plug, after, resting, kettle) | fal, `google/gemini-3.8-flash-tts`, voice `Orus` | fal model page: "Commercial use" (Google's own terms not read) | No, generated 2026-11-14 |
| `audio/narration/VO_AI_finale.wav` (the Wonderwell AI's line; voice `Leda`, picked from an audition with `Puck` and `Achird` in `audio/narration/audition/`) | fal, `google/gemini-3.8-flash-tts` | fal model page: "Commercial use" (Google's own terms not read) | No, generated 2026-11-14 |
| `audio/sfx/SFX_PowerCut_A.wav` to `_F.wav` (power-cut takes, not used) | fal, `elevenlabs/sound-effects/v3` | fal model page badge not checked | No, generated 2026-11-14 |
| `audio/sfx/SFX_PowerCut_H.wav` (the finale's power cut, used): E's click and thump plus a CRT switch-off synthesized in Python | fal, `elevenlabs/sound-effects/v3` (click), own code (the rest) | as above, plus our own | No, made 2026-11-14 |
| `audio/music/MUS_TitleTheme_A.wav`, `_B.wav` and their `_Loop` versions (title theme takes from the Wonderwell jingle; the loops crossfade the end into the start) | fal, `elevenlabs/music/v2.5`, the jingle as an audio reference | fal model page badge not checked | No, generated 2026-11-14 |
| `audio/music/MUS_EndTheme_A.wav` to `_D.wav` and their `_Loop` versions (end card theme takes from theme B; `D_Loop` is used, an ominous minor-key rendition) | fal, `elevenlabs/music/v2.5`, title theme B as an audio reference | fal model page badge not checked | No, generated 2026-11-14 |
| `audio/narration/VO_Director_finale_notyours.wav`, `VO_AI_finale_2.wav`, and the plug re-records in `audio/narration/takes/` (take C is now `VO_Director_finale_plug.wav`) | fal, `google/gemini-3.8-flash-tts` (`Orus`, `Leda`) | fal model page: "Commercial use" (Google's own terms not read) | No, generated 2026-11-14 |
| `art/title/T_TitleClouds.png` (the drifting cloud strip on the title card; raw takes in `art/title/raw/`) | fal, `google/nano-banana-2.1/edit`, the title card as the style reference, magenta-keyed with `art/tools/cutout.py` | fal model page: "Commercial use" | No, generated 2026-11-14 |
