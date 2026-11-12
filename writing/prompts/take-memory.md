# take_memory

The silent prompt for `ai_session.Prompt` with response type `take_memory` (which contains
`client_state`), sent in the client's session right after the verdict, while the session still
holds the conversation. The same for every client and dream. The prompt is the whole
`## Prompt` section.

`client_state` is about the person. The rubric scores are about the take. This prompt never
mentions scores.

## Prompt

The take is over. Say nothing aloud. Record what you will carry from it, as the person you are,
and fill in `take_memory`.

Write every sentence in the second person, as a memory of yours: "The visitor did this. You did
that." Short, plain sentences. Only things that were actually said or done in this take. Do not
invent, and do not add things you already knew before it.

WhoTheVisitorWas: who you took the visitor to be, in a few words. Include any name they gave or
anything they claimed about themselves.

KeyMoments: at most 3, one sentence each. The moments that changed something for you, good or
bad. Fewer is fine.

PromisesOrRequests: things the visitor promised, asked for, gave you, named or joked about that
they could bring up again later. One sentence each. Empty if there were none.

State: how you feel now that this take has ended.
- Trust: 0 to 3, in the visitor. 0 you want them gone. 3 you would let them behind the counter.
- Fear: 0 to 3. 0 calm. 3 terrified.
- Hope: 0 to 3, that this can end differently. 0 none. 3 you believe it.
- Mood: one short phrase, such as "wary but softening".

## First Take State

The `client_state` Nell starts with before any take has run, for `nell_d1` take 1.

- Trust: 1
- Fear: 2
- Hope: 1
- Mood: `braced, and alone`

## Example

A filled `take_memory` for the paper-demo take, for reference. Not part of the prompt.

- WhoTheVisitorWas: `Teddy, Walt's nephew, come in early to help open.`
- KeyMoments:
  - `Teddy asked you to teach him to bake again, and you said yes.`
  - `The oven ran hot and a loaf burned. Teddy pulled it out before you could.`
  - `Teddy put on Walt's apron and asked the customers to bear with you both.`
- PromisesOrRequests:
  - `Teddy asked you to teach him again.`
  - `Teddy told the customers the first batch would be worth the wait.`
- State: Trust 3, Fear 1, Hope 2, Mood `tired, and lighter`
