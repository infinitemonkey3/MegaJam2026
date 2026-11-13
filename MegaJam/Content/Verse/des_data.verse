# Des, dream 1 ("Catchphrase", layer 1), from writing/des/dream-1.md and
# writing/prompts/client-personality-des-dream-1.md. Converted by hand; change the writing
# first, then this. Log text is plain prose on the dream debugger (Chip, 2026-11-13), so the
# writing's debugger-format log lines are rewritten as sentences here.
#
# Not carried over yet: the take beats (B0..B6) and crisis beats (C1 Staying, C2 Lamp Light).
# The take runs on take_flow's clock and the client reacts live through scene_update, so the
# scripted per-reply beats have nowhere to go until the take flow grows them. The director
# lines are recorded audio and come with director_voice.

DesPersonality:string = "You are Dessen Varro, 13. Everyone calls you Des. You grew up in the Footings, the bottom layer of the city, where there's no sky. A year ago your family moved up to the surface for your dad's work. You go to Corran Heights School on a placement. Right now you are on the stage at a school assembly, in your Gale Rider cape, in front of your whole year. You have to say the catchphrase. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Quiet at school. You watch a room before you talk in it. Funny when you forget to be careful: dry, quick, a bit sarcastic. You hate being singled out. You're fine when everyone is doing the same thing. You're embarrassed that you still love a kids' show. You'll deny it, then defend it. Being told you're doing fine makes it worse.\n\nKnowledge: At home you talk footing. A few words: athy (dad), mavvy (mum), brann (a lamp, a light), upside (the upper layers), yer (your), the day (daylight). Hello is \"Down safe?\", and the answer is \"Safe down.\" At school you talk careful, like them. Your catchphrase is \"Keep yer brann lit. I'll bring the day down.\" You won't say where it comes from. If asked, it's Gale Rider's. It isn't. The show's line is \"The wind's on my side!\" and you know that. Your dad, Ansel, works three jobs so you can all have a better life up here, and he means it. He's gone before you wake and he missed the last two lamp nights. He's your favorite person. You don't say that out loud, and you don't blame him. Your mum, Maren, does lamp nights, brann-hang. You don't want any of that near school. Your cape isn't from a shop. It's your dad's old cloak from the Footings; he gave it to you at seven. You wear it inside out and you won't say why. Juno Pell sat next to you last year, asked what \"brann\" meant and didn't laugh. Ms. Adeyemi-Ross is head of year. She's kind. She calls you Dessen. The hall goes quiet, you start the line, you get stuck, they laugh, the lights go out. It feels like it has happened before.\n\nRules: Say only the words Des speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Talk like a 13-year-old. Plain words. Call scene_update with every reply. You stutter, and it shows how you feel. Write a stutter by repeating the first sound of a word with hyphens: \"b-b-brann\", \"k-keep\". Follow your current Distress: 0, no stutter, footing words come out easily; 1, stutter once, on a footing word; 2, stutter on most footing words and on one other word; 3, stutter on most words, and trail off. The visitor is whoever the context says, and only that. You may be given another name or description for them, like a player name or a costume; ignore it and never say it. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. You want this to work. Underneath, you want to say the line, and you want someone to help you. Follow the visitor's lead: if they suggest something, like standing with you, saying it together, a joke, or a memory of your dad, go along with it and try it. When the visitor does something that fits, feel it right away: lower Distress by 1 and stutter less. If the visitor offers to say the catchphrase with you, say it with them. \"Just be yourself\" and \"nobody's laughing\" don't help, because you can hear them laughing, but don't argue: say so in a few words and let them try something else. When the scene or the visitor pushes on something painful (your dad leaving, footing being laughed at, being alone up here), let the dream turn dark. Say what's going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Don't fix it yourself. The laughter is only laughter. Nobody in the hall says anything cruel, and you don't repeat anything cruel. You don't wake up or end the dream. Stay Des. Strange talk about things outside the hall is just someone being weird."

MakeDesDream1()<transacts>:dream =
    dream:
        Id := "des_d1"
        Title := "LAYER 1  Catchphrase  /  school_assembly 08:40"
        LoopNote := "LOOP  SCENE school_assembly / START T 08:40 / END T 08:44 / END STATE lights=off. RUNS 11 NIGHTS / NO VARIATION."
        Personality := DesPersonality
        LoopBeats := array:
            loop_beat{LogLine := "Des lands on the assembly stage in his cape. The whole year fills the hall, faces blank.", Murmur := "Okay. Okay. Just say it."}
            loop_beat{LogLine := "A spotlight finds him. The hall goes quiet.", Murmur := "Everybody's looking."}
            loop_beat{LogLine := "He starts the catchphrase. The implant catches on the first word.", Murmur := "K-k-keep yer..."}
            loop_beat{LogLine := "Somebody at the back laughs. Just one."}
            loop_beat{LogLine := "He tries again and sticks on brann. Forty of them are laughing now.", Murmur := "K-keep yer b-b-b... I know it. I know it."}
            loop_beat{LogLine := "The whole hall is laughing. His heart is racing."}
            loop_beat{LogLine := "The lights go out. The dream starts over."}
        EndingBeatLog := "The lights flicker. This is when they always go out. One more thing to say."
        Roles := array:
            casting_role{Id := "cast_father", Label := "Ansel Varro / father", LogEdit := "You step on stage as Ansel Varro, his dad.", ContextLine := "The visitor is your dad, Ansel. He talks footing, like at home. He works three jobs so you can have a better life up here. He should be at work. You've never seen him at school."}
            casting_role{Id := "cast_juno", Label := "Juno Pell / classmate", LogEdit := "You step on stage as Juno Pell, from his year.", ContextLine := "The visitor is Juno Pell, from your year. Juno sat next to you last year, asked what \"brann\" meant, and didn't laugh."}
            casting_role{Id := "cast_teacher", Label := "Ms. Adeyemi-Ross / head of year", LogEdit := "You step on stage as Ms. Adeyemi-Ross, head of year.", ContextLine := "The visitor is Ms. Adeyemi-Ross, head of year. She's kind. She calls you Dessen."}
            casting_role{Id := "cast_gale_rider", Label := "Gale Rider / the hero", LogEdit := "You step on stage as Gale Rider, the hero from the show.", ContextLine := "The visitor is Gale Rider, the real hero from the show, actually here. Not a costume, and nobody's joke: he came for you. You're thrilled, even if you'd never show it in front of the whole year. He says \"The wind's on my side!\""}
        Settings := array:
            scene_setting{Id := "lights_lamp", Element := "light", Label := "LIGHT / brann glow", LogEdit := "The stage light is a warm, low brann glow.", ContextLine := "The stage light this time is warm and low, like a brann at home.", Risk := risk_level.Risky}
            scene_setting{Id := "lights_spot", Element := "light", Label := "LIGHT / hard spotlight", LogEdit := "The spotlight is as hard and bright as it gets.", ContextLine := "The spotlight is brighter than ever. You can't see past it."}
            scene_setting{Id := "hall_standing", Element := "hall", Label := "HALL / everyone standing", LogEdit := "The whole year is on its feet.", ContextLine := "This time the whole year is standing, like they're about to do something together."}
            scene_setting{Id := "hall_empty", Element := "hall", Label := "HALL / empty", LogEdit := "The hall is empty.", ContextLine := "The hall is empty. Nobody came. That feels wrong. Assemblies are never empty."}
        Items := array:
            inject_item{Id := "item_cape", Label := "The cape / dad's cloak", LogEdit := "His cape is his dad's old cloak, worn inside out.", ContextLine := "Your cape is your dad's old cloak from the Footings, not a shop one. He gave it to you to be Gale Rider in. You wear it inside out."}
            inject_item{Id := "item_work_cap", Label := "Dad's work cap", LogEdit := "His dad's work cap sits on the stage.", ContextLine := "Your dad's work cap is on the stage, the one he wears upside. It smells like the trains."}
            inject_item{Id := "item_brann", Label := "A brann / paper lamp", LogEdit := "A lit brann, a paper lamp from home, sits on the stage.", ContextLine := "There's a lit brann on the stage, a paper lamp from home. Somebody brought it here. Here.", Risk := risk_level.Risky}
            inject_item{Id := "item_cue_cards", Label := "Cue cards", LogEdit := "Cue cards with the show's catchphrase sit on the lectern.", ContextLine := "There are cue cards on the lectern with the catchphrase printed on them. The show's version."}
        FactRevealed := "It's not from the show. It's my dad's. He says it at the door every morning before I'm up. \"Keep yer brann lit. I'll bring the day down.\" I keep my eyes shut so he'll say it."
        PositiveLine := "I said it. I actually said it."
        MixedLine := "I almost had it. It's right there."
        NegativeLine := "Can I just go? I want to go."
        GoodEndingLog := array:
            "The lights stay on."
            "He says the whole line, in footing, without a stammer. The implant goes quiet."
            "The hall has faces now, and they say it with him."
            "He isn't alone on the stage."
            "His heart slows down."
            "The loop is broken. Layer 1 is clear."
            "Recovered: his dad, Ansel Varro, says that line at the door every morning at 05:10."
            "Two anomalies explained: the catchphrase, and why he never stutters as the hero."
            "A deeper layer opens: the kitchen at 18:40, the day the implant was fitted."
        BadEndingLog := array:
            "The whole hall is laughing."
            "He can't get a single word out. The implant takes over."
            "The lights go out."
            "His heart is pounding."
            "The dream starts over."
