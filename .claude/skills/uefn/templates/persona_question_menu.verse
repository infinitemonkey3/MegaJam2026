using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Conversations }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Chat }
using { /Verse.org/Simulation }

question_menu_log := class(log_channel){}

# One preset question: the button label and the instructions sent to the persona.
persona_question := class:
    Label:message
    Prompt:message

# Opens a menu of preset questions when a player uses TalkButton.
# Picking one makes the player's current conversation target (set by persona_npc_behavior) answer out loud.
persona_question_menu := class(creative_device):
    Logger:log = log{Channel := question_menu_log}

    @editable
    TalkButton:button_device = button_device{}

    TitleText<localizes>:message = "Ask Barnaby..."
    CloseText<localizes>:message = "Never mind"
    NoTargetText<localizes>:message = "Barnaby isn't listening right now."

    Q1Label<localizes>:message = "Tell me about the sunken ship."
    Q1Prompt<localizes>:message = "The player asks you: \"Tell me about the sunken ship.\" Answer in character."
    Q2Label<localizes>:message = "What's it like living here?"
    Q2Prompt<localizes>:message = "The player asks you: \"What's it like living in the lighthouse?\" Answer in character."
    Q3Label<localizes>:message = "Any advice for a traveler?"
    Q3Prompt<localizes>:message = "The player asks you: \"Do you have any advice for a traveler like me?\" Answer in character."
    GreetPrompt<localizes>:message = "The player has walked up to you and waved hello. Greet them in character."

    var OpenMenus:[player]canvas = map{}

    OnBegin<override>()<suspends>:void =
        TalkButton.InteractedWithEvent.Subscribe(OnTalkButton)

    Questions()<transacts>:[]persona_question =
        array:
            persona_question{Label := Q1Label, Prompt := Q1Prompt}
            persona_question{Label := Q2Label, Prompt := Q2Prompt}
            persona_question{Label := Q3Label, Prompt := Q3Prompt}

    OnTalkButton(Agent:agent):void =
        if (Player := player[Agent]):
            if (Player.GetConversationTarget[]):
                # Have Barnaby greet the player, then show the menu.
                AskPersona(Player, GreetPrompt)
                OpenMenu(Player)
            else:
                Logger.Print("Player has no conversation target yet", ?Level := log_level.Warning)

    OpenMenu(Player:player):void =
        CloseMenu(Player)
        if (PlayerUI := GetPlayerUI[Player]):
            Stack := stack_box{Orientation := orientation.Vertical}
            Stack.AddWidget(stack_box_slot{Widget := text_block{DefaultText := TitleText}, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 12.0}})
            for (Question : Questions()):
                Button := button_regular{DefaultText := Question.Label}
                Button.OnClick().Subscribe(question_handler{Menu := Self, Question := Question}.OnClick)
                Stack.AddWidget(stack_box_slot{Widget := Button, HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 4.0, Bottom := 4.0}})
            Close := button_quiet{DefaultText := CloseText}
            Close.OnClick().Subscribe(OnCloseClicked)
            Stack.AddWidget(stack_box_slot{Widget := Close, HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 12.0}})

            Menu := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := Stack
            PlayerUI.AddWidget(Menu, player_ui_slot{InputMode := ui_input_mode.All})
            if (set OpenMenus[Player] = Menu) {}

    CloseMenu(Player:player):void =
        if (Menu := OpenMenus[Player], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(Menu)
        var Remaining:[player]canvas = map{}
        for (Key -> Value : OpenMenus, Key <> Player):
            set Remaining = ConcatenateMaps(Remaining, map{Key => Value})
        set OpenMenus = Remaining

    OnCloseClicked(Message:widget_message):void =
        CloseMenu(Message.Player)

    OnQuestionClicked(Player:player, Question:persona_question):void =
        CloseMenu(Player)
        AskPersona(Player, Question.Prompt)

    AskPersona(Player:player, Prompt:message):void =
        if:
            Target := Player.GetConversationTarget[]
            Persona := Target(0)
            Channel := Target(1)
            Persona.PromptToTalk[Prompt, Channel]
        then:
            Logger.Print("Sent preset question to persona")
        else:
            Logger.Print("Persona did not accept the prompt (busy, or no channel)", ?Level := log_level.Warning)

# Binds a button click to the question it represents.
question_handler := class:
    Menu:persona_question_menu
    Question:persona_question

    OnClick(Message:widget_message):void =
        Menu.OnQuestionClicked(Message.Player, Question)
