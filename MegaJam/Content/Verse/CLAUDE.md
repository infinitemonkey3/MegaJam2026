# Content/Verse

The game logic for *Wonderwell* (`docs/design.md`): the game director and its phases, the
pre-roll and cold open, the take loop for one client with three dreams, the wrapper around the
client's LLM persona, and seams for the screen, haze and director's voice. One file per system.
All files share one module (the folder's).

**Status:** the start screen, cold open and boot have been played in a session (2026-11-13).
`overlay_screen` (the black room stand-in) compiles clean but hasn't been played yet. Earlier: Every file builds with no errors or warnings
(2026-11-12; 43.00 for the take flow, 43.10 for the cold open), and the editor loads the classes
as `/<guid>/_Verse.Verse-<class>` (for example `_Verse.Verse-game_director`). A `Game Director`
and a `Take Flow` device are placed and wired in the editor's level, but nothing has run in a
play session yet.

## Provides

### Game (`game_director.verse`, `game_state.verse`, `input_router.verse`)
- `game_director`: the one `creative_device` with a script. Runs `PreRollPhase`,
  `ColdOpenPhase` (with the boot), `RoomPhase`, `ClientPhase`, then `DonePhase`, logging
  `[game] A -> B` on each change. Holds every device
  reference as an `@editable` (`Takes`, the cold-open cameras, sequence and audio players).
- Space (Jump, the router's `ConfirmEvent`) skips the cold open straight to the room intro, for
  players and for iterating on the room.
- Debug starts: `@editable StartAt:game_phase` (`PreRollPhase` is the real game;
  `ColdOpenPhase` skips the pre-roll; `RoomPhase` or later starts at the desk) and `@editable DevKeys` (Sprint skips the current
  phase).
- `game_state`: `Phase`, `MaybePlayer`, `VoiceMode` (`voice_mode{Mic, Presets}`),
  `PhaseChangedEvent`. `game_phase`, `GamePhaseName`, `GamePhaseIndex`.
- `input_router`: `Bind(Player, DevKeys)`; `NextEvent` (Crouch), `ConfirmEvent` (Jump),
  `SkipEvent` (Sprint, dev keys only), `AnyKeyEvent` (movement, Jump, Crouch, Sprint, Interact,
  Reload, both mouse buttons: Verse only hears Fortnite's input actions, not raw keys).

### Cold open (`cold_open.verse`)
- `title_card` (`title_card.verse`): the Wonderwell title card (`Content/TitleCard/T_TitleCard`,
  from `art/style-test/mockup-title.jpg`) full screen with the prompt low under the recliner.
  The pre-roll shows it over the black overlay and `EndPreRoll` takes it down.
- `cold_open`: `RunPreRoll` (the title card over a full-screen black Verse UI overlay, "PRESS ANY KEY TO START",
  ended by `input_router.AnyKeyEvent`; lifted under the sequence's own fade from black),
  `RunColdOpen` (plays the Level Sequence and swaps to the desk
  camera underneath it), `RunRoomIntro` (plays `LS_RoomIntro` on the `Room Intro Sequence`
  device: fades up from black and drifts 60 cm forward onto the desk camera's exact spot and
  90° field of view), `RunBoot` (DREAM DEBUGGER, the boot log, the tutorial line, on the dream
  debugger). Each has an `End*`/`SkipToDesk` that leaves cameras and sounds right if the phase
  was skipped.
- `cold_open_rig`: the device references it uses. Placeholder text: `PressAnyKeyText`,
  `DebuggerTitle`, `BootLines`.

### Data (`dream_data.verse`)
- `dead_air_log`: the log channel everything prints to (`GetVerseOutput`). Lines are tagged
  `[flow]`, `[client]`, `[screen]`, `[haze]`, `[director]`.
- `ToMessage(Text:string):message`: wraps authored text for the persona API and the screen.
- LLM response shapes, as in the design: `take_verdict`, `take_score`, `scene_update`,
  `client_state`, `take_memory`.
- Authored shapes: `client`, `dream`, `loop_beat`, `casting_role`, `scene_setting`,
  `inject_item`, `risk_level`, `take_setup`. Authored text is `string`.
- `MakeTakeSetup(Role, Settings, Items)`: builds a `take_setup` capped at `MaxSettings` (2) and
  `MaxItems` (2). `SetupHazeBase(Setup)`: haze base level from the riskiest choice.
- `MakeDesClient()` (`des_data.verse`): Des, with the case file's Screen section from
  `writing/des/case-file.md` and a full dream 1.
- `MakeNellClient()` (`nell_data.verse`): Nell, the current patient 1 (2026-11-13), with the
  Screen section of `writing/nell/case-file.md` and a full dream 1 from
  `writing/nell/dream-1.md`; layers 2 and 3 are placeholders.
- Patients are data: `game_director`'s `@editable Patient` (`patient_choice`) is the one switch.
  `MakePatient` gives the client for the debugger and the takes; `SetUpPatient` (first thing in
  `OnBegin`) sets `PatientRecliner`'s material on the `ReclinerCard` entity and the patient's
  NPC definition (`NellDefinition` / `DesDefinition`, `Room/NPC/CD_*`; only the voice matters,
  since `LoadDream` replaces the personality) on the take flow's `ClientSpawner`, then respawns
  the NPC. A new patient needs a `patient_choice` value, a `Make*Client`, a recliner material
  and a definition slot.
- The recliner is a Scene Graph entity (`ReclinerCard`) with a `Room.Meshes.SM_RoomCard` mesh
  component, whose `Card` material Verse can set. A plain static mesh actor can't be changed
  from Verse, and "Hidden in Game" doesn't hide one in a session. `SM_RoomCard` is our own copy
  of the engine plane (`art/meshes/SM_RoomCard.obj`; UEFN won't duplicate `/Engine` assets);
  each patient's recliner art is the empty recliner with them painted in, one texture.
- `MakePlaceholderClient()`: Nell, from the paper demo, with the same placeholder dream three
  times (only the id, title and revealed fact differ). Replace with the text from `writing/`.

### Take flow (`take_flow.verse`)
- `take_flow`: `creative_device`, the state machine. `@editable ClientSpawner` is the client
  NPC's spawner. Phases (`take_phase`): CaseFile, Observe, Direct, RunTake, LastLine, Verdict,
  then GoodEnding (next dream), RetryEnding (back to Direct, "Take N+1"), or Finale after a
  positive verdict on the last dream (`DoFinale`, a stub for the scripted ending).
- Direct is one role and one item (play test, 2026-11-13); settings are skipped. The take's
  opening prompt names both, so the client's first line reacts to them. `PickSettings` and
  `PickItems` are unused until settings or more items come back.
- Observe (the replay) is paced by the player: each loop beat goes in the log, the client tells
  it as her own memory (`client_control.NarrateBeat`, first person, past tense, using the beat's
  murmur), and `debug_screen.AwaitContinue` waits for CONTINUE (row 16 of the dream debugger,
  a click or Space) before the next beat. `loop_beat.HoldSeconds` is no longer used.
- Endings are told the same way: each `GoodEndingLog` / `BadEndingLog` line is narrated with
  CONTINUE; on a good ending the client then names what the player said or did that turned it
  around (`client_control.CreditLine`, from the take still in the session), says `FactRevealed`
  aloud, then `Celebrate` shows the LAYER CLEARED
  banner with the dream's `ClearedLog` (the debugger's notes, not told by the client) listed
  under it, and one CONTINUE before the next layer.
- The dream debugger's take log shows only the newest line (the player reads at their own pace),
  pinned to the top of the log area (`LatestText`'s slot is top-aligned).
- Every take tells the client to play it like improv, "yes, and": whatever the visitor says or
  does ("I light the oven") is true, and she builds on it rather than refusing or arguing.
- The directing menu logic (`PickOne`, `PickSettings`, `PickItems`): one list at a time,
  "next" moves the highlight, "confirm" picks; a `Done` option ends a list early.
- Fields `Screen`, `Haze`, `Director` hold the seams; they default to the stubs.
  `game_director` replaces `Screen` with the in-world screen.
- `@editable RunOnBegin` (default off): `game_director` calls `RunClient`; turn it on only to
  test the take loop without the director.

### Client control (`client_control.verse`)
- `client_npc_behavior`: the `npc_behavior` for the client's NPC Character Definition (which
  also needs the Persona modifier). Sets up the voice channel and exposes `MaybeControl`.
- `client_control`: `LoadDream` (SetPersonality), `RegisterSceneUpdate` and
  `SceneUpdateEvent`, `StartTake` (context lines, carried-forward memory and state),
  `MurmurLine`, `RequestScore`, `RequestMemory`, `SpeakVerdict`, `SpeakLine`,
  `AwaitSpeechEnd`, `AwaitPlayerLine`, `StartingFear`. Carries `Memories` (last
  `MaxMemories` = 6) and `Feeling` across takes and dreams.
- `VerdictPromptText`, `MemoryPromptText`, the `scene_update` description: placeholder prompts.

### Seams (stubs that log)
- `debug_screen` / `stub_debug_screen` (`debug_screen.verse`): `SetTitle`, `ClearLog`,
  `SetCaseFile`, `AppendLogLine`, `SetMenu`, `ShowSlate`, `SetVitals`, `SetClientState`,
  `AwaitNext`, `AwaitConfirm`. Display takes `message`s only; input is two waits the real
  screen backs with `/Verse.org/Input` actions. `EmptyText`.
- `overlay_screen` (`overlay_screen.verse`): the `debug_screen` as a full-screen Verse UI
  overlay, black with title, log and menu text. `Show(Player)` / `Hide()`. It's the start
  screen and covers the hand-offs around the cold open; text set while it's hidden shows next
  time. Its text helpers (`OverlayNewLine`, `OverlayPicked`, ...) are shared with the debugger.
- `dream_debugger_screen` (`dream_debugger_screen.verse`): the `debug_screen` on the in-world
  dream debugger, the `UW_DreamDebugger` widget (`Content/DreamDebugger/`) placed as a Scene
  Graph entity 1 cm behind `Room_Monitor`, whose glass is cut out of its texture. Sets the
  entity's `TitleMessage`, `BodyMessage`, `MenuMessage`. `Clear()` blanks the designer's sample
  text. `game_director` holds the entity as `@editable DebuggerScreen` and gives this screen to
  the boot and the take flow.
- `world_panel` / `monitor_rect` (`monitor_projection.verse`): projects a flat upright
  rectangle in the world onto the viewport as screen fractions (0..1), for canvas anchors, so
  screen-space UI can sit exactly over the monitor. `ProjectWorldToViewport` answers in physical
  screen centimeters (1920 px is 50.8 cm), so it solves the viewport size from the desk
  camera's known eye, angle (yaw 180, pitch -5) and 90 degree FOV. The eye that
  `DeprojectViewportToWorld` reports doesn't match the camera (it made the screen 12% small),
  so it isn't used; valid only while the desk camera is the view. Kept in its own file because
  `/Verse.org/SpatialMath` and the UI's `/UnrealEngine.com/Temporary/SpatialMath` clash.
- `dream_debugger_ui` (`dream_debugger_ui.verse`): the interactive dream debugger, shown over
  the monitor's glass hole once the boot has played (placed by `MakeMonitorPanel().ProjectRect`).
  Two layers: the text is `UW_DebuggerText` (`Content/DreamDebugger/`), a UMG widget with 18
  NotoSans rows (`Row00Text`..`Row17Text`, row 4 is `Tab0Text`..`Tab2Text`) in a Scale Box;
  input is invisible Verse UI buttons over the selectable rows (mouse, arrow keys, D-pad), whose
  highlight moves the `>` cursor. Tabs: CASE FILE (paged, `[ MORE ]` on row 15), DREAMS (INVOKE
  lines) and ASSISTANT (face plus preset questions). Invoking and asking only log so far. Shown
  with input mode All. No flat UI fill or frame: the world's glass and in-world screen are the
  background (they get the camera's perspective).
- Input on the debugger (play test, 2026-11-13): the UMG text widget must be Not Hit-Testable
  (Self & All Children) or its rows catch the mouse above the Verse buttons; "Self Hit-Test
  Invisible" isn't enough. `input_router.FreeMouse` drops the weapon mapping before it shows.
  Hovering a line focuses it, Space (Jump) activates the focused button, mouse clicks work.
  Arrow keys and Enter do nothing: Verse can't hear them and Fortnite's UI doesn't navigate with
  them.
- Fonts: Verse UI can't set one. UMG can, but UEFN refuses `.ttf`/`.otf` imports and validation
  blocks `/Engine` fonts (DroidSansMono), so only Fortnite's fonts (NotoSans, Burbank, ...) ship.
- `haze_controller` (`haze_controller.verse`): `SetDistress`, `SetSetupRisk`, `SetClock`,
  `Reset`; level is the highest of the three. Devices hang off `ApplyLevel`.
- `director_voice` / `stub_director_voice` (`director_voice.verse`): `PlayLine(LineId)`. Line
  names: `before_take`, `failed_take`, `mixed_take`, `ending_reaction`, `<dream id>_intro`,
  `<dream id>_solved`.

## Gotchas
- **Model-written text stays a `message`.** It is redacted when turned into a string, so the
  code never calls `Localize` on it to branch or to build prompts. Prompts that carry it are
  built with `<localizes>` functions taking `message` parameters and `Join([]message, message)`.
  The stub screen does `Localize` it for the log, where it shows redacted.
- `take_flow` finds the client by polling `ClientSpawner.GetAgents()` for an agent whose
  behavior is a `client_npc_behavior` with `MaybeControl` set, so spawn order doesn't matter.
- `StartTake` calls `ClearHistory()` so the verdict judges one take; what matters from earlier
  takes travels in `Memories`. Remove that call if retries should remember everything.
- The haze clock input is ignored while distress is 0 ("unless the client is calm"), and the
  take's starting distress is the client's carried-forward fear until the first `scene_update`.
- If the verdict prompt fails (moderated, say), `RequestScore` retries once with the shorter
  `VerdictRetryText`; if that fails too, the take counts as mixed (the client says the mixed line). The
  design's other fallbacks are listed as comments on `RequestScore`, `RegisterSceneUpdate`
  and `StartTake`; each sits behind that one function.
- A setting pick removes the other settings with the same `Element`. The design's "up to 2 per
  element" could also mean 2 per element; this reads it as 2 in total, one per element.
- **Content folder names become Verse modules** (`Content/ColdOpen/` is module `ColdOpen`), and
  a module name clashes with an enumerator of the same name anywhere in this module. That's why
  `game_phase` values carry a `Phase` suffix (`ColdOpenPhase`, `RoomPhase`). Don't add enum
  values named like a content folder.
- **The room shows from the room intro on** (2026-11-13), and everything the player reads is on
  the dream debugger in the monitor. A `RoomPhase` or later debug start goes straight to the
  desk camera with no intro.
- **Before the room intro, the 3D world only shows inside the cold-open sequence.** Outside it,
  `overlay_screen` is up (black). The sequence fades in from and out to black, so the overlay
  comes down and goes back up under black with no seam.
- **Don't name a content folder like a Verse field.** A `Content/Screen/` folder made `Screen`
  ambiguous in `cold_open.verse` (module vs. field), which is why the widget lives in
  `Content/DreamDebugger/`.
- In-world widgets don't render in editor scene captures; check the debugger's size, facing and
  text in a play session. Nothing documents how widget pixels map to world size.
- Nothing here uses `Content/Spikes/UW_SpikeScreen` any more; it and the spike screen entities
  can go.
- **Talking to the client needs the persona's conversation UI** (play test, 2026-11-13). It's
  the HUD Controller device's "Show LLM Conversations UI" (Show Element). That device's "Show
  HUD" must stay Do Not Override: Hide Element hides everything, the talk UI included, and Verse
  `ShowElementsForPlayer` can't override the device. The player holds the talk key it shows.
  During a take the debugger also drops to input mode None so Fortnite gets the keyboard.
- **The first take works end to end** (2026-11-13): INVOKE layer 1, the replay with Des's
  murmurs, directing by clicks, talking to Des by voice, his `scene_update` sentences in the
  log, the verdict and the retry.
- **The player never has a body or a Fortnite HUD.** `game_director` hides every Fortnite HUD
  element for the player (`HideFortniteHUD`) and the character the moment it exists
  (`HoldPlayer`), before the black start screen goes on. If a later feature needs one HUD
  element back (the persona talk prompt, say), show just that one with `ShowElementsForPlayer`. **Don't put the character in stasis:** `PutInStasis` also blocks Crouch and Jump,
  which drive every menu, and the game sits waiting with no control. Nothing waits on the client
  NPC before the opening; the client phase waits for it.
- The pre-roll no longer has the design's mic check or the Talk/Preset-lines choice (Chip
  wanted a plain black start screen). `game_state.VoiceMode` stays `Mic` until that choice gets
  a new home.
- Only one `take_flow` may run: it's started by `game_director`, so keep its `RunOnBegin` off
  whenever a director is placed.
- Verse devices render as consoles in a play session too. Keep `Game Director` and `Take Flow`
  out of every camera's view (they sit behind the cameras, at +X).
- `audio_player_device` has no finished event, so `cold_open.TutorialSeconds` is the WAV's
  length (5.36 s) plus a margin. Change it with the line.
- The folder is named `Verse`, so its module is `Verse` and class paths carry a `Verse-` prefix.
  It compiles alongside the implicit `/Verse.org/Verse`; don't add `using { /Verse.org/Verse }`
  in these files without building, since that path was not tried.

## Engine APIs relied on

Digest files: `%LOCALAPPDATA%\UnrealEditorFortnite\Saved\VerseProject\MegaJam\Digests\BuiltIn\`.
UE = `UnrealEngine\UnrealEngine.digest.verse`, V = `Verse\Verse.digest.verse`,
FN = `Fortnite\Fortnite.digest.verse`. The first table's lines are from build
`++Fortnite+Release-43.00-CL-59596594`; the editor is now on 43.10 and the digests were
regenerated, so those line numbers have moved (the signatures still compile). The cold-open
table's lines are from `++Fortnite+Release-43.10-CL-60458657`.

| API | Signature (from the digest) | Where |
|---|---|---|
| `ai_session.Prompt` | `Prompt<native><public>((local:)Prompt:message, response_type:type)<suspends>:result(response_type, ai_error)` | UE:55 |
| `ai_session.RegisterAction` | `RegisterAction<native><public>(Definition:prompt_binding_definition, Required:logic, output_type:type, Callback:type {_(:output_type):void})<transacts>:cancelable` | UE:61 |
| `prompt_binding_definition` | `struct` with `Name<native><public>:message`, `Description<native><public>:message` | UE:35 |
| `ai_session.ClearHistory` | `ClearHistory<native><public>()<transacts>:void` | UE:48 |
| `ai_error.Message` | `Message<native><public>:message` | UE:19 |
| `persona_component.SetPersonality` | `SetPersonality<native><public>(NewPersonality:message)<transacts><decides>:void` | UE:80 |
| `persona_component.GetAISession` | `GetAISession<native><public>()<transacts>:ai_session` | UE:86 |
| `persona_component.PromptToTalk` | `PromptToTalk<native><public>((Instructions:message, Channel:voice_channel(member_info)) where member_info:subtype(has_voice_member_info))<transacts><decides>:void` | UE:119 |
| `persona_component.StopHearEvent` | `StopHearEvent<native><public>:listenable(agent)` | UE:100 |
| `persona_component.StopSayEvent` | `StopSayEvent<native><public>:listenable(logic)` | UE:115 |
| `SetConversationTarget` | `(Player:player where member_info:subtype(has_voice_member_info)).SetConversationTarget<native><public>((local:)Persona:persona_component, Channel:voice_channel(member_info))<transacts>:void` | UE:138 |
| `ClearConversationTarget` | `(Player:player).ClearConversationTarget<native><public>()<transacts>:void` | UE:146 |
| `log`, `log.Print` | `log := class` with `Channel:subtype(log_channel)`; `Print<public>(Message:string, ?Level:log_level = external {})<computes>:void` | UE:1438, 1446 |
| `log_level`, `log_channel` | `enum: Debug, Verbose, Normal, Warning, Error`; `class<abstract>` | UE:1427, 1435 |
| `has_voice_member_info` | `interface(member_info_interface)` with `var CanBroadcast<public>:logic` | V:34 |
| `voice_channel` | `voice_channel<native><public>(member_info:subtype(has_voice_member_info)) := class<final>(chat_channel(member_info))`, fields `Name<public>:message`, `Group<public>:agent_group_interface(member_info)` | V:66, 21, 24 |
| `AddChatChannel` | `(Entity:entity where MemberInfo:subtype(member_info_interface)).AddChatChannel<native><public>(Channel:chat_channel(MemberInfo)):result(void, add_channel_error)` (no effect specifier) | V:142 |
| `agent_group`, `AddMember` | `AddMember<public>(Agent:agent, MemberInfo:member_info)<transacts>:result(void, add_member_error)` | V:2615, 2627 |
| `result.GetSuccess`, `GetError` | `GetSuccess<native_callable><public>()<computes><decides>:success_type`; `GetError<native_callable><public>()<computes><decides>:error_type` | V:912, 915 |
| `event(t)` | `Await<native><override>()<suspends>:t`; `Signal<native><override>(Val:t):void` | V:644, 652, 657 |
| `listenable` / `awaitable.Await` | `listenable(payload) := interface(awaitable(payload), subscribable(payload))`; `Await<public>()<suspends>:payload` | V:698, 3867 |
| `subscribable.Subscribe` | `Subscribe<public>(Callback:type {_(:t):void})<transacts>:cancelable` | V:952 |
| `cancelable` | `interface` with `Cancel<native_callable><public>()<transacts>:void` | V:524, 526 |
| `Localize` | `Localize<native><public>(Message:message)<reads>:string` | V:712 |
| `Join` (messages) | `Join<native><public>(Messages:[]message, Separator:message)<transacts>:message` | V:716 |
| `Join` (strings) | `Join<native><public>(Strings:[]string, Separator:string)<computes>:string` | V:937 |
| `Clamp`, `Min`, `Max` (int) | `Clamp<native><public>(Val:int, A:int, B:int)<computes>:int`; `Min<public>(X:int, Y:int)<computes>:int`; `Max<public>(X:int, Y:int)<computes>:int` | V:750, 753, 756 |
| `Mod` | `Mod<native><public>(X:int, Y:int)<computes><decides>:int` | V:866 |
| `Slice` | `(Input:[]t where t:type).Slice<public>(StartIndex:int, StopIndex:int)<computes><decides>:[]t`; one-argument form `Slice<public>(StartIndex:int)` | V:470, 474 |
| `RemoveElement` | `(Input:[]t where t:type).RemoveElement<public>(IndexToRemove:int)<computes><decides>:[]t` | V:481 |
| `Sleep` | `Sleep<native><public>(Seconds:float)<suspends>:void` (`Inf` waits forever) | V:3126 |
| `entity.GetComponent` | `GetComponent<native><final><public>(component_type:castable_subtype(component))<decides><reads>:component_type` | V:2351 |
| `entity.GetSimulationEntity` | `(InEntity:entity).GetSimulationEntity<native><public>()<transacts><decides>:entity` | V:2470 |
| `npc_behavior` | `class<abstract>`; `OnBegin<native_callable><public>()<suspends>:void`; `OnEnd<native_callable><public>():void`; `GetAgent<native><public>()<transacts><decides>:agent`; `GetEntity<native><public>()<transacts><decides>:entity` | FN:2216-2227 |
| `GetNPCBehavior` | `(InAgent:agent).GetNPCBehavior<native><public>()<transacts><decides>:npc_behavior` | FN:2230 |
| `npc_spawner_device.GetAgents` | `GetAgents<public>()<transacts>:[]agent` | FN:8156, 8190 |
| `creative_device.OnBegin` | `OnBegin<native_callable><public>()<suspends>:void` | FN:9287, 9289 |
| `fort_playspace` | `GetPlayers<public>()<transacts>:[]player`; `PlayerAddedEvent<public>():listenable(player)` | FN:10385, 10391 |
| `GetPlayspaceForEntity` | `(InEntity:entity).GetPlayspaceForEntity<native><public>()<transacts><decides>:fort_playspace` | FN:10406 |

Cold open and game shell (43.10 lines):

| API | Signature (from the digest) | Where |
|---|---|---|
| `GetPlayerInput` | `GetPlayerInput<native><public>(Player:player)<transacts><decides>:player_input` | V:3605 |
| `player_input` | `AddInputMapping<native><public>(InputMapping:input_mapping):void`; `GetInputEvents<native><public>(ActionToBind:input_action(t) where t:type):input_events(t)` | V:3653, 3659 |
| `input_events.TriggerActivationEvent` | `TriggerActivationEvent<native><public>:listenable(tuple(player, t))` | V:3623 |
| `Character` inputs | `TraversalMapping<public>:input_mapping`; `Crouch`, `Sprint`, `Jump<public>:input_action(logic)` | FN:35, 38, 41, 44 |
| `GetPlayerUI`, `player_ui` | `GetPlayerUI<native><public>(Player:player)<transacts><decides>:player_ui`; `AddWidget<native><public>(Widget:widget, Slot:player_ui_slot):void`; `RemoveWidget<native><public>(Widget:widget):void` | UE:1837, 1845, 1848 |
| `canvas_slot`, `color_block`, `text_base` | `canvas_slot` (`Anchors`, `Offsets`, `SizeToContent`, `Alignment`, `Widget`); `color_block` (`DefaultColor`, `DefaultOpacity`); `text_base` (`DefaultText`, `DefaultTextColor`, `DefaultJustification`) | UE:2007, 2038, 2231 |
| `Character` extra inputs | `InteractMapping`, `RangedWeaponMapping:input_mapping`; `Interact`, `Reload`, `WeaponPrimary`, `WeaponSecondary:input_action(logic)`; `Move:input_action(vector3)` | FN:18-60 |
| `entity.FindDescendantEntities` | `(InEntity:entity).FindDescendantEntities<native><public>(entity_type:castable_subtype(entity))<transacts>:generator(entity_type)` | V:766 |
| `creative_device.GetSimulationEntity` | `(CreativeDevice:creative_device).GetSimulationEntity<native><public>()<transacts><decides>:entity` | FN:9045 |
| `GetPlayspace`, `GetPlayers` | `(CreativeObject:creative_object_interface).GetPlayspace<native><public>()<transacts>:fort_playspace`; `GetPlayers<public>()<transacts>:[]player` | FN:9116, 1615 |
| `cinematic_sequence_device` | `Play<public>(Agent:agent):void`; `GoToEndAndStop<public>(Agent:agent):void`; `StoppedEvent<public>:listenable(tuple())` | FN:6242, 6260, 6236 |
| `gameplay_camera_device` | `AddTo<public>(Agent:agent):void`; `RemoveFrom<public>(Agent:agent):void` | FN:4473, 4479 |
| `audio_player_device` | `Play<public>():void`; `Stop<public>():void` (no finished event) | FN:2758, 2764 |
| `GetFortCharacter` | `(InAgent:agent).GetFortCharacter<native><public>()<transacts><decides>:fort_character` | FN:905 |
| `fort_character.Hide` | `Hide<public>():void` | FN:875 |
| `fort_hud_controller` | `(Playspace:fort_playspace).GetHUDController<native><public>():fort_hud_controller`; `HideElementsForPlayer<public>(Player:player, HUDElements:[]hud_element_identifier):void`; `creative_hud_identifier_all`, `player_hud_identifier_all`, `hud_identifier_visual_sound_effect_all` | FN:12424, 12418, 12426, 12478, 12502 |
| `stack_box`, `stack_box_slot` | `stack_box` (`Orientation`, `Slots`); `stack_box_slot` (`Widget`, `HorizontalAlignment`, `Padding`) | UE:2171, 2185 |

Not called yet: `CommitSayEvent<native><public>:listenable(tuple(?agent, message))` (UE:111 in 43.00, for the verdict fallback).

## Checked by the first compile

Signatures above are exact. The language uses below were guesses when written; all of them
compiled on 2026-11-12. "Compiles" isn't "works": items 1, 4 and 8 still need a play session.

1. **Casting an `npc_behavior` to `client_npc_behavior`** (`client_npc_behavior[Agent.GetNPCBehavior[]]`
   in `take_flow.FindClientControl`). `npc_behavior` is `class<abstract>` with no `<castable>`
   in the digest. If the cast is refused, have the behavior hand its `client_control` to the
   device another way (for example the device subscribes to `ClientSpawner.SpawnedEvent`).
2. **`<localizes>` functions with `message` and `int` parameters** (`StateLine`,
   `VerdictInstructions`, ... in `client_control.verse`), and `\"` inside a localized string.
3. **`ToMessage` and the other `<localizes>` functions called from plain (no-specifier) and
   `<transacts>`-free code**: their effect isn't in any digest.
4. **`race` whose blocks return a value** (`AwaitPlayerLine`, `PickOne`), and `race` between a
   never-ending `loop` and a finishing call (`DoRunTake`, `DoLastLine`).
5. **Generic helpers** `FirstN` / `LastN` written as `(Input:[]t, Count:int where t:type)`.
6. **`event(scene_update){}`** as a class field default, with `scene_update` a struct that holds
   a `message`.
7. **`option{Result.GetError[]}`** to turn the failable `GetError` into a `?ai_error`.
8. **A bound method as the `RegisterAction` callback** (`OnSceneUpdate`); the spike used a
   callback of that shape, but check it was a method.
9. **`if (not X?):`** and `for (...) { ... }` array comprehensions used inline as arguments.
10. **`log.Print` is `<computes>`**; it is only called outside failure contexts here.
11. **Structs as class field values**: `var MaybeSetup:?take_setup`, `var Feeling:?client_state`,
    and `take_setup` holding class references and arrays.
12. **Interfaces with `<suspends>` methods and interface-typed field defaults**
    (`Screen:debug_screen = stub_debug_screen{}`).

Behavior a play session still needs to answer (the code assumes yes): `PromptToTalk` context lines
stay in the session history for the take; `ClearHistory()` leaves the personality in place;
`Prompt` right after another `Prompt` works; `StopHearEvent` fires once per player utterance;
`PromptToTalk` is accepted while the persona is idle after `SetPersonality`.

## Depends on / used by
- The level (in the editor's checkout): `Game Director` and `Take Flow` devices (outliner folder
  `Game`), the cold-open devices (`ColdOpen/Devices`) and the street set and sequence camera
  (`ColdOpen/Street`). Assets in `Content/ColdOpen/` (Textures, Audio, Materials,
  `Sequences/LS_ColdOpen`).
- Text comes from `writing/` (converted by hand into `dream_data.verse` shapes).
- `Content/UI/` (screen) will implement `debug_screen`; the level provides the NPC spawner, the
  client's NPC Character Definition (Persona modifier + `client_npc_behavior`) and a placed
  `take_flow` device.
