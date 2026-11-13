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
#  - the input: invisible Verse UI buttons over the selectable rows, so the mouse clicks them and
#    the arrow keys or D-pad move focus between them. Hovering or focusing one moves the ">"
#    cursor in the text.
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

# One invisible button over a row (or part of a row). Action: 0..2 tabs, 100+ dreams,
# 200+ questions.
debugger_hotspot := class:
    Row:int
    Action:int
    Owner:dream_debugger_ui
    Button:button = button{Slot := button_slot{Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0}}}

    OnHighlight(Message:widget_message):void = Owner.MoveCursor(Action)
    OnClick(Message:widget_message):void = Owner.Activate(Action)

dream_debugger_ui := class:
    Client:client

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
            Logger.Print("[ui] invoke dream {Action - 100} (not wired yet)")
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
            # The tabs share row 4, a third of the row each.
            for (I -> Name : DebuggerTabNames):
                AddHotspot(Root, 4, I, (1.0 * I) / 3.0, (1.0 * (I + 1)) / 3.0)
            for (I -> Action : BodyActions()):
                if (Action >= 0):
                    AddHotspot(Root, DebuggerBodyFirst + I, Action, 0.0, 1.0)
            if (First := Hotspots[Tab], PlayerUI := MaybePlayerUI?):
                PlayerUI.SetFocus(First.Button)

    AddHotspot(Root:canvas, Row:int, Action:int, X0:float, X1:float):void =
        Hotspot := debugger_hotspot{Row := Row, Action := Action, Owner := Self}
        Hotspot.Button.HighlightEvent().Subscribe(Hotspot.OnHighlight)
        Hotspot.Button.OnClick().Subscribe(Hotspot.OnClick)
        Y0 := (1.0 * Row) / (1.0 * DebuggerRowCount)
        Y1 := (1.0 * (Row + 1)) / (1.0 * DebuggerRowCount)
        Root.AddWidget(canvas_slot{Anchors := AreaAnchors(X0, Y0, X1, Y1), Offsets := margin{}, Widget := Hotspot.Button})
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
        SetRow(16, "")
        SetRow(17, "ARROWS move  /  ENTER select  /  MOUSE click")

    SetRow(Index:int, Text:string):void =
        Message := ToMessage(Text)
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
        Message := ToMessage(Text)
        case (Index):
            0 => set View.Tab0Text = Message
            1 => set View.Tab1Text = Message
            2 => set View.Tab2Text = Message
            _ => {}
