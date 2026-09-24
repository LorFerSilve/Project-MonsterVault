# TA-17 CI, Branch, Release, and Change-Control Lock

> **Status:** PASS
> **Date:** 2026-09-24

## 1. Repository reality

Repository is public and default branch is `main`.

At TA-17 review, GitHub reports no active repository rulesets. TA-17 therefore locks the required process/check contract but does not falsely claim server-side branch protection is already enforced.

The available connector in this session does not expose a ruleset mutation action, so no repository-admin rule is invented or claimed.

## 2. Public PR lane

Actual workflow:

- `.github/workflows/ci.yml`
- check name: **CI / static-build**
- GitHub-hosted `ubuntu-24.04`
- `contents: read`
- no secrets
- checkout credentials not persisted
- action references pinned to immutable commits
- Rokit cache disabled for untrusted PR baseline

Checks:

1. locked tool versions available;
2. StyLua;
3. Selene;
4. Rojo build;
5. Rojo sourcemap;
6. luau-lsp analysis once Luau exists;
7. Lune fast tests once runtime Luau exists.

Runtime Luau without `tests/runner.luau` is a CI failure.

## 3. Required check progression

Immediately after the workflow lands:

- required process check: `CI / static-build`.

By IMP-1/2, the same job already executes the fast test runner.

Future privileged checks use these stable semantic names when automation exists:

- `Engine / integration`;
- `Staging / fault-security`;
- `Release / performance-l0-l5`.

They are release gates even if temporarily manual/trusted rather than automated.

## 4. Branch workflow

- main is integration branch;
- feature implementation uses PRs;
- ordinary direct pushes to main violate the project process;
- stacked architecture PRs are an exception only for the current pre-code chain;
- squash merge is the default implementation merge method;
- branch may be deleted after merge when safe.

No mandatory approval count is locked while the project is single-maintainer; CI/evidence requirements remain mandatory.

## 5. Fork trust

Untrusted fork code:

- GitHub-hosted runner only;
- no environment secrets;
- no STG/PROD credentials;
- no persistent self-hosted personal runner;
- no pull_request_target execution of fork head.

## 6. Staging / production

STG/PROD credentials are environment-scoped and unavailable to public PRs.

Publishing stays disabled until actual external Roblox universe/place IDs and permissions are configured.

No fake IDs are accepted as a substitute.

## 7. Release candidate

A candidate must have:

- all applicable TA-15 C0/C1 evidence;
- TA-14 hard budgets passing;
- STG adapter tests for affected cloud/platform paths;
- current policy/API review for sensitive platform surfaces;
- no unresolved P0/P1 implementation defect;
- documented build/commit identity.

## 8. Change classification

### Local implementation change
No TA reopen when contracts remain intact.

### Architecture material change
Reopen owning TA and append architecture decision.

### Gameplay semantic change
Reopen owning GDS then dependent TA.

### Protocol/schema breaking change
Increment protocol/schema generation and provide migration/compatibility plan.

## 9. Enforcement follow-up

Because rulesets are not currently present, the first repository-administration opportunity after this PR chain lands should configure main to require PRs and `CI / static-build`.

This administrative enforcement strengthens the locked process but does not change its semantics.

**CI/release/change-control lock: PASS.**
