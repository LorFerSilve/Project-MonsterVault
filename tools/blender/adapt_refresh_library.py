"""Adapt the selected CC0 library to MonsterVault, never the entire asset pack.

Blender --background --python tools/blender/adapt_refresh_library.py -- <library>
The editable sources pack their images; native appearance metadata lives beside
the exports. Geometry retains authored topology/UVs, with a grounded Roblox pivot.
"""
from __future__ import annotations

import hashlib
import json
import math
import re
import shutil
import sys
import tempfile
from pathlib import Path
from urllib.parse import unquote

import bpy
from mathutils import Euler, Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
LIBRARY = Path(sys.argv[sys.argv.index("--") + 1]) if "--" in sys.argv else ROOT / "assets/source/cc0-refresh"
OUT = ROOT / "assets/exported/refresh"
BLENDS = ROOT / "assets/blender/refresh"
SOURCES = ROOT / "assets/source/cc0-refresh"
PALETTE = {
    name: tuple(int(v) / 255 for v in (r, g, b))
    for name, r, g, b in re.findall(
        r"(\w+)\s*=\s*\{\s*material\s*=\s*Enum\.Material\.\w+,\s*color\s*=\s*Color3\.fromRGB\((\d+),\s*(\d+),\s*(\d+)\)",
        (ROOT / "src/shared/config/MaterialPalette.luau").read_text(encoding="utf-8"),
    )
}
# Key, pack model name, dimension axis (Blender), target size in studs.
SELECTION = [
    ("CanopyOak", "CommonTree_5", 2, 19),
    ("CanopyPine", "Pine_5", 2, 23),
    ("ReserveBoulder", "Rock_Medium_1", 0, 10),
    ("ReserveBoulderWide", "Rock_Medium_2", 0, 9),
    ("FernCluster", "Fern_1", 2, 2.2),
    ("MeadowGrass", "Grass_Common_Short", 2, 1.35),
    ("FlowerPatch", "Flower_3_Group", 2, 1.5),
    ("LeafBush", "Bush_Common", 2, 3),
    ("FoundryColumn", "Column_MetalSupport", 2, 17.2),
    ("FoundryWall", "WallAstra_Straight_Flat", 0, 9.6),
    ("FoundryWindow", "WallAstra_Straight_Flat_Window", 0, 9.6),
    ("FoundryVent", "Prop_Vent_Wide", 0, 3.2),
    ("ServiceCrate", "Prop_Crate4", 2, 2.8),
    ("CableHeader", "TopCables_Straight", 0, 9.6),
    ("StationTerminal", "Prop_Computer", 2, 2.6),
]


def group_for(name):
    if "Bark" in name: return "BarkWood"
    if "Leaves" in name: return "LeafGreen"
    if name == "Grass": return "LeafGreen"
    if name == "Flowers": return "CreatureCream"
    if "Rocks" in name: return "MossRock"
    if name == "M_Black": return "PanelPlastic"
    if name == "M_White": return "SecondaryMetal"
    if name == "M_Glass": return "RavineWater"
    if "Cables" in name: return "EnergyGreen"
    if "Padded" in name or "Dark" in name: return "PanelPlastic"
    if "Trim_02" in name: return "SecondaryMetal"
    if "Trim" in name: return "DarkMetal"
    if "Decal" in name: return "CreatureCream"
    raise ValueError(f"Unmapped material: {name}")


def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in list(bpy.data.materials): bpy.data.materials.remove(block)
    for block in list(bpy.data.images):
        if block.name not in {"Render Result", "Viewer Node"}: bpy.data.images.remove(block)


def native_coords(v):
    return [round(v.x, 6), round(v.z, 6), round(-v.y, 6)]


def save_blend(target):
    # OneDrive can briefly lock a previously generated source during sync.
    # Save a complete new file outside that folder, then replace our own output.
    temporary = Path(tempfile.gettempdir()) / f"mv-refresh-{target.name}"
    bpy.ops.wm.save_as_mainfile(filepath=str(temporary), compress=True)
    shutil.copyfile(temporary, target)


def save_original(gltf):
    doc = json.loads(gltf.read_text(encoding="utf-8"))
    dest = SOURCES / gltf.relative_to(LIBRARY)
    dest.parent.mkdir(parents=True, exist_ok=True)
    hashes = {}
    for entry in doc.get("buffers", []) + doc.get("images", []):
        if "uri" not in entry or entry["uri"].startswith("data:"): continue
        source = gltf.parent / unquote(entry["uri"])
        if not source.is_file():
            matches = list((LIBRARY / gltf.relative_to(LIBRARY).parts[0]).rglob(source.name))
            assert matches, f"Missing pack resource: {source}"
            source = matches[0]
        # Some Standard-pack glTF files expect textures beside the model while
        # the supplied ZIP stores them in Textures. Repair only the local copy.
        entry["uri"] = source.name
        target = dest.parent / source.name
        target.parent.mkdir(parents=True, exist_ok=True)
        digest = hashlib.sha256(source.read_bytes()).hexdigest()
        if not target.is_file() or hashlib.sha256(target.read_bytes()).hexdigest() != digest:
            shutil.copy2(source, target)
        hashes[str(target.relative_to(ROOT)).replace("\\", "/")] = digest
    dest.write_text(json.dumps(doc, indent=2), encoding="utf-8", newline="\n")
    hashes[str(dest.relative_to(ROOT)).replace("\\", "/")] = hashlib.sha256(dest.read_bytes()).hexdigest()
    return dest, hashes


def color_image(material, group, source_path, alpha):
    # Retain alpha silhouettes and UV-authored trim detail. Recolor the shared
    # atlas to the central palette, rather than importing mismatched pack colors.
    if source_path is None: return None
    source = bpy.data.images.load(str(source_path), check_existing=False)
    material.node_tree.nodes.clear()
    bsdf = material.node_tree.nodes.new("ShaderNodeBsdfPrincipled")
    output = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    material.node_tree.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
    texture = material.node_tree.nodes.new("ShaderNodeTexImage")
    key = re.sub(r"[^A-Za-z0-9_]+", "_", f"{source.name}_{group}")
    target = OUT / "textures" / f"{key}.png"
    source_copy = source.copy()
    source_copy.name = key
    w, h = source_copy.size
    if max(w, h) > 512:
        ratio = 512 / max(w, h)
        source_copy.scale(max(1, round(w * ratio)), max(1, round(h * ratio)))
    pixels = list(source_copy.pixels[:])
    colors = [(.2126 * pixels[i] + .7152 * pixels[i + 1] + .0722 * pixels[i + 2]) for i in range(0, len(pixels), 4) if pixels[i + 3] > .2]
    mean = sum(colors) / max(1, len(colors))
    rgb = PALETTE[group]
    for i in range(0, len(pixels), 4):
        luminance = .2126 * pixels[i] + .7152 * pixels[i + 1] + .0722 * pixels[i + 2]
        shade = max(.22, min(1.2, luminance / max(.03, mean)))
        pixels[i:i + 3] = [min(1, channel * shade) for channel in rgb]
    source_copy.pixels[:] = pixels
    source_copy.filepath_raw, source_copy.file_format = str(target), "PNG"
    source_copy.save()
    source_copy.pack()
    texture.image = source_copy
    material.node_tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
    if alpha: material.node_tree.links.new(texture.outputs["Alpha"], bsdf.inputs["Alpha"])
    bsdf.inputs["Base Color"].default_value = (*rgb, 1)
    # Atlas is color/alpha only; native Metal provides restrained specular response.
    bsdf.inputs["Metallic"].default_value = .25 if group in {"DarkMetal", "SecondaryMetal"} else 0
    bsdf.inputs["Roughness"].default_value = .6
    for name in ("Normal", "Metallic", "Roughness"):
        for link in list(bsdf.inputs[name].links): material.node_tree.links.remove(link)
    return str(target.relative_to(ROOT)).replace("\\", "/")


def adapt(key, model, axis, target_size):
    clear()
    candidates = list(LIBRARY.rglob(f"{model}.gltf"))
    assert len(candidates) == 1, (model, candidates)
    gltf = candidates[0]
    staged, source_hashes = save_original(gltf)
    doc = json.loads(staged.read_text(encoding="utf-8"))
    bpy.ops.import_scene.gltf(filepath=str(staged))
    objects = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    assert objects, model
    for o in objects:
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.select_all(action="DESELECT")
        o.select_set(True)
        # Meshes become world-aligned, avoiding importer-specific parent scale.
        world = o.matrix_world.copy()
        o.parent = None
        o.data.transform(world)
        o.matrix_world = Matrix.Identity(4)
    # Standard-kit glTF axes differ between wall bays and flat support/vent
    # modules. Normalize the authored geometry once, before stud-scale sizing.
    angles = (math.pi / 2, 0, 0) if key in {"FoundryColumn", "FoundryVent"} else ((0, 0, math.pi / 2) if key in {"FoundryWall", "FoundryWindow", "CableHeader"} else (0, 0, 0))
    rotation = Euler(angles).to_matrix().to_4x4()
    for o in objects: o.data.transform(rotation)
    points = [v.co for o in objects for v in o.data.vertices]
    lo, hi = Vector(tuple(min(p[i] for p in points) for i in range(3))), Vector(tuple(max(p[i] for p in points) for i in range(3)))
    scale = target_size / (hi[axis] - lo[axis])
    offset = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    for o in objects:
        for v in o.data.vertices: v.co = (v.co - offset) * scale
    # Separate by material then join equal groups, keeping clone count small.
    for o in list(objects):
        bpy.ops.object.select_all(action="DESELECT")
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
        if len(o.data.materials) > 1:
            bpy.ops.object.mode_set(mode="EDIT")
            bpy.ops.mesh.select_all(action="SELECT")
            bpy.ops.mesh.separate(type="MATERIAL")
            bpy.ops.object.mode_set(mode="OBJECT")
    objects = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    by_material = {}
    for o in objects:
        used = {p.material_index for p in o.data.polygons}
        assert len(used) == 1, (o.name, used)
        material = o.data.materials[next(iter(used))]
        o.data.materials.clear()
        o.data.materials.append(material)
        for p in o.data.polygons: p.material_index = 0
        by_material.setdefault(material, []).append(o)
    groups = []
    for index, (material, members) in enumerate(by_material.items()):
        bpy.ops.object.select_all(action="DESELECT")
        for o in members: o.select_set(True)
        bpy.context.view_layer.objects.active = members[0]
        if len(members) > 1: bpy.ops.object.join()
        o = bpy.context.object
        original_material = material.name.split(".")[0]
        group = group_for(original_material)
        o.name = f"RF_{key}_{index:02d}_{group}"
        material.name = f"RF_{key}_{index:02d}_{group}"
        description = next(m for m in doc["materials"] if m["name"] == original_material)
        base_texture = description.get("pbrMetallicRoughness", {}).get("baseColorTexture")
        source_image = staged.parent / doc["images"][doc["textures"][base_texture["index"]]["source"]]["uri"] if base_texture else None
        alpha = description.get("alphaMode") in {"MASK", "BLEND"}
        image = color_image(material, group, source_image, alpha)
        o["MaterialGroup"], o["AssetKey"], o["SourceAuthor"] = group, key, "Quaternius"
        mesh = o.data
        mesh.calc_loop_triangles()
        vertices = [native_coords(v.co) for v in mesh.vertices]
        lo = [min(v[i] for v in vertices) for i in range(3)]
        hi = [max(v[i] for v in vertices) for i in range(3)]
        center = [(lo[i] + hi[i]) / 2 for i in range(3)]
        groups.append({"name": o.name, "material": group, "sourceMaterial": original_material,
                       "center": center, "size": [max(.001, hi[i] - lo[i]) for i in range(3)],
                       "triangles": len(mesh.loop_triangles), "texture": image,
                       "doubleSided": "Leaves" in original_material or original_material in {"Grass", "Flowers"},
                       "alpha": alpha,
                       "glass": original_material == "M_Glass"})
    # Keep only the authored mesh source; imported empties add no runtime value.
    for o in list(bpy.context.scene.objects):
        if o.type != "MESH": bpy.data.objects.remove(o, do_unlink=True)
    bpy.context.scene.unit_settings.system = "NONE"
    bpy.context.scene.unit_settings.scale_length = 1
    bpy.data.orphans_purge(do_recursive=True)
    save_blend(BLENDS / f"{key}.blend")
    bpy.ops.export_scene.gltf(filepath=str(OUT / f"{key}.glb"), export_format="GLB", export_extras=True, export_yup=True)
    geo_hash = hashlib.sha256(json.dumps(groups, sort_keys=True).encode()).hexdigest()
    return {"key": key, "model": model, "author": "Quaternius", "license": "CC0-1.0", "geometrySha256": geo_hash,
            "triangles": sum(g["triangles"] for g in groups), "groups": groups,
            "blend": str((BLENDS / f"{key}.blend").relative_to(ROOT)).replace("\\", "/"),
            "export": str((OUT / f"{key}.glb").relative_to(ROOT)).replace("\\", "/"),
            "sourceHashes": source_hashes}


def main():
    bpy.context.preferences.filepaths.save_version = 0
    for folder in (OUT / "textures", BLENDS, SOURCES): folder.mkdir(parents=True, exist_ok=True)
    assets = [adapt(*entry) for entry in SELECTION]
    clear()
    for a in assets:
        with bpy.data.libraries.load(str(ROOT / a["blend"])) as (source, target):
            target.objects = source.objects
        for o in target.objects:
            if o: bpy.context.collection.objects.link(o)
    save_blend(BLENDS / "refresh_studio_import.blend")
    bpy.ops.export_scene.fbx(filepath=str(OUT / "refresh_studio_import.fbx"), object_types={"MESH"}, add_leaf_bones=False,
                             bake_anim=False, axis_forward="-Z", axis_up="Y", apply_unit_scale=True, path_mode="STRIP")
    licenses = {}
    for pack in ("Quaternius-Nature", "Quaternius-SciFi"):
        original = next((LIBRARY / pack).rglob("License_Standard.txt"))
        target = SOURCES / pack / "License_Standard.txt"
        target.parent.mkdir(parents=True, exist_ok=True)
        if original.resolve() != target.resolve():
            shutil.copy2(original, target)
        licenses[pack] = str(target.relative_to(ROOT)).replace("\\", "/")
    manifest = {"version": 1, "assets": assets, "licenses": licenses}
    (OUT / "refresh_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print("REFRESH_ASSETS", json.dumps([{"key": a["key"], "triangles": a["triangles"], "size": [g["size"] for g in a["groups"]]} for a in assets]))


if __name__ == "__main__": main()
