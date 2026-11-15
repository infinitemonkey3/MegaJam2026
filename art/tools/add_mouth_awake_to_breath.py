"""In the UEFN editor, after add_eyes_to_breath.py: Nell talks while awake (Chip, 2026-11-15).

add_eyes_to_breath.py put the awake face on top of the mouth, so her lips stopped moving when
she woke. This puts the mouth back on top (base -> awake face -> mouth) and has the mouth sample
T_Client_Nell_Mouth_Awake_Atlas8 (make_mouth_awake.py, smiling shapes in the same 8-cell
layout) as MouthAwake at the same atlas UV, blended in by EyesOpen. Asleep: the old frames.
Awake and silent: the face patch's closed smile. Awake and talking: the smiling frames.
"""
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
MATS = G + "/Room/Materials"
TEXS = G + "/Room/Textures"
SRC = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/style-test/final/T_Client_Nell_Mouth_Awake_Atlas8.png"
mel = unreal.MaterialEditingLibrary

t = unreal.AssetImportTask()
t.filename = SRC
t.destination_path = TEXS
t.destination_name = "T_Client_Nell_Mouth_Awake_Atlas"
t.automated = True
t.replace_existing = True
unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([t])
awake_tex = unreal.load_asset(TEXS + "/T_Client_Nell_Mouth_Awake_Atlas")
asleep_tex = unreal.load_asset(TEXS + "/T_Client_Nell_Mouth_Atlas")
for prop in ("lod_group", "compression_settings", "srgb", "never_stream", "mip_gen_settings"):
    try:
        awake_tex.set_editor_property(prop, asleep_tex.get_editor_property(prop))
    except Exception as e:
        print("copy", prop, e)
unreal.EditorAssetLibrary.save_loaded_asset(awake_tex)

m = unreal.load_asset(MATS + "/M_Room_Breath")
names = [str(n) for n in mel.get_texture_parameter_names(m)] if hasattr(mel, "get_texture_parameter_names") else []
emissive = mel.get_material_property_input_node(m, unreal.MaterialProperty.MP_EMISSIVE_COLOR)
top, bright = mel.get_inputs_for_material_expression(m, emissive)[:2]
if "MouthAwake" in names:
    print("M_Room_Breath already has MouthAwake; texture reimported only")
else:
    # Today: emissive.A = eyes_lerp(A = mouth_lerp(A = rgb, B = Mouth.RGB, Alpha = mouth_w), B = EyesTex.RGB, Alpha = eyes_w)
    eyes_lerp = top
    mouth_lerp, eyes_tex, eyes_w = mel.get_inputs_for_material_expression(m, eyes_lerp)[:3]
    rgb, mouth_tex, mouth_w = mel.get_inputs_for_material_expression(m, mouth_lerp)[:3]
    uvs = [n for n in mel.get_inputs_for_material_expression(m, mouth_tex) if n][0]
    awake_param = [n for n in mel.get_inputs_for_material_expression(m, eyes_w) if n][1]   # EyesOpen
    print("found", eyes_lerp.get_name(), mouth_lerp.get_name(), mouth_tex.get_name(), uvs.get_name(), awake_param.get_name())

    awake = mel.create_material_expression(m, unreal.MaterialExpressionTextureSampleParameter2D, -150, 700)
    awake.set_editor_property("parameter_name", "MouthAwake")
    awake.set_editor_property("texture", awake_tex)
    mel.connect_material_expressions(uvs, "", awake, "UVs")
    pick = mel.create_material_expression(m, unreal.MaterialExpressionLinearInterpolate, 50, 800)
    mel.connect_material_expressions(mouth_tex, "RGB", pick, "A")
    mel.connect_material_expressions(awake, "RGB", pick, "B")
    mel.connect_material_expressions(awake_param, "", pick, "Alpha")

    # Reorder: eyes on the base, the mouth on top of that.
    mel.connect_material_expressions(rgb, "", eyes_lerp, "A")
    mel.connect_material_expressions(eyes_lerp, "", mouth_lerp, "A")
    mel.connect_material_expressions(pick, "", mouth_lerp, "B")
    mel.connect_material_expressions(mouth_lerp, "", emissive, "A")
    mel.connect_material_expressions(bright, "", emissive, "B")
    mel.recompile_material(m)
    print("material saved", unreal.EditorAssetLibrary.save_loaded_asset(m))

mi = unreal.load_asset(MATS + "/MI_Room_Recliner_Nell")
mel.set_material_instance_texture_parameter_value(mi, "MouthAwake", awake_tex)
mel.update_material_instance(mi)
print("instance saved", unreal.EditorAssetLibrary.save_loaded_asset(mi))
e2 = mel.get_material_property_input_node(m, unreal.MaterialProperty.MP_EMISSIVE_COLOR)
print("emissive A now", mel.get_inputs_for_material_expression(m, e2)[0].get_name())
