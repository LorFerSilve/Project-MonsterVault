"""Focused regression tests for the static TA-2 / TA-17 dependency checker."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from check_dependencies import check


class DependencyCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def module(self, name: str, source: str = "return {}\n") -> None:
        path = self.root / "src" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source, encoding="utf-8")

    def issues(self) -> list[str]:
        return [finding.message for finding in check(self.root)]

    def test_allowed_layer_and_public_domain_imports(self) -> None:
        self.module("shared/contracts/Result.luau")
        self.module("server/domains/capture/internal/Rules.luau", "return require(script.Parent.Parent.Parent.Parent.Parent.shared.contracts.Result)\n")
        self.module("server/domains/capture/CaptureContract.luau", "return require(script.Parent.internal.Rules)\n")
        self.module("server/application/FinishCapture.luau", "return require(script.Parent.Parent.domains.capture.CaptureContract)\n")
        self.module("server/bootstrap/ServerComposition.luau", "return require(script.Parent.Parent.application.FinishCapture)\n")
        self.assertEqual([], self.issues())

    def test_server_cannot_import_client(self) -> None:
        self.module("client/store/ProjectionStore.luau")
        self.module("server/bootstrap/ServerComposition.luau", "return require(script.Parent.Parent.Parent.client.store.ProjectionStore)\n")
        self.assertTrue(any("server may not import client" in issue for issue in self.issues()))

    def test_lua_source_is_scanned_too(self) -> None:
        self.module("client/store/ProjectionStore.lua")
        self.module("server/bootstrap/Forbidden.lua", "return require(script.Parent.Parent.Parent.client.store.ProjectionStore)\n")
        self.assertTrue(any("server may not import client" in issue for issue in self.issues()))

    def test_client_controller_cannot_import_bootstrap(self) -> None:
        self.module("client/bootstrap/ClientComposition.luau")
        self.module("client/controllers/SessionController.luau", "return require(script.Parent.Parent.bootstrap.ClientComposition)\n")
        self.assertTrue(any("only client bootstrap may import bootstrap" in issue for issue in self.issues()))

    def test_standalone_server_file_requires_locked_layer(self) -> None:
        self.module("server/Loose.luau")
        self.assertTrue(any("outside the locked server/client/shared layers" in issue for issue in self.issues()))

    def test_standalone_client_file_requires_locked_layer(self) -> None:
        self.module("client/Loose.luau")
        self.assertTrue(any("outside the locked server/client/shared layers" in issue for issue in self.issues()))

    def test_unknown_runtime_root_is_rejected_without_imports(self) -> None:
        self.module("extra/Loose.luau")
        self.assertTrue(any("outside the locked server/client/shared layers" in issue for issue in self.issues()))

    def test_valid_standalone_file_in_each_root(self) -> None:
        self.module("server/bootstrap/ServerComposition.luau")
        self.module("client/controllers/SessionController.luau")
        self.module("shared/contracts/Protocol.luau")
        self.assertEqual([], self.issues())

    def test_shared_cannot_import_server(self) -> None:
        self.module("server/domains/capture/CaptureContract.luau")
        self.module("shared/contracts/Protocol.luau", "return require(script.Parent.Parent.Parent.server.domains.capture.CaptureContract)\n")
        self.assertTrue(any("shared may import only shared" in issue for issue in self.issues()))

    def test_infrastructure_cannot_import_domain(self) -> None:
        self.module("server/domains/capture/CaptureContract.luau")
        self.module("server/infrastructure/networking/Gateway.luau", "return require(script.Parent.Parent.Parent.domains.capture.CaptureContract)\n")
        self.assertTrue(any("infrastructure may not import gameplay domains" in issue for issue in self.issues()))

    def test_other_domain_internal_is_forbidden(self) -> None:
        self.module("server/domains/vault/internal/State.luau")
        self.module("server/domains/capture/CaptureService.luau", "return require(script.Parent.Parent.vault.internal.State)\n")
        self.assertTrue(any("domain public API/contract" in issue for issue in self.issues()))

    def test_domain_must_use_technical_interface(self) -> None:
        self.module("server/infrastructure/clock/RobloxClock.luau")
        self.module("server/domains/capture/CaptureService.luau", "return require(script.Parent.Parent.Parent.infrastructure.clock.RobloxClock)\n")
        self.assertTrue(any("technical contract/interface" in issue for issue in self.issues()))

    def test_domain_may_import_technical_interface(self) -> None:
        self.module("server/infrastructure/clock/ClockInterface.luau")
        self.module("server/domains/capture/CaptureService.luau", "return require(script.Parent.Parent.Parent.infrastructure.clock.ClockInterface)\n")
        self.assertEqual([], self.issues())

    def test_datamodel_service_alias_is_resolved(self) -> None:
        self.module("shared/contracts/Protocol.luau")
        self.module(
            "client/networking/Transport.luau",
            'local ReplicatedStorage = game:GetService("ReplicatedStorage")\n'
            'local Shared = ReplicatedStorage:WaitForChild("MonsterVault"):WaitForChild("Shared")\n'
            'return require(Shared.Contracts.Protocol)\n',
        )
        self.assertEqual([], self.issues())

    def test_later_alias_does_not_rewrite_earlier_import(self) -> None:
        self.module("shared/contracts/Protocol.luau")
        self.module("server/domains/capture/CaptureContract.luau")
        self.module(
            "client/networking/Transport.luau",
            'local Root = game:GetService("ReplicatedStorage"):WaitForChild("MonsterVault"):WaitForChild("Shared")\n'
            'local public = require(Root.Contracts.Protocol)\n'
            'local Root = game:GetService("ServerScriptService"):WaitForChild("MonsterVaultServer")\n'
            'return public\n',
        )
        self.assertEqual([], self.issues())

    def test_inner_local_shadow_cannot_rewrite_outer_alias(self) -> None:
        self.module("shared/contracts/Protocol.luau")
        self.module(
            "client/networking/Transport.luau",
            'local Root = game:GetService("ServerScriptService"):WaitForChild("MonsterVaultServer")\n'
            'do local Root = game:GetService("ReplicatedStorage"):WaitForChild("MonsterVault"):WaitForChild("Shared") end\n'
            'return require(Root.contracts.Protocol)\n',
        )
        self.assertTrue(any("dynamic or unresolved require" in issue for issue in self.issues()))

    def test_reassigned_alias_fails_closed(self) -> None:
        self.module("shared/contracts/Protocol.luau")
        self.module(
            "client/networking/Transport.luau",
            'local Root = game:GetService("ReplicatedStorage"):WaitForChild("MonsterVault"):WaitForChild("Shared")\n'
            'Root = game:GetService("ServerScriptService"):WaitForChild("MonsterVaultServer")\n'
            'return require(Root.contracts.Protocol)\n',
        )
        self.assertTrue(any("dynamic or unresolved require" in issue for issue in self.issues()))

    def test_parameter_shadow_fails_closed(self) -> None:
        self.module("shared/contracts/Protocol.luau")
        self.module(
            "client/networking/Transport.luau",
            'local Root = game:GetService("ReplicatedStorage"):WaitForChild("MonsterVault"):WaitForChild("Shared")\n'
            'local function importFrom(Root) return require(Root.contracts.Protocol) end\n'
            'return importFrom\n',
        )
        self.assertTrue(any("dynamic or unresolved require" in issue for issue in self.issues()))

    def test_dynamic_require_fails_closed(self) -> None:
        self.module("shared/contracts/Protocol.luau")
        self.module("client/networking/Transport.luau", "local path = script.Parent.Protocol\nreturn require(path)\n")
        self.assertTrue(any("dynamic or unresolved require" in issue for issue in self.issues()))

    def test_cycle_is_reported(self) -> None:
        self.module("shared/util/A.luau", "return require(script.Parent.B)\n")
        self.module("shared/util/B.luau", "return require(script.Parent.A)\n")
        self.assertTrue(any("require cycle" in issue for issue in self.issues()))

    def test_comments_and_strings_do_not_create_edges(self) -> None:
        self.module(
            "shared/util/A.luau",
            '-- require(script.Parent.Missing)\n'
            'local note = "require(script.Parent.Missing)"\n'
            'local literal = `require(script.Parent.Missing)`\n'
            '--[[ require(script.Parent.Missing) ]]\n'
            'return {}\n',
        )
        self.assertEqual([], self.issues())

    def test_interpolated_backtick_cannot_hide_require(self) -> None:
        self.module(
            "shared/util/A.luau",
            'local message = `missing {require(script.Parent.Missing)}`\nreturn message\n',
        )
        self.assertTrue(any("interpolated backtick expression" in issue for issue in self.issues()))


if __name__ == "__main__":
    unittest.main()
