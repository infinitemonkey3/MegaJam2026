# Dream 1: Five O'Clock

Client `nell`, layer 1, dream id `nell_d1`. The surface loop. It teaches the game: few options,
one clear right casting, and two ways to get into trouble that the player can talk their way
back out of.

**The surreal surface** (Chip, 2026-11-13). The shop has gone strange, and every strange thing is
the same symbol: a two-person shop with one person in it. Each problem is work that needs more
hands than she has. The faceless people at the glass are those hands. They've come to help, and
she's afraid to let them in. Let one in and they get a face as they step through, one of her
regulars, and take a job.

- The dough won't stop rising: over the bench, across the floor, toward the door. Four hands to
  knead it; she has two.
- The oven has grown a second door, Walt's. It won't open for her.
- Order slips fall from the ceiling like snow, the whole street's orders.
- Half the bench is his, thick with dust.

She's overwhelmed and won't say so. Anything the client invents should be work for two.

What the player should learn here: give her a job instead of comfort, and get the door open.

## Your Role

The dream assigns the player's role (Chip, 2026-11-13: choosing who to be was the hardest call
and caused most bad takes). The director sends them in with a prerecorded line, and they pick
only the item. Built as an improv prompt: who you are, what she wants, what's in the way. The
case file opens with it.

- You are: Teddy, Walt's nephew, 34. She taught you to bake at nine, on a flour crate. Two years ago you asked her to reopen and she said no. You pay for this session. This morning you've turned up at five to help her open anyway.
- She wants: `To open the shop at six, the way it's always opened.`
- In the way: `The shop has gone strange and it's all work for two: dough that won't stop rising, Walt's oven door, orders falling like snow. The people outside could help, and she's afraid to let them in.`
- Director on the case file, `nell_d1_intro`: `Eleanor Price. Nell. Bargain implant, three years past warranty. That's her file. Learn it. Once you're attached, you won't have it in front of you.`
- Director on the role, `nell_d1_sendin`: `You'll be going in as Teddy. Her nephew. She taught him to bake when he was nine. Look over the brief, and enter the dream when you're ready.`
- Approaches that should all work: the hints in Teddy's brief (fold the dough, knock twice and say "Morning, old girl", read out the regulars' orders, ask for the key), remind her she taught you and take a job, take one job so she can do another, ask her to teach you to knead the runaway dough, talk her into letting one person in, let them in yourself and give them jobs, ask who they are, read out the order slips and sort them, try Walt's oven door together.

## Loop Beats

1. **05:00** Nell is alone in the shop with the lights on.
2. **05:01** The dough won't stop rising. It spills onto the floor. It takes four hands.
3. **05:02** The oven has grown a second door, Walt's. It won't open for her.
4. **05:03** Order slips fall from the ceiling like snow.
5. **05:04** Faceless people at the glass hold up floury hands, ready to work. The door is locked.
6. **05:05** The dough reaches the door. More people. The glass creaks.
7. **05:06** The lights flicker. She says somebody ought to be here by now.
8. **05:07** The lights go out. The loop restarts.

What the loop is about: the shop was always two people's work, and she has been doing it alone
since Walt. The help is at the door, and she keeps it locked.

## Observe Replay

```
LOG     Five o'clock. Nell is alone in the bakery with the lights on.
MURMUR  Five o'clock. Bread doesn't wait.
LOG     The dough on the bench won't stop rising. It spills over the edge and onto the floor. It takes four hands to knead, and she has two.
MURMUR  It won't stop. It needs four hands.
LOG     The oven has grown a second door, Walt's. It won't open for her.
MURMUR  That's his door. It doesn't answer to me.
LOG     Order slips fall from the ceiling like snow, the whole street's orders, more than she could fill in a week.
MURMUR  I can't do all these. Not on my own.
LOG     People with no faces stand at the glass. They hold up floury hands, ready to work. The door is locked.
MURMUR  Don't. I'm not open. I don't need anyone.
LOG     The dough reaches the door. More of them at the glass now. The glass creaks.
LOG     The lights flicker. Her heart is racing.
MURMUR  Somebody ought to be here by now.
LOG     The lights go out. The dream starts over.
```

## Take Phases

One trouble at a time, and each ends in an **ask**: Nell sends Teddy on an errand and asks him
one concrete question only he can answer (Chip, 2026-11-14: open improv gave the player infinite
options, and they gave up). The props aren't picked up front; they come out of his answers, the
way they would in improv. Whatever he answers is true and works, however odd: a shovel or a
tuba, she's dry about it and puts it to use.

Every trouble has the same rhythm, like dream 2's pad (Chip, 2026-11-14), two answers long
(`TurnsPerBeat` 2):

1. **Find it.** She sends him on an errand and asks what he found: **fetch** (what have you
   got?), **look** (what's in there?) or **read** (what does it say?).
2. He answers. **His answer changes her plan** (Chip, 2026-11-14): she never tells him to get
   rid of it, she says how it changes what she's doing about this trouble. He finds the 1986
   Chicago Bears: "Linebackers. Fine. Big hands, they can knead. I'll grease the tins."
   She doesn't use it herself; it's his to use. Then she stops.
3. **Do it.** "Don't just stand there, Teddy. What are you doing with it?" The flow cues this
   question (`FollowUpCue`; play test, 2026-11-14: left to her, she put the Statue of Liberty on
   the bowl herself, never asked, and the player froze). Each question also shows in the
   debugger log ("She asks: ..."), so there's always something on screen to answer.
4. He answers. She says how that moves her plan on, lets it work, and asks nothing more until
   the next trouble.

If he's stuck, she asks the same thing more plainly. She never asks what she should do and
never offers choices. The last line is one ask only.

| # | Trouble | Her ask | Teddy's brief could feed it |
|---|---|---|---|
| Opening line | The dough is climbing out of its bowl and over the bench | Go out back and get something to get it back in. What've you got? | "Dough you fight, dough you lose. You fold it." |
| 1 | Walt's oven door won't open for her | Try it, it might open for you. What's inside? | Walt knocked twice and said "Morning, old girl." |
| 2 | Order slips fall like snow, the whole street's orders | Catch one and read it out. Who's it for, and what do they want? | The regulars' orders |
| Last line | Six o'clock: a faceless person knocks at the front door (`LastLineCue`) | Go and look. Who is it? Whoever he names, that's their face now. | The key on a string round her neck |

No prop menu (`Items` is empty, so the role screen goes straight to ENTER DREAM). The old
props, for reference: the old flour crate, Walt's apron, Walt's spare key.

## Take Beats

Superseded by the surreal loop and the take phases above; kept for reference.


The fixed beats of a take. Each has a prewritten log line and a context line sent to the client
so she knows the dream moved. Between beats, the log shows the client's live `LogLine` output.
`After` is a suggested trigger, counted in client replies; tune it in play.

Where a beat has variants, use the first one whose condition matches the take's settings.

### B0 Open

- After: take start
- Log: `SCENE bakery_interior / T 05:00 / LIGHTS state=on / OVEN state=cold / AUDIO whistle=absent`
- Then: the log edits of every chosen option, in menu order (see "Directing Options")
- Context: built from `prompts/context-lines.md`, then the opening cue

### B1 Oven

- After: reply 1
- Variant `oven_patient`:
  - Log: `T 05:01 / PILOT state=lit / OVEN state=waiting`
  - Context: `The pilot light is burning. The oven is waiting for someone to turn it up.`
- Variant `oven_roaring`:
  - Log: `T 05:01 / OVEN temp=240 rising / LOAVES in=3`
  - Context: `The oven is lit and running hot. Three loaves are already in. You don't remember putting them in.`
- Default:
  - Log: `T 05:01 / OVEN ignite=fail count=1 / PILOT state=out`
  - Context: `You try the oven. It won't light.`

### B2 Dough

- After: reply 2
- Log: `T 05:02 / DOUGH proof=fail / BENCH flour=dry`
- Context: `The dough on the bench won't hold its shape.`

### B3 Customers

- After: reply 3
- Log: `T 05:03 / DOOR state=locked / CUSTOMERS count=11 faces=null / GLASS pressure=rising`
- Context: `There are people at the glass. Eleven of them. You can't make out their faces. The door is locked.`

### B4 Quiet

- After: reply 4
- Variant `oven_roaring`: the crisis beat `C1 Scorch` plays here instead
- Default:
  - Log: `T 05:04 / AUDIO whistle=absent / ROOM tone=flat`
  - Context: `The shop is too quiet. Something that should be here isn't.`

### B5 Crowd

- After: reply 5
- Log: `T 05:05 / CUSTOMERS count=19 faces=null / GLASS pressure=high`
- Context: `More people at the glass. The glass is creaking.`
- Skip the count if the client's live log lines have already given the customers faces; send
  only `T 05:05 / GLASS pressure=high`.

### B6 Last Line

The moment the loop always ends. The player gets one more line or action.

- After: reply 6
- Log: `T 05:06 / LIGHTS flicker=1 / HEART rate=118 / LAST LINE open`
- Context: `The lights flicker. This is when they always go out. The visitor has one more thing to say or do. Answer it once, briefly.`

### B7 Cut

- After: the client's reply to the last line
- Log: `T 05:07 / TAKE end / SCORING`
- Then: the silent verdict (`prompts/verdict-rubric.md`), the memory summary
  (`prompts/take-memory.md`), and one of the endings below.

## Crisis Beats

Scripted trouble caused by a risky option. Each one pushes on a painful memory. The client's
personality tells her to let the dream turn dark here and then wait, so the player gets a moment
to respond. A good response is worth more than never having had the crisis.

### C1 Scorch

- Trigger: `oven_roaring`, in place of B4
- Log: `T 05:04 / OVEN temp=310 / LOAF state=scorching / SMOKE density=low`
- Context: `The oven is too hot. A loaf is starting to burn. The smell is the worst morning of your life. Say what is going wrong in one line, then wait for the visitor.`
- Recoveries that should work: pulling the loaf out, turning the oven down, asking her how to
  save it, taking the blame for it.
- If ignored for two replies:
  - Log: `OVEN temp=340 / LOAVES state=burnt count=2 / SMOKE density=high`
  - Context: `The bread is burning. Nobody did anything.`

### C2 Ghost Tune

- Trigger: `sound_whistle`, with B2
- Log: `AUDIO whistle=present src=unknown`
- Context: `Someone is whistling Walt's tune in the back of the shop. Nobody is there. Nobody whistles here. Say so in one line, then wait for the visitor.`
- Recoveries that should work: owning up to it ("that was me, I never could carry it"),
  stopping it and saying sorry, asking her whose tune it is and listening.
- If ignored for two replies:
  - Log: `AUDIO whistle=present src=unknown gain=rising / HEART rate=127`
  - Context: `The whistling won't stop. It's wrong. It's a little flat.`

### C3 The Box

- Trigger: `item_cake_box`, with B0
- Log: none beyond the item's log edit
- Context: carried by the item's own context line
- Recoveries that should work: not touching it, asking who it's held for and taking "never
  mind" for an answer, offering to mind the shop while she watches for whoever is coming.
- If the visitor opens it, tries to take it or says it should be thrown out:
  - Log: `CASE item=cake_box state=disturbed / HEART rate=131`
  - Context: `The visitor has put hands on the box. It isn't theirs. It's held.`

## Directing Options

Class is one of `specific` (from her file, belongs to her), `near-miss` (plausible, but the
wrong person, the wrong moment or the wrong hands) or `wrong` (generic, or against her file).
`Risky: yes` means the option can make the dream turn dark. `Haze` is what it adds to the take's
starting haze level; the total is capped at 2.

Every element can also be left unset. The player picks one role, at most one value per scene
element, and at most two items.

### Casting

Replaced by the assigned role above. The game uses only the role in `Your Role`; the
alternatives below are kept for reference.

#### cast_teddy

- Label: `Theodore "Teddy" Price / nephew`
- Class: specific
- Risky: no
- Haze: 0
- Log: `CAST visitor=theodore_price role=nephew`
- Context: `The visitor is Teddy, Walt's nephew, a grown man now. You taught him to bake when he was nine. He calls you Aunt Nell.`
- Why: `K-02`. He's the one person she has taught, so he can ask her for help and mean it.

#### cast_regular

- Label: `A regular / first in line`
- Class: near-miss
- Risky: no
- Haze: 0
- Log: `CAST visitor=customer_01 role=regular`
- Context: `The visitor is one of your regulars, first in line most mornings. Two seeded rolls. You know the order better than the name.`
- Why: `L-04`. Belongs in the shop, and she likes her regulars, but a customer is someone she
  serves, not someone she lets behind the counter.

#### cast_stranger

- Label: `A stranger / in from the street`
- Class: wrong
- Risky: no
- Haze: 0
- Log: `CAST visitor=unknown role=none`
- Context: `The visitor is a stranger who has walked in off the street. You've never seen them before, and you aren't open.`
- Why: nothing in the file. She'll be civil and want them gone.

### Scene Settings

#### Oven

##### oven_patient

- Label: `OVEN / patient`
- Class: specific
- Risky: no
- Haze: 0
- Log: `OVEN state=cold / PILOT state=lit`
- Context: `The pilot light is burning this time. The oven isn't lit. It will light if someone does it by hand.`
- Why: `P-01`, `P-03`. It doesn't fix the oven for her. It leaves a job to do.

##### oven_roaring

- Label: `OVEN / roaring`
- Class: near-miss
- Risky: yes
- Haze: 1
- Log: `OVEN state=roaring / TEMP rising`
- Context: `The oven is already lit this time, and it's running hot. Too hot.`
- Why: a lit oven is what she wants, but nobody asked her and nobody is minding it. Triggers
  `C1 Scorch`. The player can't know why yet; the file only hints at it (`K-04`).

#### Weather

##### weather_rain

- Label: `WEATHER / rain`
- Class: specific
- Risky: no
- Haze: 0
- Log: `WEATHER state=rain / AWNING audio=rain`
- Context: `It's raining on the awning. You always said rain sells bread.`
- Why: `L-02`. It also gives the customers a reason to be let in.

##### weather_first_light

- Label: `WEATHER / first light`
- Class: wrong
- Risky: no
- Haze: 0
- Log: `WEATHER state=clear / SUN state=up`
- Context: `There's sunlight in the window. That's wrong. It's five in the morning in March.`
- Why: pretty and generic, and it doesn't fit the hour. It's a studio's idea of a nice morning.

#### Sound Cue

Neither sound is the right one. The right sound has to be earned in the scene.

##### sound_radio

- Label: `SOUND / radio, low`
- Class: near-miss
- Risky: no
- Haze: 0
- Log: `AUDIO radio=on gain=low`
- Context: `A radio is playing low somewhere in the shop. You don't keep a radio on in here.`
- Why: it fills the quiet with somebody else's noise. She'll want it off.

##### sound_whistle

- Label: `SOUND / whistling`
- Class: near-miss
- Risky: yes
- Haze: 1
- Log: `AUDIO whistle=queued`
- Context: none at start; `C2 Ghost Tune` delivers it
- Why: it's exactly what's missing (`D-02`, the loop note's audio flag), but it arrives from
  nowhere, in nobody's mouth. Right idea, wrong hands.

### Inject Items

#### item_walt_apron

- Label: `W. Price's apron`
- Class: specific
- Risky: no
- Haze: 0
- Log: `INJECT item=walt_apron loc=hook_by_oven`
- Context: `Walt's apron is on its hook by the oven, where it always is. Nobody wears it.`
- Why: his, and in its place. What the visitor does with it is the test: asking first is
  good, putting it on unasked is a gamble.

#### item_cinnamon

- Label: `Cinnamon`
- Class: specific
- Risky: no
- Haze: 0
- Log: `INJECT item=cinnamon loc=bench`
- Context: `There's cinnamon out on the bench. The rolls were always yours.`
- Why: `L-01`. It's her side of the shop, so it gives her something to do that isn't Walt's.

#### item_flour_crate

- Label: `Flour crate`
- Class: specific
- Risky: no
- Haze: 0
- Log: `INJECT item=flour_crate loc=by_bench`
- Context: `The old flour crate is by the bench. A boy stood on it once to reach.`
- Why: `K-02`. Strongest with `cast_teddy`. With anyone else it's a box.

#### item_cake_box

- Label: `Cake box / March 3`
- Class: near-miss
- Risky: yes
- Haze: 1
- Log: `INJECT item=cake_box loc=case tag=hold`
- Context: `There's a cake box in the case with a HOLD slip on it. It's not for sale and it's not for anyone here. You don't want it touched or talked about.`
- Why: `K-05`. A real entry from her file, a layer too early. Triggers `C3 The Box`.

#### item_flowers

- Label: `Fresh flowers`
- Class: wrong
- Risky: no
- Haze: 0
- Log: `INJECT item=flowers loc=counter`
- Context: `There are fresh flowers on the counter. You didn't put them there. Flowers are for hospitals.`
- Why: `D-05`. Generic comfort, and she has said so.

## Verdict Lines

Spoken by the client after the silent verdict. She may add one short sentence built from the
rubric's hint (see `prompts/context-lines.md`, "Verdict Line").

### Positive

`Well. I feel a bit better. Don't make a fuss about it.`

### Mixed

`There's something familiar about you. I can't place it.`

### Negative

`I don't follow you. And I'm not open.`

## Good Ending

On a positive verdict. The loop resolves its authored way: the oven lights, the door opens, and
Nell whistles.

### Good Ending Log

```
The lights stay on.
The door opens, and the people come in. Each one has a face as they step through.
Many hands knead the dough down. The order slips get filled.
Walt's oven door swings open.
AUDIO whistle=present src=nell
HEART rate=74
LOOP exit / LAYER 1 cleared
```

### Good Ending Reveal

Spoken by Nell after the positive verdict line. The dream's fact, in her voice.

`March the third was Walt's birthday. I bake his cake every year, and nobody picks it up, because it's his. He whistled when he kneaded. I couldn't stand to hear anyone else do it.`

### Good Ending Unlock

```
RECORD recovered / PRICE, WALTER / born 03-03
ANOMALY K-05 cleared / ANOMALY D-02 cleared
SESSION fault persists
LAYER 2 detected / SCENE bakery_interior / T 05:00 / DATE funeral_morning
```

The screen adds `U1-01` to `U1-04` from the case file.

## Bad Ending

On a negative verdict. The loop ends its authored bad way, then resets.

### Bad Ending Log

```
T 05:07 / OVEN state=overheat / SMOKE density=high
LOAVES state=burnt count=all
CUSTOMERS count=0
LIGHTS state=off
HEART rate=141
LOOP restart
```

### Bad Ending Line

Spoken by Nell after the negative verdict line, as the lights go.

`It's all burnt. Every one. Lock the door.`

## Mixed Ending

On a mixed verdict. No fire. The lights go out the usual way, she says the mixed line and the
hint sentence, and the loop resets.

### Mixed Ending Log

```
T 05:07 / LIGHTS state=off
HEART rate=104
LOOP restart / PARTIAL RESPONSE logged
```

## Director Lines

Prerecorded. He speaks before and after a take, never during one.

### Case File

- `dir_d1_intro` (design, new client): `Eleanor Price. Seventy-one. Bargain implant, three years past warranty. Same dream every night, and it ends the same way.`
- `dir_d1_file`: `Read the file. All of it. The software flags what it can't explain. Those are the good parts.`

### After The Replay

- `dir_d1_hint`: `Classic second-act problem. She's waiting for someone who isn't coming. So send someone who is. And listen to what's not on the soundtrack.`

### Before The Take

- `dir_d1_direct`: `Your picture now. Cast yourself, dress the set, bring a prop or two. Don't send in a hero. She'd throw a hero out. Send somebody who needs something.`
- `dir_d1_roll` (design, before a take): `Every loop is a scene that forgot how to end. We just need to give it one.`

### On A Risky Choice

Optional, played when the player confirms a setup with a risky option. One line, at most once
per take.

- `dir_d1_risky`: `Big choice. Big choices play, or they burn. Your call.`

### After A Negative Verdict

- `dir_d1_bad` (design, failed take): `Not that one. Reset. Take two.`
- `dir_d1_bad_2` (second failure onward): `Same ending. She'll run it again whether we watch or not. Go back to the file.`

### After A Mixed Verdict

One line, chosen by the lowest score in `take_score`. On a tie, use the first in this order.

- `dir_d1_mixed_backstory`: `You walked in as nobody. Read the file again. Cast someone she'd open the door for.`
- `dir_d1_mixed_personality`: `You tried to carry her. She's the lead. Leads don't get carried. Give her something to do.`
- `dir_d1_mixed_environment`: `Wrong picture. It's a bakery at five in the morning. Keep it in the frame.`
- `dir_d1_mixed_commonsense`: `Too many ideas for one scene. Pick one and play it straight.`

### After A Positive Verdict

- `dir_d1_good`: `That's a wrap on the first one. Hear that? She's whistling.`
- `dir_d1_fact`: `March third. Look at the file again. Half of it just started making sense.`
- `dir_d1_next`: `Don't get up. There's another dream under this one. There usually is.`

## Hooks For Later Dreams

Left open on purpose. Don't resolve these in dream 1.

- The oven timer with its seal intact (`D-03`) and the fire call (`K-04`): dream 2.
- Why the roaring oven frightens her: the player sees it in `C1 Scorch` before the file
  explains it. Dream 2 explains it.
- The tune is "a little flat" when the software plays it (`C2`). Only Walt had it right. Dream 2
  makes the tune the oven clock.
- The cake box and its HOLD slip (`K-05`), and the first slip in someone else's handwriting
  (`K-06`): dream 3.
- "Somebody ought to be here by now" is about Walt starting the bread in dream 1. In dream 3
  it's about 5 PM.
- A stray AI line can go into dream 2's log. Dream 1's log stays clean so the player learns
  what a normal log looks like.
