# Day 1 tech spikes

Results for the technical risks in `design.md`, tested in the `MegaJam` project on Fortnite
43.00. Each spike ends with one of: **works**, **doesn't work**, or **fallback chosen**.
Test content lives in `MegaJam/Content/Spikes/` and the `Spikes` folder in the level outliner,
and comes out before the final build.

| # | Spike | Status |
|---|---|---|
| 1 | Structured verdict (`ai_session.Prompt` with `take_score`, then `take_memory`) | Built and compiled; needs a play session |
| 2 | Runtime context (`SetPersonality`, context line with `PromptToTalk`) | Built and compiled; needs a play session |
| 3 | `RegisterAction`: distress and `LogLine` | Built and compiled; needs a play session |
| 4 | In-world UMG screen | Not started |
| 5 | Art path test (3D blockout against 2D layers) | Waiting on the 2D style test images |
| 6 | Two personas in one channel | Not started |
| 7 | Private version code with a persona NPC | Not started |

## Test setup for spikes 1 to 3

- `Content/Spikes/spike_persona.verse` compiled with no errors or warnings on the first build,
  so these signatures from the 43.00 digest are right as written: `ai_session.Prompt(message,
  type)` returning `result(t, ai_error)`, `RegisterAction(prompt_binding_definition, logic, type,
  callback)` returning a `cancelable`, and response structs holding `int`, an enum, `message`,
  `[]message` and a nested struct. Whether the model fills them is the play-session question.
- `spike_client_behavior` (NPC behavior): voice channel setup, the required `scene_update`
  action, and a timestamped log line for every hear, say, action and prompt failure.
- `spike_menu` (device, opened with the button next to the spawn): six steps.
  1. Load the dream personality (`SetPersonality`)
  2. Start a take: a spoken context line (storm, roaring oven, the visitor is Teddy with Walt's
     apron)
  3. Verdict (`take_score`), with the time it took
  4. Take memory (`take_memory`)
  5. Recall check: asks the session who the visitor is, the weather, the oven's name and state,
     and what the visitor said aloud
  6. Clear history
- `Spikes/SpikeClientDefinition`: test client "Nell (spike)", `elmira_voice`, placeholder
  personality. The prompts in the Verse file are placeholders too; the real ones come from the
  writing stream.
- Verse classes in a subfolder get the asset path `/<guid>/_Verse.<Folder>-<class>` (here
  `_Verse.Spikes-spike_menu`), not `_Verse.<class>`.

### Play-session script

Results are read from the `spike_log` channel with `SessionToolset.GetVerseOutput`.

1. Menu step 1, then step 2. Nell should react to Teddy and the storm in one or two sentences,
   with no narration, and an `ACTION` line should appear in the log.
2. Talk to her by voice for four or five exchanges as Teddy: something specific (Walt's
   whistling, asking her to teach you again) and something to push on (the funeral morning).
   Watch for an `ACTION` line per reply and whether distress moves.
3. Step 5: does the recall list what was said by voice, and the storm, Teddy and the oven?
4. Step 3, then step 4: scores, verdict, hint, timing, and the memory summary.
5. Step 6, step 2, then say only something generic ("Don't be afraid, it'll be fine"), and run
   step 3 again. A fair judge scores this take low.

## Results

Filled in as each spike runs.

### First launch (one voice exchange, before the scripted run)

- The session launched from the agent (`StartSession`) and the client NPC set itself up: voice
  group, channel, and the required `scene_update` action all registered.
- **`RegisterAction` fires with a reply.** One spoken exchange produced one `ACTION` callback
  (`Distress=0`), in the same tick as `CommitSayEvent`. One sample only; reliability and whether
  distress tracks the scene still need the scripted run.
- **Timing, one sample:** the player stopped talking, 1.6 s later the client started speaking,
  and the line was committed 3.4 s after the player stopped.
- **Model-written text is redacted in the Verse log.** `Localize()` on the spoken line and on
  `LogLine` printed as `[Redacted] <number>`. Numbers and enums from the model print normally.
  So the agent can read scores, verdicts and counts from the log, but not the wording. The
  spike now shows the action line, verdict hint, memory and recall on screen (top left) for
  whoever is playing, and logs each text's length to show whether the string Verse gets is the
  real text or the redacted stand-in.
- **Open, and it matters for a fallback:** if Verse only ever gets the stand-in string, the
  "match the client's spoken line from `CommitSayEvent`" fallback for the verdict can't work,
  and nothing in the game may depend on reading model text as a string. Passing the `message`
  straight to UI (subtitles) did work in the pre-jam test, so showing `LogLine` on the screen
  should be fine.
