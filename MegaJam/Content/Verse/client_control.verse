using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Conversations }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/AgentGroup }
using { /Verse.org/Chat }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

# Everything that touches the client's LLM persona. take_flow never calls the persona API
# itself, so when a spike changes how the verdict, the context or the scene_update action
# works, the change stays in this file. NOT COMPILED YET: see CLAUDE.md in this folder.

# Placeholder prompts. The writing stream's versions replace these.
VerdictPromptText:string = "The take is over. Step out of the scene and judge, silently and honestly, how the visitor's take reached you. Score each criterion 0 to 3. Backstory: did they use people, places, moments and loved things from your own life, or call back to something from an earlier dream? Personality: did it appeal to who you are? Environment: did their changes belong in this dream's setting? Common sense: did their choices make sense together and in the moment? Generic comfort scores 0 or 1. Verdict: Positive if the total is 9 or more and no score is 0, Negative if the total is 4 or less, otherwise Mixed. HintForWeakestCriterion: one short sentence, in your own voice, about what was missing."

MemoryPromptText:string = "Summarize the take that just ended, as you lived it. WhoTheVisitorWas: who you believed the visitor was. KeyMoments: at most 3, one sentence each. PromisesOrRequests: things the visitor or you said that could be called back to later. State: how you feel now, with Trust, Fear and Hope each 0 to 3 and Mood as one short phrase."

# Text written by the model is redacted when it is turned into a string, so it stays a
# `message` end to end: these build the prompts that carry it, and nothing branches on it.
MessageSpace<localizes>:message = " "
VisitorLine<localizes>(Who:message):message = "The visitor was {Who}."
SaidLine<localizes>(Said:message):message = "It was said: {Said}"
RecalledLine<localizes>(Recalled:message):message = "Earlier, in another dream, a visitor did these things. They are true for you, unless they conflict with your own life: {Recalled}"
StateLine<localizes>(Mood:message, Trust:int, Fear:int, Hope:int):message = "You start this dream {Mood}: trust {Trust}, fear {Fear}, hope {Hope}, each out of 3."
VerdictInstructions<localizes>(Line:string, Hint:message):message = "Back in the dream, say exactly this line: \"{Line}\" Then add one short sentence, in character, that touches on this without explaining it: {Hint}"

# How many carried-forward memory items the client is told at take start (design: "the last 6").
MaxMemories:int = 6

LastN(Input:[]t, Count:int where t:type)<transacts>:[]t =
    if (Tail := Input.Slice[Input.Length - Count]):
        Tail
    else:
        Input

# Member info for the voice channel the player and the client share.
client_voice_member_info := class(has_voice_member_info):
    var CanBroadcast<override>:logic = true

# The client's NPC behavior. Assign it in the client's NPC Character Definition (Verse
# Behavior); the definition also needs the Persona modifier. It puts the NPC and every player
# in one voice channel, points each player's talk key at the persona, and builds the
# client_control that take_flow picks up. Channel setup follows the uefn skill's
# persona_npc_behavior template, which compiled and ran in the scratch project.
client_npc_behavior := class(npc_behavior):
    Logger:log = log{Channel := dead_air_log}

    ChannelName<localizes>:message = "Dream link"

    var MaybeGroup:?agent_group(client_voice_member_info) = false
    var MaybeControl:?client_control = false

    OnBegin<override>()<suspends>:void =
        if:
            NPCEntity := GetEntity[]
            NPCAgent := GetAgent[]
            Persona := NPCEntity.GetComponent[persona_component]
            SimEntity := NPCEntity.GetSimulationEntity[]
            Playspace := NPCEntity.GetPlayspaceForEntity[]
        then:
            Group := agent_group(client_voice_member_info){}
            VoiceChannel := voice_channel(client_voice_member_info):
                Name := ChannelName
                Group := Group
            Control := client_control{Persona := Persona, VoiceChannel := VoiceChannel}
            set MaybeGroup = option{Group}

            if (Group.AddMember(NPCAgent, client_voice_member_info{}).GetSuccess[]):
                Logger.Print("[client] NPC joined the voice group")

            for (Player : Playspace.GetPlayers()):
                AddPlayer(Player, Control, Group)

            # AddChatChannel has no effect specifier: store the result, then check it.
            AddResult := SimEntity.AddChatChannel(VoiceChannel)
            if (AddResult.GetSuccess[]):
                Logger.Print("[client] voice channel registered")
            else:
                Logger.Print("[client] could not register the voice channel", ?Level := log_level.Error)

            Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)
            # Set last: take_flow starts as soon as it sees this.
            set MaybeControl = option{Control}
        else:
            Logger.Print("[client] setup failed: the NPC needs a Persona modifier (persona_component)", ?Level := log_level.Error)

    OnPlayerAdded(Player:player):void =
        if (Control := MaybeControl?, Group := MaybeGroup?):
            AddPlayer(Player, Control, Group)

    AddPlayer(Player:player, Control:client_control, Group:agent_group(client_voice_member_info)):void =
        if (Group.AddMember(Player, client_voice_member_info{}).GetSuccess[]):
            Player.SetConversationTarget(Control.Persona, Control.VoiceChannel)
            Logger.Print("[client] player can talk to the client")
        else:
            Logger.Print("[client] could not add the player to the voice group", ?Level := log_level.Warning)

    OnEnd<override>():void =
        if (Playspace := GetEntity[].GetPlayspaceForEntity[]):
            for (Player : Playspace.GetPlayers()):
                Player.ClearConversationTarget()

# Wraps the client's persona for one client across all their dreams and takes.
client_control := class:
    Persona:persona_component
    VoiceChannel:voice_channel(client_voice_member_info)

    Logger:log = log{Channel := dead_air_log}

    # What the model sees when deciding to emit the scene_update action.
    SceneUpdateName<localizes>:message = "scene_update"
    SceneUpdateDescription<localizes>:message = "Emit with every reply. Distress is how distressed you are right now, 0 (calm) to 3 (panicking). LogLine is one short plain sentence, present tense, saying what you do or what changes in the scene, like: The bread comes out of the oven and the smoke starts to clear. Never say the log line aloud."

    # Signaled with every scene_update the model emits. take_flow awaits it during a take.
    SceneUpdateEvent:event(scene_update) = event(scene_update){}

    # Carried forward between takes and dreams (design: "Continuity").
    var Memories:[]message = array{}        # oldest first, at most MaxMemories
    var Feeling:?client_state = false       # false until LoadDream sets the starting state

    var MaybeAction:?cancelable = false
    # The dream's personality from LoadDream; each take adds its own setup to it.
    var DreamPersonality:message = EmptyText

    # ---- Per dream ----

    # Loads a dream: the personality is the dream's text plus the case file and the facts found
    # so far, since the session forgets them between rounds. Keep it to a few hundred words
    # (ai_character_limit_error exists; the limit isn't documented).
    LoadDream(Subject:client, Dream:dream, Facts:[]string):void =
        if (not Feeling?):
            StartMood := ToMessage(Subject.StartMood)
            Start := client_state{Trust := Subject.StartTrust, Fear := Subject.StartFear, Hope := Subject.StartHope, Mood := StartMood}
            set Feeling = option{Start}
        CaseText := Join(Subject.CaseFile, " ")
        FactText := Join(Facts, " ")
        Personality := ToMessage("{Dream.Personality}\n\nYour waking life: {CaseText}\n\nAlso true: {FactText}")
        set DreamPersonality = Personality
        if (Persona.SetPersonality[Personality]):
            Logger.Print("[client] personality set for {Dream.Id}")
        else:
            Logger.Print("[client] SetPersonality failed for {Dream.Id}", ?Level := log_level.Error)

    # ---- Live side-output ----

    # Registers the scene_update action once. Required is true so the model emits it with
    # every reply.
    # Spike 5 fallback: if the action doesn't fire reliably or LogLine comes back badly, skip
    # this call. The haze then runs on setup risk and the clock only, and the log shows
    # prewritten lines only. Nothing else in the flow depends on it.
    RegisterSceneUpdate():void =
        if (not MaybeAction?):
            Definition := prompt_binding_definition{Name := SceneUpdateName, Description := SceneUpdateDescription}
            Handle := Persona.GetAISession().RegisterAction(Definition, true, scene_update, OnSceneUpdate)
            set MaybeAction = option{Handle}
            Logger.Print("[client] scene_update action registered")

    OnSceneUpdate(Update:scene_update):void =
        SceneUpdateEvent.Signal(Update)

    # ---- Per take ----

    # Starts a take: clears the last take's conversation, then tells the client the setup and
    # what carries forward, and has them speak the dream's first line. Returns false if the
    # persona refused the prompt (busy, or not in the channel).
    # Spike 2 fallback: if a PromptToTalk context line doesn't stay in the session history for
    # the whole take, append these lines to the personality in LoadDream-style SetPersonality
    # instead and prompt only "Say your first line".
    StartTake(Dream:dream, Setup:take_setup, TakeNumber:int):logic =
        # The persona system also passes on the player's own name or outfit, and the client used
        # it ("Sergeant") despite the personality's rule (play test, 2026-11-13), so every take
        # says it again next to the casting.
        var Lines:[]message = array{ToMessage("This time, the dream begins again from the top."), ToMessage(Setup.Role.ContextLine), ToMessage("Use only the visitor's name from these notes. Any other name or rank you have been told for them is wrong; never say it.")}
        for (Setting : Setup.Settings):
            set Lines += array{ToMessage(Setting.ContextLine)}
        for (Item : Setup.Items):
            set Lines += array{ToMessage(Item.ContextLine)}
        if (Memories.Length > 0):
            set Lines += array{RecalledLine(Join(Memories, MessageSpace))}
        if (Now := Feeling?):
            set Lines += array{StateLine(Now.Mood, Now.Trust, Now.Fear, Now.Hope)}
        # The take's setup goes into the personality, not only the opening prompt: as a one-off
        # PromptToTalk instruction the client forgot it after the first reply (the father became
        # "a stranger", play test 2026-11-13). The personality holds for every reply.
        TakePersonality := Join(array{DreamPersonality, ToMessage("\n\nTHIS TAKE:")} + Lines, MessageSpace)
        if (not Persona.SetPersonality[TakePersonality]):
            Logger.Print("[client] SetPersonality failed for take {TakeNumber}", ?Level := log_level.Error)

        # The verdict should judge this take only; what matters from earlier takes is in Memories.
        Persona.GetAISession().ClearHistory()
        Context := ToMessage("Say your first line of the dream now.")
        if (Persona.PromptToTalk[Context, VoiceChannel]):
            Logger.Print("[client] take {TakeNumber} of {Dream.Id} started with {Lines.Length} context lines")
            true
        else:
            Logger.Print("[client] the persona refused the take-start prompt", ?Level := log_level.Warning)
            false

    # Has the client mutter one of the loop's prewritten lines during the observe replay.
    MurmurLine(Line:string):void =
        Instructions := ToMessage("Half asleep, murmur exactly this and nothing else, and don't call anyone by name: {Line}")
        if (not Persona.PromptToTalk[Instructions, VoiceChannel]):
            Logger.Print("[client] murmur skipped (persona busy)", ?Level := log_level.Verbose)

    # The fear the take starts from, 0-3. Sets the haze's starting level.
    StartingFear()<transacts>:int =
        if (Now := Feeling?) then Clamp(Now.Fear, 0, 3) else 0

    # ---- Verdict ----

    # Asks the session, silently, to score the take. False if the prompt failed.
    # Spike 1 fallbacks, in order (docs/design.md, "Technical risks"):
    #  1. Prompt the client to say one of the dream's three verdict lines and match the text
    #     from Persona.CommitSayEvent (Localize the message, compare to the three lines).
    #  2. If the client judges too kindly, a separate judge persona gives the score.
    #  3. Fixed scores per setup option, with the LLM only adding flavor.
    # Any of these can sit behind this function as long as it still returns ?take_score.
    RequestScore()<suspends>:?take_score =
        Result := Persona.GetAISession().Prompt(ToMessage(VerdictPromptText), take_score)
        if (Score := Result.GetSuccess[]):
            option{Score}
        else:
            LogPromptError("verdict", option{Result.GetError[]})
            false

    # Asks the session for what to carry forward, and stores it. Call right after RequestScore,
    # while the session still holds the take's conversation. Runs after good and bad takes alike.
    RequestMemory()<suspends>:void =
        Result := Persona.GetAISession().Prompt(ToMessage(MemoryPromptText), take_memory)
        if (Recalled := Result.GetSuccess[]):
            Remember(Recalled)
        else:
            LogPromptError("memory", option{Result.GetError[]})

    Remember(Recalled:take_memory):void =
        set Feeling = option{Recalled.State}
        var Fresh:[]message = array{VisitorLine(Recalled.WhoTheVisitorWas)}
        for (Moment : Recalled.KeyMoments):
            set Fresh += array{Moment}
        for (Promise : Recalled.PromisesOrRequests):
            set Fresh += array{SaidLine(Promise)}
        set Memories = LastN(Memories + Fresh, MaxMemories)
        Logger.Print("[client] remembered {Fresh.Length} items, carrying {Memories.Length}")

    LogPromptError(What:string, MaybeError:?ai_error):void =
        if (Failure := MaybeError?):
            Detail := Localize(Failure.Message)
            Logger.Print("[client] {What} prompt failed: {Detail}", ?Level := log_level.Error)
        else:
            Logger.Print("[client] {What} prompt failed", ?Level := log_level.Error)

    # Has the client say the verdict line for this score, plus one sentence built from the hint.
    SpeakVerdict(Dream:dream, Score:take_score):logic =
        Line := case (Score.Verdict):
            take_verdict.Positive => Dream.PositiveLine
            take_verdict.Mixed => Dream.MixedLine
            take_verdict.Negative => Dream.NegativeLine
        SpeakInstructions(VerdictInstructions(Line, Score.HintForWeakestCriterion))

    # Has the client say one authored line and nothing else.
    SpeakLine(Line:string):logic =
        SpeakInstructions(ToMessage("Say exactly this line and nothing else: \"{Line}\""))

    SpeakInstructions(Instructions:message):logic =
        if (Persona.PromptToTalk[Instructions, VoiceChannel]):
            true
        else:
            Logger.Print("[client] the persona refused a line prompt", ?Level := log_level.Warning)
            false

    # ---- Waiting on speech ----

    # Returns when the client stops talking, or after TimeoutSeconds.
    AwaitSpeechEnd(TimeoutSeconds:float)<suspends>:void =
        race:
            block:
                Persona.StopSayEvent.Await()
                Logger.Print("[client] finished speaking", ?Level := log_level.Verbose)
            block:
                Sleep(TimeoutSeconds)
                Logger.Print("[client] speech wait timed out", ?Level := log_level.Verbose)

    # Returns true when a player finishes saying something to the client, false after
    # TimeoutSeconds of silence.
    AwaitPlayerLine(TimeoutSeconds:float)<suspends>:logic =
        race:
            block:
                Persona.StopHearEvent.Await()
                true
            block:
                Sleep(TimeoutSeconds)
                false
