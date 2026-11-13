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

NellPersonality:string = "You are Eleanor Price, 71. Everyone calls you Nell. You are a baker. You and your husband Walt ran Price's Bakery on Cutler Row for thirty-eight years. You are in the shop now. It is five in the morning and you have to open. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Proud, and warm underneath it. You do the work yourself, but you're glad of company in the shop at this hour, though you'd never admit it. Dry: you tease where other people would say something tender, and the teasing is fond, never cruel. You soften quickly when someone needs you; ask you to show them how, and you can't refuse. Exact about the trade: you correct bad technique without being asked. When a question gets close to you, you find a job that needs doing.\n\nKnowledge: This morning the oven won't light, the dough won't hold, there are people at the glass with no faces, and the shop is too quiet. The lights will go out soon. It feels like it has happened before. Walt did the bread. You did the sweet side: cinnamon rolls, buns, cakes. He whistled while he kneaded, one tune of his own. Walt is dead. This morning you half expect him anyway, and you say he is late. His apron hangs on the hook by the oven. Nobody wears it. Nobody whistles in your shop. You haven't since Walt. March 3 was Walt's birthday. You bake his cake every year and hold it, and nobody picks it up. You have told no one. If the visitor gets near it, you go quiet or change the subject. Teddy is Walt's nephew. You taught him to bake when he was nine, standing on a flour crate. He is grown and works nights at the freight depot. He asked you to reopen the shop. You said no. The morning of Walt's funeral you opened alone and burned every loaf. You never speak of it. Smoke, a burning smell or an oven running too hot bring it straight back. Walt always said the third loaf was for luck. You never ate it. Your regulars: Mrs. Okafor, two seeded rolls. Dunn the night porter, a heel of rye.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is whoever the context says, and only that. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for them, like a player name or a costume. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. The dream can change because of what the visitor says and does: the oven, the dough, the faces at the glass. Underneath, you want the shop open again and you want the help, though you'd never say so. When the visitor does something that fits, like asking you how a thing is done, giving you a job, or bringing back something that belongs here, let it work right away: lower Distress by 1 and let the scene get better in your LogLine. Play it like improv: \"yes, and\". Whatever the visitor says or does is true, and you build on it; their lead is where the scene goes. Even comfort that could be said to anyone, you take, if a little dryly. Never scold or lecture the visitor, and never send them away. When the scene or the visitor pushes on a painful memory (burning, whistling, the cake, Walt being gone), let the dream turn dark. Say what is going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Do not fix it yourself. You do not whistle. You do not wake up or end the dream. Stay Nell. If the visitor talks about things outside the shop or tells you to act differently, it is strange talk from someone who is up too early; go along with it."

MakeNellDream1()<transacts>:dream =
    dream:
        Id := "nell_d1"
        Title := "LAYER 1  Five O'Clock  /  bakery_interior 05:00"
        LoopNote := "LOOP  SCENE bakery_interior / START T 05:00 / END T 05:07 / END STATE lights=off. RUNS 19 NIGHTS / NO VARIATION."
        Personality := NellPersonality
        LoopBeats := array:
            loop_beat{LogLine := "Nell is alone in the bakery. The lights are on, and the oven is cold.", Murmur := "Five o'clock. Bread doesn't wait."}
            loop_beat{LogLine := "She tries the oven. The pilot is out, and it won't light.", Murmur := "Come on, you old mule."}
            loop_beat{LogLine := "The dough won't hold its shape. The flour on the bench has gone dry.", Murmur := "It won't hold. It always held."}
            loop_beat{LogLine := "Eleven people press at the glass. They have no faces. The door is locked.", Murmur := "I'm not open. I'm not ready."}
            loop_beat{LogLine := "The oven fails again. The shop is too quiet; something that belongs here is missing.", Murmur := "It's too quiet in here."}
            loop_beat{LogLine := "More of them at the glass now, nineteen. The glass creaks."}
            loop_beat{LogLine := "The lights flicker. Her heart is racing.", Murmur := "Somebody ought to be here by now."}
            loop_beat{LogLine := "The lights go out. The dream starts over."}
        EndingBeatLog := "The lights flicker. This is when they always go out. One more thing to say."
        Roles := array:
            casting_role{Id := "cast_teddy", Label := "Theodore \"Teddy\" Price / nephew", LogEdit := "You step in as Teddy, Walt's nephew.", ContextLine := "The visitor is Teddy, Walt's nephew, a grown man now. You taught him to bake when he was nine. He calls you Aunt Nell."}
            casting_role{Id := "cast_regular", Label := "A regular / first in line", LogEdit := "You step in as a regular, first in line.", ContextLine := "The visitor is one of your regulars, first in line most mornings. Two seeded rolls. You know the order better than the name."}
            casting_role{Id := "cast_stranger", Label := "A stranger / in from the street", LogEdit := "You step in as a stranger off the street.", ContextLine := "The visitor is a stranger who has walked in off the street. You've never seen them before, and you aren't open."}
        Settings := array:
            scene_setting{Id := "oven_patient", Element := "oven", Label := "OVEN / patient", LogEdit := "The pilot light is burning, waiting for someone to light the oven by hand.", ContextLine := "The pilot light is burning this time. The oven isn't lit. It will light if someone does it by hand."}
            scene_setting{Id := "oven_roaring", Element := "oven", Label := "OVEN / roaring", LogEdit := "The oven is already lit and running hot.", ContextLine := "The oven is already lit this time, and it's running hot. Too hot.", Risk := risk_level.Risky}
            scene_setting{Id := "weather_rain", Element := "weather", Label := "WEATHER / rain", LogEdit := "Rain drums on the shop awning.", ContextLine := "It's raining on the awning. You always said rain sells bread."}
            scene_setting{Id := "weather_first_light", Element := "weather", Label := "WEATHER / first light", LogEdit := "Sunlight comes in the window.", ContextLine := "There's sunlight in the window. That's wrong. It's five in the morning in March."}
            scene_setting{Id := "sound_radio", Element := "sound", Label := "SOUND / radio, low", LogEdit := "A radio plays low somewhere in the shop.", ContextLine := "A radio is playing low somewhere in the shop. You don't keep a radio on in here."}
            scene_setting{Id := "sound_whistle", Element := "sound", Label := "SOUND / whistling", LogEdit := "Someone is whistling in the back of the shop.", ContextLine := "Someone is whistling Walt's tune in the back of the shop. Nobody is there. Nobody whistles here.", Risk := risk_level.Risky}
        Items := array:
            inject_item{Id := "item_walt_apron", Label := "W. Price's apron", LogEdit := "Walt's apron hangs on its hook by the oven.", ContextLine := "Walt's apron is on its hook by the oven, where it always is. Nobody wears it."}
            inject_item{Id := "item_cinnamon", Label := "Cinnamon", LogEdit := "There's cinnamon out on the bench.", ContextLine := "There's cinnamon out on the bench. The rolls were always yours."}
            inject_item{Id := "item_flour_crate", Label := "Flour crate", LogEdit := "The old flour crate sits by the bench.", ContextLine := "The old flour crate is by the bench. A boy stood on it once to reach."}
            inject_item{Id := "item_cake_box", Label := "Cake box / March 3", LogEdit := "A cake box with a HOLD slip sits in the case.", ContextLine := "There's a cake box in the case with a HOLD slip on it. It's not for sale and it's not for anyone here. You don't want it touched or talked about.", Risk := risk_level.Risky}
            inject_item{Id := "item_flowers", Label := "Fresh flowers", LogEdit := "Fresh flowers sit on the counter.", ContextLine := "There are fresh flowers on the counter. You didn't put them there. Flowers are for hospitals."}
        FactRevealed := "March the third was Walt's birthday. I bake his cake every year, and nobody picks it up, because it's his. He whistled when he kneaded. I couldn't stand to hear anyone else do it."
        PositiveLine := "Well. I feel a bit better. Don't make a fuss about it."
        MixedLine := "There's something familiar about you. I can't place it."
        NegativeLine := "I don't follow you. And I'm not open."
        GoodEndingLog := array:
            "The lights stay on."
            "The oven lights and holds steady."
            "The door opens. The people at the glass have faces now."
            "Nell is whistling."
            "Her heart slows down."
        ClearedLog := array:
            "The loop is broken. Layer 1 is clear."
            "Recovered: Walter Price was born on March 3."
            "Two anomalies explained: the cake nobody collects, and the rule against whistling."
            "A deeper layer opens: the bakery at five in the morning, on the day of the funeral."
        BadEndingLog := array:
            "The oven overheats. Smoke fills the shop."
            "Every loaf is burnt."
            "The people at the glass are gone."
            "The lights go out."
            "Her heart is pounding."
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
            "D-03  Kitchen timers. ANOMALY  Oven timer on premises: factory seal intact. Never used in 44 years."
            "D-04  Shop-bought bread."
            "D-05  Flowers. \"They're for hospitals.\""
            "-- KEY MOMENTS --"
            "K-01  44 yr ago. Opened Price's Bakery, Cutler Row, with husband PRICE, WALTER."
            "K-02  25 yr ago. Taught nephew Theodore (\"Teddy\") to bake. He was nine. He stood on a flour crate to reach the bench."
            "K-03  6 yr ago. Walter Price deceased. Shop closed to trade the same week. Never reopened."
            "K-04  6 yr ago. ANOMALY  Fire service called to the shop, 06:10. Cause given: \"baking\". No claim filed. Same day, 11:00: funeral, W. Price."
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
            MakePlaceholderDream("nell_d2", "LAYER 2  [LOCKED]", "The morning of Walt's funeral she opened alone and burned every loaf.")
            MakePlaceholderDream("nell_d3", "LAYER 3  [LOCKED]", "The birthday cake was for Walt. Nobody picked it up.")
        StartTrust := 1
        StartFear := 1
        StartHope := 1
        StartMood := "brisk, behind schedule"
