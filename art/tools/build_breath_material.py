"""In the UEFN editor: Nell's breathing recliner (Chip, 2026-11-14).

Imports T_Room_Recliner_Nell_Breath (make_breath_frame.py), builds M_Room_Breath (Room/Materials):
the card material (unlit, masked, two-sided, texture x Brightness into emissive) crossfading Tex
and Tex2 on a slow sine, and points MI_Room_Recliner_Nell at it with Tex2 set. The patient
switch in game_director keeps using MI_Room_Recliner_Nell, so nothing in Verse changes.
"""
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
MATS = G + "/Room/Materials"
TEXS = G + "/Room/Textures"
SRC = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/style-test/final/T_Room_Recliner_Nell_Breath.png"
mel = unreal.MaterialEditingLibrary
tools = unreal.AssetToolsHelpers.get_asset_tools()

# The second frame, set up like the first.
t = unreal.AssetImportTask()
t.filename = SRC
t.destination_path = TEXS
t.destination_name = "T_Room_Recliner_Nell_Breath"
t.automated = True
t.replace_existing = True
tools.import_asset_tasks([t])
first = unreal.load_asset(TEXS + "/T_Room_Recliner_Nell")
second = unreal.load_asset(TEXS + "/T_Room_Recliner_Nell_Breath")
for prop in ("lod_group", "mip_gen_settings", "compression_settings", "srgb", "never_stream"):
    try:
        second.set_editor_property(prop, first.get_editor_property(prop))
    except Exception as e:
        print("copy", prop, e)
unreal.EditorAssetLibrary.save_loaded_asset(second)

# The material.
path = MATS + "/M_Room_Breath"
if unreal.EditorAssetLibrary.does_asset_exist(path):
    unreal.EditorAssetLibrary.delete_asset(path)
m = tools.create_asset("M_Room_Breath", MATS, unreal.Material, unreal.MaterialFactoryNew())
m.set_editor_property("shading_model", unreal.MaterialShadingModel.MSM_UNLIT)
m.set_editor_property("blend_mode", unreal.BlendMode.BLEND_MASKED)
m.set_editor_property("two_sided", True)


def node(cls, x, y):
    return mel.create_material_expression(m, cls, x, y)


tex0 = node(unreal.MaterialExpressionTextureSampleParameter2D, -900, -200)
tex0.set_editor_property("parameter_name", "Tex")
tex0.set_editor_property("texture", first)
tex1 = node(unreal.MaterialExpressionTextureSampleParameter2D, -900, 100)
tex1.set_editor_property("parameter_name", "Tex2")
tex1.set_editor_property("texture", second)

# a = 0.5 + 0.5 sin(2 pi Time x BreathRate): one breath every 1 / BreathRate seconds.
time = node(unreal.MaterialExpressionTime, -1300, 400)
rate = node(unreal.MaterialExpressionScalarParameter, -1300, 500)
rate.set_editor_property("parameter_name", "BreathRate")
rate.set_editor_property("default_value", 0.22)
cycles = node(unreal.MaterialExpressionMultiply, -1100, 450)
mel.connect_material_expressions(time, "", cycles, "A")
mel.connect_material_expressions(rate, "", cycles, "B")
sine = node(unreal.MaterialExpressionSine, -950, 450)
sine.set_editor_property("period", 1.0)
mel.connect_material_expressions(cycles, "", sine, "")
half = node(unreal.MaterialExpressionMultiply, -800, 450)
half.set_editor_property("const_b", 0.5)
mel.connect_material_expressions(sine, "", half, "A")
alpha = node(unreal.MaterialExpressionAdd, -650, 450)
alpha.set_editor_property("const_b", 0.5)
mel.connect_material_expressions(half, "", alpha, "A")

rgb = node(unreal.MaterialExpressionLinearInterpolate, -500, -100)
mel.connect_material_expressions(tex0, "RGB", rgb, "A")
mel.connect_material_expressions(tex1, "RGB", rgb, "B")
mel.connect_material_expressions(alpha, "", rgb, "Alpha")
op = node(unreal.MaterialExpressionLinearInterpolate, -500, 200)
mel.connect_material_expressions(tex0, "A", op, "A")
mel.connect_material_expressions(tex1, "A", op, "B")
mel.connect_material_expressions(alpha, "", op, "Alpha")

bright = node(unreal.MaterialExpressionScalarParameter, -500, -300)
bright.set_editor_property("parameter_name", "Brightness")
bright.set_editor_property("default_value", 1.0)
lit = node(unreal.MaterialExpressionMultiply, -250, -150)
mel.connect_material_expressions(rgb, "", lit, "A")
mel.connect_material_expressions(bright, "", lit, "B")
mel.connect_material_property(lit, "", unreal.MaterialProperty.MP_EMISSIVE_COLOR)
mel.connect_material_property(op, "", unreal.MaterialProperty.MP_OPACITY_MASK)
mel.recompile_material(m)
unreal.EditorAssetLibrary.save_loaded_asset(m)

# Nell's recliner instance onto it.
mi = unreal.load_asset(MATS + "/MI_Room_Recliner_Nell")
old_bright = mel.get_material_instance_scalar_parameter_value(mi, "Brightness")
mi.set_editor_property("parent", m)
mel.set_material_instance_texture_parameter_value(mi, "Tex", first)
mel.set_material_instance_texture_parameter_value(mi, "Tex2", second)
mel.set_material_instance_scalar_parameter_value(mi, "Brightness", old_bright)
mel.update_material_instance(mi)
print("brightness", old_bright, "saved", unreal.EditorAssetLibrary.save_loaded_asset(mi))
