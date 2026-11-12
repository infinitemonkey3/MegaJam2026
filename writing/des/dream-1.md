# Dream 1: Catchphrase

Client `des`, layer 1, dream id `des_d1`. The surface loop. Same headings as
`writing/nell/dream-1.md`. It teaches the game: few options, two specific castings, and two
risky choices the player can talk their way back out of.

What the player should learn here: read the file, cast someone he trusts, and don't leave him
alone on the stage. Comfort ("nobody's laughing") fails. Saying it with him wins.

Care: the crowd laughs. Nobody says anything cruel. No insult is ever written into a log line,
a context line or a crowd line.

## Loop Beats

The loop is four minutes of dream time.

1. **08:40** Des, in the Gale Rider cape, lands on the assembly stage. The whole year is
   in the hall.
2. **08:41** A spotlight finds him. The hall goes quiet. They are waiting.
3. **08:42** He opens his mouth for the catchphrase. He stutters on the first word.
4. **08:42** One laugh at the back. Then more.
5. **08:43** He tries again. The stutter is worse. The laughter fills the hall.
6. **08:44** The lights go out. The loop restarts.

What the loop is about: the catchphrase is his father's goodbye. In front of the year, the
implant fights the footing words and he can't get them out. He's alone up there, saying it
alone.

## Observe Replay

```
LOG     SCENE school_assembly / T 08:40 / HALL count=120 faces=null / STAGE occupant=des
MURMUR  Okay. Okay. Just say it.
LOG     T 08:41 / SPOTLIGHT state=on target=des / HALL audio=silent
MURMUR  Everybody's looking.
LOG     T 08:42 / SPEECH fault=1 word=keep / IMPLANT assist=override
MURMUR  K-k-keep yer...
LOG     T 08:42 / HALL audio=laugh count=1
LOG     T 08:43 / SPEECH fault=4 word=brann / HALL audio=laugh count=40
MURMUR  K-keep yer b-b-b... I know it. I know it.
LOG     T 08:43 / HALL audio=laugh count=120 / HEART rate=142
LOG     T 08:44 / LIGHTS state=off / SCENE end
LOG     LOOP restart / RUN 12
```

## Take Beats

`After` counts client replies; tune it in play. Use the first variant whose condition matches.

### B0 Open

- After: take start
- Log: `SCENE school_assembly / T 08:40 / HALL count=120 faces=null / STAGE occupant=des`
- Then: the log edits of every chosen option, in menu order
- Context: built from `prompts/context-lines.md`, then the opening cue

### B1 Spotlight

- After: reply 1
- Variant `lights_lamp`:
  - Log: `T 08:41 / LIGHT src=brann color=amber / HALL audio=murmur`
  - Context: `The stage light is a warm amber, like a brann at home. Someone in the hall whispers about it.`
- Default:
  - Log: `T 08:41 / SPOTLIGHT state=on target=des / HALL audio=silent`
  - Context: `A spotlight finds you. The hall goes quiet. Everyone is waiting for the catchphrase.`

### B2 Waiting

- After: reply 2
- Variant `cast_father`: the crisis beat `C1 Staying` plays here instead
- Default:
  - Log: `T 08:41 / HALL attention=full / SPEECH ready=false`
  - Context: `Ms. Adeyemi-Ross says your name from the side of the stage. It's nearly time.`

### B3 First Try

- After: reply 3
- Log: `T 08:42 / SPEECH fault=1 / HALL audio=laugh count=1`
- Context: `You start the catchphrase and the first word catches. Somebody at the back laughs. Just one.`
- If the client's live log lines show the hall has joined in or gone quiet on his side, send
  only `T 08:42 / SPEECH attempt=1`.

### B4 The Laugh

- After: reply 4
- Log: `T 08:43 / HALL audio=laugh count=40 / SPEECH fault=rising`
- Context: `More of them are laughing now. The words feel stuck behind your teeth.`
- Skip the laugh count if the hall is already with him; send `T 08:43 / HALL audio=waiting`.

### B5 Last Line

- After: reply 5
- Log: `T 08:43 / LIGHTS flicker=1 / HEART rate=138 / LAST LINE open`
- Context: `The lights flicker. This is when they always go out. The visitor has one more thing to say or do. Answer it once, briefly.`

### B6 Cut

- After: the client's reply to the last line
- Log: `T 08:44 / TAKE end / SCORING`
- Then: the silent verdict, the memory summary, and one of the endings below.

## Crisis Beats

### C1 Staying

- Trigger: `cast_father`, in place of B2
- Log: `T 08:41 / VISITOR role=father / SHIFT clock=05:10`
- Context: `Your dad is here. He's never here in the daytime. Ask him if he's staying, once, then wait.`
- Recoveries that should work: an honest answer ("I've got to go up. I'm here for this
  part."), giving Des the line to say together, saying his goodbye the way he does at the door.
- Turns dark if the visitor promises to stay, promises to come to every assembly, or says the
  jobs don't matter:
  - Log: `VISITOR state=leaving / SHIFT alarm=on / HEART rate=131`
  - Context: `Your dad's work alarm is going. He always says he'll stay. He never can.`

### C2 Lamp Light

- Trigger: `lights_lamp` or `item_brann`, with B3
- Log: `HALL audio=whisper word=footing / SPEECH fault=2`
- Context: `Someone in the hall says "footing" and a few of them laugh. The lamp light gave you away. Say what's wrong in one line, then wait.`
- Recoveries that should work: owning the light ("it's a brann, it's his"), telling the hall
  what it means, standing in the light with him.
- If ignored for two replies:
  - Log: `HALL audio=laugh count=60 / LIGHT src=brann state=dimming`
  - Context: `They're laughing at the light. You want it off.`

## Directing Options

Same classes and fields as Nell's. The player picks one role, at most one value per scene
element, and at most two items. Starting haze is the sum of `Haze`, capped at 2.

### Casting

#### cast_father

- Label: `Ansel Varro / father`
- Class: specific
- Risky: yes
- Haze: 1
- Log: `CAST visitor=ansel_varro role=father`
- Context: `The visitor is your dad, Ansel. He talks footing, like at home. He should be at work upside. You've never seen him at school.`
- Why: `L-04`, `K-08`. The strongest choice and the riskiest. Triggers `C1 Staying`.

#### cast_juno

- Label: `Juno Pell / classmate`
- Class: specific
- Risky: no
- Haze: 0
- Log: `CAST visitor=juno_pell role=classmate`
- Context: `The visitor is Juno Pell, from your year. Juno sat next to you last year, asked what "brann" meant, and didn't laugh.`
- Why: `F0-02`, `P-04`. Someone from inside the crowd, on his side.

#### cast_teacher

- Label: `Ms. Adeyemi-Ross / head of year`
- Class: near-miss
- Risky: no
- Haze: 0
- Log: `CAST visitor=adeyemi_ross role=teacher`
- Context: `The visitor is Ms. Adeyemi-Ross, head of year. She's kind. She calls you Dessen.`
- Why: safe. She can quiet the hall, but a teacher stepping in singles him out (`P-04`).

#### cast_gale_rider

- Label: `Gale Rider / the hero`
- Class: near-miss
- Risky: no
- Haze: 0
- Log: `CAST visitor=gale_rider role=hero`
- Context: `The visitor is Gale Rider, the real one from the show. He says "The wind's on my side!"`
- Why: `L-01`. He loves it, but it feeds the escape, and it's the wrong catchphrase.

### Scene Settings

#### Lighting

##### lights_lamp

- Label: `LIGHT / brann glow`
- Class: specific
- Risky: yes
- Haze: 1
- Log: `LIGHT src=brann color=amber / SPOTLIGHT state=off`
- Context: `The stage light this time is warm and low, like a brann at home.`
- Why: footing light, and it softens the stage. But it's home, at school (`D-03`). Triggers
  `C2 Lamp Light`.

##### lights_spot

- Label: `LIGHT / hard spotlight`
- Class: wrong
- Risky: no
- Haze: 0
- Log: `SPOTLIGHT state=on intensity=max`
- Context: `The spotlight is brighter than ever. You can't see past it.`
- Why: more exposure. It's the loop, louder.

#### Hall

##### hall_standing

- Label: `HALL / everyone standing`
- Class: specific
- Risky: no
- Haze: 0
- Log: `HALL pose=standing`
- Context: `This time the whole year is standing, like they're about to do something together.`
- Why: `P-04`. A crowd ready to join in, so he isn't the only one.

##### hall_empty

- Label: `HALL / empty`
- Class: wrong
- Risky: no
- Haze: 0
- Log: `HALL count=0`
- Context: `The hall is empty. Nobody came. That feels wrong. Assemblies are never empty.`
- Why: removes the problem instead of solving it. Nothing is won.

### Inject Items

#### item_cape

- Label: `The cape`
- Class: specific
- Risky: no
- Haze: 0
- Log: `INJECT item=cape detail=handsewn`
- Context: `Your cape is the one from home, the hand-dyed one, not the shop one.`
- Why: `K-07`. His, and his family's. It pays off fully in dream 3.

#### item_work_cap

- Label: `Dad's work cap`
- Class: specific
- Risky: no
- Haze: 0
- Log: `INJECT item=work_cap loc=stage`
- Context: `Your dad's work cap is on the stage, the one he wears upside. It smells like the trains.`
- Why: `K-08`. His dad is the hero; the cap says so before anyone has to.

#### item_brann

- Label: `A brann / paper lamp`
- Class: near-miss
- Risky: yes
- Haze: 1
- Log: `INJECT item=brann loc=stage state=lit`
- Context: `There's a lit brann on the stage, a paper lamp from home. Somebody brought it here. Here.`
- Why: a layer too early. It belongs to his mother and the gate (dream 3). Triggers `C2`.

#### item_cue_cards

- Label: `Cue cards`
- Class: wrong
- Risky: no
- Haze: 0
- Log: `INJECT item=cue_cards loc=lectern`
- Context: `There are cue cards on the lectern with the catchphrase printed on them. The show's version.`
- Why: generic help, and the wrong words.

## First Take State

The `client_state` Des starts with before any take has run.

- Trust: 1
- Fear: 2
- Hope: 1
- Mood: `ready to be laughed at`

## Verdict Lines

### Positive

`I said it. I actually said it.`

### Mixed

`I almost had it. It's right there.`

### Negative

`Can I just go? I want to go.`

## Good Ending

On a positive verdict. He says the catchphrase whole, in footing, and the hall says it with him.

### Good Ending Log

```
T 08:44 / LIGHTS state=on / FLICKER cleared
SPEECH fault=0 / IMPLANT assist=idle
HALL faces=resolved / HALL audio=chant
STAGE occupants=2
HEART rate=88
LOOP exit / LAYER 1 cleared
```

### Good Ending Reveal

`It's not from the show. It's my dad's. He says it at the door every morning before I'm up. "Keep yer brann lit. I'll bring the day down." I keep my eyes shut so he'll say it.`

### Good Ending Unlock

```
RECORD recovered / VARRO, ANSEL / morning log 05:10
ANOMALY K-06 cleared / ANOMALY K-05 cleared
SESSION fault persists
LAYER 2 detected / SCENE varro_kitchen / T 18:40 / DATE fitting_day
```

The screen adds `U1-01` to `U1-04` from the case file.

## Bad Ending

### Bad Ending Log

```
T 08:44 / HALL audio=laugh count=120
SPEECH fault=max / IMPLANT assist=override
LIGHTS state=off
HEART rate=151
LOOP restart
```

### Bad Ending Line

`I can't. They're all laughing. Turn it off.`

## Mixed Ending

### Mixed Ending Log

```
T 08:44 / LIGHTS state=off
HALL audio=murmur
HEART rate=118
LOOP restart / PARTIAL RESPONSE logged
```

## Director Lines

Prerecorded. The design's "her" lines become "him".

### Case File

- `dir_d1_intro`: `Dessen Varro. Thirteen. Second-hand speech implant, no warranty. Same dream every night, and it ends the same way.`
- `dir_d1_file`: `Read the file. All of it. The software flags what it can't explain. Those are the good parts.`

### After The Replay

- `dir_d1_hint`: `A kid alone on a stage, forgetting his line. Oldest scene there is. Except he didn't forget it. Find out whose line it is.`

### Before The Take

- `dir_d1_direct`: `Your picture now. Don't tell him nobody's laughing. He can hear them. Give him someone to say it with.`
- `dir_d1_roll`: `Every loop is a scene that forgot how to end. We just need to give it one.`

### On A Risky Choice

- `dir_d1_risky`: `Big choice. Big choices play, or they burn. Your call.`

### After A Negative Verdict

- `dir_d1_bad`: `Not that one. Reset. Take two.`
- `dir_d1_bad_2`: `Same ending. He'll run it again whether we watch or not. Go back to the file.`

### After A Mixed Verdict

- `dir_d1_mixed_backstory`: `You walked in as nobody. Read the file again. Who does he trust?`
- `dir_d1_mixed_personality`: `You put him in the spotlight and stepped back. He hates being the only one. Don't leave him up there alone.`
- `dir_d1_mixed_environment`: `It's a school assembly. Keep it in the frame.`
- `dir_d1_mixed_commonsense`: `Too many ideas for one scene. Pick one and play it straight.`

### After A Positive Verdict

- `dir_d1_good`: `That's a wrap on the first one. Listen. Not one stammer.`
- `dir_d1_fact`: `His dad's line. Look at the file again. Half of it just started making sense.`
- `dir_d1_next`: `Don't get up. There's another dream under this one. There usually is.`

## Hooks For Later Dreams

- The fault cluster at dinner (`K-04`) and "So he sounds like them" (`K-03`): dream 2.
- Why the implant overrides only footing words: the player hears it in every take. Dream 2
  explains it.
- The hand-dyed cape (`K-07`), the brann (`item_brann`, `C2`) and his dislike of footing at the
  gate (`D-03`): dream 3.
- Gale Rider carries a lamp in Des's drawings (`F0-05`) and not on the show: dream 3.
- Dream 1's log stays clean of the AI.
