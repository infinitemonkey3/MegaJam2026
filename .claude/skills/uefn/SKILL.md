---
name: uefn
description: Work on UEFN (Unreal Editor for Fortnite) projects through the editor's MCP server - placing and wiring devices, editing assets with editor Python, writing and compiling Verse, NPCs and LLM persona (Conversations) NPCs, Verse UI, and running/pushing play sessions. Use whenever the task touches a UEFN project, Verse code, Fortnite devices, or the UEFN editor.
---

# UEFN

Learnings from setting up this repo (Fortnite / UEFN 43.00, Nov 2026). Verify against the
live editor when something disagrees; Epic ships API changes every Fortnite release.

## How UEFN differs from Unreal

- No Play-In-Editor. **Launch Session** cooks the project, uploads it to a Fortnite game server
  (usually Epic's cloud), and starts the real Fortnite client, which joins it ("Play in Client").
- The editor stays linked to the session. Editor changes reach it only after **Push Changes**
  (full cook) or a **Verse-only push**. Restarting the round in-game does NOT pick up changes.
- **Verse runs on the server.** `Print`/log output shows in UEFN's Verse log
  (`SessionToolset.GetVerseOutput`), not in the Fortnite window.
- Submission/sharing is via private version codes, not packaged builds.

## Connecting to the editor (MCP)

- UEFN embeds an MCP server: Edit > Editor Preferences > Agentic Workflows > Model Context
  Protocol (default `http://127.0.0.1:8000/mcp`). The editor must be open. The repo's
  `.mcp.json` registers it as `unreal-mcp`. Only one editor can hold the port.
- It exposes three tools: `list_toolsets`, `describe_toolset(toolset_name)`,
  `call_tool(toolset_name, tool_name, arguments)`. `tool_name` has no toolset prefix.
  Always `describe_toolset` before calling: argument names vary (`devicePath` vs `device`,
  some booleans are required).
- If the MCP tools aren't loaded in this session, use the bundled curl scripts (they handle the
  session handshake). From the repo root:
  - `bash .claude/skills/uefn/scripts/ct.sh <Toolset> <Tool> '<json args>'` call one tool
  - `bash .claude/skills/uefn/scripts/mcp.sh describe_toolset '{"toolset_name":"..."}'`
  - `bash .claude/skills/uefn/scripts/runpy.sh <file.py>` run editor Python (see below)
  - `bash .claude/skills/uefn/scripts/capture.sh <out.png> <x> <y> <z> <pitch> <yaw> [fov]`
    render the open level to a PNG, then Read it to check placement
  - The scripts set `MSYS_NO_PATHCONV=1`; without it, Git Bash rewrites `/<guid>/...` asset
    paths into `C:/Program Files/Git/...`. Do the same in any ad-hoc Bash call that passes
    asset paths as arguments.
- Tool coordinates are engine XYZ (Forward-Right-Up, cm). The editor UI shows LUF
  (Left-Up-Forward, Verse convention). Convert when talking to the user. 100 units = 1 m.
- Many writes need an explicit save; actors live in one-file-per-actor packages under
  `Content/__ExternalActors__/`. After Python edits, call
  `unreal.get_editor_subsystem(unreal.LevelEditorSubsystem).save_current_level()` and confirm
  `EditorLoadingAndSavingUtils.get_dirty_content_packages()` is empty.

### Useful toolsets

| Need | Toolset (tools) |
|---|---|
| Project/level info | `EditorToolset.LevelToolset` (GetCurrentLevel, FindActors), `AIAssistantEditor.AIAssistantToolset` (GetProjectContext) |
| Devices | `ValkyrieFortniteToolset.DeviceToolset` (ListDeviceAssets nameFilter, PlaceDevice, ListClassicDeviceOptions, SetClassicDeviceOption, ListDeviceProperties/SetDeviceProperty for Verse @editables, AddEventBinding) |
| Verse | `VerseToolset.VerseToolset` (BuildAll returns diagnostics; ReadFile/WriteFile/Grep) |
| Sessions | `ValkyrieFortniteToolset.SessionToolset` (GetSessionStatus, StartSession, PushChanges {bVerseOnly}, StartGame/StopGame, GetVerseOutput, GetClientLogEntries) |
| Screenshots | `SceneCaptureToolset.SceneCaptureToolset` (Capture with a world + camera, mode "Lit"; CaptureActiveEditorView). The image comes back base64 in the response; decode it to a PNG and look at it. |
| Anything else | `editor_toolset.toolsets.python_scripting.PythonScriptingTools` (execute_python, search_symbols, get_symbol, grep_stubs) - last resort, but needed for asset creation and most property edits |
| Editor-side skills | `ToolsetRegistry.AgentSkillToolset` (ListSkills, GetSkills) - Epic's own guidance for PCG, materials, Sequencer, GenMedia, placing actors |

Verify placement visually with a Capture from where the player will stand; it caught a
device that was too small, facing backwards, and an editor-only mesh blocking the view.

## Verse

- API reference that matches the installed build: the digest files in
  `%LOCALAPPDATA%\UnrealEditorFortnite\Saved\VerseProject\<Project>\Digests\BuiltIn\`
  (`Fortnite`, `UnrealEngine`, `Verse`). Grep them for exact signatures before writing code.
- Put `.verse` files in the project's `Content/` folder, then compile with
  `VerseToolset.BuildAll` and iterate until it returns `[]`.
- Gotchas seen so far:
  - `result(t, e)` is unwrapped with `.GetSuccess[]`, not `?`.
  - Functions without an effect specifier are `no_rollback`; they can't be called inside a
    failure context (`if (...)`). Mark helpers `<transacts>` or call them outside the `if`.
    `AddChatChannel` is `no_rollback`: store its result first, then check it.
  - `<localizes>` messages must be class members or module-level, not inline literals.
  - A placed Verse `creative_device` shows as a large computer console in the editor and is
    invisible in game.
- Compiled Verse classes are UObjects at `/<plugin-guid>/_Verse.<class_name>`; editor Python can
  reference them (use the class default object where an instance is expected).

## Devices

- Device catalog names are item definitions, e.g. NPC Spawner =
  `/CRD_AISpawner/SetupAssets/PID_Device_AISpawner_Character.PID_Device_AISpawner_Character`,
  Button = `/CreativeCoreDevices/SetupAssets/PID_Device_Button.PID_Device_Button`.
- A Verse device's `@editable` actor reference is set with `SetDeviceProperty`, value as a JSON
  string: `"{\"refPath\":\"<actor path>\"}"`. Property names are camelCase (`talkButton`).
- The Button device is a small wall switch; scale it up (~1.5x) or mount it on something.
- Island Settings is the `Device_ExperienceSettings_V2_UEFN_C` actor; read its options with
  `ListClassicDeviceOptions` (voice chat scope, etc.).

## LLM persona NPCs (Conversations)

See `reference/persona-npc.md` for the full recipe (class paths, Python, Verse). Short version:

1. Verse `npc_behavior` that puts the NPC and players in a shared `voice_channel` and calls
   `Player.SetConversationTarget(Persona, Channel)`. Without this, players can't talk to it.
   Template: `templates/persona_npc_behavior.verse`.
2. NPC Character Definition (Custom type) with the Persona modifier (personality + voice),
   a UI modifier (display name), and a Verse Behavior pointing at the class from step 1.
3. NPC Spawner with that definition, set through its `NPCCharacterDefinitionComponent`.
4. Players talk by **voice only**; there's no player text input. For button-driven questions
   use `Persona.PromptToTalk[Instructions, Channel]`
   (template: `templates/persona_question_menu.verse`). `CommitSayEvent` gives the spoken
   text for subtitles.
5. Island voice chat must be on, and the player needs voice chat enabled in Fortnite.

## Jam rules (2026 Epic AI MegaJam)

This repo is a jam entry. Build game content only from 2026-11-12 00:00 EST; the deadline is
2026-11-15 5:59 PM PST. Use the local `ConversationExploration/` project (git-ignored) for
experiments, and log pre-jam work in `docs/devlog.md`. See `README.md`.
