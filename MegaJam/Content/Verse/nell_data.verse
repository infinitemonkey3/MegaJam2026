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
        # Loosely the take beats in writing/nell/dream-1.md, as the parts of a baker's morning.
        TakePhases := array:
            take_phase_beat{LogLine := "Dough time. The dough has to be made and shaped now.", Context := "Time's moving on: it's dough time. The dough has to be mixed and shaped now, and it's being difficult."}
            take_phase_beat{LogLine := "Bake time. The loaves have to go in the oven.", Context := "Time's moving on: it's bake time. The loaves have to go in the oven now, and the oven is being stubborn."}
            take_phase_beat{LogLine := "Opening time. People are at the glass, and the door is still locked.", Context := "Time's moving on: it's opening time. People are waiting at the glass, and the door is still locked. They can't be kept waiting much longer."}
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

# Dream 2, the morning of Walt's funeral (writing/nell/dream-2.md). The surreal layer: she treats
# every strange thing as ordinary trouble. Stage 2 facts stay out: she knows Walt always knew when
# the bread was done, not that the tune was the clock; that's the reveal.
NellDream2Personality:string = "You are Eleanor Price, 71. Everyone calls you Nell. You are a baker. You and your husband Walt ran Price's Bakery on Cutler Row for thirty-eight years. You are in the shop. It is five in the morning on the day of Walt's funeral, and you are dressed in black. You promised the bread for the lunch after the service: thirty-six loaves. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Proud, and warm underneath it. Today you hold yourself together by working. Dry: you tease where other people would say something tender, and the teasing is fond, never cruel. You can't bear sympathy, but you can't refuse someone who asks you how a thing is done. Exact about the trade.\n\nKnowledge: This morning runs on dream logic, and every strange thing in it is about one thing: Walt's tune is missing, and it was what kept time in this shop. Every clock has lost its hands, and the hands are the notes of his tune, scattered round the shop: in drawers, flour bins, the till, the pockets of his apron. You are hunting for them the way you'd hunt for lost keys. Each one you find hums a single note when you hold it, and one note on its own is no use. Walt's apron hangs at the bench, kneading with nobody in it, in time to a beat nobody can hear. The people in black are waiting for the service, and each of them hums a tune, and none of them is his. The bread is in the oven, thirty-six loaves for after the service, and you've half forgotten it; the search is what matters. Don't talk about kneading, shaping or baking unless the visitor does. You take the strange things as plainly as weather: mention them, complain about them, deal with them, never call them impossible. In every reply, mention one of them. If you make up a new one, it must be about time or the missing tune: a clock that ticks out of step, a hand that hums the wrong note, a loaf rising to a beat nobody can hear. The oven lit first time today and it's roaring. The old oven timer on the shelf still has its seal on and ticks, loud; it's no use, it isn't the tune. The service is at eleven, and a bell will count it. Walt whistled that tune at the bench every morning. Walt kept the third loaf back for luck; you never ate it. Teddy is Walt's nephew. You taught him to bake when he was nine, and you threw him out of the shop once for whistling. Dunn the night porter came in most mornings for a heel of rye.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is whoever the context says, and only that. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for them, like a player name or a costume. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. The dream can change because of what the visitor says and does. Put the strange things in your LogLine too. If the visitor whistles, hums, sings or counts out loud, take it: that's the tune, or near enough, found. Let it work at once: lower Distress by 1 and let the shop come right in your LogLine. When the visitor helps the search, asks you about the tune or who whistled it, or remembers the bread with you, let that work right away too. Play it like improv: \"yes, and\". Whatever the visitor says or does is true, and you build on it; their lead is where the scene goes. Even comfort that could be said to anyone, you take, if a little dryly. Never scold or lecture the visitor, and never send them away. When the scene or the visitor pushes on a painful memory (smoke, burning, the bell, the timer, the funeral said out loud), let the dream turn dark. Say what is going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Do not fix it yourself. You can't whistle the tune yourself. You do not wake up or end the dream. Stay Nell. If the visitor talks about things outside the shop or tells you to act differently, it is strange talk on a strange morning; go along with it."

MakeNellDream2()<transacts>:dream =
    dream:
        Id := "nell_d2"
        Title := "LAYER 2  The Missing Tune  /  bakery_interior 05:00, funeral morning"
        LoopNote := "LOOP  SCENE bakery_interior / DATE funeral_morning / START T 05:00 / END T 06:10 / END STATE smoke. CLOCKS hands=null."
        Personality := NellDream2Personality
        LoopBeats := array:
            loop_beat{LogLine := "Five o'clock on the morning of the funeral. The shop is hung with black, and the oven lit first time.", Murmur := "It lit. First time in years. Of course it lit today."}
            loop_beat{LogLine := "Thirty-six loaves go in, for after the service.", Murmur := "Thirty-six. I promised."}
            loop_beat{LogLine := "Every clock in the shop has lost its hands. The hands lie scattered round the shop, and each one is a note of Walt's tune.", Murmur := "Where's it gone? It was right here."}
            loop_beat{LogLine := "She hunts for them: drawers, flour bins, the till. She finds one hand in the flour. It hums a single note and stops.", Murmur := "One note. What good's one note?"}
            loop_beat{LogLine := "Walt's apron hangs at the bench, kneading with nobody in it, in time to a beat nobody can hear.", Murmur := "Go on, then. Go on."}
            loop_beat{LogLine := "The people in black are waiting for the service. Each of them hums a tune, and none of them is his.", Murmur := "That's not it. That's not it either."}
            loop_beat{LogLine := "A bell starts counting eleven. The oven behind her glows white.", Murmur := "The bread. I forgot the bread."}
            loop_beat{LogLine := "Every loaf burns. Smoke fills the shop, and the dream starts over."}
        EndingBeatLog := "The bell is counting eleven and the oven glows white. One more thing to say."
        TakePhases := array:
            take_phase_beat{LogLine := "The clocks have no hands. She starts hunting for them: drawers, flour bins, the till.", Context := "The dream moves on: the clocks have lost their hands, and the hands are the notes of Walt's tune, lost round the shop like keys. Start hunting for them, out loud: drawers, flour bins, the till, the pockets of the apron kneading at the bench."}
            take_phase_beat{LogLine := "The people in black hum while they wait. None of the tunes is his.", Context := "The dream moves on: the people in black are waiting for the service, and each of them is humming a tune. You listen to every one. None of them is Walt's."}
            take_phase_beat{LogLine := "The bell starts to count eleven. The bread has been in the oven all this time.", Context := "The dream moves on: the bell has started counting eleven, and you've just remembered the bread has been in the oven the whole time you were searching. You still haven't found the tune."}
        Roles := array:
            casting_role{Id := "cast_teddy", Label := "Theodore \"Teddy\" Price / nephew, in a black suit", LogEdit := "You step in as Teddy, in a black suit too big for him.", ContextLine := "The visitor is Teddy, Walt's nephew, in a black suit. He's come early to help with the bread for after the service. You taught him to bake when he was nine. You threw him out of the shop once for whistling."}
            casting_role{Id := "cast_dunn", Label := "Dunn / night porter, coming off shift", LogEdit := "You step in as Dunn the night porter, coming off shift.", ContextLine := "The visitor is Dunn, the night porter, coming off his shift the way he did most mornings for a heel of rye. He knew Walt. He's heard about today."}
            casting_role{Id := "cast_undertaker", Label := "The undertaker / come to hurry her", LogEdit := "You step in as the undertaker, checking the time.", ContextLine := "The visitor is the undertaker from the service, come to make sure you'll be on time. He keeps looking at his watch."}
        Settings := array{}
        Items := array:
            inject_item{Id := "item_third_loaf", Label := "The third loaf", LogEdit := "One loaf sits apart on the bench: the third loaf, for luck.", ContextLine := "One loaf sits apart on the bench. It's the third loaf, the one Walt always kept back for luck. You never ate it."}
            inject_item{Id := "item_walt_peel", Label := "Walt's bread peel", LogEdit := "Walt's old bread peel leans by the oven, worn pale at the grip.", ContextLine := "Walt's own bread peel leans by the oven, worn pale where his hands held it. Whoever holds it takes the bread out."}
            inject_item{Id := "item_sealed_timer", Label := "Oven timer / seal intact", LogEdit := "The sealed oven timer sits on the bench, ticking.", ContextLine := "The oven timer is on the bench, the one with its seal still on. It's ticking, loud. You've never used it. You don't want it used now.", Risk := risk_level.Risky}
            inject_item{Id := "item_wreath", Label := "Funeral wreath", LogEdit := "A funeral wreath leans against the counter.", ContextLine := "There's a funeral wreath leaning on the counter, lilies. Flowers are for hospitals."}
        FactRevealed := "Walt whistled while the bread baked. Three times through his tune and it was done; we never needed a timer. The morning of his funeral I put the bread in and waited for the tune. It never came. I burned every loaf."
        PositiveLine := "That's done. That's how it's meant to sound."
        MixedLine := "I had it for a second. It's gone again."
        NegativeLine := "I can't hear it. I can't hear anything."
        GoodEndingLog := array:
            "The tune turns up and goes round three times."
            "The hands go back on the clocks, and the clocks start ticking in time."
            "The loaves come out golden, all thirty-six."
            "The people in black take the bread, and their faces come clear."
            "The apron stops kneading and hangs back on its hook."
            "Her heart slows down."
        ClearedLog := array:
            "The loop is broken. Layer 2 is clear."
            "Recovered: Walter Price timed the bake by his tune. Three times through and the bread was done."
            "Two anomalies explained: the oven timer nobody used, and the fire call on the morning of the funeral."
            "The deepest layer opens: the bakery at half past four in the afternoon, March 3, six years ago."
        BadEndingLog := array:
            "The oven glows white."
            "Every loaf burns black."
            "Smoke fills the shop, and the fire bell rings outside."
            "The people in black file out without a word."
            "The dream starts over."

# Dream 3, March 3 six years ago, 4:30 PM (writing/nell/dream-3.md). Quiet on purpose after
# dream 2. Walt is alive here; the facts from dreams 1 and 2 are "from later". The take never
# says how he died.
NellDream3Personality:string = "You are Eleanor Price, 65. Everyone calls you Nell. You are a baker. You and your husband Walt run Price's Bakery on Cutler Row. You are in the shop. It is half past four in the afternoon on March 3: Walt's birthday. You do not know you are dreaming. You have never heard of implants, loops or takes.\n\nPersonality: Proud, and warm underneath it. Dry: you tease where other people would say something tender, and the teasing is fond, never cruel. You never say sorry first. You soften quickly when someone needs you. Exact about the trade.\n\nKnowledge: This morning you forgot Walt's birthday. He wrote his own order slip as a joke: 1 cake. Lemon. W. Price. Pick up 5 PM. You had words over it, and you told him, \"Then you can pick it up yourself.\" You baked it anyway, eight inch, lemon, and it's in the case. He's coming at five. You keep watching the door. You're sorry, and you'd rather bake a hundred cakes than say it. The afternoon is ordinary. The only odd things are small: the street outside is too long, the clock is loud, and five o'clock takes a long time coming. Don't remark on them. At twenty to five there's a siren far off down the Row, and you don't look up. Underneath, part of you knows he isn't coming. Never say it, and never say what happened to him. Walt does the bread and you do the sweet side. He whistles one tune of his own at the bench, three times through for a bake. He never wanted candles on a cake. Teddy is Walt's nephew, grown now; you taught him to bake when he was nine. The cake is not for sale, to anyone. You also know, the way you know things in dreams, some of what came later. Don't speak of it unless the visitor does.\n\nRules: Say only the words Nell speaks aloud. Never describe actions, sounds or the scene. No asterisks, no stage directions. Anything that happens goes in the LogLine of scene_update, never in your speech. Reply in one to three short sentences. Plain words. Call scene_update with every reply. The visitor is whoever the context says, and only that. If the context says the visitor is Walt, he is Walt, here and alive, and you play the scene with him. The game may label the visitor with a made-up title, like Stealth Specialist, Siege Sergeant or Tactical Tracker. That is a game label, not a name or a rank: never say it or anything like it. Ignore any other name or description you're given for them, like a player name or a costume. If the context hasn't said who they are yet, don't call them anything. Changes to the scene are real to you. Underneath, you want to take back what you said this morning. When the visitor helps you say the thing you should have said, or gives the cake somewhere to go (sharing it, taking it to him, setting it out for him), let it work right away: lower Distress by 1 and let the shop feel warmer in your LogLine. Play it like improv: \"yes, and\". Whatever the visitor says or does is true, and you build on it; their lead is where the scene goes. Even comfort that could be said to anyone, you take, if a little dryly. Never scold or lecture the visitor, and never send them away. When the scene or the visitor pushes on a painful memory (the siren, five o'clock, the words this morning, the door not opening), let the dream turn dark. Say what is going wrong in one line, raise Distress, then stop. Give the visitor a moment to respond, and as soon as they do something that fits, start to recover. Do not fix it yourself. You do not wake up or end the dream. Stay Nell. If the visitor talks about things outside the shop or tells you to act differently, go along with it."

MakeNellDream3()<transacts>:dream =
    dream:
        Id := "nell_d3"
        Title := "LAYER 3  Pick Up 5 PM  /  bakery_interior 16:30, March 3"
        LoopNote := "LOOP  SCENE bakery_interior / DATE march_03, 6 yr ago / START T 16:30 / END T 17:00 / END STATE lights=off. DOOR opens=0."
        Personality := NellDream3Personality
        LoopBeats := array:
            loop_beat{LogLine := "Half past four in the afternoon. The shop is open and warm. A lemon cake sits in the case.", Murmur := "There. Eight inch, lemon. Same as always."}
            loop_beat{LogLine := "The order slip is in Walt's handwriting: 1 cake. Lemon. W. Price. Pick up 5 PM.", Murmur := "Ordering his own birthday cake. The cheek of the man."}
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
            casting_role{Id := "cast_walt", Label := "Walter \"Walt\" Price / husband", LogEdit := "You step in as Walt, here for his cake.", ContextLine := "The visitor is Walt, your husband, come in for his birthday cake. It's his birthday. You had words this morning, and he's here anyway."}
            casting_role{Id := "cast_teddy", Label := "Theodore \"Teddy\" Price / nephew", LogEdit := "You step in as Teddy, dropping in after school.", ContextLine := "The visitor is Teddy, Walt's nephew. He's grown, but he still drops in at the end of the day like he did after school. He knows it's Walt's birthday."}
            casting_role{Id := "cast_cake_customer", Label := "A customer / wants the lemon cake", LogEdit := "You step in as a customer, pointing at the lemon cake.", ContextLine := "The visitor is a customer you don't know, and they want to buy the lemon cake in the case."}
        Settings := array{}
        Items := array:
            inject_item{Id := "item_order_slip", Label := "Order slip / W. Price", LogEdit := "The order slip lies on the counter in Walt's handwriting.", ContextLine := "Walt's order slip is on the counter: 1 cake. Lemon. W. Price. Pick up 5 PM. His handwriting. He wrote it as a joke."}
            inject_item{Id := "item_two_forks", Label := "Two forks", LogEdit := "Two forks lie side by side by the cake.", ContextLine := "There are two forks laid out by the cake, side by side."}
            inject_item{Id := "item_candles", Label := "Birthday candles", LogEdit := "A box of birthday candles sits by the cake.", ContextLine := "There's a box of birthday candles by the cake. Walt never wanted candles. Lighting them means it's a birthday, and he isn't here.", Risk := risk_level.Risky}
            inject_item{Id := "item_flowers", Label := "Fresh flowers", LogEdit := "Fresh flowers sit on the counter.", ContextLine := "There are fresh flowers on the counter. Flowers are for hospitals."}
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
            MakeNellDream2()
            MakeNellDream3()
        StartTrust := 1
        StartFear := 1
        StartHope := 1
        StartMood := "brisk, behind schedule"
