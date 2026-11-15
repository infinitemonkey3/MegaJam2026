"""Dream debugger, design B ("boxed terminal"): the textures for UW_DebuggerB, and its layout.

Chip picked design B on 2026-11-14 (art/debugger_designs/README.md). The mockups bake everything
into one picture; the game can't, since the text changes. So this splits B into:
  - full-page layers (1200 x 908, the page's own size) for what never moves: the chrome
    (T_DbgB_Base), Lumi awake (T_DbgB_LumiOn, faded in by the LumiOn field), the scanlines on top;
  - small parts the widget places and stretches: button frames, the focused button, the speak
    panel, CONTINUE, a vitals block;
  - layout.json: every rectangle the widget builder (build_debugger_b.py, run in the editor) and
    dream_debugger_ui.verse (hotspots) use, so the three agree.
Text is UMG text blocks over these (NotoSans), so nothing here draws text that changes.

Run: python art/tools/make_debugger_b.py
"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "art", "debugger_designs", "src"))
import mock  # noqa: E402  (the mockup helpers: fonts, panels, Lumi's face)
from mock import F, T, TC, tw, hexc, titlebar, glow, lumi_face, W, H, MX, MY  # noqa: E402
# The page fills the monitor's glass hole, which is about 1.45 : 1 on screen (play test,
# 2026-11-14: at the mockups' 1200 the page sat letterboxed, with spare room on the right).
W = 1310
mock.W = W
# A thinner safe margin than the mockups' 60 x 40: dream_debugger_ui's hole margins already keep
# the page off the glass's rounded corners (play test, 2026-11-14: the page sat well inside).
MX, MY = 44, 18
MY_TOP = 40   # more room at the top than the bottom (Chip, 2026-11-14)
# Taller than the mockups (play test, 2026-11-14): at 908 the page left a band of glass below it.
H = 980
mock.H = H

OUT = os.path.join(ROOT, "art", "debugger_b")
os.makedirs(OUT, exist_ok=True)
B = mock.B
SPEAK = "#6ccff6"

# ---- layout (page px) ----
TB_BOTTOM = MY_TOP + round((W - 2 * MX) * mock._tb.height / mock._tb.width)
TOP = TB_BOTTOM + 30                       # panels' top edge
DOCK0 = H - MY - 98
DOCK1 = DOCK0 + 54
SX1 = MX + 300                             # sidebar right edge
PANEL_BOTTOM = DOCK0 - 22
MAIN = (SX1 + 24, TOP, W - MX, PANEL_BOTTOM)
CX0, CX1 = MAIN[0] + 22, MAIN[2] - 22     # main panel content columns
S0 = TOP + 226                             # SESSION panel top
FILE_BTN_Y = MAIN[3] - 78
MENU_Y0, MENU_STEP, MENU_H = TOP + 96, 80, 60
MENU_COUNT = 5

L = {
    "page": [W, H],
    "patient_name": [MX + 28, TOP + 32, SX1 - 28, TOP + 118],
    "patient_aka": [MX + 70, TOP + 128, SX1 - 16, TOP + 162],
    "patient_info": [MX + 18, TOP + 166, SX1 - 16, TOP + 188],
    # One row for the dream (a dream is a layer); it says DREAM, not LAYER (Chip, 2026-11-14:
    # dream is what the game is about, and layer sounds like Inception).
    "layer": [MX + 110, S0 + 34, SX1 - 16, S0 + 62],
    "layer_title": [MX + 18, S0 + 66, SX1 - 16, S0 + 96],
    "take": [MX + 110, S0 + 110, SX1 - 16, S0 + 138],
    "vitals": [[MX + 112 + i * 30, S0 + 134 + 20, MX + 112 + i * 30 + 22, S0 + 134 + 42] for i in range(3)],
    "main_tab": [MAIN[0] + 18, TOP - 14],                 # left, top; height 28, width fits the title
    "main_badge": [MAIN[2] - 18, TOP - 13],               # right, top; height 26
    "file_body": [CX0, TOP + 30, CX1, FILE_BTN_Y - 12],
    "file_more": [MAIN[0] + 20, FILE_BTN_Y, MAIN[0] + 250, FILE_BTN_Y + 54],
    "file_button": [MAIN[0] + 280, FILE_BTN_Y, MAIN[2] - 20, FILE_BTN_Y + 54],
    "log_body": [CX0, TOP + 30, CX1, MAIN[3] - 16],
    "menu_intro": [CX0, TOP + 34, CX1, TOP + 80],
    "menu": [[MAIN[0] + 20, MENU_Y0 + i * MENU_STEP, MAIN[2] - 20, MENU_Y0 + i * MENU_STEP + MENU_H] for i in range(MENU_COUNT)],
    "main_panel": list(MAIN),
    "footer_file": [MX, H - MY - 34, MX + 400, H - MY - 6],
    "footer_hint": [W - MX - 600, H - MY - 34, W - MX, H - MY - 6],
    "continue": [0, 0, 300, 60],                          # the CONTINUE part's own size (no hint beside it, Chip 2026-11-14)
    "speak": [0, 0, CX1 - CX0, 150],                      # the speak panel's own size
}


def save(im, name):
    im.save(os.path.join(OUT, name + ".png"))
    print("wrote", name, im.size)


def panel(d, box, title, col):
    """mock.B_panel, but the title tab's text is left to UMG when title is None."""
    x0, y0, x1, y1 = box
    d.rectangle(box, outline=hexc(col), width=2)
    d.line((x0, y0 + 5, x1, y0 + 5), fill=hexc(col), width=1)
    if title:
        f = F(19, 800)
        w = tw(title, f, 3) + 24
        d.rectangle((x0 + 18, y0 - 14, x0 + 18 + w, y0 + 14), fill=hexc(col))
        TC(d, x0 + 30, y0, title, f, hexc(B["ink"]), sp=3)


def base():
    c = B
    # Transparent: the monitor's own dark glass is the background, with the camera's perspective
    # and its rounded corners (a flat fill didn't match, 2026-11-13).
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    titlebar(im, MX, MY_TOP, W - 2 * MX)
    panel(d, (MX, TOP, SX1, TOP + 196), "PATIENT", c["frame"])
    d.rectangle((MX + 16, TOP + 30, SX1 - 16, TOP + 120), fill=hexc(c["amber"]))
    T(d, MX + 18, TOP + 154, "AKA", F(18, 700), hexc(c["muted"]), sp=3)
    panel(d, (MX, S0, SX1, PANEL_BOTTOM), "SESSION", c["frame"])
    for label, y in (("DREAM", S0 + 54), ("TAKE", S0 + 130), ("VITALS", S0 + 174)):
        T(d, MX + 18, y, label, F(17, 800), hexc(c["muted"]), sp=3)
    for x0, y0, x1, y1 in L["vitals"]:
        d.rectangle((x0, y0, x1, y1), outline=hexc(c["dim"]), width=2)
    panel(d, MAIN, None, c["frame"])
    # Lumi's dock, off: hazard tape, a sleeping face, DISABLED
    dbox = (MX, DOCK0, W - MX, DOCK1)
    tape = Image.new("RGBA", im.size, (0, 0, 0, 0))
    td = ImageDraw.Draw(tape)
    for x in range(MX - 60, W - MX + 60, 22):
        td.polygon([(x, DOCK1), (x + 10, DOCK1), (x + 64, DOCK0), (x + 54, DOCK0)], fill=(70, 90, 88, 60))
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rectangle(dbox, fill=255)
    im.paste(Image.alpha_composite(im, tape), (0, 0), mask)
    d = ImageDraw.Draw(im)
    d.rectangle(dbox, outline=hexc(c["dim"]), width=2)
    d.rectangle((MX + 2, DOCK0 + 2, MX + 420, DOCK1 - 2), fill=hexc(c["bg"]))
    cy = (DOCK0 + DOCK1) / 2
    lumi_face(d, MX + 34, cy, 15, False, None, c["muted"])
    TC(d, MX + 66, cy, "LUMI", F(24, 800), hexc(c["muted"]), sp=4)
    TC(d, MX + 160, cy, "story guide", F(24, 400), hexc(c["muted"]))
    w = tw("DISABLED", F(22, 800), 3) + 30
    d.rectangle((W - MX - 20 - w, DOCK0 + 10, W - MX - 20, DOCK1 - 10), fill=hexc(c["bg"]), outline=hexc(c["dim"]), width=2)
    TC(d, W - MX - 20 - w + 15, cy, "DISABLED", F(22, 800), hexc(c["muted"]), sp=3)
    return im


def lumi_on():
    """Lumi awake, over the base and the sidebar's text: the sidebar dims, the main frame and
    its tab go lavender, and the dock lights up."""
    c = B
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for box in ((MX, TOP, SX1, TOP + 196), (MX, S0, SX1, PANEL_BOTTOM)):
        d.rectangle((box[0] - 2, box[1] - 16, box[2] + 2, box[3] + 2), fill=hexc(c["bg"], 165))
        d.rectangle(box, outline=hexc(c["framedim"]), width=2)
        d.line((box[0], box[1] + 5, box[2], box[1] + 5), fill=hexc(c["framedim"]), width=1)
    for title, y in (("PATIENT", TOP), ("SESSION", S0)):
        f = F(19, 800)
        w = tw(title, f, 3) + 24
        d.rectangle((MX + 18, y - 14, MX + 18 + w, y + 14), fill=hexc(c["framedim"]))
        TC(d, MX + 30, y, title, f, hexc(c["ink"]), sp=3)
    x0, y0, x1, y1 = MAIN
    d.rectangle(MAIN, outline=hexc(c["lumi"]), width=2)
    d.line((x0, y0 + 5, x1, y0 + 5), fill=hexc(c["lumi"]), width=1)
    title = "WONDERWELL // LUMI"
    f = F(19, 800)
    w = tw(title, f, 3) + 24
    d.rectangle((x0 + 14, y0 - 16, x0 + 22 + w + 40, y0 + 16), fill=hexc(c["bg"]))   # hides the teal tab
    d.rectangle((x0 + 18, y0 - 14, x0 + 18 + w, y0 + 14), fill=hexc(c["lumi"]))
    TC(d, x0 + 30, y0, title, f, hexc(c["ink"]), sp=3)
    d.rectangle((x1 - 18 - 30, y0 - 13, x1 - 18, y0 + 13), fill=hexc(c["bg"]), outline=hexc(c["lumi"]), width=2)
    TC(d, x1 - 18 - 20, y0, "!", F(19, 800), hexc(c["lumi"]))
    dbox = (MX, DOCK0, W - MX, DOCK1)
    glow(im, dbox, 4, c["lumi"], 14, 130)
    d = ImageDraw.Draw(im)
    d.rectangle(dbox, fill=hexc(c["lumi"]))
    cy = (DOCK0 + DOCK1) / 2
    lumi_face(d, MX + 34, cy, 17, True, "#fff6dc", c["dim"])
    TC(d, MX + 66, cy, "LUMI", F(24, 800), hexc("#1b1640"), sp=4)
    TC(d, MX + 160, cy, "I'm here.", F(26, 600), hexc("#1b1640"))
    d.ellipse((W - MX - 150, cy - 7, W - MX - 136, cy + 7), fill=hexc("#1b1640"))
    TC(d, W - MX - 126, cy, "ONLINE", F(22, 800), hexc("#1b1640"), sp=3)
    return im


def scanlines():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for y in range(0, H, 4):
        d.line((0, y, W, y), fill=(0, 0, 0, 14))
    return im


def frame_part(col, fill=None, size=64, width=2):
    """A box frame for a Box brush (margins 8 px): button and badge outlines."""
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, size - 1, size - 1), fill=hexc(fill) if fill else None, outline=hexc(col), width=width)
    return im


def focus_part():
    """The focused button: solid amber with a drop block down-right (Box brush, margins 12 px)."""
    im = Image.new("RGBA", (70, 70), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle((6, 6, 69, 69), fill=hexc("#5a4210"))
    d.rectangle((0, 0, 63, 63), fill=hexc(B["amber"]))
    return im


def arrow_part():
    im = Image.new("RGBA", (16, 22), (0, 0, 0, 0))
    ImageDraw.Draw(im).polygon([(0, 0), (0, 21), (15, 11)], fill=hexc(B["ink"]))
    return im


def continue_part():
    """CONTINUE, always focused when shown (the log's only button). A click anywhere on the log
    works too, but the screen doesn't say so (Chip, 2026-11-14: no extra instruction)."""
    w, h = L["continue"][2], L["continue"][3]
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = 0, 0, 280, 54
    d.rectangle((x0 + 6, y0 + 6, x1 + 6, y1 + 6), fill=hexc("#5a4210"))
    d.rectangle((x0, y0, x1, y1), fill=hexc(B["amber"]))
    cy = 27
    d.polygon([(18, cy - 10), (18, cy + 10), (32, cy)], fill=hexc(B["ink"]))
    TC(d, 46, cy, "CONTINUE", F(24, 800), hexc(B["ink"]), sp=2)
    return im


def mic(d, cx, cy, s, col):
    w = max(3, int(s * 0.12))
    d.rounded_rectangle((cx - s * 0.22, cy - s * 0.55, cx + s * 0.22, cy + s * 0.12), s * 0.22, fill=hexc(col))
    d.arc((cx - s * 0.38, cy - s * 0.42, cx + s * 0.38, cy + s * 0.3), 0, 180, fill=hexc(col), width=w)
    d.line((cx, cy + s * 0.3, cx, cy + s * 0.5), fill=hexc(col), width=w)
    d.line((cx - s * 0.2, cy + s * 0.5, cx + s * 0.2, cy + s * 0.5), fill=hexc(col), width=w)


def speak_part():
    """The 'your turn to speak' panel; the ask itself is UMG text at (112, 52)."""
    pw, ph = L["speak"][2], L["speak"][3]
    pad = 16
    im = Image.new("RGBA", (pw + 2 * pad, ph + 2 * pad), (0, 0, 0, 0))
    bx = (pad, pad, pad + pw - 1, pad + ph - 1)
    glow(im, bx, 2, SPEAK, 12, 70)
    d = ImageDraw.Draw(im)
    d.rectangle(bx, fill=hexc("#0b2530"), outline=hexc(SPEAK), width=3)
    d.rectangle((bx[0], bx[1], bx[0] + 90, bx[3]), fill=hexc(SPEAK))
    mic(d, bx[0] + 45, bx[1] + 70, 56, B["ink"])
    T(d, bx[0] + 112, bx[1] + 40, "AWAITING VOICE INPUT", F(18, 800), hexc(SPEAK), sp=3)
    x = bx[0] + 112
    d.polygon([(x, bx[1] + 120), (x + 9, bx[1] + 113), (x + 9, bx[1] + 127)], fill=hexc(SPEAK))
    T(d, x + 16, bx[1] + 127, "HOLD TALK KEY", F(18, 800), hexc(SPEAK), sp=2)
    T(d, x + 16 + tw("HOLD TALK KEY", F(18, 800), 2) + 14, bx[1] + 127, "voice panel, left", F(19, 500), hexc("#9cd9ef"))
    hs = [0.35, 0.7, 1.0, 0.55, 0.85, 0.45, 0.25]
    for i, hh in enumerate(hs):
        hh *= 26
        x = bx[2] - 110 + i * 12
        d.rounded_rectangle((x, bx[1] + 34 - hh / 2, x + 6, bx[1] + 34 + hh / 2), 3, fill=hexc(SPEAK))
    return im


if __name__ == "__main__":
    save(base(), "T_DbgB_Base")
    save(lumi_on(), "T_DbgB_LumiOn")
    save(scanlines(), "T_DbgB_Scan")
    save(frame_part(B["frame"]), "T_DbgB_Outline")
    save(frame_part(B["frame"], fill=B["bg"]), "T_DbgB_Badge")
    save(focus_part(), "T_DbgB_Focus")
    save(arrow_part(), "T_DbgB_Arrow")
    save(continue_part(), "T_DbgB_Continue")
    save(speak_part(), "T_DbgB_Speak")
    L["colors"] = {k: B[k] for k in ("bg", "frame", "framedim", "amber", "text", "muted", "dim", "ink", "red", "lumi")}
    L["colors"]["speak"] = SPEAK
    L["colors"]["speaktext"] = "#e6f8ff"
    with open(os.path.join(OUT, "layout.json"), "w") as f:
        json.dump(L, f, indent=1)
    print("wrote layout.json")
