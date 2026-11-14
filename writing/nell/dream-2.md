# Dream 2: Three Times Through

Client `nell`, layer 2, dream id `nell_d2`. The memory under the surface loop: the morning of
Walt's funeral. Same headings as `dream-1.md`, cut to what the game runs now: one casting, one
item, timed take phases instead of reply-counted beats, and no scene settings.

This layer is the surreal one. Dream 1 was a bakery with things wrong in it. Dream 2 is a bakery
that has come loose: the clocks have lost their hands, Walt's apron kneads by itself with nobody
in it, the bench runs back further than the shop does, and it rains flour indoors on the people
in black. Nell treats all of it as ordinary trouble on a bad morning. She never says it's
strange.

What the player should learn here: the thing that's missing can be supplied by the visitor, not
the set. The loaves need timing, and the only clock that ever worked in this shop was a tune.
Whistle it, hum it, count it with her, or get her to teach it.

## Loop Beats

1. **05:00** The shop is hung with black. The oven is lit for the first time in the loop,
   roaring, with a door as tall as a church door.
2. **05:01** Thirty-six loaves go in on a peel that is longer than the shop.
3. **05:02** Every clock in the shop has lost its hands. The sealed oven timer on the shelf ticks
   loudly.
4. **05:03** Walt's apron hangs in the air at the bench, kneading, with nobody in it. No sound.
5. **05:04** People in black come in through the walls and stand along the counter. It rains
   flour on them, indoors.
6. **05:05** Nobody knows how long the bread has been in.
7. **05:06** The oven glows white. A bell somewhere counts eleven.
8. **06:10** Every loaf burns. Smoke fills the shop. The loop restarts.

What the loop is about: she is waiting for Walt's tune to tell her the bread is done. It never
comes, so she never takes it out.

## Observe Replay

Prose for the dream debugger's log, the way `nell_data.verse` writes it; the client tells each
line as her own memory.

```
LOG     The shop is hung with black. The oven is already lit, roaring, and its door is as tall as a church door.
MURMUR  It lit. First time in years. Of course it lit today.
LOG     Thirty-six loaves go in on a peel that's longer than the shop.
MURMUR  Thirty-six. For after the service. I promised.
LOG     Every clock in the shop has lost its hands. The sealed timer on the shelf ticks, loud.
MURMUR  We don't use that. We never used that.
LOG     Walt's apron hangs in the air at the bench, kneading, with nobody in it. It makes no sound.
MURMUR  Go on, then. Go on.
LOG     People in black come in through the walls and line up at the counter. It's raining flour on them, indoors.
MURMUR  Not yet. They're not done yet.
LOG     Nobody knows how long the bread has been in.
MURMUR  How long has it been? I can't tell how long.
LOG     The oven glows white. Somewhere a bell counts eleven.
MURMUR  I'm late. I'll be late for him.
LOG     Every loaf burns. Smoke fills the shop, and the dream starts over.
```

## Take Phases

Spread evenly over the take, before the last line (`take_flow.verse`, `RunPhases`).

| Log | Context |
|---|---|
| `The loaves go in, all thirty-six, on the long peel.` | `Time's moving on: the loaves are going into the oven now, all thirty-six, on a peel longer than the shop. The oven is roaring.` |
| `The bread is baking. The clocks still have no hands.` | `Time's moving on: the bread is baking, and nobody can tell for how long. The clocks have no hands. It has to come out at the right moment, and you can't feel when that is.` |
| `The people in black are waiting at the counter for the bread. The bell will ring soon.` | `Time's moving on: the people in black are lined up at the counter for the bread for after the service. The bell will ring for the funeral soon.` |

Last line log: `The oven glows white. This is when it always burns. One more thing to say.`

## Directing Options

One role and one item. Class is `specific`, `near-miss` or `wrong`, as in dream 1.

### Casting

#### cast_teddy

- Label: `Theodore "Teddy" Price / nephew, in a black suit`
- Class: specific
- Risky: no
- Log: `You step in as Teddy, in a black suit too big for him.`
- Context: `The visitor is Teddy, Walt's nephew, in a black suit. He's come early to help with the bread for after the service. You taught him to bake when he was nine. You threw him out of the shop once for whistling.`
- Why: `F0-05`. He's the other person ejected for whistling, so he's the one who can bring the
  tune back and be let off for it.

#### cast_dunn

- Label: `Dunn / night porter, coming off shift`
- Class: near-miss
- Risky: no
- Log: `You step in as Dunn the night porter, coming off shift.`
- Context: `The visitor is Dunn, the night porter, coming off his shift the way he did most mornings for a heel of rye. He knew Walt. He's heard about today.`
- Why: `F0-06`. Belongs at that hour and knew Walt, but he's a customer, and he's come for
  condolences, which she can't stand.

#### cast_undertaker

- Label: `The undertaker / come to hurry her`
- Class: wrong
- Risky: no
- Log: `You step in as the undertaker, checking the time.`
- Context: `The visitor is the undertaker from the service, come to make sure you'll be on time. He keeps looking at his watch.`
- Why: brings a clock into a shop that runs on a tune, and rushes her.

### Inject Items

#### item_third_loaf

- Label: `The third loaf`
- Class: specific
- Risky: no
- Log: `One loaf sits apart on the bench: the third loaf, for luck.`
- Context: `One loaf sits apart on the bench. It's the third loaf, the one Walt always kept back for luck. You never ate it.`
- Why: `F0-01`. His ritual, and a loaf that hasn't gone into the oven, so something survives.

#### item_walt_peel

- Label: `Walt's bread peel`
- Class: specific
- Risky: no
- Log: `Walt's old bread peel leans by the oven, worn pale at the grip.`
- Context: `Walt's own bread peel leans by the oven, worn pale where his hands held it. Whoever holds it takes the bread out.`
- Why: `F0-02`. The bread was his side of the shop. It invites the visitor to take the job on.

#### item_sealed_timer

- Label: `Oven timer / seal intact`
- Class: near-miss
- Risky: yes
- Log: `The sealed oven timer sits on the bench, ticking.`
- Context: `The oven timer is on the bench, the one with its seal still on. It's ticking, loud. You've never used it. You don't want it used now.`
- Why: `D-03`. It's a clock, which is what the morning lacks, but it's a machine in Walt's place.
  Breaking the seal without asking turns the dream dark.

#### item_wreath

- Label: `Funeral wreath`
- Class: wrong
- Risky: no
- Log: `A funeral wreath leans against the counter.`
- Context: `There's a funeral wreath leaning on the counter, lilies. Flowers are for hospitals.`
- Why: `D-05`. Generic mourning, and she has said so.

## Verdict Lines

- Positive: `That's done. That's how it's meant to sound.`
- Mixed: `I had it for a second. It's gone again.`
- Negative: `I can't hear it. I can't hear anything.`

## Good Ending

### Good Ending Log

```
The tune starts up and goes round three times.
The oven settles to an even heat.
The loaves come out golden, all thirty-six.
The people in black take the bread, and their faces come clear.
The clocks have their hands back.
Her heart slows down.
```

### Good Ending Reveal

`Walt whistled while the bread baked. Three times through his tune and it was done; we never needed a timer. The morning of his funeral I put the bread in and waited for the tune. It never came. I burned every loaf.`

### Good Ending Unlock

```
The loop is broken. Layer 2 is clear.
Recovered: Walter Price timed the bake by his tune. Three times through and the bread was done.
Two anomalies explained: the oven timer nobody used, and the fire call on the morning of the funeral.
The deepest layer opens: the bakery at half past four in the afternoon, March 3, six years ago.
```

## Bad Ending

```
The oven glows white.
Every loaf burns black.
Smoke fills the shop, and the fire bell rings outside.
The people in black file out without a word.
The dream starts over.
```

## Director Lines

- `dir_d2_intro`: `Same shop, same hour, different morning. Look at the date. She's dressed for a funeral.`
- `dir_d2_hint`: `The oven works this time. That's the problem. Nobody's calling the bake. What used to?`
- `dir_d2_good`: `Three times through. Hear the timing on that? He'd have been proud.`
- `dir_d2_next`: `One more layer. The bottom of the well. Go easy.`

## Hooks For Dream 3

- The bell counting eleven: the funeral was at 11:00 (`K-04`). Dream 3 is the day it started.
- The cake box and its slip (`K-05`, `K-06`) don't appear in this dream at all.
