using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /invaliddomain/MegaJam/Spikes }

# TEMPORARY screen: drives the spike's in-world widget (Content/Spikes/UW_SpikeScreen) through
# the debug_screen seam, so the cold open can be seen before the real screen (stream 5) exists.
# Its three message fields stand in for the real ones: Title, Body (the log or case file) and
# Menu. Writes to every UW_SpikeScreen entity under Root. Swap for the real widget's adapter
# when it lands, and drop this file before the spikes come out.

NewLine<localizes>:message = "\n"
MenuGap<localizes>:message = "    "
MenuPicked<localizes>(Option:message):message = "> {Option}"
MenuUnpicked<localizes>(Option:message):message = "  {Option}"
SlateTitle<localizes>(TakeNumber:int):message = "TAKE {TakeNumber}"

entity_screen := class(debug_screen):
    Root:entity
    Input:input_router

    Logger:log = log{Channel := dead_air_log}
    MaxLogLines:int = 8

    var Lines:[]message = array{}

    Screens()<transacts>:[]UW_SpikeScreen_entity =
        for (Screen : Root.FindDescendantEntities(UW_SpikeScreen_entity)) { Screen }

    SetTitle<override>(Title:message):void =
        for (Screen : Screens()):
            set Screen.TitleMessage = Title

    ClearLog<override>():void =
        set Lines = array{}
        ShowBody()

    AppendLogLine<override>(Line:message):void =
        set Lines = LastN(Lines + array{Line}, MaxLogLines)
        ShowBody()

    SetCaseFile<override>(Entries:[]message):void =
        set Lines = Entries
        ShowBody()

    ShowBody():void =
        Body := Join(Lines, NewLine)
        for (Screen : Screens()):
            set Screen.BodyMessage = Body

    SetMenu<override>(Title:message, Options:[]message, Highlighted:int):void =
        Items := for (Index -> Option : Options):
            if (Index = Highlighted) then MenuPicked(Option) else MenuUnpicked(Option)
        Menu := Join(array{Title} + Items, MenuGap)
        for (Screen : Screens()):
            set Screen.MenuMessage = Menu

    ShowSlate<override>(TakeNumber:int)<suspends>:void =
        SetTitle(SlateTitle(TakeNumber))
        Sleep(1.5)

    # No fields for these on the spike widget yet: log only.
    SetVitals<override>(Level:int):void =
        Logger.Print("[screen] VITALS level={Level}", ?Level := log_level.Verbose)

    SetClientState<override>(TakeNumber:int, Feeling:client_state):void =
        Logger.Print("[screen] STATE take={TakeNumber} trust={Feeling.Trust} fear={Feeling.Fear} hope={Feeling.Hope}")

    AwaitNext<override>()<suspends>:void =
        Input.NextEvent.Await()

    AwaitConfirm<override>()<suspends>:void =
        Input.ConfirmEvent.Await()
