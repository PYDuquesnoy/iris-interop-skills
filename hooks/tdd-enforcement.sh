#!/bin/sh
# PostToolUse TDD guard for Write|Edit (iris-interop-skills) — reminds to write the
# test first when an interop component class is written without a sibling *Test*.cls.
# Thin wrapper: exec the .py so the hook JSON on stdin reaches Python. Resolves the
# interpreter as python3 -> python -> py (Windows has no `python3`); no-op if none is
# on PATH. Never blocks.
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)
[ -n "$PY" ] || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$PY" "$DIR/tdd_enforcement.py"
