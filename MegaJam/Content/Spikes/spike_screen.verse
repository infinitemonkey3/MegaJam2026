# Day 1 tech spike 4 (docs/spikes.md): the in-world UMG screen.
# Drives the Verse fields of every placed UW_SpikeScreen entity once a second, and logs which
# input actions fire in first person so we know what can drive a display-only screen.

using { /Fortnite.com/Devices }
using { /Fortnite.com/Input }
using { /Verse.org/Input }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Verse.org/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

spike_screen := class(creative_device):
    Logger:log = log{Channel := spike_log}

    var Selected:int = 0
    var Ticks:int = 0
    var Locked:logic = false
    Options:[]string = array{"stranger", "old friend", "nephew Teddy"}

    TitleText<localizes>(N:int):message = "DEAD AIR // debug session t={N}"
    LogText<localizes>(N:int):message = "SCENE bakery_interior / T 05:00 / OVEN state=cold / CUSTOMERS count=11 faces=null\nVITALS hr={N} / LOOP count=412 / STATUS persistent session fault"
    MenuText<localizes>(S:string):message = "> CASTING: {S}    [crouch: next / jump: lock]"
    LockedText<localizes>(S:string):message = "CAST LOCKED: {S}"

    OnBegin<override>()<suspends>:void =
        for (Player : GetPlayspace().GetPlayers()):
            BindInput(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(BindInput)
        loop:
            Refresh()
            Sleep(1.0)
            set Ticks += 1

    Refresh():void =
        var Count:int = 0
        if (Sim := GetSimulationEntity[]):
            for (Screen : Sim.FindDescendantEntities(UW_SpikeScreen_entity)):
                set Count += 1
                set Screen.TitleMessage = TitleText(Ticks)
                set Screen.BodyMessage = LogText(60 + Mod[Ticks, 40] or 60)
                if (Option := Options[Selected]):
                    set Screen.MenuMessage = if (Locked?) then LockedText(Option) else MenuText(Option)
        if (Ticks = 0):
            Logger.Print("SCREEN found {Count} UW_SpikeScreen entities")

    BindInput(Player:player):void =
        if (PlayerInput := GetPlayerInput[Player]):
            PlayerInput.AddInputMapping(Character.TraversalMapping)
            PlayerInput.AddInputMapping(UI.MenuNavigationMapping)
            PlayerInput.GetInputEvents(Character.Crouch).TriggerActivationEvent.Subscribe(OnCrouch)
            PlayerInput.GetInputEvents(Character.Jump).TriggerActivationEvent.Subscribe(OnJump)
            PlayerInput.GetInputEvents(Character.Sprint).TriggerActivationEvent.Subscribe(OnSprint)
            PlayerInput.GetInputEvents(UI.NextTab).TriggerActivationEvent.Subscribe(OnNextTab)
            PlayerInput.GetInputEvents(UI.PreviousTab).TriggerActivationEvent.Subscribe(OnPreviousTab)
            PlayerInput.GetInputEvents(UI.Back).TriggerActivationEvent.Subscribe(OnBack)
            Logger.Print("SCREEN input bound for a player")
        else:
            Logger.Print("SCREEN GetPlayerInput failed", ?Level := log_level.Warning)

    OnCrouch(Payload:tuple(player, logic)):void =
        Logger.Print("INPUT Crouch")
        if (not Locked?):
            set Selected = Mod[Selected + 1, Options.Length] or 0
        Refresh()

    OnJump(Payload:tuple(player, logic)):void =
        Logger.Print("INPUT Jump")
        set Locked = if (Locked?) then false else true
        Refresh()

    OnSprint(Payload:tuple(player, logic)):void =
        Logger.Print("INPUT Sprint")

    OnNextTab(Payload:tuple(player, logic)):void =
        Logger.Print("INPUT UI.NextTab")

    OnPreviousTab(Payload:tuple(player, logic)):void =
        Logger.Print("INPUT UI.PreviousTab")

    OnBack(Payload:tuple(player, logic)):void =
        Logger.Print("INPUT UI.Back")
