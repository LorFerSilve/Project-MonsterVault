"""Build a deterministic, material-only Energy Core Generator in Blender 5.2.2.

Run with: blender --background --python tools/blender/generate_energy_core.py
Optional checks after ``--``: --inspect --roundtrip --preview
FBX experiment from the saved source only: --fbx-only (never rewrites BLEND/GLB).
One modeling unit is one stud; use Scale Unit = Stud in Studio's importer.
The editable source retains named components. The GLB combines them into four
single-material meshes, all sharing a floor-centered origin.
"""

import argparse
import hashlib
import json
import math
from pathlib import Path
import struct
import sys

import bmesh
import bpy
from mathutils import Vector


REPO_ROOT = Path(__file__).resolve().parents[2]
BLEND_PATH = REPO_ROOT / "assets" / "blender" / "energy_core_generator.blend"
GLB_PATH = REPO_ROOT / "assets" / "exported" / "energy_core_generator.glb"
FBX_PATH = REPO_ROOT / "assets" / "exported" / "energy_core_generator.fbx"
CHECK_DIR = REPO_ROOT / ".test-results" / "blender"
ROOT_NAME = "EnergyCoreGenerator"
MATERIAL_NAMES = ("DarkMetal", "SecondaryMetal", "PanelPlastic", "EnergyGreen")
EXPECTED_COMPONENTS = {
    "Base_ReinforcedPlinth", "Base_UpperDeck", "Chamber_LowerSocket",
    "Chamber_UpperSocket", "Chamber_EnergyLower", "Chamber_EnergyMiddle",
    "Chamber_EnergyUpper", "Chamber_CollarLower", "Chamber_CollarUpper",
    "Pillar_FrontLeft", "Pillar_FrontRight", "Pillar_RearLeft", "Pillar_RearRight",
    "Crown_MainHousing", "Crown_RoofRim", "Control_FrontBezel",
    "Cooling_RightHousing", "Pipe_RearLeft", "Pipe_RearRight",
}


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def activate(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def material(name, color, metallic, roughness, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    if emission is not None:
        shader.inputs["Emission Color"].default_value = (*emission, 1.0)
        # Core glTF emissiveFactor only: no HDR, glass, or shader extensions.
        shader.inputs["Emission Strength"].default_value = 1.0
    return mat


class Builder:
    def __init__(self):
        bpy.ops.wm.read_factory_settings(use_empty=True)
        bpy.context.preferences.filepaths.save_version = 0
        scene = bpy.context.scene
        scene.name = "EnergyCoreGenerator_Source"
        scene.unit_settings.system = "NONE"
        scene.unit_settings.scale_length = 1.0
        scene.cursor.location = (0.0, 0.0, 0.0)
        self.collection = bpy.data.collections.new("EnergyCoreGenerator_Asset")
        scene.collection.children.link(self.collection)
        self.root = bpy.data.objects.new(ROOT_NAME, None)
        self.root.empty_display_type = "PLAIN_AXES"
        self.root.empty_display_size = 0.6
        self.collection.objects.link(self.root)
        self.root["asset_units"] = "stud"
        self.root["design_dimensions_width_depth_height"] = [4.0, 4.0, 6.0]
        self.root["pivot"] = "floor center; Blender Z-up, exported glTF Y-up"
        self.materials = {
            "DarkMetal": material("DarkMetal", (0.075, 0.105, 0.140), 0.72, 0.43),
            "SecondaryMetal": material("SecondaryMetal", (0.34, 0.43, 0.50), 0.62, 0.34),
            "PanelPlastic": material("PanelPlastic", (0.017, 0.025, 0.034), 0.0, 0.70),
            "EnergyGreen": material("EnergyGreen", (0.055, 0.95, 0.16), 0.0, 0.28,
                                    emission=(0.08, 1.0, 0.22)),
        }
        self.parts = []

    def finish(self, obj, name, mat, bevel=0.0):
        obj.name = name
        obj.data.name = name + "_Mesh"
        for collection in list(obj.users_collection):
            collection.objects.unlink(obj)
        self.collection.objects.link(obj)
        activate(obj)
        # Bake position as well as rotation/scale so every piece shares the pivot.
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        obj.data.materials.append(self.materials[mat])
        if bevel:
            modifier = obj.modifiers.new("EdgeChamfer", "BEVEL")
            # Thin indicators need a smaller chamfer than structural components.
            modifier.width = min(bevel, min(obj.dimensions) * 0.4)
            modifier.segments = 1
            modifier.limit_method = "ANGLE"
            require("FINISHED" in bpy.ops.object.modifier_apply(modifier=modifier.name),
                    f"Bevel application failed: {name}")
        # Keep source faces as triangles/quads, including cylinder end caps.
        bm = bmesh.new()
        try:
            bm.from_mesh(obj.data)
            bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
            ngons = [face for face in bm.faces if len(face.verts) > 4]
            if ngons:
                bmesh.ops.triangulate(bm, faces=ngons)
            bm.to_mesh(obj.data)
        finally:
            bm.free()
        obj.data.update()
        obj.parent = self.root
        self.parts.append(obj)
        return obj

    def box(self, name, dimensions, center, mat="DarkMetal", bevel=0.04):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=center)
        obj = bpy.context.object
        obj.dimensions = dimensions
        return self.finish(obj, name, mat, bevel)

    def mesh(self, name, vertices, faces, mat, bevel=0.0, smooth_sides=False):
        data = bpy.data.meshes.new(name + "_Mesh")
        data.from_pydata(vertices, [], faces)
        data.update()
        if smooth_sides:
            for polygon in data.polygons:
                polygon.use_smooth = len(polygon.vertices) == 4
        obj = bpy.data.objects.new(name, data)
        self.collection.objects.link(obj)
        return self.finish(obj, name, mat, bevel)

    def lathe(self, name, profile, mat, sides=16, closed_profile=False):
        vertices = [(radius * math.cos(2 * math.pi * i / sides),
                     radius * math.sin(2 * math.pi * i / sides), z)
                    for z, radius in profile for i in range(sides)]
        faces = []
        intervals = len(profile) if closed_profile else len(profile) - 1
        for ring in range(intervals):
            following = (ring + 1) % len(profile)
            for i in range(sides):
                j = (i + 1) % sides
                faces.append((ring * sides + i, ring * sides + j,
                              following * sides + j, following * sides + i))
        if not closed_profile:
            faces.extend([tuple(reversed(range(sides))),
                          tuple((len(profile) - 1) * sides + i for i in range(sides))])
        return self.mesh(name, vertices, faces, mat, smooth_sides=True)

    def ring(self, name, bottom, top, outer, inner, mat):
        chamfer = 0.035
        profile = [(bottom, outer - chamfer), (bottom + chamfer, outer),
                   (top - chamfer, outer), (top, outer - chamfer),
                   (top, inner), (bottom, inner)]
        return self.lathe(name, profile, mat, closed_profile=True)

    def pillar(self, name, x, y):
        vertices = []
        levels = [(0.69, 0.62), (0.96, 0.62), (1.26, 0.44),
                  (4.90, 0.44), (5.18, 0.64), (5.43, 0.64)]
        for z, width in levels:
            half, corner = width / 2, 0.08
            outline = [(-half + corner, -half), (half - corner, -half),
                       (half, -half + corner), (half, half - corner),
                       (half - corner, half), (-half + corner, half),
                       (-half, half - corner), (-half, -half + corner)]
            vertices.extend((x + u, y + v, z) for u, v in outline)
        faces = []
        for level in range(len(levels) - 1):
            for i in range(8):
                j = (i + 1) % 8
                faces.append((level * 8 + i, level * 8 + j,
                              (level + 1) * 8 + j, (level + 1) * 8 + i))
        faces.extend([tuple(reversed(range(8))), tuple(40 + i for i in range(8))])
        return self.mesh(name, vertices, faces, "DarkMetal", bevel=0.018)

    def beam(self, name, start, end, width, depth, mat):
        direction = Vector(end) - Vector(start)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(Vector(start) + Vector(end)) / 2)
        obj = bpy.context.object
        obj.dimensions = (width, depth, direction.length)
        obj.rotation_mode = "QUATERNION"
        obj.rotation_quaternion = direction.to_track_quat("Z", "Y")
        return self.finish(obj, name, mat, bevel=0.025)

    def pipe(self, name, points, radius=0.13):
        centers = [Vector(point) for point in points]
        sides, vertices, faces = 8, [], []
        for index, center in enumerate(centers):
            tangent = (centers[min(index + 1, len(centers) - 1)]
                       - centers[max(index - 1, 0)]).normalized()
            side = tangent.cross(Vector((0, 1, 0))).normalized()
            other = tangent.cross(side).normalized()
            for i in range(sides):
                angle = 2 * math.pi * i / sides
                vertices.append(tuple(center + radius * (math.cos(angle) * side
                                                          + math.sin(angle) * other)))
        for ring in range(len(centers) - 1):
            for i in range(sides):
                j = (i + 1) % sides
                faces.append((ring * sides + i, ring * sides + j,
                              (ring + 1) * sides + j, (ring + 1) * sides + i))
        faces.extend([tuple(reversed(range(sides))),
                      tuple((len(centers) - 1) * sides + i for i in range(sides))])
        return self.mesh(name, vertices, faces, "SecondaryMetal")

    def roof_rim(self):
        outer, inner = 1.85, 1.59
        vertices = []
        for z in (5.88, 6.0):
            for extent in (outer, inner):
                vertices.extend((x, y, z) for x, y in
                                ((-extent, -extent), (extent, -extent),
                                 (extent, extent), (-extent, extent)))
        faces = []
        for i in range(4):
            j = (i + 1) % 4
            faces.extend([(i, j, 8 + j, 8 + i), (4 + j, 4 + i, 12 + i, 12 + j),
                          (8 + i, 8 + j, 12 + j, 12 + i), (j, i, 4 + i, 4 + j)])
        return self.mesh("Crown_RoofRim", vertices, faces, "SecondaryMetal", bevel=0.025)

    def build(self):
        self.box("Base_ReinforcedPlinth", (4.0, 4.0, 0.42), (0, 0, 0.21), bevel=0.10)
        self.box("Base_UpperDeck", (3.70, 3.70, 0.24), (0, 0, 0.54), "SecondaryMetal", 0.055)
        for label, x, y in (("FrontLeft", -1.55, -1.55), ("FrontRight", 1.55, -1.55),
                            ("RearLeft", -1.55, 1.55), ("RearRight", 1.55, 1.55)):
            self.pillar("Pillar_" + label, x, y)
            self.box("Foot_" + label, (0.72, 0.72, 0.23), (x, y, 0.765), "SecondaryMetal")
            self.box("Shoulder_" + label, (0.72, 0.72, 0.23), (x, y, 5.315), "SecondaryMetal")
            self.beam("Brace_" + label, (x * 0.72, y * 0.72, 0.73),
                      (x, y, 1.28), 0.20, 0.22, "SecondaryMetal")
            if label.startswith("Front"):
                self.box("Pillar_" + label + "_Inset", (0.25, 0.05, 2.45),
                         (x, -1.795, 3.14), "PanelPlastic", 0.015)
                self.box("Pillar_" + label + "_EnergyStrip", (0.075, 0.018, 1.94),
                         (x, -1.830, 3.15), "EnergyGreen", 0.006)

        self.lathe("Chamber_LowerSocket", [(0.65, 0.88), (0.77, 1.07), (0.95, 1.07),
                                          (1.12, 0.88), (1.29, 0.66)], "SecondaryMetal")
        self.ring("Chamber_LowerRetainer", 1.23, 1.42, 0.88, 0.58, "PanelPlastic")
        for name, bottom, top in (("Lower", 1.38, 2.41), ("Middle", 2.55, 3.65),
                                  ("Upper", 3.79, 4.80)):
            self.lathe("Chamber_Energy" + name,
                       [(bottom, 0.62), (bottom + 0.16, 0.78),
                        (top - 0.16, 0.78), (top, 0.62)], "EnergyGreen")
        self.ring("Chamber_CollarLower", 2.38, 2.58, 0.91, 0.58, "DarkMetal")
        self.ring("Chamber_CollarUpper", 3.62, 3.82, 0.91, 0.58, "DarkMetal")
        self.ring("Chamber_UpperRetainer", 4.77, 4.96, 0.88, 0.58, "PanelPlastic")
        self.lathe("Chamber_UpperSocket", [(4.77, 0.66), (4.95, 0.88), (5.13, 1.07),
                                          (5.31, 1.07), (5.43, 0.89)], "SecondaryMetal")
        for label, sign in (("Left", -1), ("Right", 1)):
            self.pipe("Pipe_Rear" + label,
                      [(sign * 0.71, 0.77, 1.05), (sign * 1.10, 1.06, 1.39),
                       (sign * 1.13, 1.12, 1.64), (sign * 1.13, 1.12, 4.47),
                       (sign * 1.10, 1.06, 4.74), (sign * 0.71, 0.77, 5.08)])

        self.box("Control_BaseHousing", (2.08, 0.73, 0.53), (0, -1.34, 0.915), bevel=0.07)
        self.box("Control_FrontBezel", (1.98, 0.22, 0.66), (0, -1.71, 1.04), "SecondaryMetal", 0.055)
        self.box("Control_RecessedPanel", (1.68, 0.08, 0.41), (0, -1.85, 1.05), "PanelPlastic", 0.025)
        for index, width in enumerate((0.72, 0.55, 0.37)):
            self.box(f"Control_EnergyReadout_{index + 1}", (width, 0.025, 0.045),
                     (-0.28, -1.90, 1.15 - index * 0.095), "EnergyGreen", 0.007)
        for index in range(2):
            self.box(f"Control_StatusLight_{index + 1}", (0.11, 0.025, 0.11),
                     (0.55, -1.90, 1.14 - index * 0.18), "EnergyGreen", 0.013)

        self.box("Cooling_RightHousing", (0.70, 1.48, 1.08), (1.36, 0, 1.20), "SecondaryMetal", 0.06)
        self.box("Cooling_VentBacking", (0.06, 1.22, 0.73), (1.725, 0, 1.22), "PanelPlastic", 0.015)
        for index in range(4):
            self.box(f"Cooling_VentSlat_{index + 1}", (0.045, 1.04, 0.055),
                     (1.775, 0, 0.96 + index * 0.175), "SecondaryMetal", 0.012)

        self.box("Crown_MainHousing", (3.90, 3.90, 0.45), (0, 0, 5.655), bevel=0.08)
        self.roof_rim()
        self.box("Crown_RecessedRoof", (3.16, 3.16, 0.07), (0, 0, 5.915), "DarkMetal", 0.025)
        self.box("Crown_VentWell", (2.44, 1.06, 0.03), (0, 0, 5.955), "PanelPlastic", 0.01)
        for index in range(5):
            self.box(f"Crown_VentSlat_{index + 1}", (0.14, 0.84, 0.026),
                     ((index - 2) * 0.43, 0, 5.984), "SecondaryMetal", 0.008)
        self.box("Crown_FrontInset", (1.26, 0.035, 0.15), (0, -1.96, 5.65), "PanelPlastic", 0.012)
        self.box("Crown_EnergyStatus", (1.08, 0.012, 0.048), (0, -1.985, 5.65), "EnergyGreen", 0.004)
        return self.parts


def bounds(objects):
    points = [obj.matrix_world @ vertex.co for obj in objects for vertex in obj.data.vertices]
    minimum = [min(point[axis] for point in points) for axis in range(3)]
    maximum = [max(point[axis] for point in points) for axis in range(3)]
    return minimum, maximum, [round(high - low, 6) for low, high in zip(minimum, maximum)]


def validate_mesh(obj):
    mesh = obj.data
    require(not mesh.validate(verbose=False, clean_customdata=False), f"Invalid mesh data: {obj.name}")
    require(all(math.isfinite(value) for vertex in mesh.vertices for value in vertex.co),
            f"Non-finite vertex: {obj.name}")
    bm = bmesh.new()
    try:
        bm.from_mesh(mesh)
        require(all(vertex.link_faces for vertex in bm.verts), f"Loose vertex: {obj.name}")
        require(all(edge.is_manifold and edge.is_contiguous and edge.calc_length() > 1e-7
                    for edge in bm.edges), f"Open, loose, or invalid edge: {obj.name}")
        require(all(face.calc_area() > 1e-9 and len(face.verts) <= 4 for face in bm.faces),
                f"Degenerate face or n-gon: {obj.name}")
        require(bm.calc_volume(signed=True) > 1e-8, f"Inverted or zero-volume mesh: {obj.name}")
    finally:
        bm.free()
    mesh.calc_loop_triangles()
    require(all(triangle.area > 1e-9 for triangle in mesh.loop_triangles),
            f"Degenerate triangle: {obj.name}")


def source_signature(parts):
    payload = []
    for obj in sorted(parts, key=lambda item: item.name):
        payload.append({"name": obj.name,
                        "material": obj.data.materials[0].name,
                        "vertices": [[round(value, 6) for value in vertex.co] for vertex in obj.data.vertices],
                        "faces": [[*polygon.vertices] for polygon in obj.data.polygons],
                        "smooth": [polygon.use_smooth for polygon in obj.data.polygons]})
    for name in MATERIAL_NAMES:
        shader = bpy.data.materials[name].node_tree.nodes.get("Principled BSDF")
        payload.append({"material": name, "parameters": {
            key: list(shader.inputs[key].default_value) if key.endswith("Color") else shader.inputs[key].default_value
            for key in ("Base Color", "Metallic", "Roughness", "Emission Color", "Emission Strength")}})
    return hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def inspect_source():
    root = bpy.data.objects.get(ROOT_NAME)
    require(root is not None and root.type == "EMPTY", "Missing asset root/pivot")
    parts = sorted((obj for obj in bpy.context.scene.objects if obj.type == "MESH"), key=lambda obj: obj.name)
    require(EXPECTED_COMPONENTS <= {obj.name for obj in parts}, "Expected named components missing")
    require({mat.name for mat in bpy.data.materials} == set(MATERIAL_NAMES), "Unexpected materials")
    for obj in [root, *parts]:
        require(all(abs(value) < 1e-7 for value in obj.location), f"Unapplied location: {obj.name}")
        require(all(abs(value - 1.0) < 1e-7 for value in obj.scale), f"Unapplied scale: {obj.name}")
        require(obj.matrix_local.to_quaternion().angle < 1e-6, f"Unapplied rotation: {obj.name}")
        if obj.type == "MESH":
            require(obj.parent == root and not obj.modifiers, f"Unexpected parent/modifiers: {obj.name}")
            require(len(obj.data.materials) == 1, f"Multiple materials on component: {obj.name}")
            validate_mesh(obj)
    for mat in bpy.data.materials:
        require(not any(node.type == "TEX_IMAGE" for node in mat.node_tree.nodes), "External texture node found")
    shader = bpy.data.materials["EnergyGreen"].node_tree.nodes.get("Principled BSDF")
    require(shader.inputs["Emission Strength"].default_value == 1.0
            and shader.inputs["Emission Color"].default_value[1] > 0.9, "Energy emission missing")
    minimum, maximum, dimensions = bounds(parts)
    require(all(abs(actual - target) < 1e-5 for actual, target in zip(dimensions, (4, 4, 6))),
            f"Unexpected asset dimensions: {dimensions}")
    require(abs(minimum[2]) < 1e-6 and abs(minimum[0] + maximum[0]) < 1e-6
            and abs(minimum[1] + maximum[1]) < 1e-6, "Asset is not floor-centered")
    stats = {"objects": len(parts), "vertices": sum(len(obj.data.vertices) for obj in parts),
             "faces": sum(len(obj.data.polygons) for obj in parts),
             "triangles": sum(len(obj.data.loop_triangles) for obj in parts)}
    require(stats["triangles"] < 8000, "Exceeded the asset's 8,000-triangle budget")
    return parts, dimensions, stats, source_signature(parts)


def export_glb(parts):
    """Consolidate disconnected, closed components by material for Studio."""
    root = bpy.data.objects[ROOT_NAME]
    staging = bpy.data.collections.new("_TemporaryExport")
    bpy.context.scene.collection.children.link(staging)
    export_objects = []
    try:
        for mat_name in MATERIAL_NAMES:
            vertices, faces, smooth = [], [], []
            for source in parts:
                if source.data.materials[0].name != mat_name:
                    continue
                offset = len(vertices)
                vertices.extend(tuple(vertex.co) for vertex in source.data.vertices)
                faces.extend(tuple(offset + index for index in polygon.vertices)
                             for polygon in source.data.polygons)
                smooth.extend(polygon.use_smooth for polygon in source.data.polygons)
            data = bpy.data.meshes.new("EC_" + mat_name + "_Mesh")
            data.from_pydata(vertices, [], faces)
            data.materials.append(bpy.data.materials[mat_name])
            for polygon, is_smooth in zip(data.polygons, smooth):
                polygon.use_smooth = is_smooth
            data.update()
            obj = bpy.data.objects.new("EC_" + mat_name, data)
            staging.objects.link(obj)
            obj.parent = root
            export_objects.append(obj)
            validate_mesh(obj)
        bpy.ops.object.select_all(action="DESELECT")
        for obj in [root, *export_objects]:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = root
        result = bpy.ops.export_scene.gltf(
            filepath=str(GLB_PATH), check_existing=False, export_format="GLB",
            use_selection=True, export_yup=True, export_apply=True,
            export_materials="EXPORT", export_normals=True, export_texcoords=False,
            export_animations=False, export_cameras=False, export_lights=False,
            export_extras=True, export_draco_mesh_compression_enable=False,
            export_meshopt_compression_enable=False, will_save_settings=False,
        )
        require("FINISHED" in result, "GLB export failed")
    finally:
        for obj in export_objects:
            data = obj.data
            bpy.data.objects.remove(obj, do_unlink=True)
            bpy.data.meshes.remove(data)
        bpy.data.collections.remove(staging)


def run_fbx_experiment():
    """Export the existing source and verify FBX data without touching BLEND/GLB."""
    from io_scene_fbx import parse_fbx  # Bundled Blender exporter/parser, no dependency added.

    protected_before = {path: hashlib.sha256(path.read_bytes()).hexdigest()
                        for path in (BLEND_PATH, GLB_PATH)}
    require("FINISHED" in bpy.ops.wm.open_mainfile(filepath=str(BLEND_PATH)), "Source reopen failed")
    parts, dimensions, source_stats, fingerprint = inspect_source()
    require(fingerprint == bpy.data.objects[ROOT_NAME]["geometry_material_sha256"], "Source fingerprint differs")
    assignments = {obj.name: obj.data.materials[0].name for obj in parts}
    component_bounds = {obj.name: bounds([obj])[:2] for obj in parts}
    shader_keys = ("Base Color", "Metallic", "Roughness", "Emission Color", "Emission Strength")
    expected_materials = {}
    for name in MATERIAL_NAMES:
        shader = bpy.data.materials[name].node_tree.nodes.get("Principled BSDF")
        expected_materials[name] = {
            key: list(shader.inputs[key].default_value) if key.endswith("Color")
            else shader.inputs[key].default_value for key in shader_keys}

    bpy.ops.object.select_all(action="DESELECT")
    root = bpy.data.objects[ROOT_NAME]
    for obj in [root, *parts]:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    FBX_PATH.parent.mkdir(parents=True, exist_ok=True)
    export_settings = {
        "axis_forward": "Z", "axis_up": "Y", "global_scale": 1.0,
        "apply_unit_scale": True, "apply_scale_options": "FBX_SCALE_UNITS",
        "use_space_transform": True, "bake_space_transform": True,
        "use_selection": True, "object_types": {"EMPTY", "MESH"},
        "use_mesh_modifiers": True, "mesh_smooth_type": "FACE",
        "use_triangles": False, "use_mesh_edges": False,
        "bake_anim": False, "add_leaf_bones": False,
        "use_custom_props": False, "path_mode": "AUTO", "embed_textures": False,
    }
    # Source transforms are already baked; the exporter bakes axis conversion
    # into this static FBX without editing the source components or materials.
    require("FINISHED" in bpy.ops.export_scene.fbx(
        filepath=str(FBX_PATH), check_existing=False, **export_settings), "FBX export failed")
    require(FBX_PATH.is_file() and FBX_PATH.stat().st_size > 0, "Missing or empty FBX")
    require(source_signature(parts) == fingerprint, "FBX export mutated source geometry/materials")

    tree, version = parse_fbx.parse(str(FBX_PATH))

    def child(element, identifier):
        return next(item for item in element.elems if item.id == identifier)

    def element_name(element):
        return element.props[1].split(b"\x00\x01", 1)[0].decode("utf-8")

    def property_values(element):
        properties = next((item for item in element.elems if item.id == b"Properties70"), None)
        if properties is None:
            return {}
        values = {}
        for item in properties.elems:
            if item.id == b"P":
                entries = [value.decode("utf-8") if isinstance(value, bytes) else value
                           for value in item.props[4:]]
                values[item.props[0].decode("utf-8")] = entries[0] if len(entries) == 1 else entries
        return values

    objects = child(tree, b"Objects").elems
    geometries = [item for item in objects if item.id == b"Geometry" and item.props[2] == b"Mesh"]
    models = [item for item in objects if item.id == b"Model"]
    materials = [item for item in objects if item.id == b"Material"]
    require(len(geometries) == source_stats["objects"]
            and len(models) == source_stats["objects"] + 1, "Unexpected FBX object/geometry count")
    require({element_name(item) for item in materials} == set(MATERIAL_NAMES), "FBX materials missing")
    require(not any(item.id in {b"Texture", b"Video"} for item in objects), "FBX contains texture/image records")
    vertex_count = sum(len(child(item, b"Vertices").props[0]) // 3 for item in geometries)
    face_count = sum(sum(index < 0 for index in child(item, b"PolygonVertexIndex").props[0])
                     for item in geometries)
    require(vertex_count == source_stats["vertices"] and face_count == source_stats["faces"],
            "FBX geometry counts differ from source")

    # Default material properties may be stored in the FBX template rather than
    # repeated in every material. Resolve both when inspecting the binary file.
    material_type = next(item for item in child(tree, b"Definitions").elems
                         if item.id == b"ObjectType" and item.props[0] == b"Material")
    defaults = property_values(child(material_type, b"PropertyTemplate"))
    material_fields = ("DiffuseColor", "DiffuseFactor", "EmissiveColor", "EmissiveFactor",
                       "ReflectionFactor", "Shininess", "ShininessExponent", "Opacity")
    material_records = {}
    for item in materials:
        properties = {**defaults, **property_values(item)}
        require(all(key in properties for key in material_fields), "Expected FBX material fields missing")
        material_records[element_name(item)] = {
            "shading_model": child(item, b"ShadingModel").props[0].decode("utf-8"),
            **{key: properties[key] for key in material_fields},
        }
    require(material_records["EnergyGreen"]["EmissiveColor"][1] > 0.9
            and material_records["EnergyGreen"]["EmissiveFactor"] > 0, "FBX energy emission missing")

    material_ids = {item.props[0]: element_name(item) for item in materials}
    model_ids = {item.props[0]: element_name(item) for item in models if item.props[2] == b"Mesh"}
    exported_assignments = {}
    for connection in child(tree, b"Connections").elems:
        kind, source, destination = connection.props[:3]
        if kind == b"OO" and source in material_ids and destination in model_ids:
            name = model_ids[destination]
            require(name not in exported_assignments, "FBX mesh has multiple material assignments")
            exported_assignments[name] = material_ids[source]
    require(exported_assignments == assignments, "FBX object/material assignments differ")
    global_settings = property_values(child(tree, b"GlobalSettings"))

    # Reimport in memory only to check orientation, dimensions and shader values.
    bpy.ops.wm.read_factory_settings(use_empty=True)
    require("FINISHED" in bpy.ops.import_scene.fbx(
        filepath=str(FBX_PATH), global_scale=1.0, use_manual_orientation=False,
        use_image_search=False, use_anim=False, use_custom_normals=True), "FBX reimport failed")
    imported = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    require({obj.name: obj.data.materials[0].name for obj in imported} == assignments,
            "FBX reimport changed object/material assignments")
    require({mat.name for mat in bpy.data.materials} == set(MATERIAL_NAMES), "FBX reimport materials differ")
    require(all(abs(actual - target) < 1e-5 for actual, target in zip(bounds(imported)[2], dimensions)),
            "FBX reimport dimensions differ")
    for obj in imported:
        obj.data.calc_loop_triangles()
        actual_bounds = bounds([obj])[:2]
        require(all(abs(actual - target) < 1e-5
                    for actual_corner, target_corner in zip(actual_bounds, component_bounds[obj.name])
                    for actual, target in zip(actual_corner, target_corner)),
                f"FBX component orientation/position differs: {obj.name}")
    require(sum(len(obj.data.loop_triangles) for obj in imported) == source_stats["triangles"],
            "FBX reimport triangle count differs")
    for name, expected in expected_materials.items():
        shader = bpy.data.materials[name].node_tree.nodes.get("Principled BSDF")
        require(shader is not None, f"FBX reimport shader missing: {name}")
        for key, target in expected.items():
            actual = shader.inputs[key].default_value
            actual_values = list(actual) if key.endswith("Color") else [actual]
            target_values = target if isinstance(target, list) else [target]
            require(all(abs(a - b) < 1e-5 for a, b in zip(actual_values, target_values)),
                    f"FBX reimport material parameter differs: {name}/{key}")

    protected_after = {path: hashlib.sha256(path.read_bytes()).hexdigest()
                       for path in protected_before}
    require(protected_after == protected_before, "Existing BLEND/GLB files changed")
    report = {
        "status": "PASS", "blender_version": bpy.app.version_string,
        "fbx_path": str(FBX_PATH), "fbx_bytes": FBX_PATH.stat().st_size, "fbx_version": version,
        "geometry_statistics": source_stats, "dimensions_width_depth_height": dimensions,
        "fbx_model_count": len(models), "fbx_material_records": material_records,
        "object_material_assignments_preserved": True, "blender_fbx_roundtrip": "PASS",
        "global_axis_unit_metadata": {key: global_settings[key] for key in
                                      ("UpAxis", "UpAxisSign", "FrontAxis", "FrontAxisSign", "UnitScaleFactor")},
        "export_settings": {key: sorted(value) if isinstance(value, set) else value
                            for key, value in export_settings.items()},
        "protected_output_sha256": {str(path): value for path, value in protected_after.items()},
        "textures": 0, "validation_scope": "FBX export, binary inspection and Blender reimport; Studio comparison pending",
    }
    CHECK_DIR.mkdir(parents=True, exist_ok=True)
    report_path = CHECK_DIR / "energy_core_generator_fbx_validation.json"
    report_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("ENERGY_CORE_FBX_EXPERIMENT: PASS", flush=True)
    print(json.dumps(report, indent=2, sort_keys=True), flush=True)
    print(f"FBX_VALIDATION_REPORT: {report_path}", flush=True)


def inspect_glb():
    data = GLB_PATH.read_bytes()
    magic, version, length = struct.unpack_from("<4sII", data)
    require(magic == b"glTF" and version == 2 and length == len(data), "Invalid GLB 2.0 header")
    json_length, json_type = struct.unpack_from("<I4s", data, 12)
    require(json_type == b"JSON" and json_length % 4 == 0, "Invalid GLB JSON chunk")
    document = json.loads(data[20:20 + json_length])
    offset = 20 + json_length
    binary_length, binary_type = struct.unpack_from("<I4s", data, offset)
    require(binary_type == b"BIN\x00" and offset + 8 + binary_length == len(data), "Invalid GLB binary chunk")
    binary = memoryview(data)[offset + 8:]
    require(document["asset"]["version"] == "2.0", "Unexpected glTF version")
    require(len(document["buffers"]) == 1 and "uri" not in document["buffers"][0], "External buffer found")
    require(document["buffers"][0]["byteLength"] <= binary_length
            <= document["buffers"][0]["byteLength"] + 3, "Invalid embedded buffer length")
    require(not document.get("images") and not document.get("textures"), "Texture images found")
    require(not document.get("extensionsRequired"), "GLB requires non-core extensions")
    require(not document.get("skins") and not document.get("animations"), "Unexpected rig/animation")
    require(len(document["meshes"]) == 4, "Export did not produce four material meshes")
    require({mat["name"] for mat in document["materials"]} == set(MATERIAL_NAMES), "GLB materials missing")
    require(any(node.get("name") == ROOT_NAME for node in document["nodes"]), "GLB root/pivot missing")
    green = next(mat for mat in document["materials"] if mat["name"] == "EnergyGreen")
    require(green.get("emissiveFactor", [0, 0, 0])[1] > 0.9, "GLB emission missing")

    def accessor_values(index):
        accessor = document["accessors"][index]
        view = document["bufferViews"][accessor["bufferView"]]
        formats = {5121: "B", 5123: "H", 5125: "I", 5126: "f"}
        widths = {"SCALAR": 1, "VEC3": 3}
        format_string = "<" + formats[accessor["componentType"]] * widths[accessor["type"]]
        element_size = struct.calcsize(format_string)
        stride = view.get("byteStride", element_size)
        start = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
        require(start + (accessor["count"] - 1) * stride + element_size
                <= view.get("byteOffset", 0) + view["byteLength"] <= len(binary), "Accessor exceeds buffer")
        return [struct.unpack_from(format_string, binary, start + item * stride)
                for item in range(accessor["count"])]

    vertex_count, triangle_count, all_positions = 0, 0, []
    for mesh in document["meshes"]:
        require(len(mesh["primitives"]) == 1, "Mesh has multiple material primitives")
        primitive = mesh["primitives"][0]
        require(primitive.get("mode", 4) == 4, "Non-triangle primitive")
        positions = accessor_values(primitive["attributes"]["POSITION"])
        normals = accessor_values(primitive["attributes"]["NORMAL"])
        indices = [value[0] for value in accessor_values(primitive["indices"])]
        require(len(normals) == len(positions) and len(indices) % 3 == 0, "Malformed mesh attributes")
        require(all(math.isfinite(value) for position in positions for value in position), "Invalid exported position")
        require(all(abs(Vector(normal).length - 1.0) < 1e-4 for normal in normals), "Invalid exported normal")
        require(all(0 <= index < len(positions) for index in indices), "Index outside exported vertices")
        for item in range(0, len(indices), 3):
            a, b, c = (Vector(positions[index]) for index in indices[item:item + 3])
            require((b - a).cross(c - a).length > 1e-9, "Degenerate exported triangle")
        vertex_count += len(positions)
        triangle_count += len(indices) // 3
        all_positions.extend(positions)
    dimensions = [round(max(p[axis] for p in all_positions) - min(p[axis] for p in all_positions), 6)
                  for axis in range(3)]
    require(dimensions == [4.0, 6.0, 4.0], f"Unexpected Y-up GLB dimensions: {dimensions}")
    return {"meshes": 4, "vertices": vertex_count, "triangles": triangle_count,
            "dimensions_gltf_xyz": dimensions, "sha256": hashlib.sha256(data).hexdigest()}


def roundtrip_glb(expected_triangles):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    require("FINISHED" in bpy.ops.import_scene.gltf(filepath=str(GLB_PATH)), "GLB reimport failed")
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    require(len(meshes) == 4 and len(bpy.data.materials) == 4, "Unexpected GLB roundtrip contents")
    require({obj.name for obj in meshes} == {"EC_" + name for name in MATERIAL_NAMES}, "GLB mesh names changed")
    require(bounds(meshes)[2] == [4.0, 4.0, 6.0], "Roundtrip dimensions differ")
    for obj in meshes:
        obj.data.calc_loop_triangles()
    require(sum(len(obj.data.loop_triangles) for obj in meshes) == expected_triangles, "Roundtrip triangle count differs")
    require(bpy.data.objects.get(ROOT_NAME) is not None, "Roundtrip pivot missing")
    print("GLB_ROUNDTRIP: PASS - four material meshes, expected dimensions and triangles", flush=True)


def render_preview():
    """Diagnostic render only; camera, lighting and ground are never saved/exported."""
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 32
    scene.cycles.use_denoising = True
    scene.render.resolution_x = 900
    scene.render.resolution_y = 1000
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    scene.view_settings.exposure = -0.4
    world = bpy.data.worlds.new("PreviewWorld")
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.075, 0.10, 0.15, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = 0.32
    scene.world = world
    bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, -0.018))
    bpy.context.object.name = "PreviewGround"
    ground = material("PreviewGroundMaterial", (0.095, 0.125, 0.17), 0.0, 0.85)
    bpy.context.object.data.materials.append(ground)
    bpy.ops.object.camera_add(location=(8.7, -11.5, 8.2))
    camera = bpy.context.object
    camera.rotation_euler = (Vector((0, 0, 2.92)) - camera.location).to_track_quat("-Z", "Y").to_euler()
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 8.4
    scene.camera = camera
    for label, location, energy, size, color in (
            ("Key", (1, -5, 10), 1150, 5.0, (0.87, 0.94, 1.0)),
            ("Fill", (6, -1, 5), 800, 4.0, (0.70, 0.86, 1.0)),
            ("Rim", (-4, 4, 8), 1500, 4.0, (0.60, 0.77, 1.0))):
        bpy.ops.object.light_add(type="AREA", location=location)
        light = bpy.context.object
        light.name = "Preview" + label
        light.data.energy, light.data.shape, light.data.size, light.data.color = energy, "DISK", size, color
        light.rotation_euler = (Vector((0, 0, 2.8)) - light.location).to_track_quat("-Z", "Y").to_euler()
    CHECK_DIR.mkdir(parents=True, exist_ok=True)
    preview_path = CHECK_DIR / "energy_core_generator_preview.png"
    scene.render.filepath = str(preview_path)
    require("FINISHED" in bpy.ops.render.render(write_still=True), "Preview render failed")
    print(f"PREVIEW: {preview_path}", flush=True)


def main():
    require(bpy.app.version == (5, 2, 2), f"Blender 5.2.2 required, found {bpy.app.version_string}")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--inspect", action="store_true", help="Reopen and validate the saved source without regeneration")
    parser.add_argument("--roundtrip", action="store_true", help="Import the exported GLB into an empty scene")
    parser.add_argument("--preview", action="store_true", help="Render a local diagnostic preview")
    parser.add_argument("--fbx-only", action="store_true", help="Export/verify FBX from the saved source without regenerating BLEND/GLB")
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
    if args.fbx_only:
        require(not (args.inspect or args.roundtrip or args.preview), "Use --fbx-only without the other optional modes")
        run_fbx_experiment()
        return
    for path in (BLEND_PATH, GLB_PATH):
        path.parent.mkdir(parents=True, exist_ok=True)
    if args.inspect:
        require("FINISHED" in bpy.ops.wm.open_mainfile(filepath=str(BLEND_PATH)), "Source reopen failed")
    else:
        builder = Builder()
        builder.build()
        parts, _, _, fingerprint = inspect_source()
        builder.root["geometry_material_sha256"] = fingerprint
        builder.root["generator"] = "tools/blender/generate_energy_core.py"
        export_glb(parts)
        bpy.ops.object.select_all(action="DESELECT")
        builder.root.select_set(True)
        bpy.context.view_layer.objects.active = builder.root
        require("FINISHED" in bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH)), "Source save failed")
    for path in (BLEND_PATH, GLB_PATH):
        require(path.is_file() and path.stat().st_size > 0, f"Missing or empty output: {path}")
    parts, dimensions, mesh_stats, fingerprint = inspect_source()
    require(fingerprint == bpy.data.objects[ROOT_NAME]["geometry_material_sha256"], "Saved source fingerprint differs")
    glb_stats = inspect_glb()
    require(glb_stats["triangles"] == mesh_stats["triangles"], "Source/export triangle counts differ")
    report = {"status": "PASS", "blender_version": bpy.app.version_string,
              "dimensions_width_depth_height_studs": dimensions,
              "source_mesh_statistics": mesh_stats, "glb_statistics": glb_stats,
              "materials": list(MATERIAL_NAMES), "geometry_material_sha256": fingerprint,
              "outputs": [{"path": str(path), "bytes": path.stat().st_size} for path in (BLEND_PATH, GLB_PATH)],
              "geometry_checks": "closed, consistently wound, no loose/degenerate elements, no n-gons",
              "import_scale_unit": "Stud", "warnings": [],
              "validation_scope": "Blender source and glTF 2.0; Roblox Studio import not exercised"}
    CHECK_DIR.mkdir(parents=True, exist_ok=True)
    report_path = CHECK_DIR / "energy_core_generator_validation.json"
    report_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("ENERGY_CORE_GENERATOR: PASS", flush=True)
    print(json.dumps(report, indent=2, sort_keys=True), flush=True)
    print(f"VALIDATION_REPORT: {report_path}", flush=True)
    if args.roundtrip:
        roundtrip_glb(mesh_stats["triangles"])
    if args.preview:
        render_preview()


if __name__ == "__main__":
    main()
