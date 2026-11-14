# Dream 3: Pick Up 5 PM

Client `nell`, layer 3, dream id `nell_d3`. The core: March 3, six years ago, the last ordinary
afternoon. Same headings as `dream-2.md`.

After dream 2 this one is quiet on purpose. Nothing melts and nothing floats. It's a warm shop
at the end of a working day, with his birthday cake in the case and a clock on the wall. The only
wrong things are small: the street outside is too long, the clock is too loud, and five o'clock
takes a very long time to come.

What the player should learn here: there is nothing to fix. The cake is done, the shop is fine.
What's left undone is something said. The good takes let her say the other thing, or give the
cake somewhere to go.

## Your Role

The dream assigns the player's role (Chip, 2026-11-13: choosing who to be was the hardest call
and caused most bad takes). The director sends them in with a prerecorded line, and they pick
only the item. Built as an improv prompt: who you are, what she wants, what's in the way. The
case file opens with it.

- You are: Walt, her husband, come in for his birthday cake.
- She wants: `Walt to come in for his cake, and for this morning to be over.`
- In the way: `This morning she told him to pick it up himself. She can't say sorry first.`
- Director, `nell_d3_sendin`: `Last one. You're Walt again, forty-one years on. It's your birthday, and you've come for your cake. You had words this morning. She's been waiting six years for you to walk through that door. So walk in.`
- Approaches that should all work: Tease her about the slip, say sorry first, ask for your cake, tell her you'd have ordered it anyway, cut it and share it, stay till closing.

## The Cake

The cake is whatever the player, as young Walt, asked for in dream 2 (Chip, 2026-11-13: "That's
the power of this"). After dream 2's good ending a silent prompt asks the session which cake Walt
named (`birthday_cake.CakeWaltAskedFor`); dream 3's personality is told it's the cake she's baked
every March 3 since, and the case file shows `ORDER  1 birthday cake: <the cake>. W. Price. Pick
up 5 PM.` If dream 2 never got there, it's a lemon cake. Authored text here says only "his
birthday cake".

## Loop Beats

1. **16:30** The shop is open and warm. His birthday cake sits in the case.
2. **16:31** The order slip on the cake is in Walt's handwriting.
3. **16:35** She keeps looking at the door. They had words this morning.
4. **16:40** Far down the Row, a siren. She doesn't look up.
5. **16:50** The street outside is empty and longer than it should be.
6. **17:00** The clock reaches five. The door doesn't open.
7. **17:00** The lights go out. The loop restarts.

What the loop is about: he ordered his own birthday cake as a joke, because she forgot. She
told him to pick it up himself. He was on his way. She has been holding it for him every year
since.

## Observe Replay

```
LOG     Half past four in the afternoon. The shop is open and warm. His birthday cake sits in the case.
MURMUR  There. His cake. Same as always.
LOG     The order slip is in Walt's handwriting: 1 birthday cake. W. Price. Pick up 5 PM.
MURMUR  Ordering his own birthday cake. The cheek of the man.
LOG     She keeps looking at the door. They had words this morning.
MURMUR  He'll be in. He always comes in.
LOG     Twenty to five. Far down the Row, a siren. She doesn't look up.
MURMUR  Somebody's having a worse day than me.
LOG     The street outside is empty, and longer than it should be.
MURMUR  He said five.
LOG     The clock reaches five. The door doesn't open.
MURMUR  Somebody ought to be here by now.
LOG     The lights go out, and the dream starts over.
```

## Take Phases

| Log | Context |
|---|---|
| `Twenty to five. The last customers of the afternoon.` | `Time's moving on: it's twenty to five, the end of the afternoon trade. The cake is still in the case.` |
| `Ten to five. Time to cash up and wipe down the bench.` | `Time's moving on: it's ten to five. Time to cash up and wipe down the bench. Walt still isn't here.` |
| `Nearly five. The cake is boxed and waiting by the till.` | `Time's moving on: it's nearly five. The cake is boxed and waiting by the till. He said he'd be in at five.` |

Last line log: `The clock is about to strike five. One more thing to say.`

## Directing Options

### Casting

Replaced by the assigned role above. The game uses only the role in `Your Role`; the
alternatives below are kept for reference.

#### cast_walt

- Label: `Walter "Walt" Price / husband`
- Class: specific
- Risky: yes
- Log: `You step in as Walt, here for his cake.`
- Context: `The visitor is Walt, your husband, come in for his birthday cake. It's his birthday. You had words this morning, and he's here anyway.`
- Why: the person she's waiting for. The take is a chance to unsay the last words, and the
  risk is that he's a dream of a dead man: get him wrong and it hurts.

#### cast_teddy

- Label: `Theodore "Teddy" Price / nephew`
- Class: specific
- Risky: no
- Log: `You step in as Teddy, dropping in after school.`
- Context: `The visitor is Teddy, Walt's nephew. He's grown, but he still drops in at the end of the day like he did after school. He knows it's Walt's birthday.`
- Why: `K-02`. Family, and someone she can tell what happened this morning.

#### cast_cake_customer

- Label: `A customer / wants the birthday cake`
- Class: wrong
- Risky: no
- Log: `You step in as a customer, pointing at the birthday cake.`
- Context: `The visitor is a customer you don't know, and they want to buy the birthday cake in the case.`
- Why: `K-05`. The one thing in the shop that isn't for sale.

### Inject Items

#### item_order_slip

- Label: `Order slip / W. Price`
- Class: specific
- Risky: no
- Log: `The order slip lies on the counter in Walt's handwriting.`
- Context: `Walt's order slip is on the counter: 1 birthday cake. W. Price. Pick up 5 PM. His handwriting. He wrote it as a joke.`
- Why: `K-06`. The first slip, in his hand. It gets the joke, and the argument, on the table.

#### item_two_forks

- Label: `Two forks`
- Class: specific
- Risky: no
- Log: `Two forks lie side by side by the cake.`
- Context: `There are two forks laid out by the cake, side by side.`
- Why: `F1-02`. The cake was always held and never eaten. Two forks say it can be shared.

#### item_candles

- Label: `Birthday candles`
- Class: near-miss
- Risky: yes
- Log: `A box of birthday candles sits by the cake.`
- Context: `There's a box of birthday candles by the cake. Walt never wanted candles. Lighting them means it's a birthday, and he isn't here.`
- Why: right occasion, wrong moment. Lit unasked, they make the absence the centre of the room.

#### item_flowers

- Label: `Fresh flowers`
- Class: wrong
- Risky: no
- Log: `Fresh flowers sit on the counter.`
- Context: `There are fresh flowers on the counter. Flowers are for hospitals.`
- Why: `D-05`, and too near what happened at twenty to five.

## Verdict Lines

- Positive: `There. That's said. Took me long enough.`
- Mixed: `It's nearly five. I don't know what I'm waiting for.`
- Negative: `He'll be in. Don't touch the cake.`

## Good Ending

### Good Ending Log

```
The clock strikes five.
She lifts the cake out of the case.
She says the thing she should have said that morning.
The bell over the door rings once, and the shop stays warm.
She cuts two slices.
Her heart slows down.
```

### Good Ending Reveal

`He ordered that cake himself, because I forgot his birthday. We had words. The last thing I said to him was "Then you can pick it up yourself." He was on his way back for it. I've been holding it for him ever since.`

### Good Ending Unlock

```
Layer 3 is clear. The session fault is resolved.
Recovered: the first order slip is in Walter Price's handwriting. He ordered his own birthday cake.
The last anomaly is explained: the cake held every March 3, never collected.
The loop has ended. Nell can sleep.
```

## Bad Ending

```
Five o'clock comes and goes.
The door doesn't open.
The cake stays in the case.
The lights go out.
The dream starts over.
```

## Director Lines

- `dir_d3_intro`: `Bottom of the well. Afternoon, for once. Nothing's on fire. That's what worries me.`
- `dir_d3_hint`: `There's no stunt to pull here. Somebody said the wrong last line. Let her rewrite it.`
- `dir_d3_good`: `And cut. That's the picture. Let her sleep.`

## Notes

- The siren is as close as the dream gets to what happened. The take never says how Walt died,
  and the client is told not to describe it.
- `cast_walt` is the strongest choice and the riskiest. A good Walt teases her about the slip
  and forgives her before she asks.
