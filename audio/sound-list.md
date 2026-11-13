# Sound list

Every sound and music cue for the jam slice, with the prompt that makes it. Written 2026-11-12
from Chip's notes on the first plan: no slate clap, no vitals beep (the vitals trace on the
screen stays, silent), and a film projector spinning up marks the start of a take.

**The rule:** the player talks to Des out loud, so voice stays clear. The room's own sounds carry
the mood; music stays out of the takes.

**Models** (fal, both pages show "Commercial use"; the providers' own terms not read):

- Effects and ambience: `elevenlabs/sound-effects/v3`, $0.002 per second, up to 30 s, `loop: true`
  for seamless ambience.
- Music: `sonilo/v1.1/text-to-music`, $0.0025 per second (under 10 s bills as 10 s), exact
  duration. Its fal description says "licensed, commercial-use-safe".

Nothing here is generated until Chip approves the batch and its cost. Every kept file goes in
`docs/assets.md`.

## Kept so far

From batch A, with Chip's notes. Effects are WAV, 44.1 kHz stereo, in `audio/sfx/`.

| File | Was generated as | Now used for |
|---|---|---|
| `sfx/AMB_Rain_Window.wav` | `AMB_Rain_Window` | Rain on the window, the room's base loop |
| `sfx/AMB_Dream_Hum.wav` | `AMB_Monitor_Hum` | The "we're in the dream" bed, right after the projector transition |
| `sfx/SFX_Dream_Transition.wav` | `SFX_Projector_SpinUp`, take A | The transition into dream debugging (6 s, ends on its own, so no running loop) |
| `sfx/AMB_AI_NeonBuzz.wav` | `AMB_Neon_Buzz` | Too harsh for the room; kept for the AI break-in |
| `music-src/MUS_Wonderwell_Jingle.m4a` | `MUS_Wonderwell_Jingle`, take B | Cold-open ad. AAC from the model: needs converting to WAV before UEFN can import it |

The room still needs a softer outside-sign sound (a new prompt for `AMB_Neon_Buzz` below, much
quieter and more distant), or none.

### Jingle sync with the narration

The hard cut lands on the narration's turn. Timings measured from the kept takes:
`VO_Director_ColdOpen_01` is 8.1 s, `_02` is 4.4 s, `_03` is 6.8 s.

1. The jingle starts with the pan down the wall (t = 0).
2. Line 1 ("Everyone dreams now... it's beautiful.") starts about 3 s in, over the jingle, and
   ends at about 11 s.
3. At about 11.5 s the jingle stops dead, and line 2 ("That's not me.") starts on the cut, with
   only rain and the street left.

The jingle is 15 s, so it is still mid-phrase at the cut, which is the point. The exact frame is
set in the cold-open Level Sequence; if the cut feels late, start line 1 earlier rather than
trimming the jingle's opening.

## Batch marks

| Mark | Meaning |
|---|---|
| A | In the first audition batch (done) |
| - | Later batch |

## The room (looping ambience)

| ID | Sound | Length | Loop | Batch | Prompt |
|---|---|---|---|---|---|
| `AMB_Rain_Window` | Rain on the window, steady | 20 s | yes | A | Steady night rain against a single-pane window in a small cluttered room, heard from inside. Close, soft drips on the sill, no thunder, no music. |
| `AMB_Rain_Window_Heavy` | Heavier rain for tense states | 20 s | yes | - | Heavy night rain lashing a single-pane window in a small room, heard from inside, gusts against the glass, no thunder, no music. |
| `AMB_Neon_Buzz` | Soft neon sign outside (batch A's take was too harsh; it moved to the AI break-in) | 20 s | yes | - | A neon sign across the street at night heard faintly through a closed window, a soft low electrical hum, very quiet and distant, rain in front of it, no crackles. |
| `AMB_Neon_Buzz_Failing` | The sign flickering harder (haze) | 20 s | yes | - | A failing neon sign outside a window, buzzing and sputtering, irregular crackles and clicks as it flickers, muffled by glass. |
| `AMB_Monitor_Hum` | Old monitor hum and coil whine | 20 s | yes | A | A bulky old CRT computer monitor running in a quiet room, low electrical hum with a faint high coil whine, close by, no other sounds. |
| `AMB_City_Distant` | Far siren, a train, all very low | 30 s | yes | - | A distant city at night heard through a closed window: a far-off siren fading, a train passing a long way off, low traffic rumble, very quiet. |

## Cold open

| ID | Sound | Length | Loop | Batch | Prompt |
|---|---|---|---|---|---|
| `MUS_Wonderwell_Jingle` | The studio's ad jingle (music model) | 15 s | no | A | A glossy, smooth luxury advertisement jingle: warm synth pads, soft bells, an airy wordless female vocal, gentle uplifting chord progression, polished and expensive, no lyrics. |
| `AMB_Street_Rain` | Street rain, wider and wetter | 30 s | yes | - | Rain falling on a narrow city back street at night, water running in gutters, drips from awnings, a puddle splash, distant traffic, no voices. |
| `SFX_Jingle_Cut` | The hard cut on "That's not me" | n/a | n/a | - | No file: the jingle stops dead and the street rain and the buzzing sign carry on. |

## The debug screen

| ID | Sound | Length | Loop | Batch | Prompt |
|---|---|---|---|---|---|
| `SFX_Boot_Chime` | DEAD AIR boots on the monitor | 3 s | no | - | An old computer powering on: a CRT thunk and rising whine, then a short dull two-note boot chime, slightly detuned, cheap speaker. |
| `AMB_No_Signal` | "NO SIGNAL" pre-roll | 20 s | yes | - | An old television tuned to a dead channel: soft static hiss with a steady faint test-pattern tone underneath, quiet and unsettling. |
| `SFX_Key_Click` | Keyboard clicks | 2 s | no | - | A few clicks on a worn mechanical keyboard, close, dry room. |
| `SFX_Log_Tick` | One new log line | 0.5 s | no | - | A single tiny dry electronic tick from an old computer, like a line printed on a terminal. |
| `SFX_Menu_Move` | Menu move | 0.5 s | no | - | A short soft electronic blip from an old computer interface, low and muted. |
| `SFX_Menu_Confirm` | Menu confirm | 0.7 s | no | - | A short confirming two-tone electronic beep from an old computer interface, low and muted. |

## The take

| ID | Sound | Length | Loop | Batch | Prompt |
|---|---|---|---|---|---|
| `SFX_Projector_SpinUp` | Take start: an old film projector spinning up | 6 s | no | A | An old 16mm film projector switching on in a small room: a heavy switch click, the motor spinning up, then the rhythmic clicking clatter of film running through the gate settling into a steady speed. Close, mechanical, no music. |
| `SFX_Projector_Stop` | The take ends: projector winds down | 4 s | no | - | An old 16mm film projector switching off: switch click, the clatter slowing and the motor winding down to silence. |

During the take, `AMB_Dream_Hum` (kept from batch A) is the bed, so there is no projector running
loop.
| `SFX_Implant_Sync` | The readout takes over the view | 3 s | no | - | A soft rising electronic whoosh with a tape-machine spin-up, a faint digital shimmer at the end, as if a dream is syncing in. |
| `AMB_Haze_1` / `_2` / `_3` | Haze layers, a low drone that thickens | 20 s each | yes | - | (1) A barely audible low sub drone, calm but uneasy. (2) A low drone with a slow dissonant swell and faint static. (3) A thick low drone, dissonant, with crackling static and a distant warped hum. |
| `SFX_Glitch_Burst` | The log corrupts | 1 s | no | - | A short harsh digital glitch: data stutter, a crackle of static and a clipped electronic squeal. |
| `SFX_Lights_Out` | Bad ending | 2 s | no | - | A heavy electrical power cut in a large hall: a deep thunk and a fading hum as the lights die, then silence. |
| `SFX_Verdict_Pass` | A take passes | 3 s | no | - | A warm soft swell of a single sustained chord fading out, gentle, a feeling of release. |
| `SFX_Verdict_Fail` | Before "Take two" | 2 s | no | - | An old machine powering down: an electrical whine dropping in pitch to a dull thud. |
| `AMB_Hall_Murmur` | Inside Des's dream, under the log | 20 s | yes | - | The muffled murmur of a school assembly hall full of teenagers, heard as if through a wall, indistinct, no clear words, no laughter. |

The hall murmur never has clear laughter in it; the laugh in the loop is carried by the log and
the lights going out.

## The AI break-in

| ID | Sound | Length | Loop | Batch | Prompt |
|---|---|---|---|---|---|
| `SFX_AI_Corrupt` | Data stutter, reversed, corrupted | 4 s | no | - | Corrupted digital audio: stuttering fragments, a reversed swell, bit-crushed crackles, as if a machine is breaking up. |
| `AMB_AI_Presence` | A tone that doesn't belong to the room | 20 s | yes | - | A clean, pure, slowly shifting synthetic tone, smooth and unnervingly perfect, with a faint glassy shimmer. |

## Music

| ID | Cue | Length | Batch | Prompt |
|---|---|---|---|---|
| `MUS_Wonderwell_Jingle` | Cold open ad (also listed above) | 15 s | A | See above. |
| `MUS_Room_Bed` | Quiet noir bed between takes, under the director | 90 s | - | Slow, sparse late-night noir: a lone muted trumpet, soft brushed drums, upright bass, a little rain-soaked reverb, melancholy and tired, very quiet. |
| `MUS_End_Sting` | End card | 10 s | - | A short noir sting: a low piano chord and a muted trumpet note held and fading, unresolved. |

## Batch A (first audition)

| Call | Endpoint | Seconds | Each | Total |
|---|---|---|---|---|
| `AMB_Rain_Window`, `AMB_Neon_Buzz`, `AMB_Monitor_Hum` | `elevenlabs/sound-effects/v3` | 3 x 20 | $0.002/s | $0.12 |
| `SFX_Projector_SpinUp`, 2 variations | `elevenlabs/sound-effects/v3` | 2 x 6 | $0.002/s | $0.024 |
| `MUS_Wonderwell_Jingle`, 2 samples | `sonilo/v1.1/text-to-music` | 2 x 15 | $0.0025/s | $0.075 |
| **Total** | | | | **about $0.22** |

Asked cap: $0.50, which covers a rerun of each.

## Full list, rough cost

About 30 effects at 1 to 30 s and three music cues come to roughly $1 to $2 with retries.
