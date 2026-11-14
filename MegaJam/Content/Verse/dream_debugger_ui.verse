using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# The interactive dream debugger (Chip, 2026-11-13): Wonderwell's dream debugger, a cracked
# unregistered copy, naming the patient. The take flow drives it: a file to learn with one button
# under it (the patient's case file and ATTACH TO DREAMER, then the player's role and ENTER
# DREAM), the scene log with CONTINUE, and the take's menus.
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
# Shown with input mode All, so while it's up it has the mouse and focus.

DebuggerRowCount:int = 18
DebuggerColumns:int = 72      # wrap width in characters (NotoSans 28 px on the 1300 px page)
DebuggerBodyFirst:int = 6     # rows 6..15 are the body
DebuggerBodyLast:int = 15

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

# One invisible button over a row. Action: MoreAction (next page of a file), 300+ take menu
# options, ContinueAction, FileAction (the file's button).
ContinueAction:int = 400
FileAction:int = 500
# CONTINUE sits right under the newest log line, inside LatestText (Chip, 2026-11-13: it was down
# on row 16, far from what the client said).
ContinuePrompt<localizes>:message = "\n\n> [ CONTINUE ]"

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

    # The file view's button was pressed (ATTACH TO DREAMER, ENTER DREAM).
    FileEvent:event() = event(){}
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
    var Cursor:int = 0
    var Page:int = 0

    # The take view: rows 6..15 are the take flow's scene log or its menu.
    var Title:message = EmptyText
    var TakeLog:[]message = array{}
    var MenuTitle:message = EmptyText
    var MenuOptions:[]message = array{}
    var Vitals:int = 0
    # True while the take flow waits on CONTINUE; it shows under the newest log line.
    var ContinueShown:logic = false
    # The file view (ShowFile): rows to read, paged, and one button under them.
    var FileShown:logic = false
    var FileRows:[]message = array{}
    var FileButton:string = ""
    # Input mode All while there's something to click; None while the player talks, so Fortnite
    # gets the keyboard (and the talk key) back.
    var Clickable:logic = true
    # The player's active input, for the controls hint on row 17 (WatchInputKind keeps it current).
    var Kind:input_kind = input_kind.KeyboardInput

    ControlsHint():string =
        case (Kind):
            input_kind.GamepadInput => "D-PAD move  /  A select"
            input_kind.TouchInput => "TAP select"
            input_kind.KeyboardInput => "MOUSE click  /  SPACE select"

    # Re-renders the hint when the player switches between keyboard and gamepad. Runs for good.
    WatchInputKind(Player:player)<suspends>:void =
        loop:
            Now := ActiveInputKind(Player)
            if (Now <> Kind):
                set Kind = Now
                Render()
            Sleep(InputKindPollSeconds)

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
            set Kind = ActiveInputKind(Player)
            spawn{WatchInputKind(Player)}
            BeginTake()
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
            # Next page of the file, wrapping round.
            set Page = if (Page + 1 < FilePageCount()) then Page + 1 else 0
            Render()
        else if (Action = FileAction):
            FileEvent.Signal()
        else if (Action = ContinueAction):
            ContinueEvent.Signal()
        else if (Action >= 300):
            PickEvent.Signal(Action - 300)

    # ---- Buttons ----

    RebuildHotspots():void =
        if (Root := MaybeRoot?):
            for (Old : Hotspots):
                Root.RemoveWidget(Old.Button)
            set Hotspots = array{}
            if (FileShown?):
                # The button first, so it has the focus and Space presses it.
                AddHotspot(Root, 16, FileAction, 0.0, 1.0)
                if (FilePageCount() > 1):
                    AddHotspot(Root, 15, MoreAction, 0.0, 1.0)
            else:
                # Only the menu's options, from row 7 (row 6 is the menu's title).
                for (I -> Option : MenuOptions, DebuggerBodyFirst + 1 + I <= DebuggerBodyLast):
                    AddHotspot(Root, DebuggerBodyFirst + 1 + I, 300 + I, 0.0, 1.0)
                if (ContinueShown?):
                    for (Row := DebuggerBodyFirst..16):
                        AddHotspot(Root, Row, ContinueAction, 0.0, 1.0)
            if (First := Hotspots[0], PlayerUI := MaybePlayerUI?):
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


    # ---- The file view ----

    # Rows 6..14 show the file; row 15 is "[ MORE ]" when it runs to more pages; row 16 is
    # the button.
    FilePageRows:int = 9
    MoreAction:int = 50

    FilePageCount()<transacts>:int =
        if (Pages := Quotient[FileRows.Length + FilePageRows - 1, FilePageRows], Pages > 0) then Pages else 1

    Render():void =
        if (FileShown?):
            RenderFile()
        else:
            RenderTake()

    Header():void =
        SetRow(0, "")    # row 0 is the title bar image (TitleBarImage in UW_DebuggerText)
        SetRow(1, "")    # the [UNREGISTERED] tag is in the title bar image
        SetRow(2, "PATIENT: {Client.Name}")
        SetRow(3, "")
        SetTabMessage(0, TakeTitle(Title))
        SetTab(1, "")
        SetTab(2, "")
        SetRow(5, "------------------------------------------------------------------------")
        SetRow(17, ControlsHint())

    RenderFile():void =
        Header()
        set View.BodyMessage = EmptyText
        set View.LatestMessage = EmptyText
        Start := Page * FilePageRows
        for (Row := DebuggerBodyFirst..DebuggerBodyFirst + FilePageRows - 1):
            if (Line := FileRows[Start + Row - DebuggerBodyFirst]):
                SetRowMessage(Row, Line)
            else:
                SetRow(Row, "")
        Mark := if (Cursor = MoreAction) then "> " else "  "
        SetRow(15, if (FilePageCount() > 1) then "{Mark}[ MORE  {Page + 1}/{FilePageCount()} ]" else "")
        SetRow(16, "> [ {FileButton} ]")

    # The TAKE view: the take's title on row 4, then its menu or the last lines of its scene log,
    # and the vitals on row 16.
    RenderTake():void =
        Header()
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
            # The log is prose, one line at a time: the newest is big and bright at the bottom
            # (LatestText). The player reads at their own pace with CONTINUE, so the older lines
            # aren't shown (play test, 2026-11-13).
            for (Row := DebuggerBodyFirst..DebuggerBodyLast):
                SetRow(Row, "")
            set View.BodyMessage = EmptyText
            Shown := if (Newest := TakeLog[TakeLog.Length - 1]) then Newest else EmptyText
            set View.LatestMessage = if (ContinueShown?) then Join(array{Shown, ContinuePrompt}, EmptyText) else Shown
        Bars := if (Vitals >= 3) then "#####" else if (Vitals = 2) then "####." else if (Vitals = 1) then "##..." else "#...."
        SetRow(16, "VITALS  [{Bars}]")

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

    # Clears the view for the take flow, which fills it.
    BeginTake():void =
        set TakeLog = array{}
        set MenuOptions = array{}
        set Vitals = 0
        RebuildHotspots()
        Render()

    # Once the client's run is over: the mouse back, the last screen left up.
    EndTake():void =
        SetClickable(true)

    # A file to learn with one button under it (Chip, 2026-11-13): the case file and ATTACH TO
    # DREAMER, then the player's role and ENTER DREAM. Heading rows first (they can carry model
    # text), then the authored lines, word-wrapped and paged. Returns when the button is pressed.
    ShowFile<override>(InTitle:message, Heading:[]message, Lines:[]string, Button:string)<suspends>:void =
        SetClickable(true)
        set Title = InTitle
        Wrapped := for (Entry : Lines, Line : WrapText(Entry, DebuggerColumns - 4)):
            ToMessage(Line)
        set FileRows = Heading + Wrapped
        set FileButton = Button
        set Page = 0
        set Cursor = FileAction
        set MenuOptions = array{}
        set FileShown = true
        RebuildHotspots()
        Render()
        FileEvent.Await()
        set FileShown = false
        set Page = 0
        RebuildHotspots()
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

    # CONTINUE under the newest log line: a click anywhere on the log, or Space.
    AwaitContinue<override>()<suspends>:void =
        SetClickable(true)
        set ContinueShown = true
        RebuildHotspots()
        Render()
        ContinueEvent.Await()
        set ContinueShown = false
        RebuildHotspots()
        Render()
