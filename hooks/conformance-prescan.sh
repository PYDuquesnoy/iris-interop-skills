#!/bin/sh
# PostToolUse conformance pre-scan for Write|Edit (iris-interop-skills) — when an interop
# .cls is written, cheaply screen that file for the mechanically-detectable anti-patterns
# (CR-1/2/4/5/7/10) and, if any match, nudge to run the conformance-reviewer agent. Thin
# wrapper: exec the .py so the hook JSON on stdin reaches Python. Resolves the interpreter
# as python3 -> python -> py (Windows has no `python3`); no-op if none is on PATH. Never blocks.
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)
[ -n "$PY" ] || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$PY" "$DIR/conformance_prescan.py"
