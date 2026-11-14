using { /Fortnite.com/Input }
using { /Verse.org/Input }
using { /Verse.org/Simulation }
using { /Verse.org/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The player's keys for the whole game, as events:
#  - NextEvent (Crouch) and ConfirmEvent (Jump) for menus
#  - SkipEvent (Sprint, dev keys only): skip the current phase
#  - AnyKeyEvent: any of the keys Verse can hear (movement, Jump, Crouch, Sprint, Interact,
#    Reload, both mouse buttons). Verse only sees Fortnite's input actions, not raw keys, so
#    "press any key" means these.
# The menu bindings follow the screen spike; change them here once a play test shows which
# keys work best in first person.
# The player's active input, for prompts that name the key (Chip, 2026-11-14). From
# player_input.PreferredInputMethod, which updates when the player switches; it has no change
# event, so screens poll it. It can't tell an Xbox pad from a PlayStation one: Jump is "A" on
# Xbox, Cross on PlayStation, and prompts say "A".
input_kind := enum{KeyboardInput, GamepadInput, TouchInput}

ActiveInputKind(Player:player)<transacts>:input_kind =
    if (PlayerInput := GetPlayerInput[Player]):
        Method := PlayerInput.PreferredInputMethod
        if (Method = input_method.Gamepad) then input_kind.GamepadInput
        else if (Method = input_method.Touch) then input_kind.TouchInput
        else input_kind.KeyboardInput
    else:
        input_kind.KeyboardInput

# How often screens check for a switch between keyboard and gamepad.
InputKindPollSeconds:float = 0.25

input_router := class:
    Logger:log = log{Channel := dead_air_log}

    NextEvent:event() = event(){}
    ConfirmEvent:event() = event(){}
    SkipEvent:event() = event(){}
    AnyKeyEvent:event() = event(){}

    var DevKeys:logic = false

    Bind(Player:player, InDevKeys:logic):void =
        set DevKeys = InDevKeys
        if (PlayerInput := GetPlayerInput[Player]):
            PlayerInput.AddInputMapping(Character.TraversalMapping)
            PlayerInput.AddInputMapping(Character.InteractMapping)
            PlayerInput.AddInputMapping(Character.RangedWeaponMapping)
            PlayerInput.GetInputEvents(Character.Crouch).TriggerActivationEvent.Subscribe(OnNext)
            PlayerInput.GetInputEvents(Character.Jump).TriggerActivationEvent.Subscribe(OnConfirm)
            PlayerInput.GetInputEvents(Character.Sprint).TriggerActivationEvent.Subscribe(OnSprint)
            PlayerInput.GetInputEvents(Character.Interact).TriggerActivationEvent.Subscribe(OnOtherKey)
            PlayerInput.GetInputEvents(Character.Reload).TriggerActivationEvent.Subscribe(OnOtherKey)
            PlayerInput.GetInputEvents(Character.WeaponPrimary).TriggerActivationEvent.Subscribe(OnOtherKey)
            PlayerInput.GetInputEvents(Character.WeaponSecondary).TriggerActivationEvent.Subscribe(OnOtherKey)
            PlayerInput.GetInputEvents(Character.Move).TriggerActivationEvent.Subscribe(OnMove)
            if (DevKeys?):
                Logger.Print("[input] bound: crouch=next, jump=confirm, sprint=skip, any key")
            else:
                Logger.Print("[input] bound: crouch=next, jump=confirm, any key")
        else:
            Logger.Print("[input] GetPlayerInput failed; menus won't respond", ?Level := log_level.Error)

    # Gives the mouse buttons back to the UI. The weapon mapping (bound so a click counts as "any
    # key" on the start screen) takes left and right click before Verse UI buttons see them, so
    # the dream debugger's clicks never arrive while it's on (play test, 2026-11-13).
    FreeMouse(Player:player):void =
        if (PlayerInput := GetPlayerInput[Player]):
            PlayerInput.RemoveInputMapping(Character.RangedWeaponMapping)
            Logger.Print("[input] weapon mapping off: the mouse is the UI's")

    OnNext(Payload:tuple(player, logic)):void =
        AnyKeyEvent.Signal()
        NextEvent.Signal()

    OnConfirm(Payload:tuple(player, logic)):void =
        AnyKeyEvent.Signal()
        ConfirmEvent.Signal()

    OnSprint(Payload:tuple(player, logic)):void =
        AnyKeyEvent.Signal()
        if (DevKeys?):
            Logger.Print("[input] skip")
            SkipEvent.Signal()

    OnOtherKey(Payload:tuple(player, logic)):void =
        AnyKeyEvent.Signal()

    OnMove(Payload:tuple(player, vector3)):void =
        AnyKeyEvent.Signal()
