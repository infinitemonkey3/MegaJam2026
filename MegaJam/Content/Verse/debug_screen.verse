using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }

# Seam for the in-world debug screen (stream 5). The screen is display only: a UMG widget
# entity whose `message` fields are set from Verse. So this interface is "set these messages"
# plus two input waits, "next" and "confirm", which the real screen backs with /Verse.org/Input
# actions (GetPlayerInput[Player], GetInputEvents(Action).TriggerActivationEvent). The menu
# logic itself lives in take_flow. NOT COMPILED YET.
#
# Everything is a `message`, never a `string`: text written by the model is redacted when it
# is turned into a string, so it can only be passed through to UI.
EmptyText<localizes>:message = ""

debug_screen := interface:
    # The screen's title line: "DREAM DEBUGGER", "TAKE 2", the client's name.
    SetTitle(Title:message):void

    # Empties the log.
    ClearLog():void

    # Case file view: one message per entry.
    SetCaseFile(Entries:[]message):void

    # Adds one line to the scene log.
    AppendLogLine(Line:message):void

    # Directing menu: a title, the options, and which option is highlighted.
    SetMenu(Title:message, Options:[]message, Highlighted:int):void

    # "Take N" slate. Returns when the slate is done.
    ShowSlate(TakeNumber:int)<suspends>:void

    # Vitals trace speed, 0 (calm) to 3 (spiking).
    SetVitals(Level:int):void

    # The client's trust, fear and hope after a take, for the per-take chart.
    SetClientState(TakeNumber:int, Feeling:client_state):void

    # Return when the player presses "next" / "confirm".
    AwaitNext()<suspends>:void
    AwaitConfirm()<suspends>:void

    # Returns the index of a menu option the player picked directly (a click on the dream
    # debugger). Screens without direct picks never return.
    AwaitPick()<suspends>:int

    # Shows a CONTINUE prompt under the log, keeping the log on screen, and returns when the
    # player presses it. The replay waits on it between beats.
    AwaitContinue()<suspends>:void

# Logs every call. Never presses "next" and presses "confirm" after a moment, so every menu
# takes its first option and the flow runs unattended. Model-written text shows redacted here.
stub_debug_screen := class(debug_screen):
    Logger:log = log{Channel := dead_air_log}

    SetTitle<override>(Title:message):void =
        Text := Localize(Title)
        Logger.Print("[screen] TITLE {Text}")

    ClearLog<override>():void =
        Logger.Print("[screen] LOG cleared")

    SetCaseFile<override>(Entries:[]message):void =
        Logger.Print("[screen] CASE FILE {Entries.Length} entries")
        for (Entry : Entries):
            Text := Localize(Entry)
            Logger.Print("[screen]   {Text}")

    AppendLogLine<override>(Line:message):void =
        Text := Localize(Line)
        Logger.Print("[screen] LOG {Text}")

    SetMenu<override>(Title:message, Options:[]message, Highlighted:int):void =
        Text := Localize(Title)
        Logger.Print("[screen] MENU {Text}: {Options.Length} options, highlighted {Highlighted}")

    ShowSlate<override>(TakeNumber:int)<suspends>:void =
        Logger.Print("[screen] SLATE Take {TakeNumber}")
        Sleep(1.5)

    SetVitals<override>(Level:int):void =
        Logger.Print("[screen] VITALS level={Level}")

    SetClientState<override>(TakeNumber:int, Feeling:client_state):void =
        Logger.Print("[screen] STATE take={TakeNumber} trust={Feeling.Trust} fear={Feeling.Fear} hope={Feeling.Hope}")

    AwaitNext<override>()<suspends>:void =
        Sleep(Inf)

    AwaitConfirm<override>()<suspends>:void =
        Sleep(0.5)

    AwaitContinue<override>()<suspends>:void =
        Logger.Print("[screen] CONTINUE")
        Sleep(0.5)

    AwaitPick<override>()<suspends>:int =
        Sleep(Inf)
        0
