using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The pre-roll and the cold open (docs/implementation-plan.md, section 2). game_director runs
# RunPreRoll, RunColdOpen and RunBoot in order, each raced against the dev skip, and calls the
# matching End* function afterwards either way, so a skipped phase still leaves the cameras
# and sounds right.
#
# The pre-roll is the desk monitor seen up close through MonitorCamera: a dead broadcast, the
# mic check and the voice choice. The cinematic is one Level Sequence (camera path, narration,
# jingle and rain on its own tracks). It ends on the desk view, where the same monitor boots.

# Authored placeholder text; the writing stream's versions replace it.
NoSignalTitle<localizes>:message = "NO SIGNAL"
MicPrompt<localizes>:message = "Say something."
MicHeard<localizes>:message = "SIGNAL DETECTED"
VoiceMenuTitle<localizes>:message = "HOW DO YOU TALK TO THEM?  [crouch] change  [jump] start"
TalkOption<localizes>:message = "Out loud (microphone)"
PresetOption<localizes>:message = "Preset lines (no microphone)"
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

    # ---- Pre-roll ----

    # Takes is only used to find the client NPC's voice channel for the mic check, whenever the
    # NPC finishes setting up; the pre-roll doesn't wait for it.
    RunPreRoll(State:game_state, Player:player, Takes:take_flow)<suspends>:void =
        Rig.MonitorCamera.AddTo(Player)
        Rig.NoSignalSound.Play()
        Screen.ClearLog()
        Screen.SetTitle(NoSignalTitle)
        Screen.AppendLogLine(MicPrompt)
        race:
            WatchMic(Takes)
            ChooseVoiceMode(State)
        Logger.Print("[cold_open] pre-roll done")

    # Shows "SIGNAL DETECTED" whenever someone speaks on the client's voice channel. In a solo
    # island that's the player. Waits for the client NPC to set up first, however long that
    # takes. Unverified: whether a player broadcasts on that channel before anyone is their
    # conversation target. Never returns.
    WatchMic(Takes:take_flow)<suspends>:void =
        var MaybeControl:?client_control = false
        loop:
            if (Found := Takes.FindClientControl[]):
                set MaybeControl = option{Found}
                break
            Sleep(0.5)
        if (Control := MaybeControl?):
            Logger.Print("[cold_open] mic check listening on the client's voice channel")
            loop:
                Control.VoiceChannel.BeginBroadcastEvent().Await()
                Screen.AppendLogLine(MicHeard)

    # The voice choice doubles as the start prompt: confirming a choice starts the game.
    ChooseVoiceMode(State:game_state)<suspends>:void =
        Options := array{TalkOption, PresetOption}
        var Highlighted:int = 0
        loop:
            Screen.SetMenu(VoiceMenuTitle, Options, Highlighted)
            Confirmed := race:
                block:
                    Input.ConfirmEvent.Await()
                    true
                block:
                    Input.NextEvent.Await()
                    false
            if (Confirmed?):
                break
            set Highlighted = if (Highlighted = 0) then 1 else 0
        set State.VoiceMode = if (Highlighted = 0) then voice_mode.Mic else voice_mode.Presets
        if (Highlighted = 0):
            Logger.Print("[cold_open] voice mode: mic")
        else:
            Logger.Print("[cold_open] voice mode: presets")

    EndPreRoll():void =
        Rig.NoSignalSound.Stop()
        Screen.SetMenu(EmptyText, array{}, 0)
        Screen.ClearLog()
        Screen.SetTitle(EmptyText)

    # ---- Cinematic ----

    RunColdOpen(Player:player)<suspends>:void =
        Rig.Sequence.Play(Player)
        # Swap to the desk camera underneath the sequence's camera, one tick in, so the pre-roll
        # view never shows between the two and the sequence's last frame hands straight over.
        Sleep(0.0)
        GoToDesk(Player)
        race:
            Rig.Sequence.StoppedEvent.Await()
            block:
                Sleep(SequenceTimeoutSeconds)
                Logger.Print("[cold_open] sequence never stopped; moving on", ?Level := log_level.Warning)
        Logger.Print("[cold_open] sequence done")

    EndColdOpen(Player:player):void =
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

    # For debug starts after the cold open: put the player at the desk as if it had played.
    SkipToDesk(Player:player):void =
        GoToDesk(Player)
        Rig.RoomRain.Play()
        Screen.SetTitle(DeadAirTitle)
