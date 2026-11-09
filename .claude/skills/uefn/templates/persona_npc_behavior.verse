using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Conversations }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/AgentGroup }
using { /Verse.org/Chat }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

persona_log := class(log_channel){}

# Member info for the shared voice channel between players and the persona NPC.
persona_voice_member_info := class(has_voice_member_info):
    var CanBroadcast<override>:logic = true

# NPC behavior that lets every player in the island talk to this NPC's persona.
# Assign it in the NPC Character Definition: NPC Character Behavior > Verse Behavior.
persona_npc_behavior := class(npc_behavior):
    Logger:log = log{Channel := persona_log}

    ChannelName<localizes>:message = "Persona Chat"

    var MaybeChannel:?voice_channel(persona_voice_member_info) = false
    var MaybeGroup:?agent_group(persona_voice_member_info) = false

    # On-screen subtitles of what the persona says, one widget per player.
    var Subtitles:[player]text_block = map{}
    var SubtitleVersion:int = 0

    OnBegin<override>()<suspends>:void =
        if:
            NPCEntity := GetEntity[]
            NPCAgent := GetAgent[]
            Persona := NPCEntity.GetComponent[persona_component]
            SimEntity := NPCEntity.GetSimulationEntity[]
            Playspace := NPCEntity.GetPlayspaceForEntity[]
        then:
            Group := agent_group(persona_voice_member_info){}
            Channel := voice_channel(persona_voice_member_info):
                Name := ChannelName
                Group := Group
            set MaybeGroup = option{Group}
            set MaybeChannel = option{Channel}

            if (Group.AddMember(NPCAgent, persona_voice_member_info{}).GetSuccess[]):
                Logger.Print("Added NPC to persona voice group")

            for (Player : Playspace.GetPlayers()):
                AddPlayer(Player, Persona, Group, Channel)

            AddResult := SimEntity.AddChatChannel(Channel)
            if (AddResult.GetSuccess[]):
                Logger.Print("Registered persona voice channel")
            else:
                Logger.Print("Failed to register persona voice channel", ?Level := log_level.Error)

            Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)
            Persona.CommitSayEvent.Subscribe(OnPersonaSaid)
        else:
            Logger.Print("Persona setup failed: NPC needs a Persona Modifier (persona_component)", ?Level := log_level.Error)

    OnPlayerAdded(Player:player):void =
        if:
            Persona := GetEntity[].GetComponent[persona_component]
            Group := MaybeGroup?
            Channel := MaybeChannel?
        then:
            AddPlayer(Player, Persona, Group, Channel)

    AddPlayer(Player:player, Persona:persona_component, Group:agent_group(persona_voice_member_info), Channel:voice_channel(persona_voice_member_info)):void =
        if (Group.AddMember(Player, persona_voice_member_info{}).GetSuccess[]):
            Player.SetConversationTarget(Persona, Channel)
            Logger.Print("Player can now talk to the persona")
        else:
            Logger.Print("Could not add player to persona voice group", ?Level := log_level.Warning)

    OnPersonaSaid(Payload:tuple(?agent, message)):void =
        spawn{ShowSubtitle(Payload(1))}

    ShowSubtitle(Text:message)<suspends>:void =
        set SubtitleVersion += 1
        MyVersion := SubtitleVersion
        if (Playspace := GetEntity[].GetPlayspaceForEntity[]):
            for (Player : Playspace.GetPlayers()):
                GetSubtitle(Player).SetText(Text)
                if (Block := Subtitles[Player]):
                    Block.SetVisibility(widget_visibility.Visible)
        # Hide after a while unless a newer line replaced it.
        Sleep(8.0)
        if (MyVersion = SubtitleVersion):
            for (Block : Subtitles):
                Block.SetVisibility(widget_visibility.Collapsed)

    GetSubtitle(Player:player):text_block =
        if (Existing := Subtitles[Player]):
            Existing
        else:
            Block := text_block{DefaultJustification := text_justification.Center}
            if (PlayerUI := GetPlayerUI[Player]):
                Root := canvas:
                    Slots := array:
                        canvas_slot:
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.8}, Maximum := vector2{X := 0.5, Y := 0.8}}
                            Alignment := vector2{X := 0.5, Y := 1.0}
                            SizeToContent := true
                            Widget := Block
                PlayerUI.AddWidget(Root, player_ui_slot{InputMode := ui_input_mode.None})
            if (set Subtitles[Player] = Block) {}
            Block

    OnEnd<override>():void =
        if (Playspace := GetEntity[].GetPlayspaceForEntity[]):
            for (Player : Playspace.GetPlayers()):
                Player.ClearConversationTarget()
