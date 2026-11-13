# Implementation plan: Wonderwell jam slice

Written 2026-11-12 (jam day 1, evening) while UEFN reinstalls. Builds on `design.md` (the Des
client and the jam slice), `spikes.md`, the art run log (`art/style-test/runs.md`: cold-open
layout, camera path, dream-transition masks, client overlays), `audio/narration/`,
`audio/sound-list.md` (on `feature/sound-list`) and the Verse skeleton on `main`
(`MegaJam/Content/Verse/`, not compiled yet). Deadline: **Sun 2026-11-15 5:59 PM PST**.

**Decisions made on Day 1 that this plan follows** (`design.md` is updated to match in the same
change):

- The room is **2D layers on planes**. All art so far is built that way (back wall, junk pile,
  recliner, desk, monitor, clutter, posters), so "light" in the room is blended overlay planes,
  not UEFN lights.
- The cold open **tracks** past the flyer to the Help Wanted sign on "That's not me" (Chip's
  camera path in `runs.md`) instead of a visual hard cut. The hard cut stays in the **sound**:
  the Wonderwell jingle stops dead on that line.
- **Take start** is movie night: house lights down (vignette overlay), a projector click
  (`SFX_Dream_Transition`), a light flickering up on the client (`T_FX_Spot_Recliner`), then the
  dream hum bed (`AMB_Dream_Hum`). No slate clap sound; the "Take N" slate stays on the screen.
- **Vitals:** the trace stays on the screen, silent. No vitals beep.
- The **harsh neon buzz belongs to the AI break-in** (`AMB_AI_NeonBuzz`), not the room.
- Des's latest writing (Gale Rider, the brann as a separate thread, the cape as his father's
  carrier's cloak, Ansel working for a better life) is on `main` (#15). `data_des.verse` is
  converted from it.

The order is cold open first, as asked, but the first thing built is the **game shell** that
the cold open runs inside, because every later piece hangs off it.

---

## 1. Game state management

### The shape: one owner, two levels of state machine

```
game_director (the only creative_device with a script)
  owns game_state  ── the single source of truth
  runs the macro flow, a straight script of <suspends> phase functions:

    Boot ─> PreRoll ─> ColdOpen ─> Room ─> Client ─> Ending ─> EndCard
                                            │
                                            └─ take_flow.Run(State)   the micro flow
                                                 CaseFile ─> Observe ─> Direct ─> RunTake
                                                 ─> LastLine ─> Verdict ─> Good / Retry / Finale
```

- **Macro flow** (`game_phase`): linear, plays once per session. It is a script, not a table of
  transitions: `RunPreRoll(State)`, then `RunColdOpen(State)`, and so on. A straight script is the
  easiest thing to read and debug in Verse, and nothing in the macro flow branches except "skip".
- **Micro flow** (`take_phase`): the loop that already exists in `take_flow.verse`. It is the
  only part that branches and repeats, so it keeps its explicit state machine.
- **Only `game_director` changes `game_state.Phase`.** Everything else (screen, haze, audio,
  client control) is called by the director or by `take_flow`, or listens to
  `game_state.PhaseChangedEvent`. No device runs its own `OnBegin` logic, which removes
  start-order bugs between devices.

### What lives in `game_state`

| Field | Type | Why it's here and not in a subsystem |
|---|---|---|
| `Player` | `?player` | The one player everything acts on (see "One player" below) |
| `Phase` | `game_phase` | Logged on every change; drives `PhaseChangedEvent` |
| `VoiceMode` | `voice_mode{Mic, Presets}` | Chosen in the pre-roll; changes how takes collect the player's lines |
| `DreamIndex`, `TakeNumber` | `int` | Moved out of `take_flow` so debug starts can seed them |
| `Facts` | `[]string` | Revealed facts; authored text, so strings are fine |
| `Memories` | `[]message` | Carried-forward `take_memory`, last 6. Moved out of `client_control` |
| `Feeling` | `?client_state` | Current emotional state |
| `TakeHistory` | `[]take_record` | One per take: dream, take number, verdict, scores, `client_state`. Feeds the screen's chart, the software's records and the end card |
| `FactStage` | `int` | 0-3: which stages of the hidden fact sheet the software may answer from. Rises when a dream resolves |
| `Listener` | `listener{Client, Software}` | Who hears the player right now (the conversation target). Changed only through the query key handler |
| `Flags` | `[]string` | One-off story flags (`ai_line_seen`, `tutorial_done`) |

`client_control` keeps only what is about the persona itself (the persona, the channel, the
action handle). This is a small refactor of the skeleton, done when it first compiles.

### One player

The game is a solo experience: set Island Settings max players to 1. The director takes the
first player from `GetPlayspace().GetPlayers()` (or waits on `PlayerAddedEvent`) and stores it.
Every device call that takes an `Agent` gets that player. If a second player ever joins, they
are ignored and logged, not crashed on.

### No persistence

A session runs once from the pre-roll to the end card. Leaving and rejoining starts over. No
save data, which is fine for a 15-20 minute slice and avoids the persistence API entirely.

### Debug starts: the biggest time saver

Every test costs a push (minutes). So `game_director` gets editables:

- `@editable StartAt:game_phase = game_phase.PreRoll`: start at `Room`, `Client` or `Ending`
  directly.
- `@editable StartDream:int = 0`: with `StartAt = Client`, start at dream 2 or 3, with
  `Facts` seeded from the earlier dreams' reveals and a placeholder `Feeling`.
- `@editable DevKeys:logic = false`: binds one key (Sprint, which the spike logs as working)
  to "skip the current phase" through a `SkipEvent` raced against every phase.

Every phase change prints `[game] PreRoll -> ColdOpen` on `dead_air_log`, so `GetVerseOutput`
shows where a session is without watching it.

### Skipping and racing

Each macro phase runs as `race: RunX(State); SkipEvent.Await()`. A phase must leave the world
consistent when cancelled (camera stacks popped, sequence stopped, post process blended out), so
each phase function has a matching `CleanupX()` that runs after the race either way.

---

## 2. Cold open (build first)

The player experience, in order (design "Pre-roll" and "Cold open", with Chip's camera path
replacing the visual hard cut; the jingle's stop keeps the cut in the sound):

| # | Beat | What the player sees and hears | Length |
|---|---|---|---|
| 1 | Spawn | Black. No HUD. Faint static | 1-2 s |
| 2 | NO SIGNAL | A test pattern on a dead broadcast, "NO SIGNAL", static hiss and a test tone (`AMB_No_Signal`) | until Start |
| 3 | Mic check | "Say something." A level meter or a "SIGNAL" light reacts when they talk. Choice: *Talk* or *Preset lines* | until chosen |
| 4 | Start | "Press [Jump] to start." Cut to black | 1 s |
| 5 | Poster | Fade in on "MAKE DREAMS HAPPEN" with the Wonderwell jingle; drift down to WONDERWELL. VO 01 (8.1 s) comes in about 3 s after the jingle | ~11 s |
| 6 | The track | The jingle **stops dead** as VO 02 "That's not me" (4.4 s) starts, about 11.5 s in; only street rain is left. The camera tracks right past the flyer to the Help Wanted sign | ~6 s |
| 7 | Street | VO 03 (6.8 s) over the peeling ad, warning sticker, the doorway figure | ~7 s |
| 8 | His room | Push into the back room: posters, recliner with Des, cables, monitor. Room rain (`AMB_Rain_Window`) takes over from street rain. Lands at the desk | ~5 s |
| 9 | Title and boot | The WONDERWELL title card, then the monitor flickers on, a boot chime, the screen boots | ~5 s |
| 10 | Hand-off | Tutorial VO 01 ("Got a looper in the chair...") and the Room phase begins | |

### How each piece is built

**The pre-roll rig (beats 1-4).**
- A small closed box away from the set, with a plane showing a test-pattern texture and a
  `gameplay_camera_fixed_point_device` aimed at it. A fixed camera on a textured plane gets
  grain and scanlines from a post-process device for free; a screen-space Verse UI would not.
- The test pattern is our own image (colour bars plus "NO SIGNAL" in the screen's type), made
  locally with a script, no paid generation. Log it in `assets.md`.
- Text on the rig ("Say something", the choice, "Press Jump") is a second in-world UMG widget
  (the same widget class as the debug screen, in a `Boot` mode), so it is one more Verse entity
  to set messages on, nothing new.
- Input: the screen spike's bindings. `Character.Crouch` = next, `Character.Jump` = confirm,
  pending the spike 4 play test. These go into one `input_router` used by the pre-roll, the
  directing menu and the dev skip.
- Mic check: subscribe to the client voice channel's `BeginBroadcastEvent()` (V:89) for the
  player. It is a "they spoke" signal, not a level, so the meter is a light that pulses while
  `IsMemberSpeaking[Player]` holds. **Unverified:** whether a player broadcasts on a channel
  whose only other member is an NPC that isn't their conversation target yet. Fallback: no
  meter, just the choice and a line telling them to enable voice chat.
- Presets mode is recorded in `game_state.VoiceMode`. What it does in a take (a short menu of
  prewritten player lines, sent to the client as "The visitor says: ...") is milestone 5.
- Ambience: `audio_player_device` for `AMB_No_Signal`, started here, stopped at beat 4.

**The cinematic (beats 5-8).** One Level Sequence on one `cinematic_sequence_device`:
- Camera cuts and the drift, track and push are keyframed in Sequencer, following the framing
  table in `art/style-test/runs.md` ("Cold-open camera path"). The street wall, poster, flyer,
  sign and cables are 2D planes at the sizes in "Cold-open layout: a row".
- The three VO WAVs (`audio/narration/VO_Director_ColdOpen_01..03.wav`) and the Wonderwell
  jingle sit on audio tracks in the sequence, so the jingle's cut lands exactly on VO 02 and both
  stay in sync with the camera (timings in `audio/sound-list.md`, "Jingle sync"). Street rain
  (`AMB_Street_Rain`) and, for beat 8, room rain are audio tracks too. No buzzing sign: that
  sound is the AI's. The jingle is AAC from the model and needs converting to WAV first.
- Verse calls `Play(Player)` and awaits `StoppedEvent`. Settings to set on the device: visible to
  the instigator, hide HUD, disable movement for the sequence.
- **No pop at the end.** The sequence's last camera frame equals the desk camera's transform,
  and Verse adds the desk camera (`gameplay_camera_first_person_device` or fixed point, per the
  art path) to the player before the sequence ends. Test this hand-off first; it's the most
  likely thing to look broken.
- The player is teleported to the desk spot (`fort_character.TeleportTo`) during the black at
  beat 4, so they are already in place.

**The boot (beats 9-10).** The title card, then the debug screen in `Boot` mode: a short
fake boot log appended line by line, then `VO_Director_Tutorial_01`. The screen is the same
entity the whole game uses, so the first thing the player looks at is the interface.

### Cold-open done when

A launched session goes: black, NO SIGNAL, mic light reacts to speech, the choice, Start, the
sequence with all three lines in sync, lands at the desk with no camera pop, the title card shows and the screen boots, the
tutorial line plays, and the log shows `[game] Boot -> PreRoll -> ColdOpen -> Room`. With
`StartAt = Room` the session skips straight to the desk.

### Cold-open open questions

1. Does the cinematic sequence device's "disable movement / hide HUD" restore cleanly, or does
   Verse need a `hud_controller_device` and a `movement_modulator_device` of its own?
2. Do in-world widgets render during a cinematic camera? (The boot happens after the sequence,
   so only matters if the monitor should glow in beat 8.)
3. Audio tracks in a UEFN Level Sequence: confirm they play in a private version. Fallback: an
   `audio_player_device` per line started from Verse at fixed times
   (`audio_player_device` has no finished event, so durations are hard-coded either way).

---

## 2b. Asking the software (the case-fact query)

The player holds a key and asks the debug software out loud about something the dream mentioned
("Gale Rider", "brann", "Dad's line"). The software answers in a terse record voice from
the **full fact sheet**, which holds more than the screen shows, and the answer is also written
to the log. Design: "Bonus: ask the software". It turns listening closely into investigating,
and found facts feed the **Backstory** criterion. The writing already supports it:
`writing/des/case-file.md` has `Full Fact Sheet` > `Stage 0`-`Stage 3`.

**How it's built**

- **A second persona, `software`**, on its own NPC (hidden, no body; a spawner off-set). It uses
  the same voice channel as the client, with a narrator voice (`terns_voice`, "Narrator, Low,
  Warm", or a flatter one) so it never sounds like the client.
- **Its personality is its records**, rebuilt with `SetPersonality` whenever `FactStage` rises
  or a take ends:
  - the rules: answer only from these records, in the form "Query: X. N records. ...", say
    "No record." for anything not in them, never guess
  - fact-sheet stages 0 to `FactStage` (later stages never leak in)
  - the session records: `Memories` and a line per `TakeHistory` entry ("Take 2: negative,
    trust 1 fear 3"), so "what did I say last time?" and "how is he doing?" work.
    `Memories` are model-written `message`s; they go in with `Join`, never through strings.
- **Who hears the player** (`Listener`): holding the query key calls
  `Player.SetConversationTarget(SoftwarePersona, Channel)`; letting go sets it back to the
  client. One `listener_switch` owns this, so nothing else calls `SetConversationTarget`.
  During a take this reads as whispering to the operator.
- **The answer on screen:** subscribe to the software persona's `CommitSayEvent` and append the
  `message` to the log as is (no `Localize`, it's redacted anyway).
- **Keep it out of the client's head.** Personas in one channel share conversation history
  (`GetAISession` comment, UE:83-85), so the client may "hear" the query. Two options, to settle
  in spike 6: give the software its own voice channel and switch the player's target between
  the two channels, or accept it and tell the client's personality to ignore lines starting
  "Query:". The first is cleaner; it's the recommendation if a player can sit in two channels.
- **Input:** the query key needs a hold (start and end). `input_events` has
  `BeginDetectEvent` and `EndDetectEvent` (V:2744, V:2755), so a held action works; which key
  is free in first person comes from the spike 4 input log.

**Where it sits in the flow**

- Available in `Room` and `Client` phases, in every take phase. Disabled in the pre-roll, cold
  open and ending (`listener_switch` checks `game_state.Phase`).
- The tutorial gets one line teaching it once the first dream's replay has dropped an
  unexplained reference.
- Dream 1's good ending raises `FactStage` to 1 and refreshes the software's records, so a fact
  the dream just revealed becomes askable ("corrupted records" unlocking).

**Risks:** spike 6 (two personas in one channel, `SetConversationTarget` switching) hasn't run.
Flash-Lite may invent records: the fact sheets are short and concrete for this reason, and a
test pass asks it ten things that aren't in the sheet. If spike 6 fails, the fallback is a
screen-only search: the player picks a keyword from a menu and Verse prints the matching
prewritten record (no LLM).

---

## 3. Systems, and how they hang together

| System | File | Owns | Called by |
|---|---|---|---|
| Game director | `game_director.verse` | `game_state`, macro phases, device editables, debug starts | its own `OnBegin` |
| Game state | `game_state.verse` | the fields above, `PhaseChangedEvent`, `take_record` | everyone reads |
| Input router | `input_router.verse` | the player's input mappings; `NextEvent`, `ConfirmEvent`, `SkipEvent` | director, take flow |
| Pre-roll and cold open | `cold_open.verse` | beats 1-10 | director |
| Take flow | `take_flow.verse` (exists) | the micro state machine, now a class taking `game_state`; the reply-driven beat script, crisis beats, verdict recompute, director-line triggers (section 3b) | director |
| Client control | `client_control.verse` (exists) | the persona | take flow |
| Screen | `debug_screen.verse` (seam exists) + `screen_view.verse` | modes: Boot, CaseFile, Log, Menu, Slate, Vitals (a silent trace), Chart, EndCard | director, take flow |
| Client puppet | `client_puppet.verse` | The 2D client on the recliner: Des's overlay plane, the mouth flipbook (4 cells) driven by the persona's `StartSayEvent` and `StopSayEvent`, the chest overlay's slow ~2% breathing scale. The persona NPC itself is hidden off-set | director, take flow |
| Room light | `room_light.verse` | Overlay planes, since the room is 2D: `T_FX_Vignette` for house lights down, `T_FX_Spot_Recliner` for light on the client (flicker for the projector start, tint per take), shown and hidden or swapped per colour | take flow, haze |
| Haze | `haze_controller.verse` (exists) | 3 post-process devices, the room-light overlays, the haze drone layers | take flow |
| Room audio | `room_audio.verse` | `audio_player_device`s for the loops (room rain, dream hum, haze drones, AI neon buzz) and one-shots (dream transition, glitches, verdict stings); starting and stopping them by phase | director, take flow, finale |
| Director voice | `director_voice.verse` (exists) | `audio_player_device` per line id, with known durations | director, take flow |
| Software query | `software_query.verse` | the software persona's records (`SetPersonality` per stage), `listener_switch` (the only `SetConversationTarget` caller), answers to the log | director, take flow (on stage changes) |
| Ending | `finale.verse` | the scripted break-in after dream 3, the end card | director |
| Dream data | `data_des.verse` | Des's case file and three dreams, converted from `writing/des/` | take flow |

Device references all live on `game_director` as `@editable`s (spawner, cinematic device,
cameras, post-process devices, overlay props, audio players), and are handed to the systems that
use them.
One place to wire in the editor, one place to check when something isn't hooked up.

---

## 3b. The take, as the Des writing defines it

`writing/des/dream-1.md` (on `main`, #15) is more specific than the skeleton in
`take_flow.verse`, and changes how a take runs. The skeleton is updated to this in milestone 4.

**Beats advance on client replies, not on a clock.** A take is a short script: `B0 Open` at
take start, then `B1`-`B5` after client replies 1-5, then `B6 Cut` after the client answers the
last line. Verse counts replies with the persona's `CommitSayEvent`. Each beat is a log line for
the screen and a context line for the client, with **variants keyed by the chosen option ids**
(`B1` has a `lights_lamp` variant). The skeleton's `RunClock` timer goes; a long silence
timeout (about 40 s with no player line) stays as a safety net that moves to the next beat.

**Crisis beats** (`C1 Staying`, `C2 Lamp Light`) trigger on option ids: `C1` replaces `B2` when
the player cast `cast_father`; `C2` plays with `B3` when `lights_lamp` or `item_brann` is chosen.
Each has a "turns dark" or "if ignored" follow-up.

**Conditions on what the model wrote become numbers.** Verse only ever gets model text as a
redacted string (spikes.md), so it can't check "the hall has joined in" or "the visitor promised
to stay". Each such condition is read from `scene_update.Distress` instead:

| Writing says | Verse checks |
|---|---|
| `B3`/`B4`: skip the laugh if the hall is with him | `Distress <= 1` on the last reply |
| `C2`: if ignored for two replies | `Distress >= 2` on both replies after `C2` |
| `C1`: turns dark if the visitor promises to stay | The client's own context handles the turn; Verse shows the dark log when `Distress = 3` after `C1` |

**How a beat's context reaches the client is open.** Sending it with `PromptToTalk` makes the
client speak again right after its own reply, which crowds the player out. Recommendation, to
test in the spike 1-3 session: send beat context silently with `ai_session.Prompt` and a
one-field acknowledgement struct, so it lands in the history without speech. Unverified that a
`Prompt`'s instructions stay in the history. Fallback: `PromptToTalk` the beat only after the
player has been quiet for about 6 s, which suits beats like `B2 Waiting`.

**Context lines follow `writing/prompts/context-lines.md`'s send order:** Take Start (with the
dream's `{Time}` and `{Place}`), Role, each Setting, each Item, State, Memory Intro, each
Memory, Memory Visitor, Authored Facts Win, Opening Cue. This replaces the skeleton's
hand-written lines in `client_control.StartTake`.

**Haze inputs from the writing:**
- setup: the sum of the chosen options' `Haze` values, capped at 2 (the skeleton takes the
  highest; change it)
- distress: live, as before
- clock: driven by beats (`B3` = 1, `B4` = 2, `B5` = 3) instead of time, still ignored while
  distress is 0
- start: the carried-forward fear, as before

**Verse recomputes the verdict from the scores** with the rubric's `Thresholds`: positive if
the total is 8 or more and Backstory and Personality are each at least 2; negative if the total
is 4 or less; mixed otherwise. The model's own `Verdict` field is logged but not trusted. The
weakest criterion (ties: Backstory, Personality, Environment, Common sense) picks the
director's mixed line.

**Director lines by trigger** (ids from the dream file):

| When | Line |
|---|---|
| Case file | `dir_d1_intro`, then `dir_d1_file` |
| After the replay | `dir_d1_hint` |
| Menu open, then confirm | `dir_d1_direct`, then `dir_d1_roll` |
| A `Risky: yes` option confirmed in the menu | `dir_d1_risky`, once per take |
| Negative verdict | `dir_d1_bad` the first time in this dream, `dir_d1_bad_2` after (counted from `TakeHistory`) |
| Mixed verdict | `dir_d1_mixed_<weakest>` |
| Positive verdict | `dir_d1_good`, `dir_d1_fact`, `dir_d1_next` |

**Endings:** good: the log, the client says `Good Ending Reveal` exactly (the Reveal template),
the unlock log, the screen adds `U1-01`-`U1-05`, `FactStage` rises. Bad: the log, then the client
says `Bad Ending Line`. Mixed: the log only. The client's first state in a dream with no takes
yet comes from the dream file's `First Take State`.

**Data shapes this needs** (`dream_data.verse`, M4): options gain `Class`, `Risky` and a
numeric `Haze`; a `take_beat` (id, after-reply, log, context, variants by option id); a
`crisis_beat` (trigger option ids, replaces or joins a beat, log, context, dark log and
context, escalation rule); the dream gains `Time`, `Place`, `FirstTakeState`, the reveal line,
the unlock log and entries, the bad-ending line, the mixed-ending log and its director line
ids. Option groups use the writing's elements (`Lighting`, `Hall`), one value each, as the menu
already does.

**Murmurs in the replay:** a voiced "say exactly" murmur costs 2-3 s per line (spikes.md
timing) and may be paraphrased. Show each `MURMUR` on the screen as the client's subtitle line;
voice it only if a play test shows it keeps pace.

---

## 4. Milestones

Each milestone ends in a launched session that shows it working, and a PR.

| # | Milestone | Done when | Editor-bound part | Offline part (can start now) |
|---|---|---|---|---|
| **0** | Editor back on `main` | Verse on `main` compiles clean | Merge `main` into the editor's checkout, `BuildAll`, fix | none |
| **1** | Game shell | `game_director` runs empty phases with logs; `StartAt` works | Place the device | `game_state`, `game_director`, `input_router`; take flow as a class |
| **2** | Cold open | "Cold-open done when" above | Pre-roll rig, Level Sequence, cameras, VO tracks, boot screen | `cold_open.verse`; the test-pattern image |
| **3** | Screen wired | Spike 4 result in; `screen_view` shows case file, log, menu, slate; input picks a setup | The final UMG widget with every field | `screen_view.verse` against the field list |
| **4** | Dream 1 end to end (**Friday goal**) | Des dream 1: case file, replay, direct, a take whose beats advance on his replies (with `C1` and `C2`), last line, verdict recomputed from scores, good, mixed and bad endings with their director lines, with Des on the recliner and his mouth moving when he talks | Hidden client NPC (voice for a 13-year-old, from the voice test), the 2D client planes | the new data shapes and `data_des.verse` from `writing/des/` (section 3b); beat-driven take flow; context lines in the writing's order; real prompts from `writing/prompts/`; `client_puppet.verse`. **Needs art first:** the client overlays drawn so far are Nell; Des needs an empty recliner, his overlay, and his own mouth and chest pieces (paid, Chip approves) |
| **5** | Danger and feel | Take start (house lights down, projector click, light flickers up on Des, dream hum); haze at 3 levels (post process, overlays, drones); the screen's "Take N" slate; the silent vitals trace; presets mode for no-mic players | Post-process devices, overlay planes, audio players | `room_light.verse`, `room_audio.verse`, haze hookup; presets menu |
| **5b** | Ask the software | Holding the query key asks the software; it answers from stages 0..`FactStage` and session records, says "No record." otherwise; the answer shows in the log; the client doesn't react to queries | Software NPC definition and spawner, voice | `software_query.verse`; fact sheets from `writing/des/case-file.md` as data |
| **6** | Dreams 2-3 and the ending | Full slice plays through; dream 3's break-in (with `AMB_AI_NeonBuzz` and the corruption sounds), director's reaction, end card | Ending assets | data for dreams 2-3 (Friday's writing); `finale.verse` |
| **7** | Ship (Sunday) | Private version code, video, devlog, assets list | Publish, record | docs |

Rule of thumb from `workstreams.md` still holds: if milestone 4 isn't done by end of Friday,
cut from 5 and 6 (presets mode, the AI's voice line, dream 2's extras), not from the loop.

5b depends on spike 6, which hasn't run. The design marks it "after the slice works", so if
spike 6 fails or Saturday runs short, it drops to the screen-only search fallback, or out. The
`game_state` fields for it (`FactStage`, `Listener`) go in at milestone 1 either way; they cost
nothing and keep `SetConversationTarget` in one place from the start.

---

## 5. Risks that change this plan

| Risk | Hits | If it fails |
|---|---|---|
| Spike 1-3 play test: verdict, context, `RegisterAction` in a real session | M4 | Fallbacks already in `client_control.verse` comments |
| Spike 4: in-world screen input and readability | M3 | Screen-space Verse UI over a fixed camera framing the monitor |
| Sequence-to-gameplay camera hand-off | M2 | End the sequence on black and fade up on the desk camera |
| 2D layers not yet tested in UEFN (alpha edges, lighting, parallax, blend modes for the overlays) | M2 room landing, M5 | Masked materials before translucent; one overlay plane per colour if runtime tint fails |
| No Des art for the recliner yet | M4 | Placeholder: the empty recliner with a silhouette plane |
| Jingle is AAC (`.m4a`), which UEFN doesn't import | M2 | Convert with ffmpeg or an audio editor |
| Read-only `.uasset` from LFS `lockable` (spikes.md) | every editor save | Chip's call on removing `lockable` from `.gitattributes` |
| A 13-year-old voice from the persona voice list | M4 | Pick the youngest-sounding voice; the stutter carries more than pitch |
| Spike 6: two personas, target switching, shared history | M5b | Separate channels; else the screen-only keyword search |
| Model text is redacted as a string | any logic on model text | Already designed around: only numbers and enums are branched on; the writing's text conditions map to `Distress` (section 3b) |
| Beat context without making the client speak twice | M4 | Silent `Prompt` if it stays in history; else `PromptToTalk` after a player silence |
