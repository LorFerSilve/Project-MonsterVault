"""Regression tests for TA-15 V1 artifact and traceability enforcement."""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path

from check_integrity import check_manifest_references, check_tracked_artifacts


class IntegrityCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def write(self, name: str, contents: str) -> Path:
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(contents, encoding="utf-8")
        return path

    def manifest(self, references: str) -> None:
        self.write(
            "tests/manifest.luau",
            'return { { testId = "T15.test.check.valid", requirements = { '
            + references
            + ' } } }\n',
        )

    def test_phase_and_exact_requirement_headings_resolve(self) -> None:
        self.write("docs/technical_architecture/economy/08_economy.md", "### CLOCK-01 — Wall clock\n")
        self.write("docs/technical_architecture/verification/15_verification.md", "# Verification\n")
        self.write("docs/game_design/capture/05_capture.md", "### CAP-01 — Capture rule\n")
        self.manifest('"TA-8", "TA-8:CLOCK-01", "TA-15", "GDS-5:CAP-01"')
        self.assertEqual([], check_manifest_references(self.root))

    def test_missing_phase_and_missing_heading_are_rejected(self) -> None:
        self.write("docs/technical_architecture/economy/08_economy.md", "### CLOCK-01 — Wall clock\n")
        self.manifest('"TA-99", "TA-8:CLOCK-99"')
        issues = [finding.message for finding in check_manifest_references(self.root)]
        self.assertTrue(any("phase document not found" in issue for issue in issues))
        self.assertTrue(any("requirement heading not found" in issue for issue in issues))

    def test_narrative_and_dynamic_references_are_rejected(self) -> None:
        self.write("docs/technical_architecture/implementation/17_roadmap.md", "# Roadmap\n")
        self.manifest('"TA-17:V1 routes"')
        self.assertTrue(any("invalid requirement reference" in finding.message for finding in check_manifest_references(self.root)))
        self.manifest('"TA-17", routeId')
        self.assertTrue(any("nonempty static string list" in finding.message for finding in check_manifest_references(self.root)))

    def test_missing_manifest_is_rejected(self) -> None:
        self.assertTrue(any("manifest is missing" in finding.message for finding in check_manifest_references(self.root)))

    def test_force_added_generated_artifact_is_rejected(self) -> None:
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.write(".gitignore", "*.rbxlx\nsourcemap.json\n")
        self.write("build/MonsterVault.rbxlx", "generated")
        self.write("sourcemap.json", "generated")
        self.write("assets/reference.txt", "safe")
        subprocess.run(
            ["git", "-C", str(self.root), "add", "-f", "--", "build/MonsterVault.rbxlx", "sourcemap.json"],
            check=True,
        )
        subprocess.run(["git", "-C", str(self.root), "add", "--", "assets/reference.txt"], check=True)
        issues = check_tracked_artifacts(self.root)
        self.assertEqual({"build/MonsterVault.rbxlx", "sourcemap.json"}, {finding.path for finding in issues})

    def test_untracked_generated_files_do_not_block(self) -> None:
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.write("build/MonsterVault.rbxlx", "generated")
        self.write("assets/reference.txt", "safe")
        subprocess.run(["git", "-C", str(self.root), "add", "--", "assets/reference.txt"], check=True)
        self.assertEqual([], check_tracked_artifacts(self.root))


if __name__ == "__main__":
    unittest.main()
