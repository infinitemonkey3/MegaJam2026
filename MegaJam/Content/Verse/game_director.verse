using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/SceneGraph }
using { /Verse.org/Assets }
using { /Fortnite.com/Assets }
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
    @editable RoomIntroSequence:cinematic_sequence_device = cinematic_sequence_device{}
    # The dream debugger: the in-world screen entity inside the monitor.
    @editable DebuggerScreen:DreamDebugger.UW_DreamDebugger_entity = DreamDebugger.UW_DreamDebugger_entity{}
    @editable NoSignalSound:audio_player_device = audio_player_device{}
    @editable RoomRain:audio_player_device = audio_player_device{}
    @editable BootChime:audio_player_device = audio_player_device{}
    @editable TutorialLine:audio_player_device = audio_player_device{}
    @editable TitleTheme:audio_player_device = audio_player_device{}
    # The title theme in a minor key, looping under the end card.
    @editable EndTheme:audio_player_device = audio_player_device{}
    # The director's lines over the case file and the role (Content/DirectorVO, players in the
    # outliner's Director/Devices). Lengths are in DirectorLines.
    @editable NellD1Intro:audio_player_device = audio_player_device{}
    @editable NellD1SendIn:audio_player_device = audio_player_device{}
    @editable NellD2Intro:audio_player_device = audio_player_device{}
    @editable NellD2SendIn:audio_player_device = audio_player_device{}
    @editable NellD3Intro:audio_player_device = audio_player_device{}
    @editable NellD3SendIn:audio_player_device = audio_player_device{}
    # The shipping Nell's send-ins (2026-11-15). Her intros reuse NellD1Intro and NellD3Intro,
    # which don't mention the bakery.
    @editable NellAltD1SendIn:audio_player_device = audio_player_device{}
    @editable NellAltD2SendIn:audio_player_device = audio_player_device{}
    # The finale (writing/nell/finale.md): the director's lines, the AI's line and the power cut.
    @editable FinalePraise:audio_player_device = audio_player_device{}
    @editable FinaleReboot:audio_player_device = audio_player_device{}
    @editable FinaleAI:audio_player_device = audio_player_device{}
    @editable FinaleNotYours:audio_player_device = audio_player_device{}
    @editable FinaleAI2:audio_player_device = audio_player_device{}
    @editable FinaleAICut:audio_player_device = audio_player_device{}
    # The hack's sounds (audio/sfx, players DIR sfx_*). The blip's player restarts on each play.
    @editable SfxHack:audio_player_device = audio_player_device{}
    @editable SfxSpamRamp:audio_player_device = audio_player_device{}
    @editable SfxSpamBlip:audio_player_device = audio_player_device{}
    @editable FinalePlug:audio_player_device = audio_player_device{}
    @editable FinalePowerCut:audio_player_device = audio_player_device{}
    @editable FinaleAfter:audio_player_device = audio_player_device{}
    @editable FinaleResting:audio_player_device = audio_player_device{}
    @editable FinaleKettle:audio_player_device = audio_player_device{}
    # Room lines: the director on things in the room the player clicks (writing/director/room-lines.md).
    @editable RoomPosterMusical:audio_player_device = audio_player_device{}
    @editable RoomFilmCamera:audio_player_device = audio_player_device{}

    # Debug starts. PreRoll is the real game; ColdOpen skips the pre-roll; Room or later skips
    # the whole opening and starts at the desk.
    @editable StartAt:game_phase = game_phase.PreRollPhase
    # Sprint skips the current phase.
    @editable DevKeys:logic = false
    # Debug: the patient's dream to start at (0 is the first). 2 starts at Nell's dream 3, to test
    # it and the finale; the cake from dream 2 then falls back to a lemon cake.
    @editable StartDream:int = 0
    # Debug: skip every dream and play the finale (Lumi, the plug, Nell waking, the end card).
    # Off for a real build.
    @editable SkipToFinale:logic = false
    # Which client is on the debugger, in the takes and in the recliner. SetUpPatient puts their
    # art on ReclinerCard and their NPC definition (the voice) on the take flow's ClientSpawner.
    @editable Patient:patient_choice = patient_choice.NellAltPatient
    # The recliner: a Scene Graph entity with a Room.Meshes.SM_RoomCard mesh component.
    @editable ReclinerCard:entity = entity{}
    # Nell's recliner material once SetUpPatient has put it on the card (AnimateMouth sets it).
    var NellRecliner:?Room.Materials.MI_Room_Recliner_Nell = false
    # Each patient's NPC Character Definition. Only its voice matters: LoadDream replaces the
    # personality. Left empty, the spawner keeps the definition it was placed with.
    @editable NellDefinition:?npc_character_definition = false
    @editable DesDefinition:?npc_character_definition = false

    # How long the client phase waits for the client NPC's behavior to set up. The opening
    # doesn't wait for it at all.
    ClientWaitSeconds:float = 15.0
    # How long to keep trying to hide the player's character after they spawn.
    CharacterWaitSeconds:float = 5.0

    State:game_state = game_state{}
    Input:input_router = input_router{}

    OnBegin<override>()<suspends>:void =
        Logger.Print("[game] director started, StartAt={GamePhaseName(StartAt)}")
        SetUpPatient()
        Player := AwaitPlayer()
        set State.MaybePlayer = option{Player}
        # The player is never a body in this game and never sees Fortnite's HUD: hide both
        # before anything else, so the first thing they see is the start screen.
        HideFortniteHUD(Player)
        HoldPlayer(Player)
        Input.Bind(Player, DevKeys)

        # The black full-screen overlay is the start screen and covers hand-offs; everything the
        # player reads after that is on the dream debugger in the monitor.
        Screen := overlay_screen{Input := Input}
        Debugger := dream_debugger_screen{Entity := DebuggerScreen, Input := Input}
        Debugger.Clear()
        set Takes.Screen = Debugger
        set Takes.Director = device_director_voice{Lines := DirectorLines()}

        # The design B debugger is made up front so the boot can play on it (Chip, 2026-11-15:
        # the boot should match the new debugger). It shows when the room intro reaches the desk.
        Client := MakePatient(Patient)
        DebuggerUI := dream_debugger_ui{Client := Client}

        Opening := cold_open:
            Rig := cold_open_rig:
                MonitorCamera := MonitorCamera
                DeskCamera := DeskCamera
                Sequence := ColdOpenSequence
                RoomIntro := RoomIntroSequence
                NoSignalSound := NoSignalSound
                RoomRain := RoomRain
                BootChime := BootChime
                TutorialLine := TutorialLine
                TitleTheme := TitleTheme
            Input := Input
            Screen := Screen
            Debugger := DebuggerUI

        if (Runs[game_phase.PreRollPhase]):
            EnterPhase(game_phase.PreRollPhase)
            race:
                Opening.RunPreRoll(Player)
                Input.SkipEvent.Await()
            Opening.EndPreRoll()

        if (Runs[game_phase.ColdOpenPhase]):
            EnterPhase(game_phase.ColdOpenPhase)
            # Space (Jump, the router's confirm) skips the cold open to the room intro (Chip,
            # 2026-11-13), for players and for iterating on the room.
            race:
                Opening.RunColdOpen(Player)
                Input.SkipEvent.Await()
                AwaitFreshConfirm()
            Opening.EndColdOpen(Player)
            spawn{RehideHUD(Player)}            # the sequence restores the HUD when it stops
            # Space again skips the room intro and the boot together, straight to the debugger
            # (Chip, 2026-11-14, to iterate faster).
            race:
                block:
                    Opening.RunRoomIntro(Player)
                    Opening.EndRoomIntro(Player)
                    spawn{RehideHUD(Player)}
                    ShowDebugger(Player, Debugger, DebuggerUI)
                    Opening.RunBoot()
                Input.SkipEvent.Await()
                AwaitFreshConfirm()
            Opening.EndRoomIntro(Player)
            Opening.EndBoot()
            spawn{RehideHUD(Player)}
        else:
            Opening.SkipToDesk(Player)

        # The interactive dream debugger, if the boot didn't already show it (a skip or a debug
        # start). Let the view settle on the desk camera first: after a skip the client is still
        # at the room intro's start, 60 cm back, for a moment, and the debugger came out too small
        # (play test, 2026-11-14): the projection reads the player's current view.
        Sleep(ViewSettleSeconds)
        ShowDebugger(Player, Debugger, DebuggerUI)
        # Clickable things in the room (Chip, 2026-11-15: the poster first, as the example).
        if (Poster := MakePosterPanel().ProjectRect[Player]):
            DebuggerUI.AddRoomTarget("room_poster_musical", "SING, MEADOW, SING", Poster)
        if (Camera := MakeFilmCameraPanel().ProjectRect[Player]):
            DebuggerUI.AddRoomTarget("room_film_camera", "FILM CAMERA", Camera)
        spawn{PlayRoomLines(DebuggerUI)}

        EnterPhase(game_phase.RoomPhase)
        # The tutorial and the room between dreams come here (milestone 4).

        EnterPhase(game_phase.ClientPhase)
        # The take flow runs on the dream debugger from here: the case file and ATTACH TO
        # DREAMER first (Chip, 2026-11-13: the debugger is just the case file now).
        set Takes.Screen = DebuggerUI
        # The persona's talk UI is the HUD Controller device's "Show LLM Conversations UI", set to
        # Show Element; its "Show HUD" is Do Not Override so it doesn't hide that too. The rest of
        # the HUD stays hidden by HideFortniteHUD (play test, 2026-11-13).
        MaybeControl := AwaitClientControl()
        if (Control := MaybeControl?):
            spawn{AnimateMouth(Control)}
            DebuggerUI.BeginTake()
            if (StartDream > 0):
                Logger.Print("[game] debug start at dream {StartDream}")
                set Takes.DreamIndex = StartDream
            if (SkipToFinale?):
                Logger.Print("[game] debug: straight to the finale")
                set Takes.DreamIndex = Max(0, Client.Dreams.Length - 1)
                set Takes.Phase = take_phase.Finale
            Takes.RunClient(Client, Control)
            DebuggerUI.EndTake()
            if (Takes.FinaleReached?):
                RunFinaleEnd(Player, Control, Screen, Debugger, DebuggerUI)
        else:
            Logger.Print("[game] no client NPC; skipping the client phase", ?Level := log_level.Error)

        EnterPhase(game_phase.DonePhase)

    # The director's recorded lines, by the ids take_flow plays, with each WAV's length plus a
    # beat (audio/narration/VO_Director_nell_*.wav).
    DirectorLines():[]director_line =
        array:
            director_line{Id := "nell_d1_intro", Player := NellD1Intro, Seconds := 13.2}
            director_line{Id := "nell_d1_sendin", Player := NellD1SendIn, Seconds := 11.4}
            director_line{Id := "nell_d2_intro", Player := NellD2Intro, Seconds := 9.1}
            director_line{Id := "nell_d2_sendin", Player := NellD2SendIn, Seconds := 13.9}
            director_line{Id := "nell_d3_intro", Player := NellD3Intro, Seconds := 6.3}
            director_line{Id := "nell_d3_sendin", Player := NellD3SendIn, Seconds := 12.7}
            # The shipping Nell: "Eleanor Price. Nell. Bargain implant..." and "Bottom of the
            # well..." fit her too; the send-ins are her own.
            director_line{Id := "nellalt_d1_intro", Player := NellD1Intro, Seconds := 13.2}
            director_line{Id := "nellalt_d1_sendin", Player := NellAltD1SendIn, Seconds := 11.5}
            director_line{Id := "nellalt_d2_intro", Player := NellD3Intro, Seconds := 6.3}
            director_line{Id := "nellalt_d2_sendin", Player := NellAltD2SendIn, Seconds := 13.4}
            director_line{Id := "finale_praise", Player := FinalePraise, Seconds := 9.8}
            director_line{Id := "finale_reboot", Player := FinaleReboot, Seconds := 6.9}
            director_line{Id := "finale_ai", Player := FinaleAI, Seconds := 9.8}
            director_line{Id := "finale_notyours", Player := FinaleNotYours, Seconds := 4.3}
            director_line{Id := "finale_ai_2", Player := FinaleAI2, Seconds := 6.0}
            director_line{Id := "finale_plug", Player := FinalePlug, Seconds := 3.4}
            # Lumi's "No! You will not take-", trimmed to end on the cut: no beat after it.
            director_line{Id := "finale_ai_cut", Player := FinaleAICut, Seconds := 2.6}
            director_line{Id := "sfx_hack", Player := SfxHack, Seconds := 5.0}
            director_line{Id := "sfx_spam_ramp", Player := SfxSpamRamp, Seconds := 11.0}
            director_line{Id := "sfx_spam_blip", Player := SfxSpamBlip, Seconds := 0.12}
            director_line{Id := "room_poster_musical", Player := RoomPosterMusical, Seconds := 8.8}
            director_line{Id := "room_film_camera", Player := RoomFilmCamera, Seconds := 8.4}
            director_line{Id := "finale_power_cut", Player := FinalePowerCut, Seconds := 3.6}
            director_line{Id := "finale_after", Player := FinaleAfter, Seconds := 6.9}
            director_line{Id := "finale_resting", Player := FinaleResting, Seconds := 2.9}
            director_line{Id := "finale_kettle", Player := FinaleKettle, Seconds := 1.8}

    # A Space press made after the stage began. The press that ended the stage before fires the
    # Jump event again (play test, 2026-11-14: the start press skipped the whole cold open), so
    # presses in the first SkipGraceSeconds are ignored.
    SkipGraceSeconds:float = 1.0
    # How long the view gets to land on the desk camera before the debugger is placed over it.
    ViewSettleSeconds:float = 1.0
    AwaitFreshConfirm()<suspends>:void =
        Sleep(SkipGraceSeconds)
        Input.ConfirmEvent.Await()

    # The end of the finale, after the director pulls the plug (writing/nell/finale.md): the
    # power cut and the monitor going black, the director shaken, Nell waking as if from a nap in
    # front of the TV, a little banter, then the end card.
    RunFinaleEnd(Player:player, Control:client_control, Screen:overlay_screen, Debugger:dream_debugger_screen, DebuggerUI:dream_debugger_ui)<suspends>:void =
        Logger.Print("[game] finale: the plug")
        branch:
            Takes.Director.PlayLine("finale_power_cut")
        DebuggerUI.Hide()
        Debugger.Clear()
        Takes.Haze.Reset()
        Sleep(5.0)                                      # the sound, then a beat of rain and dark
        Takes.Director.PlayLine("finale_after")         # "That thing talked..."
        Sleep(1.0)
        # She wakes: her eyes open for her lines (Chip, 2026-11-15). EyesOpen is a scalar on
        # M_Room_Breath (art/tools/add_eyes_to_breath.py).
        if (Nell := NellRecliner?):
            set Nell.EyesOpen = 1.0
        NellSays(Control, NellWakeLine)
        Takes.Director.PlayLine("finale_resting")       # "Just resting your eyes, Mrs. Price."
        NellSays(Control, NellBanterLine)
        Takes.Director.PlayLine("finale_kettle")        # "Kettle's on."
        Sleep(1.5)
        Logger.Print("[game] finale: end card")
        Screen.Show(Player)
        EndTheme.Play()
        EndCard := title_card{}
        EndCard.Show(Player, EndCardText)

    # Puts the design B debugger over the monitor's glass (once; later calls do nothing). The
    # in-world screen behind stays as the dark fill, so its text is blanked.
    ShowDebugger(Player:player, Debugger:dream_debugger_screen, DebuggerUI:dream_debugger_ui):void =
        if (Monitor := MakeMonitorPanel().ProjectRect[Player]):
            Debugger.Clear()
            Input.FreeMouse(Player)
            DebuggerUI.Show(Player, Monitor)
        else:
            Logger.Print("[game] couldn't place the dream debugger over the monitor", ?Level := log_level.Warning)

    # Nell says one line word for word, and this waits until she has finished.
    NellSays(Control:client_control, Line:string)<suspends>:void =
        Speaking := Control.SpeakLine(Line)             # no_rollback: not inside the if
        if (Speaking?):
            Control.AwaitSpeechEnd(20.0)

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
        # Hide the Fortnite HUD again at each phase: in the published version it came back after
        # the hide at join (play test, 2026-11-15). Phases change only before the first take, so
        # this never fights the persona's talk UI.
        if (Player := State.MaybePlayer?):
            HideFortniteHUD(Player)

    # Hides every Fortnite HUD element (health, minimap, prompts, sound visualizers) for this
    # player for the whole game. Our own Verse UI isn't part of it and still shows.
    HideFortniteHUD(Player:player):void =
        Everything:[]hud_element_identifier = array{creative_hud_identifier_all{}, player_hud_identifier_all{}, hud_identifier_visual_sound_effect_all{}}
        GetPlayspace().GetHUDController().HideElementsForPlayer(Player, Everything)
        Logger.Print("[game] Fortnite HUD hidden")

    # Cinematic sequences hide the HUD while they play and restore it when they stop, which undid
    # our hide (published version, 2026-11-15: minimap, health and the weapon bar came back when
    # the room started). The client restores it a few frames after the server's stop, so hide it
    # again now and twice more over the next two seconds.
    RehideHUD(Player:player)<suspends>:void =
        HideFortniteHUD(Player)
        Sleep(0.5)
        HideFortniteHUD(Player)
        Sleep(1.5)
        HideFortniteHUD(Player)

    # Hides the player's character for the whole game. The character can take a moment to
    # exist after the player joins, so this retries briefly. Not put in stasis: stasis also
    # blocks Crouch and Jump, which drive the menus (first replay, 2026-11-13).
    HoldPlayer(Player:player)<suspends>:void =
        var Waited:float = 0.0
        loop:
            if (Character := Player.GetFortCharacter[]):
                Character.Hide()
                Logger.Print("[game] player character hidden")
                # Spawning can bring the HUD back (published version, 2026-11-15).
                HideFortniteHUD(Player)
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

    # A clicked room target plays the director's line for it, unless he's already talking.
    # Clicks during a line are ignored. Runs for good.
    PlayRoomLines(UI:dream_debugger_ui)<suspends>:void =
        loop:
            Id := UI.RoomTargetEvent.Await()
            if (not Takes.Director.Speaking[]):
                Takes.Director.PlayLine(Id)

    # Nell's mouth moves while she speaks (Chip, 2026-11-14): her recliner material
    # (M_Room_Breath) plays a 4-frame mouth flipbook over her face while Talking is 1. Driven by
    # the persona's say events, so it covers takes, narration and the finale alike. Runs for good.
    AnimateMouth(Control:client_control)<suspends>:void =
        loop:
            Control.Persona.StartSayEvent.Await()
            SetTalking(1.0)
            Control.Persona.StopSayEvent.Await()
            SetTalking(0.0)

    SetTalking(Value:float):void =
        if (Nell := NellRecliner?):
            set Nell.Talking = Value

    # Puts the chosen patient in the room: their art on the recliner card, and their NPC
    # definition on the client spawner. The NPC is respawned so the new voice takes; nothing
    # waits on it until the client phase.
    SetUpPatient():void =
        if (Card := ReclinerCard.GetComponent[Room.Meshes.SM_RoomCard]):
            if (Patient = patient_choice.NellPatient or Patient = patient_choice.NellAltPatient):
                # Kept, so AnimateMouth can set its Talking parameter.
                Nell := Room.Materials.MI_Room_Recliner_Nell{}
                set Card.Card = Nell
                set NellRecliner = option{Nell}
            else:
                set Card.Card = PatientRecliner(Patient)
        else:
            Logger.Print("[game] ReclinerCard has no SM_RoomCard; the recliner keeps its placed art", ?Level := log_level.Warning)
        MaybeDefinition := case (Patient):
            patient_choice.NellPatient => NellDefinition
            patient_choice.NellAltPatient => NellDefinition
            patient_choice.DesPatient => DesDefinition
        if (Definition := MaybeDefinition?, Takes.ClientSpawner.SetNPCCharacterDefinition[Definition]):
            Takes.ClientSpawner.DespawnAll(false)
            Takes.ClientSpawner.Spawn()
        else:
            Logger.Print("[game] no NPC definition set for this patient; the client spawner keeps its own", ?Level := log_level.Warning)

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

# Nell, awake in the recliner after the finale, as if she'd nodded off in front of the TV.
NellWakeLine:string = "Hm? Oh. Did I drop off? I must have nodded off in front of the telly again."
NellBanterLine:string = "Nell. Mrs. Price was for the classroom, and that was a long time ago. I had the loveliest dream. Walt was in it. Well, don't just stand there. Somebody put the kettle on."
# PLACEHOLDER team name until it's chosen.
EndCardText<localizes>:message = "THANK YOU FOR PLAYING   //   DREAM TEAM"

# The patients the game can run. Values carry a suffix so they can't clash with a content
# folder's module name.
patient_choice := enum:
    NellPatient
    DesPatient
    # The shipping Nell (nell_alt_data.verse, Chip, 2026-11-15): her art and voice, a different woman.
    NellAltPatient

# The recliner art for each patient: the empty recliner with them in it, painted as one image.
PatientRecliner(Choice:patient_choice)<transacts>:material =
    case (Choice):
        patient_choice.NellPatient => Room.Materials.MI_Room_Recliner_Nell{}
        patient_choice.NellAltPatient => Room.Materials.MI_Room_Recliner_Nell{}
        patient_choice.DesPatient => Room.Materials.MI_Room_Recliner_Des{}

MakePatient(Choice:patient_choice)<transacts>:client =
    case (Choice):
        patient_choice.NellPatient => MakeNellClient()
        patient_choice.NellAltPatient => MakeNellAltClient()
        patient_choice.DesPatient => MakeDesClient()
