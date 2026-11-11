# Design (working title: Director's Cut)

Jam theme: **Director's Cut**. Written 2026-11-11, before the jam started. This is a plan, not
game content; it's declared in `devlog.md`.

## Pitch

You wake up in a hospital where every patient is in a coma, each stuck in a recurring dream.
You watch a dream play out, read the patient's case file, then step in as the dream's director:
recast yourself, change the scene, bring in pieces of the patient's past, and talk to the
dreamer live to help them let go. Each solved dream leaves you an item, and you keep finding
clues about yourself. Slowly it becomes clear that you're in a nightmare too, one you've been
avoiding, and the hospital is turning on you. Use what the dreams gave you and what you've
learned about yourself to break free.

## Core loop (one patient)

1. **Case file.** At the patient's bed, read their file: personality, likes, dislikes, key
   moments.
2. **Observe.** Watch the dream loop as an outside camera (Cinematic Sequence device). It always
   ends the same way.
3. **Direct.** Before entering, set up the next take:
   - **Cast yourself** in one of 2-3 roles (stranger, old friend, doctor). Changes your costume
     and who the dreamer thinks you are.
   - **Apply adjectives** from a fixed set per dream (for example stormy, warm, silent). Each
     one is a prebuilt change: lighting, weather, props shown or hidden.
   - **Bring in history items** from the case file (for example a music box, a dog).
4. **Enter.** Play your role inside the dream and talk to the dreamer (an LLM persona NPC) by
   voice, or with preset lines for players without a mic.
5. **Resolve or retry.** If you get through to them, the dream resolves and you keep an item.
   If not, the dream loops and you can direct a new take.

## Specificity is the score

How well a take resolves depends on how **specific** it is to this dreamer. Generic comfort
barely moves them, and details from their own life move them a lot.

- **Low:** you enter as a random extra and say "There's no reason to fear."
- **High:** you enter as their teacher and have the class chant the catch phrase of the
  superhero they love.

A take is scored on four criteria:

| Criterion | Rewards | Example |
|---|---|---|
| **Backstory** | Using elements from the case file: people, places, key moments, loved things | Entering as their teacher, not a stranger |
| **Personality** | Appealing to who they are: what moves a shy kid differs from what moves a show-off | The class chants with them so they aren't singled out |
| **Environment** | Fitting the dream's setting, so the change belongs there | A classroom chant in a classroom dream, not a parade |
| **Common sense** | Choices that make sense together and in the moment | Not a teacher cheering on a superhero in the middle of a fire drill |

The whole take is judged on these: who you enter as, how you direct the dream's extras (for
example "the class chants [their hero's catch phrase]" versus "the crowd cheers"), the
adjectives and items you add, and what you say to the dreamer.

## The dreamer's verdict

You can't predict every avenue a player takes, so the scores can't be fixed in advance. **The
dreamer (the LLM persona) judges the take on the rubric and gives its verdict in character.**

1. The scene plays out: the player's role, direction, adjectives and items, and the
   conversation.
2. Verse ends the scene and prompts the dreamer to weigh the take against the rubric and answer
   with exactly one of three fixed lines:

   | Verdict | Line (example) | Result |
   |---|---|---|
   | Positive | "I'm feeling a bit better." | The dream resolves and you get the item |
   | Mixed | "Something about this feels familiar..." | Partial reaction; the dream loops with a hint |
   | Negative | "I'm confused." | The dream loops again |

3. Verse listens for the line (`CommitSayEvent` converted with `Localize`) and advances.

This keeps the judging in character, so the score feels like the dreamer's reaction rather than
a grade. It also needs only one persona NPC and a phrase match, not number parsing. The dreamer
can add a sentence after the fixed line ("...you sound like Mr. Hale, but he never shouted"),
which works as the hint toward the weakest criterion.

The direction menus can still offer many options, mostly generic or near-misses, so reading the
case file closely is the puzzle. But the dreamer, not the menu, decides what a take is worth.

**Items are specific to the player too.** What a dreamer gives you isn't a generic key. It's
something that belongs to the player's own story, and it connects to the clues found on
yourself.

## Meta story

- **The player is also dreaming.** The hospital is the player's own nightmare. Each patient's
  dream reflects something the player is avoiding.
- **Saving each other.** Each patient is a savior of the player, just as the player is a savior
  of them. Helping a dreamer let go of their loop also gives the player something they need to
  face their own: the dream item, and what the dreamer tells them on the way out.
- **Lore found on yourself.** After each dream, a new clue turns up on the player: a wristband,
  a note in a pocket, their own chart. Together the clues reveal the player's story.
- **The hospital escalates.** After each solved dream the hospital gets worse: lights fail,
  sounds change, doors lock, and something starts to follow you. Built as 3 states switched with
  devices.
- **Escape.** The dream items combine with what you learned about yourself to open the way out.
  The ending is the player's own "director's cut": they finally face their own dream.

## Scope

- **Must have:** the hospital hub, **one** complete patient (case file, observe, direct, talk,
  resolve), one hospital escalation, and a short escape ending.
- **Then:** a second patient, more adjectives and items, and a fuller escape.
- **Cut first:** a third patient.

The 30-60 second video should show watching the loop, setting up the take, talking to the
dreamer, the dream resolving, and the hospital turning darker.

## Technical risks (test these on Day 1 first)

1. **Getting the verdict.** As far as I know, the only LLM a UEFN island can reach is a persona
   NPC: Verse has no general web or LLM API. Plan: at the end of the scene, Verse sends the
   dreamer a `PromptToTalk` asking for its verdict, and listens for one of the three lines. To
   check:
   - whether the dreamer says the fixed lines word for word, so the phrase match works
   - whether it judges the take fairly against the rubric while staying in character, or is
     too easily pleased
   - whether Verse can tell the verdict line apart from normal dialogue (for example by only
     listening right after the verdict prompt)
2. **Giving the NPC context at runtime.** The role, adjectives and items have to reach the
   dreamer. Plan: `PromptToTalk` with a context line ("A storm rolls in. The visitor is your
   brother."). Need to check whether the NPC keeps that context for the rest of the
   conversation.
3. **Private version code.** Confirm an island with persona NPCs can be published as a private
   version.

Fallback if the dreamer is too lenient: add a second, hidden judge persona that only gives the
verdict. Last resort if the verdict can't be read reliably: fixed values per option, with the
LLM only adding flavor.

## Open questions

- Who the patients are to the player (people from their life, or parts of them), given that
  each one saves the player in return.
- What follows the player through the hospital, and whether it can catch them.
- How the dream items combine in the escape.
