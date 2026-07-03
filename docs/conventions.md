# Conventions

Code style and structure for the Intune shell script samples. Agents and
contributors should follow these so new samples match the existing ones.

## File header

Every script starts with, in order:

1. A shebang (`#!/bin/bash`, `#!/bin/zsh`, `#!/usr/bin/env bash`, `#!/bin/dash`,
   or `#!/usr/bin/env python3`).
2. The Microsoft copyright + license header:

   ```bash
   # Copyright (c) Microsoft Corporation.
   # Licensed under the MIT License.
   ```

3. A `##` banner block with the script name, version, and a dated change log,
   for example:

   ```bash
   ############################################################################
   ##
   ## Script to install the latest <APP NAME>
   ##
   ## VER 3.0.1
   ##
   ## Change Log
   ## 2024-01-05  - Initial version
   ##
   ############################################################################
   ## Copyright (c) 2024 Microsoft Corp. All rights reserved.
   ## Licensed under the MIT License.
   ```

Most existing scripts carry a `## Copyright (c) <year> Microsoft Corp. All rights
reserved.` line followed by a `## Licensed under the MIT License.` line. **Never
remove an existing copyright notice** — add the license line beside it if it is
missing, but leave the copyright intact.

## Structure & behaviour

- **Idempotent:** safe to run repeatedly. Check for existing state before acting.
- **Non-production:** these are samples. The README disclaimer requires running
  them in a test environment — do not assume a specific production tenant.
- **Logging:** write progress to a predictable log. Existing macOS samples log
  under `/Library/Logs/Microsoft/IntuneScripts/<app>/`; echo the key steps.
- **Exit codes:** exit `0` on success and non-zero on failure so Intune reports
  status correctly.
- **Placeholders:** template scripts use `[APPNAME]` / `<APP NAME>` markers —
  replace them consistently when cloning a sample.
- **No secrets:** never commit tokens, certificates, or private keys. The
  `getBetaTokens` tool writes secrets to the gitignored `abm_auth/` directory.

## Validate before pushing

Run [`../scripts/verify.sh`](../scripts/verify.sh) — it shellchecks every `*.sh`
and syntax-checks every `*.py`.
