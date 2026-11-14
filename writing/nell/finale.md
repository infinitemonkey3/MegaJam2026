# Finale: Nell

Draft for Chip to approve (written 2026-11-14, overnight). It follows the design's jam-slice
ending (`docs/design.md`, "Jam slice", steps 5-8), which was written for Des, adapted to Nell.
Everything here is **scripted**, not LLM-driven: reliable for judges and for the video.

It plays after dream 3's good ending: the LAYER CLEARED banner, then this instead of the next
layer (`take_flow.DoFinale`, a placeholder today).

## 1. The moment, then again

Dream 3's good ending has just shown: the clock strikes five, she lifts the cake out, says the
thing she should have said, cuts two slices. The log carries on, each line with a short
pause, and no CONTINUE. The AI breaks in.

```
The loop is resolved. Exit pending.
wait
she's smiling. is that what it looks like when it ends
The clock goes back to five to five.
again
She cuts two slices.
The clock goes back to five to five.
again
again
Her heart is racing.
```

- The haze clears on "resolved", then floods back to full on the first "again".
- Vitals climb to full.
- Optional: Nell's positive line ("There. That's said. Took me long enough.") replays from the
  persona on each restart.

**The AI's voice** (prerecorded, a new voice: polite, eager, a little too bright):
`Once more. I want to see how it's done.`

## 2. The director cuts it

For the first time not dry, and afraid (prerecorded, Orus):
`That's not us. Pull her out. Pull her out!`

The debugger goes black, the haze drops, and there's rain, the room's rain loop.

## 3. Nell wakes

In the recliner, awake and confused. Fixed text, spoken by the persona told to say exactly
this, or prerecorded if that isn't reliable:

`Where's... This isn't the shop. I had the dream again. Only it ended.` A beat.
`Thank you, love. I don't know what for. Thank you.`

## 4. The director, quietly

`She said thanks.`

This answers his line from after earlier rescues, "They never say thanks." The jam slice has
no earlier rescue to set it up, so it could gain one dry line after dream 1's LAYER CLEARED
instead: `nell_d1_solved`: `She's through the first one. They never say thanks. They don't
remember us.`

## 5. End card

Black. `WONDERWELL`, a thank-you, the credits, and the hint: `Someone else is dreaming the same
dream.`

## What it needs

- **Audio, 3 new lines:** the AI's line (a new voice; pick from a short audition), the
  director's "Pull her out!", and "She said thanks". Optionally `nell_d1_solved`. The same fal
  TTS endpoint, about $0.10.
- **Nell's waking line:** the persona with a fixed-text prompt (the `SpeakLine` path that already
  says `FactRevealed`), or a TTS line in her voice if the persona paraphrases it.
- **Verse** (`DoFinale`): log lines on a timer, haze and vitals, the audio players, a black
  overlay, the waking line, the end card on the dream debugger. About 1-2 hours.
- **Decisions for Chip:**
  - Keep the AI break-in, or end straight on the waking and "She said thanks"?
  - The AI's voice: same director voice pitched oddly, or a new TTS voice?
  - The end card's hint line.
