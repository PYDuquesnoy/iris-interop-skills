#!/bin/sh
# PostToolUse guard for iris_execute (iris-interop-skills) — advisory note when the
# call succeeded but captured no output. Thin wrapper: exec the .py so the hook JSON
# on stdin reaches Python (a heredoc would consume stdin instead). Resolves the
# interpreter as python3 -> python -> py (Windows has no `python3`); no-op if none is
# on PATH. Never blocks.
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)
[ -n "$PY" ] || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$PY" "$DIR/silent_execute_guard.py"
