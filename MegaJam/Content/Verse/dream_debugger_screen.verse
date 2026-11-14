using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The dream debugger: the in-world screen inside the monitor (Chip, 2026-11-13). It's the
# UW_DreamDebugger widget (Content/DreamDebugger) placed as a Scene Graph entity just behind the
# monitor plane, whose glass is cut out of its texture so the bezel frames the widget. The
# widget's TitleMessage, BodyMessage and MenuMessage Verse fields drive its three text blocks.
# In-world widgets are display only, so input comes from the input router, as on the overlay.
#
# The text helpers (OverlayNewLine, OverlayPicked, ...) are shared with overlay_screen.

dream_debugger_screen := class(debug_screen):
    Entity:DreamDebugger.UW_DreamDebugger_entity
    Input:input_router

    Logger:log = log{Channel := dead_air_log}
    MaxLogLines:int = 10

    var Lines:[]message = array{}

    # Blank screen: the widget's fields start with the designer's sample text.
    Clear():void =
        set Lines = array{}
        set Entity.TitleMessage = EmptyText
        set Entity.BodyMessage = EmptyText
        set Entity.MenuMessage = EmptyText

    SetTitle<override>(Title:message):void =
        set Entity.TitleMessage = Title

    ClearLog<override>():void =
        set Lines = array{}
        set Entity.BodyMessage = EmptyText

    AppendLogLine<override>(Line:message):void =
        set Lines = LastN(Lines + array{Line}, MaxLogLines)
        set Entity.BodyMessage = Join(Lines, OverlayNewLine)

    SetCaseFile<override>(Entries:[]message):void =
        set Lines = Entries
        set Entity.BodyMessage = Join(Lines, OverlayNewLine)

    SetMenu<override>(MenuTitle:message, Options:[]message, Highlighted:int):void =
        if (Options.Length = 0):
            set Entity.MenuMessage = MenuTitle
        else:
            Items := for (Index -> Option : Options):
                if (Index = Highlighted) then OverlayPicked(Option) else OverlayUnpicked(Option)
            set Entity.MenuMessage = Join(array{MenuTitle} + Items, OverlayMenuGap)

    ShowSlate<override>(TakeNumber:int)<suspends>:void =
        SetTitle(OverlaySlate(TakeNumber))
        Sleep(1.5)

    # No vitals or chart on the screen yet: log only.
    SetVitals<override>(Level:int):void =
        Logger.Print("[screen] VITALS level={Level}", ?Level := log_level.Verbose)

    SetClientState<override>(TakeNumber:int, Feeling:client_state):void =
        Logger.Print("[screen] STATE take={TakeNumber} trust={Feeling.Trust} fear={Feeling.Fear} hope={Feeling.Hope}")

    AwaitNext<override>()<suspends>:void =
        Input.NextEvent.Await()

    AwaitConfirm<override>()<suspends>:void =
        Input.ConfirmEvent.Await()

    AwaitContinue<override>()<suspends>:void =
        Input.ConfirmEvent.Await()

    AwaitPick<override>()<suspends>:int =
        Sleep(Inf)
        0

    # The file as the log, and the confirm key for its button.
    ShowFile<override>(FileTitle:message, Heading:[]message, FileLines:[]string, Button:string)<suspends>:void =
        SetTitle(FileTitle)
        SetCaseFile(Heading + (for (Line : FileLines) { ToMessage(Line) }) + array{ToMessage("[ {Button} ]")})
        Input.ConfirmEvent.Await()
