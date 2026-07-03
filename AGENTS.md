# AGENTS.md — Intune Shell Script Samples

Canonical entry point for AI agents and human contributors. Read this first.

This repository is a curated collection of **sample** shell scripts maintained by
the Microsoft Intune Customer Experience Engineering (CXE) team. The samples show
how to manage **macOS** and **Linux** devices with Microsoft Intune. They are
provided for **education and "the art of the possible"** — download, test, and
adapt them, and run them only in a **non-production / test** environment.

> Classification: **non-production** (samples / learning environment). The full
> compliance audit lives in `shell-intune-samples-oss-compliance-report.md`
> (local, gitignored).

## Repository map

| Path | What's here |
| --- | --- |
| `macOS/Apps/` | Scripts that download + install macOS apps via Intune |
| `macOS/Config/` | macOS configuration / hardening samples |
| `macOS/Custom Attributes/` | Shell-based custom attribute collectors |
| `macOS/Custom Profiles/` | Sample `.mobileconfig` configuration profiles |
| `macOS/Tools/` | Helper utilities (bundle IDs, beta tokens, migration) |
| `Linux/Apps/` | Linux app install samples |
| `Linux/Config/`, `Linux/Custom Compliance/`, `Linux/Misc/`, `Linux/WSL/` | Linux config, custom compliance, and WSL samples |

## Conventions

See [docs/conventions.md](docs/conventions.md) for the full style guide. In short:

- Every script starts with a shebang, then the Microsoft copyright + MIT license
  header, then a `##` banner with name, version, and a dated change log.
- Scripts must be **idempotent** and safe to re-run.
- Log progress to a predictable location and exit non-zero on failure.
- Never commit secrets (tokens, certs, private keys).

## Build / test / validate — the verify loop

There is no compile step; the scripts themselves are the deliverable. Validate a
change before pushing with the one-command verify loop:

```bash
./scripts/verify.sh
```

It runs `shellcheck` over every tracked `*.sh` and `python3 -m py_compile` over
every `*.py`. Install `shellcheck` first (`brew install shellcheck` on macOS,
`apt-get install shellcheck` on Linux).

## Pull request conventions

See [.github/instructions/telemetry.instructions.md](.github/instructions/telemetry.instructions.md)
and [CONTRIBUTING.md](CONTRIBUTING.md).

- Branch from `master`; name branches `feature/...`, `fix/...`, or `chore/...`.
- Use short, imperative PR titles; describe what the sample does **and how it was
  tested** (OS version + Intune scenario, in a test environment).
- All contributions require the Microsoft CLA (the CLA bot guides you).
- Keep PRs focused and reasonably sized; split large changes.

## Authority Map

How agents should treat each artifact in this repo.

| Artifact | Authority |
| --- | --- |
| `AGENTS.md` (this file) | **canon** — start here |
| `docs/conventions.md` | canon — code style + structure |
| `.github/instructions/telemetry.instructions.md` | canon — PR conventions |
| `scripts/verify.sh` | canon — the verify loop |
| `README.md` | human overview — **not** agent-canonical |
| per-sample `README.md` files | human usage docs for that one sample |
| `shell-intune-samples-oss-compliance-report.md` | generated audit — local, not checked in |
