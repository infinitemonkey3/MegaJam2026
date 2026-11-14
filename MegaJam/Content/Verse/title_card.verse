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
    # The band the clouds drift in, as fractions of the screen height. M_TitleClouds' U tiling
    # (1.48) keeps the clouds' shape for a band this tall; change both together.
    CloudsTop:float = 0.0
    CloudsBottom:float = 0.30

    var MaybeRoot:?canvas = false
    var MaybePlayerUI:?player_ui = false
    var MaybePromptText:?text_block = false

    # Changes the prompt while the card is up (the player switched to a gamepad, say).
    SetPrompt(Prompt:message):void =
        if (PromptText := MaybePromptText?):
            PromptText.SetText(Prompt)

    Show(Player:player, Prompt:message):void =
        if (not MaybeRoot?, PlayerUI := GetPlayerUI[Player]):
            PromptText := text_block:
                DefaultText := Prompt
                DefaultTextColor := NamedColors.White
                DefaultTextSize := 26.0
                DefaultJustification := text_justification.Center
            # Three layers (Chip, 2026-11-14): the sky and street, clouds drifting across the top
            # (M_TitleClouds pans T_TitleClouds on the player's machine), and the wordmark over
            # them. art/tools/make_title_card.py writes the two image layers.
            Root := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                        Offsets := margin{}
                        Widget := texture_block{DefaultImage := TitleCard.T_TitleCard_Sky}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := CloudsTop}, Maximum := vector2{X := 1.0, Y := CloudsBottom}}
                        Offsets := margin{}
                        Widget := material_block{DefaultImage := TitleCard.M_TitleClouds{}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                        Offsets := margin{}
                        Widget := texture_block{DefaultImage := TitleCard.T_TitleCard_Wordmark}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := PromptY}, Maximum := vector2{X := 0.5, Y := PromptY}}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := PromptText
            # Input mode None, like the overlay: keys still reach the input router.
            PlayerUI.AddWidget(Root, player_ui_slot{ZOrder := 1001, InputMode := ui_input_mode.None})
            set MaybeRoot = option{Root}
            set MaybePlayerUI = option{PlayerUI}
            set MaybePromptText = option{PromptText}

    Hide():void =
        if (Root := MaybeRoot?, PlayerUI := MaybePlayerUI?):
            PlayerUI.RemoveWidget(Root)
        set MaybeRoot = false
        set MaybePromptText = false
