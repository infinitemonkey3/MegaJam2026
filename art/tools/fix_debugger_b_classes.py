"""One-off, in the UEFN editor: swaps the widget classes UEFN's validation refuses out of
UW_DebuggerB (Border, HorizontalBox, VerticalBox and their slots) for allowed ones (Overlay +
Image, StackBox), in place, so the Verse field bindings (which name text widgets, not their
containers) survive. build_debugger_b.py builds it this way from the start now.
"""
import json
import os
import unreal

FOLDER = "/76e8e788-bf61-4537-8f86-b062e519fb2d/DreamDebugger"
ART = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/debugger_b"
L = json.load(open(os.path.join(ART, "layout.json")))
C = L["colors"]
wbp = unreal.load_asset(FOLDER + "/UW_DebuggerB")
tree = unreal.find_object(None, wbp.get_path_name() + ":WidgetTree")
P = wbp.get_path_name() + ":WidgetTree."


def w(name):
    return unreal.find_object(None, P + name)


def lin(h):
    h = h.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    return unreal.LinearColor(r ** 2.2, g ** 2.2, b ** 2.2, 1.0)


def new(cls, name):
    x = w(name) or unreal.new_object(cls, outer=tree, name=name)
    try:
        x.set_editor_property("is_variable", True)
    except Exception:
        pass
    return x


def fill_image(name, tex=None, margin=0.0, tint=None):
    i = new(unreal.Image, name)
    b = unreal.SlateBrush()
    if tex is not None:
        b.set_editor_property("resource_object", tex)
        b.set_editor_property("draw_as", unreal.SlateBrushDrawType.BOX)
        b.set_editor_property("margin", unreal.Margin(margin, margin, margin, margin))
    if tint:
        b.set_editor_property("tint_color", unreal.SlateColor(lin(tint)))
    i.set_editor_property("brush", b)
    return i


def overlay_add(o, child, pad=(0, 0, 0, 0), h=unreal.HorizontalAlignment.H_ALIGN_FILL,
                v=unreal.VerticalAlignment.V_ALIGN_FILL):
    s = o.add_child_to_overlay(child)
    s.set_padding(unreal.Margin(*pad))
    s.set_horizontal_alignment(h)
    s.set_vertical_alignment(v)


def copy_canvas_slot(old, new_widget, canvas):
    s = old.get_editor_property("slot")
    pos, size, auto, align = s.get_position(), s.get_size(), s.get_auto_size(), s.get_alignment()
    canvas.remove_child(old)
    ns = canvas.add_child_to_canvas(new_widget)
    ns.set_position(pos)
    ns.set_size(size)
    ns.set_auto_size(auto)
    ns.set_alignment(align)


def stack_add(stack, child, pad=(0, 0, 0, 0)):
    s = stack.add_child_to_stack_box(child)
    s.set_editor_property("padding", unreal.Margin(*pad))
    s.set_editor_property("horizontal_alignment", unreal.HorizontalAlignment.H_ALIGN_FILL)
    return s


canvas = w("Canvas")

# The main tab: Border -> Overlay with a teal fill under the title.
tab = w("MainTab")
if isinstance(tab, unreal.Border):
    title = w("MainTitle")
    tab.remove_child(title)
    box = new(unreal.Overlay, "MainTabBox")
    overlay_add(box, fill_image("MainTabFill", tint=C["frame"]))
    overlay_add(box, title, pad=(12, 0, 12, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT,
                v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    copy_canvas_slot(tab, box, canvas)
    print("tab done")

# The badge: the Border inside MainBadgeWrap -> a framed image under the text.
wrap = w("MainBadgeWrap")
badge_box = w("MainBadgeBox")
if badge_box is not None and isinstance(badge_box, unreal.Border) and wrap.has_child(badge_box):
    text = w("MainBadge")
    badge_box.remove_child(text)
    wrap.remove_child(badge_box)
    overlay_add(wrap, fill_image("MainBadgeFill", unreal.load_asset(FOLDER + "/T_DbgB_Badge"), 0.125))
    overlay_add(wrap, text, pad=(10, 0, 10, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT,
                v=unreal.VerticalAlignment.V_ALIGN_CENTER)
    print("badge done")

# The file's entries: VerticalBox -> StackBox.
entries = w("Entries")
if isinstance(entries, unreal.VerticalBox):
    stack = new(unreal.StackBox, "EntryStack")
    stack.set_editor_property("orientation", unreal.Orientation.ORIENT_VERTICAL)
    kids = [entries.get_child_at(i) for i in range(entries.get_children_count())]
    entries.clear_children()
    for k in kids:
        is_tag = k.get_name().startswith("Tag")
        first = k.get_name() == "Tag0"
        stack_add(stack, k, (0, 0 if first else 16, 0, 2) if is_tag else (0, 0, 0, 0))
    copy_canvas_slot(entries, stack, w("FilePage"))
    print("entries done", len(kids))

# The log: VerticalBox -> StackBox; the current line's HorizontalBox -> Overlay (bar + text).
log = w("Log")
if isinstance(log, unreal.VerticalBox):
    prev, row, cue = w("LogPrev"), w("LogCurrentRow"), w("LogCue")
    bar, cur = w("LogBar"), w("LogCurrent")
    row.clear_children()
    log.clear_children()
    current = new(unreal.Overlay, "LogCurrentBox")
    overlay_add(current, bar, pad=(0, 6, 0, 0), h=unreal.HorizontalAlignment.H_ALIGN_LEFT,
                v=unreal.VerticalAlignment.V_ALIGN_TOP)
    overlay_add(current, cur, pad=(22, 0, 0, 0), v=unreal.VerticalAlignment.V_ALIGN_TOP)
    stack = new(unreal.StackBox, "LogStack")
    stack.set_editor_property("orientation", unreal.Orientation.ORIENT_VERTICAL)
    stack_add(stack, prev)
    stack_add(stack, current, (0, 22, 0, 26))
    stack_add(stack, cue)
    copy_canvas_slot(log, stack, w("LogPage"))
    print("log done")

# Anything of a refused class still in the tree?
bad = (unreal.Border, unreal.VerticalBox, unreal.HorizontalBox)
left = []
stack_ = [w("Fit")]
while stack_:
    x = stack_.pop()
    if x is None:
        continue
    if isinstance(x, bad):
        left.append(x.get_name())
    if isinstance(x, unreal.PanelWidget):
        stack_ += [x.get_child_at(i) for i in range(x.get_children_count())]
    elif isinstance(x, unreal.ContentWidget):
        stack_.append(x.get_content())
print("refused classes left in tree:", left)
unreal.BlueprintEditorLibrary.compile_blueprint(wbp)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(wbp, False))
