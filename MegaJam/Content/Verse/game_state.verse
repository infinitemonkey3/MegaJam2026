using { /Verse.org/Simulation }

# The game's top-level phases (docs/implementation-plan.md, "Game state management"). The macro
# flow runs them once, in this order; only game_director changes the phase.
game_phase := enum{PreRollPhase, ColdOpenPhase, RoomPhase, ClientPhase, EndingPhase, DonePhase}

GamePhaseName(Phase:game_phase)<transacts>:string =
    case (Phase):
        game_phase.PreRollPhase => "PreRoll"
        game_phase.ColdOpenPhase => "ColdOpen"
        game_phase.RoomPhase => "Room"
        game_phase.ClientPhase => "Client"
        game_phase.EndingPhase => "Ending"
        game_phase.DonePhase => "Done"

# Phase order, for "start at" comparisons.
GamePhaseIndex(Phase:game_phase)<transacts>:int =
    case (Phase):
        game_phase.PreRollPhase => 0
        game_phase.ColdOpenPhase => 1
        game_phase.RoomPhase => 2
        game_phase.ClientPhase => 3
        game_phase.EndingPhase => 4
        game_phase.DonePhase => 5

# How the player speaks in takes: out loud, or by picking preset lines (no microphone).
voice_mode := enum{Mic, Presets}

# The single source of truth for the session. Grows with milestone 1 (dream and take counters,
# facts, memories and the client's state move here from take_flow and client_control).
game_state := class:
    var Phase:game_phase = game_phase.PreRollPhase
    var MaybePlayer:?player = false
    var VoiceMode:voice_mode = voice_mode.Mic

    # Signaled by game_director after every phase change.
    PhaseChangedEvent:event(game_phase) = event(game_phase){}
