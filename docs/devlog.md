# Dev Log

Needed for the Glass Box prize: show how the game was built, including how AI tools were used.

## Pre-jam setup (declared)

Everything below was made before the jam started (2026-11-12 00:00 EST). None of it is game
content for the entry. Anything from this list that ends up in the game is marked when it's
used.

### Tools and project setup

- **2026-11-08: Repo.** Set up the git repo, Git LFS, `.gitignore`, `.gitattributes` and
  README. Created the GitHub remote.
- **2026-11-08: Empty UEFN project.** Created the `MegaJam/` project from the Blank template
  (Fortnite 43.00). Not changed since.
- **2026-11-08: AI agent connected to UEFN.** Connected Claude Code (AI coding agent) to UEFN's
  built-in MCP server through `.mcp.json`, so the agent can place devices, edit assets, compile
  Verse and push changes to play sessions.
- **2026-11-08 to 2026-11-09: Agent skill.** Wrote a `uefn` skill for the agent: notes on how
  UEFN sessions work, helper scripts for calling the MCP server, Verse gotchas, and a recipe for
  LLM persona NPCs. It lives in the separate
  [agent-kit](https://github.com/infinitemonkey3/agent-kit) plugin repo (`skills/uefn`, merged in
  agent-kit#31), and this project loads it through `.claude/settings.json`.

### Experiments (scratch project, not part of the entry)

- **2026-11-08: Persona NPC test.** In a separate, git-ignored scratch project
  (`ConversationExploration/`), built a test LLM persona NPC to learn the Conversations feature:
  "Barnaby Wick", a lighthouse keeper. The agent made it through the MCP server. It has:
  - an NPC Character Definition with a Persona modifier, a personality prompt, the `terns_voice`
    voice and a name plate
  - a Verse NPC behavior (`persona_npc_behavior.verse`) that puts players and the NPC in a voice
    channel so players can talk to it, and shows its replies as subtitles
  - a Verse device (`persona_question_menu.verse`) with a button that opens a menu of preset
    questions, for players who can't use voice
- **Pre-jam code that may be reused:** the two Verse files above. Copies are kept as templates in
  agent-kit's `skills/uefn/templates/`. If they're used in the entry, the dev log will say so.

### Prompts

- The Barnaby personality prompt was written for the test only and won't be used in the entry.

### Design

- **2026-11-11: Game design.** After the theme reveal ("Director's Cut"), wrote the game concept
  and plan in [`design.md`](design.md) with the agent: a coma ward where the player directs
  patients' recurring dreams and slowly uncovers their own nightmare. A plan only; no game
  content was built before the jam.
- **2026-11-11: New frame story.** Later the same day, reworked the frame in `design.md` with
  the agent: a noir, cyberpunk back room where a failed dream designer and film lover hacks
  people out of looping dreams on cheap brain implants, with stolen debug software. The player
  is his assistant, and an AI from the premium world appears in the logs. Includes a draft
  cold-open narration and draft director lines (prompts and text only). The core loop and
  rubric didn't change.
- No other prompts, scripts or assets were made for the game before the jam.

## Day 1 (Nov 12)

- **How the day is run.** One Claude Code session acts as orchestrator: it drives the UEFN editor
  through MCP, one job at a time, and starts separate agent sessions for work that only touches
  files. Each of those works in its own git worktree and branch and opens a pull request, which
  the orchestrator reviews and Chip merges. A hold system (agent-kit) stops two sessions from
  using the editor or the same Verse files at once.
- **Offline sessions started:** writing (Nell's case file, dream 1, persona prompts), a 2D art
  style test plan (models, prompts and cost; nothing generated until Chip approves the spend),
  and the Verse take-flow skeleton.
- **Tech spikes 1 to 3 built** (`docs/spikes.md`): the agent wrote `spike_persona.verse`, a test
  client NPC and a step menu to check the structured verdict, runtime context and the
  `scene_update` action. It compiled on the first build. The voice-channel setup and the menu
  pattern are adapted from the two pre-jam Verse templates declared above. Results need a play
  session with a microphone.
- **First launch.** The agent started the play session itself. One spoken exchange showed the
  client answering in about 1.6 seconds and the `scene_update` action arriving with the reply.
  It also showed that anything the model writes is redacted in the Verse log, so the agent can
  read scores but not wording; the spike now puts results on screen for the human tester.
- **Spike 4 built: the in-world screen.** The agent made a UMG widget with Verse fields, placed
  it in the level as a Scene Graph entity, and wrote a device that updates it and listens for
  key input. Finding from Epic's docs: in-world widgets can't be clicked, so the debug screen
  will be display only, with input coming from keys or a screen-space menu. Getting the
  widget's fields to show up in Verse took some trial and error, recorded in `docs/spikes.md`.
- **Usage limit.** The first five-hour usage window ran out mid-morning and cut off the writing
  and Verse sessions partway through, with their files written but not committed. It happened
  again after they were resumed; the orchestrator opened the writing PR itself.
- **Art: 2D style test planned.** An agent session wrote `art/style-test/plan.md`: a "two-ink
  print" look with a fixed palette, fal models picked by price and license (Nano Banana 2.1 to
  generate and edit, Bria RMBG 2.0 for cutout alpha), every prompt written out, and a checklist
  for judging the result from the desk in UEFN. Nothing was generated until Chip approved the
  cost.
- **Art: style test generated.** After approval the agent ran the plan on fal: 3 style
  references, then a back wall, the client in her recliner and desk clutter, each drawn with the
  chosen reference fed in. 14 calls, about $0.74. Cutouts were made two ways (Bria, and a
  magenta-key script the agent wrote); the script's were cleaner.
- **Art: round 2 from Chip's notes.** Chip reviewed the images and asked for a monitor facing
  the player, a talking mouth and breathing chest for the client, genre film posters with
  invented titles, and more depth layers for the entry shot. The agent generated 14 more images
  (about $0.77) and cut the mouth into a 4-frame flipbook and the chest into an overlay, so the
  engine animates small pieces instead of swapping whole redrawn frames. All assets are logged
  in `docs/assets.md`.
