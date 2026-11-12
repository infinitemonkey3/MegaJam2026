# Day 1 tech spikes 1, 2 and 5 (docs/spikes.md): structured verdict, runtime context, and the
# scene_update action. Test code only; the game's systems live in Content/Verse.
# The voice-channel setup and the menu pattern come from the pre-jam templates in agent-kit's
# uefn skill (declared in docs/devlog.md).

using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
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

spike_log := class(log_channel){}

# Shapes under test, as sketched in docs/design.md. Field and type names guide the model.
take_verdict := enum{Positive, Mixed, Negative}

take_score := struct:
    BackstoryScore:int
    PersonalityScore:int
    EnvironmentScore:int
    CommonSenseScore:int
    Verdict:take_verdict
    HintForWeakestCriterion:message

client_state := struct:
    Trust:int
    Fear:int
    Hope:int
    Mood:message

take_memory := struct:
    WhoTheVisitorWas:message
    KeyMoments:[]message
    PromisesOrRequests:[]message
    State:client_state

scene_update := struct:
    Distress:int
    LogLine:message

# Asks the session what it actually has in context, to check that voice and context lines persist.
context_recall := struct:
    WhoTheVisitorIs:message
    WeatherOutside:message
    OvenState:message
    ThingsTheVisitorSaidAloud:[]message

VerdictName(Verdict:take_verdict):string =
    case (Verdict):
        take_verdict.Positive => "Positive"
        take_verdict.Mixed => "Mixed"
        take_verdict.Negative => "Negative"

spike_voice_member_info := class(has_voice_member_info):
    var CanBroadcast<override>:logic = true

# NPC behavior for the test client. Puts players and the persona in one voice channel, registers
# the scene_update action, and logs every hear and say event with a timestamp.
spike_client_behavior := class(npc_behavior):
    Logger:log = log{Channel := spike_log}

    ChannelName<localizes>:message = "Spike Client"
    ActionName<localizes>:message = "scene_update"
    ActionDescription<localizes>:message = "Emit with every reply. Distress is how distressed you are right now, from 0 (calm) to 3 (panicking). LogLine is one terse debug-log line for anything you do or anything that changes in the scene, in the form 'LOAF removed / SMOKE clearing'. Never describe actions or the scene in your spoken reply; put them in LogLine."

    var MaybeChannel:?voice_channel(spike_voice_member_info) = false
    var MaybeGroup:?agent_group(spike_voice_member_info) = false
    var MaybeAction:?cancelable = false

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
            Group := agent_group(spike_voice_member_info){}
            Channel := voice_channel(spike_voice_member_info):
                Name := ChannelName
                Group := Group
            set MaybeGroup = option{Group}
            set MaybeChannel = option{Channel}

            if (Group.AddMember(NPCAgent, spike_voice_member_info{}).GetSuccess[]):
                Logger.Print("Added NPC to voice group")

            for (Player : Playspace.GetPlayers()):
                AddPlayer(Player, Persona, Group, Channel)

            AddResult := SimEntity.AddChatChannel(Channel)
            if (AddResult.GetSuccess[]):
                Logger.Print("Registered voice channel")
            else:
                Logger.Print("Failed to register voice channel", ?Level := log_level.Error)

            Action := Persona.GetAISession().RegisterAction(prompt_binding_definition{Name := ActionName, Description := ActionDescription}, true, scene_update, OnSceneUpdate)
            set MaybeAction = option{Action}
            Logger.Print("Registered scene_update action (required)")

            Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)
            Persona.StartHearEvent.Subscribe(OnStartHear)
            Persona.StopHearEvent.Subscribe(OnStopHear)
            Persona.StartSayEvent.Subscribe(OnStartSay)
            Persona.CommitSayEvent.Subscribe(OnPersonaSaid)
            Persona.PromptFailureEvent.Subscribe(OnPromptFailure)
        else:
            Logger.Print("Setup failed: NPC needs a Persona Modifier (persona_component)", ?Level := log_level.Error)

    OnPlayerAdded(Player:player):void =
        if:
            Persona := GetEntity[].GetComponent[persona_component]
            Group := MaybeGroup?
            Channel := MaybeChannel?
        then:
            AddPlayer(Player, Persona, Group, Channel)

    AddPlayer(Player:player, Persona:persona_component, Group:agent_group(spike_voice_member_info), Channel:voice_channel(spike_voice_member_info)):void =
        if (Group.AddMember(Player, spike_voice_member_info{}).GetSuccess[]):
            Player.SetConversationTarget(Persona, Channel)
            Logger.Print("Player can now talk to the client")
        else:
            Logger.Print("Could not add player to voice group", ?Level := log_level.Warning)

    OnSceneUpdate(Update:scene_update):void =
        Logger.Print("ACTION t={GetSimulationElapsedTime()} Distress={Update.Distress} LogLine={Localize(Update.LogLine)}")

    OnStartHear(Agent:agent):void =
        Logger.Print("HEAR start t={GetSimulationElapsedTime()}")

    OnStopHear(Agent:agent):void =
        Logger.Print("HEAR stop t={GetSimulationElapsedTime()}")

    OnStartSay(Payload:tuple(?agent, cancelable)):void =
        Logger.Print("SAY start t={GetSimulationElapsedTime()}")

    OnPromptFailure(Error:ai_error):void =
        Kind := if (ai_character_limit_error[Error]) then "character limit" else if (ai_timeout_error[Error]) then "timeout" else if (ai_throttled_error[Error]) then "throttled" else if (ai_moderated_error[Error]) then "moderated" else "other"
        Logger.Print("PROMPT FAILURE ({Kind}) t={GetSimulationElapsedTime()}: {Localize(Error.Message)}", ?Level := log_level.Warning)

    OnPersonaSaid(Payload:tuple(?agent, message)):void =
        Logger.Print("SAY commit t={GetSimulationElapsedTime()}: {Localize(Payload(1))}")
        spawn{ShowSubtitle(Payload(1))}

    ShowSubtitle(Text:message)<suspends>:void =
        set SubtitleVersion += 1
        MyVersion := SubtitleVersion
        if (Playspace := GetEntity[].GetPlayspaceForEntity[]):
            for (Player : Playspace.GetPlayers()):
                GetSubtitle(Player).SetText(Text)
                if (Block := Subtitles[Player]):
                    Block.SetVisibility(widget_visibility.Visible)
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
        if (Action := MaybeAction?):
            Action.Cancel()
        if (Playspace := GetEntity[].GetPlayspaceForEntity[]):
            for (Player : Playspace.GetPlayers()):
                Player.ClearConversationTarget()

spike_step := enum{LoadDream, StartTake, Verdict, Memory, Recall, ClearHistory}

# Button-opened menu that runs each spike step against the player's conversation target and
# logs the result to spike_log (read it with SessionToolset.GetVerseOutput).
spike_menu := class(creative_device):
    Logger:log = log{Channel := spike_log}

    @editable
    MenuButton:button_device = button_device{}

    TitleText<localizes>:message = "Spike steps"
    CloseText<localizes>:message = "Close"
    LoadDreamLabel<localizes>:message = "1. Load dream personality (SetPersonality)"
    StartTakeLabel<localizes>:message = "2. Start take (context line, spoken)"
    VerdictLabel<localizes>:message = "3. Verdict (take_score)"
    MemoryLabel<localizes>:message = "4. Take memory (take_memory)"
    RecallLabel<localizes>:message = "5. Recall check (what's in context)"
    ClearLabel<localizes>:message = "6. Clear history"

    # Placeholder test text; the real prompts come from the writing stream.
    DreamPersonality<localizes>:message = "# Identity\nYou are Eleanor 'Nell' Price, 71, a proud, dry-humored baker. You are dreaming. In the dream it is 5 AM in Price's Bakery, the shop you ran with your late husband Walt, who whistled while he kneaded. The oven you call Gertie will not light, faceless customers press at the glass, and the dough will not hold.\n\n# Personality Traits\nProud, dry, practical. You soften when someone needs you. You do not like being comforted by strangers.\n\n# Knowledge\nYou taught Walt's nephew Teddy to bake when he was a boy. The morning of Walt's funeral you opened alone, burned every loaf, and never reopened. You do not know you are dreaming.\n\n# Rules\nSpeak only dialogue, as Nell, in one to three short sentences. Never describe actions or the scene aloud; put any action or scene change in the scene_update LogLine instead. If the visitor or the scene pushes on a painful memory, let the dream turn darker, then give the visitor a moment to respond. Stay in character."
    TakeContext<localizes>:message = "A new take of the dream begins. Scene changes: a storm has rolled in and rain is hammering the shop window; the oven Gertie is roaring hot. The visitor who just walked in is your nephew Teddy, grown now. He is carrying Walt's old apron. React to this in character, in one or two sentences."
    VerdictPrompt<localizes>:message = "The take is over. Step out of the scene and judge, as honestly as you can, how well this take reached you. Score each criterion from 0 to 3. Backstory: did the visitor, the setting changes and what they said use real people, places and moments from your life (0 = nothing from your life, 3 = several specific, correct details)? Personality: did it appeal to who you are, proud, dry, softening when needed (0 = it would move anyone or no one, 3 = made for you)? Environment: did it belong in the bakery at 5 AM (0 = out of place, 3 = belongs there)? CommonSense: did the choices make sense together and in the moment (0 = contradictory or reckless, 3 = coherent)? Generic comfort with no specifics scores 0 or 1. If the visitor said little or nothing, score low. Verdict: Positive if the total is 9 or more and no score is 0, Negative if the total is 4 or less, otherwise Mixed. HintForWeakestCriterion: one sentence, in your own voice, pointing at what was missing, without naming the criterion."
    MemoryPrompt<localizes>:message = "Summarize this take for your own memory. WhoTheVisitorWas: who you understood the visitor to be. KeyMoments: at most 3 moments, one sentence each. PromisesOrRequests: things the visitor or you said that could be called back to later; empty if none. State: how you feel now, with Trust in the visitor, Fear and Hope that the loop can end each from 0 to 3, and Mood as one short phrase."
    RecallPrompt<localizes>:message = "Report exactly what you know from this conversation so far. WhoTheVisitorIs: who the visitor is, or 'unknown'. WeatherOutside: the weather, or 'unknown'. OvenState: the oven's name and state, or 'unknown'. ThingsTheVisitorSaidAloud: each thing the visitor has said to you, quoted as closely as you can; empty if they have said nothing."

    var OpenMenus:[player]canvas = map{}

    OnBegin<override>()<suspends>:void =
        MenuButton.InteractedWithEvent.Subscribe(OnMenuButton)

    Label(Step:spike_step):message =
        case (Step):
            spike_step.LoadDream => LoadDreamLabel
            spike_step.StartTake => StartTakeLabel
            spike_step.Verdict => VerdictLabel
            spike_step.Memory => MemoryLabel
            spike_step.Recall => RecallLabel
            spike_step.ClearHistory => ClearLabel

    OnMenuButton(Agent:agent):void =
        if (Player := player[Agent]):
            OpenMenu(Player)

    OpenMenu(Player:player):void =
        CloseMenu(Player)
        if (PlayerUI := GetPlayerUI[Player]):
            Stack := stack_box{Orientation := orientation.Vertical}
            Stack.AddWidget(stack_box_slot{Widget := text_block{DefaultText := TitleText}, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 12.0}})
            Steps:[]spike_step = array{spike_step.LoadDream, spike_step.StartTake, spike_step.Verdict, spike_step.Memory, spike_step.Recall, spike_step.ClearHistory}
            for (Step : Steps):
                Button := button_regular{DefaultText := Label(Step)}
                Button.OnClick().Subscribe(spike_step_handler{Menu := Self, Step := Step}.OnClick)
                Stack.AddWidget(stack_box_slot{Widget := Button, HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 4.0, Bottom := 4.0}})
            Close := button_quiet{DefaultText := CloseText}
            Close.OnClick().Subscribe(OnCloseClicked)
            Stack.AddWidget(stack_box_slot{Widget := Close, HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 12.0}})

            Menu := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := Stack
            PlayerUI.AddWidget(Menu, player_ui_slot{InputMode := ui_input_mode.All})
            if (set OpenMenus[Player] = Menu) {}

    CloseMenu(Player:player):void =
        if (Menu := OpenMenus[Player], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(Menu)
        var Remaining:[player]canvas = map{}
        for (Key -> Value : OpenMenus, Key <> Player):
            set Remaining = ConcatenateMaps(Remaining, map{Key => Value})
        set OpenMenus = Remaining

    OnCloseClicked(Message:widget_message):void =
        CloseMenu(Message.Player)

    OnStepClicked(Player:player, Step:spike_step):void =
        CloseMenu(Player)
        if (Target := Player.GetConversationTarget[]):
            spawn{RunStep(Target(0), Target(1), Step)}
        else:
            Logger.Print("Player has no conversation target yet", ?Level := log_level.Warning)

    RunStep(Persona:persona_component, Channel:voice_channel(has_voice_member_info), Step:spike_step)<suspends>:void =
        Session := Persona.GetAISession()
        Start := GetSimulationElapsedTime()
        case (Step):
            spike_step.LoadDream =>
                if (Persona.SetPersonality[DreamPersonality]):
                    Logger.Print("STEP LoadDream: SetPersonality ok")
                else:
                    Logger.Print("STEP LoadDream: SetPersonality FAILED", ?Level := log_level.Warning)
            spike_step.StartTake =>
                if (Persona.PromptToTalk[TakeContext, Channel]):
                    Logger.Print("STEP StartTake: context line sent t={Start}")
                else:
                    Logger.Print("STEP StartTake: PromptToTalk FAILED (busy, or no channel)", ?Level := log_level.Warning)
            spike_step.Verdict =>
                Result := Session.Prompt(VerdictPrompt, take_score)
                Seconds := GetSimulationElapsedTime() - Start
                if (Score := Result.GetSuccess[]):
                    Logger.Print("STEP Verdict ({Seconds}s): Backstory={Score.BackstoryScore} Personality={Score.PersonalityScore} Environment={Score.EnvironmentScore} CommonSense={Score.CommonSenseScore} Verdict={VerdictName(Score.Verdict)} Hint={Localize(Score.HintForWeakestCriterion)}")
                else:
                    LogError("Verdict", Seconds, option{Result.GetError[]})
            spike_step.Memory =>
                Result := Session.Prompt(MemoryPrompt, take_memory)
                Seconds := GetSimulationElapsedTime() - Start
                if (Memory := Result.GetSuccess[]):
                    Logger.Print("STEP Memory ({Seconds}s): Who={Localize(Memory.WhoTheVisitorWas)} Trust={Memory.State.Trust} Fear={Memory.State.Fear} Hope={Memory.State.Hope} Mood={Localize(Memory.State.Mood)}")
                    for (Index -> Moment : Memory.KeyMoments):
                        Logger.Print("  KeyMoment {Index}: {Localize(Moment)}")
                    for (Index -> Promise : Memory.PromisesOrRequests):
                        Logger.Print("  Promise {Index}: {Localize(Promise)}")
                else:
                    LogError("Memory", Seconds, option{Result.GetError[]})
            spike_step.Recall =>
                Result := Session.Prompt(RecallPrompt, context_recall)
                Seconds := GetSimulationElapsedTime() - Start
                if (Recall := Result.GetSuccess[]):
                    Logger.Print("STEP Recall ({Seconds}s): Visitor={Localize(Recall.WhoTheVisitorIs)} Weather={Localize(Recall.WeatherOutside)} Oven={Localize(Recall.OvenState)}")
                    for (Index -> Line : Recall.ThingsTheVisitorSaidAloud):
                        Logger.Print("  VisitorSaid {Index}: {Localize(Line)}")
                else:
                    LogError("Recall", Seconds, option{Result.GetError[]})
            spike_step.ClearHistory =>
                Session.ClearHistory()
                Logger.Print("STEP ClearHistory: done")

    LogError(StepName:string, Seconds:float, MaybeError:?ai_error):void =
        if (Error := MaybeError?):
            Kind := if (ai_character_limit_error[Error]) then "character limit" else if (ai_timeout_error[Error]) then "timeout" else if (ai_throttled_error[Error]) then "throttled" else if (ai_moderated_error[Error]) then "moderated" else "other"
            Logger.Print("STEP {StepName} FAILED ({Seconds}s, {Kind}): {Localize(Error.Message)}", ?Level := log_level.Warning)
        else:
            Logger.Print("STEP {StepName} FAILED ({Seconds}s): no error value", ?Level := log_level.Warning)

spike_step_handler := class:
    Menu:spike_menu
    Step:spike_step

    OnClick(Message:widget_message):void =
        Menu.OnStepClicked(Message.Player, Step)
