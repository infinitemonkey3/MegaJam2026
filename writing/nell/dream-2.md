# Dream 2: Twenty Questions

Client `nell`, layer 2, dream id `nell_d2`. The memory under the surface loop: the night young
Nell decided about Walt, 47 years ago. Same headings as `dream-1.md`, cut to what the game runs:
an assigned role, one item, timed take phases, no scene settings.

A cute one, between two sad layers (Chip, 2026-11-13). Nell is 24 and works the counter at
Hollis's Tea Room. Walt Price, 27, delivers flour for the mill, whistles a tune he swears he
wrote, and has bought one of her cinnamon rolls every day for a month. Tonight she has agreed to
hear his case, at closing, and she has her questions written on her order pad. She takes his
answers like an order.

The symbol is the order slip. She writes him down the way she'll write orders for the next 44
years, and if he wins her over, the last thing she writes is his birthday cake. That's the cake
she holds in the case every March 3, and the slip comes back in dream 3.

## Your Role

- You are: Walt Price, 27, flour on your jacket. Here to make your case.
- She wants: `To find out if Walt Price is worth a yes, without letting on that she likes him already.`
- In the way: `She has decided not to be charmed, and it's nearly nine. The tea room closes at nine.`
- Director on the case file, `nell_d2_intro`: `She let us down a layer. Her file's grown since you last read it. Learn the new parts, then attach.`
- Director on the role, `nell_d2_sendin`: `This time you'll be Walt Price, twenty-seven, flour on his jacket. This is the night she made up her mind about him. Look over Walt, and enter the dream when you're ready.`
- Approaches that should all work: specific, honest answers; making her laugh; asking about her
  baking and her plans; owning up to the whistling; teasing back; admitting he's nervous; a
  real plan for a date instead of a grand one.

What wins her: specifics, honesty, humour, and anything that takes her work seriously. What
doesn't: bragging, flattery that could be said to anyone, grand gestures. She never sends him
away; a bad answer just gets written down with a look.

## Loop Beats

1. **20:50** Hollis's Tea Room at closing. Nell, 24, behind the counter with her order pad.
2. **20:51** Walt Price comes in, whistling, flour on his jacket.
3. **20:52** She opens the pad. Her questions are written on it.
4. **20:55** She asks the first one, and he opens his mouth.
5. **21:00** The clock strikes nine. Mrs. Hollis turns the sign. He hasn't answered anything.
6. **21:00** The lights go out. The loop restarts.

What the loop is about: every night he comes in, and every night time runs out before she's
decided. She never hears his answers, so she never says yes.

## Observe Replay

```
LOG     Hollis's Tea Room, ten to nine. Nell, twenty-four, wipes the counter with her order pad in her apron pocket.
MURMUR  If he's coming, he'd better come.
LOG     Walt Price comes in from the rain, whistling, flour on his jacket.
MURMUR  And he can stop that, for a start.
LOG     She opens the order pad. Her questions are written down the first page.
MURMUR  I've got questions. I'm not daft.
LOG     She asks the first one. He opens his mouth to answer.
MURMUR  First one's easy. Cinnamon or lemon?
LOG     The clock strikes nine. Mrs. Hollis turns the sign to CLOSED. He hasn't said a word.
MURMUR  That's nine. Typical.
LOG     The lights go out, and the dream starts over.
```

## Take Phases

The take runs on turns (`TurnsPerBeat := 1`): after each answer and her reply, the next thing on
her pad. First three this-or-that guesses about her, which reward reading her file (Chip,
2026-11-14), then the real questions.

| # | Log | Her answer / note |
|---|---|---|
| Opening line | `Cinnamon or lemon?` | Cinnamon, every time (`L-01`) |
| 1 | `Guess two on her pad: rain or sunshine?` | Rain: rain sells bread (`L-02`) |
| 2 | `Guess three on her pad: flowers, or a sack of good flour?` | The flour: flowers are for hospitals (`D-05`) |
| 3 | `The guessing's done. First real question: how would we spend a Saturday?` | Free answer |
| 4 | `Next on her pad: what about my baking?` | Would he mind her having a trade of her own? |
| 5 | `Last on her pad: why me? The clock says five to nine.` | The hard one |

A right guess pleases her more than she lets on; a wrong one she corrects, drily. "What would
our life together be like" was cut to keep the take short (and less romance for moderation).

Last line log: `The clock is about to strike nine. One more thing to say.`

## Directing Options

### Casting

Assigned: Walt Price (see Your Role).

### Inject Items

- `item_cinnamon_roll` (specific): `He's holding one of your cinnamon rolls. He's bought one every day this month. He never eats it in front of you.` (`L-01`; he's been courting her with her own baking)
- `item_flour_sack` (specific): `There's a sack of flour from the mill on the counter, a gift. Good flour, the kind Mrs. Hollis won't pay for.` (`F0-02`; his trade, and it takes her work seriously)
- `item_cinema_tickets` (near-miss): `He's got two tickets to the pictures in his hand. Saturday. He didn't ask what you'd like to see.` (a fine date, but nobody asked her)
- `item_roses` (wrong): `He's brought a bunch of red roses. Flowers are for hospitals.` (`D-05`)

## The Cake Carries Forward

Whatever cake the player names here becomes the cake in dream 3: after a good ending, a silent
prompt asks the session which cake Walt asked for, and dream 3 bakes it (`AsksForCake` here,
`UsesCake` there). Lemon if he never said.

## Verdict Lines

- Positive: `Well. You'll do. Don't let it go to your head.`
- Mixed: `Ask me again next week.`
- Negative: `We're closing.`

## Good Ending

On a positive verdict. During the take, once he's won her over, she tells him so in her own dry
way and asks what kind of birthday cake he'd like, and writes it on the pad. The ending tells
the rest.

### Good Ending Log

```
She puts down the pencil.
She tears the top slip off the order pad and keeps it.
Mrs. Hollis turns the sign, and nobody minds.
She lets him walk her home in the rain.
He's whistling. She doesn't tell him to stop.
```

### Good Ending Reveal

`I made him answer every question on my pad. The last thing I wrote down was what cake he'd want for his birthday. I kept that slip. I baked him that cake every March the third for thirty-eight years.`

### Good Ending Unlock

```
The loop is broken. Layer 2 is clear.
Recovered: the first order Nell took from Walter Price. One birthday cake.
Anomaly explained: the order slip from Hollis's Tea Room, kept in her purse for 47 years.
The deepest layer opens: the bakery at half past four in the afternoon, March 3, six years ago.
```

## Bad Ending

```
Nine o'clock. Mrs. Hollis turns the sign.
Nell puts the pad away. The answers are blank.
Walt goes out into the rain, whistling.
The lights go out.
The dream starts over.
```

## Director Lines

- `dir_d2_intro`: `Different reel. She's twenty-four, and she's got a list.`
- `dir_d2_good`: `She kept the slip. Of course she kept the slip.`
- `dir_d2_next`: `One more layer. The bottom of the well. Go easy.`

## Changes To The Arc

This replaces the funeral-morning dream. The case file's fire call (`K-04`) and the sealed
oven timer anomaly (`D-03`) paid off there, so `K-04` is now the Hollis's slip in her purse, which
this dream explains, and `D-03` is a plain dislike. The funeral-morning burning stays in dream 1's
personality as backstory.
