# GitHub Copilot instructions

This repository's canonical agent context lives in [`AGENTS.md`](../AGENTS.md) at
the repository root. **Read it first.** It describes the repository layout, the
script conventions ([`docs/conventions.md`](../docs/conventions.md)), the
one-command verify loop ([`scripts/verify.sh`](../scripts/verify.sh)), and the
pull-request conventions
([`.github/instructions/telemetry.instructions.md`](instructions/telemetry.instructions.md)).

These are **sample** scripts for educating Intune administrators; they are run in
non-production / test environments only. Keep changes focused, idempotent, and
consistent with the existing `##` banner plus Microsoft copyright / MIT license
header style. Run `./scripts/verify.sh` before opening a pull request.
