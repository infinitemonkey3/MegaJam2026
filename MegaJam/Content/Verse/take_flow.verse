using { /Fortnite.com/AI }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }

# The take loop for one client with several dreams (docs/design.md, "Core loop" and "Jam
# slice"), as a state machine. Each phase function does its work and returns the next phase.
# NOT COMPILED YET: see CLAUDE.md in this folder.
#
#   CaseFile -> Observe -> Direct -> RunTake -> LastLine -> Verdict
#   Verdict, positive          -> GoodEnding -> CaseFile of the next dream
#   Verdict, positive, dream 3 -> Finale -> Done   (the loop doesn't end: scripted ending)
#   Verdict, mixed or negative -> RetryEnding -> Direct   ("Take N+1")

take_phase := enum{CaseFile, Observe, Direct, RunTake, LastLine, Verdict, GoodEnding, RetryEnding, Finale, Done}

PhaseName(Value:take_phase)<transacts>:string =
    case (Value):
        take_phase.CaseFile => "CaseFile"
        take_phase.Observe => "Observe"
        take_phase.Direct => "Direct"
        take_phase.RunTake => "RunTake"
        take_phase.LastLine => "LastLine"
        take_phase.Verdict => "Verdict"
        take_phase.GoodEnding => "GoodEnding"
        take_phase.RetryEnding => "RetryEnding"
        take_phase.Finale => "Finale"
        take_phase.Done => "Done"

# The menu option that ends a settings or items menu early.
MenuDoneLabel:string = "Done"

take_flow := class(creative_device):
    Logger:log = log{Channel := dead_air_log}

    # The spawner for the client NPC. Its character definition must use client_npc_behavior.
    @editable
    ClientSpawner:npc_spawner_device = npc_spawner_device{}

    # Off when game_director runs the game (it calls RunClient). On to test the take loop alone.
    @editable RunOnBegin:logic = false

    # Seams. Swap the stubs for the real screen, haze devices and audio when they exist.
    # game_director replaces Screen with the in-world screen.
    var Screen:debug_screen = stub_debug_screen{}
    Haze:haze_controller = haze_controller{}
    Director:director_voice = stub_director_voice{}

    # How long to wait for the player's last line, and for the client to finish a line.
    LastLineSeconds:float = 30.0
    SpeechSeconds:float = 20.0

    var Phase:take_phase = take_phase.CaseFile
    var DreamIndex:int = 0              # index into the client's Dreams
    var TakeNumber:int = 0              # takes of the current dream; the slate shows it
    var Facts:[]string = array{}        # facts revealed by solved dreams
    var MaybeSetup:?take_setup = false  # the setup for the take being run
    var MaybeScore:?take_score = false  # the last take's score, if the verdict prompt worked

    OnBegin<override>()<suspends>:void =
        if (not RunOnBegin?):
            return
        Logger.Print("[flow] waiting for the client NPC")
        loop:
            if (Control := FindClientControl[]):
                RunClient(MakePlaceholderClient(), Control)
                break
            Sleep(0.5)

    # The client NPC's control, once its behavior has finished setting up. Polled rather than
    # taken from SpawnedEvent, so it doesn't matter whether the NPC spawns before this device begins.
    FindClientControl()<transacts><decides>:client_control =
        var Found:?client_control = false
        for:
            Agent : ClientSpawner.GetAgents()
            Behavior := client_npc_behavior[Agent.GetNPCBehavior[]]
            Control := Behavior.MaybeControl?
        do:
            set Found = option{Control}
        Found?

    RunClient(Subject:client, Control:client_control)<suspends>:void =
        Logger.Print("[flow] client {Subject.Id}, {Subject.Dreams.Length} dreams")
        Control.RegisterSceneUpdate()
        loop:
            if (Phase = take_phase.Done):
                break
            if (Dream := Subject.Dreams[DreamIndex]):
                Next := RunPhase(Subject, Dream, Control)
                From := PhaseName(Phase)
                To := PhaseName(Next)
                Logger.Print("[flow] {Dream.Id} take {TakeNumber}: {From} -> {To}")
                set Phase = Next
            else:
                Logger.Print("[flow] no dream at index {DreamIndex}", ?Level := log_level.Error)
                break
        Logger.Print("[flow] done")

    RunPhase(Subject:client, Dream:dream, Control:client_control)<suspends>:take_phase =
        case (Phase):
            take_phase.CaseFile => DoCaseFile(Subject, Dream, Control)
            take_phase.Observe => DoObserve(Dream, Control)
            take_phase.Direct => DoDirect(Dream)
            take_phase.RunTake => DoRunTake(Dream, Control)
            take_phase.LastLine => DoLastLine(Dream, Control)
            take_phase.Verdict => DoVerdict(Subject, Dream, Control)
            take_phase.GoodEnding => DoGoodEnding(Dream)
            take_phase.RetryEnding => DoRetryEnding(Dream)
            take_phase.Finale => DoFinale()
            take_phase.Done => take_phase.Done

    # 1. Case file: load the dream into the client, show the file, the director's aside.
    DoCaseFile(Subject:client, Dream:dream, Control:client_control)<suspends>:take_phase =
        set TakeNumber = 0
        Control.LoadDream(Subject, Dream, Facts)
        Entries := for (Entry : Subject.CaseFile + Facts + array{Dream.LoopNote}) { ToMessage(Entry) }
        Screen.SetCaseFile(Entries)
        Director.PlayLine("{Dream.Id}_intro")
        take_phase.Observe

    # 2. Observe: replay the loop as a log, the client murmuring over it.
    DoObserve(Dream:dream, Control:client_control)<suspends>:take_phase =
        for (Beat : Dream.LoopBeats):
            Log(Beat.LogLine)
            if (Beat.Murmur.Length > 0):
                Control.MurmurLine(Beat.Murmur)
            Sleep(Beat.HoldSeconds)
        take_phase.Direct

    # 3. Direct: the player sets up the take on the screen: a role, then up to 2 settings,
    # then up to 2 items.
    DoDirect(Dream:dream)<suspends>:take_phase =
        Director.PlayLine(DirectorLineBeforeTake)
        RoleIndex := PickOne("CASTING", for (Option : Dream.Roles) { Option.Label })
        if (Role := Dream.Roles[RoleIndex]):
            Settings := PickSettings(Dream)
            Items := PickItems(Dream)
            set MaybeSetup = option{MakeTakeSetup(Role, Settings, Items)}
            take_phase.RunTake
        else:
            Logger.Print("[flow] {Dream.Id} has no roles to cast", ?Level := log_level.Error)
            take_phase.Done

    # Shows one menu and returns the index the player chose: "next" moves the highlight and
    # "confirm" takes it, or the screen reports a direct pick (a click on the dream debugger).
    PickOne(Title:string, Labels:[]string)<suspends>:int =
        Options := for (Label : Labels) { ToMessage(Label) }
        var Highlighted:int = 0
        loop:
            Screen.SetMenu(ToMessage(Title), Options, Highlighted)
            # -1: confirm the highlight; -2: next; 0 or more: picked directly.
            Choice := race:
                block:
                    Screen.AwaitConfirm()
                    -1
                block:
                    Screen.AwaitNext()
                    -2
                Screen.AwaitPick()
            if (Choice >= 0):
                set Highlighted = Choice
                break
            if (Choice = -1):
                break
            if (Wrapped := Mod[Highlighted + 1, Max(1, Labels.Length)]):
                set Highlighted = Wrapped
        Highlighted

    # Up to MaxSettings settings, one per element (picking an oven setting removes the other
    # oven settings). The last option, MenuDoneLabel, stops early.
    PickSettings(Dream:dream)<suspends>:[]scene_setting =
        var Remaining:[]scene_setting = Dream.Settings
        var Chosen:[]scene_setting = array{}
        loop:
            if (Chosen.Length >= MaxSettings or Remaining.Length = 0):
                break
            Index := PickOne("SCENE SETTINGS", (for (Option : Remaining) { Option.Label }) + array{MenuDoneLabel})
            if (Pick := Remaining[Index]):
                set Chosen += array{Pick}
                set Remaining = for (Option : Remaining, Option.Element <> Pick.Element) { Option }
            else:
                break
        Chosen

    # Up to MaxItems items. The last option, MenuDoneLabel, stops early.
    PickItems(Dream:dream)<suspends>:[]inject_item =
        var Remaining:[]inject_item = Dream.Items
        var Chosen:[]inject_item = array{}
        loop:
            if (Chosen.Length >= MaxItems or Remaining.Length = 0):
                break
            Index := PickOne("INJECT ITEMS", (for (Option : Remaining) { Option.Label }) + array{MenuDoneLabel})
            if (Pick := Remaining[Index], Rest := Remaining.RemoveElement[Index]):
                set Chosen += array{Pick}
                set Remaining = Rest
            else:
                break
        Chosen

    # Adds an authored line to the screen's scene log.
    Log(Line:string):void =
        Screen.AppendLogLine(ToMessage(Line))

    # 4. Run the take: slate, setup edits in the log, then the player talks to the client while
    # the clock runs toward the moment the loop always ends.
    DoRunTake(Dream:dream, Control:client_control)<suspends>:take_phase =
        if (Setup := MaybeSetup?):
            set TakeNumber += 1
            Screen.ShowSlate(TakeNumber)
            Log(Setup.Role.LogEdit)
            for (Setting : Setup.Settings):
                Log(Setting.LogEdit)
            for (Item : Setup.Items):
                Log(Item.LogEdit)

            Haze.Reset()
            Haze.SetSetupRisk(SetupHazeBase(Setup))
            Haze.SetDistress(Control.StartingFear())

            Control.StartTake(Dream, Setup, TakeNumber)
            race:
                WatchScene(Control)
                RunClock(Dream)
            take_phase.LastLine
        else:
            Logger.Print("[flow] no setup for the take; back to the menu", ?Level := log_level.Warning)
            take_phase.Direct

    # 5. Last line: the loop reaches the moment it always ends. The player gets one more line,
    # and the client answers it, before the take is judged.
    DoLastLine(Dream:dream, Control:client_control)<suspends>:take_phase =
        Log(Dream.EndingBeatLog)
        race:
            WatchScene(Control)
            block:
                Heard := Control.AwaitPlayerLine(LastLineSeconds)
                if (Heard?):
                    Control.AwaitSpeechEnd(SpeechSeconds)
                else:
                    Logger.Print("[flow] no last line from the player")
        take_phase.Verdict

    # 6. Verdict: score the take, pull out what carries forward, then the client says the line.
    DoVerdict(Subject:client, Dream:dream, Control:client_control)<suspends>:take_phase =
        set MaybeScore = Control.RequestScore()
        Remembered := Control.RequestMemory()
        if (not Remembered?, Score := MaybeScore?):
            Control.NudgeFeeling(Score.Verdict)
        if (Feeling := Control.Feeling?):
            Screen.SetClientState(TakeNumber, Feeling)

        if (Score := MaybeScore?):
            Total := Score.BackstoryScore + Score.PersonalityScore + Score.EnvironmentScore + Score.CommonSenseScore
            Logger.Print("[flow] score backstory={Score.BackstoryScore} personality={Score.PersonalityScore} environment={Score.EnvironmentScore} common_sense={Score.CommonSenseScore} total={Total}")
            Control.SpeakVerdict(Dream, Score)
            Control.AwaitSpeechEnd(SpeechSeconds)
            if (Score.Verdict = take_verdict.Positive):
                if (IsLastDream[Subject]) then take_phase.Finale else take_phase.GoodEnding
            else:
                take_phase.RetryEnding
        else:
            # No score came back. Treat the take as mixed so the player can go again; see the
            # fallbacks on client_control.RequestScore.
            Logger.Print("[flow] no verdict; treating the take as mixed", ?Level := log_level.Warning)
            Control.SpeakLine(Dream.MixedLine)
            Control.AwaitSpeechEnd(SpeechSeconds)
            take_phase.RetryEnding

    # Good ending: the loop resolves its authored way, the client gives up the dream's fact,
    # and the next dream begins.
    DoGoodEnding(Dream:dream)<suspends>:take_phase =
        Haze.Reset()
        Screen.SetVitals(0)
        for (Line : Dream.GoodEndingLog):
            Log(Line)
            Sleep(1.5)
        set Facts += array{Dream.FactRevealed}
        Log("RECOVERED {Dream.FactRevealed}")
        Director.PlayLine("{Dream.Id}_solved")
        set DreamIndex += 1
        take_phase.CaseFile

    # Bad or mixed ending, then back to the menu for the next take. A negative verdict plays
    # the authored bad ending. A mixed one (or a missing score) resets with only the hint the
    # client already spoke.
    DoRetryEnding(Dream:dream)<suspends>:take_phase =
        if (Score := MaybeScore?, Score.Verdict = take_verdict.Negative):
            Haze.SetDistress(3)
            Screen.SetVitals(3)
            for (Line : Dream.BadEndingLog):
                Log(Line)
                Sleep(1.5)
            Director.PlayLine(DirectorLineFailedTake)
        else:
            Director.PlayLine(DirectorLineMixedTake)
        Haze.Reset()
        Screen.SetVitals(0)
        take_phase.Direct

    # Hook for the jam slice's ending: dream 3 passes, the client says the positive line, and
    # the loop doesn't end. Scripted, not LLM-driven. STUB: logs the beats in order.
    DoFinale()<suspends>:take_phase =
        Logger.Print("[flow] FINALE (stub)")
        Haze.Reset()                                    # the take passed: the haze clears...
        Sleep(2.0)
        Log("FINALE the AI's log lines go here")
        Screen.SetVitals(3)
        Haze.SetDistress(3)                             # ...then floods back to maximum
        Logger.Print("[flow] FINALE the AI's voice line (stub)")
        Director.PlayLine(DirectorLineEndingReaction)
        Logger.Print("[flow] FINALE cut to black, thank-you card (stub)")
        take_phase.Done

    IsLastDream(Subject:client)<transacts><decides>:void =
        DreamIndex + 1 >= Subject.Dreams.Length

    # Feeds the client's live scene_update into the haze, the vitals and the log. Never
    # returns; run it in a race with whatever ends the phase.
    WatchScene(Control:client_control)<suspends>:void =
        loop:
            Update := Control.SceneUpdateEvent.Await()
            Level := Clamp(Update.Distress, 0, 3)
            Haze.SetDistress(Level)
            Screen.SetVitals(Level)
            # Passed through untouched: model text is redacted as a string, so never branch on it.
            Screen.AppendLogLine(Update.LogLine)

    # The take's clock: the haze's clock input rises a step each quarter of the take, and the
    # function returns when the take reaches the moment the loop always ends.
    RunClock(Dream:dream)<suspends>:void =
        Quarter := Dream.TakeSeconds / 4.0
        for (Step := 1..3):
            Sleep(Quarter)
            Haze.SetClock(Step)
        Sleep(Quarter)
