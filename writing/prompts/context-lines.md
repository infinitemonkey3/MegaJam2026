# Context lines

Templates for the short lines Verse sends to the client around a take. The same for every client
and dream. `{Braces}` are filled by Verse. Each template is the single line in backticks under
its heading. Lines addressed to the client use "you", in the present tense, and stay under about
25 words.

Send order at take start: Take Start, Role, each Setting, each Item, State, each Memory, then
Opening Cue. Send only the lines that apply.

## Take Start

`A new morning in the same place. It is {Time} at {Place}. You don't remember that this has happened before, only the feeling of it.`

For `nell_d1`: `{Time}` is `five in the morning`, `{Place}` is `Price's Bakery`.

## Role

`{RoleContext}`

The chosen casting option's `Context` line, unchanged (see the dream file, "Casting").

## Setting

`{SettingContext}`

One line per chosen scene setting: the option's `Context`, unchanged. Skip settings left unset
and options whose context is `none`.

## Item

`{ItemContext}`

One line per injected item: the option's `Context`, unchanged.

## State

`You start this dream {Mood}: trust in the visitor {Trust} of 3, fear {Fear} of 3, hope {Hope} of 3.`

From the last take's `client_state`, or the dream's "First Take State" if no take has run.

## Memory Intro

`Earlier, in another dream, a visitor came to you. What follows happened, and it is true for you.`

Sent once, before the first memory line, only if there are any.

## Memory

`Earlier, in another dream: {MemorySentence}`

One line per stored item from `take_memory` (`KeyMoments` and `PromisesOrRequests`), most recent
last, capped at 6. The sentences are already in the second person.

## Memory Visitor

`In that dream you took the visitor to be {WhoTheVisitorWas}. Today's visitor may be the same person or someone else.`

Sent once after the memory lines.

## Authored Facts Win

`If a memory disagrees with what you know about your own life, your own life is right.`

Sent once after the memory lines.

## Opening Cue

`The visitor has just come in. Say your first line to them.`

Sent with `PromptToTalk`, last, so the client speaks first.

## Beat

`{BeatContext}`

A take beat's or crisis beat's `Context` line, unchanged, sent when the beat fires.

## Last Line Cue

The context of the dream's last-line beat (`B6` in `nell_d1`). No separate template.

## Verdict Line

`Say exactly this, in your own voice: "{VerdictLine}" Then add one short sentence that says this in your own words: {Hint}`

Sent with `PromptToTalk` after the silent verdict. `{VerdictLine}` is the dream's line for the
verdict. `{Hint}` is `HintForWeakestCriterion`. On a positive verdict, leave the second sentence
off and send the short form:

`Say exactly this, in your own voice: "{VerdictLine}"`

## Reveal

`The visitor reached you. Now say this, exactly, and nothing else: "{RevealLine}"`

Sent with `PromptToTalk` after the positive verdict line. `{RevealLine}` is the dream's "Good
Ending Reveal".

## Bad Ending Line

`It has all gone wrong again. Say exactly this, and nothing else: "{BadEndingLine}"`

Sent with `PromptToTalk` after the negative verdict line.

## Example: nell_d1, Take 1

The paper-demo setup as the client receives it.

```
A new morning in the same place. It is five in the morning at Price's Bakery. You don't remember that this has happened before, only the feeling of it.
The visitor is Teddy, Walt's nephew, a grown man now. You taught him to bake when he was nine. He calls you Aunt Nell.
The oven is already lit this time, and it's running hot. Too hot.
It's raining on the awning. You always said rain sells bread.
Walt's apron is on its hook by the oven, where it always is. Nobody wears it.
There's cinnamon out on the bench. The rolls were always yours.
You start this dream braced, and alone: trust in the visitor 1 of 3, fear 2 of 3, hope 1 of 3.
The visitor has just come in. Say your first line to them.
```
