"""Read-only Blender/GLB audit of the selected refresh assets, not the whole library.

Blender --background --python-exit-code 1 --python tools/blender/validate_refresh_sources.py
Only the evidence JSON is written; editable sources and exports are never repaired.
"""
import hashlib
import json
import math
from pathlib import Path
import struct

import bpy

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "assets/exported/refresh/refresh_manifest.json"


def owned_path(relative):
    path = (ROOT / relative).resolve()
    assert path.is_relative_to((ROOT / "assets").resolve()), "outside asset directory"
    assert path.is_file(), f"missing source: {relative}"
    return path


def main():
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert len(manifest["assets"]) == 15
    for path in manifest["licenses"].values():
        assert "CC0" in owned_path(path).read_text(encoding="utf-8")
    rows, atlas = [], {}
    for asset in manifest["assets"]:
        source, export = owned_path(asset["blend"]), owned_path(asset["export"])
        for path, digest in asset["sourceHashes"].items():
            assert hashlib.sha256(owned_path(path).read_bytes()).hexdigest() == digest, path
        bpy.ops.wm.open_mainfile(filepath=str(source))
        meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
        groups = {group["name"]: group for group in asset["groups"]}
        assert {obj.name for obj in meshes} == set(groups), asset["key"]
        triangles, geometry = 0, []
        for obj in sorted(meshes, key=lambda entry: entry.name):
            group = groups[obj.name]
            assert obj.get("MaterialGroup") == group["material"]
            assert obj.get("AssetKey") == asset["key"]
            assert obj.parent is None and len(obj.modifiers) == 0
            assert all(abs(v) < 1e-6 for v in obj.location)
            assert all(abs(v) < 1e-6 for v in obj.rotation_euler)
            assert all(abs(v - 1) < 1e-6 for v in obj.scale)
            mesh = obj.data
            mesh.calc_loop_triangles()
            assert len(mesh.loop_triangles) == group["triangles"]
            assert all(tri.area > 1e-10 for tri in mesh.loop_triangles), f"degenerate: {obj.name}"
            assert mesh.uv_layers.active is not None, f"missing UV: {obj.name}"
            vertices = [(v.co.x, v.co.z, -v.co.y) for v in mesh.vertices]
            assert all(math.isfinite(v) for point in vertices for v in point)
            lo = [min(point[i] for point in vertices) for i in range(3)]
            hi = [max(point[i] for point in vertices) for i in range(3)]
            assert all(abs((lo[i] + hi[i]) / 2 - group["center"][i]) < 1e-5 for i in range(3))
            assert all(abs(max(.001, hi[i] - lo[i]) - group["size"][i]) < 1e-5 for i in range(3))
            for node in obj.data.materials[0].node_tree.nodes:
                if node.type == "TEX_IMAGE" and node.image:
                    assert node.image.packed_file, f"external texture dependency: {obj.name}"
                    assert max(node.image.size) <= 512
            triangles += len(mesh.loop_triangles)
            geometry.append({"name": obj.name, "vertices": vertices,
                             "triangles": [list(tri.vertices) for tri in mesh.loop_triangles],
                             "uv": [list(uv.uv) for uv in mesh.uv_layers.active.data]})
            if group["texture"]:
                path = owned_path(group["texture"])
                data = path.read_bytes()
                assert data[:8] == b"\x89PNG\r\n\x1a\n"
                width, height = struct.unpack_from(">II", data, 16)
                assert max(width, height) <= 512
                atlas[group["texture"]] = {"width": width, "height": height,
                                           "sha256": hashlib.sha256(data).hexdigest()}
        assert triangles == asset["triangles"]
        data = export.read_bytes()
        assert data[:4] == b"glTF" and struct.unpack_from("<I", data, 8)[0] == len(data)
        length = struct.unpack_from("<I", data, 12)[0]
        doc = json.loads(data[20:20 + length])
        assert all("uri" not in buffer for buffer in doc["buffers"]), "external GLB dependency"
        assert len(doc["meshes"]) == len(meshes) and not doc.get("animations")
        exported = 0
        for mesh in doc["meshes"]:
            for primitive in mesh["primitives"]:
                assert primitive.get("mode", 4) == 4
                assert {"POSITION", "NORMAL", "TEXCOORD_0"}.issubset(primitive["attributes"])
                count = doc["accessors"][primitive["indices"]]["count"]
                assert count % 3 == 0
                exported += count // 3
        assert exported == triangles, f"GLB topology differs: {asset['key']}"
        rows.append({"asset": asset["key"], "triangles": triangles, "meshObjects": len(meshes),
                     "blend": asset["blend"], "export": asset["export"],
                     "geometryUvSha256": hashlib.sha256(json.dumps(geometry, sort_keys=True).encode()).hexdigest(),
                     "blendSha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                     "glbSha256": hashlib.sha256(data).hexdigest()})
    combined = owned_path("assets/blender/refresh/refresh_studio_import.blend")
    bpy.ops.wm.open_mainfile(filepath=str(combined))
    expected = {group["name"] for asset in manifest["assets"] for group in asset["groups"]}
    assert {obj.name for obj in bpy.context.scene.objects if obj.type == "MESH"} == expected
    owned_path("assets/exported/refresh/refresh_studio_import.fbx")
    report = {"validated": len(rows), "triangles": sum(row["triangles"] for row in rows),
              "meshObjects": sum(row["meshObjects"] for row in rows), "assets": rows, "atlas": atlas,
              "scope": "Source/UV/topology/transforms/resources; native Studio import is separate evidence"}
    target = ROOT / "docs/implementation/production/evidence/refresh/source_audit.json"
    target.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("REFRESH_SOURCE_AUDIT", json.dumps({key: report[key] for key in ("validated", "triangles", "meshObjects")}))


if __name__ == "__main__":
    main()
