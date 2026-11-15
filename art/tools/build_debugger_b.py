"""Builds UW_DebuggerB (Content/DreamDebugger), the dream debugger in design B. Runs in the UEFN
editor (uefn skill: runpy.sh). The asset must exist first (UMGToolSet.CreateWidgetBlueprint);
the Verse fields and their bindings come after, from bind_debugger_b.sh.

Imports the textures from art/debugger_b (make_debugger_b.py writes them, with layout.json),
then builds the tree:

  Fit (Scale Box, scale to fit; nothing in it is hit-testable)
   Page (Size Box 1200 x 908)
    Canvas
     Base                     the chrome (T_DbgB_Base)
     sidebar texts            PatientName, PatientAka, PatientInfo, Dream/Layer/LayerTitle/Take,
                              Vital0..2 (red blocks)
     MainTab, MainBadge       the main panel's title tab and right-hand badge
     Pages (Widget Switcher)  0 File, 1 Log, 2 Menu
     LumiOn                   Lumi awake (T_DbgB_LumiOn), faded by a field
     FooterFile, FooterHint
     Scan                     scanlines over everything

To rebuild, delete the asset, create it again, and run this and bind_debugger_b.sh.
"""
import json
import os
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
FOLDER = G + "/DreamDebugger"
ART = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/debugger_b"
L = json.load(open(os.path.join(ART, "layout.json")))
C = L["colors"]

# ---------- textures ----------
TEXTURES = ["T_DbgB_Base", "T_DbgB_LumiOn", "T_DbgB_Scan", "T_DbgB_Outline", "T_DbgB_Badge",
            "T_DbgB_Focus", "T_DbgB_Arrow", "T_DbgB_Continue", "T_DbgB_Speak"]
tasks = []
for name in TEXTURES:
    t = unreal.AssetImportTask()
    t.filename = os.path.join(ART, name + ".png")
    t.destination_path = FOLDER
    t.destination_name = name
    t.automated = True
    t.replace_existing = True
    t.save = False
    tasks.append(t)
unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
TEX = {}
for name in TEXTURES:
    tex = unreal.load_asset(FOLDER + "/" + name)
    tex.set_editor_property("lod_group", unreal.TextureGroup.TEXTUREGROUP_UI)
    tex.set_editor_property("mip_gen_settings", unreal.TextureMipGenSettings.TMGS_NO_MIPMAPS)
    tex.set_editor_property("never_stream", True)
    tex.set_editor_property("compression_settings", unreal.TextureCompressionSettings.TC_EDITOR_ICON)
    unreal.EditorAssetLibrary.save_loaded_asset(tex)
    TEX[name] = tex
print("textures", len(TEX))

# ---------- helpers ----------
wbp = unreal.load_asset(FOLDER + "/UW_DebuggerB")
tree = unreal.find_object(None, wbp.get_path_name() + ":WidgetTree")
TEXT_CLASS = unreal.load_class(None, "/Game/Valkyrie/UMG/UEFN_TextBlock.UEFN_TextBlock_C")
NOTO = unreal.load_asset("/FortUILibrary/Fonts/NotoSans")


def lin(h, a=1.0):
    h = h.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    return unreal.LinearColor(r ** 2.2, g ** 2.2, b ** 2.2, a)


def new(cls, name):
    # An earlier failed run can leave an unparented widget with this name: reuse it.
    w = unreal.find_object(None, wbp.get_path_name() + ":WidgetTree." + name)
    if w is None:
        w = unreal.new_object(cls, outer=tree, name=name)
    try:
        w.set_editor_property("is_variable", True)
    except Exception:
        pass
    return w


def text(name, size, face, color, spacing=0, wrap=False, justify=None, sample=""):
    t = new(TEXT_CLASS, name)
    t.set_editor_property("text", unreal.Text(sample))
    t.set_editor_property("color_and_opacity", unreal.SlateColor(lin(color)))
    f = t.get_editor_property("font")
    f.set_editor_property("font_object", NOTO)
    # Sizes here are the mockups' px; UMG sizes are points (1 pt = 4/3 px). Fortnite's NotoSans
    # has only NotoSans-Regular, -Bold and -Italic; "Black" means Bold.
    f.set_editor_property("typeface_font_name", "NotoSans-Regular" if face == "Regular" else "NotoSans-Bold")
    f.set_editor_property("size", round(size * 0.75))
    f.set_editor_property("letter_spacing", spacing)
    t.set_editor_property("font", f)
    if wrap:
        t.set_editor_property("auto_wrap_text", True)
    if justify:
        t.set_editor_property("justification", justify)
    return t


def vec2(x, y):
    """SlateBrush.ImageSize is a DeprecateSlateVector2D, which takes no constructor arguments."""
    v = unreal.DeprecateSlateVector2D()
    v.set_editor_property("x", float(x))
    v.set_editor_property("y", float(y))
    return v


def brush(tex=None, draw=unreal.SlateBrushDrawType.IMAGE, margin=0.0, size=None, tint=None):
    b = unreal.SlateBrush()
    if tex is not None:
        b.set_editor_property("resource_object", tex)
        b.set_editor_property("image_size", vec2(*(size or (tex.blueprint_get_size_x(), tex.blueprint_get_size_y()))))
    elif size:
        b.set_editor_property("image_size", vec2(*size))
    b.set_editor_property("draw_as", draw)
    if margin:
        b.set_editor_property("margin", unreal.Margin(margin, margin, margin, margin))
    if tint:
        b.set_editor_property("tint_color", unreal.SlateColor(lin(tint)))
    return b


def image(name, tex=None, draw=unreal.SlateBrushDrawType.IMAGE, margin=0.0, size=None, tint=None):
    i = new(unreal.Image, name)
    i.set_editor_property("brush", brush(tex, draw, margin, size, tint))
    return i


def place(canvas, w, x0, y0, x1=None, y1=None, auto=False, align=(0.0, 0.0)):
    s = canvas.add_child_to_canvas(w)
    s.set_position(unreal.Vector2D(x0, y0))
    if auto:
        s.set_auto_size(True)
    else:
        s.set_size(unreal.Vector2D(x1 - x0, y1 - y0))
    s.set_alignment(unreal.Vector2D(*align))
    return s


def fill_overlay(o, w, pad=(0, 0, 0, 0), h=unreal.HorizontalAlignment.H_ALIGN_FILL,
                 v=unreal.VerticalAlignment.V_ALIGN_FILL):
    s = o.add_child_to_overlay(w)
    s.set_padding(unreal.Margin(*pad))
    s.set_horizontal_alignment(h)
    s.set_vertical_alignment(v)
    return s


def stack(name):
    st = new(unreal.StackBox, name)
    st.set_editor_property("orientation", unreal.Orientation.ORIENT_VERTICAL)
    return st


def stack_add(st, child, pad=(0, 0, 0, 0)):
    sl = st.add_child_to_stack_box(child)
    sl.set_editor_property("padding", unreal.Margin(*pad))
    sl.set_editor_property("horizontal_alignment", unreal.HorizontalAlignment.H_ALIGN_FILL)
    return sl


def button(canvas, name, rect, label_sample="", count=False):
    """A design B button: a teal outline with teal text, and over it the focused state (amber
    block, arrow, ink text) in its own overlay, <name>Focus, faded by a field. The whole button is
    <name>, also faded by a field (shown or not)."""
    root = new(unreal.Overlay, name)
    place(canvas, root, *rect)
    fill_overlay(root, image(name + "Frame", TEX["T_DbgB_Outline"], unreal.SlateBrushDrawType.BOX, 0.125))
    fill_overlay(root, text(name + "Text", 24, "Black", C["frame"], 100, sample=label_sample),
                 pad=(46, 0, 0, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    if count:
        fill_overlay(root, text(name + "Count", 16, "Bold", C["muted"], sample="1/3"),
                     pad=(0, 0, 18, 0), h=unreal.HorizontalAlignment.H_ALIGN_RIGHT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    focus = new(unreal.Overlay, name + "Focus")
    fill_overlay(root, focus, pad=(0, 0, -6, -6))
    fill_overlay(focus, image(name + "Block", TEX["T_DbgB_Focus"], unreal.SlateBrushDrawType.BOX, 12.0 / 70.0))
    fill_overlay(focus, image(name + "Arrow", TEX["T_DbgB_Arrow"]),
                 pad=(18, 0, 0, 6), h=unreal.HorizontalAlignment.H_ALIGN_LEFT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    fill_overlay(focus, text(name + "InkText", 24, "Black", C["ink"], 100, sample=label_sample),
                 pad=(46, 0, 0, 6), h=unreal.HorizontalAlignment.H_ALIGN_LEFT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    if count:
        fill_overlay(focus, text(name + "InkCount", 16, "Bold", C["ink"], sample="1/3"),
                     pad=(0, 0, 24, 6), h=unreal.HorizontalAlignment.H_ALIGN_RIGHT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    return root


# ---------- tree ----------
# Fit > Page > Canvas come from UMGToolSet.AddWidget (Python can't set the tree's root).
P = wbp.get_path_name() + ":WidgetTree."
fit = unreal.find_object(None, P + "Fit")
page = unreal.find_object(None, P + "Page")
cv = unreal.find_object(None, P + "Canvas")
if cv is None or cv.get_children_count() > 0:
    raise RuntimeError("needs a fresh UW_DebuggerB with Fit > Page > Canvas (add them with UMGToolSet.AddWidget)")
fit.set_editor_property("stretch", unreal.Stretch.SCALE_TO_FIT)
fit.set_editor_property("visibility", unreal.SlateVisibility.HIT_TEST_INVISIBLE)
page.set_editor_property("width_override", float(L["page"][0]))
page.set_editor_property("height_override", float(L["page"][1]))
page.set_editor_property("override_width_override", True)
page.set_editor_property("override_height_override", True)
W, H = L["page"]

place(cv, image("Base", TEX["T_DbgB_Base"]), 0, 0, W, H)

# sidebar
place(cv, text("PatientName", 30, "Black", C["ink"], wrap=True, sample="PRICE, ELEANOR M."), *L["patient_name"])
place(cv, text("PatientAka", 28, "Black", C["text"], sample="\"NELL\""), *L["patient_aka"])
place(cv, text("PatientInfo", 17, "Bold", C["muted"], 120, sample="71  /  BAKER"), *L["patient_info"])
place(cv, text("LayerNumber", 24, "Bold", C["text"], sample="3"), *L["layer"])
place(cv, text("LayerTitle", 22, "Bold", C["amber"], sample="Pick Up 5 PM"), *L["layer_title"])
place(cv, text("TakeNumber", 24, "Bold", C["text"], sample="1"), *L["take"])
for i, r in enumerate(L["vitals"]):
    place(cv, image("Vital%d" % i, None, size=(22, 22), tint=C["red"]), *r)

# main panel tab and badge. Overlays with an image under the text: UEFN's validation refuses
# Border (and HorizontalBox, VerticalBox; StackBox is allowed).
tab = new(unreal.Overlay, "MainTabBox")
fill_overlay(tab, image("MainTabFill", None, tint=C["frame"]))
fill_overlay(tab, text("MainTitle", 19, "Black", C["ink"], 160, sample="CASE FILE"),
             pad=(12, 0, 12, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
place(cv, tab, L["main_tab"][0], L["main_tab"][1], auto=True)
# In its own overlay so the badge hides when empty (MainBadgeOpacity).
badge_wrap = new(unreal.Overlay, "MainBadgeWrap")
fill_overlay(badge_wrap, image("MainBadgeFill", TEX["T_DbgB_Badge"], unreal.SlateBrushDrawType.BOX, 0.125))
fill_overlay(badge_wrap, text("MainBadge", 19, "Bold", C["frame"], 100, sample="1/3"),
             pad=(10, 0, 10, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT, v=unreal.VerticalAlignment.V_ALIGN_CENTER)
place(cv, badge_wrap, L["main_badge"][0], L["main_badge"][1], auto=True, align=(1.0, 0.0))

# pages
pages = new(unreal.WidgetSwitcher, "Pages")
place(cv, pages, 0, 0, W, H)

# 0: the file, four entries a page, MORE and the file's button
pf = new(unreal.CanvasPanel, "FilePage")
pages.add_child(pf)
entries = stack("EntryStack")
place(pf, entries, *L["file_body"])
entries.set_editor_property("clipping", unreal.WidgetClipping.CLIP_TO_BOUNDS)
for i in range(4):
    stack_add(entries, text("Tag%d" % i, 20, "Black", C["amber"], 150, sample="WALT"), (0, 0 if i == 0 else 16, 0, 2))
    stack_add(entries, text("Entry%d" % i, 25, "Regular", C["text"], wrap=True,
                            sample="Her husband. They ran Price's Bakery on Cutler Row for 38 years."))
button(pf, "MoreButton", L["file_more"], "MORE", count=True)
button(pf, "FileButton", L["file_button"], "ATTACH TO DREAMER")

# 1: the scene log: older lines dim, the newest big with an amber gutter, then CONTINUE or the
# speak cue
pl = new(unreal.CanvasPanel, "LogPage")
pages.add_child(pl)
log = stack("LogStack")
place(pl, log, *L["log_body"])
log.set_editor_property("clipping", unreal.WidgetClipping.CLIP_TO_BOUNDS)
stack_add(log, text("LogPrev", 22, "Regular", C["dim"], wrap=True,
                    sample="Nell turns the order slip over and reads it twice."))
current = new(unreal.Overlay, "LogCurrentBox")
fill_overlay(current, image("LogBar", None, size=(6, 42), tint=C["amber"]), pad=(0, 6, 0, 0),
             h=unreal.HorizontalAlignment.H_ALIGN_LEFT, v=unreal.VerticalAlignment.V_ALIGN_TOP)
fill_overlay(current, text("LogCurrent", 36, "Bold", C["text"], wrap=True, sample="She puts the order pad down."),
             pad=(22, 0, 0, 0), v=unreal.VerticalAlignment.V_ALIGN_TOP)
stack_add(log, current, (0, 22, 0, 26))
cue = new(unreal.Overlay, "LogCue")
stack_add(log, cue)
fill_overlay(cue, image("Continue", TEX["T_DbgB_Continue"]), h=unreal.HorizontalAlignment.H_ALIGN_LEFT,
             v=unreal.VerticalAlignment.V_ALIGN_TOP)
speak = new(unreal.Overlay, "Speak")
fill_overlay(cue, speak, pad=(-16, -16, 0, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT,
             v=unreal.VerticalAlignment.V_ALIGN_TOP)
fill_overlay(speak, image("SpeakPanel", TEX["T_DbgB_Speak"]))
fill_overlay(speak, text("SpeakAsk", 32, "Bold", C["speaktext"], sample="What do you have to say?"),
             pad=(16 + 112, 16 + 56, 16, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT,
             v=unreal.VerticalAlignment.V_ALIGN_TOP)

# 2: a menu: a line of context, then up to five options
pm = new(unreal.CanvasPanel, "MenuPage")
pages.add_child(pm)
place(pm, text("MenuIntro", 24, "Regular", C["muted"], wrap=True, sample="Link stable. Dreamer is under."), *L["menu_intro"])
for i, r in enumerate(L["menu"]):
    button(pm, "Option%d" % i, r, "VIEW THE DREAM")

# Lumi awake, the footer, the scanlines
place(cv, image("LumiOn", TEX["T_DbgB_LumiOn"]), 0, 0, W, H)
place(cv, text("FooterFile", 17, "Regular", C["dim"], sample="nell_d3.dream"), *L["footer_file"])
place(cv, text("FooterHint", 19, "Regular", C["muted"], justify=unreal.TextJustify.RIGHT,
               sample="MOUSE click   SPACE select"), *L["footer_hint"])
place(cv, image("Scan", TEX["T_DbgB_Scan"]), 0, 0, W, H)

unreal.BlueprintEditorLibrary.compile_blueprint(wbp)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(wbp, False))
