using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
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

    # How long the client phase waits for the client NPC's behavior to set up. The opening
    # doesn't wait for it at all.
    ClientWaitSeconds:float = 15.0
    # How long to keep trying to hide the player's character after they spawn.
    CharacterWaitSeconds:float = 5.0

    State:game_state = game_state{}
    Input:input_router = input_router{}

    OnBegin<override>()<suspends>:void =
        Logger.Print("[game] director started, StartAt={GamePhaseName(StartAt)}")
        Player := AwaitPlayer()
        set State.MaybePlayer = option{Player}
        # The player is never a body in this game and never sees Fortnite's HUD: hide both
        # before anything else, so the first thing they see is the start screen.
        HideFortniteHUD(Player)
        HoldPlayer(Player)
        Input.Bind(Player, DevKeys)

        # The debug screen is a full-screen overlay until the real screen and 2D room exist.
        Screen := overlay_screen{Input := Input}
        set Takes.Screen = Screen

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
                Opening.RunPreRoll(Player)
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
        MaybeControl := AwaitClientControl()
        if (Control := MaybeControl?):
            Takes.RunClient(MakePlaceholderClient(), Control)
        else:
            Logger.Print("[game] no client NPC; skipping the client phase", ?Level := log_level.Error)

        EnterPhase(game_phase.DonePhase)

    # Succeeds if the session should play Phase, given StartAt.
    Runs(Phase:game_phase)<transacts><decides>:void =
        GamePhaseIndex(StartAt) <= GamePhaseIndex(Phase)

    EnterPhase(Next:game_phase):void =
        if (State.Phase = Next):
            Logger.Print("[game] start at {GamePhaseName(Next)}")
        else:
            Logger.Print("[game] {GamePhaseName(State.Phase)} -> {GamePhaseName(Next)}")
        set State.Phase = Next
        State.PhaseChangedEvent.Signal(Next)

    # Hides every Fortnite HUD element (health, minimap, prompts, sound visualizers) for this
    # player for the whole game. Our own Verse UI isn't part of it and still shows.
    HideFortniteHUD(Player:player):void =
        Everything:[]hud_element_identifier = array{creative_hud_identifier_all{}, player_hud_identifier_all{}, hud_identifier_visual_sound_effect_all{}}
        GetPlayspace().GetHUDController().HideElementsForPlayer(Player, Everything)
        Logger.Print("[game] Fortnite HUD hidden")

    # Hides the player's character for the whole game. The character can take a moment to
    # exist after the player joins, so this retries briefly. Not put in stasis: stasis also
    # blocks Crouch and Jump, which drive the menus (first replay, 2026-11-13).
    HoldPlayer(Player:player)<suspends>:void =
        var Waited:float = 0.0
        loop:
            if (Character := Player.GetFortCharacter[]):
                Character.Hide()
                Logger.Print("[game] player character hidden")
                break
            if (Waited >= CharacterWaitSeconds):
                Logger.Print("[game] no character to hide after {CharacterWaitSeconds}s", ?Level := log_level.Warning)
                break
            Sleep(0.1)
            set Waited += 0.1

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
