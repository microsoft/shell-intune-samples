#!/usr/bin/env bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#
# verify.sh — one-command verification for the Intune shell script samples.
# Runs an ADVISORY shellcheck lint over every tracked *.sh and an ENFORCED
# syntax check of every tracked *.py. Run this before opening a pull request.
#
# Note: shellcheck findings are advisory for the existing sample corpus — many
# community-contributed scripts carry long-standing style warnings, so the lint
# reports them without failing the run. Please do not introduce NEW warnings; a
# follow-up cleanup will promote shellcheck to a hard gate. Python syntax errors
# are enforced and will fail this script.
#
# Usage:  ./scripts/verify.sh

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
sc_files=0
sc_findings=0

echo "==> shell scripts (shellcheck — advisory)"
if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! out=$(shellcheck -S warning "$f" 2>&1); then
      sc_files=$((sc_files + 1))
      sc_findings=$((sc_findings + $(printf '%s\n' "$out" | grep -cE '\((error|warning|info|style)\)')))
      printf '%s\n' "$out"
    fi
  done < <(git ls-files '*.sh')
  if [ "$sc_files" -gt 0 ]; then
    echo "-- shellcheck: $sc_findings advisory finding(s) across $sc_files file(s) (non-blocking)."
  else
    echo "-- shellcheck: clean."
  fi
else
  echo "!! shellcheck not found. Install it before pushing:"
  echo "     macOS:  brew install shellcheck"
  echo "     Linux:  sudo apt-get install shellcheck"
fi

echo "==> python files (syntax check — enforced)"
if command -v python3 >/dev/null 2>&1; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! python3 -c 'import sys; compile(open(sys.argv[1], "rb").read(), sys.argv[1], "exec")' "$f"; then
      echo "SYNTAX ERROR: $f"
      fail=1
    fi
  done < <(git ls-files '*.py')
else
  echo "!! python3 not found — skipping python syntax check."
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "OK: required checks passed."
else
  echo "FAILED: python syntax error(s) above."
fi
exit "$fail"
