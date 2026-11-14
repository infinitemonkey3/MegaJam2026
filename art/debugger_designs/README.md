# Dream Debugger redesigns (2026-11-14)

Three layouts to choose from. Each one has six states, plus the same mockups pasted into the monitor:

| State | A | B | C |
|---|---|---|---|
| Case file (MORE, ATTACH) | `A_casefile.png` | `B_casefile.png` | `C_casefile.png` |
| Scene log (her line, CONTINUE) | `A_scenelog.png` | `B_scenelog.png` | `C_scenelog.png` |
| Your turn to speak | `A_speak.png` | `B_speak.png` | `C_speak.png` |
| Menu (ATTACHED) | `A_menu.png` | `B_menu.png` | `C_menu.png` |
| Finale: Lumi awake | `A_lumi_awake.png` | `B_lumi_awake.png` | `C_lumi_awake.png` |
| In the monitor | `A_in_monitor*.png` | `B_in_monitor*.png` | `C_in_monitor*.png` |

Every design keeps `T_Debugger_TitleBar` as the top bar. Lumi's off state is in every non-finale mockup.

**How these were made.** The mockups are 1200 x 908, the glass's aspect: I measured the glass at
618 x 468 px in the screenshot, so 1.32 : 1, a bit wider than the 1.2 in the brief. They keep a
60 / 40 px safe margin, about 5% of the glass, on every side. The text is Noto Sans (from
`C:\Windows\Fonts\NotoSansJP-VF.ttf`, which has the same Latin glyphs as Fortnite's NotoSans) in
weights 400-800, so it should look the same in UMG. At 1080p the glass is about 860 px wide, so the
mockups shrink by about 0.72 on screen: 28 px body text comes out at about 20 px. To re-render, run
`python src/mock.py`, then `python src/speak.py`.

**Rules for all three designs:**
- Draw shapes (triangles, the mic, Lumi's face, the meter blocks) as UMG Images or Borders, never
  as glyphs. Fortnite's NotoSans may not have ▶ or ■.
- Put a page's body text in one text block per entry, with auto-wrap and a fixed wrap width. That
  replaces `WrapText` and the 72-column rows. Page the file by entries per page, not by lines.
- Make hotspots fixed rectangles per element, in fractions of the page, from one table in Verse
  (`AddHotspot(Root, X0, Y0, X1, Y1, Action)`), instead of row index / 18. The focused element
  shows its focus state through a field (see each design), instead of the `>` cursor in the text.
- "Your turn to speak" is a third kind of body state, beside CONTINUE and the menu. It isn't a
  button, because the take sets input mode None while the player talks. It looks different from
  CONTINUE in every design: it uses its own colour (sky blue `#6ccff6`, used nowhere else), a mic
  icon, a "live" wave, no button shape, and no click hints.

---

## A: "Wonderwell app" (cards and pills)

Polished vendor software that happens to be cracked. Each kind of information gets its own rounded card.

- **Wall of text:** each case-file entry is its own row: a tag on the left (NELL, WALT, with
  ORDER in gold), wrapped text in a fixed column on the right, and a thin rule between entries.
  Four entries per page.
- **Buttons:** the primary button (ATTACH, CONTINUE) is a filled gold pill with a cream focus
  ring. The secondary button (MORE 1/3) is a teal outline pill. Menu options are full-width cards
  with a second line underneath, and the focused one is gold. Page dots show where you are in the file.
- **Fits the glass:** a 5% safe margin all round, and everything sits on a single column grid.
- **Lumi:** a full-width pill right under the title bar. Off, it's grey: a sleeping face,
  "story guide", and a DISABLED outline tag. On (finale), it's lavender with a glow, a smiling
  face, "I'm here." and a green ONLINE pill. In the finale the body card turns lavender and fills with log spam.
- **Patient:** moved below the Lumi bar into a card with a coral edge. "PATIENT" sits above the
  name as a small label, and the name is 38 px heavy cream with a coral "AKA NELL" chip. The
  card's right side shows DREAM 3 and the current state (CASE FILE, LAYER 3, ATTACHED).
- **Scene log:** a TAKE 1 pill, the layer title, and a 3-block VITALS meter top right. The
  previous line is dimmed. Her current line is 44 px. The PROMPT callout and CONTINUE go
  underneath. In the speak state, a sky-blue "YOUR TURN" banner with a mic takes CONTINUE's place
  under her line.

**Palette:** glass `#0b1418`, card `#13232a`, card 2 `#1a2f37`, rule `#26414a`, text `#efe6d2`,
muted `#8fa5ab`, dim `#56696f`, teal `#5fd4c8`, gold `#f2b84b`, coral `#ef6f5e`, Lumi
`#c8b8ff` on `#2a2452`, online `#7ef0a8`, speak `#6ccff6`.

**To build (UW_DebuggerText rebuilt, about 4-5 h):**
- **UMG:** replace the 18 rows with a Vertical Box: the title bar image, `LumiBar` (Border with a
  rounded brush, a face Image, two texts and a pill Border), `PatientCard` (Border with
  `PatientName`, `PatientAka` and `StateLabel`), and `Body` (a Widget Switcher with four pages:
  File, Log, Menu, Speak), then the footer buttons and the hint.
    - The File page is 4 entry slots. Each slot is a tag Border and text, plus a value text with
      auto-wrap.
    - Each button is a Border holding a text.
- **States:** off/on (Lumi), focused/unfocused (buttons) and the active body page are driven
  either by bound fields (logic or int to visibility or switcher index), or by two copies of the
  widget with float fields bound to Render Opacity.
    - I didn't check which View field types UEFN accepts here. Today's code only uses
      `message`, so check that first.
- **Verse (`dream_debugger_ui.verse`):** `SetRow` / `SetTab` become named setters
  (`SetPatient`, `SetLumi`, `SetEntry(Slot, Tag, Text)`, `SetLog(Prev, Current, Prompt)`,
  `SetMenu`, `SetVitals`, `SetSpeak`).
    - Case-file lines split at the first double space into tag and value. `nell_data` already
      writes them as `"WALT  Her husband..."`.
    - Hotspots come from a rect table: MORE, ATTACH, CONTINUE, menu option 0-2.
- **Speak state:**
    - Add `ShowSpeakCue(Ask:message)` and `HideSpeakCue()` to the `debug_screen` interface.
    - `take_flow` calls them around `Control.AwaitPlayerLine` in `RunBeats` and `DoLastLine`.
    - The Ask text defaults to "What do you have to say?".
    - The mic and wave are images. A slow opacity pulse on the wave is optional.

---

## B: "Boxed terminal" (TUI panels, inverse video)

Leans into the cracked, unregistered look: boxed panels with tabbed titles, inverse-video
highlights, faint scanlines, and a Lumi "dock" at the bottom like a terminal status line.

- **Wall of text:** two columns. A sidebar holds the facts that stay put (PATIENT, then SESSION:
  dream, layer and title, take, vitals). The main panel holds what you read. Entry labels are
  amber caps followed by a rule, with the text on the line underneath.
- **Buttons:** boxes. The focused one is solid amber with a ▶ and a drop-shadow block. The others
  are teal outlines, and MORE carries a 1/3 key-cap. Menu options are full-width boxes with
  number key-caps. Nothing else on screen is a solid box, so solid means "press me".
- **Fits the glass:** every panel sits inside the 5% margin, and panel titles sit on the frame
  line, so they don't use up rows.
- **Lumi:** a full-width dock at the bottom, above the hint line. Off, it's dim with diagonal
  hazard-tape hatching (a tiled image) and a DISABLED box. On, it's a solid glowing lavender bar
  with dark text, "I'm here." and ONLINE. In the finale the main panel's frame turns lavender and
  the sidebar fades to dim.
- **Patient:** in its own sidebar box beside the content, not under the title bar. The name is
  inverse video (navy on an amber block), 30 px heavy, over two lines, with AKA "NELL" and
  71 / BAKER underneath.
- **Scene log:** older lines are dim. Her current line has an amber gutter bar and a block caret.
  Then a PROMPT sub-box, then CONTINUE. In the speak state an "AWAITING VOICE INPUT" panel
  appears: cyan frame, solid cyan mic tab, blinking caret, and "HOLD TALK KEY" with an arrow
  pointing left to the voice panel.

**Palette:** glass `#081210`, frame `#3fb8a6`, dim frame `#1f4a45`, amber `#f4b942`, text
`#e9e2cc`, muted `#86a39d`, dim `#3e5a56`, ink `#081210`, vitals `#e0584e`, Lumi `#d6c3ff`,
speak `#6ccff6`. Scanlines: black at 5% every 4 px.

**To build (UW_DebuggerText rebuilt, about 5-6 h, the most work):**
- **UMG:** a Horizontal Box with a fixed-width sidebar (two panel Borders, each with an outline
  brush and a title Border overlapping the top edge) and a main panel (a Border holding a Widget
  Switcher of File / Log / Speak / Menu pages).
    - The dock is an Overlay: hatch image, then the label strip, then the status box, with an
      on-state copy on top.
    - A scanline image tiles over the whole page.
- **Verse:** the same named setters as A. Sidebar fields: `Dream`, `Layer`, `LayerTitle`,
  `Take`, and a vitals int (or 3 opacity floats). The `TakeTitle` text splits into the
  sidebar's layer and take fields instead of one row.
    - Hotspots: the same rect table as A.
    - MORE and ATTACH sit side by side, so their rects split the row (X0 / X1), which
      `AddHotspot` already supports.
- **Speak state:** the same `ShowSpeakCue` / `HideSpeakCue` hook as A. The caret blink is
  optional (a Verse loop toggling one float).

---

## C: "Typographic" (minimal, big type, one accent)

No cards and no boxes. Big type, lots of space, and gold as the only accent, used only on things
that matter (the patient's name, the primary button, the focused option).

- **Wall of text:** entry tags are small, letter-spaced gold caps in a left column. Values are
  28 px in a wide right column. The scene log is centred: her line at 54 px, the prompt in gold
  under it, then CONTINUE. Nothing competes with her line.
- **Buttons:** solid gold rectangles with an arrow are primary. A cream outline is secondary.
  Focus is a cream underline. The focused menu option is a full-width gold band with an arrow;
  the others are big plain text with a number.
- **Fits the glass:** fewest elements of the three. Everything is left-aligned to the margin or
  centred.
- **Lumi:** the divider between the patient header and the body: a hairline across the screen
  with a "LUMI · story guide | DISABLED" capsule in the middle. In the finale the divider takes
  over the screen as a lavender panel: Lumi's face, "I'm here.", ONLINE, and the log spam in
  big lavender type.
- **Patient:** under the title bar with space around it. "PATIENT" is a small label, and the name
  is 46 px heavy navy on a gold highlighter swipe, with "aka Nell, 71" beside it. It's the
  loudest thing on the page.
- **Speak state:** a big sky-blue mic in a ring, centred under her line, with "What do you have to
  say?" at 38 px and "◂ Hold your talk key to speak" under it. CONTINUE never looks like that.

**Palette:** glass `#0b1418`, text `#f1e9d6`, muted `#7f9196`, dim `#3f5056`, rule `#22343a`,
gold `#f2c14e`, highlight text `#0b1418`, vitals `#ef6f5e`, Lumi `#c3b1ff` on `#221d40`, speak
`#6ccff6`.

**To build (UW_DebuggerText rebuilt, about 3 h, the least work):**
- **UMG:** a Vertical Box: the title bar, a patient row (a gold highlighter image behind
  `PatientName`, which should be Size To Content, plus `PatientAka`), and the Lumi divider (a
  line image with a capsule Border).
    - Then a Widget Switcher: File (4 tag/value rows), Log (prev, current and prompt, all
      centred), Speak, Menu, and a LumiTakeover page that replaces the divider and body in the finale.
    - Then the buttons and the hint.
- **Verse:** the same named setters and rect hotspots as A. The finale's
  `SetAssistantAwake(true)` switches to the LumiTakeover page, which takes over from the log
  lines.
- **Speak state:** the same `ShowSpeakCue` / `HideSpeakCue` hook. The ring could pulse with one
  float.

---

## Recommendation

**A.** It fixes every complaint most clearly: its buttons look the most like buttons, the patient
card and Lumi bar read as separate things at a glance, and every piece is a plain UMG Border and
text. **C** is the fallback if time is short: it's the cheapest to build and still fixes
everything, though its Lumi bar is quieter while off.
