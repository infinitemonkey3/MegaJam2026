using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The pre-roll and the cold open (docs/implementation-plan.md, section 2). game_director runs
# RunPreRoll, RunColdOpen and RunBoot in order, each raced against the dev skip, and calls the
# matching End* function afterwards either way, so a skipped phase still leaves the cameras,
# the overlay and the sounds right.
#
# Everything outside the Level Sequence is the full-screen overlay (overlay_screen):
#  - pre-roll: black with "PRESS ANY KEY TO START" (Chip, 2026-11-13)
#  - cold open: the overlay comes down under the sequence's own fade from black
#  - after it: the sequence ends on black and the overlay goes back up as the stand-in for the
#    room, where DEAD AIR boots. The 3D world is never shown outside the sequence.

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
    MonitorCamera:gameplay_camera_fixed_point_device    # a fixed view under the start screen
    DeskCamera:gameplay_camera_fixed_point_device       # the seated desk view the game plays from
    Sequence:cinematic_sequence_device                  # the cold-open Level Sequence
    NoSignalSound:audio_player_device                   # AMB_No_Signal, looping
    RoomRain:audio_player_device                        # AMB_Rain_Window, looping
    BootChime:audio_player_device                       # SFX_Boot_Chime
    TutorialLine:audio_player_device                    # VO_Director_Tutorial_01

cold_open := class:
    Rig:cold_open_rig
    Input:input_router
    Screen:overlay_screen

    Logger:log = log{Channel := dead_air_log}

    # Safety net in case the sequence never signals StoppedEvent.
    SequenceTimeoutSeconds:float = 60.0
    # VO_Director_Tutorial_01.wav is 5.36 s; audio_player_device has no finished event.
    TutorialSeconds:float = 5.6

    var OnDesk:logic = false

    # ---- Pre-roll ----

    # Black with "PRESS ANY KEY TO START"; any key the input router hears starts the game.
    # Voice mode stays at its default (mic); the preset-lines choice needs a new home.
    RunPreRoll(Player:player)<suspends>:void =
        Rig.MonitorCamera.AddTo(Player)    # a fixed view under the black, so nothing shows when it lifts
        Screen.ClearLog()
        Screen.SetMenu(EmptyText, array{}, 0)
        Screen.SetTitle(PressAnyKeyText)
        Screen.Show(Player)
        Rig.NoSignalSound.Play()
        Input.AnyKeyEvent.Await()
        Logger.Print("[cold_open] pre-roll done")

    EndPreRoll():void =
        Rig.NoSignalSound.Stop()
        Screen.SetTitle(EmptyText)

    # ---- Cinematic ----

    RunColdOpen(Player:player)<suspends>:void =
        Rig.Sequence.Play(Player)
        # Swap to the desk camera underneath the sequence's camera, one tick in, so the pre-roll
        # view never shows between the two. The sequence opens on its own fade from black, so
        # the overlay comes down under it without a seam.
        Sleep(0.0)
        GoToDesk(Player)
        Screen.Hide()
        race:
            Rig.Sequence.StoppedEvent.Await()
            block:
                Sleep(SequenceTimeoutSeconds)
                Logger.Print("[cold_open] sequence never stopped; moving on", ?Level := log_level.Warning)
        Logger.Print("[cold_open] sequence done")

    # The sequence ends on black; the overlay goes straight back up as the room stand-in.
    EndColdOpen(Player:player):void =
        Screen.Show(Player)
        Rig.Sequence.GoToEndAndStop(Player)
        GoToDesk(Player)
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

    # For debug starts after the cold open: put the player at the room stand-in as if it had
    # played.
    SkipToDesk(Player:player):void =
        Screen.SetTitle(DeadAirTitle)
        Screen.Show(Player)
        GoToDesk(Player)
        Rig.RoomRain.Play()
