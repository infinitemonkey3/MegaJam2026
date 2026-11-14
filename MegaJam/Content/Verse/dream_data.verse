using { /UnrealEngine.com/Temporary/Diagnostics }

# Data shapes for Dead Air, plus one placeholder client so the flow can run before the
# writing lands. NOT COMPILED YET: see CLAUDE.md in this folder for what is unverified.
#
# Two kinds of text live here:
#  - `message` fields are filled by the LLM (ai_session.Prompt / RegisterAction). Their shapes
#    come from docs/design.md and should only change with it.
#  - `string` fields are authored text. Strings can be written inline and joined freely;
#    ToMessage turns one into a `message` at the persona API edge.

# One log channel for the whole game. Read it with SessionToolset.GetVerseOutput.
dead_air_log := class(log_channel){}

# Wraps authored text as a message for the persona API. Module-level because <localizes>
# can't be an inline literal.
ToMessage<localizes>(Text:string):message = "{Text}"

# ---------------------------------------------------------------------------------------------
# LLM response shapes (docs/design.md: "The client's verdict", "Continuity", "Narration and voice")
# Field and type names guide the model, so renaming one changes what the model writes.
# ---------------------------------------------------------------------------------------------

take_verdict := enum{Positive, Mixed, Negative}

take_score := struct:
    BackstoryScore:int        # 0-3
    PersonalityScore:int      # 0-3
    EnvironmentScore:int      # 0-3
    CommonSenseScore:int      # 0-3
    Verdict:take_verdict
    HintForWeakestCriterion:message

scene_update := struct:
    Distress:int              # 0-3, drives the haze
    LogLine:message           # one terse debug-log line, e.g. "LOAF removed / SMOKE clearing"

client_state := struct:
    Trust:int                 # 0-3, in the visitor
    Fear:int                  # 0-3
    Hope:int                  # 0-3, that the loop can end
    Mood:message              # one short phrase, e.g. "wary but softening"

# Filled after a good ending of a dream with AsksForCake (Chip, 2026-11-13): what the player, as
# Walt, said in Nell's dream 2. Dreams with UsesCake bake that cake, and remember the Saturday he
# promised her (2026-11-14), so the player can call back to it.
birthday_cake := struct:
    CakeWaltAskedFor:message        # a few words, like "a lemon cake"
    SaturdayWaltPromised:message    # one short sentence, like "a walk by the river, then the pictures"

take_memory := struct:
    WhoTheVisitorWas:message        # the role as the client understood it
    KeyMoments:[]message            # at most 3, one sentence each
    PromisesOrRequests:[]message    # things said that could be called back to
    State:client_state              # how the client feels at the end of this take

# ---------------------------------------------------------------------------------------------
# Authored shapes
# ---------------------------------------------------------------------------------------------

# How much a setup choice pushes on the client's trauma. Sets the haze's base level for the take.
risk_level := enum{Safe, Risky, Dangerous}

RiskToHaze(Risk:risk_level)<transacts>:int =
    case (Risk):
        risk_level.Safe => 0
        risk_level.Risky => 1
        risk_level.Dangerous => 2

# Casting: who the client thinks the player is.
casting_role := class:
    Id:string
    Label:string              # shown on the directing menu
    LogEdit:string            # log line shown when the take starts
    ContextLine:string        # told to the client at take start

# One scene setting. Element groups the options that exclude each other (oven, weather, ...).
scene_setting := class:
    Id:string
    Element:string
    Label:string
    LogEdit:string
    ContextLine:string
    Risk:risk_level = risk_level.Safe

# An item from the case file that the player brings into the dream.
inject_item := class:
    Id:string
    Label:string
    LogEdit:string
    ContextLine:string
    Risk:risk_level = risk_level.Safe

# One step of the loop replay in the observe phase.
loop_beat := class:
    LogLine:string
    Murmur:string = ""        # what the client mutters over this beat, if anything
    HoldSeconds:float = 2.5

# A beat of the take: the scene moves on to its next part (Chip, 2026-11-13: without it the
# client stayed on the first task, the dough, for the whole take). Beats advance by turns, not
# time (2026-11-14: a timer made her talk over the player): after TurnsPerBeat answers from the
# player and her replies, the next beat is told to her.
take_phase_beat := class:
    LogLine:string            # prose for the dream debugger's log
    Context:string            # what's now happening, for the client: "It's time to ..."

dream := class:
    Id:string
    Title:string
    LoopNote:string           # the case file's note on the loop
    Personality:string        # SetPersonality text for this dream (dream self, rules, setting)
    LoopBeats:[]loop_beat     # prewritten replay; the last beat is where the loop always ends
    EndingBeatLog:string      # log line for "the moment the loop always ends" during a take
    LastLineCue:string = ""   # told to the client at the last line, so she asks for it; the player's answer is the last line
    TakePhases:[]take_phase_beat = array{} # the take's clock: what part of the scene comes next
    Roles:[]casting_role      # one role: the dream assigns it and the director sends you in as it
    # The improv prompt the player is sent in with (Chip, 2026-11-13): who you are (the one role),
    # what the client wants, and what's in the way. Shown at the top of the case file; Want and
    # Obstacle also go to the client, who states her want early.
    Want:string = ""
    Obstacle:string = ""
    SendIn:string = ""        # the director's prerecorded send-in line ("<dream id>_sendin"); the text is for the writing
    RoleFile:[]string = array{} # what the player's role knows, shown before ENTER DREAM, to learn like the case file
    AsksForCake:logic = false # a good ending asks the session which birthday cake was named
    UsesCake:logic = false    # the client and the case file get that cake (a lemon cake if none was named)
    Settings:[]scene_setting
    Items:[]inject_item
    PositiveLine:string       # the client's verdict lines, spoken with PromptToTalk
    MixedLine:string
    NegativeLine:string
    GoodEndingLog:[]string    # authored good ending: scene lines, told by the client
    ClearedLog:[]string = array{} # after a good ending: the debugger's notes, shown, not told
    BadEndingLog:[]string     # authored bad ending
    FactRevealed:string       # what a positive verdict gives up; joins the facts for later dreams
    TurnsPerBeat:int = 2      # player answers before the scene moves to the next beat; after the last beat, the last line
    # The client moves the beats on herself (a list of questions she asks in turn); the flow only
    # counts answers and logs each beat, and never prompts her (2026-11-14: a prompted question
    # came on top of the one her reply had already asked, so she asked it twice).
    ClientLeads:logic = false

client := class:
    Id:string
    Name:string
    CaseFile:[]string         # entries shown on the screen
    Dreams:[]dream            # in play order
    StartTrust:int = 1
    StartFear:int = 1
    StartHope:int = 1
    StartMood:string = "guarded"

# The player's choices for one take. Build it with MakeTakeSetup so the caps hold.
take_setup := struct:
    Role:casting_role
    Settings:[]scene_setting  # at most MaxSettings
    Items:[]inject_item       # at most MaxItems

MaxSettings:int = 2
MaxItems:int = 2

FirstN(Input:[]t, Count:int where t:type)<transacts>:[]t =
    if (Head := Input.Slice[0, Min(Count, Input.Length)]):
        Head
    else:
        Input

MakeTakeSetup(Role:casting_role, Settings:[]scene_setting, Items:[]inject_item)<transacts>:take_setup =
    take_setup:
        Role := Role
        Settings := FirstN(Settings, MaxSettings)
        Items := FirstN(Items, MaxItems)

# The haze base level for a setup: its riskiest choice.
SetupHazeBase(Setup:take_setup)<transacts>:int =
    var Highest:int = 0
    for (Setting : Setup.Settings):
        set Highest = Max(Highest, RiskToHaze(Setting.Risk))
    for (Item : Setup.Items):
        set Highest = Max(Highest, RiskToHaze(Item.Risk))
    Highest

# ---------------------------------------------------------------------------------------------
# Des, the slice's patient (writing/des/case-file.md). The case file is the file's "Screen"
# section, as the dream debugger shows it: header, personality, likes, dislikes, key moments
# (ANOMALY flags kept, the "Pays off" notes for us left out) and the loop note. The hidden fact
# sheet unlocks by dream and isn't here. Dream 1 is MakeDesDream1 (des_data.verse); dreams 2
# and 3 are the placeholder dream under locked titles until they're written.
# ---------------------------------------------------------------------------------------------

MakeDesClient()<transacts>:client =
    client:
        Id := "des"
        Name := "VARRO, DESSEN  AKA \"DES\""
        CaseFile := array:
            "SUBJECT  VARRO, DESSEN  AKA \"DES\""
            "AGE  13"
            "IMPLANT  VOXA CLEAR / SPEECH ASSIST / 2ND-HAND / WARRANTY NONE"
            "FAULT  PERSISTENT SESSION FAULT / 11 NIGHTS"
            "PACKAGE  HERO HOUR (KIDS) / LICENSED: GALE RIDER"
            "BROUGHT IN  VARRO, MAREN (MOTHER)"
            "-- PERSONALITY --"
            "P-01  Quiet at school. Loud at home, before."
            "P-02  Watches a room before he speaks in it."
            "P-03  Funny when he forgets to be careful."
            "P-04  Hates being singled out. Fine in a crowd that's doing the same thing."
            "P-05  Answers to \"Des\". Teachers use \"Dessen\"."
            "-- LIKES --"
            "L-01  Gale Rider. A kids' show. Ages 5 to 8 on the box. He is 13."
            "L-02  Drawing Gale Rider, in the margins of every school book."
            "L-03  Being in on a joke. Not being the joke."
            "L-04  His father. Listed by subject as \"favorite person\". Same answer since age 6."
            "L-05  Flying, in the hero package. Logged hours: 214."
            "-- DISLIKES --"
            "D-01  Assemblies. Absent from 6 of the last 9."
            "D-02  Being asked to repeat himself."
            "D-03  His mother talking footing near the school gate."
            "D-04  Being told he's doing fine."
            "-- KEY MOMENTS --"
            "K-01  Born in the Footings, Lower Varr ward. No sky on record."
            "K-02  1 yr ago. Household moved upside, to the surface, for the father's work. Assistance placement, Corran Heights School. Eighth grade."
            "K-03  8 mo ago. After the move. Implant fitted. Gift from father, VARRO, ANSEL. Reason given at purchase: \"So he sounds like them.\""
            "K-04  ANOMALY  Speech faults since fitting: 1,140. 71% between 18:00 and 19:30."
            "K-05  ANOMALY  Speech faults during hero play: 0."
            "K-06  ANOMALY  Hero catchphrase, as spoken by subject: \"Keep yer brann lit. I'll bring the day down.\" No match in show transcripts, 412 episodes."
            "K-07  ANOMALY  Hero package costume: cape. Material: old dark wool, hem cut ragged, worn inside out. Embroidery on the hidden face, not read. Not licensed merchandise."
            "K-08  Father works upside. Three jobs on record. Leaves home 05:10, before subject wakes. Brann-hang attendance, last 2 winters: 0."
            "K-09  ANOMALY  Brann-hang, last winter: household Varro hung 3 lamps. One tag reads \"DESSEN\". Subject not present."
            "-- LOOP --"
            "LOOP  SCENE school_assembly / START T 08:40 / END T 08:44 / END STATE lights=off"
            "RUNS  11 NIGHTS / NO VARIATION"
            "VITALS  HEART RATE CLIMBS FROM 08:41 / SPEECH FAULTS CLIMB WITH IT"
            "AUDIO  CROWD LAUGHTER / SOURCE NOT RENDERED"
            "CAST  1 PRINCIPAL / 120 EXTRAS, FACES NOT RENDERED"
            "DEPTH  3 LAYERS DETECTED / LAYER 1 ACTIVE / LAYERS 2-3 LOCKED"
        Dreams := array:
            MakeDesDream1()
            MakePlaceholderDream("des_d2", "LAYER 2  [LOCKED]", "The implant chokes on the words his family gave him.")
            MakePlaceholderDream("des_d3", "LAYER 3  [LOCKED]", "What he never faced is what he did to his mother at the gate.")
        StartTrust := 1
        StartFear := 2
        StartHope := 1
        StartMood := "ready to be laughed at"

# ---------------------------------------------------------------------------------------------
# Placeholder content, from the Nell paper demo in docs/design.md. The writing stream's text in
# writing/ replaces this. The same dream is used three times so the three-dream flow can run.
# ---------------------------------------------------------------------------------------------

MakePlaceholderClient()<transacts>:client =
    client:
        Id := "nell"
        Name := "Eleanor \"Nell\" Price"
        CaseFile := array:
            "Eleanor \"Nell\" Price, 71. Baker. Proud, dry-humored, softens when someone needs her."
            "Ran Price's Bakery with her late husband Walt, who whistled while he kneaded."
            "Taught Walt's nephew Teddy to bake when he was a kid."
            "Orders a cake every March 3 and never lets it be picked up."
            "Won't let anyone whistle in the shop."
            "Heart rate rises at 5 AM."
        Dreams := array:
            MakePlaceholderDream("nell_1", "Dream 1: 5 AM", "March 3 was Walt's birthday.")
            MakePlaceholderDream("nell_2", "Dream 2 (placeholder copy)", "The morning of Walt's funeral she opened alone and burned every loaf.")
            MakePlaceholderDream("nell_3", "Dream 3 (placeholder copy)", "The birthday cake was for Walt. Nobody picked it up.")
        StartFear := 2

MakePlaceholderDream(Id:string, Title:string, Fact:string)<transacts>:dream =
    dream:
        Id := Id
        Title := Title
        LoopNote := "5 AM at the bakery. The oven won't light. It always ends with the lights going out."
        Personality := "You are Nell Price, 71, a proud, dry-humored baker, dreaming. It is 5 AM in your bakery and the oven won't light. Faceless customers press at the glass. The dough won't hold. There is no whistling. You do not know you are dreaming. Speak only dialogue, one to three short sentences. Never describe actions or the scene aloud; put any action in the scene log line instead. If the visitor or the scene pushes on a painful memory, let the dream turn dark and give the visitor a moment to respond."
        LoopBeats := array:
            loop_beat{LogLine := "SCENE bakery_interior / T 05:00 / OVEN state=cold / CUSTOMERS count=11 faces=null", Murmur := "It won't light. Why won't it light."}
            loop_beat{LogLine := "T 05:02 / DOUGH state=slack / AUDIO whistling=absent", Murmur := "It's too quiet in here."}
            loop_beat{LogLine := "T 05:04 / CUSTOMERS pressing=glass / HEART rate=rising", Murmur := "I'm not ready. Tell them I'm not ready."}
            loop_beat{LogLine := "T 05:05 / LIGHTS state=out / LOOP restart"}
        EndingBeatLog := "T 05:05 / LIGHTS state=flickering / LOOP end_imminent"
        Roles := array:
            casting_role{Id := "stranger", Label := "A stranger", LogEdit := "CAST visitor=unknown", ContextLine := "The visitor is a stranger who has walked into the shop."}
            casting_role{Id := "teddy", Label := "Teddy, Walt's nephew", LogEdit := "CAST visitor=teddy_price", ContextLine := "The visitor is Teddy, Walt's nephew, who you taught to bake when he was a boy."}
            casting_role{Id := "customer", Label := "A regular customer", LogEdit := "CAST visitor=regular", ContextLine := "The visitor is one of your regulars from years ago."}
        Settings := array:
            scene_setting{Id := "oven_warm", Element := "oven", Label := "Oven: warm", LogEdit := "OVEN state=warm", ContextLine := "The oven is lit and gently warm."}
            scene_setting{Id := "oven_roaring", Element := "oven", Label := "Oven: roaring", LogEdit := "OVEN state=roaring", ContextLine := "The oven is roaring hot, and the bread is close to burning, the way it did the morning of the funeral.", Risk := risk_level.Dangerous}
            scene_setting{Id := "weather_rain", Element := "weather", Label := "Weather: rain", LogEdit := "WEATHER state=rain", ContextLine := "Rain runs down the shop window."}
            scene_setting{Id := "weather_clear", Element := "weather", Label := "Weather: clear dawn", LogEdit := "WEATHER state=clear", ContextLine := "A clear dawn is coming up outside."}
        Items := array:
            inject_item{Id := "walt_apron", Label := "Walt's apron", LogEdit := "INJECT item=walt_apron", ContextLine := "Walt's flour-stained apron hangs on its hook by the oven.", Risk := risk_level.Risky}
            inject_item{Id := "cinnamon", Label := "Cinnamon", LogEdit := "INJECT item=cinnamon", ContextLine := "The shop smells of cinnamon."}
            inject_item{Id := "music_box", Label := "A music box", LogEdit := "INJECT item=music_box", ContextLine := "A music box sits on the counter. You have never seen it before."}
        PositiveLine := "I'm feeling a bit better."
        MixedLine := "Something about this feels familiar..."
        NegativeLine := "I'm confused."
        GoodEndingLog := array:
            "AUDIO whistling=present source=nell"
            "CUSTOMERS faces=resolved / LOOP exit"
        BadEndingLog := array:
            "OVEN state=burning / SMOKE rising"
            "LIGHTS state=out / HEART rate=spike / LOOP restart"
        FactRevealed := Fact
