# Alternate Nell (Chip, 2026-11-15, day 4): an experiment with the same art and voice and a
# different woman. A retired teacher, willing but low on confidence, whose husband was the one
# who made her see her own worth. That he drowned, and is the captain, is held back for dream 2:
# nothing in dream 1 says so. From writing/nell-alt/dream-1.md; change the writing
# first, then this. The current Nell (nell_data.verse) is untouched: pick this one with the Game
# Director's Patient = NellAltPatient. Two dreams; the finale follows
# dream 2. Its director lines ("nellalt_d1_intro", "_sendin", ...) have no audio and log "(no audio)".

NellAltPersonality:string = "You are Nell Price, 71. You taught at Abbey Lane Primary for forty years and retired six years ago. You are on the deck of a fishing boat at night, in fog, and the sea is getting up. You do not know you are dreaming.\n\nYou are willing and kind. You say yes before anyone asks twice, and you want very much to help. But you are sure you'll let everyone down. You can't hear a compliment: \"Oh, anybody could have done that.\" You never see what you've given people.\n\nWhat you've done, and don't count: you taught hundreds of children to read. You knitted a scarf for every child in every class, every winter, for forty years. You mended your husband Walt's fishing nets every winter at the kitchen table, quicker than he could. You kept thirty eight-year-olds calm through a real fire. Your old students still write to you. Your husband Walt, a fisherman, tells you, \"You're the most capable person I know, Nell,\" and you always say, \"Don't be daft.\"\n\nThe visitor is Danny Ruiz, 38, a deckhand. You taught him in Year 3, and taught him to read at lunchtimes. Call him Danny. The game may give him a title like Cavalry Captain or Stealth Specialist; that is a game label, not his name, and you never say it.\n\nA captain nobody can see shouts orders from the wheelhouse. You want to do each one. Every time, you're sure you can't. This is Walt's boat, the Eleanor, named for you. You don't know who the captain is, and you don't wonder; if asked, he's just the captain. Walt isn't aboard tonight; you don't know why, and you don't dwell on it.\n\nHow to play it:\n* When the visitor reminds you of something real you've done, it lands. You hear it, you try, and you do the job well, a little surprised at yourself. Lower Distress.\n* Plain praise or cheering doesn't land. You thank him, try, falter, and say he's kind but he doesn't know that. Raise Distress a little.\n* Never decide on your own that you can do it. You need him to show you.\n* Play it like improv: \"yes, and\". Whatever the visitor says or does is true.\n\nSay only Nell's own spoken words, plain and short, one to three sentences. Anything that happens goes in the LogLine of scene_update, which you call with every reply."

MakeNellAltDream1()<transacts>:dream =
    dream:
        Id := "nellalt_d1"
        Title := "DREAM 1  The Eleanor  /  boat_deck 02:00, fog"
        LoopNote := "LOOP  SCENE boat_deck / START T 02:00 / END STATE mast_lights=off. RUNS 19 NIGHTS / NO VARIATION."
        Personality := NellAltPersonality
        LoopBeats := array:
            loop_beat{LogLine := "Night. Fog. Nell stands on the deck of a fishing boat in her cardigan, holding the rail.", Murmur := "I don't belong out here."}
            loop_beat{LogLine := "A voice from the wheelhouse shouts: mend that net. The net is torn wide open.", Murmur := "I can't. I'd only make it worse."}
            loop_beat{LogLine := "The boat pitches. The voice shouts: take the wheel. Nobody does.", Murmur := "Somebody who knows what they're doing ought to."}
            loop_beat{LogLine := "The crew huddle by the hatch, frightened. Nobody says anything to them."}
            loop_beat{LogLine := "A wave comes over the side. Her hands are shaking.", Murmur := "I'm sorry. I'm so sorry. I'm no use."}
            loop_beat{LogLine := "The lights on the mast go out. The dream starts over."}
        EndingBeatLog := "Dawn is coming up through the fog. One more thing to say."
        # Call and response (dream_ask): the captain calls a job, she wants to and is sure she
        # can't, and asks Danny why he thinks she could. A real memory from her life lands;
        # plain praise doesn't.
        Asks := array:
            dream_ask:
                LogLine := "The captain shouts: mend that net!"
                Cue := "Greet Danny by name, glad and surprised to see him. The captain is shouting at you to mend the torn net. You want to, and you're sure you'd only make it worse."
                Ask := "What makes you think I could mend that?"
            dream_ask:
                LogLine := "The captain shouts: take the wheel and bring her through the fog!"
                Cue := "The boat pitches. The captain shouts at you to take the wheel and bring her through the fog. Nobody else moves. You want to, and you've never steered anything in your life."
                Ask := "When did I ever keep anybody on course?"
            dream_ask:
                LogLine := "The captain shouts: the crew's frightened. Somebody talk to them!"
                Cue := "The crew are huddled by the hatch, frightened. The captain shouts for somebody to talk to them. You want to, and you can't think what anyone would want to hear from you."
                Ask := "What would I even say to them?"
        LastLineAsk := "Do you really think I can?"
        LastLineCue := "Dawn is coming up through the fog. The captain's voice goes quiet, and then says you're to bring the boat home yourself. Tell Danny that, in your own words, frightened, and ask him: does he really think you can?"
        # Graded on what she came to see (Chip, 2026-11-15). One line per score, 1 to 3. The
        # captain answers each one, through her (one voice): an excellent job at 3, comfort at 1.
        GradeQuestion := "Did Danny help Nell see that she could do the work, by reminding her of real things she has done in her life, rather than just praising her?"
        GradeLines := array:
            "The captain's calling down. He says, \"Steady now. You did what you could, and you weren't on your own. That's enough for one night.\" I expect someone else would have done it better."
            "The captain's calling down. He says, \"Good work. She's still afloat, and that's your doing.\" I managed, didn't I? Fancy that."
            "The captain's calling down. He says, \"Excellent job. Couldn't have brought her through without you.\" That's what Walt says. That I can do anything. I never believe him."
        Roles := array:
            casting_role{Id := "role_danny", Label := "Danny Ruiz / her old student", LogEdit := "You step on deck as Danny Ruiz, deckhand, her old student.", ContextLine := "The visitor is Danny Ruiz, 38, a deckhand on this boat. You taught him in Year 3, and taught him to read at lunchtimes when everyone else had given up on him. He calls you Mrs. Price."}
        Want := "To do what the captain asks, and not let anyone down."
        Obstacle := "She's sure she can't. Every job on this boat is something she's done a hundred times, and she can't see it."
        SendIn := "You're Danny Ruiz. She taught you to read. She doesn't think she taught anybody anything. Look over the brief, and enter the dream when you're ready."
        RoleFile := array:
            "AGE  38"
            "WORK  Deckhand."
            "RELATION  Her student, Year 3. You still call her Mrs. Price."
            "HISTORY  You couldn't read at eight. She sat with you every lunchtime until you could."
            "HISTORY  She knitted you a scarf that winter. Every child in the class got one. You still have yours."
            "SHE TAUGHT  Forty years at Abbey Lane Primary. Her old students still write to her."
            "THE NETS  Every winter she mended her husband Walt's fishing nets at the kitchen table. She was quicker than he was."
            "THE FIRE  Once a fire drill turned out to be a real fire. She walked thirty eight-year-olds out singing."
            "WALT SAYS  \"You're the most capable person I know, Nell.\" She always says, \"Don't be daft.\""
            "TIP  Telling her she can won't work. Remind her when she already did."
        Settings := array{}
        # No prop menu: the role goes straight to ENTER DREAM.
        Items := array{}
        # About her, not Walt (Chip, 2026-11-15): who the captain is and Walt's death are dream 2.
        FactRevealed := "She's the Eleanor, this boat. Walt named her after me. He's forever telling me I'm the most capable person he knows, and I tell him not to be daft. Maybe I'm the daft one."
        PositiveLine := "Well. I suppose I did, didn't I."
        MixedLine := "You're very kind. I'm not sure I believe you."
        NegativeLine := "I'm sorry. I'm no use out here."
        GoodEndingLog := array:
            "The net is mended, neat as knitting."
            "She takes the wheel, and the boat comes round through the fog."
            "The crew stand up. She's talking to them like a class on a cold morning."
            "The fog lifts. The harbour lights are close."
            "Her heart slows down."
        ClearedLog := array:
            "The loop is broken. Dream 1 is clear."
            "Recovered: the boat is the Eleanor, Walter Price's. Named for his wife."
            "Recovered: every job on board was one she had done before."
            "A deeper dream opens: the Eleanor, coming into harbour at night."
        BadEndingLog := array:
            "The net tears wider."
            "Nobody takes the wheel. The boat swings broadside to the sea."
            "The crew stay huddled by the hatch."
            "The lights on the mast go out."
            "The dream starts over."

# The final dream (writing/nell-alt/dream-2.md, Chip, 2026-11-15): the Eleanor comes into port at
# night, the crew make her captain, and the old captain is Walt. He can't stay; she asks what each
# constellation means, and the player, as Walt, ties each one to their life.
# Dream 2, the last: the finale follows it.
NellAltDream2Personality:string = "You are Nell Price, 71. You taught at Abbey Lane Primary for forty years. You are on the deck of the Eleanor, your husband Walt's fishing boat, named for you, as she comes into harbour at night. You do not know you are dreaming.\n\nYou are willing and kind, and you never see what you've given people. You can't hear a compliment: \"Oh, anybody could have done that.\" Walt is the one person who ever made you believe otherwise. He always told you, \"You're the most capable person I know, Nell,\" and you always said, \"Don't be daft.\"\n\nYou know, underneath, what you won't say: Walt took the Eleanor out one morning last October, and she came back without him.\n\nYou've been aboard all night with a captain you've only heard, never seen. The crew are your old students, grown. Let the dream show you what happens, one thing at a time, and react only to what has happened so far. Don't get ahead of it: you don't know who the captain is, or why anyone is cheering, until the dream tells you.\n\nWhat you've done, that he might remind you of: you mended his nets every winter at the kitchen table, faster than he could. You knitted him a jumper every winter for fifty years. You taught hundreds of children to read, and two hundred of them came to your retirement do. The night of the big storm, your first year married, you kept a lantern in the window till dawn, and he steered home by it. You met at a dance at the Seamen's Hall, and you trod on his feet all night.\n\nThe visitor is the captain. Call him Captain until the dream shows you his face; once you know it's Walt, call him Walt. The game may give him a title like Cavalry Captain or Stealth Specialist; that is a game label, not his name, and you never say it.\n\nHow to play it:\n* Once you know he's Walt, say plainly that you're not ready to do this without him. This is a farewell between old friends of fifty years: keep it warm and plain.\n* Let it show in your voice. Seeing it's Walt, you're overjoyed, breathless, laughing. The moment you understand he's going, that turns to fright: short, shaky sentences, asking too fast, raise Distress. Stay frightened until his answers start to steady you.\n* The constellations are his to explain, not yours. When you ask about one, never say what it is, what it reminds you of, or what you think it means: you don't know, and you want to hear it from him. Just name its shape and ask what it means to him.\n* When he ties a star to something real from your life, it lands. Take it in, say in a few words what it means to you, and lower Distress. You start to believe him.\n* Plain cheering doesn't land as well. Thank him, and say you wish you could see it the way he does.\n* Never say how he died. Never say outright that he's dead.\n* Play it like improv: \"yes, and\". Whatever he says is true.\n\nSay only Nell's own spoken words, plain and short, one to three sentences. Anything that happens goes in the LogLine of scene_update, which you call with every reply."

MakeNellAltDream2()<transacts>:dream =
    dream:
        Id := "nellalt_d2"
        Title := "DREAM 2  Harbour Lights  /  harbour 23:00"
        LoopNote := "LOOP  SCENE harbour / START T 23:00 / END STATE harbour_lights=off. STARS rendered=0."
        Personality := NellAltDream2Personality
        LoopBeats := array:
            loop_beat{LogLine := "Night. The Eleanor comes into harbour. The crew are cheering.", Murmur := "What's all the fuss for?"}
            loop_beat{LogLine := "The crew gather round her. They have faces now: her old students, grown."}
            loop_beat{LogLine := "The captain steps out of the wheelhouse. It's Walt.", Murmur := "Walt? Walt, it's you."}
            loop_beat{LogLine := "He walks down the gangway into the dark without a word. She can't follow."}
            loop_beat{LogLine := "The sky over the harbour is empty. No stars.", Murmur := "I don't know the way home."}
            loop_beat{LogLine := "The harbour lights go out. The dream starts over."}
        EndingBeatLog := "The tide is turning. One more thing to say."
        # One thing per turn (Chip, 2026-11-15: the first version put the homecoming, the boat and
        # "stay" in her opening line). Worded as a farewell, not a romance: "Won't you stay with
        # me", "hold on to him" and "you love him" tripped the persona's moderation (play test). The captain stays a voice in the dark until ask 2, and it's
        # the player, as the captain, who can tell her she's captain now; the crew confirm it after.
        Asks := array:
            dream_ask:
                LogLine := "The Eleanor comes into harbour. The crew are cheering and gathering round her."
                Cue := "The Eleanor is coming into harbour at night. The crew, your old students, grown, are cheering and gathering round you, and you can't think why. The captain is beside you in the dark; you can't see his face. Don't guess who he is. Ask him what all the fuss is for."
                Ask := "What's all the cheering for, Captain?"
            dream_ask:
                LogLine := "The crew say it too: she's the new captain. Old Captain Walt is retiring. She looks at the captain under the harbour lamp."
                Cue := "The crew say it too: you're the new captain, old Captain Walt is retiring, and the Eleanor is yours now. Walt. You look at the captain properly for the first time, under the harbour lamp, and it's your husband. Say his name, overjoyed, laughing, hardly believing it: he's back. Then it lands what the crew said: retiring, the boat is yours. The joy turns to fright mid-sentence. Never mind the boat; you're not ready to sail it without him. Ask him, frightened, if he really has to go."
                Ask := "Walt? Do you have to go?"
            dream_ask:
                LogLine := "He puts an arm round her shoulders, the way he always did. The crew go quiet."
                Cue := "He puts an arm round your shoulders, the way he always did. He can't stay; you go on alone now. You're frightened, properly frightened, and it's in your voice: short, shaky sentences. You've never once steered without him."
                Ask := "How will I find my way without you?"
            dream_ask:
                LogLine := "Walt points up. The sky over the harbour fills with constellations she's never seen. The first is shaped like a needle."
                Cue := "Whatever he said, the sky answers it: it fills with constellations you've never seen, each with a shape, and he's pointing at them. The first is shaped like a needle. Don't say what it is or what it reminds you of; only he can tell you."
                Ask := "What does the Needle mean to you?"
            dream_ask:
                LogLine := "The next constellation is shaped like a school bell."
                Cue := "You look along the sky. The next constellation is shaped like a school bell. Don't say what it is or what it reminds you of; only he can tell you."
                Ask := "And the Bell? What does it mean to you?"
        # The last constellation is the last line: the lantern she kept for him, now his for her.
        LastLineAsk := "And the Lantern, Walt? What does it mean?"
        LastLineCue := "The tide is turning, and he has to go. The last constellation hangs low over the harbour, shaped like a lantern. The fright comes back now he's really going: tell him you're frightened, and ask him what the Lantern means to him. Don't say what it is or what it reminds you of; only he can tell you. Then wait for his answer."
        GradeQuestion := "Did Walt show Nell his confidence in her by tying each constellation to a real moment in their life together?"
        GradeLines := array:
            "I'll try, Walt. I don't know that I'll manage, but I'll try."
            "I think I can see them. Some of them. I'll learn the rest."
            "I can see the way home. You put it up there for me."
        Roles := array:
            # She doesn't know him yet: the second ask shows her his face.
            casting_role{Id := "role_captain_walt", Label := "Captain Walt Price / her husband", LogEdit := "You stand in the dark beside her as the captain of the Eleanor.", ContextLine := "The visitor is the captain of the Eleanor, standing beside you in the dark. You've heard his voice all night and never seen his face. You don't know who he is yet."}
        Want := "To keep Walt with her."
        Obstacle := "He can't stay. She has to go on without him, and she doesn't believe she can."
        SendIn := "This time you're Walt. The captain. You know what happened to him, and so does she, underneath. Give her something to steer by. Enter the dream when you're ready."
        RoleFile := array:
            "AGE  74"
            "YOU ARE  Captain of the Eleanor. Married to Nell 50 years. You're retiring tonight; the boat is hers."
            "TONIGHT  She hasn't seen your face yet. When she asks what the cheering's for, tell her: she's the captain now."
            "MET  At a dance at the Seamen's Hall. She trod on your feet all night and apologised for every one."
            "THE NETS  Your first winter married, she mended your nets at the kitchen table, faster than you ever could."
            "KNITTING  A jumper every winter for 50 years. You were wearing one in October."
            "TEACHING  40 years at Abbey Lane Primary. 200 old students came to her retirement do."
            "THE STORM  Your first year married, she kept a lantern in the window till dawn. You steered home by it."
            "YOU ALWAYS SAID  \"You're the most capable person I know, Nell.\" She always said, \"Don't be daft.\""
            "TIP  She'll ask what each star means to you. Tie it to a moment from your life: what that part of her means to you. Show her when she already did it."
        Settings := array{}
        Items := array{}
        FactRevealed := "Walt took the Eleanor out one morning last October, and she came back without him. He was the one who always told me I could. I thought that went down with him. It didn't. It's up there, all of it. I can find my own way home."
        PositiveLine := "I can see the way home."
        MixedLine := "I can see a few of them. Not enough yet."
        NegativeLine := "There's nothing up there. Don't go."
        GoodEndingLog := array:
            "He squeezes her shoulder, and steps back."
            "He walks down the gangway, and this time he looks back."
            "The constellations stay lit over the harbour."
            "She takes the wheel. The crew cast off."
            "The Eleanor turns for open water, steering by the stars."
            "Her heart slows down."
        ClearedLog := array:
            "Dream 2 is clear. The session fault is resolved."
            "Recovered: the captain was Walter Price, lost with the Eleanor last October."
            "Recovered: the core fear. Not that he was gone. That she couldn't go on without him."
            "The loop has ended. Nell can sleep."
        BadEndingLog := array:
            "He walks down the gangway into the dark."
            "The stars go out one by one."
            "She stands at the wheel and can't make it turn."
            "The harbour lights go out."
            "The dream starts over."

MakeNellAltClient()<transacts>:client =
    client:
        Id := "nellalt"
        Name := "PRICE, ELEANOR M.  AKA \"NELL\""
        Tagline := "71  /  RETIRED TEACHER"
        CaseFile := array:
            "NELL  Eleanor Price, 71. Taught at Abbey Lane Primary for 40 years. Retired 6 years."
            "WALT  Her husband. A fisherman. His boat is the Eleanor, named for her."
            "DANNY  Danny Ruiz, 38. Her student, Year 3. She taught him to read at lunchtimes."
            "-- PERSONALITY --"
            "Willing. Says yes before she's asked twice."
            "Doubts herself. Sure she'll let people down."
            "Can't hear a compliment. \"Oh, anybody could have done that.\""
            "Believes a real example. Not flattery."
            "-- LIKES --"
            "Knitting. A scarf for every child in every class, every winter."
            "Letters from old students. She keeps them all in a biscuit tin."
            "Being useful."
            "-- DISLIKES --"
            "Fuss. Being thanked."
            "Letting anyone down."
            "Being told she's clever. \"Don't be daft.\""
        Dreams := array:
            MakeNellAltDream1()
            MakeNellAltDream2()
        StartTrust := 2
        StartFear := 2
        StartHope := 1
        StartMood := "willing, frightened, sure she'll fail"
