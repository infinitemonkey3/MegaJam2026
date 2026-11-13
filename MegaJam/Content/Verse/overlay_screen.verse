using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# The debug screen as a full-screen Verse UI overlay: solid black with a title, the log and the
# menu as text. It's the start screen ("PRESS ANY KEY TO START") and, until the 2D room exists,
# the stand-in for the room (Chip, 2026-11-13: show black, not the 3D world). Show() puts it
# up for the player; Hide() takes it down, for the cold-open sequence. Text set while it's
# hidden is kept and shown next time.

OverlayNewLine<localizes>:message = "\n"
OverlayMenuGap<localizes>:message = "    "
OverlayPicked<localizes>(Option:message):message = "> {Option}"
OverlayUnpicked<localizes>(Option:message):message = "  {Option}"
OverlaySlate<localizes>(TakeNumber:int):message = "TAKE {TakeNumber}"

overlay_screen := class(debug_screen):
    Input:input_router

    Logger:log = log{Channel := dead_air_log}
    MaxLogLines:int = 10

    var Title:message = EmptyText
    var Lines:[]message = array{}
    var Menu:message = EmptyText

    var MaybeRoot:?canvas = false
    var MaybePlayerUI:?player_ui = false
    var MaybeTitleText:?text_block = false
    var MaybeBodyText:?text_block = false
    var MaybeMenuText:?text_block = false

    # ---- Showing ----

    Show(Player:player):void =
        if (not MaybeRoot?, PlayerUI := GetPlayerUI[Player]):
            TitleText := text_block{DefaultTextColor := NamedColors.White, DefaultTextSize := 48.0, DefaultJustification := text_justification.Center}
            BodyText := text_block{DefaultTextColor := NamedColors.White, DefaultTextSize := 20.0, DefaultJustification := text_justification.Center}
            MenuText := text_block{DefaultTextColor := NamedColors.White, DefaultTextSize := 22.0, DefaultJustification := text_justification.Center}
            Column := stack_box:
                Orientation := orientation.Vertical
                Slots := array:
                    stack_box_slot{Widget := TitleText, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 24.0}}
                    stack_box_slot{Widget := BodyText, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 24.0}}
                    stack_box_slot{Widget := MenuText, HorizontalAlignment := horizontal_alignment.Center}
            Root := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                        Offsets := margin{}
                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 1.0}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := Column
            # InputMode None: the overlay takes no input, so the keys still reach the input router.
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 1000, InputMode := ui_input_mode.None})
            set MaybeRoot = option{Root}
            set MaybePlayerUI = option{PlayerUI}
            set MaybeTitleText = option{TitleText}
            set MaybeBodyText = option{BodyText}
            set MaybeMenuText = option{MenuText}
            Refresh()

    Hide():void =
        if (Root := MaybeRoot?, PlayerUI := MaybePlayerUI?):
            PlayerUI.RemoveWidget(Root)
        set MaybeRoot = false
        set MaybeTitleText = false
        set MaybeBodyText = false
        set MaybeMenuText = false

    Refresh():void =
        if (TitleText := MaybeTitleText?):
            TitleText.SetText(Title)
        if (BodyText := MaybeBodyText?):
            BodyText.SetText(Join(Lines, OverlayNewLine))
        if (MenuText := MaybeMenuText?):
            MenuText.SetText(Menu)

    # ---- debug_screen ----

    SetTitle<override>(InTitle:message):void =
        set Title = InTitle
        Refresh()

    ClearLog<override>():void =
        set Lines = array{}
        Refresh()

    AppendLogLine<override>(Line:message):void =
        set Lines = LastN(Lines + array{Line}, MaxLogLines)
        Refresh()

    SetCaseFile<override>(Entries:[]message):void =
        set Lines = Entries
        Refresh()

    SetMenu<override>(MenuTitle:message, Options:[]message, Highlighted:int):void =
        if (Options.Length = 0):
            set Menu = MenuTitle
        else:
            Items := for (Index -> Option : Options):
                if (Index = Highlighted) then OverlayPicked(Option) else OverlayUnpicked(Option)
            set Menu = Join(array{MenuTitle} + Items, OverlayMenuGap)
        Refresh()

    ShowSlate<override>(TakeNumber:int)<suspends>:void =
        SetTitle(OverlaySlate(TakeNumber))
        Sleep(1.5)

    # No vitals or chart on the overlay yet: log only.
    SetVitals<override>(Level:int):void =
        Logger.Print("[screen] VITALS level={Level}", ?Level := log_level.Verbose)

    SetClientState<override>(TakeNumber:int, Feeling:client_state):void =
        Logger.Print("[screen] STATE take={TakeNumber} trust={Feeling.Trust} fear={Feeling.Fear} hope={Feeling.Hope}")

    AwaitNext<override>()<suspends>:void =
        Input.NextEvent.Await()

    AwaitConfirm<override>()<suspends>:void =
        Input.ConfirmEvent.Await()
