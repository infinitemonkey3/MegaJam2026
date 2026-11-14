using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# The start screen's picture: the Wonderwell title card (Content/TitleCard/T_TitleCard, from
# art/style-test/mockup-title.jpg: dream sky, wordmark, the empty recliner) over the whole
# screen, with the prompt low in the dark floor under the recliner. It sits above the black
# overlay_screen, which stays up underneath for the hand-off into the cold open.
title_card := class:
    # Where the prompt's centre sits, as a fraction of the screen height: below the recliner.
    PromptY:float = 0.965

    var MaybeRoot:?canvas = false
    var MaybePlayerUI:?player_ui = false

    Show(Player:player, Prompt:message):void =
        if (not MaybeRoot?, PlayerUI := GetPlayerUI[Player]):
            PromptText := text_block:
                DefaultText := Prompt
                DefaultTextColor := NamedColors.White
                DefaultTextSize := 26.0
                DefaultJustification := text_justification.Center
            Root := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                        Offsets := margin{}
                        Widget := texture_block{DefaultImage := TitleCard.T_TitleCard}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := PromptY}, Maximum := vector2{X := 0.5, Y := PromptY}}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := PromptText
            # Input mode None, like the overlay: keys still reach the input router.
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 1001, InputMode := ui_input_mode.None})
            set MaybeRoot = option{Root}
            set MaybePlayerUI = option{PlayerUI}

    Hide():void =
        if (Root := MaybeRoot?, PlayerUI := MaybePlayerUI?):
            PlayerUI.RemoveWidget(Root)
        set MaybeRoot = false
