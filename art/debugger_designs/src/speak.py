"""'Your turn to speak' state for designs A, B, C."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mock import *

SPEAK = "#6ccff6"       # "mic live" sky blue: not gold (buttons), not lavender (Lumi)
ASK = "What do you have to say?"
HOW = "Hold your talk key to speak"

def mic(d, cx, cy, s, col, width=None):
    w = width or max(3, int(s * 0.12))
    d.rounded_rectangle((cx - s * 0.22, cy - s * 0.55, cx + s * 0.22, cy + s * 0.12), s * 0.22, fill=hexc(col))
    d.arc((cx - s * 0.38, cy - s * 0.42, cx + s * 0.38, cy + s * 0.3), 0, 180, fill=hexc(col), width=w)
    d.line((cx, cy + s * 0.3, cx, cy + s * 0.5), fill=hexc(col), width=w)
    d.line((cx - s * 0.2, cy + s * 0.5, cx + s * 0.2, cy + s * 0.5), fill=hexc(col), width=w)

def wave(d, x, cy, col, n=7, step=12, hmax=30):
    hs = [0.35, 0.7, 1.0, 0.55, 0.85, 0.45, 0.25, 0.6, 0.9, 0.4][:n]
    for i, h in enumerate(hs):
        hh = hmax * h
        d.rounded_rectangle((x + i * step, cy - hh / 2, x + i * step + 6, cy + hh / 2), 3, fill=hexc(col))
    return n * step

def left_arrow(d, x, cy, col, size=12):
    d.polygon([(x, cy), (x + size, cy - size * 0.8), (x + size, cy + size * 0.8)], fill=hexc(col))

def A_speak():
    c = A
    im, d, y = A_frame("LAYER 3")
    bot = H - MY - 44
    RR(d, (MX, y, W - MX, bot), 14, fill=hexc("#0f1c21"))
    tx = MX + 26
    pw = tw("TAKE 1", F(18, 800), 2) + 28
    RR(d, (tx, y + 20, tx + pw, y + 52), 16, fill=hexc(c["gold"]))
    TC(d, tx + 14, y + 36, "TAKE 1", F(18, 800), hexc(c["navy"]), sp=2)
    T(d, tx + pw + 16, y + 46, "Pick Up 5 PM", F(26, 700), hexc(c["text"]))
    vx = W - MX - 26
    for i in range(3):
        x1 = vx - i * 44
        RR(d, (x1 - 36, y + 26, x1, y + 46), 5, fill=hexc(c["coral"] if (2 - i) < 2 else c["card2"]))
    T(d, vx - 3 * 44 - 10, y + 44, "VITALS", F(17, 800), hexc(c["muted"]), sp=3, align="r")
    d.line((MX + 26, y + 70, W - MX - 26, y + 70), fill=hexc(c["line"]))
    T(d, MX + 40, y + 120, PREV_LINE, F(24, 400), hexc(c["dim"]))
    cy = y + 190
    T(d, MX + 40, cy, "\"What are you doing with it, then?\"", F(44, 600), hexc(c["text"]))
    # speak banner: full width, outlined, mic + live wave, no button shape
    by0, by1 = cy + 50, cy + 190
    glow(im, (MX + 40, by0, W - MX - 40, by1), 18, SPEAK, 18, 70)
    d = ImageDraw.Draw(im)
    RR(d, (MX + 40, by0, W - MX - 40, by1), 18, fill=hexc("#0f2a36"), outline=hexc(SPEAK), width=3)
    d.ellipse((MX + 70, by0 + 30, MX + 150, by0 + 110), fill=hexc("#163f52"), outline=hexc(SPEAK), width=3)
    mic(d, MX + 110, by0 + 74, 52, SPEAK)
    pw = tw("YOUR TURN", F(17, 800), 3) + 26
    RR(d, (MX + 180, by0 + 24, MX + 180 + pw, by0 + 54), 15, fill=hexc(SPEAK))
    TC(d, MX + 193, by0 + 39, "YOUR TURN", F(17, 800), hexc(c["navy"]), sp=3)
    T(d, MX + 180, by0 + 98, ASK, F(36, 700), hexc("#e6f8ff"))
    left_arrow(d, MX + 180, by0 + 122, SPEAK, 9)
    T(d, MX + 196, by0 + 130, HOW + "  (voice panel, left of the screen)", F(21, 500), hexc("#9cd9ef"))
    wave(d, W - MX - 140, by0 + 40, SPEAK)
    return im

def B_speak():
    c = B
    im, d, (x0, y0, x1, y1) = B_frame("SCENE LOG", "TAKE 1", "1", "3  Pick Up 5 PM", 2)
    y = y0 + 54
    for s in ["Nell sets the lemon down on the counter.", PREV_LINE]:
        T(d, x0 + 22, y, s, F(22, 400), hexc(c["dim"]))
        y += 32
    y += 36
    d.rectangle((x0 + 22, y - 34, x0 + 28, y + 8), fill=hexc(c["amber"]))
    lines = wrap("\"What are you doing with it, then?\"", F(36, 600), x1 - x0 - 70)
    for i, ln in enumerate(lines):
        T(d, x0 + 44, y + i * 48, ln, F(36, 600), hexc(c["text"]))
    y += len(lines) * 48 + 20
    # INPUT panel: the same box language, but cyan and "live"
    bx = (x0 + 22, y, x1 - 22, y + 150)
    glow(im, bx, 2, SPEAK, 12, 70)
    d = ImageDraw.Draw(im)
    d.rectangle(bx, fill=hexc("#0b2530"), outline=hexc(SPEAK), width=3)
    d.rectangle((bx[0], bx[1], bx[0] + 90, bx[3]), fill=hexc(SPEAK))
    mic(d, bx[0] + 45, bx[1] + 70, 56, c["ink"])
    T(d, bx[0] + 112, bx[1] + 40, "AWAITING VOICE INPUT", F(18, 800), hexc(SPEAK), sp=3)
    w = T(d, bx[0] + 112, bx[1] + 88, ASK, F(32, 700), hexc("#e6f8ff"))
    d.rectangle((bx[0] + 120 + w, bx[1] + 60, bx[0] + 136 + w, bx[1] + 90), fill=hexc(SPEAK))   # blinking caret
    left_arrow(d, bx[0] + 112, bx[1] + 120, SPEAK, 9)
    T(d, bx[0] + 128, bx[1] + 127, "HOLD TALK KEY", F(18, 800), hexc(SPEAK), sp=2)
    T(d, bx[0] + 128 + tw("HOLD TALK KEY", F(18, 800), 2) + 14, bx[1] + 127, "voice panel, left", F(19, 500), hexc("#9cd9ef"))
    wave(d, bx[2] - 110, bx[1] + 34, SPEAK, n=7, step=12, hmax=26)
    scanlines(im)
    return im

def C_speak():
    c = C
    im, d, y = C_frame("LAYER 3  PICK UP 5 PM")
    T(d, MX, y + 22, "TAKE 1", F(18, 800), hexc(c["gold"]), sp=4)
    T(d, W - MX - 3 * 26 - 14, y + 22, "VITALS", F(17, 800), hexc(c["muted"]), sp=4, align="r")
    for i in range(3):
        cx = W - MX - 8 - (2 - i) * 26
        d.ellipse((cx - 9, y + 6, cx + 9, y + 24), fill=hexc("#ef6f5e") if i < 2 else None, outline=hexc("#ef6f5e") if i < 2 else hexc(c["dim"]), width=2)
    cy = y + 150
    T(d, W / 2, cy - 60, PREV_LINE, F(24, 400), hexc(c["dim"]), align="c")
    T(d, W / 2, cy + 20, "\"What are you doing with it, then?\"", F(46, 700), hexc(c["text"]), align="c")
    # speak cue: centred mic in a ring, the ask in sky blue, the how under it
    my = cy + 120
    glow(im, (W / 2 - 46, my - 46, W / 2 + 46, my + 46), 46, SPEAK, 16, 90)
    d = ImageDraw.Draw(im)
    d.ellipse((W / 2 - 46, my - 46, W / 2 + 46, my + 46), fill=hexc(SPEAK))
    d.ellipse((W / 2 - 62, my - 62, W / 2 + 62, my + 62), outline=hexc(SPEAK, 120), width=2)
    mic(d, W / 2, my + 4, 54, c["navy"])
    T(d, W / 2, my + 116, ASK, F(38, 800), hexc(SPEAK), align="c")
    hw = tw(HOW, F(22, 500)) + 22
    left_arrow(d, W / 2 - hw / 2, my + 150, "#9cd9ef", 9)
    T(d, W / 2 - hw / 2 + 22, my + 158, HOW, F(22, 500), hexc("#9cd9ef"))
    return im

if __name__ == "__main__":
    for k, fn in (("A", A_speak), ("B", B_speak), ("C", C_speak)):
        im = fn()
        save(im, f"{k}_speak.png")
        in_monitor(im, f"{k}_in_monitor_speak.png")
    print("ok")
