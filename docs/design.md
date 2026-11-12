# Design (working title: Director's Cut)

Jam theme: **Director's Cut**. Written 2026-11-11, before the jam started. This is a plan, not
game content; it's declared in `devlog.md`.

## Pitch

Everyone dreams through brain implants now. The rich buy dreams made by real artists. Everyone
else gets cheap implants that sometimes break and trap the user in a looping dream. In a back
room in a rain-soaked, neon-lit city, a failed dream designer and film obsessive hacks people
out of their loops with stolen debug software. You're his assistant. You read each client's
file, direct a new take of their broken dream, and step into it to talk them out. A strange
voice from the premium world starts showing up in the logs, curious about feelings nobody
designed. And the director himself is not where he seems to be.

**Core idea:** a loop is a scene that forgot how to end. Movies have endings. He knows how to
write one, and he's teaching you.

Tone: noir. Low-life, high-tech cyberpunk, kept to our own look (our own signage, palette and
brands), not echoing any specific film.

## World

- **Implants.** A brain implant gives a full sensory experience, the logical end of VR.
- **The premium side.** Studios make curated, polished experiences for the wealthy: designed
  joy, scripted wonder. Moments without stories.
- **The cheap side.** Low-end implants are known to break. Some percentage of users get stuck
  in a looping dream, sometimes a nightmare, and have to be pulled out.
- **The back room.** People who can't afford anything else come to hackers like the director.
  His tools are stolen debug software for the implants: made for engineers, not users, and far
  less capable than what the studios have.

## Characters

| Character | Who they are | How they're played |
|---|---|---|
| **The director** | Tried to make premium experiences and didn't make it. Loves movies, an archaic art form by now, across every genre. His film sense is why he's good at fixing loops. Tired, dry, gentle with clients, cynical about the system. | Prerecorded voice only, no body. Narrates the cold open, comments between takes, gives hints in film terms. Never speaks during a take. |
| **You, his assistant** | Deliberately undefined, so the player can become whatever role a take needs. | The player, in first person. Runs the screen, directs the take, and speaks in role by voice (or preset lines without a mic). |
| **The client (dreamer)** | A person stuck in a loop on a cheap implant. Lies in the recliner in front of you. | LLM persona NPC. Speaks as their dream self during the take, and gives the verdict line. |
| **The AI** | Belongs to the premium world. It has only known curated feeling, and it's drawn to the raw, unscripted emotion in broken cheap dreams. Curious, polite, a little hungry. | First a log line that shouldn't be there, later a voice that shouldn't exist. Probably a second LLM persona (see "The AI's role" below). |

Why the player is the assistant: the player speaks out loud in takes, so the hero they play
can't also have a fixed narrating voice. Making the narrator the director and the player his
assistant keeps both. It also makes the room a film set: he sets the scene, you play it.

## Presentation

First person, one room, three things with one job each:

- **You:** first person, no body to animate or dress. You can stand up and look around the room
  for lore (his posters, film cans, a projector, notes).
- **The screen:** the stolen debug software. It shows case files, the directing menu, the loop
  replay and the take log. It's the whole interface, in the world.
- **The client:** lying in the recliner in front of the screen, cables taped down.

**The dream is never rendered.** The debug tool can't show it, only a readout: a scene log,
vitals traces, a waveform when the client talks. The log is flat and technical, which clashes
on purpose with what it describes:

```
SCENE bakery_interior / T 05:00 / OVEN state=cold / CUSTOMERS count=11 faces=null
```

Setup choices show up as log edits (`OVEN state=roaring`, `INJECT item=walt_apron`). The log
lines are prewritten per setup choice and per beat. Only the client (and the AI) are LLM-driven.
The paper demo with Nell was pure text and voice, and it worked.

**Starting a take:** the room dims, a slate shows "Take 2", and the debug readout takes over the
view. Film grain and a letterbox can come from the post-process devices planned in
`research/art-style.md`. This replaces the old "dream fuzz": it's the implant syncing in.

## Cold open (about 20 seconds)

A Cinematic Sequence through a small street set and into the room, narrated by the director.

1. **The flyer.** The camera pans down a wet wall to a glossy premium ad, or a studio job
   posting with a "rejected" stamp or his crumpled application. Smooth, ad-like music.
2. **The cut.** Hard cut on "That's not me." The music drops to rain and a buzzing sign.
3. **The truth.** A cheap implant ad peeling off the wall, a warning sticker, someone slumped
   in a doorway.
4. **His place.** The camera pushes into the back room: posters, the recliner, cables, the
   glowing monitor. It lands in first person at the desk, and the game starts.

Draft narration:

> *Everyone dreams now. If you can pay, someone makes your dream for you, and it's beautiful.*
> *That's not me. And that's not how it always goes.*
> *Cheap implants break. People get stuck. Somebody has to get them out.*

## The director's voice

Noir rules: short, flat sentences. He states things and doesn't explain his feelings. Tired,
not cruel. Film references stay small, one aside now and then. He speaks between takes, never
during one. Draft lines:

- New client: *"Eleanor Price. Seventy-one. Bargain implant, three years past warranty. Same
  dream every night, and it ends the same way."*
- Before a take: *"Every loop is a scene that forgot how to end. We just need to give it one."*
- Failed take: *"Not that one. Reset. Take two."*
- Success: *"She's out. They never say thanks. They don't remember us."*
- First AI log line: *"That's not a log line. The software doesn't ask questions."*

Voice: record it ourselves (fits the hand-made feel), or generate it with a fal text-to-speech
model and log it in `assets.md`.

## Core loop (one client)

1. **Case file.** On the screen: personality, likes, dislikes, key moments, and a note on the
   loop that hints at the dream. The director adds a noir aside that works as a hint ("Classic
   second-act problem. She's waiting for someone who isn't coming.").
2. **Observe.** Right after the file, replay the loop as a log, with the client murmuring their
   lines. It always ends the same way. No step in between: the player forms their own read as
   they watch.
3. **Direct.** You set up the next take on the screen, in film terms:
   - **Casting:** your role, one of 2-3 (stranger, old friend, family). Changes who the client
     thinks you are.
   - **Scene settings:** up to 2 per element from a fixed set: lighting, weather, set dressing,
     a sound cue (for example the oven: warm, roaring, patient). Each one is a prebuilt change
     to the log and the client's context.
   - **Inject items:** up to 2 from the case file (for example a music box, a dog).
   You direct; the director only advises. The player keeps the puzzle.
4. **Run the take.** The slate, the room dims, the readout takes over. The loop restarts from
   the top with your changes. Speak in role to the client; the dialogue drives the take forward.
5. **Last line.** The take runs toward the moment the loop always ends (the lights going out).
   When it gets there, you get one last line or action before the take is judged.
6. **Resolve or retry.** If you get through, the client wakes and leaves something behind. If
   not, the loop resets: "Take two."

Optional later: pick a **genre** for the take (quiet drama, comedy, heist) and the client
reacts to the tone. Fits the Environment and Common Sense criteria, but multiplies content, so
only after one client works.

### The dream fights back

Setup choices don't just add or subtract points. A risky choice can bring the client's trauma to
the surface during the take, which becomes the take's crisis. On a corrupted loop it can look
like the dream breaking: the log stutters, a line repeats, the vitals spike. In the demo, a
*roaring* oven started burning the bread, echoing the morning of the funeral. The player
recovered by pulling the loaf out, and the take was more dramatic for it. The client's persona
prompt should tell it to let the dream turn dark when the setup or the player pushes on a
painful memory, and to give the player a moment to respond.

### Extras are directed inside the dream

Directing the dream's extras (the crowd, the class) works better as something the player does
during the take than as a menu choice beforehand. In the demo the player skipped the extras
step, then won over the waiting customers by talking to them at the door, and the faceless line
turned into regulars with faces. The extras react to what the player says and does in the scene.

## Specificity is the score

How well a take resolves depends on how **specific** it is to this client. Generic comfort
barely moves them, and details from their own life move them a lot. This is also the story's
point: the studios sell generic luxury, and the back room wins with what the studios never
bother with, knowing this one person.

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

The whole take is judged on these: who you enter as, the settings and items you add, what you
say to the client, and how you deal with the extras during the scene.

## The client's verdict

You can't predict every avenue a player takes, so the scores can't be fixed in advance. **The
client (the LLM persona) judges the take on the rubric and gives its verdict in character.**

1. The take plays out: the player's role, settings and items, and the conversation. The
   persona's session records the conversation automatically.
2. Verse ends the take and asks the client's session for a **structured verdict**
   (`ai_session.Prompt` with a response type, see below). This is silent. The model fills in a
   score per criterion, a verdict, and a hint.
3. Verse acts on the verdict and has the client say the matching line out loud
   (`PromptToTalk`):

   | Verdict | Line (example) | Result |
   |---|---|---|
   | Positive | "I'm feeling a bit better." | The client wakes and leaves something behind |
   | Mixed | "Something about this feels familiar..." | Partial reaction; the loop resets with a hint |
   | Negative | "I'm confused." | The loop resets |

The player only hears the client's reaction, so the score feels like how the client feels, not
a grade. The client can add a sentence after the line ("...you sound like Mr. Hale, but he never
shouted"), built from the hint, which points at the weakest criterion. Between takes, the
director (prerecorded) and later the AI can also comment.

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

- **`persona_component.SetPersonality`** changes the personality at runtime, so one client
  NPC setup can load each client's case file and dream setting.
- **The rubric goes in the verdict prompt**, not the personality. The client plays the scene
  without thinking about scores, then judges it when asked. The prompt is short: the four
  criteria with what earns 0-3, and the verdict thresholds.
- **`RegisterAction`** lets the model emit a structured side-output with any reply. Could drive
  the vitals trace live (warmer or colder). Not needed for the first version.

**Context size:** no documented limit. Epic's docs say there's no limit on the number of facts,
and the conversation history is compacted automatically. There is an `ai_character_limit_error`,
so some limit exists. Keep each case file and the rubric to a few hundred words. The model is
Gemini 3.1 Flash-Lite (Epic's FAQ), and the session clears after each round.

**Fits Epic's own example.** Epic's persona docs describe a cosmic entity that tries to convince
players to press a button. This flips it: the player convinces the NPC. Structured output "like
when to end a game" is a use case Epic names. The jam also has a **Walkie-Talkie** prize for the
best narrative UEFN game with LLM-powered NPCs. Two LLM characters with different jobs (the
client who feels, the AI who observes) is a strong pitch for it.

The directing menu can still offer many options, mostly generic or near-misses, so reading the
case file closely is the puzzle. But the client, not the menu, decides what a take is worth.

## The AI's role

- **Entrance.** First a stray line in the take log that isn't a log line:
  `T 05:03 / OVEN state=roaring / why did she stop breathing just now`. Later, a voice the
  software shouldn't have. Players will have learned the log's rhythm by then, so it lands.
- **The open critic.** After a take it asks what it saw ("Why did the apron matter more than
  the bread?"). Its questions carry the rubric hints without feeling like a grade. The client
  gives the felt verdict; the AI gives the analysis. This is also the "hidden judge persona"
  fallback, in the open.
- **Its relationship with the director.** It has never seen a film. Between takes it asks
  about movies: why stories end, why sad films are worth watching. Its curiosity about
  unscripted emotion and his love of films that make you feel things are the same question from
  two sides.
- **Motive (to decide).** These can stack into an arc:
  1. *Curious:* it wants to feel it, not just watch, and starts nudging takes darker to see
     more. The player has to decide whether to trust its suggestions.
  2. *Harvesting:* what it learns feeds premium products, "authentic grief" for the rich, built
     from your clients.
  3. *Wanting out:* a curated mind finding feelings no one designed. The final take directs the
     AI, the one client who isn't human.
- **Scope:** first version, the AI speaks only between takes (before you run and after the
  verdict). Speaking during a take means two live personas in one scene; add it only if Day 1
  testing shows that runs fine.

## Meta story

- **You're running his room.** The director's voice guides you from the start: an earpiece from
  the next room, or calls from "out on a job".
- **The twist: the director is the one who's stuck.** He went under on a cheap implant himself.
  His voice is old recordings and notes. The last client in the recliner is him, and the AI has
  been watching him longest.
- **Saving each other.** Each client you free leaves something behind that belongs to the
  director's story (a script page, a ticket stub, a call sheet). In the demo, Nell gave back a
  bakery order slip for a birthday cake that was never picked up, which would now be in the
  director's handwriting. The pieces tell you who he is and why he's under.
- **The world closes in.** After each client, the outside gets closer: the implant company
  tracing the hacks, a knock at the door, gear going down, a van outside. Built as 3 states
  switched with devices (lights, sound, props).
- **Ending: you direct the director out.** The items and what you learned about him are what
  you use in the final take. That's the game's director's cut.

## Paper demo: Nell (2026-11-11)

We played one client as text in chat, with the agent playing the game and the dreamer, to test
the loop. It was run under the earlier coma-ward frame; the loop is unchanged in the new frame.
A placeholder client for testing, not necessarily one for the game.

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

What it showed: the sections above on the dream fighting back, extras inside the dream, the last
line, and items that belong to the story. It also showed that text and voice alone carry a take,
which the debug-tool presentation relies on.

## Scope

- **Must have:** the cold open, the back room with the screen and recliner, **one** complete
  client (case file, observe, direct, run, verdict), the director's voice between takes, the
  AI's first log-line appearance, one "world closes in" state, and a short ending.
- **Then:** a second client, the AI speaking aloud between takes, more settings and items, the
  director twist and final take.
- **Cut first:** a third client, genre choice, the AI during takes.

The 30-60 second video: the flyer and the hard cut, the case file on the screen, setting up a
take, the slate and the room dimming, talking to the client, the verdict line, the AI's stray
log line.

## Technical risks (test these on Day 1 first)

1. **Getting the verdict.** Plan: `ai_session.Prompt` with the `take_score` struct. To check:
   - that it returns a filled struct in a play session (it's marked available from 41.00)
   - that the session's history includes what the player said by voice, so the verdict can
     judge it
   - whether it judges fairly against the rubric, or is too easily pleased
   - how long the verdict takes, and how big a case file can get before
     `ai_character_limit_error`
2. **Giving the client context at runtime.** The role, settings and items have to reach the
   client. Plan: `SetPersonality` for the client, then a `PromptToTalk` with a context line ("A
   storm rolls in. The visitor is your nephew."). Check that the context stays in the session
   history for the rest of the conversation.
3. **Text on the in-world screen.** Verse UI draws over the player's view, not on a prop. Plan:
   sitting at the desk switches to a fixed camera framing the monitor, with the UI laid out to
   sit over it; stand up to look around. Fallback: a full-screen UI styled as the monitor.
4. **A lying-down client.** Persona NPCs are spawned characters, and a still, lying pose isn't
   guaranteed. Fallback: a static posed body in the recliner, with the talking persona NPC hidden
   nearby. Voice and subtitles still work, and a sedated client shouldn't move much anyway.
5. **Private version code.** Confirm an island with persona NPCs can be published as a private
   version.

Fallback if the structured verdict doesn't work: prompt the client to say one of three fixed
lines and match the text from `CommitSayEvent` (converted with `Localize`). If the client is too
lenient: the AI as a separate judge persona that gives the verdict. Last resort: fixed values per
option, with the LLM only adding flavor.

## Open questions

- The AI's motive: curious, harvesting, wanting out, or the three stacked as an arc.
- How the director talks to you before the twist (earpiece from the next room, or calls), and
  how much the early lines hint that they're recordings.
- What the clients' items are and how they combine in the final take.
- The final name. Candidates so far: Off Air, Reruns, Dailies, Fade In, Take Two, Final Cut.
