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
  <UEFN project folder>/  <- created by UEFN (see below)
    <Project>.uefnproject
    Plugins/<Project>/
      <Project>.uplugin
      Content/            <- maps, assets, *.verse
```

## Creating the UEFN project

1. Install **Fortnite** from the Epic Games Launcher, then install **UEFN** from the Fortnite page.
2. In UEFN, pick a template and set **Project Location** to this folder
   (`C:\Users\Chip\Documents\Unreal Projects\MegaJam2026`).
3. **Turn off Unreal Revision Control** for the project. This repo uses git and Git LFS.
4. Commit the new project folder.

`.gitignore` excludes `Intermediate/`, `Saved/`, `.urc/` and the generated Verse workspace.
`.gitattributes` sends `.uasset`, `.umap` and media files to Git LFS.
