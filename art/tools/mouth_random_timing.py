"""In the UEFN editor, after add_mouth_to_breath.py: irregular mouth timing (Chip, 2026-11-14:
"more shapes and timings"). Replaces the fixed closed-half-open-half cycle with a shape picked
at random each tick, and ticks that drift faster and slower:

  tick  = floor(Time x MouthFps + 0.6 sin(Time x 1.7) + 0.4 sin(Time x 3.1))
  frame = floor(frac(sin(tick x 12.9898) x 43758.5453) x 4)

The atlas has closed, half, open, half, so a random pick is half-open half the time.
"""
import unreal

mel = unreal.MaterialEditingLibrary
m = unreal.load_asset("/76e8e788-bf61-4537-8f86-b062e519fb2d/Room/Materials/M_Room_Breath")
P = m.get_path_name() + ":"

floor_old = unreal.find_object(None, P + "MaterialExpressionFloor_0")
four = mel.get_inputs_for_material_expression(m, floor_old)[0]
frac_old = mel.get_inputs_for_material_expression(m, four)[0]
quarter = mel.get_inputs_for_material_expression(m, frac_old)[0]
cyc = mel.get_inputs_for_material_expression(m, quarter)[0]          # Time x MouthFps
time = mel.get_inputs_for_material_expression(m, cyc)[0]
cellu = unreal.find_object(None, P + "MaterialExpressionAdd_1")      # frame + local u
print("chain", floor_old.get_name(), four.get_name(), frac_old.get_name(), quarter.get_name(), cyc.get_name(), time.get_name(), cellu.get_name())


def node(cls, x, y):
    return mel.create_material_expression(m, cls, x, y)


def wobble(rate, amount, x, y):
    k = node(unreal.MaterialExpressionMultiply, x, y)
    k.set_editor_property("const_b", rate)
    mel.connect_material_expressions(time, "", k, "A")
    s = node(unreal.MaterialExpressionSine, x + 150, y)
    s.set_editor_property("period", 6.283185)
    mel.connect_material_expressions(k, "", s, "")
    a = node(unreal.MaterialExpressionMultiply, x + 300, y)
    a.set_editor_property("const_b", amount)
    mel.connect_material_expressions(s, "", a, "A")
    return a


w1 = wobble(1.7, 0.6, -1500, 1350)
w2 = wobble(3.1, 0.4, -1500, 1450)
sum1 = node(unreal.MaterialExpressionAdd, -1050, 1300)
mel.connect_material_expressions(cyc, "", sum1, "A")
mel.connect_material_expressions(w1, "", sum1, "B")
sum2 = node(unreal.MaterialExpressionAdd, -900, 1300)
mel.connect_material_expressions(sum1, "", sum2, "A")
mel.connect_material_expressions(w2, "", sum2, "B")
tick = node(unreal.MaterialExpressionFloor, -750, 1300)
mel.connect_material_expressions(sum2, "", tick, "")
h1 = node(unreal.MaterialExpressionMultiply, -600, 1300)
h1.set_editor_property("const_b", 12.9898)
mel.connect_material_expressions(tick, "", h1, "A")
hs = node(unreal.MaterialExpressionSine, -450, 1300)
hs.set_editor_property("period", 6.283185)
mel.connect_material_expressions(h1, "", hs, "")
h2 = node(unreal.MaterialExpressionMultiply, -300, 1300)
h2.set_editor_property("const_b", 43758.5453)
mel.connect_material_expressions(hs, "", h2, "A")
hf = node(unreal.MaterialExpressionFrac, -150, 1300)
mel.connect_material_expressions(h2, "", hf, "")
h4 = node(unreal.MaterialExpressionMultiply, 0, 1300)
h4.set_editor_property("const_b", 4.0)
mel.connect_material_expressions(hf, "", h4, "A")
frame = node(unreal.MaterialExpressionFloor, 150, 1300)
mel.connect_material_expressions(h4, "", frame, "")
mel.connect_material_expressions(frame, "", cellu, "A")

for old in (floor_old, four, frac_old, quarter):
    mel.delete_material_expression(m, old)
mel.recompile_material(m)
print("saved", unreal.EditorAssetLibrary.save_loaded_asset(m))
