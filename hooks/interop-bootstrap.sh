#!/bin/sh
# SessionStart bootstrap (iris-interop-skills) — inject the core interop conventions up front so a weak
# model has them without needing to call the Skill tool. Thin wrapper: exec the .py. Resolves
# python3 -> python -> py (Windows has no `python3`); exit 0 (no injection) if none is on PATH.
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)
[ -n "$PY" ] || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$PY" "$DIR/interop_bootstrap.py"
