using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# The pre-roll and the cold open (docs/implementation-plan.md, section 2). game_director runs
# RunPreRoll, RunColdOpen and RunBoot in order, each raced against the dev skip, and calls the
# matching End* function afterwards either way, so a skipped phase still leaves the cameras
# and sounds right.
#
# The pre-roll is a solid black full screen with "PRESS ANY KEY TO START" (Chip, 2026-11-13).
# The cinematic is one Level Sequence (camera path, narration, jingle and rain on its own
# tracks); it fades in from black, so the black screen lifts under it without a seam. It ends
# on the desk view, where the monitor boots.

# Authored placeholder text; the writing stream's versions replace it.
PressAnyKeyText<localizes>:message = "PRESS ANY KEY TO START"
DeadAirTitle<localizes>:message = "DEAD AIR"
BootLines:[]string = array:
    "BOOT dbg_link / BUILD unlicensed"
    "IMPLANT bus=found / MODEL budget"
    "SESSION fault=persistent"
    "DEBUG link=open / READY"

# Device references the cold open uses, set on game_director in the editor.
cold_open_rig := class:
    MonitorCamera:gameplay_camera_fixed_point_device    # tight on the monitor: the pre-roll
    DeskCamera:gameplay_camera_fixed_point_device       # the seated desk view the game plays from
    Sequence:cinematic_sequence_device                  # the cold-open Level Sequence
    NoSignalSound:audio_player_device                   # AMB_No_Signal, looping
    RoomRain:audio_player_device                        # AMB_Rain_Window, looping
    BootChime:audio_player_device                       # SFX_Boot_Chime
    TutorialLine:audio_player_device                    # VO_Director_Tutorial_01

cold_open := class:
    Rig:cold_open_rig
    Input:input_router
    Screen:debug_screen

    Logger:log = log{Channel := dead_air_log}

    # Safety net in case the sequence never signals StoppedEvent.
    SequenceTimeoutSeconds:float = 60.0
    # VO_Director_Tutorial_01.wav is 5.36 s; audio_player_device has no finished event.
    TutorialSeconds:float = 5.6

    var OnDesk:logic = false
    var MaybeBlackScreen:?canvas = false

    # ---- Pre-roll ----

    # Solid black with "PRESS ANY KEY TO START"; any key the input router hears starts the game.
    # Voice mode stays at its default (mic); the preset-lines choice needs a new home.
    RunPreRoll(Player:player)<suspends>:void =
        Rig.MonitorCamera.AddTo(Player)    # a fixed view under the black, so nothing shows when it lifts
        ShowBlackScreen(Player)
        Rig.NoSignalSound.Play()
        Input.AnyKeyEvent.Await()
        Logger.Print("[cold_open] pre-roll done")

    EndPreRoll():void =
        Rig.NoSignalSound.Stop()

    ShowBlackScreen(Player:player):void =
        if (not MaybeBlackScreen?, PlayerUI := GetPlayerUI[Player]):
            Prompt := text_block:
                DefaultText := PressAnyKeyText
                DefaultTextColor := NamedColors.White
                DefaultJustification := text_justification.Center
            Black := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                        Offsets := margin{}
                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 1.0}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := Prompt
            # InputMode None: the overlay takes no input, so the keys still reach the input router.
            PlayerUI.AddWidget(Black, player_ui_slot{ZOrder := 1000, InputMode := ui_input_mode.None})
            set MaybeBlackScreen = option{Black}

    HideBlackScreen(Player:player):void =
        if (Black := MaybeBlackScreen?, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(Black)
        set MaybeBlackScreen = false

    # ---- Cinematic ----

    RunColdOpen(Player:player)<suspends>:void =
        Rig.Sequence.Play(Player)
        # Swap to the desk camera underneath the sequence's camera, one tick in, so the pre-roll
        # view never shows between the two and the sequence's last frame hands straight over.
        # The sequence opens on its own fade from black, so the black screen lifts under it.
        Sleep(0.0)
        GoToDesk(Player)
        HideBlackScreen(Player)
        race:
            Rig.Sequence.StoppedEvent.Await()
            block:
                Sleep(SequenceTimeoutSeconds)
                Logger.Print("[cold_open] sequence never stopped; moving on", ?Level := log_level.Warning)
        Logger.Print("[cold_open] sequence done")

    EndColdOpen(Player:player):void =
        Rig.Sequence.GoToEndAndStop(Player)
        GoToDesk(Player)
        HideBlackScreen(Player)
        Rig.RoomRain.Play()

    GoToDesk(Player:player):void =
        if (not OnDesk?):
            set OnDesk = true
            Rig.DeskCamera.AddTo(Player)
            Rig.MonitorCamera.RemoveFrom(Player)

    # ---- Boot ----

    RunBoot()<suspends>:void =
        Rig.BootChime.Play()
        Sleep(0.6)
        Screen.SetTitle(DeadAirTitle)
        for (Line : BootLines):
            Screen.AppendLogLine(ToMessage(Line))
            Sleep(0.35)
        Rig.TutorialLine.Play()
        Sleep(TutorialSeconds)

    EndBoot():void =
        Screen.SetTitle(DeadAirTitle)

    # For debug starts after the cold open: put the player at the desk as if it had played.
    SkipToDesk(Player:player):void =
        HideBlackScreen(Player)
        GoToDesk(Player)
        Rig.RoomRain.Play()
        Screen.SetTitle(DeadAirTitle)
