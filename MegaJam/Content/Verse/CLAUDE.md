# Content/Verse

The game logic for *Dead Air* (`docs/design.md`): the take loop for one client with three
dreams, the wrapper around the client's LLM persona, and seams for the screen, haze and
director's voice. One file per system. All files share one module (the folder's).

**Status: written offline, never compiled.** Every engine call was checked against the 43.00
digests (table below), but the code itself has not been through `BuildAll`. Expect syntax fixes.

## Provides

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
- `MakePlaceholderClient()`: Nell, from the paper demo, with the same placeholder dream three
  times (only the id, title and revealed fact differ). Replace with the text from `writing/`.

### Take flow (`take_flow.verse`)
- `take_flow`: `creative_device`, the state machine. `@editable ClientSpawner` is the client
  NPC's spawner. Phases (`take_phase`): CaseFile, Observe, Direct, RunTake, LastLine, Verdict,
  then GoodEnding (next dream), RetryEnding (back to Direct, "Take N+1"), or Finale after a
  positive verdict on the last dream (`DoFinale`, a stub for the scripted ending).
- The directing menu logic (`PickOne`, `PickSettings`, `PickItems`): one list at a time,
  "next" moves the highlight, "confirm" picks; a `Done` option ends a list early.
- Fields `Screen`, `Haze`, `Director` hold the seams; they default to the stubs.

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
- `debug_screen` / `stub_debug_screen` (`debug_screen.verse`): `SetCaseFile`,
  `AppendLogLine`, `SetMenu`, `ShowSlate`, `SetVitals`, `SetClientState`, `AwaitNext`,
  `AwaitConfirm`. Display takes `message`s only; input is two waits the real screen backs with
  `/Verse.org/Input` actions.
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
- If the verdict prompt fails, the take counts as mixed (the client says the mixed line). The
  design's other fallbacks are listed as comments on `RequestScore`, `RegisterSceneUpdate`
  and `StartTake`; each sits behind that one function.
- A setting pick removes the other settings with the same `Element`. The design's "up to 2 per
  element" could also mean 2 per element; this reads it as 2 in total, one per element.
- The folder is named `Verse`, so its module is `Verse`. No file here writes
  `using { /Verse.org/Verse }` (it is imported implicitly), so no clash was written, but whether
  a project module named `Verse` shadows the implicit one is untested.

## Engine APIs relied on

Digest files: `%LOCALAPPDATA%\UnrealEditorFortnite\Saved\VerseProject\MegaJam\Digests\BuiltIn\`,
build `++Fortnite+Release-43.00-CL-59596594`. UE = `UnrealEngine\UnrealEngine.digest.verse`,
V = `Verse\Verse.digest.verse`, FN = `Fortnite\Fortnite.digest.verse`.

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

Not called yet, read for the seams: `GetPlayerInput<native><public>(Player:player)<transacts><decides>:player_input` (V:2713), `GetInputEvents<native><public>(ActionToBind:input_action(t) where t:type):input_events(t)` (V:2767), `TriggerActivationEvent<native><public>:listenable(tuple(player, t))` (V:2731), `CommitSayEvent<native><public>:listenable(tuple(?agent, message))` (UE:111, for the verdict fallback).

## Unverified or guessed

Signatures above are exact; these are about how the code uses them or the language.

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

Behavior the spikes still need to answer (the code assumes yes): `PromptToTalk` context lines
stay in the session history for the take; `ClearHistory()` leaves the personality in place;
`Prompt` right after another `Prompt` works; `StopHearEvent` fires once per player utterance;
`PromptToTalk` is accepted while the persona is idle after `SetPersonality`.

## Depends on / used by
- Text comes from `writing/` (converted by hand into `dream_data.verse` shapes).
- `Content/UI/` (screen) will implement `debug_screen`; the level provides the NPC spawner, the
  client's NPC Character Definition (Persona modifier + `client_npc_behavior`) and a placed
  `take_flow` device.
