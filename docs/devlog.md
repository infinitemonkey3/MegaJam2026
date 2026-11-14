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
- **Des becomes the slice's client.** The writing session added Des Varro, a 13-year-old with a
  second-hand speech implant, as the main client: case file, dream 1 ("the assembly loop") and a
  personality with a stutter rule. Nell stayed as the worked example. Chip steered his details:
  his kids' show Gale Rider, and his father's carrier's cloak worn inside out as a cape.
- **Cold open built.**
  - The street art (the Wonderwell poster, a HELP WANTED sign, a flyer, the street wall,
    cables) was generated and cut out.
  - It was laid out in UEFN as a Level Sequence with a slow camera move.
  - The director's narration was generated with text-to-speech (fal, Gemini TTS, voice "Orus",
    which Chip chose from a six-voice audition).
  - A `game_director` Verse device runs the pre-roll, the cold open and the boot of the dream
    debugger.
- **Planning.** An implementation plan (`docs/implementation-plan.md`) was written and reviewed
  against the design. The take-flow Verse compiled clean on its first full build.
- **Clean-up.** The spike devices and Verse came out of the level once their answers were
  recorded.

## Day 2 (Nov 13)

- **Overnight: the cold open's words and the name.** Chip rewrote two lines of the director's
  narration ("people don't wake up" in place of "people get stuck", and "That's where you come
  in" over the HELP WANTED sign), and the game took the name **Wonderwell**. The overnight
  Verse session merged its work and handed over to the orchestrator before the usage window ran
  out again.
- **One thread.** In the morning Chip folded the day's work into one orchestrator session,
  starting from the hand-off between the cold open and the room: the room fades up from black
  and drifts forward onto the desk camera.
- **The room.** The 2D room layers (back wall, desk, monitor, recliner, floor) were placed in
  UEFN as flat cards and reframed from Chip's notes:
  - Chip placed and reframed the layers himself. The agent put his editor view through the
    desk camera so he could check them (a placed camera device turned out to be blocking it),
    and set the camera's field of view to 90.
  - The posters and some clutter were hidden. One clutter cutout showed cigarettes, which break
    the content guidelines, so it was deleted.
  - The desk was clipped on the right and both it and the back wall looked soft, so they were
    regenerated at 4K with the whole desk in frame, and the desk lamp came out. They still
    looked blurry in game; Chip found the fix: the UI texture group, which skips mipmaps.
  - The director's VO was too quiet, so every line was doubled in volume.
- **The dream debugger.** Chip described it: a terminal-like program, a cracked, unregistered
  copy of the Wonderwell Dream Debugger, naming the patient, with tabs for the case file and the
  dreams. First it was a widget behind the monitor's glass, cut out of the monitor art.
  In-world widgets can't be clicked, so Chip suggested the interactive part be a screen-space UI
  placed by projecting the monitor's corners from the world onto the screen. It took a few
  tries to stay locked to the monitor, and Chip turned the monitor to face the camera so the
  two match exactly. A screen-space frame couldn't match the perspective of the world one, so it
  was dropped and everything sits inside the glass.
  - Fonts: UEFN won't import `.ttf` or `.otf`, and Unreal's own fonts fail validation, so the
    text is Fortnite's NotoSans. The brand font only appears as an image.
  - The tabs could only be clicked on a hairline at their top and bottom edges, which Chip
    spotted from the hover glow. Fixed.
  - Late at night it got a branded title bar (a cloud dissolving into binary digits, drawn by a
    Python script, 50% thicker after a first look). The keyboard lost its cable and was
    recoloured to match the monitor, and everything was realigned after Chip moved the monitor.
- **First take, end to end.** Des's dream 1 played through: the replay, directing by clicks,
  talking to Des by voice, his live `scene_update` lines in the log, the verdict and a retry.
  Play testing drove most of the day's changes:
  - The log was unreadable as debugger codes, so it became plain prose.
  - Chip couldn't find how to talk back. The persona needs Fortnite's conversation prompt (a
    held key), and that HUD element had been hidden with the rest.
  - The persona called the player by his Fortnite outfit label ("Sergeant", "Tactical
    Tracker", "Stealth Specialist"). Every take now repeats a rule naming those labels.
  - Cast as Des's father, the player was greeted as a stranger: a one-off prompt was forgotten
    after one reply, so the take's setup went into the personality.
  - Des was obstinate and unrewarding to play against, so the personality now lets fitting help
    land.
  - The verdict prompt was moderated when written in character. A moderated verdict fell back
    to the mixed line ("There's something familiar about you"), which puzzled Chip. The prompt
    is now neutral, with one retry.
- **Nell becomes patient 1.** Chip judged an adult's grief less likely than a child's to trip
  moderation, so Nell became the first patient. Patients are data: one `@editable` switch on the
  director picks the client, the recliner art (one texture swapped on one card, Chip's idea)
  and the persona's voice. Nell also came across too severe at first, and was softened.
- **Pacing from play tests.** The log raced by and Chip lost the gist. His idea: feed her the
  replay's lines and let her tell them as something that happened to her ("I went into the
  bakery and that darned oven wouldn't light again"). Each beat now waits for CONTINUE, and the
  newest line is pinned to the top. Endings are told the same way:
  - A good ending has her name what the player did that turned it around (Chip's request).
  - A LAYER CLEARED banner lists the debugger's notes; she doesn't narrate those.
  - With settings and two items her opening stayed generic ("you're here early"), so the take
    became one role and one item, and her first line reacts to both.
  - Takes play as improv: "yes, and". Chip found he could describe actions as well as speak,
    and a take where he brought in a handyman went well.
- **The start screen** shows the Wonderwell title card, with PRESS ANY KEY moved down.
- **Nell's three dreams.** Chip noticed she got stuck on the dough for a long time, so takes got
  a rough run of events that advance with the clock. Dreams 2 and 3 were written, then reshaped
  from Chip's notes:
  - Dream 2 started as a surreal funeral morning. Chip found it played like dream 1 ("more bake
    the loaves") and asked that the surreal parts carry a core symbol. He then asked for
    something cute about dating. It became a date interview: young Nell quizzing Walt off her
    order pad.
  - Dream 1 became more surreal from his note: not normal baking problems but strange ones she
    is overwhelmed by, with the same faceless strangers outside who could help, and she's
    afraid to let them in.
  - Dream 3 is the quiet afternoon of March 3.
- **What's fun.** Chip: the fun is "a clear problem to address for the character and a range of
  reasonable approaches to it". Looked at as an improv prompt, choosing who to be was the
  hardest call and caused most bad takes. So each dream now assigns the player's role: who you
  are, what she wants, what's in the way. The director sends you in as that role in a
  prerecorded line. You are Teddy himself in dream 1, young Walt in dream 2 and Walt in dream 3.
- **The player's words carry forward.** The birthday cake the player names as young Walt in
  dream 2 is recorded by a silent prompt. It becomes the cake in dream 3, in her personality and
  on the case file. Chip: "That's the power of this."
- **Space made the character jump** audibly. A Player Movement Settings device sets jump
  velocity to 0, so Space can still drive the menus.

## Day 3 (Nov 14)

- **A file to learn.** The debugger became a spy's briefing:
  1. The patient's case file, with ATTACH TO DREAMER.
  2. Once attached, her recounting of the loop.
  3. Your role's file, with ENTER DREAM.

  The director names the patient and sends you in. His seven new lines were recorded in the
  same TTS voice, and a Verse `device_director_voice` plays them from audio player devices.
- **Turns, not a clock.** In play the timed beats made the client talk over the player, and she
  stalled on a question. Takes now move on only after the player has answered and she has
  finished replying. In dream 2 she leads her own questions, because a prompted question landed
  on top of the one she had just asked.
- **Dream 2 grows a game.**
  - It opens with three this-or-that guesses about Nell from her case file: cinnamon or lemon,
    rain or sunshine, flowers or good flour. Then come the real questions.
  - The first question, "where would you take me on a first date", was moderated in play. It
    became "how would we spend a Saturday afternoon".
  - Her last line is always the cake question, and the Saturday the player promises is carried
    into dream 3 too.
- **Title card.** Chip asked for the recliner's cable and the crowding lanterns to go, and for
  the title to stand out.
  - A Python script edits the two title layers: it clone-stamps the cable away, paints out the
    lanterns, draws a brick wall, and gives the wordmark a stroke, shadow and halo.
  - Two AI image edits (fal, Nano Banana 2.1) followed: one removed the recliner, and one added
    a figure on the street, head in his hands, with the dream rising from his head. Chip chose
    between two takes of the figure.
  - Only the edited regions are blended in, because the edits drifted elsewhere.
- **Dream 1 made concrete.** The surreal dough was hard to tackle in the abstract. Dream 1 is now
  a run of jobs, each with a hint in Teddy's brief:
  - fold the dough;
  - knock twice on Walt's oven door and say "Morning, old girl";
  - read out the regulars' orders;
  - at six o'clock, ask for the key and let the faceless helpers in.
- **Publish dry run.** The agent validated all 323 project assets, and checked every Verse API
  we use for experimental markers. Nothing blocks a publish. Max Players (16) needs to be 1, and
  only a real upload will prove the Scene Graph setting.
