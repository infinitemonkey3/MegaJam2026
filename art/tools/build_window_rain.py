"""In the UEFN editor: rain on the room's window (Chip, 2026-11-14).

Imports T_Room_RainStreaks and T_Room_WindowGlassMask (make_window_rain.py) and builds
M_Room_WallRain (Room/Materials): the card material (unlit, masked, two-sided, texture x
Brightness into emissive) plus two layers of streaks falling at different sizes and speeds,
added in RainColor, only where the glass mask is. MI_Room_BackWallClean_A is pointed at it.

Parameters: RainSpeed (wall heights a second for the near layer), RainStrength, RainColor.
"""
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
MATS = G + "/Room/Materials"
TEXS = G + "/Room/Textures"
FINAL = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/style-test/final/"
mel = unreal.MaterialEditingLibrary
tools = unreal.AssetToolsHelpers.get_asset_tools()

tasks = []
for name in ("T_Room_RainStreaks", "T_Room_WindowGlassMask"):
    t = unreal.AssetImportTask()
    t.filename = FINAL + name + ".png"
    t.destination_path = TEXS
    t.destination_name = name
    t.automated = True
    t.replace_existing = True
    tasks.append(t)
tools.import_asset_tasks(tasks)
streaks = unreal.load_asset(TEXS + "/T_Room_RainStreaks")
mask = unreal.load_asset(TEXS + "/T_Room_WindowGlassMask")
for tex in (streaks, mask):
    tex.set_editor_property("srgb", False)
    tex.set_editor_property("never_stream", True)
    unreal.EditorAssetLibrary.save_loaded_asset(tex)   # streaks keep their mips: they tile small
wall = unreal.load_asset(TEXS + "/T_Room_BackWallClean_A")

path = MATS + "/M_Room_WallRain"
if unreal.EditorAssetLibrary.does_asset_exist(path):
    unreal.EditorAssetLibrary.delete_asset(path)
m = tools.create_asset("M_Room_WallRain", MATS, unreal.Material, unreal.MaterialFactoryNew())
m.set_editor_property("shading_model", unreal.MaterialShadingModel.MSM_UNLIT)
m.set_editor_property("blend_mode", unreal.BlendMode.BLEND_MASKED)
m.set_editor_property("two_sided", True)


def node(cls, x, y):
    return mel.create_material_expression(m, cls, x, y)


def scalar(name, value, x, y):
    s = node(unreal.MaterialExpressionScalarParameter, x, y)
    s.set_editor_property("parameter_name", name)
    s.set_editor_property("default_value", value)
    return s


base = node(unreal.MaterialExpressionTextureSampleParameter2D, -900, -300)
base.set_editor_property("parameter_name", "Tex")
base.set_editor_property("texture", wall)
bright = scalar("Brightness", 1.0, -900, -100)
lit = node(unreal.MaterialExpressionMultiply, -600, -250)
mel.connect_material_expressions(base, "RGB", lit, "A")
mel.connect_material_expressions(bright, "", lit, "B")

uv = node(unreal.MaterialExpressionTextureCoordinate, -1800, 300)
time = node(unreal.MaterialExpressionTime, -1800, 500)
speed = scalar("RainSpeed", 0.35, -1800, 600)


def layer(tile_u, tile_v, speed_scale, x, y):
    """Streaks tiled tile_u x tile_v over the wall, falling at RainSpeed x speed_scale."""
    tiles = node(unreal.MaterialExpressionConstant2Vector, x, y)
    tiles.set_editor_property("r", tile_u)
    tiles.set_editor_property("g", tile_v)
    tiled = node(unreal.MaterialExpressionMultiply, x + 150, y)
    mel.connect_material_expressions(uv, "", tiled, "A")
    mel.connect_material_expressions(tiles, "", tiled, "B")
    fall = node(unreal.MaterialExpressionMultiply, x, y + 120)
    mel.connect_material_expressions(time, "", fall, "A")
    mel.connect_material_expressions(speed, "", fall, "B")
    fall2 = node(unreal.MaterialExpressionMultiply, x + 150, y + 120)
    fall2.set_editor_property("const_b", -tile_v * speed_scale)
    mel.connect_material_expressions(fall, "", fall2, "A")
    offset = node(unreal.MaterialExpressionAppendVector, x + 300, y + 120)
    zero = node(unreal.MaterialExpressionConstant, x + 150, y + 220)
    zero.set_editor_property("r", 0.0)
    mel.connect_material_expressions(zero, "", offset, "A")
    mel.connect_material_expressions(fall2, "", offset, "B")
    moved = node(unreal.MaterialExpressionAdd, x + 450, y)
    mel.connect_material_expressions(tiled, "", moved, "A")
    mel.connect_material_expressions(offset, "", moved, "B")
    sample = node(unreal.MaterialExpressionTextureSample, x + 600, y)
    sample.set_editor_property("texture", streaks)
    sample.set_editor_property("sampler_type", unreal.MaterialSamplerType.SAMPLERTYPE_LINEAR_COLOR)
    mel.connect_material_expressions(moved, "", sample, "UVs")
    return sample


# The wall is 2:1; a 256 x 512 tile, 32 x 8 times, keeps streaks about as tall as the painted ones.
near = layer(32.0, 8.0, 1.0, -1500, 200)
far = layer(48.0, 12.0, 0.6, -1500, 600)
far_dim = node(unreal.MaterialExpressionMultiply, -600, 650)
far_dim.set_editor_property("const_b", 0.55)
mel.connect_material_expressions(far, "A", far_dim, "A")
both = node(unreal.MaterialExpressionAdd, -450, 400)
mel.connect_material_expressions(near, "A", both, "A")
mel.connect_material_expressions(far_dim, "", both, "B")

glass = node(unreal.MaterialExpressionTextureSample, -600, 850)
glass.set_editor_property("texture", mask)
glass.set_editor_property("sampler_type", unreal.MaterialSamplerType.SAMPLERTYPE_LINEAR_COLOR)
mel.connect_material_expressions(uv, "", glass, "UVs")
masked = node(unreal.MaterialExpressionMultiply, -300, 500)
mel.connect_material_expressions(both, "", masked, "A")
mel.connect_material_expressions(glass, "R", masked, "B")
strength = scalar("RainStrength", 0.6, -300, 650)
strong = node(unreal.MaterialExpressionMultiply, -150, 500)
mel.connect_material_expressions(masked, "", strong, "A")
mel.connect_material_expressions(strength, "", strong, "B")
color = node(unreal.MaterialExpressionVectorParameter, -150, 700)
color.set_editor_property("parameter_name", "RainColor")
color.set_editor_property("default_value", unreal.LinearColor(0.75, 1.0, 1.0, 1.0))
tinted = node(unreal.MaterialExpressionMultiply, 0, 550)
mel.connect_material_expressions(strong, "", tinted, "A")
mel.connect_material_expressions(color, "RGB", tinted, "B")
final = node(unreal.MaterialExpressionAdd, 150, -100)
mel.connect_material_expressions(lit, "", final, "A")
mel.connect_material_expressions(tinted, "", final, "B")
mel.connect_material_property(final, "", unreal.MaterialProperty.MP_EMISSIVE_COLOR)
mel.connect_material_property(base, "A", unreal.MaterialProperty.MP_OPACITY_MASK)
mel.recompile_material(m)
unreal.EditorAssetLibrary.save_loaded_asset(m)

mi = unreal.load_asset(MATS + "/MI_Room_BackWallClean_A")
mi.set_editor_property("parent", m)
mel.set_material_instance_texture_parameter_value(mi, "Tex", wall)
mel.update_material_instance(mi)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(mi))
