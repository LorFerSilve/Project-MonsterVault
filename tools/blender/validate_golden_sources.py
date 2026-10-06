"""Audit Golden sources/exports; --repair-exports re-exports the saved exact meshes.

Blender --background --python tools/blender/validate_golden_sources.py -- --repair-exports
Only source paths declared in the selected Golden manifests can be written.
Optional: --manifest radioactive_vault_geometry.json --report radioactive_source_audit.json
"""
import json
from pathlib import Path
import struct
import sys
import bpy

ROOT = Path(__file__).resolve().parents[2]
REPAIR = "--repair-exports" in sys.argv
bpy.context.preferences.filepaths.save_version = 0


def owned_path(relative):
    path = (ROOT / relative).resolve()
    assert path.is_relative_to((ROOT / "assets").resolve()), "outside declared asset directory"
    return path


def main():
    assets = []
    names = ("golden_geometry.json", "golden_launch_geometry.json")
    if "--manifest" in sys.argv:
        name = sys.argv[sys.argv.index("--manifest") + 1]
        assert Path(name).name == name, "manifest must be in assets/exported"
        names = (name,)
    for name in names:
        assets.extend(json.loads((ROOT / "assets/exported" / name).read_text())["assets"])
    report = []
    for data in assets:
        source, export = owned_path(data["blend"]), owned_path(data["export"])
        bpy.ops.wm.open_mainfile(filepath=str(source))
        bpy.context.scene.frame_set(1)
        meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
        assert meshes, f"{data['key']}: empty source"
        known = {group["material"] for group in data["groups"]}
        triangles = 0
        for obj in meshes:
            assert obj.get("AssetKey") == data["key"], "unexpected source asset"
            assert obj.get("MaterialGroup") in known, "unknown material group"
            assert all(abs(value - 1) < 1e-5 for value in obj.scale), "unapplied source scale"
            assert all(abs(value) < 1e-5 for value in obj.rotation_euler), "unapplied source rotation"
            evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
            mesh = evaluated.to_mesh()
            mesh.calc_loop_triangles()
            assert all(tri.area > 1e-10 for tri in mesh.loop_triangles), "zero-area triangle"
            triangles += len(mesh.loop_triangles)
            evaluated.to_mesh_clear()
        assert triangles == data["triangles"], f"{data['key']}: topology changed"
        rig = next((obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE"), None)
        if REPAIR:
            root = rig or next((obj for obj in bpy.context.scene.objects if obj.type == "EMPTY"), None)
            if root is None:
                root = bpy.data.objects.new(f"GS_{data['key']}_Root", None)
                bpy.context.collection.objects.link(root)
                for obj in meshes:
                    matrix = obj.matrix_world.copy()
                    obj.parent, obj.matrix_world = root, matrix
            root["asset_units"], root["semantic_pivot"], root["AssetKey"] = "stud", "floor_center", data["key"]
            for action in list(bpy.data.actions):
                if action.users == 0:
                    bpy.data.actions.remove(action)
            bpy.ops.object.select_all(action="DESELECT")
            root.select_set(True)
            for obj in meshes:
                obj.select_set(True)
            bpy.ops.wm.save_as_mainfile(filepath=str(source), compress=True)
            bpy.ops.export_scene.gltf(filepath=str(export), export_format="GLB", use_selection=True,
                                     export_extras=True, export_animations=True)
        glb = export.read_bytes()
        assert glb[:4] == b"glTF" and struct.unpack_from("<I", glb, 8)[0] == len(glb), "invalid GLB"
        length = struct.unpack_from("<I", glb, 12)[0]
        doc = json.loads(glb[20:20 + length])
        assert len(doc.get("meshes", [])) == len(meshes), "GLB omitted source meshes"
        exported_triangles = sum(doc["accessors"][primitive["indices"]]["count"] // 3
                                 for mesh in doc["meshes"] for primitive in mesh["primitives"])
        assert exported_triangles == triangles, "GLB topology differs from source"
        animations = len(doc.get("animations", []))
        assert animations == (1 if rig else 0), "unrelated animation exported"
        report.append({"asset": data["key"], "blend": data["blend"], "export": data["export"],
                       "triangles": triangles, "meshObjects": len(meshes), "animations": animations,
                       "glbBytes": len(glb), "runtime": data.get("runtime", True)})
    report_name = "golden_source_audit.json"
    if "--report" in sys.argv:
        report_name = sys.argv[sys.argv.index("--report") + 1]
        assert Path(report_name).name == report_name, "report must be in assets/exported"
    target = ROOT / "assets/exported" / report_name
    target.write_text(json.dumps({"assets": report, "validated": len(report)}, indent=2), encoding="utf-8")
    print("GOLDEN_SOURCE_AUDIT", json.dumps({"validated": len(report), "triangles": sum(row["triangles"] for row in report)}))


if __name__ == "__main__":
    main()
