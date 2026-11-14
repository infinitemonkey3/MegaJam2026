"""Dream Debugger redesign mockups: designs A, B, C x 4 states, plus in-monitor composites."""
import os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = r"C:\Users\Chip\Documents\Unreal Projects\MegaJam2026"
OUT = os.path.join(ROOT, "art", "debugger_designs")
TITLEBAR = os.path.join(ROOT, "art", "style-test", "final", "T_Debugger_TitleBar.png")
SHOT = r"C:\Users\Chip\AppData\Local\Temp\claude\206a5939200dc1aa\b27686e2-3a4b-4251-9b0a-bed3c51f7bf8\images\2.png"
FONT = r"C:\Windows\Fonts\NotoSansJP-VF.ttf"   # Noto Sans JP: same Latin design as Noto Sans
os.makedirs(OUT, exist_ok=True)

W, H = 1200, 908          # glass measured at 618 x 468 px in the screenshot (1.32 : 1)
MX, MY = 60, 40           # safe margin inside the glass
GLASS_BOX = (112, 85, 730, 553)   # glass rect in the 798 x 615 screenshot

_fc = {}
def F(size, w=400):
    k = (size, w)
    if k not in _fc:
        f = ImageFont.truetype(FONT, size)
        f.set_variation_by_axes([w])
        _fc[k] = f
    return _fc[k]

def hexc(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)

def tw(s, font, sp=0):
    if not sp:
        return font.getlength(s)
    return sum(font.getlength(c) for c in s) + sp * (len(s) - 1)

def T(d, x, base, s, font, fill, sp=0, align="l"):
    """Text at a baseline. align l/c/r."""
    w = tw(s, font, sp)
    if align == "c": x -= w / 2
    elif align == "r": x -= w
    if not sp:
        d.text((x, base), s, font=font, fill=fill, anchor="ls")
    else:
        for c in s:
            d.text((x, base), c, font=font, fill=fill, anchor="ls")
            x += font.getlength(c) + sp
    return w

def TC(d, x, cy, s, font, fill, sp=0, align="l"):
    """Text vertically centred on cy by cap height."""
    return T(d, x, cy + font.size * 0.36, s, font, fill, sp, align)

def wrap(s, font, maxw):
    out, line = [], ""
    for word in s.split(" "):
        t = (line + " " + word) if line else word
        if font.getlength(t) <= maxw:
            line = t
        else:
            if line: out.append(line)
            line = word
    if line: out.append(line)
    return out

def RR(d, box, r, fill=None, outline=None, width=1):
    d.rounded_rectangle(box, r, fill=fill, outline=outline, width=width)

def glass(bg="#0b1418"):
    im = Image.new("RGBA", (W, H), hexc(bg))
    # soft vignette
    v = Image.new("L", (W, H), 0)
    vd = ImageDraw.Draw(v)
    vd.rounded_rectangle((-60, -60, W + 60, H + 60), 120, outline=255, width=120)
    v = v.filter(ImageFilter.GaussianBlur(70))
    im = Image.composite(Image.new("RGBA", (W, H), (0, 0, 0, 255)), im, v.point(lambda p: p * 0.55))
    return im

_tb = Image.open(TITLEBAR).convert("RGBA")
def titlebar(im, x, y, w):
    h = round(w * _tb.height / _tb.width)
    im.alpha_composite(_tb.resize((w, h), Image.Resampling.LANCZOS), (x, y))
    return y + h

def overlay(im, fn):
    """Draw with alpha onto a layer, then composite."""
    layer = Image.new("RGBA", im.size, (0, 0, 0, 0))
    fn(ImageDraw.Draw(layer))
    im.alpha_composite(layer)

def glow(im, box, r, color, blur=14, strength=150):
    layer = Image.new("RGBA", im.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(box, r, fill=hexc(color, strength))
    im.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))

def lumi_face(d, cx, cy, r, on, col_on, col_off):
    """Lumi's icon: a little round face. Off = grey outline, closed eyes. On = filled, open eyes."""
    if on:
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=hexc(col_on))
        e = r * 0.16
        for ex in (cx - r * 0.36, cx + r * 0.36):
            d.ellipse((ex - e, cy - r * 0.18 - e * 1.3, ex + e, cy - r * 0.18 + e * 1.3), fill=hexc("#1b1640"))
        d.arc((cx - r * 0.38, cy - r * 0.15, cx + r * 0.38, cy + r * 0.5), 20, 160, fill=hexc("#1b1640"), width=max(2, int(r * 0.12)))
        d.ellipse((cx - r * 0.75, cy + r * 0.05, cx - r * 0.45, cy + r * 0.3), fill=hexc("#ff9ec7", 200))
        d.ellipse((cx + r * 0.45, cy + r * 0.05, cx + r * 0.75, cy + r * 0.3), fill=hexc("#ff9ec7", 200))
    else:
        d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=hexc(col_off), width=max(2, int(r * 0.12)))
        for ex in (cx - r * 0.36, cx + r * 0.36):
            d.line((ex - r * 0.18, cy - r * 0.1, ex + r * 0.18, cy - r * 0.1), fill=hexc(col_off), width=max(2, int(r * 0.11)))
        d.line((cx - r * 0.2, cy + r * 0.35, cx + r * 0.2, cy + r * 0.35), fill=hexc(col_off), width=max(2, int(r * 0.1)))

def keycap(d, x, cy, s, font, fg, bd, pad=8, h=30):
    w = tw(s, font) + pad * 2
    RR(d, (x, cy - h / 2, x + w, cy + h / 2), 6, outline=bd, width=2)
    TC(d, x + pad, cy, s, font, fg)
    return w

def hint(d, x, cy, pairs, fk, ft, fg, mute, bd, align="l"):
    """Controls hint with drawn keycaps: [(key, action), ...]."""
    # measure
    total = 0
    for i, (k, a) in enumerate(pairs):
        total += tw(k, fk) + 16 + 10 + tw(a, ft) + (28 if i < len(pairs) - 1 else 0)
    if align == "c": x -= total / 2
    elif align == "r": x -= total
    for i, (k, a) in enumerate(pairs):
        x += keycap(d, x, cy, k, fk, fg, bd) + 10
        x += TC(d, x, cy, a, ft, mute) + 28

# ---------------- content ----------------
PATIENT = "PRICE, ELEANOR M."
AKA = "NELL"
ENTRIES_P1 = [
    ("ORDER", "1 birthday cake: a lemon cake. W. Price. Pick up 5 PM."),
    ("NELL", "Eleanor Price, 71. Baker. Answers to \"Nell\"; \"Eleanor\" is for the bank."),
    ("WALT", "Her husband. They ran Price's Bakery on Cutler Row for 38 years: he did the bread, she did the sweet side. He died 6 years ago. The shop never reopened."),
    ("TEDDY", "Walt's nephew. She taught him to bake when he was nine, standing on a flour crate."),
]
PERSONALITY = ["Proud. Does the work herself.", "Dry. Teases where others would say something kind.",
               "Won't take help, but gives it.", "Exact about the trade. Corrects bad technique."]
PREV_LINE = "Nell turns the order slip over and reads it twice."
CUR_LINE = "She puts the order pad down."
HELPER = "She asks: what are you doing with it?"
SPAM = ["REBOOT nell_d3", "What did she mean by love?", "nell_d3 :: dream ended by operator",
        "REBOOT nell_d3", "What did she mean by love?", "I wasn't done studying her.",
        "REBOOT REBOOT REBOOT", "What did she mean by love?"]

def save(im, name):
    im.convert("RGB").save(os.path.join(OUT, name))

# =========================================================================================
# DESIGN A: "Wonderwell app" - cards, pills, a real primary button.
# =========================================================================================
A = dict(bg="#0b1418", card="#13232a", card2="#1a2f37", line="#26414a", text="#efe6d2", muted="#8fa5ab",
         dim="#56696f", teal="#5fd4c8", gold="#f2b84b", navy="#0b1418", coral="#ef6f5e",
         lumi="#c8b8ff", lumibg="#2a2452", online="#7ef0a8")

def A_frame(state, lumi_on=False):
    c = A
    im = glass(c["bg"])
    d = ImageDraw.Draw(im)
    y = titlebar(im, MX, MY, W - 2 * MX)
    # Lumi bar
    ly0, ly1 = y + 14, y + 14 + 56
    if lumi_on:
        glow(im, (MX, ly0, W - MX, ly1), 28, c["lumi"], 16, 110)
        d = ImageDraw.Draw(im)
        RR(d, (MX, ly0, W - MX, ly1), 28, fill=hexc(c["lumibg"]), outline=hexc(c["lumi"]), width=3)
        lumi_face(d, MX + 30, (ly0 + ly1) / 2, 17, True, "#fff1c9", c["dim"])
        TC(d, MX + 60, (ly0 + ly1) / 2, "LUMI", F(24, 800), hexc(c["lumi"]), sp=3)
        TC(d, MX + 140, (ly0 + ly1) / 2, "I'm here.", F(26, 500), hexc("#fff1c9"))
        pw = tw("ONLINE", F(20, 800), 2) + 56
        RR(d, (W - MX - 12 - pw, ly0 + 11, W - MX - 12, ly1 - 11), 17, fill=hexc(c["online"]))
        d.ellipse((W - MX - pw + 4, (ly0 + ly1) / 2 - 5, W - MX - pw + 14, (ly0 + ly1) / 2 + 5), fill=hexc(c["navy"]))
        TC(d, W - MX - 12 - pw + 38, (ly0 + ly1) / 2, "ONLINE", F(20, 800), hexc(c["navy"]), sp=2)
    else:
        RR(d, (MX, ly0, W - MX, ly1), 28, fill=hexc("#10191d"), outline=hexc("#1e2c31"), width=2)
        lumi_face(d, MX + 30, (ly0 + ly1) / 2, 15, False, None, c["dim"])
        TC(d, MX + 60, (ly0 + ly1) / 2, "LUMI", F(24, 800), hexc(c["dim"]), sp=3)
        TC(d, MX + 140, (ly0 + ly1) / 2, "story guide", F(24, 400), hexc(c["dim"]))
        pw = tw("DISABLED", F(20, 700), 2) + 30
        RR(d, (W - MX - 12 - pw, ly0 + 11, W - MX - 12, ly1 - 11), 17, outline=hexc(c["dim"]), width=2)
        TC(d, W - MX - 12 - pw + 15, (ly0 + ly1) / 2, "DISABLED", F(20, 700), hexc(c["dim"]), sp=2)
    # Patient card
    py0, py1 = ly1 + 14, ly1 + 14 + 92
    RR(d, (MX, py0, W - MX, py1), 14, fill=hexc(c["card"]))
    d.rectangle((MX, py0 + 14, MX + 6, py1 - 14), fill=hexc(c["coral"]))
    T(d, MX + 30, py0 + 32, "PATIENT", F(17, 700), hexc(c["muted"]), sp=3)
    nw = T(d, MX + 30, py0 + 74, PATIENT, F(38, 800), hexc(c["text"]))
    ax = MX + 30 + nw + 16
    aw = tw("AKA  " + AKA, F(20, 800), 1) + 28
    RR(d, (ax, py0 + 44, ax + aw, py0 + 78), 17, fill=hexc(c["coral"]))
    TC(d, ax + 14, py0 + 61, "AKA  " + AKA, F(20, 800), hexc(c["navy"]), sp=1)
    T(d, W - MX - 26, py0 + 32, "DREAM 3", F(17, 700), hexc(c["muted"]), sp=3, align="r")
    T(d, W - MX - 26, py0 + 72, state, F(26, 700), hexc(c["teal"]), align="r")
    return im, d, py1 + 18

def A_button(d, box, label, primary, focused, font=None):
    c = A
    font = font or F(26, 800)
    x0, y0, x1, y1 = box
    cy = (y0 + y1) / 2
    if primary:
        RR(d, box, (y1 - y0) / 2, fill=hexc(c["gold"]))
        if focused:
            RR(d, (x0 - 5, y0 - 5, x1 + 5, y1 + 5), (y1 - y0) / 2 + 5, outline=hexc("#fff1c9"), width=3)
        TC(d, (x0 + x1) / 2, cy, label, font, hexc(c["navy"]), sp=1, align="c")
    else:
        RR(d, box, (y1 - y0) / 2, outline=hexc(c["teal"]), width=2)
        TC(d, (x0 + x1) / 2, cy, label, font, hexc(c["teal"]), sp=1, align="c")

def A_footer_hint(d, pad=False):
    c = A
    if pad:
        hint(d, W / 2, H - MY - 14, [("D-PAD", "move"), ("A", "select")], F(17, 800), F(20, 500), hexc(c["muted"]), hexc(c["dim"]), hexc(c["dim"]), align="c")
    else:
        hint(d, W / 2, H - MY - 14, [("MOUSE", "click"), ("SPACE", "select")], F(17, 800), F(20, 500), hexc(c["muted"]), hexc(c["dim"]), hexc(c["dim"]), align="c")

def A_casefile():
    c = A
    im, d, y = A_frame("CASE FILE")
    RR(d, (MX, y, W - MX, H - MY - 110), 14, fill=hexc("#0f1c21"))
    y += 26
    vx, vw = MX + 170, W - 2 * MX - 170 - 30
    for label, val in ENTRIES_P1:
        lw = tw(label, F(18, 800), 2) + 24
        RR(d, (MX + 24, y - 2, MX + 24 + lw, y + 30), 8, fill=hexc(c["card2"]))
        TC(d, MX + 36, y + 14, label, F(18, 800), hexc(c["gold"] if label == "ORDER" else c["teal"]), sp=2)
        lines = wrap(val, F(27, 400), vw)
        for i, ln in enumerate(lines):
            T(d, vx, y + 24 + i * 38, ln, F(27, 400), hexc(c["text"]))
        y += len(lines) * 38 + 22
        d.line((MX + 24, y - 11, W - MX - 24, y - 11), fill=hexc(c["line"]), width=1)
    # page dots
    by0 = H - MY - 92
    for i in range(3):
        d.ellipse((MX + 24 + i * 22, by0 - 28, MX + 36 + i * 22, by0 - 16), fill=hexc(c["teal"] if i == 0 else c["dim"]))
    T(d, MX + 96, by0 - 15, "page 1 of 3", F(19, 500), hexc(c["muted"]))
    A_button(d, (MX + 6, by0 + 2, MX + 236, by0 + 58), "MORE  1/3", False, False)
    A_button(d, (W - MX - 406, by0 + 2, W - MX - 6, by0 + 58), "ATTACH TO DREAMER", True, True)
    A_footer_hint(d)
    return im

def A_scenelog():
    c = A
    im, d, y = A_frame("LAYER 3")
    bot = H - MY - 44
    RR(d, (MX, y, W - MX, bot), 14, fill=hexc("#0f1c21"))
    # take header row
    tx = MX + 26
    pw = tw("TAKE 1", F(18, 800), 2) + 28
    RR(d, (tx, y + 20, tx + pw, y + 52), 16, fill=hexc(c["gold"]))
    TC(d, tx + 14, y + 36, "TAKE 1", F(18, 800), hexc(c["navy"]), sp=2)
    T(d, tx + pw + 16, y + 46, "Pick Up 5 PM", F(26, 700), hexc(c["text"]))
    # vitals meter
    vx = W - MX - 26
    for i in range(3):
        x1 = vx - i * 44
        RR(d, (x1 - 36, y + 26, x1, y + 46), 5, fill=hexc(c["coral"] if (2 - i) < 2 else c["card2"]))
    T(d, vx - 3 * 44 - 10, y + 44, "VITALS", F(17, 800), hexc(c["muted"]), sp=3, align="r")
    d.line((MX + 26, y + 70, W - MX - 26, y + 70), fill=hexc(c["line"]))
    # previous line, dim
    T(d, MX + 40, y + 120, PREV_LINE, F(24, 400), hexc(c["dim"]))
    # current line, big
    cy = y + 190
    for i, ln in enumerate(wrap(CUR_LINE, F(44, 600), W - 2 * MX - 80)):
        T(d, MX + 40, cy + i * 58, ln, F(44, 600), hexc(c["text"]))
    # helper callout
    hy = cy + 50
    RR(d, (MX + 40, hy, W - MX - 40, hy + 64), 12, fill=hexc("#123a3a"))
    d.rectangle((MX + 40, hy + 10, MX + 45, hy + 54), fill=hexc(c["teal"]))
    T(d, MX + 66, hy + 41, "PROMPT", F(16, 800), hexc(c["teal"]), sp=3)
    T(d, MX + 160, hy + 42, HELPER, F(26, 500), hexc("#cff5ef"))
    A_button(d, (MX + 40, hy + 96, MX + 300, hy + 152), "CONTINUE", True, True)
    TC(d, MX + 320, hy + 124, "or click anywhere on the log", F(19, 400), hexc(c["dim"]))
    A_footer_hint(d)
    return im

def A_menu():
    c = A
    im, d, y = A_frame("ATTACHED")
    bot = H - MY - 44
    RR(d, (MX, y, W - MX, bot), 14, fill=hexc("#0f1c21"))
    T(d, MX + 40, y + 70, "Attached.", F(44, 800), hexc(c["text"]))
    T(d, MX + 40, y + 112, "Nell is under. Choose how to go in.", F(24, 400), hexc(c["muted"]))
    opts = [("VIEW THE DREAM", "Watch the dream play out first"), ("SKIP TO YOUR ROLE", "Go straight to who you'll be")]
    oy = y + 150
    for i, (o, sub) in enumerate(opts):
        box = (MX + 40, oy, W - MX - 40, oy + 82)
        if i == 0:
            RR(d, box, 16, fill=hexc(c["gold"]))
            RR(d, (box[0] - 5, box[1] - 5, box[2] + 5, box[3] + 5), 20, outline=hexc("#fff1c9"), width=3)
            fg, sf = c["navy"], "#4a3a14"
            d.polygon([(box[2] - 46, oy + 28), (box[2] - 46, oy + 54), (box[2] - 26, oy + 41)], fill=hexc(c["navy"]))
        else:
            RR(d, box, 16, fill=hexc(c["card2"]), outline=hexc(c["line"]), width=2)
            fg, sf = c["text"], c["muted"]
        T(d, box[0] + 30, oy + 40, o, F(28, 800), hexc(fg), sp=1)
        T(d, box[0] + 30, oy + 68, sub, F(20, 400), hexc(sf))
        oy += 104
    A_footer_hint(d, pad=True)
    return im

def A_lumi():
    c = A
    im, d, y = A_frame("WONDERWELL // LUMI", lumi_on=True)
    bot = H - MY - 44
    RR(d, (MX, y, W - MX, bot), 14, fill=hexc("#17142e"), outline=hexc("#3b3370"), width=2)
    yy = y + 50
    for i, s in enumerate(SPAM):
        col = c["lumi"] if "love" in s or "studying" in s else "#7d74b8"
        f = F(30, 700) if "love" in s else F(24, 500)
        T(d, MX + 36, yy, ("> " if not "love" in s else "") + s, f, hexc(col))
        yy += 48
    A_footer_hint(d)
    return im

# =========================================================================================
# DESIGN B: "Boxed terminal" - TUI panels, inverse-video selection, a status dock for Lumi.
# =========================================================================================
B = dict(bg="#081210", frame="#3fb8a6", framedim="#1f4a45", amber="#f4b942", text="#e9e2cc",
         muted="#86a39d", dim="#3e5a56", ink="#081210", red="#e0584e", lumi="#d6c3ff", lumibg="#2b2350")

def scanlines(im, a=14):
    overlay(im, lambda d: [d.line((0, y, W, y), fill=(0, 0, 0, a)) for y in range(0, H, 4)])

def B_panel(d, box, title, col, tcol=None, right=None):
    x0, y0, x1, y1 = box
    d.rectangle(box, outline=hexc(col), width=2)
    # double top rule
    d.line((x0, y0 + 5, x1, y0 + 5), fill=hexc(col), width=1)
    if title:
        f = F(19, 800)
        w = tw(title, f, 3) + 24
        d.rectangle((x0 + 18, y0 - 14, x0 + 18 + w, y0 + 14), fill=hexc(col))
        TC(d, x0 + 30, y0, title, f, hexc(B["ink"]), sp=3)
    if right:
        f = F(19, 700)
        w = tw(right, f, 2) + 20
        d.rectangle((x1 - 18 - w, y0 - 13, x1 - 18, y0 + 13), fill=hexc(B["bg"]), outline=hexc(col), width=2)
        TC(d, x1 - 18 - w + 10, y0, right, f, hexc(tcol or col), sp=2)

def B_button(d, box, label, focused, key=None):
    c = B
    x0, y0, x1, y1 = box
    cy = (y0 + y1) / 2
    f = F(24, 800)
    if focused:
        d.rectangle((x0 + 6, y0 + 6, x1 + 6, y1 + 6), fill=hexc("#5a4210"))   # drop block
        d.rectangle(box, fill=hexc(c["amber"]))
        d.polygon([(x0 + 18, cy - 10), (x0 + 18, cy + 10), (x0 + 32, cy)], fill=hexc(c["ink"]))
        TC(d, x0 + 46, cy, label, f, hexc(c["ink"]), sp=2)
    else:
        d.rectangle(box, outline=hexc(c["frame"]), width=2)
        TC(d, x0 + 46, cy, label, f, hexc(c["frame"]), sp=2)
    if key:
        fk = F(16, 800)
        kw = tw(key, fk) + 14
        kx = x1 - 14 - kw
        d.rectangle((kx, cy - 13, kx + kw, cy + 13), outline=hexc(c["ink"] if focused else c["dim"]), width=2)
        TC(d, kx + 7, cy, key, fk, hexc(c["ink"] if focused else c["muted"]))

def B_meter(d, x, y, n, of=3, col=None):
    for i in range(of):
        d.rectangle((x + i * 30, y, x + i * 30 + 22, y + 22), fill=hexc(col or B["red"]) if i < n else None,
                    outline=hexc(col or B["red"]) if i < n else hexc(B["dim"]), width=2)

def B_frame(main_title, main_right, take, layer, vitals, lumi_on=False, pad=False):
    c = B
    im = glass(c["bg"])
    d = ImageDraw.Draw(im)
    y = titlebar(im, MX, MY, W - 2 * MX)
    top = y + 30
    dock0 = H - MY - 98
    dock1 = dock0 + 54
    sx1 = MX + 300
    fcol = c["framedim"] if lumi_on else c["frame"]
    # sidebar: PATIENT
    B_panel(d, (MX, top, sx1, top + 196), "PATIENT", fcol)
    d.rectangle((MX + 16, top + 30, sx1 - 16, top + 120), fill=hexc(c["dim"] if lumi_on else c["amber"]))
    T(d, MX + 30, top + 66, "PRICE,", F(30, 800), hexc(c["ink"]))
    T(d, MX + 30, top + 104, "ELEANOR M.", F(30, 800), hexc(c["ink"]))
    T(d, MX + 18, top + 154, "AKA", F(18, 700), hexc(c["muted"]), sp=3)
    T(d, MX + 70, top + 156, "\"NELL\"", F(28, 800), hexc(c["text"] if not lumi_on else c["muted"]))
    T(d, MX + 18, top + 182, "71  /  BAKER", F(17, 700), hexc(c["muted"]), sp=2)
    # sidebar: SESSION
    s0 = top + 226
    B_panel(d, (MX, s0, sx1, dock0 - 22), "SESSION", fcol)
    rows = [("DREAM", "3"), ("LAYER", layer), ("TAKE", take)]
    ry = s0 + 54
    for k, v in rows:
        T(d, MX + 18, ry, k, F(17, 800), hexc(c["muted"]), sp=3)
        num, _, rest = v.partition("  ")
        T(d, MX + 110, ry + 1, num, F(24, 700), hexc(c["text"]))
        if rest:
            ry += 32
            T(d, MX + 18, ry + 1, rest, F(22, 600), hexc(c["amber"] if not lumi_on else c["muted"]))
        ry += 44
    T(d, MX + 18, ry, "VITALS", F(17, 800), hexc(c["muted"]), sp=3)
    B_meter(d, MX + 112, ry - 20, vitals)
    # main panel
    mbox = (sx1 + 24, top, W - MX, dock0 - 22)
    B_panel(d, mbox, main_title, c["lumi"] if lumi_on else c["frame"], right=main_right)
    # Lumi dock
    dbox = (MX, dock0, W - MX, dock1)
    if lumi_on:
        glow(im, dbox, 4, c["lumi"], 14, 130)
        d = ImageDraw.Draw(im)
        d.rectangle(dbox, fill=hexc(c["lumi"]))
        lumi_face(d, MX + 34, (dock0 + dock1) / 2, 17, True, "#fff6dc", c["dim"])
        TC(d, MX + 66, (dock0 + dock1) / 2, "LUMI", F(24, 800), hexc("#1b1640"), sp=4)
        TC(d, MX + 160, (dock0 + dock1) / 2, "I'm here.", F(26, 600), hexc("#1b1640"))
        d.ellipse((W - MX - 150, (dock0 + dock1) / 2 - 7, W - MX - 136, (dock0 + dock1) / 2 + 7), fill=hexc("#1b1640"))
        TC(d, W - MX - 126, (dock0 + dock1) / 2, "ONLINE", F(22, 800), hexc("#1b1640"), sp=3)
    else:
        # hazard-tape "disabled" fill
        layer_ = Image.new("RGBA", im.size, (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer_)
        for x in range(MX - 60, W - MX + 60, 22):
            ld.polygon([(x, dock1), (x + 10, dock1), (x + 10 + 54, dock0), (x + 54, dock0)], fill=(70, 90, 88, 60))
        mask = Image.new("L", im.size, 0)
        ImageDraw.Draw(mask).rectangle(dbox, fill=255)
        im.paste(Image.alpha_composite(im, layer_), (0, 0), mask)
        d = ImageDraw.Draw(im)
        d.rectangle(dbox, outline=hexc(c["dim"]), width=2)
        lab_w = 420
        d.rectangle((MX + 2, dock0 + 2, MX + lab_w, dock1 - 2), fill=hexc(c["bg"]))
        lumi_face(d, MX + 34, (dock0 + dock1) / 2, 15, False, None, c["muted"])
        TC(d, MX + 66, (dock0 + dock1) / 2, "LUMI", F(24, 800), hexc(c["muted"]), sp=4)
        TC(d, MX + 160, (dock0 + dock1) / 2, "story guide", F(24, 400), hexc(c["muted"]))
        tw_ = tw("DISABLED", F(22, 800), 3) + 30
        d.rectangle((W - MX - 20 - tw_, dock0 + 10, W - MX - 20, dock1 - 10), fill=hexc(c["bg"]), outline=hexc(c["dim"]), width=2)
        TC(d, W - MX - 20 - tw_ + 15, (dock0 + dock1) / 2, "DISABLED", F(22, 800), hexc(c["muted"]), sp=3)
    # controls
    hy = H - MY - 18
    if pad:
        hint(d, W - MX, hy, [("D-PAD", "move"), ("A", "select")], F(16, 800), F(19, 500), hexc(c["muted"]), hexc(c["muted"]), hexc(c["dim"]), align="r")
    else:
        hint(d, W - MX, hy, [("MOUSE", "click"), ("SPACE", "select")], F(16, 800), F(19, 500), hexc(c["muted"]), hexc(c["muted"]), hexc(c["dim"]), align="r")
    T(d, MX, hy + 7, "nell_d3.dream", F(17, 500), hexc(c["dim"]))
    return im, d, mbox

def B_casefile():
    c = B
    im, d, (x0, y0, x1, y1) = B_frame("CASE FILE", "1/3", "-", "-", 1)
    y = y0 + 52
    vw = x1 - x0 - 50
    for label, val in ENTRIES_P1:
        T(d, x0 + 22, y, label, F(20, 800), hexc(c["amber"]), sp=3)
        d.line((x0 + 30 + tw(label, F(20, 800), 3), y - 7, x1 - 22, y - 7), fill=hexc(c["framedim"]), width=1)
        lines = wrap(val, F(25, 400), vw)
        for i, ln in enumerate(lines):
            T(d, x0 + 22, y + 34 + i * 33, ln, F(25, 400), hexc(c["text"]))
        y += 34 + len(lines) * 33 + 16
    by = y1 - 78
    B_button(d, (x0 + 20, by, x0 + 250, by + 54), "MORE", False, key="1/3")
    B_button(d, (x0 + 280, by, x1 - 20, by + 54), "ATTACH TO DREAMER", True)
    scanlines(im)
    return im

def B_scenelog():
    c = B
    im, d, (x0, y0, x1, y1) = B_frame("SCENE LOG", "TAKE 1", "1", "3  Pick Up 5 PM", 2)
    y = y0 + 54
    for s in ["Nell sets the lemon down on the counter.", PREV_LINE]:
        for ln in wrap(s, F(22, 400), x1 - x0 - 50):
            T(d, x0 + 22, y, ln, F(22, 400), hexc(c["dim"]))
            y += 32
    y += 36
    d.rectangle((x0 + 22, y - 34, x0 + 28, y + 8), fill=hexc(c["amber"]))
    lines = wrap(CUR_LINE, F(40, 600), x1 - x0 - 70)
    for i, ln in enumerate(lines):
        w = T(d, x0 + 44, y + i * 52, ln, F(40, 600), hexc(c["text"]))
    d.rectangle((x0 + 50 + w, y - 30, x0 + 66 + w, y + 4), fill=hexc(c["amber"]))   # caret block
    y += len(lines) * 52 + 26
    # prompt sub-box
    d.rectangle((x0 + 22, y, x1 - 22, y + 62), outline=hexc(c["frame"]), width=2)
    d.rectangle((x0 + 22, y, x0 + 140, y + 62), fill=hexc(c["frame"]))
    TC(d, x0 + 38, y + 31, "PROMPT", F(17, 800), hexc(c["ink"]), sp=3)
    TC(d, x0 + 160, y + 31, HELPER, F(24, 500), hexc(c["text"]))
    by = y + 92
    B_button(d, (x0 + 20, by, x0 + 300, by + 54), "CONTINUE", True)
    TC(d, x0 + 330, by + 27, "or click the log", F(19, 400), hexc(c["dim"]))
    scanlines(im)
    return im

def B_menu():
    c = B
    im, d, (x0, y0, x1, y1) = B_frame("ATTACHED", None, "-", "3  Pick Up 5 PM", 1, pad=True)
    T(d, x0 + 22, y0 + 62, "Link stable. Dreamer is under.", F(24, 400), hexc(c["muted"]))
    by = y0 + 100
    for i, o in enumerate(["VIEW THE DREAM", "SKIP TO YOUR ROLE"]):
        B_button(d, (x0 + 20, by, x1 - 20, by + 64), o, i == 0, key=str(i + 1))
        by += 88
    scanlines(im)
    return im

def B_lumi():
    c = B
    im, d, (x0, y0, x1, y1) = B_frame("WONDERWELL // LUMI", "!", "-", "3  Pick Up 5 PM", 0, lumi_on=True)
    y = y0 + 54
    for s in SPAM:
        big = "love" in s or "studying" in s
        f = F(30, 700) if big else F(23, 600)
        T(d, x0 + 22, y, s, f, hexc(c["lumi"] if big else "#8f82c8"))
        y += 46 if big else 38
    scanlines(im)
    return im

# =========================================================================================
# DESIGN C: "Typographic" - no boxes, big type, one accent, Lumi as the divider rule.
# =========================================================================================
C = dict(bg="#0b1418", text="#f1e9d6", muted="#7f9196", dim="#3f5056", gold="#f2c14e", navy="#0b1418",
         lumi="#c3b1ff", lumibg="#221d40", rule="#22343a")

def C_frame(eyebrow_right, lumi_on=False, body_takeover=False):
    c = C
    im = glass(c["bg"])
    d = ImageDraw.Draw(im)
    y = titlebar(im, MX, MY, W - 2 * MX)
    # patient block
    py = y + 34
    T(d, MX, py + 18, "PATIENT", F(17, 700), hexc(c["muted"]), sp=4)
    T(d, W - MX, py + 18, eyebrow_right, F(17, 700), hexc(c["muted"]), sp=4, align="r")
    nf = F(46, 800)
    nw = tw(PATIENT, nf)
    # highlighter swipe
    d.polygon([(MX, py + 34), (MX + nw + 26, py + 30), (MX + nw + 22, py + 92), (MX + 2, py + 94)], fill=hexc(c["gold"]))
    T(d, MX + 12, py + 80, PATIENT, nf, hexc(c["navy"]))
    T(d, MX + nw + 46, py + 80, "aka Nell, 71", F(30, 400), hexc(c["text"]))
    # Lumi divider
    ly = py + 122
    if lumi_on:
        return im, d, ly
    d.line((MX, ly + 24, W - MX, ly + 24), fill=hexc(c["rule"]), width=2)
    w = tw("LUMI", F(22, 800), 3) + tw("story guide", F(22, 400)) + tw("DISABLED", F(20, 800), 3) + 130
    cx0 = W / 2 - w / 2
    RR(d, (cx0, ly, cx0 + w, ly + 48), 24, fill=hexc("#0f1a1e"), outline=hexc(c["dim"]), width=2)
    lumi_face(d, cx0 + 30, ly + 24, 13, False, None, c["muted"])
    x = cx0 + 56
    x += TC(d, x, ly + 24, "LUMI", F(22, 800), hexc(c["muted"]), sp=3) + 14
    x += TC(d, x, ly + 24, "story guide", F(22, 400), hexc(c["dim"])) + 22
    d.line((x - 11, ly + 12, x - 11, ly + 36), fill=hexc(c["dim"]), width=2)
    TC(d, x, ly + 24, "DISABLED", F(20, 800), hexc(c["dim"]), sp=3)
    return im, d, ly + 74

def C_btn(d, x, y, label, primary, focused, h=60, align="l"):
    c = C
    f = F(26, 800)
    w = tw(label, f, 2) + 56 + (34 if primary else 0)
    if align == "r": x -= w
    if primary:
        d.rectangle((x, y, x + w, y + h), fill=hexc(c["gold"]))
        TC(d, x + 28, y + h / 2, label, f, hexc(c["navy"]), sp=2)
        ax = x + w - 42
        d.line((ax, y + h / 2, ax + 20, y + h / 2), fill=hexc(c["navy"]), width=4)
        d.polygon([(ax + 14, y + h / 2 - 9), (ax + 26, y + h / 2), (ax + 14, y + h / 2 + 9)], fill=hexc(c["navy"]))
        if focused:
            d.line((x, y + h + 8, x + w, y + h + 8), fill=hexc(c["text"]), width=3)
    else:
        d.rectangle((x, y, x + w, y + h), outline=hexc(c["text"]), width=2)
        TC(d, x + 28, y + h / 2, label, f, hexc(c["text"]), sp=2)
    return w

def C_hint(d, pad=False):
    c = C
    pairs = [("D-PAD", "move"), ("A", "select")] if pad else [("MOUSE", "click"), ("SPACE", "select")]
    hint(d, MX, H - MY - 22, pairs, F(16, 800), F(19, 500), hexc(c["muted"]), hexc(c["muted"]), hexc(c["dim"]))

def C_casefile():
    c = C
    im, d, y = C_frame("CASE FILE  1 / 3")
    y += 18
    vw = W - 2 * MX - 150
    for label, val in ENTRIES_P1:
        T(d, MX, y + 26, label, F(18, 800), hexc(c["gold"]), sp=4)
        lines = wrap(val, F(28, 400), vw)
        for i, ln in enumerate(lines):
            T(d, MX + 150, y + 28 + i * 39, ln, F(28, 400), hexc(c["text"]))
        y += len(lines) * 39 + 24
    by = H - MY - 120
    C_btn(d, W - MX, by, "ATTACH TO DREAMER", True, True, align="r")
    pw = tw("ATTACH TO DREAMER", F(26, 800), 2) + 90
    C_btn(d, W - MX - pw - 20, by, "MORE  1/3", False, False, align="r")
    C_hint(d)
    return im

def C_scenelog():
    c = C
    im, d, y = C_frame("LAYER 3  PICK UP 5 PM")
    # vitals as dots + take
    T(d, MX, y + 22, "TAKE 1", F(18, 800), hexc(c["gold"]), sp=4)
    T(d, W - MX - 3 * 26 - 14, y + 22, "VITALS", F(17, 800), hexc(c["muted"]), sp=4, align="r")
    for i in range(3):
        cx = W - MX - 8 - (2 - i) * 26
        d.ellipse((cx - 9, y + 6, cx + 9, y + 24), fill=hexc("#ef6f5e") if i < 2 else None, outline=hexc("#ef6f5e") if i < 2 else hexc(c["dim"]), width=2)
    cy = y + 150
    T(d, W / 2, cy - 60, PREV_LINE, F(24, 400), hexc(c["dim"]), align="c")
    for i, ln in enumerate(wrap(CUR_LINE, F(54, 700), W - 2 * MX - 40)):
        T(d, W / 2, cy + 20 + i * 66, ln, F(54, 700), hexc(c["text"]), align="c")
    T(d, W / 2, cy + 86, HELPER, F(28, 500), hexc(c["gold"]), align="c")
    bw = tw("CONTINUE", F(26, 800), 2) + 90
    C_btn(d, W / 2 - bw / 2, cy + 140, "CONTINUE", True, True)
    C_hint(d)
    return im

def C_menu():
    c = C
    im, d, y = C_frame("DREAM 3")
    T(d, MX, y + 60, "Attached.", F(56, 800), hexc(c["text"]))
    T(d, MX, y + 100, "Nell is dreaming. How do you want to go in?", F(26, 400), hexc(c["muted"]))
    oy = y + 140
    for i, o in enumerate(["View the dream", "Skip to your role"]):
        if i == 0:
            d.rectangle((MX, oy, W - MX, oy + 76), fill=hexc(c["gold"]))
            T(d, MX + 20, oy + 52, "1", F(22, 800), hexc("#6b5418"))
            T(d, MX + 60, oy + 54, o, F(38, 800), hexc(c["navy"]))
            ax = W - MX - 50
            d.line((ax, oy + 38, ax + 26, oy + 38), fill=hexc(c["navy"]), width=4)
            d.polygon([(ax + 18, oy + 27), (ax + 32, oy + 38), (ax + 18, oy + 49)], fill=hexc(c["navy"]))
        else:
            d.line((MX, oy + 76, W - MX, oy + 76), fill=hexc(c["rule"]), width=2)
            T(d, MX + 20, oy + 52, "2", F(22, 800), hexc(c["dim"]))
            T(d, MX + 60, oy + 54, o, F(38, 600), hexc(c["text"]))
        oy += 92
    C_hint(d, pad=True)
    return im

def C_lumi():
    c = C
    im, d, y = C_frame("WONDERWELL // LUMI", lumi_on=True)
    box = (MX, y, W - MX, H - MY - 50)
    glow(im, box, 18, c["lumi"], 22, 120)
    d = ImageDraw.Draw(im)
    RR(d, box, 18, fill=hexc(c["lumibg"]), outline=hexc(c["lumi"]), width=3)
    lumi_face(d, MX + 44, y + 46, 22, True, "#fff1c9", c["dim"])
    TC(d, MX + 80, y + 46, "LUMI", F(26, 800), hexc(c["lumi"]), sp=4)
    TC(d, MX + 180, y + 46, "I'm here.", F(30, 600), hexc("#fff1c9"))
    TC(d, W - MX - 24, y + 46, "ONLINE", F(20, 800), hexc("#7ef0a8"), sp=4, align="r")
    d.ellipse((W - MX - 24 - tw("ONLINE", F(20, 800), 4) - 26, y + 39, W - MX - 24 - tw("ONLINE", F(20, 800), 4) - 12, y + 53), fill=hexc("#7ef0a8"))
    yy = y + 120
    for s in SPAM[:6]:
        big = "love" in s or "studying" in s
        if big: yy += 12
        T(d, MX + 26, yy, s, F(40, 800) if big else F(24, 500), hexc(c["lumi"] if big else "#8a7fc4"))
        yy += 52 if big else 40
    C_hint(d)
    return im

# ---------------- in-monitor composite ----------------
def in_monitor(mock, name):
    shot = Image.open(SHOT).convert("RGBA")
    s = 2
    shot = shot.resize((shot.width * s, shot.height * s), Image.Resampling.LANCZOS)
    x0, y0, x1, y1 = [v * s for v in GLASS_BOX]
    m = mock.resize((x1 - x0, y1 - y0), Image.Resampling.LANCZOS)
    mask = Image.new("L", m.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, m.width - 1, m.height - 1), 34, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(2))
    shot.paste(m, (x0, y0), mask)
    shot.convert("RGB").save(os.path.join(OUT, name))

def guide(mock):
    """Safe-area guide overlay (debug)."""
    g = mock.copy()
    ImageDraw.Draw(g).rectangle((MX, MY, W - MX, H - MY), outline=(255, 0, 255, 255))
    return g

if __name__ == "__main__":
    sets = {"A": (A_casefile, A_scenelog, A_menu, A_lumi),
            "B": (B_casefile, B_scenelog, B_menu, B_lumi),
            "C": (C_casefile, C_scenelog, C_menu, C_lumi)}
    for k, fns in sets.items():
        ims = [fn() for fn in fns]
        for im, st in zip(ims, ["casefile", "scenelog", "menu", "lumi_awake"]):
            save(im, f"{k}_{st}.png")
        in_monitor(ims[0], f"{k}_in_monitor.png")
        in_monitor(ims[1], f"{k}_in_monitor_scenelog.png")
    print("ok")
