using { /UnrealEngine.com/Temporary/Diagnostics }

# Seam for the danger haze (docs/design.md: "The haze shows the danger"). Three inputs, each
# 0-3; the haze level is the highest. This class holds the rule; the post-process devices and
# the room lamp hang off ApplyLevel later. NOT COMPILED YET.
haze_controller := class:
    Logger:log = log{Channel := dead_air_log}

    var Distress:int = 0    # live, from the client's scene_update
    var SetupRisk:int = 0   # base level from the take's riskiest setup choice
    var Clock:int = 0       # creeps up as the take nears the moment the loop always ends
    var Applied:int = -1    # last level sent to ApplyLevel

    SetDistress(Level:int):void =
        set Distress = Clamp(Level, 0, 3)
        Refresh()

    SetSetupRisk(Level:int):void =
        set SetupRisk = Clamp(Level, 0, 3)
        Refresh()

    SetClock(Level:int):void =
        set Clock = Clamp(Level, 0, 3)
        Refresh()

    # Back to clear, for the start of a take.
    Reset():void =
        set Distress = 0
        set SetupRisk = 0
        set Clock = 0
        Refresh()

    # Highest of the three wins. The clock doesn't count while the client is calm.
    CurrentLevel()<transacts>:int =
        ClockPart := if (Distress = 0) then 0 else Clock
        Max(Distress, Max(SetupRisk, ClockPart))

    Refresh():void =
        Level := CurrentLevel()
        if (Level <> Applied):
            set Applied = Level
            ApplyLevel(Level)

    # Stub: only logs. Later: one post-process device per level (BlendInForAll/BlendOutForAll),
    # customizable_light_device.DimLight for the lamp, room tone.
    ApplyLevel(Level:int):void =
        Logger.Print("[haze] level={Level} (distress={Distress} setup={SetupRisk} clock={Clock})")
