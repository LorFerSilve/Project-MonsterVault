"""Check static first-party Luau imports against the TA-2 / TA-17 module graph.

Run from any directory with ``python3 scripts/ci/check_dependencies.py``. Dynamic
requires fail closed: the checker must be able to see an edge to enforce it.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOTS = {"server", "client", "shared"}
SERVER_LAYERS = {"bootstrap", "application", "domains", "infrastructure", "adapters"}
CLIENT_LAYERS = {"bootstrap", "networking", "store", "input", "controllers", "features", "presentation"}
SHARED_LAYERS = {"contracts", "config", "types", "util"}
DATA_MODEL_ROOTS = {
    ("ReplicatedStorage", "MonsterVault", "Shared"): ("shared",),
    ("ServerScriptService", "MonsterVaultServer"): ("server",),
    ("StarterPlayer", "StarterPlayerScripts", "MonsterVaultClient"): ("client",),
}


@dataclass(frozen=True)
class Token:
    kind: str
    value: str
    line: int


@dataclass(frozen=True)
class Node:
    kind: str  # "file" or "datamodel"
    value: Path | tuple[str, ...]


@dataclass(frozen=True)
class Finding:
    file: Path
    line: int
    message: str

    def __str__(self) -> str:
        return f"{self.file.as_posix()}:{self.line}: {self.message}"


def tokenize(source: str) -> list[Token]:
    """Keep only tokens needed to recognize literal require expressions.

    Comments and strings are skipped as code, so text mentioning ``require`` in
    either cannot become a false dependency edge.
    """
    result: list[Token] = []
    i = 0
    line = 1
    while i < len(source):
        start = i
        char = source[i]
        if char.isspace():
            i += 1
        elif source.startswith("--", i):
            i += 2
            if i < len(source) and source[i] == "[":
                end_eq = i + 1
                while end_eq < len(source) and source[end_eq] == "=":
                    end_eq += 1
                if end_eq < len(source) and source[end_eq] == "[":
                    close = "]" + source[i + 1 : end_eq] + "]"
                    found = source.find(close, end_eq + 1)
                    i = len(source) if found < 0 else found + len(close)
                else:
                    found = source.find("\n", i)
                    i = len(source) if found < 0 else found
            else:
                found = source.find("\n", i)
                i = len(source) if found < 0 else found
        elif char in ('"', "'", "`"):
            quote = char
            i += 1
            value = []
            interpolated = False
            while i < len(source) and source[i] != quote:
                if source[i] == "\\" and i + 1 < len(source):
                    i += 1
                elif quote == "`" and source[i] == "{":
                    # Luau executes expressions inside backtick interpolation.
                    # Until those expressions are parsed, reject this source.
                    interpolated = True
                value.append(source[i])
                i += 1
            if i < len(source):
                i += 1
            result.append(Token("interpolated" if interpolated else "string", "".join(value), line))
        elif char == "[":
            end_eq = i + 1
            while end_eq < len(source) and source[end_eq] == "=":
                end_eq += 1
            if end_eq < len(source) and source[end_eq] == "[":
                close = "]" + source[i + 1 : end_eq] + "]"
                found = source.find(close, end_eq + 1)
                i = len(source) if found < 0 else found + len(close)
                result.append(Token("string", "", line))
            else:
                i += 1
                result.append(Token("symbol", char, line))
        elif char.isalpha() or char == "_":
            i += 1
            while i < len(source) and (source[i].isalnum() or source[i] == "_"):
                i += 1
            result.append(Token("name", source[start:i], line))
        else:
            i += 1
            result.append(Token("symbol", char, line))
        line += source[start:i].count("\n")
    return result


def call_arguments(tokens: list[Token], open_index: int) -> tuple[list[Token], int] | None:
    depth = 1
    index = open_index + 1
    while index < len(tokens):
        if tokens[index].value == "(":
            depth += 1
        elif tokens[index].value == ")":
            depth -= 1
            if depth == 0:
                return tokens[open_index + 1 : index], index + 1
        index += 1
    return None


def resolve_expression(
    tokens: list[Token], source: Path, aliases: dict[str, Node], blocked_names: set[str]
) -> Node | None:
    if not tokens:
        return None
    if len(tokens) == 1 and tokens[0].kind == "string":
        value = tokens[0].value
        if value.startswith(("./", "../")):
            return Node("file", source.parent / value)
        return None

    first = tokens[0]
    if first.kind != "name":
        return None
    if first.value in blocked_names:
        return None
    if first.value in aliases:
        node = aliases[first.value]
    elif first.value == "script":
        node = Node("file", source)
    elif first.value == "game":
        node = Node("datamodel", ())
    elif first.value in {"ReplicatedStorage", "ServerScriptService", "StarterPlayer"}:
        node = Node("datamodel", (first.value,))
    else:
        return None

    index = 1
    while index < len(tokens):
        token = tokens[index]
        name = None
        if token.value == "." and index + 1 < len(tokens) and tokens[index + 1].kind == "name":
            name = tokens[index + 1].value
            index += 2
        elif (
            token.value == "["
            and index + 2 < len(tokens)
            and tokens[index + 1].kind == "string"
            and tokens[index + 2].value == "]"
        ):
            name = tokens[index + 1].value
            index += 3
        elif token.value == ":" and index + 1 < len(tokens):
            method = tokens[index + 1].value
            if method not in {"GetService", "WaitForChild", "FindFirstChild"}:
                return None
            if index + 2 >= len(tokens) or tokens[index + 2].value != "(":
                return None
            parsed = call_arguments(tokens, index + 2)
            if parsed is None or len(parsed[0]) != 1 or parsed[0][0].kind != "string":
                return None
            name = parsed[0][0].value
            index = parsed[1]
            if method == "GetService" and node != Node("datamodel", ()):
                return None
        else:
            return None
        if not name or "/" in name or "\\" in name:
            return None
        if node.kind == "file":
            path = node.value
            assert isinstance(path, Path)
            node = Node("file", path.parent if name == "Parent" else path / name)
        else:
            parts = node.value
            assert isinstance(parts, tuple)
            node = Node("datamodel", parts[:-1] if name == "Parent" else parts + (name,))
    return node


def target_path(node: Node, root: Path, files: dict[str, Path]) -> Path | None:
    if node.kind == "datamodel":
        parts = node.value
        assert isinstance(parts, tuple)
        matches = [(key, value) for key, value in DATA_MODEL_ROOTS.items() if parts[: len(key)] == key]
        if not matches:
            return None
        key, prefix = max(matches, key=lambda pair: len(pair[0]))
        path = root / "src" / Path(*prefix) / Path(*parts[len(key) :])
    else:
        path = node.value
        assert isinstance(path, Path)
    path = path.resolve()
    candidates = [path, path.with_suffix(".luau"), path.with_suffix(".lua"), path / "init.luau", path / "init.lua"]
    for candidate in candidates:
        found = files.get(str(candidate).casefold())
        if found is not None:
            return found
    return None


def is_contract(parts: tuple[str, ...]) -> bool:
    return any(part.lower() in {"contracts", "interfaces", "interface"} for part in parts[:-1]) or parts[-1].lower().endswith(("contract.luau", "interface.luau", "contract.lua", "interface.lua"))


def is_domain_public(parts: tuple[str, ...]) -> bool:
    # parts begin at src/server/domains/<domain>/...
    if len(parts) != 2:
        return False
    name = Path(parts[1]).stem.casefold()
    domain = parts[0].casefold()
    return name in {"init", "public", "api", "contract", f"{domain}public", f"{domain}api", f"{domain}contract"}


def placement_issue(source: Path, root: Path) -> str | None:
    parts = source.relative_to(root / "src").parts
    if len(parts) < 3 or parts[0] not in SOURCE_ROOTS:
        return "source module is outside the locked server/client/shared layers"
    layers = {"server": SERVER_LAYERS, "client": CLIENT_LAYERS, "shared": SHARED_LAYERS}
    if parts[1] not in layers[parts[0]]:
        return f"source module is outside a locked TA-17 {parts[0]} layer"
    return None


def check_edge(source: Path, target: Path, root: Path) -> str | None:
    src = source.relative_to(root / "src").parts
    dst = target.relative_to(root / "src").parts
    if src[0] not in SOURCE_ROOTS or dst[0] not in SOURCE_ROOTS:
        return "module is outside the locked server/client/shared roots"
    if src[0] == "shared" and dst[0] != "shared":
        return "shared may import only shared"
    if src[0] == "server" and dst[0] == "client":
        return "server may not import client"
    if src[0] == "client" and dst[0] == "server":
        return "client may not import server"
    if src[0] == "client" and dst[0] == "client" and len(src) > 1 and len(dst) > 1:
        if src[1] != "bootstrap" and dst[1] == "bootstrap":
            return "only client bootstrap may import bootstrap"
    if src[0] != "server" or dst[0] != "server":
        return None
    if len(src) < 3 or len(dst) < 3 or src[1] not in SERVER_LAYERS or dst[1] not in SERVER_LAYERS:
        return "server module is outside a locked TA-17 layer"
    source_layer, target_layer = src[1], dst[1]
    if source_layer != "bootstrap" and target_layer == "bootstrap":
        return "only server bootstrap may import bootstrap"
    if source_layer in {"domains", "infrastructure", "adapters"} and target_layer == "application":
        return f"server {source_layer} may not import application"
    if source_layer == "infrastructure" and target_layer == "domains":
        return "infrastructure may not import gameplay domains"
    if target_layer == "domains":
        target_domain = dst[2]
        same_domain = source_layer == "domains" and src[2] == target_domain
        if not same_domain and source_layer != "bootstrap" and not is_domain_public(dst[2:]):
            return "cross-domain consumers must import the domain public API/contract"
    if source_layer in {"domains", "application", "infrastructure", "adapters"} and target_layer in {"infrastructure", "adapters"}:
        if source_layer != target_layer and not is_contract(dst[2:]):
            return f"server {source_layer} may import {target_layer} only through a technical contract/interface"
    return None


def find_cycles(edges: dict[Path, list[tuple[Path, int]]], root: Path) -> list[Finding]:
    state: dict[Path, int] = {}
    stack: list[Path] = []
    findings: list[Finding] = []
    reported: set[tuple[Path, ...]] = set()

    def visit(node: Path) -> None:
        state[node] = 1
        stack.append(node)
        for target, line in edges.get(node, []):
            if state.get(target, 0) == 0:
                visit(target)
            elif state[target] == 1:
                members = tuple(stack[stack.index(target) :])
                if members not in reported:
                    reported.add(members)
                    names = " -> ".join(path.relative_to(root).as_posix() for path in (*members, target))
                    findings.append(Finding(node.relative_to(root), line, f"require cycle: {names}"))
        stack.pop()
        state[node] = 2

    for node in sorted(edges):
        if state.get(node, 0) == 0:
            visit(node)
    return findings


def check(root: Path) -> list[Finding]:
    root = root.resolve()
    source_root = root / "src"
    sources = sorted(path.resolve() for path in source_root.rglob("*") if path.is_file() and path.suffix.lower() in {".lua", ".luau"})
    files = {str(path).casefold(): path for path in sources}
    findings: list[Finding] = []
    edges: dict[Path, list[tuple[Path, int]]] = {source: [] for source in sources}
    for source in sources:
        placement = placement_issue(source, root)
        if placement is not None:
            findings.append(Finding(source.relative_to(root), 1, placement))
        tokens = tokenize(source.read_text(encoding="utf-8"))
        aliases: dict[str, Node] = {}
        declared_names: set[str] = set()
        blocked_names: set[str] = set()

        def bind(name: str, node: Node | None = None) -> None:
            # This scanner does not model full Luau lexical scopes. Once a
            # name is shadowed, fail closed for subsequent static requires.
            if name in declared_names or node is None:
                blocked_names.add(name)
            declared_names.add(name)
            if name in blocked_names:
                aliases.pop(name, None)
            else:
                aliases[name] = node

        for index, token in enumerate(tokens):
            if token.kind == "interpolated":
                findings.append(Finding(source.relative_to(root), token.line, "interpolated backtick expression is not statically checkable"))
            if token.value == "local" and index + 1 < len(tokens):
                cursor = index + 1
                if tokens[cursor].value == "function":
                    if cursor + 1 < len(tokens) and tokens[cursor + 1].kind == "name":
                        bind(tokens[cursor + 1].value)
                else:
                    names: list[str] = []
                    expect_name = True
                    while cursor < len(tokens) and tokens[cursor].line == token.line and tokens[cursor].value != "=":
                        current = tokens[cursor]
                        if expect_name and current.kind == "name":
                            names.append(current.value)
                            expect_name = False
                        elif current.value == ",":
                            expect_name = True
                        cursor += 1
                    node = None
                    if len(names) == 1 and cursor < len(tokens) and tokens[cursor].value == "=":
                        end = cursor + 1
                        while end < len(tokens) and tokens[end].line == token.line:
                            end += 1
                        node = resolve_expression(tokens[cursor + 1 : end], source, aliases, blocked_names)
                    for name in names:
                        bind(name, node if len(names) == 1 else None)
            if token.value == "function" and token.kind == "name":
                cursor = index + 1
                if cursor < len(tokens) and tokens[cursor].kind == "name" and tokens[cursor].value in aliases:
                    blocked_names.add(tokens[cursor].value)
                    aliases.pop(tokens[cursor].value, None)
                while cursor < len(tokens) and cursor - index < 16 and tokens[cursor].value != "(":
                    cursor += 1
                if cursor < len(tokens) and tokens[cursor].value == "(":
                    parsed_parameters = call_arguments(tokens, cursor)
                    if parsed_parameters is not None:
                        expect_name = True
                        depth = 0
                        for parameter in parsed_parameters[0]:
                            if parameter.value in {"(", "[", "{"}:
                                depth += 1
                            elif parameter.value in {")", "]", "}"}:
                                depth -= 1
                            elif parameter.value == "," and depth == 0:
                                expect_name = True
                            elif expect_name and depth == 0 and parameter.kind == "name":
                                bind(parameter.value)
                                expect_name = False
            if token.value == "for" and token.kind == "name":
                cursor = index + 1
                expect_name = True
                while cursor < len(tokens) and tokens[cursor].line == token.line and tokens[cursor].value not in {"=", "in"}:
                    current = tokens[cursor]
                    if expect_name and current.kind == "name":
                        bind(current.value)
                        expect_name = False
                    elif current.value == ",":
                        expect_name = True
                    cursor += 1
            if token.kind == "name" and token.value in aliases and index + 1 < len(tokens):
                next_value = tokens[index + 1].value
                previous = tokens[index - 1].value if index > 0 else ""
                assignment = next_value == "=" and (index + 2 >= len(tokens) or tokens[index + 2].value != "=")
                compound = next_value in {"+", "-", "*", "/", "%", "^"} and index + 2 < len(tokens) and tokens[index + 2].value == "="
                if (assignment or compound) and previous not in {"local", ".", ":"}:
                    blocked_names.add(token.value)
                    aliases.pop(token.value, None)
            if token.value != "require" or token.kind != "name":
                continue
            relative = source.relative_to(root)
            if index + 1 >= len(tokens) or tokens[index + 1].value != "(":
                findings.append(Finding(relative, token.line, "indirect require is not statically checkable"))
                continue
            parsed = call_arguments(tokens, index + 1)
            if parsed is None:
                findings.append(Finding(relative, token.line, "unterminated require expression"))
                continue
            node = resolve_expression(parsed[0], source, aliases, blocked_names)
            target = target_path(node, root, files) if node is not None else None
            if target is None:
                findings.append(Finding(relative, token.line, "dynamic or unresolved require; use a static first-party module path"))
                continue
            edges[source].append((target, token.line))
            issue = check_edge(source, target, root)
            if issue is not None:
                findings.append(Finding(relative, token.line, f"{issue}: {target.relative_to(root).as_posix()}"))
    findings.extend(find_cycles(edges, root))
    return sorted(findings, key=lambda item: (str(item.file), item.line, item.message))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=PROJECT_ROOT, help="repository root")
    args = parser.parse_args()
    findings = check(args.root)
    if findings:
        for finding in findings:
            print(finding)
        print(f"Architecture dependencies: FAIL ({len(findings)} issue(s))")
        return 1
    print("Architecture dependencies: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
