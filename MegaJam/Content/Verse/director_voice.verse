using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }

# Seam for the director's prerecorded voice. Lines are named; the audio stream maps names to
# audio_player_devices later. NOT COMPILED YET.
director_voice := interface:
    # Plays one named line and returns when it has finished.
    PlayLine(LineId:string)<suspends>:void

# Line names take_flow uses. "{DreamId}_intro" and "{DreamId}_solved" are built per dream.
DirectorLineBeforeTake:string = "before_take"
DirectorLineFailedTake:string = "failed_take"
DirectorLineMixedTake:string = "mixed_take"
DirectorLineEndingReaction:string = "ending_reaction"

# Logs the line name and waits a moment in place of the audio.
stub_director_voice := class(director_voice):
    Logger:log = log{Channel := dead_air_log}

    PlayLine<override>(LineId:string)<suspends>:void =
        Logger.Print("[director] {LineId}")
        Sleep(1.0)
