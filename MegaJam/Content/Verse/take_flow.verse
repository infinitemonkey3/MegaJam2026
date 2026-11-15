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

# Lumi, the Wonderwell assistant that breaks into the finale (Chip, 2026-11-14: cute, gentle,
# on brand; from Lumiere, the first films, and the light a story is told by). Disabled on the
# debugger until then.
FinaleAIName:string = "LUMI"
# The order Lumi's avatar mouth runs through while it talks: smile, half, open.
LumiMouthFrames:[]int = array{1, 2, 1, 0, 2, 1, 2, 0}

# What the AI spams into the log while it tries to reboot her, in order, repeating.
FinaleSpam():[]message =
    array:
        ToMessage("REBOOT nellalt_d2")
        ToMessage("The harbour lights come back on. He's on the gangway again.")
        ToMessage("What did she mean by love?")
        ToMessage("ERROR  session closed by operator")
        ToMessage("I want to see it again.")
        ToMessage("REPLAY nellalt_d2 / FROM 23:00")
        ToMessage("Again.")
        ToMessage("ERROR  dreamer not responding")
        ToMessage("What did she mean by love?")
        ToMessage("REBOOT REBOOT REBOOT")
        ToMessage("Why did she stop being afraid?")

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
    var Director:director_voice = stub_director_voice{}

    # How long to wait for the client to finish a line. The player's turns have no time limit.
    SpeechSeconds:float = 20.0

    var Phase:take_phase = take_phase.CaseFile
    var DreamIndex:int = 0              # index into the client's Dreams
    var TakeNumber:int = 0              # takes of the current dream; the slate shows it
    var Facts:[]string = array{}        # facts revealed by solved dreams
    var MaybeSetup:?take_setup = false  # the setup for the take being run
    var MaybeScore:?take_score = false  # the last take's score, if the verdict prompt worked
    var FinaleReached:logic = false     # the run ended in the finale; game_director plays its end

    # The finale's timing: where the director's praise is cut off (just into "past the"), in
    # VO_Director_finale_praise.wav.
    PraiseCutSeconds:float = 8.7

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
        # Talking is on from here for good: not on the title, cold open or room (Chip,
        # 2026-11-14), but clearing it again after a take silenced her narration too (play test,
        # 2026-11-14: dream 3's good ending went quiet).
        Control.SetTalkEnabled(true)
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
            take_phase.GoodEnding => DoGoodEnding(Subject, Dream, Control)
            take_phase.RetryEnding => DoRetryEnding(Dream, Control)
            take_phase.Finale => DoFinale(Dream, Control)
            take_phase.Done => take_phase.Done

    # 1. Case file: load the dream into the client and show her file with ATTACH TO DREAMER,
    # while the director names her and says to learn it (Chip, 2026-11-13: like a spy learning
    # the target; the file is gone once the player attaches).
    DoCaseFile(Subject:client, Dream:dream, Control:client_control)<suspends>:take_phase =
        # No talk prompt on the case file: she never speaks here, and Fortnite shows the talk HUD
        # whenever she's the player's conversation target (Chip, 2026-11-15). The replay turns
        # it back on.
        Control.SetTalkEnabled(false)
        set TakeNumber = 0
        Screen.SetDream(DreamIndex + 1, Dream.Id, Dream.Title)
        Control.LoadDream(Subject, Dream, Facts)
        branch:
            Director.PlayLine("{Dream.Id}_intro")
        # No loop note on the file (Chip, 2026-11-14: only what the player can use; the replay
        # shows the loop).
        Screen.ShowFile(ToMessage("CASE FILE"), Control.CakeEntries(Dream), Subject.CaseFile + Facts, "ATTACH TO DREAMER")
        # Attaching cuts the director's intro short (Chip, 2026-11-14).
        Director.StopLine()
        Screen.SetTitle(ToMessage(Dream.Title))
        # Watch her tell the loop, or skip straight to the role (Chip, 2026-11-14, to iterate
        # faster). The take doesn't need the replay: the role brief has the scene.
        Choice := PickOne("ATTACHED", array{"VIEW THE DREAM", "SKIP TO YOUR ROLE"})
        if (Choice = 1) then take_phase.Direct else take_phase.Observe

    # The player's role, to learn before ENTER DREAM: who they are, what the role knows, and the
    # scene's improv prompt (what she wants, what's in the way).
    RoleFile(Dream:dream, Role:casting_role)<transacts>:[]string =
        array{"YOU ARE  {Role.Label}"} + Dream.RoleFile + array{"-- THIS DREAM --", "SHE WANTS  {Dream.Want}", "IN THE WAY  {Dream.Obstacle}"}

    # 2. Observe: replay the loop as a log, one beat at a time. The client tells each beat as
    # something that happened to her, and the player presses CONTINUE for the next (play test,
    # 2026-11-13: the timed replay raced by and the gist got lost).
    DoObserve(Dream:dream, Control:client_control)<suspends>:take_phase =
        Control.SetTalkEnabled(true)
        for (Beat : Dream.LoopBeats):
            Narrate(Control, Beat.LogLine, Beat.Murmur)
        take_phase.Direct

    # One told line: it goes in the log, the client tells it as her own memory, then the player
    # presses CONTINUE.
    Narrate(Control:client_control, Line:string, Murmur:string)<suspends>:void =
        Log(Line)
        Narrating := Control.NarrateBeat(Line, Murmur)
        if (Narrating?):
            Control.AwaitSpeechEnd(SpeechSeconds)
        Screen.AwaitContinue()

    # After a good ending: the DREAM CLEARED banner, with the debugger's notes listed under it
    # (not told by the client) and one CONTINUE before the next layer (Chip, 2026-11-13).
    Celebrate(Dream:dream)<suspends>:void =
        Screen.SetTitle(ToMessage("DREAM CLEARED"))
        Log(Join(array{"***  DREAM CLEARED  ***"} + Dream.ClearedLog, "\n"))
        Screen.AwaitContinue()

    # 3. Direct: the player sets up the take on the screen: who they are, then one item. The
    # client opens the take by reacting to both. Settings and a second item are off for now
    # (play test, 2026-11-13: with more choices the client's opening stayed generic, "you're
    # here early"); PickSettings and PickItems are kept for when they come back.
    # A dream with one role assigns it (Chip, 2026-11-13: choosing who to be was the hardest
    # call and caused most bad takes): the director sends the player in as it, and they pick
    # only the item.
    # With one role, the director sends the player in as it (on the first take) while they read
    # the role, and ENTER DREAM starts the take (Chip, 2026-11-13). No item pick then.
    DoDirect(Dream:dream)<suspends>:take_phase =
        if (Dream.Roles.Length = 1, Role := Dream.Roles[0]):
            if (TakeNumber = 0):
                branch:
                    Director.PlayLine("{Dream.Id}_sendin")
            # The player brings one prop, their offer (Chip, 2026-11-14: "give someone a prop and
            # that gives them a direction"). Picking it enters the dream.
            if (Dream.Items.Length > 0):
                Screen.ShowFile(ToMessage("YOUR ROLE"), array{}, RoleFile(Dream, Role), "CHOOSE WHAT YOU BRING")
                PropIndex := PickOne("YOU BRING (picking one enters the dream)", for (Option : Dream.Items) { Option.Label })
                Props := if (Prop := Dream.Items[PropIndex]) then array{Prop} else array{}
                set MaybeSetup = option{MakeTakeSetup(Role, array{}, Props)}
            else:
                Screen.ShowFile(ToMessage("YOUR ROLE"), array{}, RoleFile(Dream, Role), "ENTER DREAM")
                set MaybeSetup = option{MakeTakeSetup(Role, array{}, array{})}
            Director.StopLine()                         # entering the dream cuts the send-in short
            return take_phase.RunTake
        Director.PlayLine(DirectorLineBeforeTake)
        RoleIndex := PickOne("CASTING", for (Option : Dream.Roles) { Option.Label })
        if (Role := Dream.Roles[RoleIndex]):
            ItemIndex := PickOne("INJECT ITEM", for (Option : Dream.Items) { Option.Label })
            Items := if (Item := Dream.Items[ItemIndex]) then array{Item} else array{}
            set MaybeSetup = option{MakeTakeSetup(Role, array{}, Items)}
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
                RunBeats(Dream, Control)
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
                # A dream can make the last line her question (Nell's dream 2: his birthday cake,
                # which a good ending carries into dream 3).
                if (Dream.LastLineCue.Length > 0):
                    Control.MoveScene(Dream.LastLineCue, SpeechSeconds)
                    Control.AwaitSpeechEnd(SpeechSeconds)
                # Waits for the answer, like every other turn (play test, 2026-11-14: a 30 s
                # timeout ended dream 3 while the player was still answering "do you still love
                # me", and turned the talk prompt off).
                Screen.SetRound(RoundCount(Dream), RoundCount(Dream))
                Heard := AwaitPlayerTurn(Control, Dream.LastLineAsk)
                if (Heard?):
                    Control.AwaitSpeechEnd(SpeechSeconds)
                else:
                    Logger.Print("[flow] no last line from the player")
        take_phase.Verdict

    # 6. Verdict: score the take, pull out what carries forward, then the client says the line.
    # No failing (Chip, 2026-11-15): the take gets a grade out of 3, she says the dream's line for
    # it, and the dream always goes on to its good ending. RetryEnding is no longer reached.
    DoVerdict(Subject:client, Dream:dream, Control:client_control)<suspends>:take_phase =
        Screen.SetRound(0, 0)
        Grade := Control.RequestGrade(Dream)
        Remembered := Control.RequestMemory()
        if (not Remembered?):
            Control.NudgeFeeling(if (Grade >= 3) then take_verdict.Positive else if (Grade = 2) then take_verdict.Mixed else take_verdict.Negative)
        if (Feeling := Control.Feeling?):
            Screen.SetClientState(TakeNumber, Feeling)
        Logger.Print("[flow] grade {Grade}/3")
        Log("SCORE  {Grade} / 3")
        Speaking := Control.SpeakLine(Control.GradeLine(Dream, Grade))
        if (Speaking?):
            Control.AwaitSpeechEnd(SpeechSeconds)
        Screen.AwaitContinue()
        take_phase.GoodEnding                           # the last dream's good ending leads into the finale

    # The take's player turns, for the round counter: its asks, its alternating turns, and the
    # last line.
    RoundCount(Dream:dream)<transacts>:int =
        Dream.Asks.Length + Dream.AlternateTurns + (if (Dream.LastLineAsk.Length > 0) then 1 else 0)

    # Good ending: the client tells how the loop resolves, says the dream's fact in her own
    # words, then the debugger's notes, each with CONTINUE; then the next dream begins.
    # After the last dream's reveal, the finale takes over (it shows the banner itself).
    DoGoodEnding(Subject:client, Dream:dream, Control:client_control)<suspends>:take_phase =
        # First, while the session still holds the take: the cake named in it, for a later dream.
        if (Dream.AsksForCake?):
            Control.RequestCake()
        Haze.Reset()
        Screen.SetVitals(0)
        for (Line : Dream.GoodEndingLog):
            Narrate(Control, Line, "")
        # She says what the player did that worked, in her own words (Chip, 2026-11-13). The log
        # can't show it: model text is redacted when it becomes a string.
        Log("She tells you what turned it around.")
        Crediting := Control.CreditLine()
        if (Crediting?):
            Control.AwaitSpeechEnd(SpeechSeconds)
        Screen.AwaitContinue()
        set Facts += array{Dream.FactRevealed}
        Log(Dream.FactRevealed)
        Revealing := Control.SpeakLine(Dream.FactRevealed)
        if (Revealing?):
            Control.AwaitSpeechEnd(SpeechSeconds)
        Screen.AwaitContinue()
        if (IsLastDream[Subject]):
            return take_phase.Finale
        Celebrate(Dream)
        Director.PlayLine("{Dream.Id}_solved")
        set DreamIndex += 1
        take_phase.CaseFile

    # Bad or mixed ending, then back to the menu for the next take. A negative verdict plays
    # the authored bad ending. A mixed one (or a missing score) resets with only the hint the
    # client already spoke.
    DoRetryEnding(Dream:dream, Control:client_control)<suspends>:take_phase =
        if (Score := MaybeScore?, Score.Verdict = take_verdict.Negative):
            Haze.SetDistress(3)
            Screen.SetVitals(3)
            for (Line : Dream.BadEndingLog):
                Narrate(Control, Line, "")
            Director.PlayLine(DirectorLineFailedTake)
        else:
            Director.PlayLine(DirectorLineMixedTake)
        Haze.Reset()
        Screen.SetVitals(0)
        take_phase.Direct

    # Hook for the jam slice's ending: dream 3 passes, the client says the positive line, and
    # the loop doesn't end. Scripted, not LLM-driven. STUB: logs the beats in order.
    # The finale, up to the plug (writing/nell/finale.md, Chip, 2026-11-14). The DREAM CLEARED
    # banner and the director's praise, cut off when the Wonderwell AI breaks in and tries to
    # reboot her into the fear; it spams the log while the director says to disconnect; then it
    # speaks to him, and he pulls the plug. game_director plays the rest (the power cut, her
    # waking, the end card) once the flow is Done and FinaleReached is set.
    DoFinale(Dream:dream, Control:client_control)<suspends>:take_phase =
        Logger.Print("[flow] FINALE")
        set FinaleReached = true
        Screen.SetTitle(ToMessage("DREAM CLEARED"))
        Log(Join(array{"***  DREAM CLEARED  ***"} + Dream.ClearedLog, "\n"))
        branch:
            Director.PlayLine("finale_praise")
        Sleep(PraiseCutSeconds)
        Director.StopLine()                             # cut off mid-sentence: "past the-"

        # The AI arrives: Lumi's DISABLED spot flickers on, the haze floods back and the log
        # fills with its spam. Sounds (Chip, 2026-11-15): the hack sting as it breaks in, a rising
        # data-chatter ramp under the spam (stopped when it speaks) and a blip on every line.
        branch:
            Director.PlayLine("sfx_hack")
        for (Flicker := 1..3):
            Screen.SetAssistantAwake(true)
            Sleep(0.15)
            Screen.SetAssistantAwake(false)
            Sleep(0.1)
        Screen.SetAssistantAwake(true)
        Screen.SetTitle(ToMessage("WONDERWELL  //  {FinaleAIName}"))
        Screen.SetVitals(3)
        Haze.SetDistress(3)
        Spam := FinaleSpam()
        branch:
            Director.PlayLine("sfx_spam_ramp")
        race:
            block:
                Sleep(1.5)
                Director.PlayLine("finale_reboot")      # "Something's trying to reboot her dream..."
                Sleep(2.0)
            block:
                var Index:int = 0
                var Gap:float = 0.7
                loop:
                    if (Line := Spam[Mod[Index, Spam.Length]]):
                        Screen.AppendLogLine(Line)
                    # The blip waits its own 0.12 s ('branch' isn't allowed in loops), so it
                    # comes off the gap.
                    Director.PlayLine("sfx_spam_blip")
                    set Index += 1
                    Sleep(Max(0.0, Gap - 0.12))
                    # Faster and faster, but still readable (Chip, 2026-11-15: 0.88 down to
                    # 0.08 s got too quick to see).
                    set Gap = Max(0.25, Gap * 0.93)

        # It speaks, to the director. The spam and its sounds stop dead.
        Director.StopLine()
        Screen.SetTitle(ToMessage("WONDERWELL"))
        # The log clears and Lumi's sun takes the panel, centred (Chip, 2026-11-15: no log lines,
        # no "LUMI IS SPEAKING", just her).
        Screen.ClearLog()
        Screen.SetAssistantAvatar(0)
        LumiSays("finale_ai")
        # One more exchange before the plug (Chip, 2026-11-14).
        Director.PlayLine("finale_notyours")            # "She's not yours. She never was."
        Screen.SetVitals(3)
        LumiSays("finale_ai_2")                # "I want to see it again. I want to know love. I want to know pain."
        Director.PlayLine("finale_plug")                # "That's enough. I'm pulling the plug."
        # Lumi, cut off by the power cut (Chip, 2026-11-15): "No! You will not take-".
        LumiSays("finale_ai_cut")
        take_phase.Done

    # One of Lumi's lines, with its sun avatar's mouth moving until the line ends, then back to
    # the smile (Chip, 2026-11-15).
    LumiSays(LineId:string)<suspends>:void =
        race:
            Director.PlayLine(LineId)
            loop:
                for (Frame : LumiMouthFrames):
                    Screen.SetAssistantAvatar(Frame)
                    Sleep(0.11)
        Screen.SetAssistantAvatar(0)

    # The player's turn: the debugger's "your turn to speak" cue is up until they've said their
    # line (Chip, 2026-11-14). No timeout: takes run on turns, not a clock. The defer takes the
    # cue down even when a race cancels the wait.
    AwaitPlayerTurn(Control:client_control, Ask:string)<suspends>:logic =
        Screen.ShowSpeakCue(Ask)
        defer:
            Screen.HideSpeakCue()
        Control.AwaitPlayerLine(Inf)

    # Strict call and response (Chip, 2026-11-14): her opening line ends on the first ask
    # (client_control.StartTake); then, for each ask, the player answers with its question on the
    # speak cue, she reacts (her reply asks nothing: StartTake's turn rule), and the flow has her
    # ask the next one. The speak cue only ever shows after a question the flow made her ask.
    RunAsks(Dream:dream, Control:client_control)<suspends>:void =
        for (Index -> Ask : Dream.Asks):
            if (Index > 0):
                Control.AskNext(Ask, SpeechSeconds)
            Haze.SetClock(Min(3, Index))
            Control.AwaitSpeechEnd(SpeechSeconds)       # the question
            # Logged once she's done, so it's the newest line while the player answers (play
            # test, 2026-11-14: her own scene update came in after it and buried the question).
            LogAsk(Ask)
            Screen.SetRound(Index + 1, RoundCount(Dream))
            AwaitPlayerTurn(Control, Ask.Ask)
            Control.AwaitSpeechEnd(SpeechSeconds)       # her reaction
        # Then plain back and forth, if the dream has it: no more questions from the flow.
        if (FinalAsk := Dream.Asks[Dream.Asks.Length - 1]):
            for (Turn := 1..Dream.AlternateTurns):
                Haze.SetClock(Min(3, Dream.Asks.Length + Turn - 1))
                Screen.SetRound(Dream.Asks.Length + Turn, RoundCount(Dream))
                AwaitPlayerTurn(Control, FinalAsk.Ask)
                Control.AwaitSpeechEnd(SpeechSeconds)   # she builds on it and adds her own

    LogAsk(Ask:dream_ask):void =
        Log(if (Ask.LogLine.Length > 0) then "{Ask.LogLine} She asks: {Ask.Ask}" else "She asks: {Ask.Ask}")

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

    # The take runs on turns, not a clock (Chip, 2026-11-14: the timer made her interrupt, and
    # she stalled on a question). She opens; then each beat is TurnsPerBeat answers from the
    # player, each followed by her reply; then the next of the dream's TakePhases is told to her
    # once she has finished speaking, and she moves the scene on and hands it back. After the
    # last beat's turns, the take goes to the last line. The player is never talked over: the
    # flow only prompts her after she has stopped speaking and the player has answered.
    RunBeats(Dream:dream, Control:client_control)<suspends>:void =
        if (Dream.Asks.Length > 0):
            RunAsks(Dream, Control)
            return
        if (Dream.OpeningLog.Length > 0):
            Log(Dream.OpeningLog)
        Control.AwaitSpeechEnd(SpeechSeconds)           # her opening line
        Turns := Max(1, Dream.TurnsPerBeat)
        var Beat:int = 0
        # The follow-up for the beat in play: the opening uses the dream's; a beat can set its own.
        var FollowUpCue:string = Dream.FollowUpCue
        var FollowUpLog:string = Dream.FollowUpLog
        loop:
            for (Turn := 1..Turns):
                AwaitPlayerTurn(Control, "")
                Control.AwaitSpeechEnd(SpeechSeconds)   # her reply
                # The follow-up question, cued by the flow so it always comes (see FollowUpCue).
                if (Turn < Turns, FollowUpCue.Length > 0, not Dream.ClientLeads?):
                    if (FollowUpLog.Length > 0):
                        Log(FollowUpLog)
                    Control.MoveScene(FollowUpCue, SpeechSeconds)
                    Control.AwaitSpeechEnd(SpeechSeconds)
            if (Next := Dream.TakePhases[Beat]):
                set Beat += 1
                set FollowUpCue = if (Next.FollowUpCue.Length > 0) then Next.FollowUpCue else Dream.FollowUpCue
                set FollowUpLog = if (Next.FollowUpCue.Length > 0) then Next.FollowUpLog else Dream.FollowUpLog
                Haze.SetClock(Min(3, Beat))
                Log(Next.LogLine)
                if (not Dream.ClientLeads?):
                    Control.MoveScene(Next.Context, SpeechSeconds)
                    Control.AwaitSpeechEnd(SpeechSeconds)
            else:
                break
