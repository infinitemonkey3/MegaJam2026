# Room lines: things you can click at the desk

Provisional (2026-11-14), for Chip to cut and rewrite. The director's voice, `Orus` with the base
note (`audio/narration/README.md`): a tired, dry noir narrator. The angle for all of them: he used
to make pictures, real ones, before everyone's dreams came pre-made. Now he fixes cheap ones in a
back room. Each object has one or two lines; a second click plays the second line, then it stays
on the last one.

They play only while you're at the desk and the debugger is waiting on you (case file, menus,
CONTINUE), never during a take, and never over Nell or another director line.

## The posters (hidden in the room now; Sing, Meadow, Sing is coming back, the others are open)

**THE QUIET PARTNER** (gangster: three men under a streetlamp, a black car)
1. "The Quiet Partner. Shot it in nineteen nights, on a street we didn't have a permit for. The
   car was mine. So was the debt."
2. "Every gangster picture is the same picture. Somebody wants out. The town won't let him."

**SING, MEADOW, SING** (musical: a woman in a meadow, children dancing). His secret favourite
(Chip, 2026-11-14): the one soft spot in a hard man. **Approved; this poster goes back on the
wall.** One line only. **Built 2026-11-15** as the first clickable target: `Room_Poster_Musical` above Nell's recliner, line `room_poster_musical` (take A).
1. "Sing, Meadow, Sing. Don't look at me like that. I've seen it forty times. Forty-one."

**THE LAST PLANE OUT** (romance: a couple in a fog on an airfield)
1. "The Last Plane Out. Fog machine broke on day two. We used real fog. Nobody's ever matched it."
2. "Best ending I ever shot, and I didn't write it. She got on the plane. That was the point."

**TOMORROW IS RATIONED** (sci-fi: towers, a searchlight, one small man)
1. "Tomorrow Is Rationed. Picture about a company that sold people their dreams. Flopped. Too far-fetched."
2. "Look at the little guy in the corner. That's the audience. That was always the audience."

## Suggested objects

**The old film camera on the shelf (left)**. An antique by now, a museum piece, and he loves it
(Chip, 2026-11-14: show his fandom of this ancient form).
1. "Thirty-five millimetre. Older than my father. Real film runs through it, and the light gets
   in and stays there. Nothing in this building stays."
2. "I still oil it every Sunday. Can't buy film for it anymore. Doesn't matter. Some things you
   keep because they remember how it's done."

More options (2026-11-14, Chip asked for more; pick two):

3. "Twenty-four frames a second. Every one of them real. Every one of them, somebody had to be
   standing there."
4. "Back when you shot on film, you got one take. Maybe two. Made you careful. Made you mean it."
5. "Last roll I ever ran through her, I shot the rain outside this window. Ninety seconds. Best
   thing I've made in this room."
6. "Fella offered me a fortune for it once. I asked him what he'd shoot. He didn't have an
   answer. So he didn't get the camera."
7. "She's older than this building. Older than the company. Older than the idea you could sell
   somebody a dream."
8. "Light goes in, and it stays. Sixty years on, hold the film up to a window and there's the
   day, right where you left it."
9. "First thing they teach you: the camera doesn't lie. Second thing: everybody behind it does."
10. "Don't touch the crank. ...Fine. Gently. Feel that? That's a machine that wants to work."

**The fan**
1. "Every set I ever worked was too hot. Some things don't change."
2. "Leave it on. The quiet in here gets loud."

**The WARNING sticker on the monitor**
1. "Says don't open the case. I opened the case. That's why it works."
2. "Unlicensed. Unregistered. Same as me."

**The keyboard**
1. "Don't type at her. Talk. The machine reads, people listen."

**Nell, in the recliner**
1. "Seventy-one. Baked bread for thirty-eight years. Now she can't get out of one morning."
2. "Don't worry about waking her. Nobody wakes up in there. That's the job."

**The window**
1. "Rain again. It's always raining on this street. Saves on the effects budget."
2. "Out there, everybody's dreaming something they bought. In here we fix the ones that broke."

## How a clickable object is signalled (proposal)

- **Film-frame corners.** Each clickable object gets four thin viewfinder corners around it, like
  a camera's framing guides, in the debugger's teal, faint (about 30% opacity) and breathing
  slowly. That's the hint: framed things are things the director has something to say about.
  On theme, and they don't need new art per object.
- **Hover.** Over an object, the corners brighten to full and close in a little, and a small
  slate label appears beside them with the object's name (`THE QUIET PARTNER`, `CAMERA`, `NELL`),
  in the debugger's font. On a pad, D-pad left and right step between objects and the debugger.
- **After a click.** The corners dim to a faint "seen" state, so the player can tell what's left.
- **Introduced once.** The boot's tutorial line, or a new director line when the debugger first
  shows, points at them: "Take a look around while it boots. Everything in here's got a story."
- **Built the same way as the debugger:** screen-space Verse UI buttons placed by projecting each
  object's world rectangle onto the screen from the desk camera (`monitor_projection.verse`
  already does this for the monitor), with the corner and label widgets drawn over them.
