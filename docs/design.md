# Design: Wonderwell

Title: **Wonderwell** (decided 2026-11-13). It's the name of the premium dream studio, the real
menace in the story, used as the title on purpose: the player sees the polished brand first
and the back room under it. The cold open's poster and the title screen carry the studio's
name. Subtitle undecided; candidates: *Director's Cut* (names the jam theme), *Rough Cut*,
*Unscripted*. Search Fortnite Discover, itch.io and trademarks for "Wonderwell" before
publishing.

The working title until then was *Dead Air*, the broadcast term for silence where there should
be a show. It stays as a phrase inside the game where it fits (the debug software's boot
screen, the dead-channel pre-roll), not as the title.

The afflicted are **loopers** (see "World").

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

**Design rule: the endings are fixed, the route is free.** Every dream has an authored
destination (the fact it reveals, the way it resolves), and the story beats between dreams are
written. The player's freedom is in how they get there: who they play, what they bring, what
they say. The LLM makes the route feel open, and the writing keeps the story on track.

**Each dream has at least two authored endings:**

| Ending | When | What happens |
|---|---|---|
| **Good** | Positive verdict | The loop resolves its authored way (Nell starts whistling), the client gives up the dream's fact, and the game moves on |
| **Bad** | Negative verdict | The loop ends its authored bad way (the lights go out on the burning shop, the vitals spike), then resets: "Take two" |

A **mixed** verdict resets with a hint, without the full bad ending. More endings per dream (a
bittersweet one, an ending that changes the next dream) can come later; the verdict struct
already has room to choose between them.

A bad ending only resets. No fail-safe for players who keep failing (such as moving on at a
cost) until playtests show players actually get stuck.

Tone: noir. Low-life, high-tech cyberpunk, kept to our own look (our own signage, palette and
brands), not echoing any specific film.

## World

- **Implants.** A brain implant gives a full sensory experience, the logical end of VR.
- **The premium side.** Studios make curated, polished experiences for the wealthy: designed
  joy, scripted wonder. Moments without stories.
- **The cheap side.** Low-end implants are known to break. Some percentage of users get stuck
  in a looping dream, sometimes a nightmare, and have to be pulled out.
- **Loopers.** What the street calls the afflicted, and "looping" is the condition ("How long
  has he been looping?"). It's slang, a little cruel, the way people talk about a condition
  that only hits the poor ("Got a looper in the chair."). The studios and implant makers never
  use it; their paperwork says something sanitized, like "persistent session fault". The
  director uses "looper" but says it gently, and calls each one by name once
  they're in his chair.
- **The back room.** People who can't afford anything else come to hackers like the director.
  His tools are stolen debug software for the implants: made for engineers, not users, and far
  less capable than what the studios have.

## Characters

| Character | Who they are | How they're played |
|---|---|---|
| **The director** | Tried to make premium experiences and didn't make it. Loves movies, an archaic art form by now, across every genre. His film sense is why he's good at fixing loops. Tired, dry, gentle with clients, cynical about the system. | Prerecorded voice only, no body. Narrates the cold open, comments between takes, gives hints in film terms. Never speaks during a take. |
| **You, his assistant** | Deliberately undefined, so the player can become whatever role a take needs. | The player, in first person. Runs the screen, directs the take, and speaks in role by voice (or preset lines without a mic). |
| **The client (dreamer)** | A person stuck in a loop on a cheap implant. Lies in the recliner in front of you. | LLM persona NPC. Speaks as their dream self during the take, and gives the verdict line. |
| **The AI** | Belongs to the premium world. It has only known curated feeling, and it's drawn to the raw, unscripted emotion in broken cheap dreams. It gets in through the faults in cheap implants and exploits them, but like a curious child: polite, eager, with no idea what its watching costs. | First a log line that shouldn't be there, later a voice that shouldn't exist. Probably a second LLM persona (see "The AI's role" below). |

Why the player is the assistant: the player speaks out loud in takes, so the hero they play
can't also have a fixed narrating voice. Making the narrator the director and the player his
assistant keeps both. It also makes the room a film set: he sets the scene, you play it.

## Presentation

First person, one room, three things with one job each:

- **You:** first person, no body to animate or dress. You can stand up and look around the room
  for lore (his posters, film cans, a projector, notes).
- **The screen:** the stolen debug software. It shows case files, the directing menu, the loop
  replay and the take log. It's the whole interface, in the world. Before a take, it dominates
  the view.
- **The client:** in the recliner, a bit further back in the scene, behind or beside the desk,
  cables taped down. Present, but the screen is the focus until the take starts.

**The room** is a low-rent space, not a clinic: discarded electronics piled around (gutted
monitors, loose boards, tangled cable), paper case files on the desk, a cigarette stubbed out in
a saucer, his movie posters on the walls. Cheap, cluttered, lived in. The clutter is good for
the art budget: lots of small junk props that read fine without being detailed.

**Art path: 2D layers.** The view is mostly fixed (seated at the desk), so the room doesn't have
to be full 3D. All art built on Day 1 is 2D layers in one "two-ink print" style (see
`art/style-test/`), so that's the path; the comparison below is kept for the record. Because the
room is 2D, its "light" is blended overlay planes (a vignette for house lights down, a glow mask
on the recliner for light on the client), not UEFN lights. The client is an illustrated overlay
on an empty recliner, with a mouth flipbook that moves when they talk and a chest piece that
breathes; the talking persona NPC is hidden off-set.

| Path | How | Strengths | Risks |
|---|---|---|---|
| **3D room** | Gallery pieces plus Meshy props, lit in UEFN | Real depth and lighting, free head movement | Mixed sources look inconsistent; lying client needs the NPC or a posed mesh |
| **2D layers in the 3D room** | Illustrated cutouts on planes (back wall, junk pile, recliner with client, desk, foreground clutter), slight parallax; noir graphic-novel or ink-wash style from fal | Strong, cohesive look for the effort; the client is an illustration with a breathing loop, so no lying-NPC problem; lights, post process and haze still apply; tiny memory cost | Keeping every layer in one style; less freedom to look around (lore becomes clickable items on the desk) |

A full-screen UI scene (visual-novel style) was ruled out: post process and lights don't affect
UI, so the haze and dimming would have to be rebuilt as UI effects. Don't mix the paths in the
final build; a half-2D, half-3D room looks worse than either.

**Consistency for 2D:** one image model for everything, one fixed style prompt, image editing
(not fresh generation) to keep the client the same across dreams, and one reference image fed
into every generation. Pick a fal model whose page allows commercial use, and log every image in
`assets.md`.

**The screen is a UMG widget rendered in the world**, placed over the computer's monitor. We
build the whole debug interface (case file, menu, log, vitals) as one UMG UI element, and it
sits in the scene like a real screen rather than as a HUD overlay. UEFN supports this: Epic's
v41.30 UI feature example places UMG widgets in the 3D world
([forum post](https://forums.unrealengine.com/t/user-interfaces-uefn-feature-example-updated-in-v41-30/2739588)),
and the docs have a page on in-world user widgets using Scene Graph. Details to confirm on Day 1
are under "Technical risks".

**The dream is never rendered.** The debug tool can't show it, only a readout: a scene log,
vitals traces, a waveform when the client talks. The log is flat and technical, which clashes
on purpose with what it describes:

```
SCENE bakery_interior / T 05:00 / OVEN state=cold / CUSTOMERS count=11 faces=null
```

Setup choices show up as log edits (`OVEN state=roaring`, `INJECT item=walt_apron`). The paper
demo with Nell was pure text and voice, and it worked.

### Narration and voice

A persona has one voice: anything it says aloud, scene description included, is spoken as the
client. So narration and dialogue are split in what the model outputs, not in how it's voiced.

- **The client speaks only dialogue.** Its personality says: never describe actions or the scene
  aloud; put any action in the log line instead. (LLMs like to narrate, *\*she sighs\**, so this
  has to be explicit.)
- **The log is text on the screen, not spoken.** Two sources:
  - *Prewritten lines* for the fixed beats: the loop's opening, setup edits, the moment the loop
    always ends.
  - *Live lines* from the client's `RegisterAction` side-output, which isn't spoken. The same
    action carries the distress score for the haze:

    ```verse
    scene_update := struct:
        Distress:int          # 0-3, drives the haze
        LogLine:message       # one terse debug-log line, e.g. "LOAF removed / SMOKE clearing"
    ```

    If the model fills `LogLine` badly, drop to prewritten lines only.
- **Voicing the log is for later.** UEFN 43.00 has no plain text-to-speech call; `PromptToTalk`
  speaks the model's own reply, not a given string. If we voice it later:
  - prewritten lines as audio recorded ahead of time (fal text-to-speech, logged in `assets.md`),
    played with an `audio_player_device`
  - live lines through a silent narrator persona told to read a line exactly (usually works, not
    guaranteed, and adds a round trip per line)
  - story bonus: the AI takes over the narrator voice and reads a line that isn't in the log

### Bonus: ask the software

The debug software has a voice you can query, like a search engine for the client's records.
It's a second persona that holds the **full fact sheet**, while the screen shows only part of
it. The dream drops a reference the screen doesn't explain ("Walt always said the third loaf
was for luck"), the player asks the software about it, and gets an answer that isn't on the
screen, as if it searched the records.

- **Why:** listening closely to the dream pays off, the player investigates instead of only
  reading, and found facts feed the **Backstory** criterion. It also gives the narrator voice a
  real job, which makes the AI's later takeover of that voice land harder.
- **How it answers:** in the software's register, terse and record-like: *"Query: third loaf.
  One record. Walter Price, interview 2019: 'Third loaf's for luck. Nell never ate it.'"* The
  answer is spoken and also written to the log so the player can reread it.
- **No inventing:** the prompt says to answer only from the fact sheet, and to say "No record"
  for anything not in it. Keep the fact sheet short and concrete. Flash-Lite may still invent
  details, so test it hard.
- **Staged facts:** the software only holds the facts the player is allowed to find so far. The
  fact dream 1 reveals isn't in its sheet until dream 1 is solved (`SetPersonality` per stage,
  or "corrupted records" that unlock).
- **Who the player is talking to:** `SetConversationTarget` picks the persona that hears the
  player. A hold-to-query key (or a button on the screen) switches to the software, and letting
  go switches back to the client. Querying during a take reads as whispering to the operator.
- **Scope:** after the slice works; the implementation plan carries it as milestone 5b, after
  the dream loop, so it's built only if time allows. It depends on two personas sharing a voice channel cleanly
  (Day 1 test).

**Starting a take:** movie night. The house lights go down, a film projector clicks and spins up,
a light flickers up on the client, the screen's slate shows "Take 2", and the readout takes over
the view while a low dream hum settles in. Film grain and a letterbox can come from the
post-process devices planned in `research/art-style.md`. No clapperboard sound: too heavy-handed.
This replaces the old "dream fuzz": it's the implant syncing in.

**Sound:** the player talks to the client out loud, so voice stays clear. The room's own sounds
carry the mood (rain on the window, the dream hum in a take), and music stays out of the takes.
The full list, with what's kept and its timing, is in `audio/sound-list.md`.

## Pre-roll: "NO SIGNAL"

No title menu: Fortnite's loading screen and Discover tile already show the island's name. But
the cinematic shouldn't start on spawn either, because players load in at different speeds and
the game depends on their mic.

So the player spawns into a black screen styled as a dead broadcast: a static test pattern, a
faint hum, "NO SIGNAL". It holds:

- a mic check: voice permission and a level meter ("Say something")
- the choice of preset lines for players without a mic
- a "Start" prompt

It looks like the game, not a menu. Start cuts to black, then the cold open.

## Cold open (about 20 seconds)

A Cinematic Sequence through a small street set and into the room, narrated by the director.

1. **The poster.** The camera drifts down a wet wall over a glossy Wonderwell poster ("MAKE
   DREAMS HAPPEN"), the premium studio, to the Wonderwell ad jingle.
2. **The cut.** On "That's not me" the jingle stops dead, leaving only rain, and the camera
   tracks right past the director's photocopied flyer to a hand-made HELP WANTED sign. The cut
   is in the sound; the camera keeps moving (Chip's camera path, `art/style-test/runs.md`).
3. **The truth.** A cheap implant ad peeling off the wall, a warning sticker, someone slumped
   in a doorway.
4. **His place.** The camera pushes into the back room: posters, the recliner, cables, the
   glowing monitor. It lands in first person at the desk.
5. **The title, then the monitor.** The game's title, **WONDERWELL**, comes after the cold open,
   a film convention: a title card in the studio's own glossy style (the art stream is planning
   it). Then the monitor flickers on and the debug software boots; its boot screen becomes the
   interface, and the tutorial starts. The first thing the player looks at in first person is
   the screen they'll use all game.

Draft narration:

> *Everyone dreams now. If you can pay, someone makes your dream for you, and it's beautiful.*
> *That's not me. And that's not how it always goes.*
> *Cheap implants break. People don't wake up. Somebody has to get them out.*
> *That's where you come in.* (on the HELP WANTED sign, at the end of the track)

## The director's voice

Noir rules: short, flat sentences. He states things and doesn't explain his feelings. Tired,
not cruel. Film references stay small, one aside now and then. He speaks between takes, never
during one. Draft lines:

- Tutorial opener: *"Got a looper in the chair. Sit down. Let's see where he's stuck."*
- New client: *"Dessen Varro. Thirteen. Second-hand speech implant, no warranty. Same dream
  every night, and it ends the same way."*
- Before a take: *"Every loop is a scene that forgot how to end. We just need to give it one."*
- Failed take: *"Not that one. Reset. Take two."*
- Success: *"He's out. They never say thanks. They don't remember us."*
- First AI log line: *"That's not a log line. The software doesn't ask questions."*

Dream 1's full set of director lines, with ids and triggers, is in `writing/des/dream-1.md`
("Director Lines").

Voice: generated with fal's `google/gemini-3.8-flash-tts`, voice Orus (Chip's pick), in
`audio/narration/` with the delivery notes; Chip's own recording can replace any line.

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
   - **Scene settings:** one value per element from a fixed set: lighting, weather, set dressing,
     a sound cue (for example the oven: warm, roaring, patient). Each one is a prebuilt change
     to the log and the client's context.
   - **Inject items:** up to 2 from the case file (for example a music box, a dog).
   You direct; the director only advises. The player keeps the puzzle.
4. **Run the take.** House lights down, the projector, the slate, the readout takes over. The loop restarts from
   the top with your changes. Speak in role to the client; the dialogue drives the take forward.
5. **Last line.** The take runs toward the moment the loop always ends (the lights going out).
   When it gets there, you get one last line or action before the take is judged.
6. **Resolve or retry.** If you get through, the client wakes and leaves something behind. If
   not, the loop resets: "Take two."

### One client, several dreams

A client has 2-3 dreams, not one. The game moves back and forth between the dream and the facts
in the room, and each dream goes one layer deeper:

1. **The surface loop.** The dream that brought them in (Nell: 5 AM at the bakery, the oven won't
   light).
2. **The memory under it.** Solving the first dream surfaces what it was covering (Nell: the
   morning of Walt's funeral, opening the shop alone).
3. **The core.** The thing they've never faced (Nell: the last ordinary day with Walt, or the
   birthday cake no one picked up).

**Between dreams, back in the room:**

- **New facts unlock** on the screen: a new case-file entry, a memory fragment the debug tool
  recovered, a message from family, something the client mutters. Each fact feeds the
  **Backstory** criterion of the next dream, so the file the player works from grows richer.
- **A lucid moment (if it fits scope):** the client half-wakes and you talk to the real person,
  not their dream self. Same persona NPC with a different context line. Who they are awake versus
  in the dream is the clearest way to show character.
- **The director comments** on what changed, and the AI asks about it.

**Why it works:**

- **Character depth.** Players spend longer with one person and see them from several sides.
- **Reuse.** One room, one client body, one persona setup (the personality grows with each
  dream's facts via `SetPersonality`), one directing menu with new options per dream, and the
  same verdict code. A new dream is a case-file entry, a log script, a few settings and items,
  and a context update.
- **Pacing.** Dream, facts, dream, facts gives the game a rhythm, and the room between dreams is
  where the "world closes in" states can show.

Since the session clears after each round, each dream's setup has to restate the facts gathered
so far. Keep them short.

### Continuity: what the player made carries forward

If the player invents something important in a take (a promise, a name, a joke, a gift, who
they claimed to be), it should still be true in the next dream, so they can call back to it.
"You promised me you'd come back for the cinnamon rolls" should land.

1. **Extract after each take.** Right after the verdict, while the session still holds the
   conversation, Verse asks for a structured summary with `ai_session.Prompt`:

   ```verse
   take_memory := struct:
       WhoTheVisitorWas:message        # the role as the client understood it
       KeyMoments:[]message            # at most 3, one sentence each
       PromisesOrRequests:[]message    # things said that could be called back to
       State:client_state              # how the client feels at the end of this take

   client_state := struct:
       Trust:int                       # 0-3, in the visitor
       Fear:int                        # 0-3
       Hope:int                        # 0-3, that the loop can end
       Mood:message                    # one short phrase, e.g. "wary but softening"
   ```

2. **Store it in Verse** as a running list per client. Cap it (for example the last 6 items) so
   it stays under the character limit.
3. **Feed it into the next dream.** It goes into the client's context with the authored facts,
   framed as memories: "Earlier, in another dream, the visitor did this. It's true for you."
   Authored facts win if the two conflict.
4. **Make it findable.** The same list goes into the software's records (the bonus query
   feature), so the player can ask "what did I say last time?" and get a session record.
5. **Reward callbacks.** The verdict prompt counts a good callback to an earlier dream as
   **Backstory**: the shared history between the player and the client is backstory too.

**The client's emotional state carries forward too.** `client_state` is rated after every take,
good or bad, and goes two places:

- **Into the next dream.** The client starts in the state the last take left them in ("You
  start this dream wary but softening: trust 2, fear 1, hope 2"). A client who trusts the
  visitor opens up sooner; a frightened one is harder to reach. Fear also sets the haze's
  starting level. A bad take costs something even though it only resets: the next try starts
  from a worse place.
- **Into the computer.** The debug screen shows the state as a readout that tracks across takes
  (a small chart of trust, fear and hope per take), and the software can answer "how is she
  doing?" from it. The player sees what their takes did to the person, not only the verdict.

The rubric scores are about the take; `client_state` is about the person. Keep them separate.

The authored destination doesn't move: carried-forward moments and state change how a dream
plays, not where it ends.

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

### The haze shows the danger

During a take, the haze over the dream view tracks how close the take is to failing. Clear means
the client is with you. Thick, desaturated and flickering means you're losing them. It's the
only live feedback before the verdict: it tells the player they're in trouble, not what to do.

**What drives it:**

- **The client's distress, live.** The client's persona uses `RegisterAction` to emit a small
  structured side-output with each reply (for example `Distress:int` 0-3, or
  `Warmer`/`Colder`). Verse maps it to a haze level.
- **Risky setup choices** start the take at a higher base level (a *roaring* oven starts hazier
  than a *warm* one). Each option in the writing carries a `Haze` value (0 or 1) and a `Risky`
  flag. The setup's base level is the sum of the chosen options' `Haze`, capped at 2. `Risky`
  doesn't add haze; it marks the options that can turn the dream dark, and confirming one in the
  menu triggers the director's warning line once per take.
- **The beats.** A take has no timer: it advances one scripted beat per client reply, toward the
  moment the loop always ends. The haze creeps up with the late beats (in dream 1, beat 3 = 1,
  beat 4 = 2, beat 5 = 3) unless the client is calm (distress 0). A long silence (about 40 s
  with no player line) moves to the next beat, so a take can't stall.
- The haze level is the highest of the three. A take starts at least at the client's
  carried-forward fear.

**Reading the take from numbers.** Verse only receives the client's words as a redacted string,
so it never branches on what the model wrote. Wherever the writing says "if the hall has joined
in" or "if the visitor ignores it", Verse reads the client's live `Distress` instead (for example
distress 1 or lower means the hall is with him). Text goes to the screen and subtitles as is.

**How it looks (3 levels, all switchable from Verse):** one Post Process device per level (for
example light *Vignette*, then *Desolate*, then *Horror Movie* plus *Simple Blur*), blended in
and out with `BlendInForAll`/`BlendOutForAll`, since Verse can't set a device's strength. The
room's light overlays dim. The vitals trace on the screen speeds up (silently: no vitals beep),
and the log text can start to corrupt at the top level. A low drone thickens over the three
levels, and the client's chest piece breathes faster.

**In the slice:** dream 3 subverts it. The take passes and the haze clears, then it floods back
to maximum when the AI breaks in, even though the player did everything right.

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
- **`RegisterAction`** lets the model emit a structured side-output with any reply. Drives the
  live danger haze and the vitals trace (see "The haze shows the danger").

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
- **Who it is (decided 2026-11-12).** The AI exploits broken cheap implants: their faults are
  holes it climbs through to watch people feel things nobody designed. But it does it like a
  curious child, not a schemer. It holds loops open and asks for "again" without knowing that's
  harm. Its lines carry wonder, never menace. It writes flat and lowercase, with perfect
  speech: the most "upside" thing there is, against clients who stumble on their own words.
- **Wonderwell is the sinister secret.** The menace belongs to the premium studio, not the AI.
  What Wonderwell does with cheap implants and their users is the secret waiting behind the
  slice (details to decide). Harvesting, "authentic grief" for the rich built from your clients,
  fits Wonderwell rather than the AI.
- **Where the AI can go after the slice:** it nudges takes darker to see more, and the player
  has to decide whether to trust its suggestions. *Wanting out* stays possible: a curated mind
  finding feelings no one designed, and the final take directs the AI, the one client who isn't
  human.
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

## The slice's client: Des (decided 2026-11-12)

Nell was the paper-demo test case. The slice's client is **Des** instead, because his loop is
caused by the implant itself: the studios sell blending in, and his implant is that promise at
the cheapest price. Nell stays in this doc as the worked example of the loop. The names below
are working names.

- **Who:** Dessen "Des" Varro, 13, eighth grade at an upper-layer school on an assistance
  placement. Often mocked and left out. From a poor family.
- **Home:** born in the Footings, a foundation layer of the city with no sky and its own speech
  ("footing talk"). Invented for the game; it stands in for no real community. A year ago the
  family moved up to the surface for his father's work.
- **The implant:** a cheap translator, fitted a few months after the move, at the kitchen table
  of the new flat. A gift from his father, who saved four months for it, so Des would "sound like them".
  Des heard: the way we talk is wrong. It glitches and makes him stutter, mostly on footing
  words, because he fights his own home speech. The stutter rises with distress, so the player
  hears the danger before the haze shows it.
- **The hero:** he uses the implant to be **Gale Rider**, a kids' show (ages 5 to 8 on the box)
  about a boy from under the clouds who learns to fly, and is ashamed of liking it at 13. The
  show's catchphrase is "The wind's on my side!" One web search found no clash; Fortnite
  Discover and trademarks are not checked yet. Gale Rider is his escape.
- **His father, Ansel:** his hero. Moved the family up for the school placement and a flat with
  a window, and works three jobs to keep it: a better life, at the cost of their traditions and
  of being there. Leaves before Des wakes, with the same goodbye at the door every morning:
  "Keep yer brann lit. I'll bring the day down."
- **His mother, Maren:** a night cleaner who keeps the Footings' traditions, above all
  brann-hang, the winter night when families hang hand-made lamps (a brann is a light) and tell
  who carried the light down. Des loved it and now won't let her mention it near school. The
  brann is home, a separate thread from Gale Rider.
- **The cape:** his father's carrier's cloak, handed down father to son and embroidered with a
  brann for every Varro carrier. Ansel gave it to him at seven to play Gale Rider in. Des wears it
  inside out so nobody sees the embroidery, with the hem cut ragged like the hero's cape. His
  mother didn't like the cutting ("That cloth carried the light down."). He kept cutting.

**Footing talk is built like a real dialect, without copying one.** It differs from upside
speech where dialects usually differ: family words, greetings, goodbyes and a few everyday words.
Working words: `athy` (dad), `mavvy` (mum), `yer` (your), `upside` (the upper layers), `the day`
(daylight), and the greeting "Down safe?" with the answer "Safe down." (hello, how are you; you
made it down safe). Every word is invented or plain English; no real dialect's words.

**The AI's ramp across the slice.** Each step wants a little more.

1. **Dream 1: nothing.** The log stays clean, so the player learns its rhythm.
2. **Dream 2: a word.** In the kitchen on fitting day, Ansel says "Now you'll sound like them."
   Des answers his father, and the implant tries to change what he calls him:

   ```
   T 18:44 / IMPLANT substitute word=athy -> dad / result=rejected
   T 18:44 / IMPLANT substitute word=athy -> dad / result=rejected
   T 18:44 / why does he keep saying the wrong one
   ```

   "Wrong" is what the substitution list taught it. It repeats Ansel's view without knowing it.
3. **Dream 3: a feeling, then again.** The take passes and Des gives his positive line. The AI
   notices him feeling better, wants to see it again, and starts the moment over itself:

   ```
   T 16:10 / LOOP end_state=resolved / exit=pending
   T 16:10 / wait
   T 16:10 / he feels better. is that what better looks like
   T 16:10 / LOOP restart t=16:09 / src=unknown
   T 16:10 / again
   T 16:10 / LOOP restart t=16:09 / src=unknown
   T 16:10 / VITALS heart_rate=148 / rising
   T 16:11 / again
   ```

   Des's positive line replays, glitching, a little worse each time. Then the AI's voice,
   polite and eager: "Once more. I want to see how it's done."
4. **The director cuts it.** Afraid, for the first time not dry: "That's not us. Pull him out.
   Pull him out!" The session dies. Black, rain.
5. **Des wakes.** In the recliner, awake, confused, no stutter: "Where... This isn't school. I
   had the dream again. Only it ended." A beat. "Thanks. I don't know what for. Thanks."
6. **The director, quietly:** "He said thanks." It answers his own line after earlier rescues,
   "They never say thanks." Then the end card.

Suggested Wonderwell seed, not yet decided: the implant line in his case-file header reads
`OEM WONDERWELL`. It means nothing in the slice.

**His three dreams:**

| Layer | The loop | What it reveals |
|---|---|---|
| **1. Surface** | As Gale Rider, he lands in front of the whole year at an assembly, opens his mouth for the catchphrase, stutters, and the laughter puts the lights out. | His catchphrase isn't the show's. It's his father's goodbye at the door. The hero is his dad, and the cape is his father's cloak. |
| **2. Under it** | The day he got the implant. His father, proud, fitting it: "Now you'll sound like them." | The stutter makes sense: the implant chokes on the words his family gave him. |
| **3. Core** | The school gate. His mother calls to him in footing talk, holding a lamp, and he walks past as if he doesn't know her. | What he's never faced is what he did to her, not what the class did to him. |

**Planted oddities for the case file:** speech faults cluster at dinner time; no faults at all
during hero play; the cape is old dark wool worn inside out; the catchphrase isn't one the show
ever used; the household hung lamps at brann-hang last winter, one with his name, and he went to
none. The full staged fact sheet is in `writing/des/case-file.md`.

**Directing him:** casting as a teacher (safe), a classmate (specific if it's the right one), his
father (strongest and riskiest: promise what Dad can't keep and the dream turns), or the hero
himself (a near-miss, because it feeds the escape). The year group is the crowd to win over
inside the take, like Nell's customers. Low specificity: "Just be yourself, nobody's laughing."
High: the year chants the catchphrase in footing talk, so he isn't the only one saying it.

**Left behind for the director's story (suggested):** a paper lamp tag in the director's
handwriting.

**Care:** a mocked teenager in distress stays gentle on screen (laughter and lights out, nothing
cruel), for Epic's content rules and the IARC rating.

**To test (Day 1):** which persona voice passes for a 13-year-old, and how text-to-speech reads a
written stutter ("M-m-mine").

## Jam slice

What we ship for the jam: one client (Des, see above), three dreams, ending on a cliffhanger.
The Nell examples in the steps below stand for Des's equivalents.

1. **Cold open.** The "NO SIGNAL" pre-roll with the mic check, then the director's narration
   over the Wonderwell poster, the jingle's hard cut and the track past his flyer, the street and
   his room. Lands in first person at the desk, and the title boots up on the monitor.
2. **Tutorial.** The director instructs you, his assistant, on the screen: how to read a case
   file, how the dream debugger shows a loop, and how to set up and run a take. Short and in his
   voice; it can run alongside dream 1 rather than before it.
3. **Dream 1: simple.** Few options, hard to fail, so it teaches the loop. When it resolves, it
   gives up **a fact that makes more of the case file make sense.** The case file should have
   entries that read as odd or unexplained at first and click into place with this fact. (Nell
   example: the file says she orders a cake every March 3 and never lets it be picked up, and
   she won't let anyone whistle in the shop. Dream 1 reveals March 3 was Walt's birthday.)
4. **Dream 2: uses the fact.** The best options in this take depend on the new fact, so the
   player sees their reading paying off. One stray AI line in the log, curious about a word.
5. **Dream 3: passed, then off the rails.** The player passes the take, the client says the
   positive line, and then the loop doesn't end. The AI breaks in: curious that he feels
   better, then restarting the moment to see it again and again. Log lines that aren't log
   lines, the vitals spike, the screen glitches, then its voice.
6. **The director cuts it.** For the first time he's not dry and in control, and he's afraid
   ("That's not us. Pull him out. Pull him out!"). The session dies.
7. **The client wakes.** Des, awake and confused, thanks them without knowing what for. The
   director, quietly: "He said thanks."
8. **Thank-you screen.** Cut to black, a thank-you and credits card, and a hint of more to come.

**Build notes:**

- The off-the-rails ending is **scripted**, not LLM-driven: after a positive verdict on dream 3,
  Verse plays a fixed sequence (log lines, the positive line replaying, post-process glitch,
  the AI's voice line, the director's reaction, the client's waking line, the director's
  "He said thanks", end card). The waking line is fixed text: the client persona told to say it
  exactly, or prerecorded if that isn't reliable. Reliable for the video and for judges. If dream 3 fails, it
  loops like any other dream.
- The AI's voice line can be prerecorded or generated (log it in `assets.md`); it doesn't need
  to be a live persona in the slice.
- Only the client is a live LLM persona in the slice.
- Continuity is in the slice, including the client's emotional state on the screen: dreams 2
  and 3 (and retries) get the `take_memory` from earlier takes, so the
  player's own moments can be called back to.
- The three dreams reuse the same room, client body, persona setup, menu and verdict code.

**After the jam (or if there's time):** asking the software about the client, a lucid moment
between dreams, the "world closes in"
states, the AI as a speaking critic between takes, more clients, and the director twist with the
final take. These stay in the design above as the full game.

The 30-60 second video: the flyer and the hard cut, the case file on the screen, setting up a
take, the slate and the room dimming, talking to the client, the positive line, and the AI
breaking in.

## Technical risks (test these on Day 1 first)

1. **Getting the verdict.** Plan: `ai_session.Prompt` with the `take_score` struct. To check:
   - that it returns a filled struct in a play session (it's marked available from 41.00)
   - that the session's history includes what the player said by voice, so the verdict can
     judge it
   - whether it judges fairly against the rubric, or is too easily pleased
   - how long the verdict takes, and how big a case file can get before
     `ai_character_limit_error`
   - that a second `Prompt` after the verdict returns a usable `take_memory` (arrays of
     messages), and that the next dream's client actually uses it when the player calls back
2. **Giving the client context at runtime.** The role, settings and items have to reach the
   client. Plan: `SetPersonality` for the client, then a `PromptToTalk` with a context line ("A
   storm rolls in. The visitor is your nephew."). Check that the context stays in the session
   history for the rest of the conversation.
3. **The in-world UMG screen.** Plan: one UMG widget placed in the world over the monitor
   (Epic's v41.30 in-world UI example, and the Scene Graph in-world widget docs). To check:
   - that the player can click or select on it in first person (input and focus on an
     in-world widget)
   - that Verse can update it at runtime: new case-file text, log lines, menu state, vitals
   - that text stays readable at desk distance, and how it looks with the room's lighting and
     the danger haze over it
   - that it works in a private version, not only in the edit session
   Fallback: a fixed camera framing the monitor with a screen-space UMG or Verse UI laid out
   over it, or a full-screen UI styled as the monitor.
4. **A lying-down client.** Settled by the 2D path: the client is an illustrated overlay on the
   recliner, and the talking persona NPC is hidden nearby.
5. **Live danger signal and log lines.** Check that `RegisterAction` fires reliably with each
   client reply, how fast, whether the distress values track the take sensibly, that its payload
   can carry a `message` (`LogLine`), and that the client stops narrating aloud once it has the
   log line. Fallback: drive the haze from setup choices and the beats only, plus scripted crisis
   beats, and use prewritten log lines only.
6. **Art path.** Chosen: 2D layers. Still to check in UEFN: alpha edges, how the layers take the
   haze and overlays, parallax from the seated view, and the blend modes the light overlays need.
7. **Two personas in one channel** (for the bonus query feature). Check that
   `SetConversationTarget` cleanly routes the player's voice to the software or the client, and
   that the software answers only from its fact sheet ("No record" otherwise).
8. **Private version code.** Confirm an island with persona NPCs can be published as a private
   version.

Verse recomputes the verdict from the four scores with the rubric's thresholds and logs, but
doesn't trust, the model's own `Verdict` field.

Fallback if the structured verdict doesn't work: a second structured prompt asking for the
verdict alone as an enum. (Matching the client's spoken line no longer works: Verse gets the
model's words only as a redacted string.) If the client is too lenient: the AI as a separate
judge persona that gives the verdict. Last resort: fixed values per option, with the LLM only
adding flavor.

## Open questions

- What Wonderwell does with cheap implants, and how much of it the slice hints at.
- Whether dream 3's good ending is Des turning the cloak right side out.
- How the director talks to you before the twist (earpiece from the next room, or calls), and
  how much the early lines hint that they're recordings.
- What the clients' items are and how they combine in the final take.
- Whether the director's own dreams (the final take) use the same layered structure.
- The subtitle for *Wonderwell*, if any.
