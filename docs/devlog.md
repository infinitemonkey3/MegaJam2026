# Dev Log

Needed for the Glass Box prize: show how the game was built, including how AI tools were used.

## Pre-jam setup (declared)

Everything below was made before the jam started (2026-11-12 00:00 EST). None of it is game
content for the entry. Anything from this list that ends up in the game is marked when it's
used.

### Tools and project setup

- **2026-11-08: Repo.** Set up the git repo, Git LFS, `.gitignore`, `.gitattributes` and
  README. Created the GitHub remote.
- **2026-11-08: Empty UEFN project.** Created the `MegaJam/` project from the Blank template
  (Fortnite 43.00). Not changed since.
- **2026-11-08: AI agent connected to UEFN.** Connected Claude Code (AI coding agent) to UEFN's
  built-in MCP server through `.mcp.json`, so the agent can place devices, edit assets, compile
  Verse and push changes to play sessions.
- **2026-11-08 to 2026-11-09: Agent skill.** Wrote a `uefn` skill for the agent: notes on how
  UEFN sessions work, helper scripts for calling the MCP server, Verse gotchas, and a recipe for
  LLM persona NPCs. It lives in the separate
  [agent-kit](https://github.com/infinitemonkey3/agent-kit) plugin repo (`skills/uefn`, merged in
  agent-kit#31), and this project loads it through `.claude/settings.json`.

### Experiments (scratch project, not part of the entry)

- **2026-11-08: Persona NPC test.** In a separate, git-ignored scratch project
  (`ConversationExploration/`), built a test LLM persona NPC to learn the Conversations feature:
  "Barnaby Wick", a lighthouse keeper. The agent made it through the MCP server. It has:
  - an NPC Character Definition with a Persona modifier, a personality prompt, the `terns_voice`
    voice and a name plate
  - a Verse NPC behavior (`persona_npc_behavior.verse`) that puts players and the NPC in a voice
    channel so players can talk to it, and shows its replies as subtitles
  - a Verse device (`persona_question_menu.verse`) with a button that opens a menu of preset
    questions, for players who can't use voice
- **Pre-jam code that may be reused:** the two Verse files above. Copies are kept as templates in
  agent-kit's `skills/uefn/templates/`. If they're used in the entry, the dev log will say so.

### Prompts

- The Barnaby personality prompt was written for the test only and won't be used in the entry.

### Design

- **2026-11-11: Game design.** After the theme reveal ("Director's Cut"), wrote the game concept
  and plan in [`design.md`](design.md) with the agent: a coma ward where the player directs
  patients' recurring dreams and slowly uncovers their own nightmare. A plan only; no game
  content was built before the jam.
- **2026-11-11: New frame story.** Later the same day, reworked the frame in `design.md` with
  the agent: a noir, cyberpunk back room where a failed dream designer and film lover hacks
  people out of looping dreams on cheap brain implants, with stolen debug software. The player
  is his assistant, and an AI from the premium world appears in the logs. Includes a draft
  cold-open narration and draft director lines (prompts and text only). The core loop and
  rubric didn't change.
- No other prompts, scripts or assets were made for the game before the jam.

## Day 1 (Nov 12)
