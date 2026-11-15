"""In the UEFN editor, after mouth_random_timing.py: Nell's mouth from 8 cells (Chip,
2026-11-14). Imports T_Client_Nell_Mouth_Atlas8 (client_parts.py: closed, half, open, ee, oo,
f/v, m, half), sets it as the Mouth texture, and changes M_Room_Breath's random pick from 4 cells
to 8 (frame = floor(hash x 8), atlas u = (frame + u) / 8).
"""
import unreal

G = "/76e8e788-bf61-4537-8f86-b062e519fb2d"
mel = unreal.MaterialEditingLibrary
tools = unreal.AssetToolsHelpers.get_asset_tools()

t = unreal.AssetImportTask()
t.filename = r"C:/Users/Chip/Documents/Unreal Projects/MegaJam2026/art/style-test/final/T_Client_Nell_Mouth_Atlas8.png"
t.destination_path = G + "/Room/Textures"
t.destination_name = "T_Client_Nell_Mouth_Atlas"     # replaces the 4-cell one in place
t.automated = True
t.replace_existing = True
tools.import_asset_tasks([t])
atlas = unreal.load_asset(G + "/Room/Textures/T_Client_Nell_Mouth_Atlas")
atlas.set_editor_property("mip_gen_settings", unreal.TextureMipGenSettings.TMGS_NO_MIPMAPS)
print("atlas", atlas.blueprint_get_size_x(), atlas.blueprint_get_size_y(), unreal.EditorAssetLibrary.save_loaded_asset(atlas))

m = unreal.load_asset(G + "/Room/Materials/M_Room_Breath")
P = m.get_path_name() + ":"
cellu = unreal.find_object(None, P + "MaterialExpressionAdd_1")      # frame + local u
frame = mel.get_inputs_for_material_expression(m, cellu)[0]          # Floor
times = mel.get_inputs_for_material_expression(m, frame)[0]          # x 4
print("frame chain", frame.get_name(), times.get_name(), times.get_editor_property("const_b"))
times.set_editor_property("const_b", 8.0)
changed = 0
for i in range(60):
    e = unreal.find_object(None, P + "MaterialExpressionMultiply_%d" % i)
    if e is None:
        continue
    ins = mel.get_inputs_for_material_expression(m, e)
    if ins and ins[0] == cellu:
        e.set_editor_property("const_b", 0.125)
        changed += 1
print("atlas u scale nodes changed", changed)
mel.recompile_material(m)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(m))
