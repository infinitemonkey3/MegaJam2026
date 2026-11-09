# Persona NPC recipe (UEFN 43.00)

Built and tested in the `ConversationExploration` project ("Barnaby Wick").
`<guid>` below is the project's plugin GUID (the name of the `.uplugin` file); asset paths
start with `/<guid>/`.

## 1. Verse behavior

Copy `templates/persona_npc_behavior.verse` into the project's `Content/` and compile.
What it does, and why:

- `persona_voice_member_info := class(has_voice_member_info)` with `CanBroadcast = true`. The
  docs' `team_member_info` is not a built-in type; you define your own.
- Creates `agent_group(...)` and `voice_channel(...){Name, Group}`, adds the NPC agent and
  every player, registers the channel with `SimEntity.AddChatChannel`, and calls
  `Player.SetConversationTarget(Persona, Channel)`.
- Subscribes to `Playspace.PlayerAddedEvent()` for late joiners.
- Subtitles: subscribes to `Persona.CommitSayEvent` and shows the text in a `text_block`.
- Logs to channel `persona_log`; read it with `SessionToolset.GetVerseOutput`.

Useful `persona_component` members: `SetPersonality[]`, `SetVoice[]`,
`PromptInterruptionRule`, `GetAISession()` (`ai_session.Prompt(msg, struct_type)` returns
structured output without speaking; `RegisterAction` for tool-like callbacks),
`PromptToTalk[Instructions, Channel]`, events `StartHearEvent`, `StopHearEvent`,
`StartSayEvent`, `CommitSayEvent`, `StopSayEvent`, `PromptFailureEvent`.

## 2. Character definition (editor Python)

```python
import unreal
root = '/<guid>/'
tools = unreal.AssetToolsHelpers.get_asset_tools()
asset = tools.create_asset('PersonaNPCDefinition', root.rstrip('/'),
                           unreal.NPCCharacterDefinition, unreal.NPCCharacterDefinitionFactory())
# type is CharacterType_Custom by default

# Verse behavior
vb_cls = unreal.load_class(None, '/CRD_AISpawner/SpawnDefinitions/Modifiers/CharacterModifier_VerseBehavior.CharacterModifier_VerseBehavior_C')
vb = unreal.new_object(vb_cls, outer=asset)
vb.set_editor_property('npc_behavior_script',
    unreal.get_default_object(unreal.load_object(None, '/<guid>/_Verse.persona_npc_behavior')))
asset.set_editor_property('behavior', vb)

# Persona + UI modifiers (the native NPCCharacterModifier_Persona is abstract; use the BP)
persona = unreal.new_object(unreal.load_class(None, '/CRD_AIPrompt/Modifiers/CharacterModifierPersona.CharacterModifierPersona_C'), outer=asset)
ui = unreal.new_object(unreal.load_class(None, '/CRD_AISpawner/SpawnDefinitions/Modifiers/CharacterModifier_UI.CharacterModifier_UI_C'), outer=asset)

key = unreal.DataRegistryId(registry_type=unreal.DataRegistryType(name='LLMFactTypes'), item_name='PersonalityPrompt')
facts = persona.get_editor_property('character_facts')
facts.set_editor_property('fact_map', {key: PERSONALITY_MARKDOWN})
persona.set_editor_property('character_facts', facts)
persona.set_editor_property('interruption_rule', unreal.InterruptBehavior.INTERRUPT_ON_PROMPT_START)
persona.set_editor_property('VoiceModel', unreal.load_object(None, '/CRD_AIPrompt/_Verse/VNI/AIPrompt.terns_voice'))
ui.set_editor_property('display_name', 'Name Here')
ui.set_editor_property('show_name_plate', unreal.NPCIndicatorCondition.ALWAYS)

asset.set_editor_property('modifiers', [persona] + list(asset.get_editor_property('modifiers')) + [ui])
unreal.EditorAssetLibrary.save_asset(root + 'PersonaNPCDefinition', only_if_is_dirty=False)
```

- `PersonalityPrompt` is the only key in `/CRD_AIPrompt/DT_LLMFactTypes`. Markdown sections
  work well: Identity, Personality Traits, Knowledge, Rules ("Keep every reply to one to three
  short sentences", "Stay in character").
- Voices: 35 `*_voice` classes in `/CRD_AIPrompt/_Verse/VNI/AIPrompt.*`; the
  `UnrealEngine.digest.verse` lists each with a tone comment (e.g. `terns_voice`
  "Narrator, Low, Warm", `kor_voice` "Narrator, Low, Warm", `moxie_voice` "Narrator, Med,
  Warm"). Most are Fortnite characters' voices.
- Interruption options: `IGNORE_UNTIL_FINISHED`, `INTERRUPT_ON_PROMPT_START`,
  `INTERRUPT_ON_RESPONSE_START`.
- Validate with `EditorToolset.AssetToolset.ValidateAssets`.

## 3. Spawner

```python
dev = unreal.load_object(None, '<spawner actor path from PlaceDevice>')
comp = dev.get_component_by_class(unreal.NPCCharacterDefinitionComponent)
comp.update_npc_character_definition(unreal.load_asset('/<guid>/PersonaNPCDefinition'))
dev.set_actor_label('My NPC Spawner')
unreal.get_editor_subsystem(unreal.LevelEditorSubsystem).save_current_level()
```

The character definition isn't a classic device option, so `SetClassicDeviceOption` can't
set it.

## 4. Preset questions (no player text input exists)

`templates/persona_question_menu.verse` is a `creative_device` with an `@editable` Button.
Interacting opens a Verse UI menu (`player_ui_slot{InputMode := ui_input_mode.All}`, which
freezes player movement while it's open). Each choice calls `PromptToTalk` on the player's
`GetConversationTarget[]`, so it needs no direct reference to the NPC.

## 5. Testing

- Island Settings > Voice Chat Scope must not be None.
- Launch Session, then speak near the NPC after pressing the on-screen talk key.
- After any editor change: `SessionToolset.PushChanges` (or the toolbar button), then restart
  the round.
- Expect `persona_log` lines: "Added NPC to persona voice group", "Player can now talk to
  the persona", "Registered persona voice channel".
- Open question: whether islands with persona NPCs can be made into a private version code
  (needed for jam submission). Test early.
