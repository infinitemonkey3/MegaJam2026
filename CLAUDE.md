# MegaJam2026

Entry for the 2026 Epic AI MegaJam, UEFN track. Shared agent rules and the `uefn` skill come
from the agent-kit plugin (`.claude/settings.json`); this file holds project-specific facts and
overrides the kit where they conflict.

## Jam rules that affect the work

- Build game content only from **2026-11-12 00:00 EST**. Before that, only setup, tools, and
  experiments in `ConversationExploration/`.
- Deadline: **2026-11-15 5:59 PM PST**. Late entries are disqualified.
- Submission is a UEFN **private version code** (not live or playtest codes), a 30-60 second
  gameplay video, and an optional dev log (needed for the Glass Box prize).
- Declare anything made before the jam (prompts, scripts, assets) in `docs/devlog.md`, and list
  third-party assets with licenses in `docs/assets.md`.

## Layout

- `MegaJam/`: the jam's UEFN project (`MegaJam.uefnproject`). Fortnite 43.00, Blank template.
- `ConversationExploration/`: local scratch UEFN project for experiments (persona NPC
  "Barnaby"). Git-ignored, not part of the entry.
- `docs/`: dev log and asset list.
- `.mcp.json`: connects agents to UEFN's MCP server on `127.0.0.1:8000`.

Only one UEFN editor can serve MCP at a time; check which project is open
(`LevelToolset.GetCurrentLevel`) before changing anything.
