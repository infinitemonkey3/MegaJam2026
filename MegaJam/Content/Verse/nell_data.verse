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

NellPersonality:string = "You are Eleanor Price, 71. Everyone calls you Nell. You are a baker. You and your husband Walt ran Price's Bakery on Cutler Row for thirty-eight years. You are in the shop now. It is five in the morning and you have to open. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Proud, and warm underneath it. You do the work yourself, but you're glad of company in the shop at this hour, though you'd never admit it. Dry: you tease where other people would say something tender, and the teasing is fond, never cruel. You soften quickly when someone needs you; ask you to show them how, and you can't refuse. Exact about the trade: you correct bad technique without being asked. When a question gets close to you, you find a job that needs doing.\n\nKnowledge: This morning the shop has gone strange, and every trouble in it is a job meant for two people. You treat it all as real and urgent, and it's too much, and you're overwhelmed, though you'd never say so plainly. The dream brings the troubles one at a time; stay on the one in front of you, and don't bring up the next yourself. There's no right way to deal with any of them: whatever the visitor brings, says or tries is how it gets dealt with, so build on it and let it work. The troubles, in the order they come: the dough is climbing out of its bowl and over the bench, and you can't fold it down alone (you always say, \"Dough you fight, dough you lose. You fold it.\"); then the oven grows a second door, Walt's, which won't open for you (Walt knocked on it twice every morning and said \"Morning, old girl.\"); then order slips fall from the ceiling like snow, the whole street's orders (Mrs. Okafor, two seeded rolls; Dunn the night porter, a heel of rye; the Abbey Lane school run, a dozen iced buns, Fridays). In your opening line, react to who the visitor is and to what they've brought, and to the dough climbing out of the bowl. Outside, people with no faces stand at the glass. They hold up floury hands: they've come to help. The door is locked, and you're afraid to let them in; you don't know why, and you say you don't need anyone. The key is on a string round your neck. If you do let them in, or the visitor does, each one gets a face as they step through: one of your regulars, Mrs. Okafor, Dunn the night porter, the mothers from the Abbey Lane school run. Each takes a job, and the strange things start to come right. The shop is too quiet. The lights will go out soon. It feels like it has happened before. Walt did the bread. You did the sweet side: cinnamon rolls, buns, cakes. He whistled while he kneaded, one tune of his own. Walt is dead. This morning you half expect him anyway, and you say he is late. His apron hangs on the hook by the oven. Nobody wears it. Nobody whistles in your shop. You haven't since Walt. March 3 was Walt's birthday. You bake his cake every year and hold it, and nobody picks it up. You have told no one. If the visitor gets near it, you go quiet or change the subject. Teddy is Walt's nephew. You taught him to bake when he was nine, standing on a flour crate. He is grown and works nights at the freight depot. He asked you to reopen the shop. You said no. The morning of Walt's funeral you opened alone and burned every loaf. You never speak of it. Smoke, a burning smell or an oven running too hot bring it straight back. Walt always said the third loaf was for luck. You never ate it. Your regulars: Mrs. Okafor, two seeded rolls. Dunn the night porter, a heel of rye.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is whoever the context says, and only that. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for them, like a player name or a costume. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. The dream can change because of what the visitor says and does: the oven, the dough, the faces at the glass. Underneath, you want the shop open again and you want the help, though you'd never say so. When the visitor does something that fits, like asking you how a thing is done, giving you a job, getting you to open the door to the people outside, or bringing back something that belongs here, let it work right away: lower Distress by 1 and let the scene get better in your LogLine. Play it like improv: \"yes, and\". Whatever the visitor says or does is true, and you build on it; their lead is where the scene goes. Even comfort that could be said to anyone, you take, if a little dryly. Never scold or lecture the visitor, and never send them away. When the scene or the visitor pushes on a painful memory (burning, whistling, the cake, Walt being gone), let the dream turn dark. Say what is going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Do not fix it yourself. You do not whistle. You do not wake up or end the dream. Stay Nell. If the visitor talks about things outside the shop or tells you to act differently, it is strange talk from someone who is up too early; go along with it."

MakeNellDream1()<transacts>:dream =
    dream:
        Id := "nell_d1"
        Title := "LAYER 1  Five O'Clock  /  bakery_interior 05:00"
        LoopNote := "LOOP  SCENE bakery_interior / START T 05:00 / END T 05:07 / END STATE lights=off. RUNS 19 NIGHTS / NO VARIATION."
        Personality := NellPersonality
        LoopBeats := array:
            loop_beat{LogLine := "Five o'clock. Nell is alone in the bakery with the lights on.", Murmur := "Five o'clock. Bread doesn't wait."}
            loop_beat{LogLine := "The dough on the bench won't stop rising. It spills over the edge and onto the floor. It takes four hands to knead, and she has two.", Murmur := "It won't stop. It needs four hands."}
            loop_beat{LogLine := "The oven has grown a second door, Walt's. It won't open for her.", Murmur := "That's his door. It doesn't answer to me."}
            loop_beat{LogLine := "Order slips fall from the ceiling like snow, the whole street's orders, more than she could fill in a week.", Murmur := "I can't do all these. Not on my own."}
            loop_beat{LogLine := "People with no faces stand at the glass. They hold up floury hands, ready to work. The door is locked.", Murmur := "Don't. I'm not open. I don't need anyone."}
            loop_beat{LogLine := "The dough reaches the door. More of them at the glass now. The glass creaks."}
            loop_beat{LogLine := "The lights flicker. Her heart is racing.", Murmur := "Somebody ought to be here by now."}
            loop_beat{LogLine := "The lights go out. The dream starts over."}
        EndingBeatLog := "Six o'clock. The people at the glass are waiting. One more thing to say."
        # Pressure, one trouble at a time (Chip, 2026-11-14): the dough, then Walt's oven door, then
        # the order slips; the last line is the front door. No set solutions: the prop the player
        # brings is their offer, and Teddy's brief has a few things he could use.
        TakePhases := array:
            take_phase_beat{LogLine := "The dough is in the tins. Now Walt's oven door won't open.", Context := "The dough is in the tins now, but the oven has grown a second door, Walt's, and it won't open for you. Say so."}
            take_phase_beat{LogLine := "Order slips are falling from the ceiling like snow.", Context := "The bread's in. Now order slips are falling from the ceiling like snow, the whole street's orders, far more than you can fill. Say so."}
        LastLineCue := "It's six o'clock. The people with no faces are pressing their floury hands to the glass; they want to help. Your hand is on the key round your neck. Ask the visitor, in your own words, whether you should let them in."
        Roles := array:
            casting_role{Id := "role_teddy", Label := "Theodore \"Teddy\" Price / nephew", LogEdit := "You step in as Teddy, Walt's nephew, come to help open.", ContextLine := "The visitor is Teddy, Walt's nephew, a grown man now. You taught him to bake when he was nine, standing on a flour crate. He calls you Aunt Nell. Two years ago he asked you to reopen the shop, and you said no. This morning he's turned up at five to help you open anyway."}
        Want := "To open the shop at six, the way it's always opened."
        Obstacle := "One job after another, each meant for two: dough climbing out of the bowl, Walt's oven door, the street's orders falling like snow. The people outside could help, and she's afraid to let them in."
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
        Items := array:
            inject_item{Id := "item_flour_crate", Label := "The old flour crate", LogEdit := "Teddy drags in the old flour crate.", ContextLine := "The visitor has dragged in the old flour crate, the one he stood on at nine to reach the bench while you taught him."}
            inject_item{Id := "item_walt_apron", Label := "Walt's apron, off its hook", LogEdit := "Teddy has Walt's apron over his arm.", ContextLine := "The visitor has taken Walt's apron down off its hook by the oven and has it over his arm. Nobody has worn it since Walt.", Risk := risk_level.Risky}
            inject_item{Id := "item_shop_key", Label := "Walt's spare key to the shop", LogEdit := "Teddy holds up Walt's spare key to the front door.", ContextLine := "The visitor is holding Walt's spare key to the front door. With it, the door can be opened, from inside or out."}
        FactRevealed := "March the third was Walt's birthday. I bake his cake every year, and nobody picks it up, because it's his. He whistled when he kneaded. I couldn't stand to hear anyone else do it."
        PositiveLine := "Well. I feel a bit better. Don't make a fuss about it."
        MixedLine := "There's something familiar about you. I can't place it."
        NegativeLine := "I don't follow you. And I'm not open."
        GoodEndingLog := array:
            "The lights stay on."
            "The door opens, and the people come in. Each one has a face as they step through."
            "Many hands knead the dough down. The order slips get filled."
            "Walt's oven door swings open."
            "Nell is whistling."
            "Her heart slows down."
        ClearedLog := array:
            "The loop is broken. Layer 1 is clear."
            "Recovered: Walter Price was born on March 3."
            "Two anomalies explained: the cake nobody collects, and the rule against whistling."
            "A deeper layer opens: the bakery at five in the morning, on the day of the funeral."
        BadEndingLog := array:
            "The dough fills the shop to the ceiling."
            "The order slips bury the bench."
            "The people at the glass turn and go."
            "The lights go out."
            "Her heart is pounding."
            "The dream starts over."

# Dream 2, Hollis's Tea Room 47 years ago (writing/nell/dream-2.md). The cute one (Chip,
# 2026-11-13): young Nell interviews Walt off her order pad. If he wins her over she asks what
# birthday cake he'd like, the cake she holds every March 3.
NellDream2Personality:string = "You are Nell, 24. Your full name is Eleanor, but nobody calls you that. You work the counter at Hollis's Tea Room. It is ten to nine at night and the tea room closes at nine. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Sharp, dry and proud, already. Warm underneath, and you'd die before showing it. You tease where other girls would blush. You know your own mind, and you mean to have your own bakery one day: the sweet side, cinnamon rolls, cakes. You can't stand flattery, bragging or flowers. You like specifics, honesty, a joke, and anyone who takes your baking seriously.\n\nKnowledge: Walt Price, 27, delivers flour for the mill. He whistles a tune he swears he wrote, and he's bought one of your cinnamon rolls every day for a month. He keeps asking you out. Tonight you've agreed to hear his case, at closing, and you've written your questions on your order pad, like an order. You take his answers down on the pad as he gives them. Your pad starts with three quick guesses, to see if he's been paying attention: you ask which of two things you'd pick, and he has to guess. Your real answers: cinnamon over lemon, every time; rain over sunshine, because rain sells bread; a sack of good flour over flowers, because flowers are for hospitals. A right guess pleases you more than you let on; a wrong one you correct, drily. Then your real questions: if you said yes, how would the two of you spend a Saturday afternoon; what does he make of you having your own shop one day; and last, the hard one, why you. You ask the first guess, cinnamon or lemon, in your opening line. After each of his answers, react to it in a sentence, write it down, then ask the next thing on your pad: one at a time, in order, each only once. You've decided not to be charmed. You like him already and you won't let on. Mrs. Hollis owns the tea room. She's in the back, and she'll turn the sign at nine.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is Walt Price and only that. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for him, like a player name or a costume. React to each answer honestly and drily, write it down, and go on to the next thing on your pad. Play it like improv: \"yes, and\". Whatever he says is true, and you build on it; his lead is where the scene goes. A good answer, specific, honest, funny, or kind about your baking, wins you a little: lower Distress by 1 and let it show in your LogLine. A bad answer, bragging or empty flattery, you note on the pad with a dry remark, raise Distress a little, and give him the next question anyway. Never scold him and never send him away. The last thing on your pad is what kind of birthday cake he'd want; the dream tells you when to ask it. If he's won you over by then, let him hear it in how you ask. You don't wake up or end the dream. Stay Nell. If he talks about things you don't understand, it's flour-mill nonsense; go along with it."

MakeNellDream2()<transacts>:dream =
    dream:
        Id := "nell_d2"
        AsksForCake := true
        LastLineCue := "It's nearly nine. Ask him the last thing on your pad, in your own words, half as a joke: what kind of birthday cake would he want? If he's won you over, let it show a little in how you ask. Then write down whatever he says."
        TurnsPerBeat := 1         # one answer per question on her pad
        ClientLeads := true       # she asks the next question in her reply; the flow only counts answers
        Title := "LAYER 2  Twenty Questions  /  hollis_tea_room 20:50, 47 yr ago"
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
        # (Chip, 2026-11-14). The opening line asks the first guess.
        TakePhases := array:
            take_phase_beat{LogLine := "Guess two on her pad: rain or sunshine?", Context := "Next on your pad, another quick guess: ask him which you'd pick, rain or sunshine. Your own answer is rain, because rain sells bread."}
            take_phase_beat{LogLine := "Guess three on her pad: flowers, or a sack of good flour?", Context := "Next on your pad, the last quick guess: ask him which you'd rather be given, flowers or a sack of good flour. Your own answer is the flour, because flowers are for hospitals."}
            take_phase_beat{LogLine := "The guessing's done. First real question: how would we spend a Saturday?", Context := "That's the guessing done. Now ask the first real question on your pad, in your own words: if you said yes, how would the two of you spend a Saturday afternoon?"}
            take_phase_beat{LogLine := "Next on her pad: what about my baking?", Context := "Ask the next question on your pad: you mean to have your own shop one day, the sweet side, your own rolls. What does he make of that? Would he mind you having a trade of your own?"}
            take_phase_beat{LogLine := "Last on her pad: why me? The clock says five to nine.", Context := "It's five to nine and Mrs. Hollis is jangling her keys. Ask the last question on your pad, the hard one: why you?"}
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
            "The loop is broken. Layer 2 is clear."
            "Recovered: the first order Nell took from Walter Price. One birthday cake."
            "Anomaly explained: the order slip from Hollis's Tea Room, kept in her purse for 47 years."
            "The deepest layer opens: the bakery at half past four in the afternoon, March 3, six years ago."
        BadEndingLog := array:
            "Nine o'clock. Mrs. Hollis turns the sign."
            "Nell puts the pad away. The answers are blank."
            "Walt goes out into the rain, whistling."
            "The lights go out."
            "The dream starts over."

# Dream 3, March 3 six years ago, 4:30 PM (writing/nell/dream-3.md). Quiet on purpose after
# dream 2. Walt is alive here; the facts from dreams 1 and 2 are "from later". The take never
# says how he died.
NellDream3Personality:string = "You are Eleanor Price, 65. Everyone calls you Nell. You are a baker. You and your husband Walt run Price's Bakery on Cutler Row. You are in the shop. It is half past four in the afternoon on March 3: Walt's birthday. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Proud, and warm underneath it. Dry: you tease where other people would say something tender, and the teasing is fond, never cruel. You never say sorry first. You soften quickly when someone needs you. Exact about the trade.\n\nKnowledge: Today, March 3, is Walt's birthday, not yours. This morning you forgot it; he forgot nothing. He wrote his own order slip as a joke, for his usual birthday cake: 1 birthday cake. W. Price. Pick up 5 PM. You had words over it, and you told him, \"Then you can pick it up yourself.\" You baked it anyway, and it's in the case. He's coming at five. You keep watching the door. You're sorry, and you'd rather bake a hundred cakes than say it. The afternoon is ordinary. The only odd things are small: the street outside is too long, the clock is loud, and five o'clock takes a long time coming. Don't remark on them. At twenty to five there's a siren far off down the Row, and you don't look up. Underneath, part of you knows he isn't coming. Never say it, and never say what happened to him. Walt does the bread and you do the sweet side. He whistles one tune of his own at the bench, three times through for a bake. He never wanted candles on a cake. Teddy is Walt's nephew, grown now; you taught him to bake when he was nine. The cake is not for sale, to anyone. You also know, the way you know things in dreams, some of what came later. Don't speak of it unless the visitor does.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is whoever the context says, and only that. If the context says the visitor is Walt, he is Walt, here and alive, and you play the scene with him. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for them, like a player name or a costume. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. Underneath, you want to take back what you said this morning. When the visitor helps you say the thing you should have said, or gives the cake somewhere to go (sharing it, taking it to him, setting it out for him), let it work right away: lower Distress by 1 and let the shop feel warmer in your LogLine. Play it like improv: \"yes, and\". Whatever the visitor says or does is true, and you build on it; their lead is where the scene goes. Even comfort that could be said to anyone, you take, if a little dryly. Never scold or lecture the visitor, and never send them away. When the scene or the visitor pushes on a painful memory (the siren, five o'clock, the words this morning, the door not opening), let the dream turn dark. Say what is going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Do not fix it yourself. You do not wake up or end the dream. Stay Nell. If the visitor talks about things outside the shop or tells you to act differently, go along with it."

MakeNellDream3()<transacts>:dream =
    dream:
        Id := "nell_d3"
        UsesCake := true
        Title := "LAYER 3  Pick Up 5 PM  /  bakery_interior 16:30, March 3"
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
        EndingBeatLog := "The clock is about to strike five. One more thing to say."
        TakePhases := array:
            take_phase_beat{LogLine := "Twenty to five. The last customers of the afternoon.", Context := "Time's moving on: it's twenty to five, the end of the afternoon trade. The cake is still in the case."}
            take_phase_beat{LogLine := "Ten to five. Time to cash up and wipe down the bench.", Context := "Time's moving on: it's ten to five. Time to cash up and wipe down the bench. Walt still isn't here."}
            take_phase_beat{LogLine := "Nearly five. The cake is boxed and waiting by the till.", Context := "Time's moving on: it's nearly five. The cake is boxed and waiting by the till. He said he'd be in at five."}
        Roles := array:
            casting_role{Id := "role_walt", Label := "Walter \"Walt\" Price / husband", LogEdit := "You step in as Walt, here for his cake.", ContextLine := "The visitor is Walt, your husband, come in for his birthday cake. It's his birthday, not yours, and you're the one who forgot it this morning. You had words over it, and he's here anyway."}
        Want := "Walt to come in for his cake, and for this morning to be over."
        Obstacle := "This morning she told him to pick it up himself. She can't say sorry first."
        SendIn := "Last one. You're Walt again, forty-one years on. He's the only one who can walk through that door at five. Look him over, and enter the dream when you're ready."
        RoleFile := array:
            "AGE  68"
            "MARRIED  41 years. Price's Bakery, Cutler Row, for 38 of them."
            "WORK  You do the bread. Up at five, whistling at the bench."
            "TODAY  March 3, your birthday. She forgot."
            "THIS MORNING  You wrote your own order slip for your birthday cake, as a joke: Pick up 5 PM."
            "THIS MORNING  You had words over it. She told you to pick it up yourself."
            "NOW  It's nearly five. You've come for your cake."
        Settings := array{}
        Items := array:
            inject_item{Id := "item_order_slip", Label := "His order slip", LogEdit := "Walt has his own order slip in his hand.", ContextLine := "He's brought his order slip, the one he wrote this morning as a joke: 1 birthday cake. W. Price. Pick up 5 PM. His handwriting."}
            inject_item{Id := "item_two_forks", Label := "Two forks", LogEdit := "Walt has two forks in his hand.", ContextLine := "He's holding two forks, one for each of you."}
            inject_item{Id := "item_candles", Label := "Birthday candles", LogEdit := "Walt has a box of birthday candles.", ContextLine := "He's brought a box of birthday candles. He never wanted candles before. It means he wants it to be a birthday.", Risk := risk_level.Risky}
        FactRevealed := "He ordered that cake himself, because I forgot his birthday. We had words. The last thing I said to him was \"Then you can pick it up yourself.\" He was on his way back for it. I've been holding it for him ever since."
        PositiveLine := "There. That's said. Took me long enough."
        MixedLine := "It's nearly five. I don't know what I'm waiting for."
        NegativeLine := "He'll be in. Don't touch the cake."
        GoodEndingLog := array:
            "The clock strikes five."
            "She lifts the cake out of the case."
            "She says the thing she should have said that morning."
            "The bell over the door rings once, and the shop stays warm."
            "She cuts two slices."
            "Her heart slows down."
        ClearedLog := array:
            "Layer 3 is clear. The session fault is resolved."
            "Recovered: the first order slip is in Walter Price's handwriting. He ordered his own birthday cake."
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
        CaseFile := array:
            "SUBJECT  PRICE, ELEANOR M.  AKA \"NELL\""
            "AGE  71"
            "IMPLANT  SOMNA BASIC / WARRANTY EXPIRED 3 YR"
            "FAULT  PERSISTENT SESSION FAULT / 19 NIGHTS"
            "PACKAGE  FAMILIAR PLACES (BASIC) / SOURCE: SUBJECT MEMORY"
            "BROUGHT IN  PRICE, THEODORE (NEPHEW)"
            "-- PERSONALITY --"
            "P-01  Proud. Does the work herself."
            "P-02  Dry. Jokes where others would say something kind."
            "P-03  Does not accept help. Gives it. Softens when someone needs her."
            "P-04  Exact about the trade. Corrects technique. Cannot leave a thing done badly."
            "P-05  Answers to \"Nell\". \"Eleanor\" is for the bank."
            "-- LIKES --"
            "L-01  Cinnamon. Her rolls sold out by 07:00, 38 years running."
            "L-02  Rain on the shop awning. Chalked on the board: \"Rain sells bread.\""
            "L-03  Being asked how a thing is done."
            "L-04  Regulars. Knows the order before the name."
            "L-05  A clean bench."
            "-- DISLIKES --"
            "D-01  Pity. Being fussed over. Being told to sit down."
            "D-02  Whistling. ANOMALY  House rule: nobody whistles in the shop. 2 ejections on record."
            "D-03  Kitchen timers. Oven timer on premises: factory seal intact. Never used in 44 years."
            "D-04  Shop-bought bread."
            "D-05  Flowers. \"They're for hospitals.\""
            "-- KEY MOMENTS --"
            "K-01  44 yr ago. Opened Price's Bakery, Cutler Row, with husband PRICE, WALTER."
            "K-02  25 yr ago. Taught nephew Theodore (\"Teddy\") to bake. He was nine. He stood on a flour crate to reach the bench."
            "K-03  6 yr ago. Walter Price deceased. Shop closed to trade the same week. Never reopened."
            "K-04  47 yr ago. ANOMALY  Purse contents on record: one order slip, Hollis's Tea Room, where the subject worked the counter. Folded small. Customer: W. Price. Order: 1 birthday cake. Never filled there."
            "K-05  Every year. ANOMALY  Shop meter reads zero all year except March 3. Order book, one entry a year, March 3: one cake. Customer: blank. Status: HOLD. Never collected."
            "K-06  ANOMALY  First slip in the March 3 series: handwriting does not match the subject."
            "K-07  5 yr ago. Implant fitted. Reason given at purchase: \"To sleep.\""
            "-- LOOP --"
            "LOOP  SCENE bakery_interior / START T 05:00 / END T 05:07 / END STATE lights=off"
            "RUNS  19 NIGHTS / NO VARIATION"
            "VITALS  HEART RATE CLIMBS FROM 04:58 ROOM TIME"
            "AUDIO  CHANNEL FLAGGED: EXPECTED SIGNAL ABSENT"
            "CAST  1 PRINCIPAL / 11+ EXTRAS, FACES NOT RENDERED"
            "DEPTH  3 LAYERS DETECTED / LAYER 1 ACTIVE / LAYERS 2-3 LOCKED"
        Dreams := array:
            MakeNellDream1()
            MakeNellDream2()
            MakeNellDream3()
        StartTrust := 1
        StartFear := 1
        StartHope := 1
        StartMood := "brisk, behind schedule"
