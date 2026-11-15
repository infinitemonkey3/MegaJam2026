"""One-off, in the UEFN editor (play test, 2026-11-14): UW_DebuggerB's text came out a third too
big and all Regular. UMG font sizes are points (1 pt = 4/3 px), and the mockups' sizes were px;
and Fortnite's NotoSans has only the faces NotoSans-Regular, -Bold and -Italic, so "Black" and
"Bold" fell back to Regular. Scales every size by 0.75 and maps the faces, and clips the file's
entries and the log to their boxes. build_debugger_b.py does both from the start now.
"""
import unreal

wbp = unreal.load_asset("/76e8e788-bf61-4537-8f86-b062e519fb2d/DreamDebugger/UW_DebuggerB")
P = wbp.get_path_name() + ":WidgetTree."
FACES = {"Black": "NotoSans-Bold", "Bold": "NotoSans-Bold", "Regular": "NotoSans-Regular"}

root = unreal.find_object(None, P + "Fit")
todo, n = [root], 0
while todo:
    w = todo.pop()
    if w is None:
        continue
    if hasattr(w, "get_editor_property") and w.get_class().get_name().startswith("UEFN_TextBlock"):
        f = w.get_editor_property("font")
        face = str(f.get_editor_property("typeface_font_name"))
        if face in FACES:   # not converted yet
            f.set_editor_property("typeface_font_name", FACES[face])
            f.set_editor_property("size", round(f.get_editor_property("size") * 0.75))
            w.set_editor_property("font", f)
            n += 1
    if isinstance(w, unreal.PanelWidget):
        todo += [w.get_child_at(i) for i in range(w.get_children_count())]
    elif isinstance(w, unreal.ContentWidget):
        todo.append(w.get_content())
print("texts fixed", n)
for name in ("EntryStack", "LogStack"):
    unreal.find_object(None, P + name).set_editor_property("clipping", unreal.WidgetClipping.CLIP_TO_BOUNDS)
unreal.BlueprintEditorLibrary.compile_blueprint(wbp)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(wbp, False))
