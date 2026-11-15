"""In the UEFN editor, after build_breath_material.py: Nell's talking mouth (Chip, 2026-11-14).

Adds a flipbook mouth to M_Room_Breath. T_Client_Mouth_Atlas (art/tools/client_parts.py) holds
four 256 px cells, closed, half, open, half, cut from the same drawing as the recliner texture.
On the recliner texture (2048 px) a cell covers x 1243..1450, y 613..820 (client_parts prints
it). While the scalar parameter Talking is 1 the material cycles the cells (MouthFps frames a
second) over that spot, blended by the cell's feathered alpha; at 0 the recliner shows as drawn.
game_director sets Talking from the persona's say events.
"""
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
MATS = G + "/Room/Materials"
TEXS = G + "/Room/Textures"
SRC = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/style-test/final/T_Client_Mouth_Atlas.png"
mel = unreal.MaterialEditingLibrary
tools = unreal.AssetToolsHelpers.get_asset_tools()

t = unreal.AssetImportTask()
t.filename = SRC
t.destination_path = TEXS
t.destination_name = "T_Client_Nell_Mouth_Atlas"
t.automated = True
t.replace_existing = True
tools.import_asset_tasks([t])
atlas = unreal.load_asset(TEXS + "/T_Client_Nell_Mouth_Atlas")
first = unreal.load_asset(TEXS + "/T_Room_Recliner_Nell")
for prop in ("lod_group", "compression_settings", "srgb", "never_stream"):
    try:
        atlas.set_editor_property(prop, first.get_editor_property(prop))
    except Exception as e:
        print("copy", prop, e)
atlas.set_editor_property("mip_gen_settings", unreal.TextureMipGenSettings.TMGS_NO_MIPMAPS)
unreal.EditorAssetLibrary.save_loaded_asset(atlas)

m = unreal.load_asset(MATS + "/M_Room_Breath")
# Emissive is (breathing colour) x Brightness; the mouth goes between the two.
emissive = mel.get_material_property_input_node(m, unreal.MaterialProperty.MP_EMISSIVE_COLOR)
rgb, bright = mel.get_inputs_for_material_expression(m, emissive)[:2]
if "Mouth" in [str(n) for n in mel.get_texture_parameter_names(m)] if hasattr(mel, "get_texture_parameter_names") else []:
    raise RuntimeError("M_Room_Breath already has the mouth; rebuild it with build_breath_material.py first")


def node(cls, x, y):
    return mel.create_material_expression(m, cls, x, y)


S = 2048.0
uv = node(unreal.MaterialExpressionTextureCoordinate, -1500, 800)
origin = node(unreal.MaterialExpressionConstant2Vector, -1500, 900)
origin.set_editor_property("r", 1243.0 / S)
origin.set_editor_property("g", 613.0 / S)
local = node(unreal.MaterialExpressionSubtract, -1350, 850)
mel.connect_material_expressions(uv, "", local, "A")
mel.connect_material_expressions(origin, "", local, "B")
scale = node(unreal.MaterialExpressionDivide, -1200, 850)
scale.set_editor_property("const_b", 207.0 / S)
mel.connect_material_expressions(local, "", scale, "A")
clamped = node(unreal.MaterialExpressionClamp, -1050, 850)
mel.connect_material_expressions(scale, "", clamped, "")
mu = node(unreal.MaterialExpressionComponentMask, -900, 800)
mu.set_editor_property("r", True)
mu.set_editor_property("g", False)   # a new mask starts with R and G both on
mel.connect_material_expressions(clamped, "", mu, "")
mv = node(unreal.MaterialExpressionComponentMask, -900, 950)
mv.set_editor_property("g", True)
mv.set_editor_property("r", False)
mel.connect_material_expressions(clamped, "", mv, "")

# frame = floor(frac(Time x MouthFps / 4) x 4): 0..3 at MouthFps frames a second.
time = node(unreal.MaterialExpressionTime, -1500, 1100)
fps = node(unreal.MaterialExpressionScalarParameter, -1500, 1200)
fps.set_editor_property("parameter_name", "MouthFps")
fps.set_editor_property("default_value", 9.0)
cyc = node(unreal.MaterialExpressionMultiply, -1350, 1150)
mel.connect_material_expressions(time, "", cyc, "A")
mel.connect_material_expressions(fps, "", cyc, "B")
quarter = node(unreal.MaterialExpressionMultiply, -1200, 1150)
quarter.set_editor_property("const_b", 0.25)
mel.connect_material_expressions(cyc, "", quarter, "A")
frac = node(unreal.MaterialExpressionFrac, -1050, 1150)
mel.connect_material_expressions(quarter, "", frac, "")
four = node(unreal.MaterialExpressionMultiply, -900, 1150)
four.set_editor_property("const_b", 4.0)
mel.connect_material_expressions(frac, "", four, "A")
frame = node(unreal.MaterialExpressionFloor, -750, 1150)
mel.connect_material_expressions(four, "", frame, "")

cellu = node(unreal.MaterialExpressionAdd, -600, 900)
mel.connect_material_expressions(frame, "", cellu, "A")
mel.connect_material_expressions(mu, "", cellu, "B")
atlasu = node(unreal.MaterialExpressionMultiply, -450, 900)
atlasu.set_editor_property("const_b", 0.25)
mel.connect_material_expressions(cellu, "", atlasu, "A")
auv = node(unreal.MaterialExpressionAppendVector, -300, 900)
mel.connect_material_expressions(atlasu, "", auv, "A")
mel.connect_material_expressions(mv, "", auv, "B")
mouth = node(unreal.MaterialExpressionTextureSampleParameter2D, -150, 900)
mouth.set_editor_property("parameter_name", "Mouth")
mouth.set_editor_property("texture", atlas)
mel.connect_material_expressions(auv, "", mouth, "UVs")

talking = node(unreal.MaterialExpressionScalarParameter, -150, 1150)
talking.set_editor_property("parameter_name", "Talking")
talking.set_editor_property("default_value", 0.0)
weight = node(unreal.MaterialExpressionMultiply, 50, 1050)
mel.connect_material_expressions(mouth, "A", weight, "A")
mel.connect_material_expressions(talking, "", weight, "B")
mixed = node(unreal.MaterialExpressionLinearInterpolate, 200, 300)
mel.connect_material_expressions(rgb, "", mixed, "A")
mel.connect_material_expressions(mouth, "RGB", mixed, "B")
mel.connect_material_expressions(weight, "", mixed, "Alpha")
mel.connect_material_expressions(mixed, "", emissive, "A")
mel.connect_material_expressions(bright, "", emissive, "B")
mel.recompile_material(m)
print("material saved", unreal.EditorAssetLibrary.save_loaded_asset(m))

mi = unreal.load_asset(MATS + "/MI_Room_Recliner_Nell")
mel.set_material_instance_texture_parameter_value(mi, "Mouth", atlas)
mel.update_material_instance(mi)
print("instance saved", unreal.EditorAssetLibrary.save_loaded_asset(mi))
