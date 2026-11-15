"""In the UEFN editor, after add_mouth_to_breath.py: Nell awake (Chip, 2026-11-15).

Adds T_Client_Nell_EyesOpen (make_eyes_open.py: her face with eyes open and a content smile,
transparent elsewhere, in the recliner texture's own UV space) to M_Room_Breath. The scalar
EyesOpen (0 asleep, 1 awake) blends it in by its alpha. It goes after the mouth, so while she's
awake the smile covers the talking flipbook (whose frames are cut from her sleeping, downturned
mouth). game_director sets EyesOpen for her waking lines.
"""
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
MATS = G + "/Room/Materials"
TEXS = G + "/Room/Textures"
SRC = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/style-test/final/T_Client_Nell_EyesOpen.png"
mel = unreal.MaterialEditingLibrary
tools = unreal.AssetToolsHelpers.get_asset_tools()

t = unreal.AssetImportTask()
t.filename = SRC
t.destination_path = TEXS
t.destination_name = "T_Client_Nell_EyesOpen"
t.automated = True
t.replace_existing = True
tools.import_asset_tasks([t])
eyes = unreal.load_asset(TEXS + "/T_Client_Nell_EyesOpen")
first = unreal.load_asset(TEXS + "/T_Room_Recliner_Nell")
for prop in ("lod_group", "compression_settings", "srgb", "never_stream", "address_x", "address_y"):
    try:
        eyes.set_editor_property(prop, first.get_editor_property(prop))
    except Exception as e:
        print("copy", prop, e)
unreal.EditorAssetLibrary.save_loaded_asset(eyes)

m = unreal.load_asset(MATS + "/M_Room_Breath")
if "EyesOpen" in [str(n) for n in mel.get_scalar_parameter_names(m)]:
    print("M_Room_Breath already has EyesOpen; texture reimported only")
else:
    emissive = mel.get_material_property_input_node(m, unreal.MaterialProperty.MP_EMISSIVE_COLOR)
    mouthed, bright = mel.get_inputs_for_material_expression(m, emissive)[:2]

    def node(cls, x, y):
        return mel.create_material_expression(m, cls, x, y)

    tex = node(unreal.MaterialExpressionTextureSampleParameter2D, -150, 1400)
    tex.set_editor_property("parameter_name", "EyesTex")
    tex.set_editor_property("texture", eyes)
    awake = node(unreal.MaterialExpressionScalarParameter, -150, 1650)
    awake.set_editor_property("parameter_name", "EyesOpen")
    awake.set_editor_property("default_value", 0.0)
    weight = node(unreal.MaterialExpressionMultiply, 50, 1500)
    mel.connect_material_expressions(tex, "A", weight, "A")
    mel.connect_material_expressions(awake, "", weight, "B")
    mixed = node(unreal.MaterialExpressionLinearInterpolate, 350, 300)
    mel.connect_material_expressions(mouthed, "", mixed, "A")
    mel.connect_material_expressions(tex, "RGB", mixed, "B")
    mel.connect_material_expressions(weight, "", mixed, "Alpha")
    mel.connect_material_expressions(mixed, "", emissive, "A")
    mel.connect_material_expressions(bright, "", emissive, "B")
    mel.recompile_material(m)
    print("material saved", unreal.EditorAssetLibrary.save_loaded_asset(m))

mi = unreal.load_asset(MATS + "/MI_Room_Recliner_Nell")
mel.set_material_instance_texture_parameter_value(mi, "EyesTex", eyes)
mel.update_material_instance(mi)
print("instance saved", unreal.EditorAssetLibrary.save_loaded_asset(mi))
print("scalars:", [str(n) for n in mel.get_scalar_parameter_names(m)])
