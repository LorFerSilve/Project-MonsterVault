# Verification, Testing, Diagnostics, Security Validation, and CI

> **Status:** Active — TA-15 Architecture Complete  
> **Authority:** Test taxonomy, deterministic verification, engine/staging validation, security/fault testing, CI trust boundaries and release evidence

This directory owns the cross-cutting verification architecture introduced by TA-15.

Primary contract:

- [15_testing_diagnostics_security_validation_and_ci_architecture.md](15_testing_diagnostics_security_validation_and_ci_architecture.md)

TA-15 defines what implementation must prove and how evidence is trusted. It does not open gameplay implementation, create production remotes/stores, or authorize production credentials in tests. Concrete test runner code, workflow YAML, pinned dev-test tooling and implementation-specific fixture modules remain TA-17 artifacts.
