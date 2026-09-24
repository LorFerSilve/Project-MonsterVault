"""Enforce TA-15 V1 repository-artifact and test-traceability gates."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
import re
import subprocess

from check_dependencies import PROJECT_ROOT, Token, tokenize


REQUIREMENT = re.compile(r"^(TA|GDS)-(\d{1,2})(?::([A-Z][A-Z0-9-]*-\d+))?$")
GENERATED_DIRECTORIES = {
    "build",
    "dist",
    "node_modules",
    "packages",
    "devpackages",
    ".luau-lsp",
    ".test-results",
    "coverage",
    "__pycache__",
}
GENERATED_FILES = {"sourcemap.json", ".ds_store", "thumbs.db"}
GENERATED_SUFFIXES = {".rbxl", ".rbxlx", ".pyc", ".log", ".tmp", ".swp"}


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    message: str

    def __str__(self) -> str:
        return f"{self.path}:{self.line}: {self.message}"


def is_generated(path: str) -> bool:
    parts = PurePosixPath(path.replace("\\", "/")).parts
    lowered = tuple(part.casefold() for part in parts)
    name = lowered[-1]
    return (
        any(part in GENERATED_DIRECTORIES for part in lowered[:-1])
        or name in GENERATED_FILES
        or PurePosixPath(name).suffix in GENERATED_SUFFIXES
        or (name.startswith(".env") and name != ".env.example")
    )


def check_tracked_artifacts(root: Path) -> list[Finding]:
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "--cached", "--full-name", "-z"],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        detail = result.stderr.decode("utf-8", errors="replace").strip()
        return [Finding(".", 1, f"git ls-files failed: {detail}")]
    paths = [path.decode("utf-8", errors="surrogateescape") for path in result.stdout.split(b"\0") if path]
    return [Finding(path, 1, "generated/place/runtime artifact is tracked") for path in paths if is_generated(path)]


def requirement_groups(tokens: list[Token]) -> tuple[list[tuple[Token, list[Token]]], list[Finding], int]:
    groups: list[tuple[Token, list[Token]]] = []
    findings: list[Finding] = []
    test_count = 0
    for index, token in enumerate(tokens):
        if token.kind != "name" or index + 1 >= len(tokens) or tokens[index + 1].value != "=":
            continue
        if token.value == "testId":
            test_count += 1
        if token.value != "requirements":
            continue
        if index + 2 >= len(tokens) or tokens[index + 2].value != "{":
            findings.append(Finding("tests/manifest.luau", token.line, "requirements must be a static string list"))
            continue
        cursor = index + 3
        values: list[Token] = []
        expect_string = True
        valid = True
        while cursor < len(tokens) and tokens[cursor].value != "}":
            current = tokens[cursor]
            if expect_string and current.kind == "string":
                values.append(current)
                expect_string = False
            elif not expect_string and current.value == ",":
                expect_string = True
            else:
                valid = False
            cursor += 1
        if cursor >= len(tokens) or not valid or not values:
            findings.append(Finding("tests/manifest.luau", token.line, "requirements must be a nonempty static string list"))
        else:
            groups.append((token, values))
    return groups, findings, test_count


def phase_documents(root: Path, kind: str, number: int) -> list[Path]:
    section = "technical_architecture" if kind == "TA" else "game_design"
    base = root / "docs" / section
    return sorted(base.rglob(f"{number:02}_*.md"))


def check_manifest_references(root: Path) -> list[Finding]:
    manifest = root / "tests" / "manifest.luau"
    if not manifest.is_file():
        return [Finding("tests/manifest.luau", 1, "test manifest is missing")]
    groups, findings, test_count = requirement_groups(tokenize(manifest.read_text(encoding="utf-8")))
    if test_count == 0 or len(groups) != test_count:
        findings.append(Finding("tests/manifest.luau", 1, "each TestId needs a static requirements list"))
    document_cache: dict[tuple[str, int], list[Path]] = {}
    text_cache: dict[Path, str] = {}
    for _, values in groups:
        for token in values:
            reference = token.value
            parsed = REQUIREMENT.fullmatch(reference)
            if parsed is None:
                findings.append(Finding("tests/manifest.luau", token.line, f"invalid requirement reference: {reference}"))
                continue
            kind, number_text, requirement_id = parsed.groups()
            number = int(number_text)
            if number_text != str(number):
                findings.append(Finding("tests/manifest.luau", token.line, f"noncanonical phase number: {reference}"))
                continue
            key = (kind, number)
            if key not in document_cache:
                document_cache[key] = phase_documents(root, kind, number)
            documents = document_cache[key]
            if not documents:
                findings.append(Finding("tests/manifest.luau", token.line, f"phase document not found: {reference}"))
                continue
            if requirement_id is not None:
                heading = re.compile(r"^#{2,6}\s+" + re.escape(requirement_id) + r"(?=\s|$)", re.MULTILINE)
                for document in documents:
                    if document not in text_cache:
                        text_cache[document] = document.read_text(encoding="utf-8")
                if not any(heading.search(text_cache[document]) for document in documents):
                    findings.append(Finding("tests/manifest.luau", token.line, f"requirement heading not found in {kind}-{number}: {requirement_id}"))
    return findings


def check(root: Path) -> list[Finding]:
    root = root.resolve()
    return sorted(
        check_tracked_artifacts(root) + check_manifest_references(root),
        key=lambda finding: (finding.path, finding.line, finding.message),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=PROJECT_ROOT, help="repository root")
    args = parser.parse_args()
    findings = check(args.root)
    if findings:
        for finding in findings:
            print(finding)
        print(f"Repository integrity: FAIL ({len(findings)} issue(s))")
        return 1
    print("Repository integrity: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
