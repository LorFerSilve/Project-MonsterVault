"""Package native screenshots without retouching, resizing, or synthesizing pixels."""

from hashlib import sha256
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "docs/implementation/production/evidence/golden"
CAPTIONS = {
    "01_starter_permanent": "Permanent Mossline vista; seasonal presentation OFF.",
    "02_starter_halloween": "Same Starter vista; actual seasonal toggle ON.",
    "03_safe_outpost": "Field Station wraps the existing secure and travel anchors.",
    "04_common_encounter": "Mossbud; existing authored Common identity.",
    "05_capture_buildup": "Native engage/Claimed frame; ordered lifecycle and peak VFX are in capture evidence.",
    "06_capture_secured": "Authoritative Secured/Collection payoff after custody reached safety.",
    "07_legendary_reveal": "Helion, protected Legendary DEV. Native isolated clock/RNG probe; settled reveal pose, not live odds evidence.",
    "08_home_exterior": "Permanent Home entry; identical source capture to the Home OFF matched pair.",
    "09_vault_interior": "Permanent Vault architecture, displays, accumulator and reused Energy Core.",
    "10_creature_display": "Exact owned Mossbud presentation faces the Vault entry; no ownership/capture tags.",
    "11_energy_claim": "Matched +8 authoritative receipt; count-up and local energy path in progress.",
    "12_progression": "Current capacity and next aspiration using the existing quote/purchase flow.",
    "13_showcase": "Current owner preview of the same approved Read Only card; visitor authority is tested separately.",
    "14_mobile": "Samsung Galaxy A06 landscape emulator, 705 x 338 native viewport; scrolling Showcase card.",
    "15_reduced_motion": "Native settings: Reduced Motion ON, effects LOW, audio OFF; receipt semantics tested separately.",
}
CAMERAS = {
    "01_starter_permanent": ([-24, 6, 22], [-4, 3, -25]),
    "02_starter_halloween": ([-24, 6, 22], [-4, 3, -25]),
    "07_legendary_reveal": ([43, 4, -32], [36, 2.5, -40]),
    "09_vault_interior": ([-17, 8, 115], [5, 4, 139]),
    "14_mobile": ([-17, 8, 115], [5, 4, 139]),
    "15_reduced_motion": ([-17, 8, 115], [5, 4, 139]),
}


def main():
    shots = []
    for suffix, caption in CAPTIONS.items():
        source = EVIDENCE / f"golden_{suffix}.jpg"
        target = source.with_suffix(".png")
        with Image.open(source) as native:
            native.save(target, "PNG")
            dimensions = list(native.size)
        camera, look_at = CAMERAS.get(suffix, (None, None))
        shots.append({
            "file": target.name,
            "caption": caption,
            "dimensions": dimensions,
            "sha256": sha256(target.read_bytes()).hexdigest(),
            "nativeSourceSha256": sha256(source.read_bytes()).hexdigest(),
            "camera": camera,
            "lookAt": look_at,
        })
    # Additional actual native views, including controller custody and failure.
    for source in sorted(EVIDENCE.glob("golden_*.jpg")):
        if source.with_suffix(".png").exists():
            continue
        with Image.open(source) as native:
            native.save(source.with_suffix(".png"), "PNG")
    manifest = {
        "date": "2026-10-06",
        "source": "Roblox Studio MCP screen_capture; actual native client state",
        "processing": "JPEG to PNG format conversion only. No retouching, composition or resizing.",
        "cameraNote": "Null means the original capture did not retain its precise camera pose.",
        "beforeEvidence": "01-before-spawn.jpg and studio_before.json only; other requested BEFORE views were not retained.",
        "shots": shots,
    }
    (EVIDENCE / "screenshots.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    perf = json.loads((EVIDENCE / "performance_native.json").read_text(encoding="utf-8"))
    perf["views"]["legendaryReveal"] = json.loads((EVIDENCE / "legendary_perf_native.json").read_text(encoding="utf-8"))
    perf["measurementScope"] = "Studio on the current workstation; emulation is not physical-device performance. Shadow pass excluded from working rendering totals."
    perf["exceptions"] = [
        "Fresh-session p95 22.18-23.54 ms exceeds the 16.67 ms reference-device target; no TA-14 closure.",
        "Earlier long-session physical-controller capture recorded p50 67.24 ms / p95 101.05 ms at ~2422 MB. See gamepad_capture_native.json; cause not established.",
        "Energy triangle query is an early receipt frame, not guaranteed to be maximum particle overdraw; 180-frame transient maximum is recorded separately.",
        "Legendary measurement uses the existing protected native DEV probe with isolated clock/RNG; it does not establish production encounter odds.",
    ]
    (EVIDENCE / "performance_native.json").write_text(json.dumps(perf, indent=2) + "\n", encoding="utf-8")
    print(f"Packaged {len(shots)} required native screenshots; six performance views.")


if __name__ == "__main__":
    main()
