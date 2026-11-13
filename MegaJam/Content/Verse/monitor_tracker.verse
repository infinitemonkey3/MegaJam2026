using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# TRACKING TEST (Chip, 2026-11-13): can a screen-space widget stay locked to the monitor?
# Every tick, projects Room_Monitor's four corners (monitor_projection.verse) and moves a
# half-transparent magenta box over them; logs the numbers once a second ("[track]"). If it
# holds through the room-intro drift and at rest, the whole monitor and the dream debugger
# become screen-space UI on this. Remove once that's built.

monitor_tracker := class:
    Logger:log = log{Channel := dead_air_log}

    # Room_Monitor: 80 cm plane at (-235, -243, 115), facing the camera (yaw -90).
    Panel:world_panel = world_panel:
        CentreX := -235.0
        CentreY := -243.0
        CentreZ := 115.0
        HalfWidth := 40.0
        HalfHeight := 40.0
        AxisX := 0.0
        AxisY := 1.0

    Run(Player:player)<suspends>:void =
        if (PlayerUI := GetPlayerUI[Player]):
            Box := color_block{DefaultColor := NamedColors.Magenta, DefaultOpacity := 0.5}
            Root := canvas{}
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 900, InputMode := ui_input_mode.None})
            Logger.Print("[track] started")
            Eye := Panel.ReportedEye(Player)
            if (X := Eye[0], Y := Eye[1], Z := Eye[2]):
                Logger.Print("[track] deproject eye = {X}, {Y}, {Z} (desk camera is -140, -287, 134)")
            var Tick:int = 0
            loop:
                if (Rect := Panel.ProjectRect[Player]):
                    # Anchors as screen fractions, zero offsets: the box stretches to them.
                    Slot := canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := Rect.Left, Y := Rect.Top}, Maximum := vector2{X := Rect.Left + Rect.Width, Y := Rect.Top + Rect.Height}}
                        Offsets := margin{}
                        Widget := Box
                    Root.RemoveWidget(Box)
                    Root.AddWidget(Slot)
                    if (Mod[Tick, 30] = 0):
                        Logger.Print("[track] left={Rect.Left} top={Rect.Top} w={Rect.Width} h={Rect.Height}")
                else if (Mod[Tick, 30] = 0):
                    Logger.Print("[track] projection failed", ?Level := log_level.Warning)
                set Tick += 1
                Sleep(0.0)
