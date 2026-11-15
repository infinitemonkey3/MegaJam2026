# Director narration

Generated 2026-11-12 with fal, `google/gemini-3.8-flash-tts`, voice `Orus`. Chip picked the voice
from a six-voice audition and the take for each line. WAV, as the model returned it.

| File | Line | Delivery note (`style_instructions`) |
|---|---|---|
| `VO_Director_ColdOpen_01.wav` | "Everyone dreams now. If you can pay, someone makes your dream for you, and it's beautiful." | Base note |
| `VO_Director_ColdOpen_02.wav` | "But that's not me. And that's not how it always goes." (redone 2026-11-14, was "That's not me"; old take in `takes/`) | Base note |
| `VO_Director_ColdOpen_03.wav` | "Cheap implants break. People don't wake up. Somebody has to get them out." (6.4 s; redone 2026-11-13, was "People get stuck") | Base note, a little weight on "don't wake up", last sentence quiet and resigned |
| `VO_Director_ColdOpen_04.wav` | "That's where you come in." (2.2 s; added 2026-11-13, on the HELP WANTED sign) | Base note, flat and matter-of-fact, as if handing over a job |
| `VO_Director_Tutorial_01.wav` | "Got a looper in the chair. Sit down. Let's see where he's stuck." | Plain talk to the assistant, a little weary |

Base note: "Film-noir narrator. A tired, dry, gentle man in his fifties. Low voice, unhurried,
flat short sentences, a short pause after each sentence. Understated, not dramatic, not a
movie-trailer voice."

To add a line in the same voice, use the same endpoint, voice and base note. Chip's own recording
can replace any of these later.

## The debugger flow (recorded 2026-11-14)

The director names the patient over her case file (ATTACH TO DREAMER), then sends the player in
over their role (ENTER DREAM). Same voice, endpoint and base note, each with a short delivery
note of its own. Files: `VO_Director_Tutorial_02.wav` (the boot line, replacing `_01`) and
`VO_Director_<id>.wav`; in UEFN under `Content/DirectorVO/` (the boot line in
`ColdOpen/Audio/`), wave volume 2.0. Verse plays them by id (`director_voice.PlayLine`).

| Id | Line |
|---|---|
| `tutorial` (replaces `VO_Director_Tutorial_01`) | "Got a looper in the chair. Sit down. Let's see where she's stuck." (Nell is a she; the old take says "he") |
| `nell_d1_intro` | "Eleanor Price. Nell. Bargain implant, three years past warranty. That's her file. Learn it. Once you're attached, you won't have it in front of you." |
| `nell_d1_sendin` | "You'll be going in as Teddy. Her nephew. She taught him to bake when he was nine. Look over the brief, and enter the dream when you're ready." |
| `nell_d2_intro` | "She let us down a layer. Her file's grown since you last read it. Learn the new parts, then attach." |
| `nell_d2_sendin` | "This time you'll be Walt Price, twenty-seven, flour on his jacket. This is the night she made up her mind about him. Look over Walt, and enter the dream when you're ready." |
| `nell_d3_intro` | "Bottom of the well. Last look at her file. Attach when you're ready." |
| `nell_d3_sendin` | "Last one. You're Walt again, forty-one years on. He's the only one who can walk through that door at five. Look him over, and enter the dream when you're ready." |

## The finale (recorded 2026-11-14)

Script and ids in `writing/nell/finale.md`. The director's six lines in `Orus` with the base
note and a delivery note each; the AI's line in `Leda` (chosen from an audition with `Puck` and
`Achird`, kept in `audition/`), told: "an artificial intelligence that has only just learned what
it feels like to lose something; soft, polite and curious, childlike and a little too bright,
with an uncanny evenness; hurt underneath, and quietly accusing." In UEFN under
`Content/DirectorVO/`, wave volume 2.0, players `DIR finale_*`. The power cut is in
`audio/sfx/` (ElevenLabs Sound Effects v3).

## Room lines (recorded 2026-11-15)

The director on things in the room the player clicks (`writing/director/room-lines.md`). Same
voice, endpoint and base note, with a delivery note each. Two takes; Chip picked A. Takes in
`takes/`; in UEFN under `Content/DirectorVO/`, wave volume 2.0, player `DIR room_poster_musical`.

| Id | Line | Delivery note |
|---|---|---|
| `room_poster_musical` (8.8 s) | "Sing, Meadow, Sing. Don't look at me like that. I've seen it forty times. Forty-one." | Caught out liking something soft: a little defensive, then a quiet "Forty-one" |
