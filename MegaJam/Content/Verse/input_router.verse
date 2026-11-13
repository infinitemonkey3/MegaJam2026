using { /Fortnite.com/Input }
using { /Verse.org/Input }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The player's keys for the whole game, as three events: "next" (Crouch), "confirm" (Jump) and,
# with dev keys on, "skip the current phase" (Sprint). The bindings follow the screen spike;
# change them here once the spike 4 play test shows which keys fire in first person.
input_router := class:
    Logger:log = log{Channel := dead_air_log}

    NextEvent:event() = event(){}
    ConfirmEvent:event() = event(){}
    SkipEvent:event() = event(){}

    Bind(Player:player, DevKeys:logic):void =
        if (PlayerInput := GetPlayerInput[Player]):
            PlayerInput.AddInputMapping(Character.TraversalMapping)
            PlayerInput.GetInputEvents(Character.Crouch).TriggerActivationEvent.Subscribe(OnNext)
            PlayerInput.GetInputEvents(Character.Jump).TriggerActivationEvent.Subscribe(OnConfirm)
            if (DevKeys?):
                PlayerInput.GetInputEvents(Character.Sprint).TriggerActivationEvent.Subscribe(OnSkip)
                Logger.Print("[input] bound: crouch=next, jump=confirm, sprint=skip")
            else:
                Logger.Print("[input] bound: crouch=next, jump=confirm")
        else:
            Logger.Print("[input] GetPlayerInput failed; menus won't respond", ?Level := log_level.Error)

    OnNext(Payload:tuple(player, logic)):void =
        NextEvent.Signal()

    OnConfirm(Payload:tuple(player, logic)):void =
        ConfirmEvent.Signal()

    OnSkip(Payload:tuple(player, logic)):void =
        Logger.Print("[input] skip")
        SkipEvent.Signal()
