# Workstreams

How the jam build for *Dead Air* (see `design.md`) splits into streams that agents can run in
parallel. Written 2026-11-11, before the jam. Nothing here starts before **2026-11-12 00:00 EST**.

## The one hard constraint: the editor

Only one UEFN editor can serve MCP at a time, and all agents share it. Anything that needs the
editor (placing actors, building UMG widgets, compiling Verse, play sessions, publishing) is
**editor-bound** and runs one at a time, from the orchestrating session. Everything else works on
files and runs in parallel.

| Kind | Runs | Examples |
|---|---|---|
| **Offline** | In parallel, each in its own session and git worktree | Writing, Verse source, image and audio generation |
| **Editor-bound** | One at a time, in the main session | Spikes, UMG, level assembly, compile, publish |

Each offline stream owns its own folder, so two agents never edit the same files.

## Streams

### 1. Tech spikes (editor-bound, Day 1 first)

The Day 1 technical risks in `design.md`, in order: structured verdict, runtime context,
`RegisterAction` (distress and `LogLine`), the in-world UMG screen, the art path test, private
version code.

- **Owns:** a scratch area in the level, `MegaJam/Content/Spikes/`
- **Output:** a short results note per risk in `docs/spikes.md`: works, doesn't, fallback chosen
- **Blocks:** stream 4 (Verse systems) final shape, stream 5 (screen), stream 3's choice of path

### 2. Writing (offline)

All the words in the slice, written to the formats Verse will load.

- Nell's case file, with odd entries planted so dream 1's fact makes them click (the March 3
  cake, no whistling)
- Three dreams: each loop's beats, the prewritten log lines, the setting and item options with
  which ones are specific, near-misses or wrong, and the fact each dream reveals
- Persona prompts: the client's personality per dream (with the "never narrate aloud" rule), the
  verdict rubric prompt, the `scene_update` instructions
- Director lines (cold open, tutorial, between takes, the reaction at the end), the AI's log
  lines and voice line, the end card
- **Owns:** `writing/`
- **Needs:** nothing; can start at midnight
- **Feeds:** stream 4 (data), stream 6 (lines to record)

### 3. Art (offline generation, editor-bound import)

Day 1 is the path test (3D room against 2D layers); after that, production for the chosen path.

- 2D: style prompt and reference image, then the layers: back wall, junk pile, recliner with the
  client (plus breathing frames), desk, foreground clutter, posters, cold-open flyers and street
- 3D: gallery search list, Meshy props (junk electronics, ashtray, case files, recliner)
- **Owns:** `art/` (source images and models, LFS)
- **Costs money:** every fal and Meshy call is confirmed with Chip first (model and cost). Every
  asset is logged in `docs/assets.md` with tool, model and license.
- **Import** into UEFN is editor-bound and goes through the main session.

### 4. Verse systems (offline source, editor-bound compile)

- Take flow: case file, observe, direct, run, last line, verdict, next dream
- Client control: `SetPersonality` per dream, context lines, the `take_score` verdict, the
  `scene_update` action
- Haze controller (3 levels from distress, setup and clock), log feed, slate and room dimming
- Scripted ending: the AI break-in, the director's reaction, the end card
- Loads the writing from stream 2 as data, not hard-coded text
- **Owns:** `MegaJam/Content/Verse/` (one file per system)
- **Needs:** the persona API digest now; spike results to lock the verdict and action shapes
- **Compile and test** are editor-bound.

### 5. Screen UI (editor-bound)

The in-world UMG debug screen: case-file view, directing menu, log, vitals trace, slate.

- **Owns:** `MegaJam/Content/UI/`
- **Needs:** the in-world UMG spike; the Verse fields it binds to from stream 4
- An offline agent can draft the layout and the field list in `docs/` while it waits.

### 6. Audio (offline)

- Music and ambience: rain, room tone, a buzzing sign, the monitor hum, a calm and a tense bed
- SFX: slate, glitch, vitals beep, haze levels
- Director voice: recorded by Chip (preferred) or fal text-to-speech, from stream 2's lines
- **Owns:** `audio/`
- **Costs money and licenses:** as for art. WeLoveIndies is non-commercial; list it.

### 7. Level and cinematic assembly (editor-bound)

The room, lighting states, post-process devices for the haze and take start, the cold-open
sequence, placing the screen and client, hooking up devices to Verse.

- **Owns:** `MegaJam/Content/` level and sequences
- **Needs:** art, audio, screen, Verse

### 8. Ship (editor-bound at the end)

Private version code, the 30-60 s video (Chip records gameplay), `docs/devlog.md` entries per
day, `docs/assets.md` complete, README submission checklist.

## Dependencies

```
2 Writing ──────────────┬──> 4 Verse systems ──┐
1 Spikes ──> (choices) ─┤                      ├──> 7 Assembly ──> 8 Ship
                        ├──> 5 Screen UI ──────┤
3 Art (path test) ──────┴──> 3 Art production ─┤
2 Writing ──> 6 Audio ─────────────────────────┘
```

## Schedule

| Day | Parallel (offline) | Main session (editor) |
|---|---|---|
| **Thu Nov 12** | Writing: case file, dream 1, prompts. Art: 2D style test images. Verse: take flow skeleton. | Spikes 1-6 in order |
| **Fri Nov 13** | Writing: dreams 2-3, director and AI lines. Art: production for the chosen path. Audio: sourcing. Verse: verdict, haze, log. | Screen UI, dream 1 playable end to end |
| **Sat Nov 14** | Audio: director voice. Art: cold open. Verse: ending sequence. | Dreams 2-3 in, cold open, lighting states |
| **Sun Nov 15** | Devlog, assets list | Polish, private version code, video. **Deadline 5:59 PM PST.** |

Rule of thumb: by end of Friday, one dream is playable from start to verdict. Everything after
that is more content on a working loop.

## How agents run

- Each offline stream runs as its own session in its own git worktree and branch, opening a PR
  into `main` when a chunk is done. The orchestrating session reviews and merges.
- Offline agents never call the UEFN MCP server. If they need something in the editor, they ask
  the main session.
- Paid generation (fal, Meshy) only after Chip approves the model and cost.
- Every stream adds a line to that day's `devlog.md` entry for the Glass Box prize.
