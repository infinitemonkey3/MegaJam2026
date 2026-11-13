using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The one device with a script (docs/implementation-plan.md, "Game state management"). Owns
# game_state, runs the macro flow PreRoll -> ColdOpen -> Room -> Client, and holds every device
# reference as an @editable. Place exactly one; the take_flow device it points to must have
# RunOnBegin off.
game_director := class(creative_device):
    Logger:log = log{Channel := dead_air_log}

    # The take loop. Its own ClientSpawner finds the client NPC.
    @editable Takes:take_flow = take_flow{}

    # Cold open (cold_open_rig).
    @editable MonitorCamera:gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}
    @editable DeskCamera:gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}
    @editable ColdOpenSequence:cinematic_sequence_device = cinematic_sequence_device{}
    @editable NoSignalSound:audio_player_device = audio_player_device{}
    @editable RoomRain:audio_player_device = audio_player_device{}
    @editable BootChime:audio_player_device = audio_player_device{}
    @editable TutorialLine:audio_player_device = audio_player_device{}

    # Debug starts. PreRoll is the real game; ColdOpen skips the pre-roll; Room or later skips
    # the whole opening and starts at the desk.
    @editable StartAt:game_phase = game_phase.PreRollPhase
    # Sprint skips the current phase.
    @editable DevKeys:logic = false

    # How long to wait for the client NPC's behavior to set up before going on without it.
    ClientWaitSeconds:float = 15.0

    State:game_state = game_state{}
    Input:input_router = input_router{}

    OnBegin<override>()<suspends>:void =
        Logger.Print("[game] director started, StartAt={GamePhaseName(StartAt)}")
        Player := AwaitPlayer()
        set State.MaybePlayer = option{Player}
        Input.Bind(Player, DevKeys)

        Screen:debug_screen = if (Sim := GetSimulationEntity[]) then entity_screen{Root := Sim, Input := Input} else stub_debug_screen{}
        set Takes.Screen = Screen
        MaybeControl := AwaitClientControl()

        Opening := cold_open:
            Rig := cold_open_rig:
                MonitorCamera := MonitorCamera
                DeskCamera := DeskCamera
                Sequence := ColdOpenSequence
                NoSignalSound := NoSignalSound
                RoomRain := RoomRain
                BootChime := BootChime
                TutorialLine := TutorialLine
            Input := Input
            Screen := Screen

        if (Runs[game_phase.PreRollPhase]):
            EnterPhase(game_phase.PreRollPhase)
            race:
                Opening.RunPreRoll(State, Player, MaybeControl)
                Input.SkipEvent.Await()
            Opening.EndPreRoll()

        if (Runs[game_phase.ColdOpenPhase]):
            EnterPhase(game_phase.ColdOpenPhase)
            race:
                Opening.RunColdOpen(Player)
                Input.SkipEvent.Await()
            Opening.EndColdOpen(Player)
            race:
                Opening.RunBoot()
                Input.SkipEvent.Await()
            Opening.EndBoot()
        else:
            Opening.SkipToDesk(Player)

        EnterPhase(game_phase.RoomPhase)
        # The tutorial and the room between dreams come here (milestone 4).

        EnterPhase(game_phase.ClientPhase)
        if (Control := MaybeControl?):
            Takes.RunClient(MakePlaceholderClient(), Control)
        else:
            Logger.Print("[game] no client NPC; skipping the client phase", ?Level := log_level.Error)

        EnterPhase(game_phase.DonePhase)

    # Succeeds if the session should play Phase, given StartAt.
    Runs(Phase:game_phase)<transacts><decides>:void =
        GamePhaseIndex(StartAt) <= GamePhaseIndex(Phase)

    EnterPhase(Next:game_phase):void =
        From := GamePhaseName(State.Phase)
        set State.Phase = Next
        Logger.Print("[game] {From} -> {GamePhaseName(Next)}")
        State.PhaseChangedEvent.Signal(Next)

    # The first player in the island. The game is solo: set Island Settings max players to 1.
    AwaitPlayer()<suspends>:player =
        loop:
            if (First := GetPlayspace().GetPlayers()[0]):
                return First
            Sleep(0.2)

    AwaitClientControl()<suspends>:?client_control =
        var Found:?client_control = false
        var Waited:float = 0.0
        loop:
            if (Control := Takes.FindClientControl[]):
                set Found = option{Control}
                break
            if (Waited >= ClientWaitSeconds):
                Logger.Print("[game] client NPC not ready after {ClientWaitSeconds}s", ?Level := log_level.Warning)
                break
            Sleep(0.5)
            set Waited += 0.5
        Found
