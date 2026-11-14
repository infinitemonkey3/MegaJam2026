using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }

# Seam for the director's prerecorded voice. Lines are named; device_director_voice plays the
# ones that have an audio player in the level (audio/narration/README.md has the script).
director_voice := interface:
    # Plays one named line and returns when it has finished.
    PlayLine(LineId:string)<suspends>:void

# Line names take_flow uses. "{DreamId}_intro" and "{DreamId}_solved" are built per dream.
DirectorLineBeforeTake:string = "before_take"
DirectorLineFailedTake:string = "failed_take"
DirectorLineMixedTake:string = "mixed_take"
DirectorLineEndingReaction:string = "ending_reaction"

# One prerecorded line: its id, the audio player that holds it, and how long it runs
# (audio_player_device has no finished event).
director_line := class:
    Id:string
    Player:audio_player_device
    Seconds:float

# Plays a line that has a player, and returns when it has run its length. A line without one
# (no audio yet) is only logged, like the stub, and returns at once.
device_director_voice := class(director_voice):
    Lines:[]director_line
    Logger:log = log{Channel := dead_air_log}

    PlayLine<override>(LineId:string)<suspends>:void =
        if (Line := FindLine[LineId]):
            Logger.Print("[director] {LineId}")
            Line.Player.Play()
            Sleep(Line.Seconds)
        else:
            Logger.Print("[director] {LineId} (no audio)")

    FindLine(LineId:string)<transacts><decides>:director_line =
        var Found:?director_line = false
        for (Line : Lines, Line.Id = LineId):
            set Found = option{Line}
        Found?

# Logs the line name and waits a moment in place of the audio.
stub_director_voice := class(director_voice):
    Logger:log = log{Channel := dead_air_log}

    PlayLine<override>(LineId:string)<suspends>:void =
        Logger.Print("[director] {LineId}")
        Sleep(1.0)
