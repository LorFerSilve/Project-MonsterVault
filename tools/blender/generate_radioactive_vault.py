"""Reclaimed Energy facility: one hero shell and two small environmental stories.

Blender CLI fallback for the unavailable MCP connector. Editable sources and
neutral material groups use the existing Golden exporter and central palette.
One FBX import contains the three assets; native static proxies own collision.
"""
from __future__ import annotations

import importlib.util
import json
import math
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("golden", Path(__file__).with_name("generate_golden_slice.py"))
golden = importlib.util.module_from_spec(spec)
spec.loader.exec_module(golden)


def xyz(x, height, depth):
    return (x, -depth, height)


def box(a, name, center, size, mat="DarkMetal", bevel=.08):
    # Subpixel vent/channels do not need dozens of bevel triangles each.
    return a.box(name, xyz(*center), (size[0], size[2], size[1]), mat,
                 bevel if min(size) >= .3 else 0)


def slab(a, name, polygon, front, back, mat):
    """Extrude a visible architectural profile in the x/height plane."""
    area = sum(polygon[i][0]*polygon[(i+1)%len(polygon)][1] - polygon[(i+1)%len(polygon)][0]*polygon[i][1] for i in range(len(polygon)))
    if area < 0:
        polygon = list(reversed(polygon))
    vertices = [xyz(x, y, z) for z in (front, back) for x, y in polygon]
    n = len(polygon)
    faces = [tuple(reversed(range(n))), tuple(range(n, 2*n))]
    faces += [(i, (i+1) % n, (i+1) % n+n, i+n) for i in range(n)]
    return a.mesh(name, vertices, faces, mat)


def pipe(a, name, start, end, radius=.18, mat="SecondaryMetal"):
    from mathutils import Vector
    p, q = Vector(xyz(*start)), Vector(xyz(*end))
    obj = a.cyl(name, (p+q)/2, radius, (q-p).length, mat, 10)
    obj.rotation_euler = (q-p).to_track_quat("Z", "Y").to_euler()
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    obj.select_set(False)
    return obj


def shell():
    a = golden.Asset("ContainmentShell")
    # A twenty-stud open portal: no raised threshold or mesh collision hull.
    outer = [(-14, 0), (-14, 13), (-8.8, 22), (8.8, 22), (14, 13), (14, 0)]
    inner = [(-10, 0), (-10, 11.5), (-6.2, 17.5), (6.2, 17.5), (10, 11.5), (10, 0)]
    for i in range(5):
        slab(a, f"PortalArmor{i}", [outer[i], outer[i+1], inner[i+1], inner[i]], -36, -33.5, "DarkMetal")
    for side in (-1, 1):
        box(a, f"PortalFoot{side}", (side*12, .7, -35), (5, 1.4, 4), "SecondaryMetal")
        box(a, f"PortalEnergy{side}", (side*10.9, 6.8, -36.04), (.16, 10.4, .1), "EnergyGreen", .01)
        # Angled buttresses and inset armor break up both formerly blank walls.
        for i, z in enumerate((-24, -6, 12, 30)):
            polygon = [(side*38, 0), (side*43, 0), (side*42, 2), (side*39.5, 19), (side*38, 22)]
            slab(a, f"Buttress{side}_{i}", polygon, z-1.4, z+1.4, "DarkMetal")
            box(a, f"Knee{side}_{i}", (side*40.5, 1, z), (5, 2, 4.8), "SecondaryMetal")
            box(a, f"PowerInset{side}_{i}", (side*39.75, 11, z-1.47), (.18, 7, .12), "EnergyGreen", .01)
        for i in range(3):
            z = -15 + i*18
            box(a, f"ArmorPanel{side}_{i}", (side*38.8, 9, z), (1.3, 12, 14.5), "WeatheredMetal", .16)
            box(a, f"ArmorInset{side}_{i}", (side*39.49, 9, z), (.14, 7.8, 10.8), "PanelPlastic", .03)
            box(a, f"SideConduit{side}_{i}", (side*39.62, 5.6, z), (.1, .13, 10.2), "EnergyGreen", .01)
            for j in range(4):
                box(a, f"Vent{side}_{i}_{j}", (side*39.68, 11+j*.55, z+3.2), (.15, .15, 3.4), "SecondaryMetal", .02)
    # Front wings frame the gate; the rear is equally authored.
    for side in (-1, 1):
        box(a, f"FrontWing{side}", (side*26, 10, -34.6), (23.8, 20, 1.2), "WeatheredMetal", .18)
        box(a, f"FrontPanel{side}", (side*26, 10, -35.3), (18, 11, .24), "PanelPlastic")
        box(a, f"FrontEnergy{side}", (side*26, 4, -35.46), (17, .14, .12), "EnergyGreen", .01)
    for i, x in enumerate((-28, -14, 0, 14, 28)):
        box(a, f"RearArmor{i}", (x, 10, 34.8), (12, 19, 1.2), "WeatheredMetal", .16)
        box(a, f"RearRib{i}", (x-6.8, 11.2, 35.1), (1, 22.4, 1.8), "DarkMetal")
        box(a, f"RearPower{i}", (x, 6, 35.45), (9.5, .14, .12), "EnergyGreen", .01)
        for j in range(4):
            box(a, f"RearVent{i}_{j}", (x, 14+j*.5, 35.5), (5.6, .17, .16), "SecondaryMetal", .02)
    # A shielded roof reactor gives the building a landmark silhouette.
    a.cyl("ReactorFoot", xyz(0, 23.3, 12), 9.2, 1.4, "DarkMetal", 8)
    a.cyl("ReactorShoulder", xyz(0, 24.4, 12), 7.7, 1.1, "SecondaryMetal", 8)
    a.cyl("ReactorCore", xyz(0, 26, 12), 5.1, 2.3, "PanelPlastic", 12)
    a.torus("ContainedEnergy", xyz(0, 26.4, 12), 5.3, .18, "EnergyGreen")
    a.cyl("ReactorCap", xyz(0, 28.3, 12), 6.2, 1.6, "DarkMetal", 8)
    a.cyl("Crown", xyz(0, 29.4, 12), 3.7, .65, "SecondaryMetal", 8)
    for i in range(8):
        t = i*math.tau/8
        x, z = math.cos(t)*6.5, 12+math.sin(t)*6.5
        obj = box(a, f"ReactorShield{i}", (x, 26.1, z), (1.2, 4.2, 2.9), "DarkMetal")
        obj.rotation_euler.z = -t
    for side in (-1, 1):
        pipe(a, f"RoofFeed{side}", (side*7, 23.4, 12), (side*30, 23.4, 12), .24)
        pipe(a, f"RoofFeedDown{side}", (side*30, 23.4, 12), (side*30, 22.6, 30), .24)
        box(a, f"RoofRail{side}", (side*36, 23, 0), (1.6, 1.2, 62), "DarkMetal")
        box(a, f"RoofPower{side}", (side*35, 23.25, 0), (.14, .14, 52), "EnergyGreen", .01)
    box(a, "ContainmentPlaque", (0, 20, -36.13), (8, 2.3, .16), "PanelPlastic")
    # Geometric warning mark, kept separate from intrinsic creature rarity.
    for i in range(3):
        t = math.tau*i/3 + math.pi/2
        polygon = [(math.cos(t)*.35, 20+math.sin(t)*.35),
                   (math.cos(t-.55)*1.0, 20+math.sin(t-.55)*1.0),
                   (math.cos(t+.55)*1.0, 20+math.sin(t+.55)*1.0)]
        slab(a, f"ContainmentMark{i}", polygon, -36.25, -36.18, "HazardAmber")
    return a


def rover():
    a = golden.Asset("SurveyRover")
    box(a, "Chassis", (0, 1.1, 0), (5.4, .7, 9), "OxideRust")
    box(a, "Body", (0, 1.9, 0), (5.3, 1.3, 8.4), "WeatheredMetal", .16)
    box(a, "Bonnet", (0, 2.7, -2.7), (5, .65, 2.7), "WeatheredMetal", .14)
    # Hollow windshield and open side windows: visibly abandoned, not a toy box.
    box(a, "Roof", (0, 4.6, .4), (5.2, .25, 4.4), "WeatheredMetal")
    for side in (-1, 1):
        for z in (-1.4, 2.3):
            box(a, f"Pillar{side}_{z}", (side*2.25, 3.7, z), (.3, 1.9, .3), "OxideRust")
        box(a, f"DoorPanel{side}", (side*2.65, 2.5, .3), (.2, 1.2, 3.4), "WeatheredMetal")
        box(a, f"RustPatch{side}", (side*2.77, 2.15, .7), (.06, .5, 1.9), "OxideRust", .02)
        for i, z in enumerate((-2.8, 2.8)):
            wheel = a.cyl(f"Tire{side}_{i}", xyz(side*2.8, 1.0, z), 1.05, .72, "EyeInk", 12)
            wheel.rotation_euler.y = math.pi/2
            hub = a.cyl(f"Hub{side}_{i}", xyz(side*3.2, 1.0, z), .43, .1, "OxideRust", 8)
            hub.rotation_euler.y = math.pi/2
    for z in (-4.5, 4.5):
        box(a, f"Bumper{z}", (0, 1.6, z), (5.8, .5, .45), "DarkMetal")
    for x in (-1.8, 1.8):
        box(a, f"Headlight{x}", (x, 2.4, -4.3), (.75, .45, .12), "SecondaryMetal", .02)
    for i in range(5):
        box(a, f"Grille{i}", (-1.0+i*.5, 2, -4.35), (.13, .6, .1), "DarkMetal", .01)
    box(a, "Seat", (0, 2.9, 1.4), (3.8, 1.1, .65), "PanelPlastic")
    box(a, "RetiredSurveyStripe", (0, 2.7, -4.38), (1.8, .13, .08), "HazardAmber", .01)
    return a


def ruins():
    a = golden.Asset("RelayRuins")
    box(a, "Foundation", (0, .25, 0), (15, .5, 12), "StoneLight")
    for side in (-1, 1):
        box(a, f"FrontPier{side}", (side*6, 3.4, -4.8), (2, 6.5, 2), "WeatheredMetal")
        box(a, f"BackPier{side}", (side*6, 4.4, 4.8), (2, 8.5, 2), "WeatheredMetal")
        box(a, f"LowWall{side}", (side*6, 1.5, 0), (1, 2.5, 8), "MossRock")
        box(a, f"RoofRail{side}", (side*6, 8.8, .9), (1.2, .65, 8.5), "OxideRust")
    box(a, "RearHeader", (0, 8.8, 4.8), (13, .7, 1.2), "WeatheredMetal")
    slab(a, "BrokenWall", [(-5, .5),(-5, 6.2),(-2.2, 5.7),(-1, 3.2),(1.4, 2.1),(3,.5)], 4.3, 5.3, "MossRock")
    obj = box(a, "FallenHeader", (1.2, .8, -3), (10, .8, 1.2), "OxideRust")
    obj.rotation_euler.z = .23
    box(a, "ControlPlinth", (-3.7, 1.4, 2), (2.6, 2.4, 1.4), "DarkMetal")
    box(a, "BlankReadout", (-3.7, 2, 1.25), (2.1, 1, .1), "PanelPlastic")
    # One sealed relic, no spill, hazard trigger or interaction authority.
    a.cyl("SealedCell", xyz(4.2, 1.3, 2.2), .8, 2.2, "DarkMetal", 10)
    a.torus("CellSeal", xyz(4.2, 1.8, 2.2), .82, .05, "EnergyGreen")
    a.cyl("CellCap", xyz(4.2, 2.45, 2.2), .85, .2, "SecondaryMetal", 10)
    return a


def main():
    assets = []
    for make in (shell, rover, ruins):
        golden.reset()
        asset = make()
        for obj in asset.objects:
            bpy.context.view_layer.objects.active = obj
            obj.select_set(True)
            bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
            obj.select_set(False)
        assets.append(golden.export_asset(asset))
    data = {"version":1, "axis":"Blender (x,y,z) -> Roblox (x,z,-y)", "assets":assets}
    (ROOT/"assets/exported/radioactive_vault_geometry.json").write_text(json.dumps(data,separators=(",", ":")), encoding="utf-8")
    golden.reset()
    for asset in assets:
        for group in asset["groups"]:
            center = group["center"]
            verts = [(v[0]+center[0], -(v[2]+center[2]), v[1]+center[1]) for v in group["vertices"]]
            mesh = bpy.data.meshes.new(group["name"])
            mesh.from_pydata(verts, [], group["triangles"])
            mesh.update()
            obj = bpy.data.objects.new(group["name"], mesh)
            bpy.context.collection.objects.link(obj)
            obj.data.materials.append(bpy.data.materials[group["material"]])
            obj["MaterialGroup"] = group["material"]
            mesh.normals_split_custom_set([(n[0],-n[2],n[1]) for row in group["normals"] for n in row])
            for poly in mesh.polygons:
                poly.use_smooth = True
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/"assets/blender/radioactive_vault_import.blend"), compress=True)
    bpy.ops.export_scene.fbx(filepath=str(ROOT/"assets/exported/radioactive_vault_import.fbx"),
        object_types={"MESH"}, add_leaf_bones=False, bake_anim=False,
        axis_forward="-Z", axis_up="Y", apply_unit_scale=True)
    print("RADIOACTIVE_KIT", json.dumps([{k:a[k] for k in ("key", "triangles", "geometrySha256")} for a in assets]))


if __name__ == "__main__":
    main()
