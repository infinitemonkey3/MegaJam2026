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
   moments, and a medical note that hints at the dream.
2. **Observe.** Right after the file, watch the dream loop as an outside camera (Cinematic
   Sequence device). It always ends the same way. No step in between: the player forms their
   own read on the dream as they watch.
3. **Direct.** Before entering, set up the next take:
   - **Cast yourself** in one of 2-3 roles (stranger, old friend, doctor). Changes your costume
     and who the dreamer thinks you are.
   - **Apply adjectives** (up to 2) from a fixed set per dream element (for example the oven:
     warm, roaring, patient). Each one is a prebuilt change: lighting, weather, props shown or
     hidden.
   - **Bring in history items** (up to 2) from the case file (for example a music box, a dog).
4. **Enter.** The clock rewinds to the start of the dream with your changes in place. Play your
   role and talk to the dreamer (an LLM persona NPC) by voice, or with preset lines for players
   without a mic. The dialogue drives the take forward.
5. **Last line.** The take runs toward the moment the dream always ends (the lights going out).
   When it gets there, the player gets one last line or action before the take is judged.
6. **Resolve or retry.** If you get through to them, the dream resolves and you keep an item.
   If not, the dream loops and you can direct a new take.

### The dream fights back

Setup choices don't just add or subtract points. A risky choice can bring the dreamer's trauma
to the surface during the take, which becomes the take's crisis. In the demo, a *roaring* oven
started burning the bread, echoing the morning of the funeral. The player recovered by pulling
the loaf out, and the take was more dramatic for it. The dreamer's persona prompt should tell it
to let the dream turn dark when the setup or the player pushes on a painful memory, and to give
the player a moment to respond.

### Extras are directed inside the dream

Directing the dream's extras (the crowd, the class) works better as something the player does
during the take than as a menu choice beforehand. In the demo the player skipped the extras
step, then won over the waiting customers by talking to them at the door, and the faceless line
turned into regulars with faces. The extras react to what the player says and does in the
scene.

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

The whole take is judged on these: who you enter as, the adjectives and items you add, what you
say to the dreamer, and how you deal with the extras during the scene (for example getting the
class to chant [their hero's catch phrase] versus telling a crowd to cheer).

## The dreamer's verdict

You can't predict every avenue a player takes, so the scores can't be fixed in advance. **The
dreamer (the LLM persona) judges the take on the rubric and gives its verdict in character.**

1. The scene plays out: the player's role, direction, adjectives and items, and the
   conversation. The persona's session records the conversation automatically.
2. Verse ends the scene and asks the dreamer's session for a **structured verdict**
   (`ai_session.Prompt` with a response type, see below). This is silent: nothing is spoken.
   The model fills in a score per criterion, a verdict, and a hint.
3. Verse acts on the verdict and has the dreamer say the matching line out loud
   (`PromptToTalk`):

   | Verdict | Line (example) | Result |
   |---|---|---|
   | Positive | "I'm feeling a bit better." | The dream resolves and you get the item |
   | Mixed | "Something about this feels familiar..." | Partial reaction; the dream loops with a hint |
   | Negative | "I'm confused." | The dream loops again |

The player only ever hears the dreamer's reaction, so the score feels like how the dreamer
feels, not a grade. The dreamer can add a sentence after the line ("...you sound like Mr. Hale,
but he never shouted"), built from the hint, which points at the weakest criterion.

### How the rules reach the LLM

The persona API (UEFN 43.00, `/UnrealEngine.com/Conversations`) gives us what we need:

- **`ai_session.Prompt(Prompt, response_type)`** sends instructions with the session's full
  context (personality, pinned facts, conversation history) and parses the reply into a Verse
  struct of numbers, messages, booleans, enums and arrays. Field and type names guide the
  model. Sketch:

  ```verse
  take_verdict := enum{Positive, Mixed, Negative}
  take_score := struct:
      BackstoryScore:int        # 0-3
      PersonalityScore:int      # 0-3
      EnvironmentScore:int      # 0-3
      CommonSenseScore:int      # 0-3
      Verdict:take_verdict
      HintForWeakestCriterion:message
  ```

- **`persona_component.SetPersonality`** changes the personality at runtime, so one dreamer NPC
  setup can load each patient's case file and dream setting.
- **The rubric goes in the verdict prompt**, not the personality. The dreamer plays the scene
  without thinking about scores, then judges it when asked. The prompt is short: the four
  criteria with what earns 0-3, and the verdict thresholds.
- **`RegisterAction`** lets the model emit a structured side-output with any reply. Could be
  used for live reactions during the scene (warmer or colder). Not needed for the first version.

**Context size:** no documented limit. Epic's docs say there's no limit on the number of facts,
and the conversation history is compacted automatically. There is an `ai_character_limit_error`,
so some limit exists. Keep each case file and the rubric to a few hundred words. The model is
Gemini 3.1 Flash-Lite (Epic's FAQ), and the session clears after each round.

**Fits Epic's own example.** Epic's persona docs describe a cosmic entity that tries to convince
players to press a button. This flips it: the player convinces the NPC. Structured output "like
when to end a game" is a use case Epic names. The jam also has a **Walkie-Talkie** prize for the
best narrative UEFN game with LLM-powered NPCs, which this concept is aimed at.

The direction menus can still offer many options, mostly generic or near-misses, so reading the
case file closely is the puzzle. But the dreamer, not the menu, decides what a take is worth.

**Items are specific to the player too.** What a dreamer gives you isn't a generic key. It's
something that belongs to the player's own story, and it connects to the clues found on
yourself. In the demo, Nell gave the player a bakery order slip for a birthday cake that was
never picked up, written in the player's own handwriting. Items tell the meta story.

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

## Paper demo: Nell (2026-11-11)

We played one patient as text in chat, with the agent playing the game and the dreamer, to test
the loop. A placeholder patient for testing, not necessarily one for the game.

- **Case file:** Eleanor "Nell" Price, 71, a proud, dry-humored baker who softens when someone
  needs her. She ran Price's Bakery with her late husband Walt, who whistled while he kneaded.
  She taught his nephew Teddy to bake as a kid. The morning of Walt's funeral she opened alone,
  burned every loaf, and never reopened. Her heart rate rises at 5 AM.
- **Dream:** 5 AM at the bakery. The oven won't light, faceless customers press at the glass,
  the dough won't hold, there's no whistling, and the lights go out.
- **Take:** Teddy, with a roaring oven, rain, Walt's apron and cinnamon. Teddy asked Nell for a
  favor (to teach him again), pulled out the burning loaf when the oven brought back the
  funeral morning, put on Walt's apron, and asked the waiting customers to bear with them.
- **Verdict:** Backstory 3, Personality 3, Environment 3, Common sense 2 (the roaring oven
  nearly ended the take). 11/12, positive: "I'm feeling a bit better." Nell started whistling.

What it showed: the four sections above on the dream fighting back, extras inside the dream,
the last line, and items that belong to the player.

## Scope

- **Must have:** the hospital hub, **one** complete patient (case file, observe, direct, talk,
  resolve), one hospital escalation, and a short escape ending.
- **Then:** a second patient, more adjectives and items, and a fuller escape.
- **Cut first:** a third patient.

The 30-60 second video should show watching the loop, setting up the take, talking to the
dreamer, the dream resolving, and the hospital turning darker.

## Technical risks (test these on Day 1 first)

1. **Getting the verdict.** Plan: `ai_session.Prompt` with the `take_score` struct. To check:
   - that it returns a filled struct in a play session (it's marked available from 41.00)
   - that the session's history includes what the player said by voice, so the verdict can
     judge it
   - whether it judges fairly against the rubric, or is too easily pleased
   - how long the verdict takes, and how big a case file can get before
     `ai_character_limit_error`
2. **Giving the NPC context at runtime.** The role, adjectives and items have to reach the
   dreamer. Plan: `SetPersonality` for the patient, then a `PromptToTalk` with a context line
   ("A storm rolls in. The visitor is your brother."). Need to check that the context stays in
   the session history for the rest of the conversation.
3. **Private version code.** Confirm an island with persona NPCs can be published as a private
   version.

Fallback if the structured verdict doesn't work: prompt the dreamer to say one of three fixed
lines and match the text from `CommitSayEvent` (converted with `Localize`). If the dreamer is
too lenient: a second, hidden judge persona that only gives the verdict. Last resort: fixed
values per option, with the LLM only adding flavor.

## Open questions

- Who the patients are to the player (people from their life, or parts of them), given that
  each one saves the player in return.
- What follows the player through the hospital, and whether it can catch them.
- How the dream items combine in the escape.
