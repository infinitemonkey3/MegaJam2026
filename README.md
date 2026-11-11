# MegaJam 2026 (UEFN track)

Entry for the [2026 Epic AI MegaJam](https://itch.io/jam/2026-epic-ai-megajam), built in UEFN.

## Key dates

| When | What |
|---|---|
| Nov 11, 11 AM PST | Kickoff livestream and theme reveal |
| Nov 12, 12:00 AM EST | Jam starts. Don't build game content before this. |
| Nov 15, 5:59 PM PST | **Submission deadline.** Late entries are disqualified. |

## Submission checklist (UEFN)

- [ ] **Private version code** of the final island, created before the deadline. Live and playtest codes are not accepted.
- [ ] Island name
- [ ] Team name, plus each member's name and Epic-account email
- [ ] Gameplay video link, 30 to 60 seconds
- [ ] Dev log link (optional; required for the Glass Box prize). See [docs/devlog.md](docs/devlog.md).
- [ ] List of third-party assets and their licenses. See [docs/assets.md](docs/assets.md).
- [ ] Declare any prompts, scripts or assets made before the jam
- [ ] Follow the [Fortnite Developer Rules](https://legal.epicgames.com/fortnite/developer-rules)

Judging scores each criterion from 1 to 5: ambition and innovation, theme, fun, gameplay, visuals, level design and progression, audio.

## Repo layout

```
MegaJam2026/              <- git repo root
  README.md
  docs/                   <- dev log, asset list, notes
  MegaJam/                <- UEFN project (Fortnite 43.00, Blank template)
    MegaJam.uefnproject   <- open this in UEFN
    <guid>.uplugin        <- root module, Verse + Scene Graph enabled
    Content/              <- maps, assets, *.verse
      MegaJam.umap
      __ExternalActors__/ <- one file per placed actor (World Partition)
    Resources/Icon128.png
```

Open the project from the UEFN Project Browser (Browse → `MegaJam\MegaJam.uefnproject`).

## Creating the UEFN project

1. Install **Fortnite** from the Epic Games Launcher, then install **UEFN** from the Fortnite page.
2. In UEFN, pick a template and set **Project Location** to this folder
   (`C:\Users\Chip\Documents\Unreal Projects\MegaJam2026`).
3. **Turn off Unreal Revision Control** for the project. This repo uses git and Git LFS.
4. Commit the new project folder.

`.gitignore` excludes `Intermediate/`, `Saved/`, `.urc/` and the generated Verse workspace.
`.gitattributes` sends `.uasset`, `.umap` and media files to Git LFS.

## UEFN MCP (Claude Code)

`.mcp.json` connects Claude Code started in this folder to UEFN's built-in MCP server.

1. Open the project in UEFN. The server must be running (Edit → Editor Preferences → Agentic Workflows → Model Context Protocol, port 8000).
2. Start Claude Code in this repo folder and approve the `unreal-mcp` server when asked.

`unreal-insights` is Epic's profiling MCP server, which ships with the Fortnite install.

## Asset generation MCP (Meshy, fal)

`.mcp.json` also connects two jam partner tools. No keys are stored in the repo.

- **Meshy** (3D props): the official `@meshy-ai/meshy-mcp-server`, run with `npx` (Node 18+).
  Needs a Meshy Pro plan or higher (the jam gives one free month). Create an API key at
  [meshy.ai/developers/keys](https://www.meshy.ai/developers/keys) and set it as a user
  environment variable, then restart Claude Code:

  ```powershell
  [Environment]::SetEnvironmentVariable("MESHY_API_KEY", "msy_...", "User")
  ```

- **fal** (images, music, audio): fal's hosted server at `https://mcp.fal.ai/mcp-relay`. It
  signs in with OAuth, so there's no key: run `/mcp` in Claude Code, pick `fal`, and choose
  Authenticate.

Log every generated asset, with the tool, model and license, in `docs/assets.md`.
