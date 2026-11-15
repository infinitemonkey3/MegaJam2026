using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }

# The interactive dream debugger (Chip, 2026-11-13): Wonderwell's dream debugger, a cracked
# unregistered copy, naming the patient. The take flow drives it: a file to learn with one button
# under it (the patient's case file and ATTACH TO DREAMER, then the player's role and ENTER
# DREAM), the scene log with CONTINUE or the "your turn to speak" cue, and the take's menus.
#
# Design B, "boxed terminal" (Chip picked it, 2026-11-14; art/debugger_designs/README.md):
#  - the look: UW_DebuggerB (Content/DreamDebugger), a UMG widget on a 1200 x 908 page in a
#    Scale Box. A sidebar (PATIENT, SESSION with the vitals), a main panel whose Widget Switcher
#    shows the file, the log or a menu, and Lumi's dock along the bottom. The chrome is baked
#    into textures by art/tools/make_debugger_b.py, which also writes the layout (layout.json)
#    that the rectangles below copy; build_debugger_b.py and bind_debugger_b.sh build the widget.
#    Verse sets it through its fields: messages for text, floats for on/off states (each drives
#    a widget's RenderOpacity), and PageIndex for the page. UMG, because Verse UI can't set a font.
#  - the input: invisible Verse UI buttons over the clickable rectangles. Hovering one focuses
#    it, which shows that button's focused state; a mouse click or Space (Jump) selects it.
#    Arrow keys and Enter don't work in Fortnite's UI.
# The dark fill behind is the world's glass and in-world screen, which get the camera's
# perspective (a flat UI fill didn't match).
#
# Shown with input mode All, so while it's up it has the mouse and focus.

# The page, in page pixels (art/debugger_b/layout.json).
DebuggerPageWidth:float = 1310.0     # with the height, about 1.34 : 1, near the glass hole on screen
DebuggerPageHeight:float = 980.0

debugger_rect := struct<computes>:
    X0:float
    Y0:float
    X1:float
    Y1:float

DebuggerMoreRect:debugger_rect = debugger_rect{X0 := 388.0, Y0 := 764.0, X1 := 618.0, Y1 := 818.0}
DebuggerFileButtonRect:debugger_rect = debugger_rect{X0 := 648.0, Y0 := 764.0, X1 := 1246.0, Y1 := 818.0}
# CONTINUE takes a click anywhere on the main panel ("or click the log").
DebuggerMainPanelRect:debugger_rect = debugger_rect{X0 := 368.0, Y0 := 149.0, X1 := 1266.0, Y1 := 842.0}
# Lumi's sun avatar: a square centred in the main panel (x 368..1266, y 149..842), which the
# log clears for.
LumiAvatarRect:debugger_rect = debugger_rect{X0 := 627.0, Y0 := 305.0, X1 := 1007.0, Y1 := 685.0}

# Lumi's avatar frames (art/tools/make_lumi_sun.py): 0 the smile, 1 half open, 2 open.
LumiSunFrame(Frame:int)<transacts>:texture =
    if (Frame = 1) then Room.Textures.T_Lumi_Sun_1
    else if (Frame = 2) then Room.Textures.T_Lumi_Sun_2
    else Room.Textures.T_Lumi_Sun_0

DebuggerMenuCount:int = 5
DebuggerMenuRect(Index:int):debugger_rect =
    Top := 245.0 + 80.0 * Index
    debugger_rect{X0 := 388.0, Y0 := Top, X1 := 1246.0, Y1 := Top + 60.0}

# The file's paging: up to four entries a page, as many as fit the panel. Line counts are
# guessed from the length (NotoSans 19 pt on the 854 px column fits about 70 characters, play test 2026-11-14; 64 to be safe, lines about 35 px).
DebuggerFileHeight:float = 573.0
DebuggerEntriesPerPage:int = 4
DebuggerCharsPerLine:int = 64

# One entry of a file: an amber tag ("WALT") and its text.
file_entry := struct:
    Tag:message
    Text:message
    Lines:int

file_entry_text := struct:
    Tag:string
    Text:string

# "-- PERSONALITY --" is a section: its name, without the dashes.
SectionName(Line:string)<transacts><decides>:string =
    Line.Length > 6
    Line.Slice[0, 3] = "-- "
    Line.Slice[Line.Length - 3] = " --"
    Line.Slice[3, Line.Length - 3]

# Splits Text at the first Sep, if it has one.
SplitOnce(Text:string, Sep:string)<transacts>:?tuple(string, string) =
    var Result:?tuple(string, string) = false
    var I:int = 0
    loop:
        if (Result? or I + Sep.Length > Text.Length):
            break
        if (Text.Slice[I, I + Sep.Length] = Sep, Before := Text.Slice[0, I], After := Text.Slice[I + Sep.Length]):
            set Result = option{(Before, After)}
        set I += 1
    Result

# A file's lines as tagged entries. "WALT  Her husband..." splits at the first double space
# (nell_data writes them that way); a section line ("-- LIKES --") starts an entry that the plain
# lines after it join, one per line; any other plain line is an entry with no tag.
ParseFileLines(Lines:[]string)<transacts>:[]file_entry_text =
    var Out:[]file_entry_text = array{}
    var InSection:logic = false
    for (Line : Lines):
        if (Section := SectionName[Line]):
            set Out += array{file_entry_text{Tag := Section, Text := ""}}
            set InSection = true
        else if (Parts := SplitOnce(Line, "  ")?):
            set Out += array{file_entry_text{Tag := Parts(0), Text := Parts(1)}}
            set InSection = false
        else if (InSection?, Last := Out[Out.Length - 1]):
            Joined := if (Last.Text.Length > 0) then Last.Text + "\n" + Line else Line
            if (set Out[Out.Length - 1] = file_entry_text{Tag := Last.Tag, Text := Joined}) {}
        else:
            set Out += array{file_entry_text{Tag := "", Text := Line}}
    Out

# A dream's title for the sidebar, which already shows the layer: "LAYER 3  Pick Up 5 PM  /
# bakery_interior 16:30, March 3" is "Pick Up 5 PM" (play test, 2026-11-14: the whole title ran
# out of the sidebar).
ShortTitle(Title:string)<transacts>:string =
    AfterLayer := if (Parts := SplitOnce(Title, "  ")?) then Parts(1) else Title
    if (Parts := SplitOnce(AfterLayer, "  /  ")?) then Parts(0) else AfterLayer

# About how many lines Text wraps to on the file page.
EstimateLines(Text:string)<transacts>:int =
    var Lines:int = 0
    var Run:int = 0
    for (C : Text + "\n"):
        if (C = '\n'):
            set Lines += (if (Q := Quotient[Run + DebuggerCharsPerLine - 1, DebuggerCharsPerLine], Q > 0) then Q else 1)
            set Run = 0
        else:
            set Run += 1
    Lines

NewLineText<localizes>:message = "\n"
SceneLogTitle<localizes>:message = "SCENE LOG"
SpeakAskText<localizes>:message = "What do you have to say?"

# One invisible button over a rectangle. Action: MoreAction (next page of a file), 300+ take
# menu options, ContinueAction, FileAction (the file's button).
ContinueAction:int = 400
FileAction:int = 500

# Something in the room the player can click while the debugger waits on them (room-lines.md,
# Chip 2026-11-15): faint teal viewfinder corners over it (T_RoomTargetCorners), bright with its
# name under it on hover, dim once seen. A click signals RoomTargetEvent with its id, a director
# line. Shown only while the debugger is clickable, never during a take.
room_target := class:
    Id:string
    Label:string
    Rect:monitor_rect           # screen fractions, from a world_panel's ProjectRect
    Owner:dream_debugger_ui
    var Seen:logic = false
    var MaybeButton:?button = false
    var MaybeCorners:?texture_block = false
    var MaybeLabel:?text_block = false

    RestTint():color =
        if (Seen?) then color{R := 0.03, G := 0.12, B := 0.11} else color{R := 0.06, G := 0.42, B := 0.38}

    OnHighlight(Message:widget_message):void =
        if (Corners := MaybeCorners?):
            Corners.SetTint(color{R := 0.3, G := 1.0, B := 0.92})
            Corners.SetVisibility(widget_visibility.Visible)
        if (Text := MaybeLabel?):
            Text.SetVisibility(widget_visibility.Visible)
        if (Button := MaybeButton?):
            Owner.FocusButton(Button)

    # The corners show only on hover (Chip, 2026-11-15: not always on the poster). Hidden, not
    # Collapsed, so the button keeps its size and still catches the mouse.
    OnUnhighlight(Message:widget_message):void =
        if (Corners := MaybeCorners?):
            Corners.SetTint(RestTint())
            Corners.SetVisibility(widget_visibility.Hidden)
        if (Text := MaybeLabel?):
            Text.SetVisibility(widget_visibility.Hidden)

    OnClick(Message:widget_message):void =
        set Seen = true
        Owner.RoomTargetEvent.Signal(Id)

debugger_hotspot := class:
    Action:int
    Owner:dream_debugger_ui
    Button:button

    # A click goes to the focused button, not the one under the mouse, and hovering doesn't move
    # focus on its own (play test, 2026-11-13), so hovering a button focuses it.
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
    # A room target was clicked: its id (game_director plays the director's line for it).
    RoomTargetEvent:event(string) = event(string){}
    var RoomTargets:[]room_target = array{}

    Logger:log = log{Channel := dead_air_log}

    # The glass hole in the monitor texture (2048 px): x 249..1800, y 282..1478, with a margin so
    # the page clears the rounded corners. The page keeps its shape (about 1.45 : 1, the glass's).
    HoleLeft:float = 265.0 / 2048.0
    HoleTop:float = 295.0 / 2048.0
    HoleRight:float = 1785.0 / 2048.0
    HoleBottom:float = 1465.0 / 2048.0

    View:DreamDebugger.UW_DebuggerB = DreamDebugger.UW_DebuggerB{}

    var MaybePlayerUI:?player_ui = false
    var MaybeRoot:?canvas = false
    var Area:monitor_rect = monitor_rect{Left := 0.0, Top := 0.0, Width := 0.0, Height := 0.0}
    var Hotspots:[]debugger_hotspot = array{}
    var Cursor:int = 0
    var Page:int = 0

    # The session: the dream being worked on (SetDream) and the take (ShowSlate).
    var DreamNumber:int = 0
    var DreamId:string = ""
    var DreamTitle:string = ""
    var TakeNumber:int = 0
    # The take view: the scene log or a menu.
    var Title:message = EmptyText
    var TakeLog:[]message = array{}
    var MenuTitle:message = EmptyText
    var MenuOptions:[]message = array{}
    var Vitals:int = 0
    # True while the take flow waits on CONTINUE.
    var ContinueShown:logic = false
    # True while the take waits for the player to talk (ShowSpeakCue), and the question asked.
    var SpeakShown:logic = false
    var SpeakAsk:string = ""
    # The take's round counter (SetRound), shown in the log's badge in place of TAKE n.
    var RoundCurrent:int = 0
    var RoundTotal:int = 0
    # The file view (ShowFile): entries, paged, and one button under them.
    var FileShown:logic = false
    var FileTitle:message = EmptyText
    var FileEntries:[]file_entry = array{}
    var FilePages:[]int = array{0}       # the first entry of each page
    var FileButton:string = ""
    # Input mode All while there's something to click; None while the player talks, so Fortnite
    # gets the keyboard (and the talk key) back.
    var Clickable:logic = true
    # Lumi, the Wonderwell assistant: disabled until the finale wakes it (SetAssistantAwake).
    var LumiAwake:logic = false
    # Lumi's sun avatar (SetAssistantAvatar), made the first time it's shown.
    var MaybeAvatar:?texture_block = false
    # The player's active input, for the controls hint (WatchInputKind keeps it current).
    var Kind:input_kind = input_kind.KeyboardInput

    ControlsHint():string =
        case (Kind):
            input_kind.GamepadInput => "D-PAD  move     A  select"
            input_kind.TouchInput => "TAP  select"
            input_kind.KeyboardInput => "MOUSE  click     SPACE  select"

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
                ViewAspect := Monitor.ViewAspect
            Root := canvas:
                Slots := array:
                    canvas_slot{Anchors := AreaAnchors(0.0, 0.0, 1.0, 1.0), Offsets := margin{}, Widget := View}
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 800, InputMode := ui_input_mode.All})
            set MaybePlayerUI = option{PlayerUI}
            set MaybeRoot = option{Root}
            set Kind = ActiveInputKind(Player)
            spawn{WatchInputKind(Player)}
            BeginTake()
            Logger.Print("[ui] dream debugger shown: area left={Area.Left} top={Area.Top} width={Area.Width} height={Area.Height} view aspect={Area.ViewAspect}")

    # Re-adds the debugger with input mode All (menus) or None (talking in a take).
    SetClickable(On:logic):void =
        if (On <> Clickable, PlayerUI := MaybePlayerUI?, Root := MaybeRoot?):
            set Clickable = On
            PlayerUI.RemoveWidget(Root)
            Mode := if (On?) then ui_input_mode.All else ui_input_mode.None
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 800, InputMode := Mode})
            if (On?):
                RebuildHotspots()
            else:
                HideRoomTargets()

    # A clickable thing in the room (room_target), shown while the debugger is clickable.
    AddRoomTarget(Id:string, Label:string, Rect:monitor_rect):void =
        set RoomTargets += array{room_target{Id := Id, Label := Label, Rect := Rect, Owner := Self}}
        if (Clickable?):
            RebuildHotspots()

    HideRoomTargets():void =
        if (Root := MaybeRoot?):
            for (Target : RoomTargets):
                if (Button := Target.MaybeButton?):
                    Root.RemoveWidget(Button)
                if (Text := Target.MaybeLabel?):
                    Root.RemoveWidget(Text)
                set Target.MaybeButton = false
                set Target.MaybeLabel = false

    ShowRoomTargets(Root:canvas):void =
        for (Target : RoomTargets):
            # A little room round the object, so the corners frame it rather than sit on it
            # (Chip, 2026-11-15): about 18 px each side at 1080p.
            PadX := 18.0 / 1920.0
            PadY := 18.0 / 1080.0
            R := monitor_rect{Left := Target.Rect.Left - PadX, Top := Target.Rect.Top - PadY, Width := Target.Rect.Width + 2.0 * PadX, Height := Target.Rect.Height + 2.0 * PadY}
            Corners := texture_block:
                DefaultImage := Room.Textures.T_RoomTargetCorners
                DefaultTint := Target.RestTint()
                DefaultDesiredSize := vector2{X := R.Width * 1920.0, Y := R.Height * 1080.0}
            Corners.SetVisibility(widget_visibility.Hidden)
            Button := button{Slot := button_slot{Widget := Corners, HorizontalAlignment := horizontal_alignment.Fill, VerticalAlignment := vertical_alignment.Fill}}
            Button.HighlightEvent().Subscribe(Target.OnHighlight)
            Button.UnhighlightEvent().Subscribe(Target.OnUnhighlight)
            Button.OnClick().Subscribe(Target.OnClick)
            ButtonAnchors := anchors{Minimum := vector2{X := R.Left, Y := R.Top}, Maximum := vector2{X := R.Left + R.Width, Y := R.Top + R.Height}}
            Root.AddWidget(canvas_slot{Anchors := ButtonAnchors, Offsets := margin{}, SizeToContent := false, Widget := Button})
            Label := text_block{DefaultText := ToMessage(Target.Label), DefaultTextColor := color{R := 0.3, G := 1.0, B := 0.92}, DefaultTextSize := 14.0, DefaultJustification := text_justification.Center}
            Label.SetVisibility(widget_visibility.Hidden)
            LabelAnchors := anchors{Minimum := vector2{X := R.Left - 0.05, Y := R.Top + R.Height + 0.005}, Maximum := vector2{X := R.Left + R.Width + 0.05, Y := R.Top + R.Height + 0.035}}
            Root.AddWidget(canvas_slot{Anchors := LabelAnchors, Offsets := margin{}, SizeToContent := false, Widget := Label})
            set Target.MaybeButton = option{Button}
            set Target.MaybeCorners = option{Corners}
            set Target.MaybeLabel = option{Label}

    Hide():void =
        if (PlayerUI := MaybePlayerUI?, Root := MaybeRoot?):
            PlayerUI.RemoveWidget(Root)
        set MaybeRoot = false
        set MaybeAvatar = false

    # Anchors for a part of the area, in fractions of it (0..1).
    AreaAnchors(X0:float, Y0:float, X1:float, Y1:float):anchors =
        anchors:
            Minimum := vector2{X := Area.Left + Area.Width * X0, Y := Area.Top + Area.Height * Y0}
            Maximum := vector2{X := Area.Left + Area.Width * X1, Y := Area.Top + Area.Height * Y1}

    # Anchors for a rectangle on the page. The Scale Box fits the page into the area and keeps
    # its shape, so the page may sit centred with bars either side; this finds where it lands.
    PageAnchors(R:debugger_rect):anchors =
        AreaAspect := (Area.Width * Area.ViewAspect) / Max(0.0001, Area.Height)
        PageAspect := DebuggerPageWidth / DebuggerPageHeight
        FW := if (AreaAspect > PageAspect) then PageAspect / AreaAspect else 1.0
        FH := if (AreaAspect > PageAspect) then 1.0 else AreaAspect / PageAspect
        FX := (1.0 - FW) / 2.0
        FY := (1.0 - FH) / 2.0
        AreaAnchors(
            FX + FW * R.X0 / DebuggerPageWidth, FY + FH * R.Y0 / DebuggerPageHeight,
            FX + FW * R.X1 / DebuggerPageWidth, FY + FH * R.Y1 / DebuggerPageHeight)

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
            set Page = if (Page + 1 < FilePages.Length) then Page + 1 else 0
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
                AddHotspot(Root, DebuggerFileButtonRect, FileAction)
                if (FilePages.Length > 1):
                    AddHotspot(Root, DebuggerMoreRect, MoreAction)
            else:
                for (I -> Option : MenuOptions, I < DebuggerMenuCount):
                    AddHotspot(Root, DebuggerMenuRect(I), 300 + I)
                if (ContinueShown?):
                    AddHotspot(Root, DebuggerMainPanelRect, ContinueAction)
            # The room's targets come after the debugger's, so the debugger's button keeps focus.
            HideRoomTargets()
            if (Clickable?):
                ShowRoomTargets(Root)
            if (First := Hotspots[0], PlayerUI := MaybePlayerUI?):
                PlayerUI.SetFocus(First.Button)

    AddHotspot(Root:canvas, Rect:debugger_rect, Action:int):void =
        # The button takes the size of its content, so the content is the rectangle, in 1080p
        # UI units. Invisible; the widget above ignores the mouse (its root is Not Hit-Testable,
        # Self & All Children), so the buttons get it.
        Anchors := PageAnchors(Rect)
        W := (Anchors.Maximum.X - Anchors.Minimum.X) * 1920.0
        H := (Anchors.Maximum.Y - Anchors.Minimum.Y) * 1080.0
        Fill := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X := W, Y := H}}
        Hotspot := debugger_hotspot:
            Action := Action
            Owner := Self
            Button := button{Slot := button_slot{Widget := Fill, HorizontalAlignment := horizontal_alignment.Fill, VerticalAlignment := vertical_alignment.Fill}}
        Hotspot.Button.HighlightEvent().Subscribe(Hotspot.OnHighlight)
        Hotspot.Button.OnClick().Subscribe(Hotspot.OnClick)
        Root.AddWidget(canvas_slot{Anchors := Anchors, Offsets := margin{}, Alignment := vector2{X := 0.0, Y := 0.0}, SizeToContent := false, Widget := Hotspot.Button})
        set Hotspots += array{Hotspot}

    # ---- Rendering ----

    MoreAction:int = 50

    Opacity(Shown:logic):float = if (Shown?) then 1.0 else 0.0

    Render():void =
        RenderSidebar()
        set View.LumiOpacity = Opacity(LumiAwake)
        set View.FooterFileText = ToMessage(if (DreamId.Length > 0) then "{DreamId}.dream" else "")
        set View.FooterHintText = ToMessage(ControlsHint())
        if (FileShown?):
            RenderFile()
        else if (MenuOptions.Length > 0):
            RenderMenu()
        else:
            RenderLog()

    # PATIENT and SESSION. The patient's name is split at "  AKA ".
    RenderSidebar():void =
        NameParts := SplitOnce(Client.Name, "  AKA ")
        FullName := if (Parts := NameParts?) then Parts(0) else Client.Name
        # "PRICE," over "ELEANOR M." (play test, 2026-11-14: it wrapped as "PRICE, ELEANOR / M.").
        set View.PatientNameText = ToMessage(if (Name := SplitOnce(FullName, ", ")?) then Name(0) + ",\n" + Name(1) else FullName)
        set View.PatientAkaText = ToMessage(if (Parts := NameParts?) then Parts(1) else "")
        set View.PatientInfoText = ToMessage(Client.Tagline)
        # One row, DREAM (Chip, 2026-11-14: a dream is a layer; "layer" sounds like Inception).
        set View.LayerText = ToMessage(if (DreamNumber > 0) then "{DreamNumber}" else "-")
        set View.LayerTitleText = ToMessage(DreamTitle)
        set View.TakeText = ToMessage(if (TakeNumber > 0) then "{TakeNumber}" else "-")
        set View.Vital0Opacity = Opacity(logic{Vitals >= 1})
        set View.Vital1Opacity = Opacity(logic{Vitals >= 2})
        set View.Vital2Opacity = Opacity(logic{Vitals >= 3})

    # The badge on the main panel's top right ("1/3", "TAKE 2"); none while Lumi is awake, whose
    # own badge is in the LumiOn layer.
    SetBadge(Text:string):void =
        set View.MainBadgeText = ToMessage(Text)
        set View.MainBadgeOpacity = Opacity(logic{Text.Length > 0, not LumiAwake?})

    RenderFile():void =
        set View.PageIndex = 0
        set View.MainTitleText = FileTitle
        Pages := FilePages.Length
        SetBadge(if (Pages > 1) then "{Page + 1}/{Pages}" else "")
        Start := if (S := FilePages[Page]) then S else 0
        End := if (E := FilePages[Page + 1]) then E else FileEntries.Length
        for (Slot := 0..DebuggerEntriesPerPage - 1):
            if (Slot < End - Start, Entry := FileEntries[Start + Slot]):
                SetEntry(Slot, Entry.Tag, Entry.Text)
            else:
                SetEntry(Slot, EmptyText, EmptyText)
        set View.MoreOpacity = Opacity(logic{Pages > 1})
        set View.MoreCountText = ToMessage("{Page + 1}/{Pages}")
        set View.MoreFocusOpacity = Opacity(logic{Cursor = MoreAction})
        set View.FileFocusOpacity = Opacity(logic{Cursor <> MoreAction})
        set View.FileButtonLabel = ToMessage(FileButton)

    SetEntry(Slot:int, Tag:message, Text:message):void =
        case (Slot):
            0 =>
                set View.Tag0Text = Tag
                set View.Entry0Text = Text
            1 =>
                set View.Tag1Text = Tag
                set View.Entry1Text = Text
            2 =>
                set View.Tag2Text = Tag
                set View.Entry2Text = Text
            3 =>
                set View.Tag3Text = Tag
                set View.Entry3Text = Text
            _ => {}

    # The scene log: the newest line big, the two before it dim above (more while Lumi spams it).
    RenderLog():void =
        set View.PageIndex = 1
        set View.MainTitleText = SceneLogTitle
        SetBadge(if (RoundTotal > 0) then "ROUND {RoundCurrent} / {RoundTotal}" else if (TakeNumber > 0) then "TAKE {TakeNumber}" else "")
        Older := if (LumiAwake?) then 7 else 2
        Count := TakeLog.Length
        Prev := for (I := Max(0, Count - 1 - Older)..Count - 2, Line := TakeLog[I]) { Line }
        set View.LogPrevText = Join(Prev, NewLineText)
        set View.LogCurrentText = if (Newest := TakeLog[Count - 1]) then Newest else EmptyText
        set View.ContinueOpacity = Opacity(logic{ContinueShown?, not SpeakShown?})
        set View.SpeakOpacity = Opacity(SpeakShown)
        # The round goes beside the question, where the player is looking on their turn (Chip,
        # 2026-11-15: the badge alone went unnoticed).
        RoundSuffix := if (RoundTotal > 0) then "   {RoundCurrent} / {RoundTotal}" else ""
        set View.SpeakAskText = if (SpeakAsk.Length > 0) then ToMessage(SpeakAsk + RoundSuffix) else if (RoundTotal > 0) then ToMessage("What do you have to say?" + RoundSuffix) else SpeakAskText

    RenderMenu():void =
        set View.PageIndex = 2
        set View.MainTitleText = MenuTitle
        SetBadge("")
        set View.MenuIntroText = EmptyText
        for (Index := 0..DebuggerMenuCount - 1):
            if (Option := MenuOptions[Index]):
                SetOption(Index, Option, 1.0, Opacity(logic{Cursor = 300 + Index}))
            else:
                SetOption(Index, EmptyText, 0.0, 0.0)

    SetOption(Index:int, Label:message, Shown:float, Focused:float):void =
        case (Index):
            0 =>
                set View.Option0Label = Label
                set View.Option0Opacity = Shown
                set View.Option0FocusOpacity = Focused
            1 =>
                set View.Option1Label = Label
                set View.Option1Opacity = Shown
                set View.Option1FocusOpacity = Focused
            2 =>
                set View.Option2Label = Label
                set View.Option2Opacity = Shown
                set View.Option2FocusOpacity = Focused
            3 =>
                set View.Option3Label = Label
                set View.Option3Opacity = Shown
                set View.Option3FocusOpacity = Focused
            4 =>
                set View.Option4Label = Label
                set View.Option4Opacity = Shown
                set View.Option4FocusOpacity = Focused
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

    SetDream<override>(Number:int, Id:string, InTitle:string):void =
        set DreamNumber = Number
        set DreamId = Id
        set DreamTitle = ShortTitle(InTitle)
        set TakeNumber = 0
        Render()

    # A file to learn with one button under it (Chip, 2026-11-13): the case file and ATTACH TO
    # DREAMER, then the player's role and ENTER DREAM. Heading entries first (they can carry
    # model text), then the authored lines as tagged entries, paged. Returns when the button is
    # pressed.
    ShowFile<override>(InTitle:message, Heading:[]file_heading, Lines:[]string, Button:string)<suspends>:void =
        SetClickable(true)
        set FileTitle = InTitle
        Authored := for (E : ParseFileLines(Lines)):
            file_entry{Tag := ToMessage(E.Tag), Text := ToMessage(E.Text), Lines := EstimateLines(E.Text)}
        Headed := for (H : Heading):
            file_entry{Tag := ToMessage(H.Tag), Text := H.Text, Lines := 2}
        # The headings (the cake, the Saturday) go last, after who's who (Chip, 2026-11-14: at the
        # top they came out of left field).
        set FileEntries = Authored + Headed
        set FilePages = PageStarts(FileEntries)
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

    # Where each page of the file starts: as many entries as fit, at most four.
    PageStarts(Entries:[]file_entry)<transacts>:[]int =
        var Starts:[]int = array{0}
        var Height:float = 0.0
        var Count:int = 0
        for (I -> Entry : Entries):
            Body := 30.0 + 35.0 * (1.0 * Entry.Lines)
            Gap := if (Count > 0) then 16.0 else 0.0
            if (Count > 0, Count >= DebuggerEntriesPerPage or Height + Gap + Body > DebuggerFileHeight):
                set Starts += array{I}
                set Height = Body
                set Count = 1
            else:
                set Height += Gap + Body
                set Count += 1
        Starts

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

    ShowSlate<override>(InTakeNumber:int)<suspends>:void =
        set MenuOptions = array{}
        RebuildHotspots()
        # The take: the player talks now, so the keyboard goes back to Fortnite.
        SetClickable(false)
        set TakeNumber = InTakeNumber
        SetTitle(OverlaySlate(InTakeNumber))
        Sleep(1.5)

    SetVitals<override>(Level:int):void =
        set Vitals = Level
        Render()

    SetAssistantAwake<override>(Awake:logic):void =
        set LumiAwake = Awake
        Render()

    SetAssistantAvatar<override>(Frame:int):void =
        if (Frame < 0):
            if (Avatar := MaybeAvatar?):
                Avatar.SetVisibility(widget_visibility.Hidden)
        else if (Root := MaybeRoot?):
            Image := LumiSunFrame(Frame)
            if (Avatar := MaybeAvatar?):
                Avatar.SetImage(Image)
                Avatar.SetVisibility(widget_visibility.Visible)
            else:
                Avatar := texture_block{DefaultImage := Image, DefaultDesiredSize := vector2{X := 380.0, Y := 380.0}}
                Root.AddWidget(canvas_slot{Anchors := PageAnchors(LumiAvatarRect), Offsets := margin{}, SizeToContent := false, Widget := Avatar})
                set MaybeAvatar = option{Avatar}

    SetRound<override>(Current:int, Total:int):void =
        set RoundCurrent = Current
        set RoundTotal = Total
        Render()

    ShowSpeakCue<override>(Ask:string):void =
        set SpeakShown = true
        set SpeakAsk = Ask
        Render()

    HideSpeakCue<override>():void =
        set SpeakShown = false
        Render()

    SetClientState<override>(InTakeNumber:int, Feeling:client_state):void =
        Logger.Print("[screen] STATE take={InTakeNumber} trust={Feeling.Trust} fear={Feeling.Fear} hope={Feeling.Hope}")

    # Picks come from clicks (AwaitPick); this screen has no separate next/confirm.
    AwaitNext<override>()<suspends>:void =
        Sleep(Inf)

    AwaitConfirm<override>()<suspends>:void =
        Sleep(Inf)

    AwaitPick<override>()<suspends>:int =
        PickEvent.Await()

    # CONTINUE under the newest log line: a click anywhere on the main panel, or Space.
    AwaitContinue<override>()<suspends>:void =
        SetClickable(true)
        set ContinueShown = true
        RebuildHotspots()
        Render()
        ContinueEvent.Await()
        set ContinueShown = false
        RebuildHotspots()
        Render()
