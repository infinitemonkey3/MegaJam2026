"""In the UEFN editor (play test, 2026-11-14): a thin dark line across the back wall, on and off.
It was the desk card's top edge: its texture wrapped, so the transparent top row filtered against
the desk's dark bottom row. Room cards show each texture once, so they should clamp, not wrap.
Sets Clamp on every Room texture except the ones that tile (rain streaks, floor).
"""
import unreal

FOLDER = "/76e8e788-bf61-4537-8f86-b062e519fb2d/Room/Textures"
TILING = {"T_Room_RainStreaks", "T_Room_Floor_A"}
for path in unreal.EditorAssetLibrary.list_assets(FOLDER, recursive=False):
    tex = unreal.load_asset(path)
    if not isinstance(tex, unreal.Texture2D) or tex.get_name() in TILING:
        continue
    tex.set_editor_property("address_x", unreal.TextureAddress.TA_CLAMP)
    tex.set_editor_property("address_y", unreal.TextureAddress.TA_CLAMP)
    print("clamp", tex.get_name(), unreal.EditorAssetLibrary.save_loaded_asset(tex))
