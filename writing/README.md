# Writing

All the words in the *Wonderwell* jam slice, in the shape the Verse data needs. This is stream 2
in `docs/workstreams.md`. The text here was written by an AI agent (Claude) during the jam, from
`docs/design.md`.

The slice's client is **Des** (`des/`). Nell (`nell/`) was the paper-demo client and stays as
the worked example; both use the same headings. Thursday's chunk: both case files, both dream
1s and the shared prompts. Dreams 2 and 3, the cold open, the tutorial, the AI's lines and the
end card come Friday.

## Files

| File | What it is |
|---|---|
| `des/case-file.md` | Des's case file, with the footing-talk word list. Same headings as Nell's |
| `des/dream-1.md` | Des's dream 1, the assembly loop. Same headings as Nell's, plus `First Take State` |
| `prompts/client-personality-des-dream-1.md` | Des's dream-self personality for dream 1, with the stutter rule |
| `nell/case-file.md` | Nell's case file as the screen shows it, the entries the screen adds after each dream, the hidden fact sheet staged by dream, and the fact each dream reveals |
| `nell/dream-1.md` | Dream 1: loop beats, the observe replay, take beats and crisis beats with their log and context lines, the directing options, the three endings, the client's verdict lines and the director's lines |
| `prompts/client-personality-dream-1.md` | Nell's dream-self personality for `SetPersonality` in dream 1 |
| `prompts/verdict-rubric.md` | The silent verdict prompt that fills `take_score`, and the thresholds |
| `prompts/scene-update.md` | The `scene_update` action text: when and how to fill `Distress` and `LogLine` |
| `prompts/take-memory.md` | The silent prompt that fills `take_memory` and `client_state` |
| `prompts/context-lines.md` | Templates for the lines Verse sends at take start and around the verdict |

## The contract

Headings are stable. Text under them can be lifted unchanged. If a heading has to change, change
it here and tell the Verse stream.

Conventions:

- Text in backticks or a code fence is literal: copy it exactly. Prose around it is a note for
  us and is not game text.
- Lowercase ids with underscores (`cast_teddy`, `dir_d1_hint`, `nell_d1`) are stable keys.
  Case-file entries have ids too (`K-05`, `F1-02`, `U1-01`).
- `{Braces}` in a template are filled by Verse.
- A `Context` line is always addressed to the client as "you" and is sent as is.
- Log lines use the debugger format: `KEY field=value` parts joined with ` / `, keys in
  capitals. Prewritten beat lines carry their own `T` stamp. Verse stamps the live ones.

### nell/case-file.md

| Heading | Becomes |
|---|---|
| `Screen` > `Header`, `Personality`, `Likes`, `Dislikes`, `Key Moments`, `Loop Note` | The case-file view. One entry per list item, id first. `ANOMALY` is shown; the `→ Pays off` note is not |
| `Screen Unlocks` > `After Dream N` | Entries added to the screen when dream N resolves |
| `Full Fact Sheet` > `Stage N` | Hidden facts available once dream N has resolved (stage 0 from the start). Source for the software persona and for later personalities |
| `Dream Reveals` > `Dream N Reveal` | The fact dream N gives up, as a summary. The spoken version is in the dream file |

### nell/dream-1.md

| Heading | Becomes |
|---|---|
| `Observe Replay` | The replay script: `LOG` lines to the screen, `MURMUR` lines as the client's voice or text |
| `Take Beats` > `B0`-`B7` | Fixed beats: `After` (trigger), `Log`, `Context`, with variants keyed by option id |
| `Crisis Beats` > `C1`-`C3` | Scripted trouble: `Trigger`, `Log`, `Context`, and the escalation if ignored |
| `Directing Options` > `Casting`, `Scene Settings`, `Inject Items` | One block per option. The heading is the id. Fields: `Label`, `Class`, `Risky`, `Haze`, `Log`, `Context`. `Why` is a note |
| `Verdict Lines` > `Positive`, `Mixed`, `Negative` | The client's line per verdict |
| `Good Ending` > `Log`, `Reveal`, `Unlock` | Positive verdict sequence |
| `Bad Ending` > `Log`, `Line` | Negative verdict sequence |
| `Mixed Ending` > `Log` | Mixed verdict sequence |
| `Director Lines` | Prerecorded lines by id, grouped by when they play. Also the script for the audio stream |

Dreams 2 and 3 will use the same headings.

### prompts/

| File | Contract heading | Notes |
|---|---|---|
| `client-personality-dream-1.md` | `Identity` through `Rules` | The four sections together are the personality, headings included |
| `verdict-rubric.md` | `Prompt`, `Thresholds` | `Thresholds` is for Verse to recompute the verdict from the scores |
| `scene-update.md` | `Action Description`, `Field Descriptions` | `Examples` can be appended to the description if the model needs them |
| `take-memory.md` | `Prompt` | Each client's starting state is in its dream file, `First Take State` |
| `client-personality-des-dream-1.md` | `Identity` through `Rules` | As Nell's |
| `context-lines.md` | One heading per template | Send order is at the top of the file |

## Sizes

Each prompt is kept short for Flash-Lite and the persona character limit. Rough word counts:
personality about 570 (3,000 characters; trim the Knowledge list first if the limit bites),
verdict prompt about 400, `scene_update` description about 190, take-memory prompt about 210. A typical take-start context is 8 to 14 lines of under 25 words.

## Rules for new text

- Noir. Short, flat sentences. People state things and don't explain their feelings.
- Our own world: our own street names, brands and tunes. No echoes of a specific film.
- The director speaks before and after a take, never during one. Film references stay small.
- The client speaks only dialogue. Anything that happens goes in a log line.
- The log is flat and technical, and never comments on what it describes.
- Later stages of the fact sheet never leak into an earlier dream's prompts or options.
