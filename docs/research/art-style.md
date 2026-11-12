# Art style research

Researched 2026-11-11, before the jam started, for the coma-ward concept in `docs/design.md`. This
is a plan, not game content. Every claim links to its source. **Unverified** means I could not
confirm it from a primary source and it should be tested in the editor on Day 1.

> **Update 2026-11-11: the frame changed.** `design.md` now sets the game in a noir, cyberpunk
> back room (rain, neon through blinds, a client in a recliner, a glowing monitor), not a
> hospital ward, and the dream is shown only as a debug log, not as props. What still applies:
> the light-and-color-first approach, the 3-stage escalation with lights, post process and
> props, the Post Process device notes (use them for the "take starting" look: dim, grain,
> letterbox), the asset library checks, the lying-NPC options, and the partner tool and import
> rules. What no longer applies: the pale clinic palette and the dream prop swap.

## Recommendation (read this first)

**Primary style: "soft liminal clinic", a near-monochrome room with one accent color.**
A quiet, almost empty room in pale teal, cream and grey, lit mostly by soft light (a window or
light panel plus one warm lamp). Few props, each placed on purpose. The mood comes from light,
fog and color, not from detailed models. Each dream gets one accent color (warm orange for
Nell's bakery, chalk green for a classroom) that leaks into the room as the dream starts.

Why: it needs very little custom art, it uses the tools UEFN is good at (lighting, fog,
post process, a few props), it survives Fortnite's stylized look because nothing has to look
realistic, and calm-to-threatening can be done by changing light and color alone. It also
reads well in a 30-60 s video, and the jam has a **Render Royalty** prize for best visuals
([jam page](https://itch.io/jam/2026-epic-ai-megajam)).

**Backup style: silhouette and fog minimalism.** If props or the room look bad, drop to near
darkness: black shapes, heavy height fog, one or two light sources and emissive outlines. Almost
no texture work. Riskier for readability (players must still find the bed and case file), and
harder to make "calm" at the start, but very cheap.

**One-day art pipeline (one person):**

| Time | Work | Tool |
|---|---|---|
| 1 h | Block the room with Fortnite gallery pieces (walls, floor, door, window, bed if one exists). Recolor with your own material instances. | UEFN Content Browser |
| 1.5 h | 3-5 tiling materials (linoleum, painted plaster, curtain, worn wood). | PBRgen |
| 2 h | 4-6 hero props: hospital bed (if no gallery bed), IV stand, bedside table, case-file folder, oven (dream), chalkboard (dream). Remesh to a low budget, 1-2K textures. | Meshy (main), Tripo or Rodin as backup |
| 0.5 h | Case-file photos, a poster, a window backdrop image. | fal (pick a model whose page says commercial use) |
| 1.5 h | Lighting states (calm, uneasy, threatening) and the dream transition. | Environment Light Rig, Customizable Light, Post Process device, Post Process Volume |
| 1 h | Patient: a Fortnite NPC with a lying idle, or a static lying figure. | NPC Spawner plus play_animation_controller, or Meshy rig and pose |
| 0.5 h | Log every generated asset with its license in `docs/assets.md`. | |

**Specific UEFN features:**

- **Room:** Environment Light Rig for sky light, exposure, height fog and color grading
  ([lighting guide](https://dev.epicgames.com/documentation/en-us/fortnite/lighting-and-lumen-quick-start-guide-in-unreal-editor-for-fortnite));
  Customizable Light devices for practical lamps; one unbound Post Process Volume for the base
  grade (slight desaturation, soft vignette).
- **Escalation, 3 stages** (all switched from Verse with verified API calls):
  1. *Calm:* warm lamp on, soft window light, low fog, no extra post process.
  2. *Uneasy:* lamp dimmed with `customizable_light_device.DimLight`, a Post Process device
     preset such as *Desolate* or *Vignette* blended in with `BlendInForAll`, a few props moved or
     shown with `creative_prop.MoveTo/Show` (an extra chair facing the bed, the door ajar).
  3. *Threatening:* lamp off (`TurnOff`), cold light only, a darker preset (*Horror Movie*,
     *Dark*), a silhouette figure prop shown at the end of the corridor.
  Sources: [customizable_light_device](https://dev.epicgames.com/documentation/es-es/uefn/verse-api/fortnitedotcom/devices/customizable_light_device),
  [post_process_device](https://dev.epicgames.com/documentation/en-us/fortnite/verse-api/fortnitedotcom/devices/post_process_device),
  [Post Process device effects](https://dev.epicgames.com/documentation/en-us/fortnite/using-post-processing-devices-in-fortnite-creative),
  [creative_prop](https://dev.epicgames.com/documentation/en-us/fortnite/verse-api/fortnitedotcom/devices/creative_prop).
  Keep the horror mild: Epic's Developer Rules (as quoted in search results; the page blocked
  fetching, so **partly unverified**) allow horror themes only if not intense or sustained
  ([Developer Rules](https://www.fortnite.com/news/fortnite-island-creator-rules?lang=en-US)).
- **Dream fuzz transition (about 3 s):**
  1. Verse calls `BlendInForAll` on a Post Process device set to *Simple Blur* (or *Radial
     Blur*), blend-in duration about 1.5 s, set in the editor.
  2. At full blur, Verse hides the room's detail props (`creative_prop.Hide`) and shows the
     dream's 2-3 silhouette props (oven, counter, shop window), and switches the lamp to the
     dream's accent color.
  3. A second Post Process device with a softer look (*Happy Place*, *Film Warm*, or
     *Vignette*) blends in, then the blur blends out with `BlendOutForAll`. The room shape stays,
     so it reads as "the same room, now a bakery".
  4. Optional, **unverified in UEFN**: a custom post-process material (soft blur plus
     dithered edges plus accent tint) on a Post Process Volume, driven by a Material Parameter
     Collection keyed in a Level Sequence and played with `cinematic_sequence_device.Play` /
     `PlayReverse`. Better looking, but test it first.

---

## 1. UEFN rendering tools for the dream transition

### Post Process Volume

- Post Process Volumes are supported in UEFN. Epic's tutorial uses Infinite Extent (Unbound),
  Priority, Color Grading (gamma, RGB/Y), Exposure Compensation, Chromatic Aberration, Vignette
  Intensity and Post Process Materials
  ([intro to post processing](https://dev.epicgames.com/documentation/en-us/fortnite/intro-to-postprocessing-in-unreal-editor-for-fortnite)).
- The same page warns that "not all devices support all features and post effects", without a
  list. **Unverified:** depth of field, bloom, film grain and LUTs in a volume. Epic's lighting
  guide says bloom, lens flare and film grain come through the Environment Light Rig's Lumen
  Exposure and Color Grading parts
  ([lighting guide](https://dev.epicgames.com/documentation/en-us/fortnite/lighting-and-lumen-quick-start-guide-in-unreal-editor-for-fortnite)).
- **Custom post-process materials are allowed.** Set the material domain to Post Process and
  add it under Rendering Features > Post Process Materials on the volume
  ([intro to post processing](https://dev.epicgames.com/documentation/en-us/fortnite/intro-to-postprocessing-in-unreal-editor-for-fortnite)).
  Limits reported by creators (forum, **unverified**): no Custom (HLSL) nodes
  ([forum](https://forums.unrealengine.com/t/uefn-customnode/1159025)), some custom effects
  rejected ([forum](https://forums.unrealengine.com/t/post-process-thermal-weapons-fish-work-but-custom-pp-thermal-effect-not-allowed/2138140)),
  and post process behaving differently in edit sessions than in published islands
  ([forum](https://forums.unrealengine.com/t/post-process-volume-device-not-working-correctly-in-private-sessions/2607011)).
  Material budget: no more than 500 instructions per material
  ([Fortnite-ready assets](https://dev.epicgames.com/documentation/fortnite/fortniteready-assets-best-practices-in-fortnite?lang=en-US)).
- **Runtime control of a volume from Verse:** I found no Verse API for a Post Process Volume's
  settings or blend weight (**unverified**; a creator asked and the thread is unresolved:
  [forum](https://forums.unrealengine.com/t/how-do-i-reference-a-post-process-volume-in-verse/1619478)).
  Plan to switch the look with the Post Process device and props instead, or test whether a
  Level Sequence can key a Material Parameter Collection (a standard Unreal pattern,
  [forum](https://forums.unrealengine.com/t/how-to-edit-post-process-settings-in-runtime-blueprint/489199/7);
  **unverified in UEFN**).

### Post Process device (the runtime switch)

- 33 built-in effects, including Dark, Film Noir, Film Warm, Happy Place, Sepia, Spooky, Horror
  Movie, Desolate, Halftone, CCTV, VHSfilter, Vignette, Radial Blur, Simple Blur, Frost, Rain
  and Heavy Linework. Options: Effect Duration, Priority, Starting Strength, Blend In Strength,
  Blend In Duration, Blend Out Duration, Applies to Team/Class. World setting Camera Filter must
  be Default
  ([device docs](https://dev.epicgames.com/documentation/en-us/fortnite/using-post-processing-devices-in-fortnite-creative)).
- **Verse:** `BlendIn`, `BlendInForAll`, `BlendOut`, `BlendOutForAll`, `Enable`, `Disable`,
  `Reset`, `ResetForAll`, plus `BlendingInCompleteEvent` / `BlendingOutCompleteEvent`. No Verse
  call picks the effect or sets strength or duration; those are editor settings, so use one
  device per look
  ([Verse API](https://dev.epicgames.com/documentation/en-us/fortnite/verse-api/fortnitedotcom/devices/post_process_device)).
- No custom materials on the device: creators report only Epic's presets work
  ([forum](https://forums.unrealengine.com/t/post-process-device/2434733), **unverified**).
- Known bugs (forum, **unverified**): effects not updating after round 1 in round-based games
  ([forum](https://forums.unrealengine.com/t/post-process-device-bugged-in-round-based-maps/2694175)).
  Our game is one round, so low risk.

### Lighting, fog and atmosphere

- **Environment Light Rig:** edits DirectionalLight, SkyAtmosphere, SkyLight,
  ExponentialHeightFog, Lumen Exposure, Basic Exposure and Color Gradient. Lumen is on by
  default but needs High or Epic Global Illumination; low-end platforms get no dynamic GI. Do not
  light only with point/spot/rect lights, or the island can render black on most platforms
  ([lighting guide](https://dev.epicgames.com/documentation/en-us/fortnite/lighting-and-lumen-quick-start-guide-in-unreal-editor-for-fortnite)).
  **Unverified:** any Verse or event control of the rig at runtime.
- **Day Sequence device:** sun, sky light, sky, clouds and fog (density, color, height falloff,
  max opacity, volumetric scattering). It can be limited to a trigger volume with a blending
  distance, has Priority, and has a Fade Speed used with Fade In / Fade Out functions
  ([Day Sequence docs](https://dev.epicgames.com/documentation/en-us/uefn/using-day-sequence-devices-in-unreal-editor-for-fortnite)).
  Epic staff say the Day Sequence device and the Environment Light Rig are meant for separate
  scenarios, and fog from the rig overrides the device
  ([forum](https://forums.unrealengine.com/t/fog-in-uefn/2538067)). Pick one per area: the rig
  for the indoor ward. A volume-scoped Day Sequence could make "walk into a foggier corridor"
  zones. **Unverified:** a Verse API for it.
- **Customizable Light device:** color and brightness change in response to events; Verse has
  `TurnOn`, `TurnOff`, `Toggle`, `DimLight`, `UndimLight`, `Reset`, `Enable`, `Disable`
  ([Verse API](https://dev.epicgames.com/documentation/es-es/uefn/verse-api/fortnitedotcom/devices/customizable_light_device)).
  This is the most reliable runtime lighting control found.
- **Scene Graph lights:** `light_component` has `Enable`/`Disable`, `ColorFilter`,
  `DiffuseScale`, `SpecularScale`, `CastShadows`
  ([Verse API](https://dev.epicgames.com/documentation/en-us/fortnite/verse-api/versedotorg/scenegraph/light_component)).
  **Unverified:** whether these fields can be changed at runtime.

### Niagara (particles)

- UEFN uses Niagara for custom VFX; not all effect nodes and emitter settings are available
  ([VFX docs](https://dev.epicgames.com/documentation/en-us/uefn/effects-and-particle-systems-in-unreal-editor-for-fortnite)).
  `particle_system_component` has Enabled, AutoPlay and AutoPlayInEditor
  ([component docs](https://dev.epicgames.com/documentation/en-us/uefn/particle-system-component-in-unreal-editor-for-fortnite)).
  Useful for dust motes in the calm room, drifting specks or flour in the dream.

### Materials

- `creative_prop` has `Hide`, `Show`, `SetMaterial` and `MoveTo` in Verse
  ([Verse API](https://dev.epicgames.com/documentation/en-us/fortnite/verse-api/fortnitedotcom/devices/creative_prop)).
  `SetMaterial` can swap a prop to a "dream" material (emissive, flat accent color) at runtime.
- Material parameters exposed to Verse through the asset digest work in some setups, but
  creators report silent failures and crashes with texture parameters
  ([forum](https://forums.unrealengine.com/t/connection-lost-when-changing-texture-material-parameter-from-verse/2099108),
  **unverified**). Prefer swapping whole materials with `SetMaterial`.
- **Unverified** (standard Unreal features, not found in UEFN docs): dithered opacity mask,
  fresnel and emissive nodes. Two-sided materials and "material effects" have UEFN pages
  ([materials landing page](https://dev.epicgames.com/documentation/en-us/uefn/materials-in-unreal-editor-for-fortnite)).

### Cameras (the "observe" view)

- **Cinematic Sequence device** (Verse): `Play`, `PlayReverse`, `Pause`, `Stop`, `TogglePause`,
  `GoToEndAndStop`, `SetPlaybackTime`, `SetPlayRate`, `GetSequenceLength`, `StoppedEvent`.
  The plain `Play()` overload only works with visibility set to Everyone
  ([Verse API](https://dev.epicgames.com/documentation/en-us/fortnite/verse-api/fortnitedotcom/devices/cinematic_sequence_device)).
  Best fit for the observe step, and for the dream transition if Sequencer can drive the look.
- **Fixed Point Camera device:** overrides the player camera, can hold still or rotate to keep a
  target in frame; FOV, pitch/yaw speed, distance and offsets
  ([docs](https://dev.epicgames.com/documentation/en-us/fortnite/using-fixed-point-camera-devices-in-fortnite-creative)).
  Good for a "standing over the bed" view while reading the case file.

## 2. Fortnite asset library

- Prefabs are ready-made structures; galleries are themed collections of pieces and props. In
  UEFN they are under All > Fortnite in the Content Browser
  ([prefabs and galleries](https://dev.epicgames.com/documentation/en-us/fortnite/using-prefabs-and-galleries-in-fortnite-creative)).
- The docs name no hospital, clinic, office, bakery or school themes. Closest themes listed:
  **Residential** galleries/prefabs ("homes and personal dwelling structures") and **Retail**
  galleries/prefabs ("shopping and restaurant structures")
  ([prefabs and galleries](https://dev.epicgames.com/documentation/en-us/fortnite/using-prefabs-and-galleries-in-fortnite-creative)).
- A third-party site reports the v41.30 **Shaken Sanctuary Secret Facility** and **Greenhouse**
  prefabs, including lab and medical areas
  ([theclick.gg](https://www.theclick.gg/fortnite-uefn-prefabs-and-galleries/), **unverified**).
  Search "Shaken Sanctuary" in the Content Browser on Day 1.
- **To check in the editor (unverified):** hospital beds, IV stands, desks and chalkboards in
  existing galleries. Search the Content Browser for "bed", "hospital", "medical", "desk",
  "school", "bakery", "oven", "counter". Gallery pieces carry Fortnite's own stylized look,
  which the primary style is built to blend with.
- **NPCs lying down:** no doc covers a lying or sleeping pose. Options:
  - NPC Spawner plus a custom animation played with `play_animation_controller` (`Play`,
    `PlayAndAwait`, with play rate and blend times). Fortnite characters use their own skeleton,
    so animations may need retargeting; the feature is Early Access
    ([NPC animations](https://dev.epicgames.com/documentation/en-us/uefn/using-the-npc-spawner-with-animations-in-unreal-editor-for-fortnite)).
  - Animation presets only need an Idle animation, so a lying "idle" could be the preset
    ([animation presets](https://dev.epicgames.com/documentation/en-us/uefn/animation-presets-in-unreal-editor-for-fortnite)).
  - Custom character: import an FBX skeletal mesh, wrap it in an Actor Blueprint, make an NPC
    Character Definition of type Custom
    ([character definitions](https://dev.epicgames.com/documentation/en-us/uefn/using-npc-character-definitions-in-unreal-editor-for-fortnite)).
  - Cheapest: a static, posed lying mesh in the bed. **Unverified:** whether the persona NPC
    (the LLM component) must sit on a spawned NPC, which would force the animated route. Check
    this alongside the Day 1 persona tests.

## 3. Art styles for a team with no artist

Scores: effort and risk for one person in ~1 day of art time; fit for calm-but-foreboding;
how the dream fuzz looks; how it survives Fortnite's look and asset rules.

| Style | Reference | Effort | Risk | Calm-but-foreboding fit | Dream fuzz | Survives Fortnite |
|---|---|---|---|---|---|---|
| **Soft liminal clinic, monochrome + one accent** (primary) | Liminal-space aesthetic: empty transitional places made uncanny by missing people and context ([Wikipedia](https://en.wikipedia.org/wiki/Liminal_space_(aesthetic))). Firewatch's bold, limited palettes from New Deal park posters ([Wikipedia](https://en.wikipedia.org/wiki/Firewatch)) | Low | Low | Very good: calm by default, threat by removing warmth | Blur, then the accent color floods the same room | Good: gallery props blend in after recoloring |
| **Silhouette and fog minimalism** (backup) | Limbo's monochrome look ([Wikipedia](https://en.wikipedia.org/wiki/Limbo_(video_game))); Inside's Playdead look, built with custom rendering ([Wikipedia](https://en.wikipedia.org/wiki/Inside_(video_game))) | Very low | Medium: readability, and "calm" is hard in the dark | Strong foreboding, weak calm | Natural: fog thickens, shapes swap | Good: few assets; watch low-end GI and mobile |
| **Stylized low-poly / flat-shaded** | Low poly as a minimal, non-photorealistic style ([Wikipedia](https://en.wikipedia.org/wiki/Low_poly)) | Medium: AI generators give dense meshes that need remeshing and flat materials | Medium: mixed sources look inconsistent | Good | Good: flat colors shift cleanly | Medium: clashes with Fortnite's own props and NPCs |
| **Painterly post-process** | Watercolor or painterly filters | Low if it worked | High: no Custom nodes in UEFN materials ([forum](https://forums.unrealengine.com/t/uefn-customnode/1159025)), PP quirks in published islands | Good | Excellent | Poor to medium: technical risk |
| **PS1-style (low-res textures, vertex wobble)** | Signalis-style retro horror ([Wikipedia](https://en.wikipedia.org/wiki/Signalis)) | Medium | High: vertex snapping needs custom material work; the *Pixelizer* and *VHSfilter* device presets are only an approximation ([device docs](https://dev.epicgames.com/documentation/en-us/fortnite/using-post-processing-devices-in-fortnite-creative)) | Leans horror more than calm | Okay | Medium |
| **Clay / miniature** | Harold Halibut: hand-made clay sets and puppets scanned with photogrammetry ([Wikipedia](https://en.wikipedia.org/wiki/Harold_Halibut)) | High: needs real craft or careful AI prompting | High | Good (cozy, then uncanny) | Okay | Medium |

Story reference: *To the Moon*, where two doctors work through a dying man's memories to grant
a wish ([Wikipedia](https://en.wikipedia.org/wiki/To_the_Moon_(video_game))), is the closest
shipped premise; useful for tone, not visuals.

## 4. Partner AI tools and UEFN import rules

Jam perks (all from the [jam page](https://itch.io/jam/2026-epic-ai-megajam)); limits from each
tool's own docs where I could reach them.

| Tool | Jam perk | Use it for | Limits and license |
|---|---|---|---|
| **Meshy** | 1 month Pro, 1,000 credits; credit card needed; redeem by Nov 17 | Main hero props (bed, IV stand, oven, chalkboard), maybe the patient figure | Pro license is "Private", full commercial use, you own the output ([pricing docs](https://docs.meshy.ai/en/webapp/pricing)). Text to 3D 20 credits (Meshy 6), Image to 3D 20-25, texturing 10, remesh and rigging free ([pricing docs](https://docs.meshy.ai/en/webapp/pricing)). Remesh to a target polycount, PBR maps, humanoid auto-rig, FBX export for Unreal; props 5,000-15,000 polys for PC ([game assets guide](https://docs.meshy.ai/en/webapp/guides/use-cases/game-assets)) |
| **Tripo** | 3,000 credits plus Pro, Nov 11-17 PST; redeem by Nov 16 | Second source for props; Smart Low Poly retopology | Claims Pro grants commercial rights; exports FBX, OBJ, GLB, USD, STL, 3MF; auto-rig ([Tripo blog](https://www.tripo3d.ai/blog/full-pipeline-rig-ready)). Pricing page blocked fetching, so license details **unverified** |
| **Hyper3D Rodin** | Rodin Business, 208 credits; redeem by Nov 16, expires Nov 20. Prize pool for teams that used Rodin | Hero props when Meshy struggles; clean topology claims | PBR materials, UVs, Smart Low-Poly, exports FBX/OBJ/GLB/GLTF/USDZ/STL; commercial use "depending on your plan and license" ([hyper3d.ai](https://hyper3d.ai)). Exact Business terms **unverified** |
| **PBRgen** | Free access plus credits, valid Nov 7-15 | Tiling floor, wall and fabric materials | Seamless PBR materials, 15+ maps, export single maps or GLB; commercial use only on a paid plan ([pbrgen.com](https://pbrgen.com)). Whether the jam credits count as a paid plan is **unverified**; ask or treat as non-commercial (fine for a jam entry, but list it) |
| **fal** | $30 credits, claim by Nov 30 | Case-file photos, posters, window backdrop, concept frames, texture source images | License depends on the model: FLUX.1 [schnell] page says commercial use ([fal](https://fal.ai/models/fal-ai/flux/schnell)); FLUX [dev] is under a non-commercial license ([VentureBeat](https://venturebeat.com/technology/new-years-ai-surprise-fal-releases-its-own-version-of-flux-2-image-generator)). Record the model per image |
| **Reallusion iClone** | Free iClone Personal, up to 30 exports | Low priority. Maybe one lying/breathing animation | Personal: 30 exports, 30 s per file; Character Creator is a paid plug-in; AI Studio exports for non-subscribers are for testing only; commercial terms point to "License Details" ([iClone download page](https://www.reallusion.com/iClone/download.html)). Fortnite skeleton retargeting adds risk |
| **Rokoko** | 1 month Rokoko Basic | Capture a short "lying, breathing, waking" clip from phone video | Free tier: video-to-motion under 15 s; Basic: unlimited video-to-motion; FBX export ([pricing](https://www.rokoko.com/ko/pricing), [Vision](https://rokoko.com/products/video)) |
| **WeLoveIndies** | Free non-commercial license for sound and music | Room tone, hum, heartbeat monitor, dream ambience | Commercial release would need a commercial license ([jam page](https://itch.io/jam/2026-epic-ai-megajam)) |

### UEFN import rules

- Formats: FBX, OBJ, USD, glTF/GLB for models; JPG, PNG, TGA, EXR and more for textures; WAV,
  OGG, FLAC for audio. Tick **Skeletal Mesh** on import for rigged meshes. You cannot import into
  the Epic or Fortnite folders
  ([importing assets](https://dev.epicgames.com/documentation/fortnite/importing-assets-in-unreal-editor-for-fortnite?lang=en-US)).
- Memory: publishing budget **300 MiB** per map, recalculated on every cook; all referenced
  assets count; textures must be power-of-two with mipmaps ("No Mipmaps" fails validation);
  lower Nanite **Keep Triangle Percent** on dense meshes
  ([memory management](https://dev.epicgames.com/documentation/en-us/fortnite/memory-management-in-unreal-editor-for-fortnite)).
- Assets: textures 2K or smaller, power of two; 512 for Switch/mobile; max 500 material
  instructions; 512-unit grid, centimeters, forward is +X
  ([Fortnite-ready assets](https://dev.epicgames.com/documentation/fortnite/fortniteready-assets-best-practices-in-fortnite?lang=en-US)).
- Nanite: no published triangle cap found. Creators report custom LODs being ignored in favor
  of Nanite after reimport ([forum](https://forums.unrealengine.com/t/lods-and-reimports-break-after-using-reimport-mesh/2746280),
  **unverified**). Remesh AI output before import anyway; it keeps memory down.
- Skeletal meshes and animation: UEFN has no preloaded skeletal meshes or animations; import
  your own ([mesh animations](https://dev.epicgames.com/documentation/fortnite/import-and-play-mesh-animations-in-unreal-editor-for-fortnite)).
  The Animated Mesh device plays FBX animations on skeletal meshes from device events
  ([Animated Mesh device](https://dev.epicgames.com/documentation/en-us/fortnite/using-animated-mesh-device-in-unreal-editor-for-fortnite)).
  Creators report a mesh made in meters ending up 100x off
  ([forum](https://forums.unrealengine.com/t/invisible-custom-npc-or-custom-npc-extremely-offset/2723942)).
- Content rules: no realistic violence or gore; horror allowed if not intense or sustained;
  IARC rating required on publish; no Epic or third-party IP without permission
  ([Developer Rules](https://www.fortnite.com/news/fortnite-island-creator-rules?lang=en-US),
  quoted from search results because the page blocked fetching, **partly unverified**;
  [IARC FAQ](https://dev.epicgames.com/documentation/fortnite/iarc-overview-and-faqs-in-fortnite-creative)).
  No Fortnite rule requiring AI disclosure was found.
- Jam rules: third-party assets are allowed with the right license and must be listed in the
  submission ([jam page](https://itch.io/jam/2026-epic-ai-megajam)). Log every AI-generated
  asset in `docs/assets.md` with the tool, model and license (for example "Meshy Pro, private
  license", "fal FLUX.1 schnell, commercial use").

## 5. Day 1 checks before committing to the style

1. Search the Content Browser for a bed, IV stand, desk, oven and chalkboard. If a hospital bed
   exists, skip generating one.
2. Place two Post Process devices (*Simple Blur*, *Film Warm*), blend them from Verse, and
   confirm they work in a **private version**, not only in the edit session.
3. Put a simple custom post-process material on an unbound volume and check it survives
   validation and publishing.
4. Try keying a Material Parameter Collection in a Level Sequence and playing it with the
   Cinematic Sequence device. If it works, use it for the dream fuzz; if not, use the devices.
5. Generate one Meshy prop, remesh it, import it, and check its memory cost in the Memory
   Snapshot tool before making the rest.
6. Check whether the persona NPC needs a spawned NPC, which decides how the patient lies down.
