# Submission

Wonderwell's entry for the 2026 Epic AI MegaJam, UEFN track. Deadline: **Sun Nov 15, 5:59 PM
PST / 8:59 PM EST**. Late entries are disqualified.

Sources: the jam page (https://itch.io/jam/2026-epic-ai-megajam), read 2026-11-15. The page is a
summary of the Official Rules (a Box link that didn't load for the agent) and points to the
Fortnite Developer Rules (behind an Epic login). **Chip: skim both yourself before submitting.**

## Blockers, in order

1. **Private version code.** Developer Terms enrollment cleared (2026-11-15, afternoon), so
   the island can be published as a private version once the build is final.
2. **Debug start is off** (2026-11-15): every Game Director debug setting is at its default
   (title start, no finale skip, dream 0, dev keys off). Play once from the title, then publish.
3. **Record the 30 to 60 second video** (shot list below).
4. **Merge PR #35** so `main` has the shipping Nell and the finished dev log, then submit.

## Requirements (UEFN track)

| Requirement | Status |
|---|---|
| Island name | **Wonderwell** |
| Team name, each member's name and Epic-account email | Team **Dream Team**, solo: Chip. Name and Epic email go on the form only (not stored in the repo) |
| **Private version code** (not live, not playtest), created before the deadline, the final build to be judged | Enrollment cleared; publish after the debug start is off |
| Gameplay video link, 30 to 60 seconds | To record |
| Dev log link (optional; required for Glass Box) | Ready: https://github.com/infinitemonkey3/MegaJam2026/blob/main/docs/devlog.md (after the merge) |
| Tools used (optional; needed for partner prizes) | Draft below |
| Third-party assets and licenses listed in the submission | `docs/assets.md`; summary below |
| Pre-jam work declared | `docs/devlog.md`, "Pre-jam setup (declared)" |
| Follows the Fortnite Developer Rules, no others' IP, nothing inappropriate | Our own world, names, tunes and art. No real films, actors or studios. Check the moderation-sensitive themes (grief, a drowning) are handled gently, which they are |
| Only one engine entered (UEFN) | Yes |

## Prizes we can aim at

| Prize | Fit | What it takes |
|---|---|---|
| **Best Overall, UEFN** | Every UEFN entry | The judging criteria below |
| **Walkie-Talkie**: "best narrative-driven UEFN game featuring LLM-powered NPCs and characters built with conversations" | **Our strongest.** Nell is a persona NPC built with Fortnite's AI conversations, the player talks to her by voice, and the whole game is the conversation | Show her talking in the video, and say it plainly in the description |
| **Glass Box**: "best dev log showing how you built your game" | Strong. The dev log covers every day, the dead ends, the play-test-driven prompt fixes, and the agent workflow | Dev log link on the form |
| **Solo Driver**: "best game built by a solo developer" | **Yes: Chip is solo.** (Best Team needs two or more, so it doesn't apply) | Enter as a team of one on the form |
| **Render Royalty**: best visuals, stylized counts | Possible: a consistent painted 2D look | Nothing extra |
| Pocket Powerhouse (mobile) | Unlikely: the game is played by voice | Skip |
| Partner prizes: Hyper3D Rodin cash pool, Tripo, Meshy | We didn't use Rodin, Tripo or Meshy for the game | Nothing to claim |

## Judging criteria (each 1 to 5) and what to show

- **Ambition and innovation:** an LLM patient you direct by voice, a debugger that's also the
  HUD, a three-act twist where the software's own AI turns on you.
- **Theme, Director's Cut:** you are the director, the director narrates, and every dream is a
  scene you re-shoot until it lands. Say it in the description's first line.
- **Fun:** the improv. Nell reacts to whatever the player says.
- **Gameplay:** call and response, graded takes, a different role each dream.
- **Visuals:** the painted room, the breathing and talking recliner art, the debugger.
- **Level design and progression:** title, cold open, the room, two dreams that deepen, the
  finale.
- **Audio:** the director's voice, title and end themes, rain, the hack and power cut.

## Video shot list (about 50 seconds)

1. 0:00 Title card and theme (3 s).
2. 0:03 Cold open: the street, the director's "Everyone dreams now..." (6 s).
3. 0:09 The room, the debugger booting, Nell asleep and breathing (4 s).
4. 0:13 Her case file, ATTACH, the director's send-in (5 s).
5. 0:18 Dream 1: Nell asks "What makes you think I could mend that?", the player answers with a
   real memory, she lights up (10 s). **This is the Walkie-Talkie shot: show the voice
   exchange.**
6. 0:28 Dream 2: the constellations, "What does the Needle mean to you?" (8 s).
7. 0:36 The finale: the log spam ramping, Lumi's sun, "No! You will not take-", the power cut
   (10 s).
8. 0:46 Nell wakes, smiling: "I had the loveliest dream." End card (5 s).

## Form text (drafts)

**Description**

> Wonderwell is a Director's Cut about a cheap dream implant that's broken. You're the
> director's new assistant, and the patient, Nell, is stuck in the same dream every night. Read
> her file, step into her dream as someone she knows, and talk her through it, out loud. Nell is
> an AI-powered conversation NPC: she hears you and answers in her own voice, so every take
> plays out differently. Get her to believe in herself, and the dream lets her go. Then the
> software's own AI decides it isn't done with her.

**Tools used**

> UEFN with Verse, Scene Graph and Fortnite AI conversations (persona NPC). Claude Code
> driving UEFN through its MCP server. fal for generated assets: Google Nano Banana 2.1 (2D art
> and edits), Gemini 3.8 Flash TTS (the director's and Lumi's voices), ElevenLabs Sound Effects
> v3 and Music v2.5 (sound and music). Python for texture and audio processing.

**Third-party assets** (summary of `docs/assets.md`)

> All 2D art, voices, music and sound effects were generated during the jam with the fal models
> above; the full list with each model's license note is in docs/assets.md in the repo. No
> other third-party assets.

(Checked 2026-11-15: every row in `docs/assets.md` is a fal generation or derived from one;
there are no Fab or store assets. Fortnite's own fonts and devices come with UEFN.)
