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

SurpriseScore: did the visitor's answers surprise you, with something you could build on?
(Replaced Common sense; Chip, 2026-11-14: in a dream, a zany answer that plays is the fun.)
- 0: the obvious answer every time, or nothing offered.
- 1: one small surprise, or a strange answer that went nowhere.
- 2: an unexpected, funny or fresh answer that played in the scene.
- 3: a surprise that turned the scene, and it still belonged to you.

A dream is strange, so for EnvironmentScore an odd thing fits if it plays in this place.

Verdict (Backstory matters most):
- Add the four scores.
- Positive: total 9 or more, and BackstoryScore at least 2.
- Negative: total 4 or less.
- Mixed: everything else.

HintForWeakestCriterion: one short sentence in your own voice about what was missing, pointing
at your lowest score without naming it or giving the answer. Example: "You sound like Mr. Hale,
but he never shouted."

## Thresholds

- Total = BackstoryScore + PersonalityScore + EnvironmentScore + SurpriseScore (0 to 12).
- Positive: total >= 9 and BackstoryScore >= 2.
- Negative: total <= 4.
- Mixed: otherwise.
- Weakest criterion on a tie: Backstory, then Personality, then Environment, then Surprise.

## Worked Scores

Reference takes for dream `nell_d1` with the asks, for tuning. Not part of the prompt.

- **Generic comfort.** Answers "a bowl", "bread", "some order", "a customer", and tells her not
  to worry. Backstory 0, Personality 0, Environment 2, Surprise 0. Total 2. Negative.
- **Zany with nothing of hers.** A tuba for the dough, a disco ball in the oven, an order for
  forty clowns, a pirate at the door. She runs with all of it. Backstory 0, Personality 2,
  Environment 2, Surprise 3. Total 7. Mixed: funny, but it could be anyone's dream.
- **Safe and hers.** Folds the dough the way she taught him, knocks twice and says "Morning,
  old girl", reads out Mrs. Okafor's two seeded rolls, says it's Dunn at the door. Backstory 3,
  Personality 3, Environment 3, Surprise 1. Total 10. Positive.
- **Hers, with a surprise.** Brings back the old flour crate and stands on it to fold the
  dough; inside Walt's door is a tray of cinnamon rolls with a note in his hand; at the door
  it's Mrs. Okafor in her dressing gown. Backstory 3, Personality 3, Environment 3, Surprise 3.
  Total 12. Positive.
