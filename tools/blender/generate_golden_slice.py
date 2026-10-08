"""Reproducible Mossline/Foundry kit and three visual standards. Blender 5.2 bpy.

Run Blender --background --python tools/blender/generate_golden_slice.py.
Neutral meshes and Roblox import data share the evaluated Blender geometry.
"""
from __future__ import annotations

import hashlib
import json
import math
import re
from pathlib import Path

import bpy
from mathutils import Vector

bpy.context.preferences.filepaths.save_version = 0

ROOT = Path(__file__).resolve().parents[2]
# The Luau palette owns native appearance; Blender consumes the same values.
_palette_source = (ROOT / "src/shared/config/MaterialPalette.luau").read_text(encoding="utf-8")
PALETTE = {
    name: ((int(r), int(g), int(b)), material)
    for name, material, r, g, b in re.findall(
        r"(\w+)\s*=\s*\{\s*material\s*=\s*Enum\.Material\.(\w+),\s*color\s*=\s*Color3\.fromRGB\((\d+),\s*(\d+),\s*(\d+)\)",
        _palette_source,
    )
}
assert len(PALETTE) >= 16, "central palette could not be read"



def reset():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for action in list(bpy.data.actions):
        bpy.data.actions.remove(action)
    for material in list(bpy.data.materials):
        bpy.data.materials.remove(material)
    for name, (rgb, native) in PALETTE.items():
        material = bpy.data.materials.new(name)
        rgba = tuple(v / 255 for v in rgb) + (1,)
        material.diffuse_color = rgba
        shader = material.node_tree.nodes.get("Principled BSDF")
        shader.inputs["Base Color"].default_value = rgba
        shader.inputs["Roughness"].default_value = .6 if native != "Metal" else .32
        shader.inputs["Metallic"].default_value = .55 if native == "Metal" else 0
        if native == "Neon":
            shader.inputs["Emission Color"].default_value = rgba
            shader.inputs["Emission Strength"].default_value = 1.25


class Asset:
    def __init__(self, name):
        self.name = name
        self.objects = []

    def finish(self, obj, name, mat, bevel=0):
        obj.name = f"GS_{self.name}_{name}_{mat}"
        obj.data.materials.clear()
        obj.data.materials.append(bpy.data.materials[mat])
        obj["MaterialGroup"] = mat
        obj["AssetKey"] = self.name
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        if bevel:
            modifier = obj.modifiers.new("ProductionChamfer", "BEVEL")
            modifier.width = min(bevel, min(obj.dimensions) * .18)
            modifier.segments = 2
            bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)
        self.objects.append(obj)
        return obj

    def box(self, name, loc, scale, mat="DarkMetal", bevel=.06):
        bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
        obj = bpy.context.object
        obj.dimensions = scale
        return self.finish(obj, name, mat, bevel)

    def sphere(self, name, loc, scale, mat, segments=20):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=12, radius=1, location=loc)
        obj = bpy.context.object
        obj.scale = scale
        for p in obj.data.polygons:
            p.use_smooth = True
        return self.finish(obj, name, mat)

    def cyl(self, name, loc, radius, depth, mat, sides=12):
        bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=depth, location=loc)
        return self.finish(bpy.context.object, name, mat, .04)

    def torus(self, name, loc, radius, minor, mat, vertical=False):
        bpy.ops.mesh.primitive_torus_add(major_segments=24, minor_segments=6,
                                       major_radius=radius, minor_radius=minor, location=loc)
        obj = bpy.context.object
        if vertical:
            obj.rotation_euler.x = math.pi / 2
        for p in obj.data.polygons:
            p.use_smooth = True
        return self.finish(obj, name, mat)

    def mesh(self, name, vertices, faces, mat):
        mesh = bpy.data.meshes.new(name)
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(name, mesh)
        bpy.context.collection.objects.link(obj)
        return self.finish(obj, name, mat)

    def leaf(self, name, loc, size, mat, angle=0):
        # Closed curved diamond: useful creature crest, foliage and fins.
        w, length, thick = size
        verts = [(0, 0, 0), (-w, length*.43, thick), (0, length, thick*.3),
                 (w, length*.43, thick), (0, length*.43, thick*2), (0, length*.43, -thick)]
        c, s = math.cos(angle), math.sin(angle)
        verts = [(loc[0]+x*c-y*s, loc[1]+x*s+y*c, loc[2]+z) for x,y,z in verts]
        return self.mesh(name, verts, [(0,1,4),(1,2,4),(2,3,4),(3,0,4),
                                     (0,5,1),(1,5,2),(2,5,3),(3,5,0)], mat)


def face(a, z, y, eyes=.6, scale=.3):
    for sign in (-1, 1):
        x = eyes * sign
        a.sphere(f"Eye{sign}", (x,y,z), (scale,.14,scale*1.22), "EyeInk",16)
        a.sphere(f"Glint{sign}", (x-.065,y-.135,z+.11), (.075,.035,.09), "EyeLight",12)
    a.sphere("Muzzle", (0,y+.055,z-.5), (.37,.16,.21), "CreatureCream",16)
    a.sphere("Nose", (0,y-.11,z-.43), (.1,.065,.06), "EyeInk",12)


def creatures():
    a = Asset("Mossbud")
    a.sphere("Body", (0,0,1.57), (1.28,.95,1.15), "CreatureMoss")
    a.sphere("Belly", (0,-.78,1.2), (.8,.24,.69), "CreatureCream")
    face(a,1.95,-.86)
    for sign in (-1,1):
        a.sphere(f"Foot{sign}", (sign*.78,-.28,.29), (.48,.65,.29), "LeafGreen",16)
        a.sphere(f"Arm{sign}", (sign*1.14,-.04,1.2), (.28,.35,.59), "CreatureMoss",16)
        a.leaf(f"Crest{sign}", (sign*.15,.1,2.52), (.33,1.0,.15), "LeafGreen",sign*.65)
    a.sphere("Tail", (0,.98,1.06), (.37,.68,.33), "LeafGreen",16)
    yield a
    a = Asset("Prismfin")
    a.sphere("Body", (0,0,1.6), (1.15,1.55,.59), "RareBlue")
    a.sphere("Belly", (0,-.2,1.28), (.83,1.04,.2), "CreatureCream")
    face(a,1.69,-1.39,.52,.24)
    for sign in (-1,1):
        a.mesh(f"Wing{sign}", [(sign*.8,0,1.6),(sign*3.1,.55,1.92),(sign*1.8,1.3,1.4),
                               (sign*.8,1.0,1.35),(sign*1.55,.48,1.67)],
               [tuple(reversed(f)) if sign < 0 else f for f in
                [(0,1,4),(1,2,4),(2,3,4),(3,0,4),(0,3,2,1)]],"RareBlue")
        a.leaf(f"FinTip{sign}", (sign*2.1,.45,1.79), (.17,.75,.1), "RareGlow",sign*-.8)
    a.leaf("Tail",(0,.98,1.5),(.28,2.1,.2),"RareBlue")
    a.leaf("Crown",(0,.18,2.12),(.15,.8,.36),"RareGlow")
    yield a
    a = Asset("Helion")
    a.sphere("Core",(0,0,2.35),(1.27,1.1,1.32),"LegendaryGold",24)
    a.sphere("Face",(0,-.9,2.44),(.99,.3,.95),"CreatureCream")
    face(a,2.7,-1.13,.56,.27)
    a.torus("Halo",(0,.5,2.4),2.1,.12,"LegendaryGold",True)
    a.torus("HaloEnergy",(0,.5,2.4),1.92,.045,"LegendaryGlow",True)
    for i in range(7):
        theta=2*math.pi*i/7
        a.sphere(f"HaloNode{i}",(2.1*math.sin(theta),.5,2.4+2.1*math.cos(theta)),
                 (.11,.1,.11),"LegendaryGlow",12)
    for sign in (-1,1):
        a.leaf(f"SolarFin{sign}",(sign*.8,.08,2.1),(.38,1.75,.28),"DarkMetal",sign*-1.1)
        a.leaf(f"SolarVein{sign}",(sign*.85,-.025,2.26),(.11,1.4,.09),"LegendaryGlow",sign*-1.1)
    a.cyl("Socket",(0,0,.35),.66,.25,"DarkMetal")
    a.torus("HoverSeal",(0,0,.54),.73,.07,"LegendaryGlow")
    yield a


def kit():
    a=Asset("Basalt")
    # Irregular tapered formation, deterministic broad facets and moss top.
    verts=[]
    for z,rx,ry,shift in [(0,2.9,2.2,0),(.8,3.0,2.3,.1),(3.6,2.2,1.8,-.4),(5.2,1.4,1.1,-.6)]:
        for i in range(7):
            t=2*math.pi*i/7
            verts.append((math.cos(t)*rx+shift, math.sin(t)*ry,z+.18*math.sin(i*2)))
    faces=[]
    for ring in range(3):
        for i in range(7):
            j=(i+1)%7
            faces.append((ring*7+i,ring*7+j,(ring+1)*7+j,(ring+1)*7+i))
    faces.extend([tuple(reversed(range(7))),tuple(range(21,28))])
    a.mesh("Formation",verts,faces,"MossRock")
    a.sphere("MossCap",(-.55,0,4.95),(1.5,1.15,.3),"LeafGreen",12)
    yield a
    a=Asset("Fern")
    for i in range(5):
        a.leaf(f"Leaf{i}",(0,0,.13),(.55,2.1,.23),"LeafGreen",i*2*math.pi/5)
    a.sphere("Bud",(0,0,.25),(.32,.32,.29),"StoneLight",12)
    yield a
    a=Asset("Relay")
    a.cyl("Foot",(0,0,.25),2.0,.5,"DarkMetal")
    a.cyl("Shoulder",(0,0,1.1),1.1,1.5,"SecondaryMetal")
    a.cyl("Column",(0,0,6),.46,9,"DarkMetal")
    for z in (2.1,3.4,4.7):
        a.torus(f"RelayBand{z}",(0,0,z),.51,.07,"EnergyGreen")
    for i in range(3):
        t=2*math.pi*i/3
        obj=a.box(f"Prong{i}",(math.cos(t)*1.25,math.sin(t)*1.25,10.6),(.55,.65,4.5),"SecondaryMetal")
        a.box(f"Signal{i}",(math.cos(t)*1.26,math.sin(t)*1.26,11.3),(.24,.3,1.8),"EnergyGreen")
    yield a
    a=Asset("Plinth")
    a.cyl("Base",(0,0,.24),2.6,.48,"DarkMetal",8)
    a.cyl("Step",(0,0,.58),2.26,.22,"SecondaryMetal",8)
    a.cyl("Surface",(0,0,.75),2.1,.13,"PanelPlastic",8)
    a.torus("Rim",(0,0,.79),2.0,.045,"EnergyGreen")
    for i in range(4):
        t=2*math.pi*i/4
        a.box(f"Socket{i}",(math.cos(t)*2.25,math.sin(t)*2.25,.36),(.25,.32,.18),"EnergyGreen")
    yield a
    a=Asset("Gate")
    for sign in (-1,1):
        a.box(f"Pillar{sign}",(sign*8,0,7.0),(2.0,2.4,14),"DarkMetal",.15)
        a.box(f"Inset{sign}",(sign*8,-1.25,7),(1.35,.2,9.5),"PanelPlastic")
        a.box(f"Light{sign}",(sign*7.8,-1.39,7),(.12,.065,7.0),"EnergyGreen",.01)
        a.box(f"Foot{sign}",(sign*8,0,.65),(2.7,3.0,1.3),"SecondaryMetal",.15)
        for z in (3,10):
            a.box(f"Brace{sign}{z}",(sign*8,-1.45,z),(2.05,.23,.48),"SecondaryMetal")
    a.box("Header",(0,0,14.2),(18,2.4,1.7),"DarkMetal",.18)
    a.box("HeaderInset",(0,-1.27,14.2),(13,.1,.6),"PanelPlastic")
    a.box("HeaderLine",(0,-1.34,14.24),(10,.035,.08),"EnergyGreen",.005)
    yield a
    a=Asset("Accumulator")
    a.cyl("Base",(0,0,.24),1.8,.48,"DarkMetal",12)
    a.cyl("Casing",(0,0,1.45),1.2,2.0,"SecondaryMetal",12)
    a.cyl("Energy",(0,0,2.75),.8,.54,"EnergyGreen",12)
    a.cyl("Top",(0,0,3.14),1.3,.18,"DarkMetal",12)
    for i in range(6):
        t=i*math.pi/3
        a.box(f"Rib{i}",(math.cos(t)*1.18,math.sin(t)*1.18,1.4),(.16,.2,2.0),"DarkMetal")
    yield a


def rig_idle(asset):
    bpy.ops.object.armature_add()
    rig=bpy.context.object
    rig.name=f"GS_{asset.name}_Rig"
    rig.data.bones[0].name="Root"
    for obj in asset.objects:
        obj.parent = rig
        group=obj.vertex_groups.new(name="Root")
        group.add(list(range(len(obj.data.vertices))),1,'REPLACE')
        modifier=obj.modifiers.new("IdleRig","ARMATURE")
        modifier.object=rig
    root=rig.pose.bones["Root"]
    for frame,z in [(1,0),(31,.12),(61,0)]:
        root.location.z=z
        root.keyframe_insert(data_path="location",frame=frame)
    rig.animation_data.action.name=f"GS_{asset.name}_GentleIdle"
    bpy.context.scene.frame_set(1)
    return rig


def convert(v):
    return [round(v[0],6),round(v[2],6),round(-v[1],6)]


def export_asset(asset):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in asset.objects:
        obj.select_set(True)
    rig=rig_idle(asset) if asset.name in {"Mossbud","Prismfin","Helion"} else None
    root = rig
    if root is None:
        root = bpy.data.objects.new(f"GS_{asset.name}_Root", None)
        bpy.context.collection.objects.link(root)
        for obj in asset.objects:
            obj.parent = root
    root["asset_units"], root["semantic_pivot"], root["AssetKey"] = "stud", "floor_center", asset.name
    # Adding an armature deselects the meshes. Re-select after constructing the root.
    root.select_set(True)
    for obj in asset.objects:
        obj.select_set(True)
    domain = ("creatures" if asset.name in {"Mossbud", "Prismfin", "Helion"}
              else "vault" if asset.name in {"Plinth", "Accumulator"}
              else "seasonal/halloween_2026" if asset.name in {"HarvestPumpkin", "HarvestLantern", "SpectralReliquary"}
              else "environment")
    blend_dir, export_dir = ROOT/"assets/blender"/domain, ROOT/"assets/exported"/domain
    blend_dir.mkdir(parents=True, exist_ok=True)
    export_dir.mkdir(parents=True, exist_ok=True)
    blend=blend_dir/f"golden_{asset.name.lower()}.blend"
    # Individual editable scene per asset. Other assets are generated in fresh scenes.
    bpy.ops.wm.save_as_mainfile(filepath=str(blend),compress=True)
    export=export_dir/f"golden_{asset.name.lower()}.glb"
    bpy.ops.export_scene.gltf(filepath=str(export),export_format='GLB',use_selection=True,
                             export_extras=True,export_animations=True)
    groups={}
    deps=bpy.context.evaluated_depsgraph_get()
    for obj in asset.objects:
        mat=obj["MaterialGroup"]
        group=groups.setdefault(mat,{"material":mat,"vertices":[],"triangles":[],"normals":[]})
        evaluated=obj.evaluated_get(deps)
        mesh=evaluated.to_mesh()
        mesh.calc_loop_triangles()
        offset=len(group["vertices"])
        group["vertices"].extend(convert(obj.matrix_world@v.co) for v in mesh.vertices)
        for tri in mesh.loop_triangles:
            group["triangles"].append([offset+i for i in tri.vertices])
            group["normals"].append([convert(obj.matrix_world.to_3x3()@mesh.corner_normals[i].vector) for i in tri.loops])
        evaluated.to_mesh_clear()
    for g in groups.values():
        lo=[min(v[i] for v in g["vertices"]) for i in range(3)]
        hi=[max(v[i] for v in g["vertices"]) for i in range(3)]
        center=[(a+b)/2 for a,b in zip(lo,hi)]
        g["center"],g["size"]=center,[max(.01,b-a) for a,b in zip(lo,hi)]
        g["vertices"]=[[round(v[i]-center[i],6) for i in range(3)] for v in g["vertices"]]
        g["name"]=f"GS_{asset.name}_{g['material']}"
    data={"key":asset.name,"runtime":asset.name != "Prismfin","groups":list(groups.values()),"blend":blend.relative_to(ROOT).as_posix(),
          "export":export.relative_to(ROOT).as_posix(),"triangles":sum(len(g['triangles']) for g in groups.values()),
          "rig":rig.name if rig else None,"idleAction":rig.animation_data.action.name if rig else None}
    data["geometrySha256"]=hashlib.sha256(json.dumps(data['groups'],sort_keys=True).encode()).hexdigest()
    return data


def main():
    (ROOT/"assets/blender").mkdir(exist_ok=True)
    (ROOT/"assets/exported").mkdir(exist_ok=True)
    assets=[]
    # Reset before each builder, so individual .blend files remain focused/editable.
    for kind, index, total in [(creatures,i,3) for i in range(3)]+[(kit,i,6) for i in range(6)]:
        reset()
        for j,asset in enumerate(kind()):
            if j==index:
                # Generator constructed preceding assets; remove those unrelated objects.
                keep=set(asset.objects)
                for obj in list(bpy.context.scene.objects):
                    if obj not in keep:
                        bpy.data.objects.remove(obj,do_unlink=True)
                assets.append(export_asset(asset))
                break
    manifest={"version":1,"axis":"Blender (x,y,z) -> Roblox (x,z,-y)","palette":PALETTE,"assets":assets}
    target=ROOT/"assets/exported/golden_geometry.json"
    target.write_text(json.dumps(manifest,separators=(',',':')),encoding='utf-8')
    # One ordinary Studio import: preserve stable group names for the native
    # palette pass, rather than uploading scores of tiny component objects.
    reset()
    for asset in assets:
        for group in asset['groups']:
            center=group['center']
            vertices=[(v[0]+center[0], -(v[2]+center[2]), v[1]+center[1]) for v in group['vertices']]
            mesh=bpy.data.meshes.new(group['name'])
            mesh.from_pydata(vertices,[],group['triangles'])
            mesh.update()
            obj=bpy.data.objects.new(group['name'],mesh)
            bpy.context.collection.objects.link(obj)
            obj.data.materials.append(bpy.data.materials[group['material']])
            obj['MaterialGroup']=group['material']
            normals=[(n[0],-n[2],n[1]) for row in group['normals'] for n in row]
            mesh.normals_split_custom_set(normals)
            for poly in mesh.polygons:
                poly.use_smooth=True
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'assets/blender/golden_studio_import.blend'),compress=True)
    bpy.ops.export_scene.fbx(filepath=str(ROOT/'assets/exported/golden_studio_import.fbx'),
        use_selection=False, object_types={'MESH'}, add_leaf_bones=False, bake_anim=False,
        axis_forward='-Z', axis_up='Y', apply_unit_scale=True)
    print('GOLDEN_GEOMETRY',json.dumps([{k:a[k] for k in ('key','triangles','geometrySha256')} for a in assets]))


if __name__=='__main__':
    main()
