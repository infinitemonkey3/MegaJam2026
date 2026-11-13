using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# The interactive dream debugger (Chip, 2026-11-13): Wonderwell's dream debugger, a cracked
# unregistered copy, naming the patient, with tabs for the case file, the dreams to invoke, and
# the Wonderwell AI assistant (a flipbook character later; for now a face and preset questions).
#
# Two layers over the monitor's glass hole, placed by monitor_projection:
#  - the text: UW_DebuggerText (Content/DreamDebugger), a UMG widget with 18 rows of NotoSans
#    text, one Verse field per row (Row00Text..Row17Text; row 4 is three tab labels,
#    Tab0Text..Tab2Text). Verse UI can't set a font, UMG can. UEFN has no monospace font that
#    passes validation (DroidSansMono is /Engine, and .ttf imports are refused), so NotoSans it
#    is. The page is 1300 x 1000 in a Scale Box, so it scales evenly into the hole.
#  - the input: invisible Verse UI buttons over the selectable rows. Hovering one focuses it and
#    moves the ">" cursor in the text; a mouse click or Space (Jump) selects it. Arrow keys and
#    Enter don't work in Fortnite's UI.
# The dark fill behind is the world's glass and in-world screen, which get the camera's
# perspective (a flat UI fill didn't match).
#
# Invoking a dream and asking a question only log for now; they get wired to the take flow and
# the AI persona next. Shown with input mode All, so while it's up it has the mouse and focus.

DebuggerRowCount:int = 18
DebuggerColumns:int = 72      # wrap width in characters (NotoSans 28 px on the 1300 px page)
DebuggerBodyFirst:int = 6     # rows 6..15 are the tab's body
DebuggerBodyLast:int = 15

DebuggerTabNames:[]string = array{"CASE FILE", "DREAMS", "ASSISTANT"}
DebuggerQuestions:[]string = array:
    "What is this program?"
    "Who is the patient?"
    "How do I run a take?"

# Word-wraps Text to lines of at most Width characters.
WrapText(Text:string, Width:int)<transacts>:[]string =
    var Lines:[]string = array{}
    var Line:string = ""
    var Word:string = ""
    for (C : Text + " "):
        if (C = ' '):
            if (Word.Length > 0):
                if (Line.Length = 0):
                    set Line = Word
                else if (Line.Length + 1 + Word.Length <= Width):
                    set Line = Line + " " + Word
                else:
                    set Lines += array{Line}
                    set Line = Word
                set Word = ""
        else:
            set Word += array{C}
    if (Line.Length > 0):
        set Lines += array{Line}
    Lines

TakeCursorOn<localizes>(Line:message):message = "> {Line}"
TakeCursorOff<localizes>(Line:message):message = "  {Line}"
TakeTitle<localizes>(Title:message):message = "[ {Title} ]"

# One invisible button over a row (or part of a row). Action: 0..2 tabs, 100+ dreams,
# 200+ questions, 300+ take menu options, ContinueAction.
ContinueAction:int = 400

debugger_hotspot := class:
    Row:int
    Action:int
    Owner:dream_debugger_ui
    Button:button

    # A click goes to the focused button, not the one under the mouse, and hovering doesn't move
    # focus on its own (play test, 2026-11-13), so hovering a line focuses it.
    OnHighlight(Message:widget_message):void =
        Owner.FocusButton(Button)
        Owner.MoveCursor(Action)

    OnClick(Message:widget_message):void =
        Owner.Activate(Action)

dream_debugger_ui := class(debug_screen):
    Client:client

    # INVOKE on the DREAMS tab: the dream's index. game_director starts the take.
    InvokeEvent:event(int) = event(int){}
    # A take menu option clicked or selected: its index (debug_screen.AwaitPick).
    PickEvent:event(int) = event(int){}
    # The CONTINUE prompt was pressed (debug_screen.AwaitContinue).
    ContinueEvent:event() = event(){}

    Logger:log = log{Channel := dead_air_log}

    # The glass hole in the monitor texture (2048 px): x 249..1800, y 282..1478, with a margin so
    # the text clears the rounded corners.
    HoleLeft:float = 290.0 / 2048.0
    HoleTop:float = 315.0 / 2048.0
    HoleRight:float = 1760.0 / 2048.0
    HoleBottom:float = 1445.0 / 2048.0

    View:DreamDebugger.UW_DebuggerText = DreamDebugger.UW_DebuggerText{}

    var MaybePlayerUI:?player_ui = false
    var MaybeRoot:?canvas = false
    var Area:monitor_rect = monitor_rect{Left := 0.0, Top := 0.0, Width := 0.0, Height := 0.0}
    var Hotspots:[]debugger_hotspot = array{}
    var Tab:int = 0
    var Cursor:int = 0
    var Reply:string = ""
    var Page:int = 0
    var Notice:string = ""

    # The TAKE view: while the take flow runs, rows 6..15 are its scene log or its menu.
    var InTake:logic = false
    var Title:message = EmptyText
    var TakeLog:[]message = array{}
    var MenuTitle:message = EmptyText
    var MenuOptions:[]message = array{}
    var Vitals:int = 0
    # True while the take flow waits on CONTINUE; row 16 shows it instead of the vitals.
    var ContinueShown:logic = false
    # How many lines show above the newest one; prose lines wrap to two or three rows each.
    TakeLogLines:int = 3
    # Input mode All while there's something to click; None while the player talks, so Fortnite
    # gets the keyboard (and the talk key) back.
    var Clickable:logic = true

    # Shows the debugger over the monitor, given the monitor plane's screen rectangle.
    Show(Player:player, Monitor:monitor_rect):void =
        if (not MaybeRoot?, PlayerUI := GetPlayerUI[Player]):
            set Area = monitor_rect:
                Left := Monitor.Left + Monitor.Width * HoleLeft
                Top := Monitor.Top + Monitor.Height * HoleTop
                Width := Monitor.Width * (HoleRight - HoleLeft)
                Height := Monitor.Height * (HoleBottom - HoleTop)
            Root := canvas:
                Slots := array:
                    canvas_slot{Anchors := AreaAnchors(0.0, 0.0, 1.0, 1.0), Offsets := margin{}, Widget := View}
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 800, InputMode := ui_input_mode.All})
            set MaybePlayerUI = option{PlayerUI}
            set MaybeRoot = option{Root}
            OpenTab(0)
            Logger.Print("[ui] dream debugger shown")

    # Re-adds the debugger with input mode All (menus) or None (talking in a take).
    SetClickable(On:logic):void =
        if (On <> Clickable, PlayerUI := MaybePlayerUI?, Root := MaybeRoot?):
            set Clickable = On
            PlayerUI.RemoveWidget(Root)
            Mode := if (On?) then ui_input_mode.All else ui_input_mode.None
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 800, InputMode := Mode})
            if (On?):
                RebuildHotspots()

    Hide():void =
        if (PlayerUI := MaybePlayerUI?, Root := MaybeRoot?):
            PlayerUI.RemoveWidget(Root)
        set MaybeRoot = false

    # Anchors for a part of the text area, in fractions of it (0..1).
    AreaAnchors(X0:float, Y0:float, X1:float, Y1:float):anchors =
        anchors:
            Minimum := vector2{X := Area.Left + Area.Width * X0, Y := Area.Top + Area.Height * Y0}
            Maximum := vector2{X := Area.Left + Area.Width * X1, Y := Area.Top + Area.Height * Y1}

    # ---- Actions ----

    FocusButton(Target:button):void =
        if (PlayerUI := MaybePlayerUI?):
            PlayerUI.SetFocus(Target)

    MoveCursor(Action:int):void =
        set Cursor = Action
        Render()

    Activate(Action:int):void =
        if (Action = MoreAction):
            # Next page of the case file, wrapping round.
            set Page = if (Page + 1 < CasePageCount()) then Page + 1 else 0
            Render()
        else if (Action < 3):
            OpenTab(Action)
        else if (Action < 200):
            Logger.Print("[ui] invoke dream {Action - 100}")
            InvokeEvent.Signal(Action - 100)
        else if (Action = ContinueAction):
            ContinueEvent.Signal()
        else if (Action >= 300):
            PickEvent.Signal(Action - 300)
        else:
            set Reply = "ASSISTANT> ...the answer will appear here."
            Logger.Print("[ui] ask question {Action - 200} (not wired yet)")
            Render()

    OpenTab(Index:int):void =
        set Tab = Index
        set Cursor = Index
        set Page = 0
        set Reply = ""
        RebuildHotspots()
        Render()

    # ---- Buttons ----

    RebuildHotspots():void =
        if (Root := MaybeRoot?):
            for (Old : Hotspots):
                Root.RemoveWidget(Old.Button)
            set Hotspots = array{}
            if (InTake?):
                # Only the menu's options, from row 7 (row 6 is the menu's title).
                for (I -> Option : MenuOptions, DebuggerBodyFirst + 1 + I <= DebuggerBodyLast):
                    AddHotspot(Root, DebuggerBodyFirst + 1 + I, 300 + I, 0.0, 1.0)
                if (ContinueShown?):
                    AddHotspot(Root, 16, ContinueAction, 0.0, 1.0)
                if (First := Hotspots[0], PlayerUI := MaybePlayerUI?):
                    PlayerUI.SetFocus(First.Button)
            else:
                # The tabs share row 4, a third of the row each.
                for (I -> Name : DebuggerTabNames):
                    AddHotspot(Root, 4, I, (1.0 * I) / 3.0, (1.0 * (I + 1)) / 3.0)
                for (I -> Action : BodyActions()):
                    if (Action >= 0):
                        AddHotspot(Root, DebuggerBodyFirst + I, Action, 0.0, 1.0)
                if (First := Hotspots[Tab], PlayerUI := MaybePlayerUI?):
                    PlayerUI.SetFocus(First.Button)

    AddHotspot(Root:canvas, Row:int, Action:int, X0:float, X1:float):void =
        # The button takes the size of its content, so the content is the row's full rectangle,
        # in 1080p UI units. Invisible; the text widget above ignores the mouse, so the buttons
        # get it (it covered them until its root was Not Hit-Testable, Self & All Children).
        W := Area.Width * (X1 - X0) * 1920.0
        H := Area.Height * (1.0 / (1.0 * DebuggerRowCount)) * 1080.0
        Fill := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X := W, Y := H}}
        Hotspot := debugger_hotspot:
            Row := Row
            Action := Action
            Owner := Self
            Button := button{Slot := button_slot{Widget := Fill, HorizontalAlignment := horizontal_alignment.Fill, VerticalAlignment := vertical_alignment.Fill}}
        Hotspot.Button.HighlightEvent().Subscribe(Hotspot.OnHighlight)
        Hotspot.Button.OnClick().Subscribe(Hotspot.OnClick)
        Y0 := (1.0 * Row) / (1.0 * DebuggerRowCount)
        Y1 := (1.0 * (Row + 1)) / (1.0 * DebuggerRowCount)
        Root.AddWidget(canvas_slot{Anchors := AreaAnchors(X0, Y0, X1, Y1), Offsets := margin{}, Alignment := vector2{X := 0.0, Y := 0.0}, SizeToContent := false, Widget := Hotspot.Button})
        set Hotspots += array{Hotspot}


    # ---- Case file pages ----

    # Rows 6..14 show the case file; row 15 is the selectable "[ MORE ]" line.
    CasePageRows:int = 9
    MoreAction:int = 50

    CaseFileLines()<transacts>:[]string =
        var Lines:[]string = array{}
        for (Entry : Client.CaseFile, Line : WrapText(Entry, DebuggerColumns - 4)):
            set Lines += array{Line}
        Lines

    CasePageCount()<transacts>:int =
        Count := CaseFileLines().Length
        if (Pages := Quotient[Count + CasePageRows - 1, CasePageRows], Pages > 0) then Pages else 1

    # ---- Text ----

    # The body's lines for the open tab, and the action of each (-1: not selectable).
    BodyLines()<transacts>:[]string =
        case (Tab):
            0 =>
                All := CaseFileLines()
                Start := Page * CasePageRows
                Shown := for (I -> Line : All, I >= Start, I < Start + CasePageRows):
                    Line
                if (CasePageCount() > 1):
                    Blank := for (I := Shown.Length..CasePageRows - 1):
                        ""
                    Shown + Blank + array{"[ MORE  {Page + 1}/{CasePageCount()} ]"}
                else:
                    Shown
            1 =>
                for (Dream : Client.Dreams):
                    "INVOKE  {Dream.Title}"
            _ =>
                Face := array{"(o_o)  WONDERWELL ASSISTANT  //  listening", ""}
                Asks := for (Question : DebuggerQuestions):
                    Question
                Tail := if (Reply.Length > 0) then array{"", Reply} else array{}
                Face + Asks + Tail

    BodyActions()<transacts>:[]int =
        case (Tab):
            0 =>
                if (CasePageCount() > 1):
                    Blank := for (I := 1..CasePageRows):
                        -1
                    Blank + array{MoreAction}
                else:
                    array{}
            1 =>
                for (I -> Dream : Client.Dreams):
                    100 + I
            2 =>
                Asks := for (I -> Question : DebuggerQuestions):
                    200 + I
                array{-1, -1} + Asks
            _ => array{}

    Render():void =
        if (InTake?):
            RenderTake()
        else:
            RenderTabs()

    RenderTabs():void =
        set View.BodyMessage = EmptyText
        set View.LatestMessage = EmptyText
        SetRow(0, "WONDERWELL DREAM DEBUGGER  v4.1.7")
        SetRow(1, "UNREGISTERED COPY  //  LICENSE CHECK BYPASSED")
        SetRow(2, "PATIENT: {Client.Name}")
        SetRow(3, "")
        for (I -> Name : DebuggerTabNames):
            Mark := if (Cursor = I) then "> " else "  "
            Label := if (Tab = I) then "[{Name}]" else " {Name} "
            SetTab(I, "{Mark}{Label}")
        SetRow(5, "------------------------------------------------------------------------")
        Lines := BodyLines()
        Actions := BodyActions()
        for (Row := DebuggerBodyFirst..DebuggerBodyLast):
            I := Row - DebuggerBodyFirst
            if (Line := Lines[I]):
                Selectable := if (Action := Actions[I], Action >= 0) then true else false
                Mark := if (Action := Actions[I], Action >= 0, Action = Cursor) then "> " else "  "
                SetRow(Row, if (Selectable?) then "{Mark}{Line}" else "  {Line}")
            else:
                SetRow(Row, "")
        SetRow(16, Notice)
        SetRow(17, "MOUSE click  /  SPACE select")

    # The TAKE view: the take's title on row 4, then its menu or the last lines of its scene log,
    # and the vitals on row 16.
    RenderTake():void =
        SetRow(0, "WONDERWELL DREAM DEBUGGER  v4.1.7")
        SetRow(1, "UNREGISTERED COPY  //  LICENSE CHECK BYPASSED")
        SetRow(2, "PATIENT: {Client.Name}")
        SetRow(3, "")
        SetTabMessage(0, TakeTitle(Title))
        SetTab(1, "")
        SetTab(2, "")
        SetRow(5, "------------------------------------------------------------------------")
        BodyRows := DebuggerBodyLast - DebuggerBodyFirst + 1
        if (MenuOptions.Length > 0):
            set View.BodyMessage = EmptyText
            set View.LatestMessage = EmptyText
            SetRowMessage(DebuggerBodyFirst, MenuTitle)
            for (Row := DebuggerBodyFirst + 1..DebuggerBodyLast):
                I := Row - DebuggerBodyFirst - 1
                if (Option := MenuOptions[I]):
                    SetRowMessage(Row, if (Cursor = 300 + I) then TakeCursorOn(Option) else TakeCursorOff(Option))
                else:
                    SetRow(Row, "")
        else:
            # The log is prose. The newest line is big and bright at the bottom (LatestText), so
            # it's always in the same place; a few lines before it sit above it, small and dim
            # (play test, 2026-11-13: lines ran off the top and the current one was hard to find).
            for (Row := DebuggerBodyFirst..DebuggerBodyLast):
                SetRow(Row, "")
            Recent := LastN(TakeLog, TakeLogLines + 1)
            if (Newest := Recent[Recent.Length - 1], Older := Recent.Slice[0, Recent.Length - 1]):
                set View.BodyMessage = Join(Older, OverlayNewLine)
                set View.LatestMessage = Newest
            else:
                set View.BodyMessage = EmptyText
                set View.LatestMessage = EmptyText
        Bars := if (Vitals >= 3) then "#####" else if (Vitals = 2) then "####." else if (Vitals = 1) then "##..." else "#...."
        if (ContinueShown?):
            SetRow(16, "> [ CONTINUE ]")
        else:
            SetRow(16, "VITALS  [{Bars}]")
        SetRow(17, "MOUSE click  /  SPACE select")

    SetRow(Index:int, Text:string):void =
        SetRowMessage(Index, ToMessage(Text))

    SetRowMessage(Index:int, Message:message):void =
        case (Index):
            0 => set View.Row00Text = Message
            1 => set View.Row01Text = Message
            2 => set View.Row02Text = Message
            3 => set View.Row03Text = Message
            5 => set View.Row05Text = Message
            6 => set View.Row06Text = Message
            7 => set View.Row07Text = Message
            8 => set View.Row08Text = Message
            9 => set View.Row09Text = Message
            10 => set View.Row10Text = Message
            11 => set View.Row11Text = Message
            12 => set View.Row12Text = Message
            13 => set View.Row13Text = Message
            14 => set View.Row14Text = Message
            15 => set View.Row15Text = Message
            16 => set View.Row16Text = Message
            17 => set View.Row17Text = Message
            _ => {}

    # Row 4 is three tab labels, a third of the row each.
    SetTab(Index:int, Text:string):void =
        SetTabMessage(Index, ToMessage(Text))

    SetTabMessage(Index:int, Message:message):void =
        case (Index):
            0 => set View.Tab0Text = Message
            1 => set View.Tab1Text = Message
            2 => set View.Tab2Text = Message
            _ => {}

    # ---- The take (debug_screen, driven by take_flow) ----

    # Switches to the TAKE view; the take flow fills it.
    BeginTake():void =
        set InTake = true
        set TakeLog = array{}
        set MenuOptions = array{}
        set Vitals = 0
        set Notice = ""
        RebuildHotspots()
        Render()

    # Back to the tabs once the client's run is over.
    EndTake():void =
        set InTake = false
        SetClickable(true)
        OpenTab(1)

    # A line on row 16 of the tabs view, such as a locked layer.
    ShowNotice(Text:string):void =
        set Notice = Text
        Render()

    SetTitle<override>(InTitle:message):void =
        set Title = InTitle
        Render()

    ClearLog<override>():void =
        set TakeLog = array{}
        Render()

    SetCaseFile<override>(Entries:[]message):void =
        set TakeLog = Entries
        Render()

    AppendLogLine<override>(Line:message):void =
        set TakeLog = LastN(TakeLog + array{Line}, 40)
        if (MenuOptions.Length > 0):
            set MenuOptions = array{}
            RebuildHotspots()
        Render()

    SetMenu<override>(InTitle:message, Options:[]message, Highlighted:int):void =
        SetClickable(true)
        set MenuTitle = InTitle
        set MenuOptions = Options
        set Cursor = 300 + Highlighted
        RebuildHotspots()
        Render()

    ShowSlate<override>(TakeNumber:int)<suspends>:void =
        set MenuOptions = array{}
        RebuildHotspots()
        # The take: the player talks now, so the keyboard goes back to Fortnite.
        SetClickable(false)
        SetTitle(OverlaySlate(TakeNumber))
        Sleep(1.5)

    SetVitals<override>(Level:int):void =
        set Vitals = Level
        Render()

    SetClientState<override>(TakeNumber:int, Feeling:client_state):void =
        Logger.Print("[screen] STATE take={TakeNumber} trust={Feeling.Trust} fear={Feeling.Fear} hope={Feeling.Hope}")

    # Picks come from clicks (AwaitPick); this screen has no separate next/confirm.
    AwaitNext<override>()<suspends>:void =
        Sleep(Inf)

    AwaitConfirm<override>()<suspends>:void =
        Sleep(Inf)

    AwaitPick<override>()<suspends>:int =
        PickEvent.Await()

    # CONTINUE on row 16, under the log: a click, or Space on the focused prompt.
    AwaitContinue<override>()<suspends>:void =
        SetClickable(true)
        set ContinueShown = true
        RebuildHotspots()
        Render()
        ContinueEvent.Await()
        set ContinueShown = false
        RebuildHotspots()
        Render()
