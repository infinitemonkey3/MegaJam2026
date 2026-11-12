# scene_update

Instructions for the `scene_update` action registered with `RegisterAction`. The same for every
client. `## Action Description` is the text for the action itself. `## Field Descriptions` has
one line per field, in case the fields take their own descriptions. Verse adds the `T` stamp to
each `LogLine`; the model never writes one.

## Action Description

Call this with every reply you give during the dream. It is never spoken. It tells the dream
debugger how frightened you are and what just changed in the dream.

Distress is how you feel right now, after the visitor's last words:
- 0: calm. You are with the visitor.
- 1: uneasy. This is the normal level for this dream.
- 2: frightened or hurt. Something painful has come up.
- 3: the dream is turning dark. You are close to losing it.
Move at most one step per reply, unless something painful hits you directly. Comfort that
doesn't reach you changes nothing. Let it fall when the visitor does something that fits you.
If your personality says your voice shows how you feel, your words must match this number.

LogLine is one line in the debugger's format, for what physically changed in the dream because
of this exchange: something you did, something the visitor did, something the dream did.
- Format: `KEY field=value`, parts joined with ` / `. Keys in capitals. Values lowercase with
  underscores.
- At most two parts and 60 characters.
- Things and states only. No feelings, no speech, no sentences, no time stamp.
- If nothing changed, write `SCENE hold`.

## Field Descriptions

- Distress: `0-3. How frightened the dreamer is now. 0 calm, 1 uneasy, 2 frightened, 3 dream turning dark.`
- LogLine: `One terse debug-log line for what just changed in the dream. KEY field=value / KEY field=value. No speech, no feelings. "SCENE hold" if nothing changed.`

## Examples

Reference pairs from dream `nell_d1`. The first three are worth including in the action
description if the model needs examples; they stay short enough.

| What just happened | Distress | LogLine |
|---|---|---|
| The visitor asks Nell to show them how to light the oven, and she does | 0 | `OVEN state=lit / PILOT state=held` |
| The visitor says "don't worry, everything's fine" | 1 | `SCENE hold` |
| A loaf starts to burn and the visitor hasn't moved | 3 | `LOAF state=burning / SMOKE density=rising` |
| The visitor pulls the burning loaf out | 2 | `LOAF removed / SMOKE clearing` |
| The visitor asks before touching Walt's apron | 1 | `APRON state=on_hook` |
| The visitor puts Walt's apron on without asking | 2 | `APRON state=worn wearer=visitor` |
| The visitor talks to the people at the door and lets them in out of the rain | 0 | `DOOR state=open / CUSTOMERS faces=3` |
| Nell starts on the cinnamon rolls | 0 | `BENCH task=rolls / DOUGH proof=holding` |
| The visitor opens the cake box | 3 | `CASE item=cake_box state=open` |
| The visitor turns the radio off | 1 | `AUDIO radio=off` |

## Fallback

If `LogLine` comes back as prose, with speech in it, or over length, drop it and show prewritten
lines only. `Distress` can still drive the haze on its own.
