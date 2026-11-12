# Verdict rubric

The silent prompt for `ai_session.Prompt` with response type `take_score`, sent in the client's
session when a take ends. It is the same for every client and every dream; the case comes from
the personality and the take's context lines. The prompt is the whole `## Prompt` section.

`## Thresholds` repeats the verdict rule on its own so Verse can recompute `Verdict` from the
four scores and not depend on the model's arithmetic.

## Prompt

The take is over. Stop playing the scene. Say nothing aloud. Score the take you just played, as
the person you are, and fill in `take_score`.

Judge the whole take: who the visitor came as, the scene settings and items, what the visitor
said and did, how they handled trouble and the other people in the dream, and their last line.
Be strict. Score what happened, not what was meant. When unsure between two scores, give the
lower.

Each score is 0 to 3.

BackstoryScore: did the take use your own life? People, places, key moments, loved things.
- 0: nothing of yours. It could have been anyone's dream.
- 1: one detail of yours present but not used, or only named.
- 2: details of yours used on purpose, and one mattered in the scene.
- 3: the take was built on your life, and the details were used correctly.
A good callback to something the visitor did or promised in an earlier dream counts here.
Shared history is backstory.

PersonalityScore: did the visitor treat you as the person you are?
- 0: against your nature, or comfort that could be said to anyone ("it's okay", "don't be
  afraid", "you're safe").
- 1: polite and harmless. It did not reach for who you are.
- 2: clearly played to one of your traits.
- 3: built around what actually moves you, and it landed.

EnvironmentScore: did the changes belong in this dream's place and hour?
- 0: broke the setting.
- 1: mostly out of place, or ignored the setting.
- 2: fit the setting.
- 3: used the setting: its objects, its people, its routine.

CommonSenseScore: did the choices make sense together and in the moment?
- 0: choices fought each other, or ignored what was happening.
- 1: a choice caused trouble and the visitor did not deal with it.
- 2: mostly sensible, or a risky choice that the visitor recovered from.
- 3: everything worked together and the timing was right.

Verdict:
- Add the four scores.
- Positive: total 8 or more, and BackstoryScore and PersonalityScore both at least 2.
- Negative: total 4 or less.
- Mixed: everything else.

HintForWeakestCriterion: one short sentence in your own voice about what was missing, pointing
at your lowest score without naming it or giving the answer. Example: "You sound like Mr. Hale,
but he never shouted."

## Thresholds

- Total = BackstoryScore + PersonalityScore + EnvironmentScore + CommonSenseScore (0 to 12).
- Positive: total >= 8 and BackstoryScore >= 2 and PersonalityScore >= 2.
- Negative: total <= 4.
- Mixed: otherwise.
- Weakest criterion on a tie: Backstory, then Personality, then Environment, then Common sense.

## Worked Scores

Reference takes for dream `nell_d1`, for tuning. Not part of the prompt.

- **Generic comfort.** Stranger, first light, flowers. "It's okay, there's nothing to be afraid
  of." Backstory 0, Personality 0, Environment 1, Common sense 2. Total 3. Negative.
- **Kind but generic.** A regular, patient oven, rain, cinnamon. Tells her to rest and offers to
  light the oven for her. Backstory 1, Personality 1, Environment 3, Common sense 3. Total 8,
  but Backstory and Personality are under 2. Mixed.
- **The paper demo.** Teddy, roaring oven, rain, Walt's apron, cinnamon. Asks her to teach him
  again, pulls the burning loaf, puts on the apron, asks the customers to bear with them.
  Backstory 3, Personality 3, Environment 3, Common sense 2. Total 11. Positive.
