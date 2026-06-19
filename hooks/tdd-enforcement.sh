#!/bin/sh
# PostToolUse TDD guard for Write|Edit (iris-interop-skills) — reminds to write the
# test first when an interop component class is written without a sibling *Test*.cls.
# Thin wrapper: exec the .py so the hook JSON on stdin reaches python. Requires python3
# (documented in README); degrades to a no-op if python3 is absent. Never blocks.
command -v python3 >/dev/null 2>&1 || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec python3 "$DIR/tdd_enforcement.py"
