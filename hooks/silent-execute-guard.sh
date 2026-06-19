#!/bin/sh
# PostToolUse guard for iris_execute (iris-interop-skills) — advisory note when the
# call succeeded but captured no output. Thin wrapper: exec the .py so the hook JSON
# on stdin reaches python (a heredoc would consume stdin instead). Requires python3
# (documented in README); degrades to a no-op if python3 is absent. Never blocks.
command -v python3 >/dev/null 2>&1 || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec python3 "$DIR/silent_execute_guard.py"
