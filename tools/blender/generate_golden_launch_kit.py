"""Source-backed permanent canopy/banks and modular spectral-harvest props.

Reuses the Golden geometry/export pipeline and central native palette.
Blender --background --python tools/blender/generate_golden_launch_kit.py
"""
import importlib.util
import json
import math
from pathlib import Path
import bpy

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("golden", Path(__file__).with_name("generate_golden_slice.py"))
golden = importlib.util.module_from_spec(spec)
spec.loader.exec_module(golden)

def pine():
    a = golden.Asset("ReservePine")
    a.cyl("Trunk", (0, 0, 3), .45, 6, "BarkWood", 7)
    for tier, (z, radius, height) in enumerate(((2.4, 3.5, 5), (5.0, 2.7, 4.5), (7.4, 1.9, 4.2))):
        verts = [(0, 0, z + height)]
        for i in range(9):
            t = i * 2 * math.pi / 9
            verts.append((radius * math.cos(t), radius * math.sin(t), z + (i % 2) * .45))
        faces = [(0, i + 1, (i + 1) % 9 + 1) for i in range(9)] + [tuple(range(9, 0, -1))]
        a.mesh(f"Canopy{tier}", verts, faces, "ForestDeep" if tier != 1 else "LeafGreen")
    return a

def bank():
    a = golden.Asset("MossBank")
    verts, faces = [], []
    n = 12
    for y in range(n + 1):
        for x in range(n + 1):
            u, v = x / n, y / n
            z = 5.5 * math.sin(math.pi * u) * math.sin(math.pi * v) * (.85 + .15 * math.sin(u * 9 + v * 4))
            verts.append(((u - .5) * 28, (v - .5) * 20, z))
    for y in range(n):
        for x in range(n):
            k = y * (n + 1) + x
            faces.extend(((k, k + 1, k + n + 2), (k, k + n + 2, k + n + 1)))
    a.mesh("Slope", verts, faces, "GrassMeadow")
    return a

def pumpkin():
    a = golden.Asset("HarvestPumpkin")
    verts, faces = [], []
    rings, sides = 7, 16
    for j in range(rings + 1):
        phi = .08 + (math.pi - .16) * j / rings
        for i in range(sides):
            t = i * 2 * math.pi / sides
            r = math.sin(phi) * (1 + .075 * math.cos(t * 8))
            verts.append((math.cos(t) * r, math.sin(t) * r, .85 + .8 * math.cos(phi)))
    for j in range(rings):
        for i in range(sides):
            k, nxt = j * sides + i, j * sides + (i + 1) % sides
            faces.append((k, nxt, nxt + sides, k + sides))
    faces.extend((tuple(range(sides - 1, -1, -1)), tuple(range(rings * sides, (rings + 1) * sides))))
    a.mesh("RibbedBody", verts, faces, "HarvestOrange")
    a.cyl("Stem", (.12, 0, 1.75), .13, .38, "BarkWood", 7)
    for sign in (-1, 1):
        x = sign * .35
        a.mesh(f"Eye{sign}", [(x - .14, -.94, 1.07), (x + .14, -.94, 1.07), (x, -.94, 1.31)], [(0, 1, 2)], "CandleGold")
    a.mesh("Smile", [(-.4, -.92, .74), (-.22, -1, .62), (0, -1.04, .58), (.22, -1, .62), (.4, -.92, .74), (0, -1.03, .72)], [(0, 1, 5), (1, 2, 5), (2, 3, 5), (3, 4, 5)], "CandleGold")
    return a

def lantern():
    a = golden.Asset("HarvestLantern")
    a.cyl("Foot", (0, 0, .12), .6, .24, "DarkMetal", 8)
    a.cyl("Crown", (0, 0, 1.84), .64, .2, "DarkMetal", 8)
    a.cyl("Glow", (0, 0, 1), .29, 1.35, "CandleGold", 8)
    for i in range(4):
        t = math.pi / 4 + math.pi * i / 2
        a.box(f"Rib{i}", (.45 * math.cos(t), .45 * math.sin(t), 1), (.09, .09, 1.65), "SecondaryMetal", .015)
    a.torus("Handle", (0, 0, 2.18), .3, .065, "DarkMetal", True)
    return a

def spectral():
    a = golden.Asset("SpectralReliquary")
    a.cyl("Foot", (0, 0, .35), 2.1, .7, "NightPlum", 8)
    a.cyl("Plinth", (0, 0, 1.25), 1.25, 1.3, "DarkMetal", 8)
    a.torus("Ward", (0, 0, 2.75), 1.8, .12, "SecondaryMetal", True)
    a.torus("SpectralSeal", (0, -.02, 2.75), 1.63, .06, "SpectralViolet", True)
    for sign in (-1, 1):
        a.box(f"Pylon{sign}", (sign * 2, 0, 2), (.35, .45, 3.5), "DarkMetal")
        a.leaf(f"MoonFin{sign}", (sign * 1.8, .1, 3.1), (.24, 1.45, .19), "NightPlum", sign * -.8)
    a.sphere("Wisp", (0, -.08, 3.1), (.76, .6, .96), "SpectralViolet", 16)
    a.leaf("WispTail", (0, .2, 2.25), (.4, 1.2, .28), "SpectralViolet", math.pi)
    for sign in (-1, 1):
        a.sphere(f"Eye{sign}", (sign * .24, -.64, 3.28), (.095, .05, .14), "EyeInk", 12)
    return a

def main():
    assets = []
    for build, domain in ((pine, "environment"), (bank, "environment"), (pumpkin, "seasonal/halloween_2026"), (lantern, "seasonal/halloween_2026"), (spectral, "seasonal/halloween_2026")):
        golden.reset()
        a = build()
        data = golden.export_asset(a)
        assert domain in data["blend"] and domain in data["export"], "shared asset routing"
        assets.append(data)
    (ROOT / "assets/exported/golden_launch_geometry.json").write_text(json.dumps({"version": 1, "assets": assets}, separators=(",", ":")), encoding="utf-8")
    golden.reset()
    for asset in assets:
        for g in asset["groups"]:
            c = g["center"]
            vertices = [(v[0] + c[0], -(v[2] + c[2]), v[1] + c[1]) for v in g["vertices"]]
            mesh = bpy.data.meshes.new(g["name"])
            mesh.from_pydata(vertices, [], g["triangles"])
            mesh.update()
            obj = bpy.data.objects.new(g["name"], mesh)
            bpy.context.collection.objects.link(obj)
            mesh.materials.append(bpy.data.materials[g["material"]])
            mesh.normals_split_custom_set([(n[0], -n[2], n[1]) for row in g["normals"] for n in row])
            for p in mesh.polygons: p.use_smooth = True
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / "assets/blender/golden_launch_import.blend"), compress=True)
    bpy.ops.export_scene.fbx(filepath=str(ROOT / "assets/exported/golden_launch_import.fbx"), use_selection=False, object_types={"MESH"}, add_leaf_bones=False, bake_anim=False, axis_forward="-Z", axis_up="Y", apply_unit_scale=True)
    print("GOLDEN_LAUNCH_KIT", json.dumps([{k: a[k] for k in ("key", "triangles", "blend", "export")} for a in assets]))

if __name__ == "__main__": main()
