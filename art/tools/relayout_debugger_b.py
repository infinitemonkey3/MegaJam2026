"""In the UEFN editor: reimports the design B textures and moves UW_DebuggerB's widgets to
art/debugger_b/layout.json, without rebuilding the widget (so its Verse fields and bindings stay).
Run after make_debugger_b.py changes the layout.
"""
import json
import os
import unreal

FOLDER = "/76e8e788-bf61-4537-8f86-b062e519fb2d/DreamDebugger"
ART = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/debugger_b"
L = json.load(open(os.path.join(ART, "layout.json")))
W, H = L["page"]

tasks = []
for name in ("T_DbgB_Base", "T_DbgB_LumiOn", "T_DbgB_Scan", "T_DbgB_Speak", "T_DbgB_Continue"):
    t = unreal.AssetImportTask()
    t.filename = os.path.join(ART, name + ".png")
    t.destination_path = FOLDER
    t.destination_name = name
    t.automated = True
    t.replace_existing = True
    tasks.append(t)
unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
for t in tasks:
    tex = unreal.load_asset(FOLDER + "/" + t.destination_name)
    tex.set_editor_property("lod_group", unreal.TextureGroup.TEXTUREGROUP_UI)
    tex.set_editor_property("mip_gen_settings", unreal.TextureMipGenSettings.TMGS_NO_MIPMAPS)
    tex.set_editor_property("never_stream", True)
    tex.set_editor_property("compression_settings", unreal.TextureCompressionSettings.TC_EDITOR_ICON)
    unreal.EditorAssetLibrary.save_loaded_asset(tex)

wbp = unreal.load_asset(FOLDER + "/UW_DebuggerB")
P = wbp.get_path_name() + ":WidgetTree."


def w(name):
    x = unreal.find_object(None, P + name)
    if x is None:
        raise RuntimeError("no widget " + name)
    return x


def move(name, x0, y0, x1=None, y1=None):
    s = w(name).get_editor_property("slot")
    s.set_position(unreal.Vector2D(x0, y0))
    if x1 is not None:
        s.set_size(unreal.Vector2D(x1 - x0, y1 - y0))


page = w("Page")
page.set_editor_property("width_override", float(W))
page.set_editor_property("height_override", float(H))
for n in ("Base", "Pages", "LumiOn", "Scan"):
    move(n, 0, 0, W, H)
# The sidebar has one row for the dream (LayerNumber's spot); DreamNumber is unused.
move("LayerNumber", *L["layer"])
move("LayerTitle", *L["layer_title"])
move("TakeNumber", *L["take"])
w("DreamNumber").set_editor_property("visibility", unreal.SlateVisibility.COLLAPSED)
for i, r in enumerate(L["vitals"]):
    move("Vital%d" % i, *r)
move("PatientName", *L["patient_name"])
move("PatientAka", *L["patient_aka"])
move("PatientInfo", *L["patient_info"])
move("MainTabBox", *L["main_tab"])
move("MainBadgeWrap", *L["main_badge"])
move("EntryStack", *L["file_body"])
move("MoreButton", *L["file_more"])
move("FileButton", *L["file_button"])
move("LogStack", *L["log_body"])
move("MenuIntro", *L["menu_intro"])
for i, r in enumerate(L["menu"]):
    move("Option%d" % i, *r)
move("FooterFile", *L["footer_file"])
move("FooterHint", *L["footer_hint"])
# Full-page images draw at their slot's size; the speak panel and CONTINUE draw at their
# brush's size, so it follows the texture.
for image_name, tex_name in (("SpeakPanel", "T_DbgB_Speak"), ("Continue", "T_DbgB_Continue")):
    image = w(image_name)
    b = image.get_editor_property("brush")
    size = unreal.DeprecateSlateVector2D()
    tex = unreal.load_asset(FOLDER + "/" + tex_name)
    size.set_editor_property("x", float(tex.blueprint_get_size_x()))
    size.set_editor_property("y", float(tex.blueprint_get_size_y()))
    b.set_editor_property("image_size", size)
    image.set_editor_property("brush", b)
unreal.BlueprintEditorLibrary.compile_blueprint(wbp)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(wbp, False))
