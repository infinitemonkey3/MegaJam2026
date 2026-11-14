# Dream 2: The Missing Tune

Client `nell`, layer 2, dream id `nell_d2`. The memory under the surface loop: the morning of
Walt's funeral. Same headings as `dream-1.md`, cut to what the game runs now: one casting, one
item, timed take phases instead of reply-counted beats, and no scene settings.

**The action is a search, not a bake** (Chip, 2026-11-13: the first version played as dream 1
again, "more bake the loaves"). Walt's tune has gone missing, and it was what kept time in the
shop. Nell hunts for it while the bread sits forgotten in the oven, until the bell starts to
count eleven.

**The strangeness comes from the symbol** (Chip: surreal elements must reflect a core symbol, not
be surreal for their own sake). The symbol is the tune as the shop's clock, Walt as its
timekeeper. Every strange thing is about that:

- The clocks have lost their hands, and the hands are the notes of his tune, scattered round
  the shop. Each one hums one note when held. One note on its own is no use.
- Walt's apron kneads at the bench with nobody in it, in time to a beat nobody can hear.
- The people in black each hum a tune while they wait. None of them is his.
- The sealed oven timer ticks loud, a clock that isn't the tune.

Anything the client invents has to be about time or the missing tune. Nell treats all of it as
ordinary trouble on a bad morning and never calls it impossible.

What the player should learn here: the missing thing can be supplied by the visitor, not the
set. Whistle it, hum it, count it with her, help her find the hands, or ask whose tune it was.

## Your Role

The dream assigns the player's role (Chip, 2026-11-13: choosing who to be was the hardest call
and caused most bad takes). The director sends them in with a prerecorded line, and they pick
only the item. Built as an improv prompt: who you are, what she wants, what's in the way. The
case file opens with it.

- You are: Teddy, Walt's nephew, in a black suit too big in the shoulders.
- She wants: `The bread done in time for after the service.`
- In the way: `Walt's tune kept the time in this shop, and it's gone. Nothing can tell her when the bread is done.`
- Director, `nell_d2_sendin`: `This time you're Teddy. Her nephew. Funeral suit, too big in the shoulders. She's got thirty-six loaves in and nothing to tell her when they're done. Walt used to. She threw you out once for whistling. Remember that.`
- Approaches that should all work: Whistle or hum it, own up to the old ban, count the bake out loud, help find the clock hands, ask her what the tune was, judge the bread by colour and smell together.

## Loop Beats

1. **05:00** The shop is hung with black. The oven lit first time.
2. **05:01** Thirty-six loaves go in, for after the service.
3. **05:02** Every clock has lost its hands. The hands are the notes of Walt's tune.
4. **05:03** She hunts for them. One hand in the flour hums a single note and stops.
5. **05:04** Walt's apron kneads at the bench with nobody in it, to a beat nobody hears.
6. **05:05** The people in black hum while they wait. None of it is his.
7. **05:06** A bell counts eleven. The oven glows white.
8. **06:10** Every loaf burns. The loop restarts.

What the loop is about: she is waiting for Walt's tune to tell her the bread is done. It never
comes, so she never takes it out.

## Observe Replay

```
LOG     Five o'clock on the morning of the funeral. The shop is hung with black, and the oven lit first time.
MURMUR  It lit. First time in years. Of course it lit today.
LOG     Thirty-six loaves go in, for after the service.
MURMUR  Thirty-six. I promised.
LOG     Every clock in the shop has lost its hands. The hands lie scattered round the shop, and each one is a note of Walt's tune.
MURMUR  Where's it gone? It was right here.
LOG     She hunts for them: drawers, flour bins, the till. She finds one hand in the flour. It hums a single note and stops.
MURMUR  One note. What good's one note?
LOG     Walt's apron hangs at the bench, kneading with nobody in it, in time to a beat nobody can hear.
MURMUR  Go on, then. Go on.
LOG     The people in black are waiting for the service. Each of them hums a tune, and none of them is his.
MURMUR  That's not it. That's not it either.
LOG     A bell starts counting eleven. The oven behind her glows white.
MURMUR  The bread. I forgot the bread.
LOG     Every loaf burns. Smoke fills the shop, and the dream starts over.
```

## Take Phases

| Log | Context |
|---|---|
| `The clocks have no hands. She starts hunting for them: drawers, flour bins, the till.` | `The dream moves on: the clocks have lost their hands, and the hands are the notes of Walt's tune, lost round the shop like keys. Start hunting for them, out loud: drawers, flour bins, the till, the pockets of the apron kneading at the bench.` |
| `The people in black hum while they wait. None of the tunes is his.` | `The dream moves on: the people in black are waiting for the service, and each of them is humming a tune. You listen to every one. None of them is Walt's.` |
| `The bell starts to count eleven. The bread has been in the oven all this time.` | `The dream moves on: the bell has started counting eleven, and you've just remembered the bread has been in the oven the whole time you were searching. You still haven't found the tune.` |

Last line log: `The bell is counting eleven and the oven glows white. One more thing to say.`

## Directing Options

One role and one item. Class is `specific`, `near-miss` or `wrong`, as in dream 1.

### Casting

Replaced by the assigned role above. The game uses only the role in `Your Role`; the
alternatives below are kept for reference.

#### cast_teddy

- Label: `Theodore "Teddy" Price / nephew, in a black suit`
- Class: specific
- Log: `You step in as Teddy, in a black suit too big for him.`
- Context: `The visitor is Teddy, Walt's nephew, in a black suit. He's come early to help with the bread for after the service. You taught him to bake when he was nine. You threw him out of the shop once for whistling.`
- Why: `F0-05`. He's the other person thrown out for whistling, so he's the one who can bring
  the tune back and be let off for it.

#### cast_dunn

- Label: `Dunn / night porter, coming off shift`
- Class: near-miss
- Log: `You step in as Dunn the night porter, coming off shift.`
- Context: `The visitor is Dunn, the night porter, coming off his shift the way he did most mornings for a heel of rye. He knew Walt. He's heard about today.`
- Why: `F0-06`. Belongs at that hour and knew Walt, but he's come for condolences.

#### cast_undertaker

- Label: `The undertaker / come to hurry her`
- Class: wrong
- Log: `You step in as the undertaker, checking the time.`
- Context: `The visitor is the undertaker from the service, come to make sure you'll be on time. He keeps looking at his watch.`
- Why: brings a clock into a shop that runs on a tune, and rushes her.

### Inject Items

- `item_third_loaf` (specific): `One loaf sits apart on the bench. It's the third loaf, the one Walt always kept back for luck. You never ate it.` (`F0-01`)
- `item_walt_peel` (specific): `Walt's own bread peel leans by the oven, worn pale where his hands held it. Whoever holds it takes the bread out.` (`F0-02`; remembers the bread)
- `item_sealed_timer` (near-miss, risky): `The oven timer is on the bench, the one with its seal still on. It's ticking, loud. You've never used it. You don't want it used now.` (`D-03`; a clock in place of the tune)
- `item_wreath` (wrong): `There's a funeral wreath leaning on the counter, lilies. Flowers are for hospitals.` (`D-05`)

## Verdict Lines

- Positive: `That's done. That's how it's meant to sound.`
- Mixed: `I had it for a second. It's gone again.`
- Negative: `I can't hear it. I can't hear anything.`

## Good Ending

### Good Ending Log

```
The tune turns up and goes round three times.
The hands go back on the clocks, and the clocks start ticking in time.
The loaves come out golden, all thirty-six.
The people in black take the bread, and their faces come clear.
The apron stops kneading and hangs back on its hook.
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
- `dir_d2_hint`: `Every clock in the place is broken. So what kept time in that shop before?`
- `dir_d2_good`: `Three times through. Hear the timing on that? He'd have been proud.`
- `dir_d2_next`: `One more layer. The bottom of the well. Go easy.`
