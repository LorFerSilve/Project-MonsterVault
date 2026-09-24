# TA-15 Roblox Testing, Security, and CI Platform Snapshot

> **Status:** PASS  
> **Snapshot date:** 2026-09-24  
> **Purpose:** Record current Roblox Studio/testing/security and GitHub Actions behavior relevant to TA-15.

## 1. Roblox Studio Testing Modes

Official source:

https://create.roblox.com/docs/studio/testing-modes

Observed current capabilities:

- ordinary Test/Test Here run distinct client and server simulations;
- Server & Clients can simulate up to **8 clients** locally;
- Team Test supports collaborative Studio testing;
- Device Simulator covers screen/device profiles;
- Network Simulator can inject latency, jitter and packet loss;
- Player Emulator supports localization/policy emulation and pseudolocalization/text elongation;
- Roblox now documents scripted testing services that can be driven programmatically from a plugin or build pipeline.

TA-15 consequence:

> Studio is the authoritative engine integration environment, but an eight-client Studio simulation alone does not prove TA-14 full-occupancy performance when configured MaxPlayers is higher.

## 2. StudioTestService / Scripted Testing

Official source:

https://create.roblox.com/docs/reference/engine/classes/StudioTestService

Current API surface includes:

- ExecuteMultiplayerTestAsync;
- ExecutePlayModeAsync;
- ExecuteRunModeAsync;
- AddPlayers;
- GetTestArgs;
- EndTest / LeaveTest.

The current testing-modes documentation also exposes:

- StudioDeviceSimulatorService;
- VirtualInput through UserInputService:CreateVirtualInput().

These services are **Studio-only** and do nothing in a published experience.

TA-15 consequence:

> MonsterVault may implement a first-party Studio test runner/plugin at TA-17 without introducing a runtime gameplay dependency.

## 3. TestService

Official source:

https://create.roblox.com/docs/reference/engine/classes/TestService

Current useful capabilities include:

- Check / Require / Fail / Error / Warn;
- checkpoints/messages;
- RunAsync;
- result counters and timeout configuration.

TA-15 consequence:

> TestService may participate in the first-party assertion/result adapter, but test identity and evidence format remain MonsterVault-owned.

## 4. Performance Diagnostics

Official sources:

https://create.roblox.com/docs/performance-optimization/identify  
https://create.roblox.com/docs/performance-optimization/microprofiler/modes  
https://create.roblox.com/docs/studio/developer-console

Current diagnostic surface includes:

- Developer Console memory/network/script information;
- Luau heap snapshots;
- Script Profiler;
- MicroProfiler frame/timer/counter views;
- client Performance Stats;
- server/client MicroProfiler access.

Roblox explicitly recommends real-client evidence for client memory rather than relying only on Studio.

TA-15 consequence:

> TA-14 performance gates require structured counters plus profiler/console evidence for regressions; real-client frame/memory evidence remains mandatory.

## 5. Roblox Client-Server Security Guidance

Official sources:

https://create.roblox.com/docs/scripting/security/client-server-boundary  
https://create.roblox.com/docs/scripting/security/security-tactics

Current guidance explicitly treats client-triggered state as hostile and requires server-side:

- context/permission validation;
- type/structure validation;
- value validation;
- rate limiting;
- protection for RemoteEvents/RemoteFunctions and client-triggered Instances;
- independent validation for ProximityPrompt/ClickDetector/DragDetector behavior;
- distrust of client-controlled physics/network ownership.

TA-15 consequence:

> Security verification is negative/adversarial and must prove both no unauthorized mutation and bounded rejection cost.

## 6. GitHub Actions: Public Repository Trust

Official source:

https://docs.github.com/en/actions/reference/security/secure-use

GitHub currently warns that:

- GitHub-hosted runners are ephemeral clean VMs;
- self-hosted runners do not receive the same clean-isolation guarantee;
- persistent self-hosted runners should almost never be used for public repositories because fork PR code can compromise the machine;
- secrets and GITHUB_TOKEN can be stolen by malicious workflow-executed code.

TA-15 consequence:

> MonsterVault's public-repository untrusted PR lane runs only on GitHub-hosted low-trust runners. Roblox Studio automation requires isolated/ephemeral trusted compute or manual controlled Studio execution until such compute exists.

## 7. pull_request_target

Official source:

https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target

Current guidance:

- pull_request_target executes with elevated base-repository trust;
- checking out and executing an untrusted PR head in that context can expose secrets/write credentials;
- ordinary pull_request is safer when privileged access is unnecessary;
- GitHub is introducing a default public-repository policy around pull_request_target.

TA-15 consequence:

> MonsterVault does not use pull_request_target to execute untrusted PR code with privileged credentials.

## 8. GitHub Evidence Retention

Official source:

https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository

Current public-repository behavior:

- default artifact/log retention is 90 days;
- public repositories can configure retention from 1 to 90 days;
- GitHub documents a retention-policy behavior change for checks/workflow runs/statuses effective 2026-10-01.

TA-15 consequence:

> Ordinary PR artifacts target 14 days; release-candidate evidence targets 90 days. TA-17 must revalidate repository settings because the documented behavior changes shortly after this snapshot date.

## 9. Toolchain Boundary

TA-1 currently pins:

- Rokit 1.2.0;
- Rojo 7.7.0;
- luau-lsp 1.69.0;
- StyLua 2.5.2;
- Selene 0.31.0;
- zero runtime third-party Luau packages.

TA-15 does not silently update these pins.

A standalone Luau execution tool may be introduced at TA-17 as a dev/test-only dependency after current-version/security review; it is not a runtime package.

## 10. Snapshot Rule

These capabilities are dated platform facts.

Before TA-17 locks concrete workflows:

- revalidate Studio testing APIs;
- revalidate GitHub Actions event/security behavior;
- revalidate action/tool versions;
- preserve stricter MonsterVault trust rules even if a platform ceiling becomes looser.

**TA-15 platform snapshot result: PASS.**
