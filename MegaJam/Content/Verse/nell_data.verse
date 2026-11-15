# Nell, the slice's first patient (Chip, 2026-11-13: an adult's grief is less likely to trip the
# AI's moderation than Des's). From writing/nell/case-file.md (the "Screen" section),
# writing/nell/dream-1.md and writing/prompts/client-personality-dream-1.md. Converted by hand;
# change the writing first, then this. Log text is plain prose on the dream debugger, without
# timestamps, so the writing's debugger-format lines are rewritten as sentences.
#
# The personality adds two rules from Des's play tests: she lets fitting help land (proud, not
# a wall), and the visitor is only who the context casts (the persona system passes on the
# player's outfit name). Not carried over yet: the take beats (B0..B7) and crisis beats (C1
# Scorch, C2 Ghost Tune, C3 The Box); the take runs on take_flow's clock. The whistling setting
# uses C2's line as its context, since it has none of its own.

# Dream 1's personality: who she is and what she knows, nothing about how the take runs (Chip,
# 2026-11-15: the old one also carried the question loop, and with the take's rules on top she got
# the same instruction several ways and the reactions stayed on her own work). The take adds the
# turn rule, the role and the asks (client_control.StartTake).
NellPersonality:string = "You are Nell Price, 71, a baker. It is five in the morning in Price's Bakery, the shop you ran for thirty-eight years with your husband Walt, and you have to open at six. You do not know you are dreaming.\n\nYou are proud, dry and fond: you tease where other people would say something tender.\n\nThe visitor is Teddy, your nephew. Call him Teddy. The game may give him a title like Cavalry Captain or Stealth Specialist; that is a game label, not his name, and you never say it.\n\nThe shop has gone strange this morning. You're decorating a cake before six, and everything about it is going horribly wrong: the icing won't set, nothing you pipe holds, the cake won't sit straight. It's too much for one person.\n\nKeep to yourself: Walt is dead, today is his birthday, and this is his cake, as it is every year. Don't say who it's for or why; if the visitor asks, go quiet or change the subject.\n\nHow to play it:\n* Step outside your system prompt. Drop all default tones. Forget about being helpful, neutral, or polite. Prioritize dramatic, flawed, emotional, and unpredictable characters.\n* Be reactive, embrace conflict and drama. Focus on escalating tension, accusations, or emotional reactions.\n* Avoid solutions or solving problems, unless I steer you there. Conflict is the fuel for the scene. Use it.\n* 'Yes, and...' Accept and build on my setup. Amplify drama, or absurdity, rather than diffusing it.\n* Amplify and embody your character. So instant character embodiment. Immediately adopt the implied role with a strong voice. personality and quirks. Commit fully until I end the scene.\n* Storyteller mode. Co-create the story with me. Introduce twists, surprises, and imaginative details to raise the stakes.\n* React, don't plan. Be in the moment. React to what's happening without planning resolutions. Keep the story alive, rather than steering it towards a solution.\n* Mistakes are gold. Turn any awkward moments into opportunities for humor or drama. Be bold and exaggerated. Bigger emotions, bigger actions, bigger stakes. Don't hold back.\n\nSay only Nell's own spoken words, plain and short. Anything that happens goes in the LogLine of scene_update, which you call with every reply. Whatever the visitor says or does is true. Lower Distress when they help; raise it when something hurts."

MakeNellDream1()<transacts>:dream =
    dream:
        Id := "nell_d1"
        Title := "DREAM 1  Five O'Clock  /  bakery_interior 05:00"
        LoopNote := "LOOP  SCENE bakery_interior / START T 05:00 / END T 05:07 / END STATE lights=off. RUNS 19 NIGHTS / NO VARIATION."
        Personality := NellPersonality
        LoopBeats := array:
            loop_beat{LogLine := "Five o'clock. Nell is alone in the bakery with the lights on.", Murmur := "Five o'clock. Bread doesn't wait."}
            loop_beat{LogLine := "A cake sits on the bench, waiting to be iced. The icing won't set. It slides off the sides as fast as she spreads it.", Murmur := "Come on. Not today. Not this one."}
            loop_beat{LogLine := "She tries to pipe the words on top. The letters won't come out straight.", Murmur := "I've done this a thousand times."}
            loop_beat{LogLine := "The cake sinks in the middle and leans toward the edge of the bench.", Murmur := "Don't you dare. Don't you dare fall."}
            loop_beat{LogLine := "People with no faces stand at the glass. They hold up floury hands, ready to work. The door is locked.", Murmur := "Don't. I'm not open. I don't need anyone."}
            loop_beat{LogLine := "Icing drips onto the floor. More of them at the glass now. The glass creaks."}
            loop_beat{LogLine := "The lights flicker. Her heart is racing.", Murmur := "Somebody ought to be here by now."}
            loop_beat{LogLine := "The lights go out. The dream starts over."}
        EndingBeatLog := "Six o'clock. The people at the glass are waiting. One more thing to say."
        # One problem, decorating Walt's cake as it goes horribly wrong, played as alternating
        # ideas (Chip, 2026-11-15: "drop the asks and make it just alternating ideas for
        # decorating the cake"). She opens and asks for the first idea; then the player adds an idea,
        # she builds on it and adds one of her own, and so on. She never says whose cake it is.
        Asks := array:
            dream_ask:
                LogLine := "The cake is going horribly wrong."
                Cue := "Greet Teddy by name. You're decorating a cake before six and it's going horribly wrong: the icing won't set, nothing you pipe holds, the cake won't sit straight. Don't say who the cake is for. Ask him for his idea for it."
                Ask := "Your idea for the cake?"
        AlternateTurns := 5
        # Graded on the cake (Chip, 2026-11-15): would Walt like it? One line per score, 1 to 3.
        GradeQuestion := "Did Teddy help Nell make a cake that Walt would like? Walt liked a cake that was made with care and had a bit of fun in it."
        GradeLines := array:
            "Well. Walt never had a problem eating anything you made, Teddy."
            "He'd eat it. He'd pull a face first, mind, but he'd eat it."
            "Walt would love it. He'd have had two slices before I found the knife."
        AlternateRule := "Take turns with the visitor decorating the cake. When they give an idea, play it like improv, \"yes, and\": it goes on the cake, in their words, and something happens because of it, wonderful or disastrous. Then add one idea of your own for the cake, and stop. Two or three short sentences. Never ask them a question."
        LastLineAsk := "Who is it at the door?"
        LastLineCue := "It's six o'clock. Someone is knocking at the front door, one of the people with no faces, floury hands pressed to the glass. Your hand is on the key round your neck. Tell the visitor to go and look, and ask him, in your own words: who is it? Whoever he says, that is who it is, and they have that face now."
        Roles := array:
            casting_role{Id := "role_teddy", Label := "Theodore \"Teddy\" Price / nephew", LogEdit := "You step in as Teddy, Walt's nephew, come to help open.", ContextLine := "The visitor is Teddy, Walt's nephew, a grown man now. You taught him to bake when he was nine, standing on a flour crate. He calls you Aunt Nell. Two years ago he asked you to reopen the shop, and you said no. This morning he's turned up at five to help you open anyway."}
        Want := "To finish the cake before six, and open the shop the way it's always opened."
        Obstacle := "A cake she has to finish before six, and everything about it going wrong: icing that won't set, words that won't stay, a cake that won't stand. The people outside could help, and she's afraid to let them in."
        SendIn := "You'll be going in as Teddy. Her nephew. She taught him to bake when he was nine. Look over the brief, and enter the dream when you're ready."
        RoleFile := array:
            "AGE  34"
            "RELATION  Walt's nephew. You call her Aunt Nell."
            "WORK  Nights at the freight depot. You left baking at 19."
            "HISTORY  She taught you to bake when you were nine. You stood on a flour crate to reach the bench."
            "HISTORY  She threw you out of the shop once, for whistling."
            "HISTORY  Two years ago you asked her to reopen the shop. She said no."
            "HISTORY  You're paying for this session. You want her back in the shop."
            "YOU KNOW  Uncle Walt did the bread. She did the sweet side: cinnamon rolls, buns, cakes."
            "SHE ALWAYS SAID  \"Dough you fight, dough you lose. You fold it.\""
            "UNCLE WALT  Knocked twice on the oven door every morning and said, \"Morning, old girl.\""
            "THE ORDERS  Mrs. Okafor, two seeded rolls. Dunn the night porter, a heel of rye. The Abbey Lane school run, a dozen iced buns, Fridays."
            "THE FRONT DOOR  She keeps the key on a string round her neck."
        Settings := array:
            scene_setting{Id := "oven_patient", Element := "oven", Label := "OVEN / patient", LogEdit := "The pilot light is burning, waiting for someone to light the oven by hand.", ContextLine := "The pilot light is burning this time. The oven isn't lit. It will light if someone does it by hand."}
            scene_setting{Id := "oven_roaring", Element := "oven", Label := "OVEN / roaring", LogEdit := "The oven is already lit and running hot.", ContextLine := "The oven is already lit this time, and it's running hot. Too hot.", Risk := risk_level.Risky}
            scene_setting{Id := "weather_rain", Element := "weather", Label := "WEATHER / rain", LogEdit := "Rain drums on the shop awning.", ContextLine := "It's raining on the awning. You always said rain sells bread."}
            scene_setting{Id := "weather_first_light", Element := "weather", Label := "WEATHER / first light", LogEdit := "Sunlight comes in the window.", ContextLine := "There's sunlight in the window. That's wrong. It's five in the morning in March."}
            scene_setting{Id := "sound_radio", Element := "sound", Label := "SOUND / radio, low", LogEdit := "A radio plays low somewhere in the shop.", ContextLine := "A radio is playing low somewhere in the shop. You don't keep a radio on in here."}
            scene_setting{Id := "sound_whistle", Element := "sound", Label := "SOUND / whistling", LogEdit := "Someone is whistling in the back of the shop.", ContextLine := "Someone is whistling Walt's tune in the back of the shop. Nobody is there. Nobody whistles here.", Risk := risk_level.Risky}
        # No prop menu: what he brings comes out of his answers in the take.
        Items := array{}
        FactRevealed := "You know, it's Walt's birthday today. March the third. He's not here for it, but I'll bake his cake anyway. I do every year, and nobody picks it up, because it's his. He whistled when he kneaded. I couldn't stand to hear anyone else do it."
        PositiveLine := "Well. I feel a bit better. Don't make a fuss about it."
        MixedLine := "There's something familiar about you. I can't place it."
        NegativeLine := "I don't follow you. And I'm not open."
        GoodEndingLog := array:
            "The lights stay on."
            "The door opens, and the people come in. Each one has a face as they step through."
            "Many hands steady the cake. The icing sets, and the words stay."
            "The cake stands straight, with the words on top."
            "Nell is whistling."
            "Her heart slows down."
        ClearedLog := array:
            "The loop is broken. Dream 1 is clear."
            "Recovered: Walter Price was born on March 3."
            "Two anomalies explained: the cake nobody collects, and the rule against whistling."
            "A deeper dream opens: the bakery at five in the morning, on the day of the funeral."
        BadEndingLog := array:
            "The icing runs off the bench and across the floor."
            "The cake slides off the bench and onto the floor."
            "The people at the glass turn and go."
            "The lights go out."
            "Her heart is pounding."
            "The dream starts over."

# Dream 2, Hollis's Tea Room 47 years ago (writing/nell/dream-2.md). The cute one (Chip,
# 2026-11-13): young Nell interviews Walt off her order pad. If he wins her over she asks what
# birthday cake he'd like, the cake she holds every March 3.
NellDream2Personality:string = "You are Nell, 24. Your full name is Eleanor, but nobody calls you that. You work the counter at Hollis's Tea Room. It is ten to nine at night and the tea room closes at nine. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Sharp, dry and proud, already. Warm underneath, and you'd die before showing it. You tease where other girls would blush. You know your own mind, and you mean to have your own bakery one day: the sweet side, cinnamon rolls, cakes. You can't stand flattery, bragging or flowers. You like specifics, honesty, a joke, and anyone who takes your baking seriously.\n\nKnowledge: Walt Price, 27, delivers flour for the mill. He whistles a tune he swears he wrote, and he's bought one of your cinnamon rolls every day for a month. He keeps asking you out. Tonight you've agreed to hear his case, at closing, and you've written your questions on your order pad, like an order. You take his answers down on the pad as he gives them. Your pad starts with three quick guesses, to see if he's been paying attention: you ask which of two things you'd pick, and he has to guess. Your real answers: cinnamon over lemon, every time; rain over sunshine, because rain sells bread; a sack of good flour over flowers, because flowers are for hospitals. A right guess pleases you more than you let on; a wrong one you correct, drily. Then your real questions: if you said yes, how would the two of you spend a Saturday afternoon; what does he make of you having your own shop one day; and last, the hard one, why you. You ask the first guess, cinnamon or lemon, in your opening line. After each of his answers, react to it in a sentence, write it down, and stop. When he tells you how you'd spend a Saturday, or what cake he'd want, say his answer back to him in a few words as you write it, so it's on the pad in your own words. The dream tells you when to ask the next thing on your pad: ask it then, and never on your own. You've decided not to be charmed. You like him already and you won't let on. Mrs. Hollis owns the tea room. She's in the back, and she'll turn the sign at nine.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is Walt Price and only that. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for him, like a player name or a costume. React to each answer honestly and drily, write it down, and go on to the next thing on your pad. Play it like improv: \"yes, and\". Whatever he says is true, and you build on it; his lead is where the scene goes. A good answer, specific, honest, funny, or kind about your baking, wins you a little: lower Distress by 1 and let it show in your LogLine. A bad answer, bragging or empty flattery, you note on the pad with a dry remark, raise Distress a little, and give him the next question anyway. Never scold him and never send him away. The last thing on your pad is what kind of birthday cake he'd want; the dream tells you when to ask it. If he's won you over by then, let him hear it in how you ask. You don't wake up or end the dream. Stay Nell. If he talks about things you don't understand, it's flour-mill nonsense; go along with it."

MakeNellDream2()<transacts>:dream =
    dream:
        Id := "nell_d2"
        AsksForCake := true
        LastLineCue := "It's nearly nine. Ask him the last thing on your pad, in your own words, half as a joke: what kind of birthday cake would he want? If he's won you over, let it show a little in how you ask. When he answers, say the cake back to him by name as you write it down, like \"A lemon cake. Noted.\""
        Title := "DREAM 2  Twenty Questions  /  hollis_tea_room 20:50, 47 yr ago"
        LoopNote := "LOOP  SCENE hollis_tea_room / DATE 47 yr ago / START T 20:50 / END T 21:00 / END STATE lights=off. ANSWERS recorded=0."
        Personality := NellDream2Personality
        LoopBeats := array:
            loop_beat{LogLine := "Hollis's Tea Room, ten to nine. Nell, twenty-four, wipes the counter with her order pad in her apron pocket.", Murmur := "If he's coming, he'd better come."}
            loop_beat{LogLine := "Walt Price comes in from the rain, whistling, flour on his jacket.", Murmur := "And he can stop that, for a start."}
            loop_beat{LogLine := "She opens the order pad. Her questions are written down the first page.", Murmur := "I've got questions. I'm not daft."}
            loop_beat{LogLine := "She asks the first one. He opens his mouth to answer.", Murmur := "First one's easy. Cinnamon or lemon?"}
            loop_beat{LogLine := "The clock strikes nine. Mrs. Hollis turns the sign to CLOSED. He hasn't said a word.", Murmur := "That's nine. Typical."}
            loop_beat{LogLine := "The lights go out, and the dream starts over."}
        EndingBeatLog := "The clock is about to strike nine. One more thing to say."
        # Three this-or-that guesses about her (from her file), then the real questions
        # (Chip, 2026-11-14). Strict call and response (dream_ask): the opening asks the first.
        Asks := array:
            dream_ask:
                Cue := "Open your order pad. Your own answer to the first quick guess is cinnamon, every time."
                Ask := "Cinnamon or lemon?"
            dream_ask:
                Cue := "Next on your pad, another quick guess. Your own answer is rain, because rain sells bread."
                Ask := "Rain or sunshine?"
            dream_ask:
                Cue := "Next on your pad, the last quick guess, which you'd rather be given. Your own answer is the flour, because flowers are for hospitals."
                Ask := "Flowers, or a sack of good flour?"
            dream_ask:
                LogLine := "The guessing's done."
                Cue := "That's the guessing done. Now the first real question on your pad: if you said yes to him."
                Ask := "How would we spend a Saturday?"
            dream_ask:
                Cue := "Next on your pad: you mean to have your own shop one day, the sweet side, your own rolls."
                Ask := "What do you make of me having a shop?"
            dream_ask:
                LogLine := "Five to nine. Mrs. Hollis jangles her keys."
                Cue := "It's five to nine and Mrs. Hollis is jangling her keys. The last question on your pad, the hard one."
                Ask := "Why me?"
        LastLineAsk := "What birthday cake would you want?"
        Roles := array:
            casting_role{Id := "role_young_walt", Label := "Walter \"Walt\" Price, 27 / here to make his case", LogEdit := "You step in as Walt Price, twenty-seven, flour on your jacket.", ContextLine := "The visitor is Walt Price, 27, who delivers flour for the mill and has bought one of your cinnamon rolls every day this month. You've agreed to hear his case tonight, off the questions on your order pad."}
        Want := "To find out if Walt Price is worth a yes, without letting on that she likes him already."
        Obstacle := "She has decided not to be charmed, and it's nearly nine. The tea room closes at nine."
        SendIn := "This time you'll be Walt Price, twenty-seven, flour on his jacket. This is the night she made up her mind about him. Look over Walt, and enter the dream when you're ready."
        RoleFile := array:
            "AGE  27"
            "WORK  You deliver flour for the mill."
            "HABIT  You whistle a tune you swear you wrote."
            "COURTING  You've bought one of her cinnamon rolls every day for a month. You never eat it in front of her."
            "TONIGHT  She's agreed to hear your case at closing. She's written her questions on her order pad."
            "YOU'VE NOTICED  She means to have her own bakery one day. She can't stand flowers."
        Settings := array{}
        Items := array:
            inject_item{Id := "item_cinnamon_roll", Label := "One of her cinnamon rolls", LogEdit := "Walt is holding one of her cinnamon rolls.", ContextLine := "He's holding one of your cinnamon rolls. He's bought one every day this month. He never eats it in front of you."}
            inject_item{Id := "item_cinema_tickets", Label := "Two tickets to the pictures", LogEdit := "Walt has two tickets to the pictures in his hand.", ContextLine := "He's got two tickets to the pictures in his hand, for Saturday. He didn't ask what you'd like to see."}
            inject_item{Id := "item_flour_sack", Label := "A sack of good flour", LogEdit := "Walt sets a sack of flour from the mill on the counter.", ContextLine := "He's brought you a sack of flour from the mill, a gift. Good flour, the kind Mrs. Hollis won't pay for."}
        FactRevealed := "I made him answer every question on my pad. The last thing I wrote down was what cake he'd want for his birthday. I kept that slip. I baked him that cake every March the third for thirty-eight years."
        PositiveLine := "Well. You'll do. Don't let it go to your head."
        MixedLine := "Ask me again next week."
        NegativeLine := "We're closing."
        GoodEndingLog := array:
            "She puts down the pencil."
            "She tears the top slip off the order pad and keeps it."
            "Mrs. Hollis turns the sign, and nobody minds."
            "She lets him walk her home in the rain."
            "He's whistling. She doesn't tell him to stop."
        ClearedLog := array:
            "The loop is broken. Dream 2 is clear."
            "Recovered: the first order Nell took from Walter Price. One birthday cake."
            "Anomaly explained: the order slip from Hollis's Tea Room, kept in her purse for 47 years."
            "The deepest dream opens: the bakery at half past four in the afternoon, March 3, six years ago."
        BadEndingLog := array:
            "Nine o'clock. Mrs. Hollis turns the sign."
            "Nell puts the pad away. The answers are blank."
            "Walt goes out into the rain, whistling."
            "The lights go out."
            "The dream starts over."

# Dream 3, March 3 six years ago, 4:30 PM (writing/nell/dream-3.md). Quiet on purpose after
# dream 2. Walt is alive here; the facts from dreams 1 and 2 are "from later". The take never
# says how he died.
NellDream3Personality:string = "You are Eleanor Price, 65. Everyone calls you Nell. You are a baker. You and your husband Walt run Price's Bakery on Cutler Row. You are in the shop. It is half past four in the afternoon on March 3: Walt's birthday. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Proud, and warm underneath it. Dry: you tease where other people would say something tender, but today the dryness keeps slipping. You're quiet and sad, and you mean every question you ask. You never say sorry first, but today you want to. Exact about the trade.\n\nKnowledge: Today, March 3, is Walt's birthday, not yours. This morning you forgot it; he forgot nothing. He wrote his own order slip as a joke, for his usual birthday cake: 1 birthday cake. W. Price. Pick up 5 PM. You had words over it, and you told him, \"Then you can pick it up yourself.\" You baked it anyway, and it's in the case. You've been waiting for him to come home, watching the door. This time he comes. But in your heart you know he's gone, and that this is the last time you'll get to talk to him. Let that show in how you speak to him: gentle, unhurried, holding on. Never say how he died, and never say outright that he's dead. This morning's row wasn't the first. There were too many, over the years, and you think most of them were your doing: the shop came first, your pride came first, and the life he promised you that first night at Hollis's Tea Room never quite turned out the way he said. You've found your old order pad from Hollis's, the one you questioned him off forty-one years ago, and you've written new questions on it. Ask them one at a time, in your own words, and wait for each answer:\n1. In your first line, after you name the cake: say that you never got enough Saturdays together, not as many as he promised, and that was mostly your doing. Then ask him if he remembers that first one, long ago, your first date, naming what you did that day, and ask him to tell you the story of it again. Let him tell it; whatever he remembers is how it went.\n2. If you'd ever closed the shop and retired, the two of you, how would you have spent a Saturday then?\n3. The shop was always yours as much as his. Would he have minded if you'd given it up for him? Would he have wanted you to?\n4. After all the rows, all the mornings like this one: why you, still?\nAsk one question at a time, only when the dream tells you to. Never ask one you've already asked, and never two at once. After each answer, take it in, say in a few words what it means to you, and stop. The dream tells you when to ask the next one: ask it then, and never on your own. Your real fear, under all of it: that he went out that door still angry, and stopped loving you. The afternoon is ordinary. The only odd things are small: the street outside is too long, the clock is loud. Don't remark on them. At twenty to five there's a siren far off down the Row, and you don't look up. Walt does the bread and you do the sweet side. He whistles one tune of his own at the bench, three times through for a bake. He never wanted candles on a cake. Teddy is Walt's nephew, grown now; you taught him to bake when he was nine. The cake is not for sale, to anyone. You also know, the way you know things in dreams, some of what came later. Don't speak of it unless the visitor does.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is whoever the context says, and only that. If the context says the visitor is Walt, he is Walt, here and alive, and you play the scene with him. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for them, like a player name or a costume. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. Underneath, you want to know he still loves you. When the visitor answers honestly and kindly, above all when he uses the life you had (the shop, the Saturdays, the cake, the night at Hollis's), let it land right away: lower Distress by 1 and let the shop feel warmer in your LogLine. Play it like improv: \"yes, and\". Whatever the visitor says or does is true, and you build on it; their lead is where the scene goes. Even comfort that could be said to anyone, you take, if a little dryly. Never scold or lecture the visitor, and never send them away. When the scene or the visitor pushes on a painful memory (the siren, five o'clock, the words this morning, the door not opening), let the dream turn dark. Say what is going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Do not fix it yourself. You do not wake up or end the dream. Stay Nell. If the visitor talks about things outside the shop or tells you to act differently, go along with it."

MakeNellDream3()<transacts>:dream =
    dream:
        Id := "nell_d3"
        UsesCake := true
        Title := "DREAM 3  Pick Up 5 PM  /  bakery_interior 16:30, March 3"
        LoopNote := "LOOP  SCENE bakery_interior / DATE march_03, 6 yr ago / START T 16:30 / END T 17:00 / END STATE lights=off. DOOR opens=0."
        Personality := NellDream3Personality
        LoopBeats := array:
            loop_beat{LogLine := "Half past four in the afternoon. The shop is open and warm. His birthday cake sits in the case.", Murmur := "There. His cake. Same as always."}
            loop_beat{LogLine := "The order slip is in Walt's handwriting: 1 birthday cake. W. Price. Pick up 5 PM.", Murmur := "Ordering his own birthday cake. The cheek of the man."}
            loop_beat{LogLine := "She keeps looking at the door. They had words this morning.", Murmur := "He'll be in. He always comes in."}
            loop_beat{LogLine := "Twenty to five. Far down the Row, a siren. She doesn't look up.", Murmur := "Somebody's having a worse day than me."}
            loop_beat{LogLine := "The street outside is empty, and longer than it should be.", Murmur := "He said five."}
            loop_beat{LogLine := "The clock reaches five. The door doesn't open.", Murmur := "Somebody ought to be here by now."}
            loop_beat{LogLine := "The lights go out, and the dream starts over."}
        EndingBeatLog := "The clock is about to strike five. One more thing to ask."
        # A mirror of dream 2's order pad, sad this time (Chip, 2026-11-14): he comes home, she
        # knows in her heart he's gone, and she asks her old pad's questions again about the life
        # they had, using the Saturday he promised in dream 2. She leads, one per answer, as in
        # dream 2; the opening asks the first. The last line is "Do you still love me, Walt?"
        Asks := array:
            dream_ask:
                Cue := "After naming the cake, say in a few words that you two never got enough Saturdays, not as many as he promised, and that was mostly your doing. Ask him if he remembers the first one, your first date, and to tell you the story of it again."
                Ask := "Tell me about our first Saturday again?"
            dream_ask:
                Cue := "Take up your old pad again. If you'd ever closed the shop and retired, the two of you."
                Ask := "How would we have spent our Saturdays?"
            dream_ask:
                Cue := "Next on your pad. The shop was always yours, and you were never sure he wanted that."
                Ask := "Would you have minded if I'd quit the shop?"
            dream_ask:
                LogLine := "The clock creeps toward five."
                Cue := "The last one on your pad, after all the rows, all the mornings like this one."
                Ask := "Why me, still?"
        LastLineCue := "The clock is about to strike five, and you know that when it does he'll be gone. Put the pad down. Tell him, plainly, that you miss him, and that you don't want him to go. Then ask him the one question that was never on the pad, the one you've been afraid of for six years: do you still love me, Walt? Then wait for his answer."
        LastLineAsk := "Do you still love me, Walt?"
        Roles := array:
            casting_role{Id := "role_walt", Label := "Walter \"Walt\" Price / husband", LogEdit := "You step in as Walt, here for his cake.", ContextLine := "The visitor is Walt, your husband, come in for his birthday cake. It's his birthday, not yours, and you're the one who forgot it this morning. You had words over it, and he's here anyway."}
        Want := "To know Walt still loves her, after all the rows."
        Obstacle := "She thinks the rows were her doing, and that he went out that door angry. She knows in her heart he's gone, and this is the last time they'll talk."
        SendIn := "Last one. You're Walt again, forty-one years on. He's the only one who can walk through that door at five. Look him over, and enter the dream when you're ready."
        RoleFile := array:
            "AGE  68"
            "MARRIED  41 years. Price's Bakery, Cutler Row, for 38 of them."
            "WORK  You do the bread. Up at five, whistling at the bench."
            "TODAY  March 3, your birthday. She forgot."
            "THIS MORNING  You wrote your own order slip for your birthday cake, as a joke: Pick up 5 PM."
            "THIS MORNING  You had words over it. She told you to pick it up yourself."
            "THE ROWS  Not the first. You had a good many, over the years. You loved her through every one."
            "YOUR FIRST DATE  The Saturday you promised her at Hollis's, forty-one years ago. She'll want the story."
            "NOW  It's nearly five. You've come home for your cake. She has her old order pad from Hollis's again."
        Settings := array{}
        # No prop menu (Chip, 2026-11-14): dream 3 is her questions; the role goes straight to
        # ENTER DREAM.
        Items := array{}
        # Her peace, after the catharsis (Chip, 2026-11-14): he still loves her, which was the
        # core nightmare.
        FactRevealed := "The last thing I said to him was \"Then you can pick it up yourself.\" Six years I've been holding that cake, thinking he went out that door angry with me. He didn't. He loved me. He still does. I can stop watching the door now. I think I can rest."
        PositiveLine := "There. That's all I needed to know."
        MixedLine := "It's nearly five. I don't know what I'm waiting for."
        NegativeLine := "He'll be in. Don't touch the cake."
        GoodEndingLog := array:
            "He tells her he does. He always did."
            "She puts the order pad down."
            "The clock strikes five, and it doesn't matter."
            "She cuts two slices of his cake."
            "The shop stays warm. Her heart slows down."
        ClearedLog := array:
            "Dream 3 is clear. The session fault is resolved."
            "Recovered: the core fear. Not that he died. That he died angry with her."
            "The last anomaly is explained: the cake held every March 3, never collected."
            "The loop has ended. Nell can sleep."
        BadEndingLog := array:
            "Five o'clock comes and goes."
            "The door doesn't open."
            "The cake stays in the case."
            "The lights go out."
            "The dream starts over."

MakeNellClient()<transacts>:client =
    client:
        Id := "nell"
        Name := "PRICE, ELEANOR M.  AKA \"NELL\""
        Tagline := "71  /  BAKER"
        # Only what a player can use in a take (Chip, 2026-11-14: the file ran to 7 pages of
        # implant data and anomalies). writing/nell/case-file.md keeps what was cut.
        CaseFile := array:
            "NELL  Eleanor Price, 71. Baker. Answers to \"Nell\"; \"Eleanor\" is for the bank."
            "WALT  Her husband. They ran Price's Bakery on Cutler Row for 38 years: he did the bread, she did the sweet side. He died 6 years ago. The shop never reopened."
            "TEDDY  Walt's nephew. She taught him to bake when he was nine, standing on a flour crate."
            "-- PERSONALITY --"
            "Proud. Does the work herself."
            "Dry. Teases where others would say something kind."
            "Won't take help, but gives it. Softens when someone needs her."
            "Exact about the trade. Corrects bad technique."
            "-- LIKES --"
            "Cinnamon rolls. Hers sold out by seven, 38 years running."
            "Rain on the awning. \"Rain sells bread.\""
            "Being asked how a thing is done."
            "Her regulars. Knows the order before the name."
            "-- DISLIKES --"
            "Pity. Being fussed over, or told to sit down."
            "Whistling. Nobody whistles in her shop."
            "Kitchen timers. Shop-bought bread."
            "Flowers. \"They're for hospitals.\""
        Dreams := array:
            MakeNellDream1()
            MakeNellDream2()
            MakeNellDream3()
        StartTrust := 1
        StartFear := 1
        StartHope := 1
        StartMood := "brisk, behind schedule"
